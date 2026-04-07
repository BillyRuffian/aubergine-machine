# frozen_string_literal: true

module AubergineMachine
  module Devices
    class TextTerminal < MOS6502::Device
      DATA_REGISTER = 0x00
      STATUS_REGISTER = 0x01
      CONTROL_REGISTER = 0x02
      CURSOR_COLUMN_REGISTER = 0x03
      CURSOR_ROW_REGISTER = 0x04

      STATUS_READY = 0x01
      STATUS_INPUT_PENDING = 0x02
      CONTROL_CLEAR = 0x01
      KEY_LEFT = 0x80
      KEY_RIGHT = 0x81
      KEY_UP = 0x82
      KEY_DOWN = 0x83
      SIZE = 0x05

      attr_reader :columns, :rows, :cursor_column, :cursor_row

      def initialize(columns: 40, rows: 25)
        super()
        @columns = columns
        @rows = rows
        reset
      end

      def reset
        @input_buffer = []
        clear_display
        self
      end

      def clear_display
        @cursor_column = 0
        @cursor_row = 0
        @cells = Array.new(rows) { Array.new(columns, " ".ord) }
        self
      end

      def read_byte(address)
        case address
        when DATA_REGISTER
          @input_buffer.shift || 0x00
        when STATUS_REGISTER
          STATUS_READY | (@input_buffer.empty? ? 0x00 : STATUS_INPUT_PENDING)
        when CONTROL_REGISTER
          0x00
        when CURSOR_COLUMN_REGISTER
          cursor_column
        when CURSOR_ROW_REGISTER
          cursor_row
        else
          0x00
        end
      end

      def write_byte(address, value)
        byte = value & 0xFF

        case address
        when DATA_REGISTER
          put_byte(byte)
        when CONTROL_REGISTER
          clear_display if (byte & CONTROL_CLEAR).positive?
        when CURSOR_COLUMN_REGISTER
          @cursor_column = byte.clamp(0, columns - 1)
        when CURSOR_ROW_REGISTER
          @cursor_row = byte.clamp(0, rows - 1)
        end

        byte
      end

      def size
        SIZE
      end

      def enqueue_input(value)
        @input_buffer << (value & 0xFF)
        self
      end

      def enqueue_text(text)
        text.bytes.each { |byte| enqueue_input(byte) }
        self
      end

      def input_pending?
        !@input_buffer.empty?
      end

      def input_size
        @input_buffer.length
      end

      def lines
        @cells.map { |row| row.pack("C*") }
      end

      def render
        lines.join("\n")
      end

      private

      def put_byte(byte)
        case byte
        when 0x08
          backspace
        when 0x0A
          line_feed
        when 0x0D
          carriage_return
        when 0x20..0x7E
          write_printable(byte)
        end
      end

      def backspace
        return if cursor_column.zero? && cursor_row.zero?

        if cursor_column.zero?
          @cursor_row -= 1
          @cursor_column = columns - 1
        else
          @cursor_column -= 1
        end

        @cells[cursor_row][cursor_column] = " ".ord
      end

      def line_feed
        @cursor_row += 1
        scroll_if_needed
      end

      def carriage_return
        @cursor_column = 0
      end

      def write_printable(byte)
        @cells[cursor_row][cursor_column] = byte
        @cursor_column += 1
        return unless cursor_column >= columns

        @cursor_column = 0
        @cursor_row += 1
        scroll_if_needed
      end

      def scroll_if_needed
        return unless cursor_row >= rows

        @cells.shift
        @cells << Array.new(columns, " ".ord)
        @cursor_row = rows - 1
      end
    end
  end
end
