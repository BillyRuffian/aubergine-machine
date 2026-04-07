# frozen_string_literal: true

RSpec.describe AubergineMachine::TUI do
  it "powers on the machine during initialization" do
    computer = AubergineMachine::Computer.new(columns: 20, rows: 4)

    tui = described_class.new(computer:, start_paused: true)

    expect(tui.paused).to be(true)
    expect(computer.snapshot[:program_counter]).to eq(0x8000)
  end

  it "starts at full speed by default" do
    computer = AubergineMachine::Computer.new(columns: 20, rows: 4)

    tui = described_class.new(computer:)

    expect(tui.paused).to be(false)
    expect(tui.speed_index).to eq(0)
  end

  it "exposes a rooted filesystem through the computer" do
    computer = AubergineMachine::Computer.new(columns: 20, rows: 4)

    expect(computer.filesystem).to be_a(AubergineMachine::VirtualFilesystem)
  end

  it "renders the terminal cursor as a highlighted cell" do
    computer = AubergineMachine::Computer.new(columns: 4, rows: 2)

    tui = described_class.new(computer:, start_paused: true)
    computer.terminal.write_byte(AubergineMachine::Devices::TextTerminal::DATA_REGISTER, "A".ord)
    lines = tui.send(:terminal_text)

    text_span = lines.first.spans[0]
    cursor_span = lines.first.spans[1]

    expect(text_span.content).to eq("A")
    expect(text_span.style.fg).to eq(described_class::THEME[:text])
    expect(cursor_span.style.fg).to eq(described_class::THEME[:terminal])
    expect(cursor_span.style.bg).to eq(described_class::THEME[:cursor])
  end

  it "highlights visible search matches while vi is active" do
    computer = AubergineMachine::Computer.new(columns: 8, rows: 4)
    tui = described_class.new(computer:, start_paused: true)

    allow(computer).to receive(:editor_active?).and_return(true)
    allow(computer).to receive(:editor_search_term).and_return("HELL")

    "HELLO".bytes.each do |byte|
      computer.terminal.write_byte(AubergineMachine::Devices::TextTerminal::DATA_REGISTER, byte)
    end

    lines = tui.send(:terminal_text)

    expect(lines.first.spans[0].style.bg).to eq(described_class::THEME[:search])
    expect(lines.first.spans[1].style.bg).to eq(described_class::THEME[:search])
    expect(lines.first.spans[2].style.bg).to eq(described_class::THEME[:search])
    expect(lines.first.spans[3].style.bg).to eq(described_class::THEME[:search])
    expect(lines.first.spans[4].style.bg).to eq(described_class::THEME[:terminal])
  end

  it "maps ctrl chord keys to control bytes for the guest terminal" do
    computer = AubergineMachine::Computer.new(columns: 4, rows: 2)
    tui = described_class.new(computer:, start_paused: true)

    ctrl_c = RatatuiRuby::Event::Key.new(code: "c", modifiers: ["ctrl"])
    ctrl_left_bracket = RatatuiRuby::Event::Key.new(code: "[", modifiers: ["ctrl"])

    expect(tui.send(:key_event_bytes, ctrl_c)).to eq([0x03])
    expect(tui.send(:key_event_bytes, ctrl_left_bracket)).to eq([0x1B])
  end

  it "maps a plain escape keypress to the guest escape byte" do
    computer = AubergineMachine::Computer.new(columns: 4, rows: 2)
    tui = described_class.new(computer:, start_paused: true)

    esc = RatatuiRuby::Event::Key.new(code: "esc", modifiers: [])

    expect(tui.send(:key_event_bytes, esc)).to eq([0x1B])
  end

  it "maps arrow keys to guest terminal cursor bytes" do
    computer = AubergineMachine::Computer.new(columns: 4, rows: 2)
    tui = described_class.new(computer:, start_paused: true)

    left = RatatuiRuby::Event::Key.new(code: "left", modifiers: [])
    right = RatatuiRuby::Event::Key.new(code: "right", modifiers: [])
    up = RatatuiRuby::Event::Key.new(code: "up", modifiers: [])
    down = RatatuiRuby::Event::Key.new(code: "down", modifiers: [])

    expect(tui.send(:key_event_bytes, left)).to eq([AubergineMachine::Devices::TextTerminal::KEY_LEFT])
    expect(tui.send(:key_event_bytes, right)).to eq([AubergineMachine::Devices::TextTerminal::KEY_RIGHT])
    expect(tui.send(:key_event_bytes, up)).to eq([AubergineMachine::Devices::TextTerminal::KEY_UP])
    expect(tui.send(:key_event_bytes, down)).to eq([AubergineMachine::Devices::TextTerminal::KEY_DOWN])
  end
end
