# frozen_string_literal: true

require "ratatui_ruby"
require "set"
require "thread"

module AubergineMachine
  class TUI
    DEFAULT_STEP_DELAYS = [0.00, 0.02, 0.10, 0.30].freeze
    FULL_SPEED_STEPS_PER_TICK = 256
    RAM_SAMPLE_INTERVAL = 0.50

    THEME = {
      surface: 233,
      header: 52,
      terminal: 232,
      state: 234,
      memory: 233,
      footer: 234,
      text: 223,
      muted: 179,
      accent: 214,
      warm: 215,
      cursor: 214,
      search: 136,
      danger: 203
    }.freeze

    attr_reader :computer, :paused, :running, :speed_index, :error_message

    def initialize(computer:, start_paused: false, step_delays: DEFAULT_STEP_DELAYS)
      @computer = computer
      @step_delays = step_delays
      @speed_index = 0
      @paused = start_paused
      @running = true
      @error_message = nil
      @status_message = start_paused ? "Paused at reset vector." : "Running AubergineOS boot ROM."
      @ram_usage_cache = nil
      @ram_usage_mutex = Mutex.new
      @ram_sampler_thread = nil
      @stop_ram_sampler = false
      computer.power_on
    end

    def run
      start_ram_sampler

      RatatuiRuby.run do
        while running
          RatatuiRuby.draw { |frame| render(frame) }
          event = RatatuiRuby.poll_event(timeout: paused ? 0.10 : current_step_delay)
          process_event(event)
        end
      end

      self
    ensure
      stop_ram_sampler
    end

    def render(frame)
      header_area, body_area, footer_area = split(frame.area, :vertical, [
                                                    constraint(:length, 3),
                                                    constraint(:fill, 1),
                                                    constraint(:length, 4)
                                                  ])

      terminal_area, sidebar_area = split(body_area, :horizontal, [
                                            constraint(:fill, 1),
                                            constraint(:length, 38)
                                          ])

      state_area = sidebar_area

      frame.render_widget(header_widget, header_area)
      frame.render_widget(terminal_widget, terminal_area)
      frame.render_widget(state_widget, state_area)
      frame.render_widget(footer_widget, footer_area)
    end

    private

    def process_event(event)
      if event.none?
        autoplay_tick unless paused
        return
      end

      return handle_resize(event) if event.resize?
      return queue_pasted_input(event.content) if event.paste?
      return unless event.key?

      case
      when meta_command?(event, "q"), meta_command?(event, "esc")
        @running = false
      when meta_command?(event, "p")
        toggle_pause
      when meta_command?(event, "n")
        step_once(manual: true) if paused
      when meta_command?(event, "r")
        reset_machine
      when meta_command?(event, "f")
        set_full_speed
      when meta_command?(event, "[")
        adjust_speed(-1)
      when meta_command?(event, "]")
        adjust_speed(1)
      else
        queue_key_input(event)
      end
    end

    def handle_resize(event)
      @status_message = "Resized to #{event.width}x#{event.height}."
    end

    def step_once(manual: false)
      computer.step
      @error_message = nil
      @status_message = format("Stepped to $%04X.", computer.cpu.program_counter) if manual
    rescue StandardError => e
      @paused = true
      @error_message = e.message
      @status_message = "Execution paused due to an error."
    end

    def autoplay_tick
      steps = current_step_delay.zero? ? FULL_SPEED_STEPS_PER_TICK : 1
      steps.times { step_once }
    end

    def reset_machine
      computer.reset
      @paused = true
      @error_message = nil
      @status_message = "Machine reset. Press Meta+p to run or Meta+n to step."
    end

    def toggle_pause
      @paused = !paused
      @status_message = paused ? "Paused." : "Running at #{speed_label.downcase}."
    end

    def adjust_speed(delta)
      @speed_index = (speed_index + delta).clamp(0, @step_delays.length - 1)
      @status_message = "Autoplay speed set to #{speed_label.downcase}."
    end

    def set_full_speed
      @speed_index = 0
      @status_message = "Autoplay speed set to full speed."
    end

    def current_step_delay
      @step_delays[speed_index]
    end

    def meta_command?(event, code)
      event.code == code && meta_modifier?(event)
    end

    def meta_modifier?(event)
      event.alt? || event.meta?
    end

    def queue_key_input(event)
      bytes = key_event_bytes(event)
      return if bytes.empty?

      bytes.each { |byte| computer.terminal.enqueue_input(byte) }
    end

    def queue_pasted_input(text)
      return if text.empty?

      computer.terminal.enqueue_text(text)
      @status_message = "Queued pasted input for the virtual terminal."
    end

    def key_event_bytes(event)
      if event.ctrl? && event.code.length == 1
        [event.code.upcase.bytes.first & 0x1F]
      else
        case event.code
        when "left"
          [Devices::TextTerminal::KEY_LEFT]
        when "right"
          [Devices::TextTerminal::KEY_RIGHT]
        when "up"
          [Devices::TextTerminal::KEY_UP]
        when "down"
          [Devices::TextTerminal::KEY_DOWN]
        when "esc", "escape"
          [0x1B]
        when "enter"
          [0x0D]
        when "backspace"
          [0x08]
        when "tab"
          [0x09]
        when "space"
          [0x20]
        else
          event.code.length == 1 ? event.code.bytes : []
        end
      end
    end

    def snapshot
      computer.snapshot
    end

    def split(area, direction, constraints)
      RatatuiRuby::Layout::Layout.split(area, direction:, constraints:)
    end

    def constraint(kind, value)
      RatatuiRuby::Layout::Constraint.public_send(kind, value)
    end

    def style(fg: nil, bg: nil, modifiers: [])
      RatatuiRuby::Style::Style.new(fg:, bg:, modifiers:)
    end

    def terminal_text
      search_matches = visible_search_matches

      computer.terminal.lines.each_with_index.map do |line, row|
        RatatuiRuby::Text::Line.new(
          spans: line.chars.each_with_index.map do |char, column|
            RatatuiRuby::Text::Span.new(
              content: char,
              style: terminal_cell_style(row:, column:, char:, search_matches:)
            )
          end
        )
      end
    end

    def terminal_cell_style(row:, column:, char:, search_matches:)
      if cursor_visible_at?(row:, column:)
        style(fg: THEME[:terminal], bg: THEME[:cursor], modifiers: [:bold])
      elsif search_matches.include?([row, column])
        style(fg: THEME[:text], bg: THEME[:search], modifiers: [:bold])
      elsif char == " "
        style(fg: THEME[:muted], bg: THEME[:terminal])
      else
        style(fg: THEME[:text], bg: THEME[:terminal])
      end
    end

    def cursor_visible_at?(row:, column:)
      row == computer.terminal.cursor_row && column == computer.terminal.cursor_column
    end

    def visible_search_matches
      return Set.new unless computer.editor_active?

      search_term = computer.editor_search_term
      return Set.new if search_term.empty?

      matches = Set.new
      computer.terminal.lines.first(computer.terminal.rows - 1).each_with_index do |line, row|
        start_index = 0

        loop do
          match_index = line.index(search_term, start_index)
          break unless match_index

          search_term.length.times do |offset|
            matches << [row, match_index + offset]
          end
          start_index = match_index + 1
        end
      end

      matches
    end

    def panel_block(title, color:, background:)
      RatatuiRuby::Widgets::Block.new(
        title:,
        borders: %i[top right bottom left],
        border_style: style(fg: color, bg: background, modifiers: [:bold]),
        style: style(bg: background)
      )
    end

    def header_widget
      RatatuiRuby::Widgets::Paragraph.new(
        text: [
          "AubergineMachine  Ruby 4+  AubergineOS amber terminal",
          format("phosphor online  %s", paused ? "PAUSED" : speed_label)
        ].join("\n"),
        block: panel_block("Live Session", color: THEME[:accent], background: THEME[:header]),
        style: style(fg: THEME[:text], bg: THEME[:header], modifiers: %i[bold])
      )
    end

    def terminal_widget
      RatatuiRuby::Widgets::Paragraph.new(
        text: terminal_text,
        block: panel_block("Virtual Terminal", color: THEME[:accent], background: THEME[:terminal]),
        style: style(fg: THEME[:text], bg: THEME[:terminal])
      )
    end

    def state_widget
      RatatuiRuby::Widgets::Paragraph.new(
        text: [
          format("mode %s", paused ? "paused" : "running"),
          ram_usage_line,
          format("cursor %02d,%02d  in %d", computer.terminal.cursor_row, computer.terminal.cursor_column, computer.terminal.input_size),
          "indicators: #{computer.filesystem_indicator_label}",
          speed_label
        ].join("\n"),
        block: panel_block("Machine State", color: THEME[:warm], background: THEME[:state]),
        style: style(fg: THEME[:text], bg: THEME[:state])
      )
    end

    def footer_widget
      color = error_message ? THEME[:danger] : THEME[:muted]
      message = error_message || @status_message

      RatatuiRuby::Widgets::Paragraph.new(
        text: [
          "Status: #{message}",
          "Bench: Meta+p pause  Meta+n step  Meta+r reset  Meta+f full speed  Meta+[/] speed  Meta+q quit"
        ].join("\n"),
        block: panel_block("Command Deck", color:, background: THEME[:footer]),
        style: style(fg: THEME[:text], bg: THEME[:footer], modifiers: %i[bold])
      )
    end

    def speed_label
      return "FULL SPEED" if current_step_delay.zero?

      format("%.2fs/step", current_step_delay)
    end

    def ram_usage_line
      used = cached_ram_used_bytes
      total = ram_total_bytes
      percent = ((used.to_f / total) * 100).round(1)

      format("RAM %d/%d (%.1f%%)", used, total, percent)
    end

    def cached_ram_used_bytes
      @ram_usage_mutex.synchronize do
        @ram_usage_cache ||= ram_used_bytes
      end
    end

    def start_ram_sampler
      return if @ram_sampler_thread&.alive?

      @stop_ram_sampler = false
      @ram_sampler_thread = Thread.new do
        loop do
          break if @stop_ram_sampler

          used = ram_used_bytes
          @ram_usage_mutex.synchronize { @ram_usage_cache = used }
          sleep(RAM_SAMPLE_INTERVAL)
        end
      end
    end

    def stop_ram_sampler
      @stop_ram_sampler = true
      return unless @ram_sampler_thread

      @ram_sampler_thread.join(RAM_SAMPLE_INTERVAL * 2)
      @ram_sampler_thread = nil
    end

    def ram_used_bytes
      (MemoryMap::RAM_START..MemoryMap::RAM_END).count do |address|
        computer.read_byte(address) != 0x00
      end
    end

    def ram_total_bytes
      MemoryMap::RAM_END - MemoryMap::RAM_START + 1
    end
  end
end
