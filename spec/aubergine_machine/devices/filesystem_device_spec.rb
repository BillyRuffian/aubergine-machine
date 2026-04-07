# frozen_string_literal: true

require "tmpdir"

RSpec.describe AubergineMachine::Devices::FilesystemDevice do
  around do |example|
    Dir.mktmpdir("aubergine-machine-fs-device") do |dir|
      @filesystem = AubergineMachine::VirtualFilesystem.new(root: dir)
      example.run
    end
  end

  subject(:device) { described_class.new(filesystem: @filesystem) }

  def write_path(path)
    bytes = path.bytes
    device.write_byte(described_class::PATH_LENGTH_REGISTER, bytes.length)
    bytes.each_with_index do |byte, index|
      device.write_byte(described_class::PATH_BUFFER_START + index, byte)
    end
  end

  def write_data(text)
    bytes = text.bytes
    device.write_byte(described_class::DATA_LENGTH_LOW_REGISTER, bytes.length & 0xFF)
    device.write_byte(described_class::DATA_LENGTH_HIGH_REGISTER, (bytes.length >> 8) & 0xFF)
    bytes.each_with_index do |byte, index|
      device.write_byte(described_class::DATA_BUFFER_START + index, byte)
    end
  end

  def result_text
    length = device.read_byte(described_class::RESULT_LENGTH_LOW_REGISTER) |
             (device.read_byte(described_class::RESULT_LENGTH_HIGH_REGISTER) << 8)

    length.times.map { |index| device.read_byte(described_class::DATA_BUFFER_START + index) }.pack("C*")
  end

  it "writes and reads a guest file through memory-mapped commands" do
    write_path("notes.txt")
    write_data("HELLO")
    device.write_byte(described_class::COMMAND_REGISTER, described_class::COMMAND_WRITE)

    expect(@filesystem.read("notes.txt")).to eq("HELLO")

    write_path("notes.txt")
    device.write_byte(described_class::COMMAND_REGISTER, described_class::COMMAND_READ)

    expect(device.read_byte(described_class::STATUS_REGISTER)).to eq(described_class::STATUS_READY | described_class::STATUS_DATA_READY)
    expect(result_text).to eq("HELLO")
  end

  it "lists directory contents through the result buffer" do
    @filesystem.write("alpha.txt", "A")
    @filesystem.write("beta.txt", "B")

    write_path(".")
    device.write_byte(described_class::COMMAND_REGISTER, described_class::COMMAND_LIST)

    expect(result_text).to eq("alpha.txt\nbeta.txt")
  end

  it "deletes guest files through memory-mapped commands" do
    @filesystem.write("trash.txt", "X")

    write_path("trash.txt")
    device.write_byte(described_class::COMMAND_REGISTER, described_class::COMMAND_DELETE)

    expect(@filesystem.exist?("trash.txt")).to be(false)
    expect(device.read_byte(described_class::STATUS_REGISTER)).to eq(described_class::STATUS_READY)
    expect(device.read_byte(described_class::ERROR_CODE_REGISTER)).to eq(described_class::ERROR_NONE)
  end

  it "creates guest directories through memory-mapped commands" do
    write_path("programs/basic")
    device.write_byte(described_class::COMMAND_REGISTER, described_class::COMMAND_MKDIR)

    expect(@filesystem.list("programs")).to eq(["basic"])
    expect(device.read_byte(described_class::STATUS_REGISTER)).to eq(described_class::STATUS_READY)
    expect(device.read_byte(described_class::ERROR_CODE_REGISTER)).to eq(described_class::ERROR_NONE)
  end

  it "tracks a current working directory for guest commands" do
    @filesystem.mkdir("programs/basic")

    write_path("programs")
    device.write_byte(described_class::COMMAND_REGISTER, described_class::COMMAND_CHDIR)

    write_path("")
    device.write_byte(described_class::COMMAND_REGISTER, described_class::COMMAND_PWD)

    expect(device.current_directory).to eq("/programs")
    expect(result_text).to eq("/programs")
  end

  it "assembles guest source files into .program images through memory-mapped commands" do
    @filesystem.write("demo.asm", <<~ASM)
      lda #'R'
      sta $7F00
      rts
    ASM

    write_path("demo.asm")
    device.write_byte(described_class::COMMAND_REGISTER, described_class::COMMAND_ASSEMBLE)

    expect(device.read_byte(described_class::STATUS_REGISTER)).to eq(described_class::STATUS_READY | described_class::STATUS_DATA_READY)
    expect(result_text).to eq("/demo.program")
    expect(@filesystem.read("demo.program").bytes).to eq([0xA9, "R".ord, 0x8D, 0x00, 0x7F, 0x60])
  end

  it "assembles guest source files to a requested output path" do
    @filesystem.write("demo.asm", <<~ASM)
      lda #'S'
      sta $7F00
      rts
    ASM

    write_path("demo.asm")
    write_data("builds/demo.run")
    device.write_byte(described_class::COMMAND_REGISTER, described_class::COMMAND_ASSEMBLE)

    expect(result_text).to eq("/builds/demo.run")
    expect(@filesystem.read("builds/demo.run").bytes).to eq([0xA9, "S".ord, 0x8D, 0x00, 0x7F, 0x60])
  end

  it "uses a specific error code for assembly failures" do
    @filesystem.write("broken.asm", "lda #\n")

    write_path("broken.asm")
    device.write_byte(described_class::COMMAND_REGISTER, described_class::COMMAND_ASSEMBLE)

    expect(device.read_byte(described_class::STATUS_REGISTER)).to eq(described_class::STATUS_READY | described_class::STATUS_ERROR)
    expect(device.read_byte(described_class::ERROR_CODE_REGISTER)).to eq(described_class::ERROR_ASSEMBLY_FAILED)
  end

  it "returns a specific error when chdir targets a file" do
    @filesystem.write("notes.txt", "HELLO")

    write_path("notes.txt")
    device.write_byte(described_class::COMMAND_REGISTER, described_class::COMMAND_CHDIR)

    expect(device.read_byte(described_class::STATUS_REGISTER)).to eq(described_class::STATUS_READY | described_class::STATUS_ERROR)
    expect(device.read_byte(described_class::ERROR_CODE_REGISTER)).to eq(described_class::ERROR_NOT_DIRECTORY)
  end

  it "surfaces rooted path errors through the status register" do
    write_path("../escape.txt")
    device.write_byte(described_class::COMMAND_REGISTER, described_class::COMMAND_READ)

    expect(device.read_byte(described_class::STATUS_REGISTER)).to eq(described_class::STATUS_READY | described_class::STATUS_ERROR)
    expect(device.read_byte(described_class::ERROR_CODE_REGISTER)).to eq(described_class::ERROR_FILESYSTEM)
  end

  it "uses a specific error code for missing paths" do
    write_path("missing.txt")
    device.write_byte(described_class::COMMAND_REGISTER, described_class::COMMAND_READ)

    expect(device.read_byte(described_class::STATUS_REGISTER)).to eq(described_class::STATUS_READY | described_class::STATUS_ERROR)
    expect(device.read_byte(described_class::ERROR_CODE_REGISTER)).to eq(described_class::ERROR_NOT_FOUND)
  end
end
