# frozen_string_literal: true

RSpec.describe AubergineMachine::Devices::TextTerminal do
  subject(:terminal) { described_class.new(columns: 4, rows: 2) }

  it "renders printable bytes onto the screen buffer" do
    "ABCD".bytes.each do |byte|
      terminal.write_byte(described_class::DATA_REGISTER, byte)
    end

    expect(terminal.lines).to eq(["ABCD", "    "])
  end

  it "handles carriage return and line feed" do
    "A\r\nB".bytes.each do |byte|
      terminal.write_byte(described_class::DATA_REGISTER, byte)
    end

    expect(terminal.lines).to eq(["A   ", "B   "])
  end

  it "clears the display through the control register" do
    "HI".bytes.each do |byte|
      terminal.write_byte(described_class::DATA_REGISTER, byte)
    end

    terminal.write_byte(described_class::CONTROL_REGISTER, described_class::CONTROL_CLEAR)

    expect(terminal.lines).to eq(["    ", "    "])
    expect(terminal.cursor_column).to eq(0)
    expect(terminal.cursor_row).to eq(0)
  end

  it "does not discard queued input when clearing the display" do
    terminal.enqueue_text("OK")

    terminal.write_byte(described_class::CONTROL_REGISTER, described_class::CONTROL_CLEAR)

    expect(terminal.read_byte(described_class::DATA_REGISTER)).to eq("O".ord)
    expect(terminal.read_byte(described_class::DATA_REGISTER)).to eq("K".ord)
  end

  it "exposes queued keyboard input through the data and status registers" do
    terminal.enqueue_text("OK")

    expect(terminal.input_pending?).to be(true)
    expect(terminal.input_size).to eq(2)
    expect(terminal.read_byte(described_class::STATUS_REGISTER)).to eq(described_class::STATUS_READY | described_class::STATUS_INPUT_PENDING)
    expect(terminal.read_byte(described_class::DATA_REGISTER)).to eq("O".ord)
    expect(terminal.read_byte(described_class::DATA_REGISTER)).to eq("K".ord)
    expect(terminal.read_byte(described_class::DATA_REGISTER)).to eq(0x00)
    expect(terminal.read_byte(described_class::STATUS_REGISTER)).to eq(described_class::STATUS_READY)
  end

  it "allows the guest to position the cursor through cursor registers" do
    terminal.write_byte(described_class::CURSOR_COLUMN_REGISTER, 2)
    terminal.write_byte(described_class::CURSOR_ROW_REGISTER, 1)
    terminal.write_byte(described_class::DATA_REGISTER, "Z".ord)

    expect(terminal.read_byte(described_class::CURSOR_COLUMN_REGISTER)).to eq(3)
    expect(terminal.read_byte(described_class::CURSOR_ROW_REGISTER)).to eq(1)
    expect(terminal.lines).to eq(["    ", "  Z "])
  end
end
