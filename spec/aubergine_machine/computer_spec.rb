# frozen_string_literal: true

require "tmpdir"

RSpec.describe AubergineMachine::Computer do
  around do |example|
    Dir.mktmpdir("aubergine-machine-computer") do |dir|
      @fs_root = dir
      example.run
    end
  end

  it "boots the assembler-driven ROM and writes the banner to the terminal" do
    File.write(File.join(@fs_root, "hello.txt"), "HELLO")
    File.write(File.join(@fs_root, "notes.txt"), "NOTES")

    computer = described_class.new(columns: 80, rows: 8, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)

    screen = computer.terminal.lines.join("\n")

    expect(screen).to include("AubergineOS says hello.")
    expect(screen).to include("Type commands.")
    expect(screen).to include("Files:")
    expect(screen).to include("hello.txt")
    expect(screen).to include("notes.txt")
    expect(screen).to include("> ")
    expect(computer.snapshot[:program_counter]).to be >= 0x8000
  end

  it "prints shell help for the help command" do
    File.write(File.join(@fs_root, "hello.txt"), "HELLO")

    computer = described_class.new(columns: 80, rows: 8, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("help\r")
    computer.run(max_instructions: 1024)

    screen = computer.terminal.lines.join("\n")

    expect(screen).to include("> help")
    expect(screen).to include("Commands: help clear ls pwd")
    expect(screen).to include("cat cd cp mv mkdir touch")
    expect(screen).to include("vi asm load new pop run save")
    expect(screen).to include("edit show append write rm")
  end

  it "clears the terminal and redraws the prompt for the clear command" do
    File.write(File.join(@fs_root, "hello.txt"), "HELLO")

    computer = described_class.new(columns: 80, rows: 8, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("clear\r")
    computer.run(max_instructions: 768)

    lines = computer.terminal.lines
    screen = lines.join("\n")

    expect(lines.first).to start_with("> ")
    expect(screen).not_to include("AubergineOS says hello.")
    expect(screen).not_to include("Files:")
  end

  it "lists files for the ls command" do
    File.write(File.join(@fs_root, "hello.txt"), "HELLO")
    File.write(File.join(@fs_root, "notes.txt"), "NOTES")

    computer = described_class.new(columns: 80, rows: 10, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("ls\r")
    computer.run(max_instructions: 512)

    screen = computer.terminal.lines.join("\n")

    expect(screen).to include("> ls")
    expect(screen).to include("hello.txt")
    expect(screen).to include("notes.txt")
  end

  it "lists a requested path for ls path" do
    Dir.mkdir(File.join(@fs_root, "programs"))
    File.write(File.join(@fs_root, "programs", "alpha.txt"), "A")
    File.write(File.join(@fs_root, "programs", "beta.txt"), "B")

    computer = described_class.new(columns: 80, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("ls programs\r")
    computer.run(max_instructions: 1024)

    screen = computer.terminal.lines.join("\n")

    expect(screen).to include("> ls programs")
    expect(screen).to include("alpha.txt")
    expect(screen).to include("beta.txt")
  end

  it "changes directories and resolves later paths relative to pwd" do
    Dir.mkdir(File.join(@fs_root, "programs"))
    File.write(File.join(@fs_root, "programs", "hello.txt"), "FROM SUBDIR")

    computer = described_class.new(columns: 80, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("cd programs\rpwd\rls\rcat hello.txt\r")
    computer.run(max_instructions: 4096)

    screen = computer.terminal.lines.join("\n")

    expect(screen).to include("> cd programs")
    expect(screen).to include("Changed directory")
    expect(screen).to include("> pwd")
    expect(screen).to include("/programs")
    expect(screen).to include("> ls")
    expect(screen).to include("hello.txt")
    expect(screen).to include("> cat hello.txt")
    expect(screen).to include("FROM SUBDIR")
  end

  it "prints a friendly error when cd targets a missing path" do
    File.write(File.join(@fs_root, "hello.txt"), "HELLO")

    computer = described_class.new(columns: 80, rows: 10, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("cd missing\r")
    computer.run(max_instructions: 1024)

    screen = computer.terminal.lines.join("\n")

    expect(screen).to include("> cd missing")
    expect(screen).to include("Missing path")
  end

  it "prints a friendly error when cd targets a file" do
    File.write(File.join(@fs_root, "hello.txt"), "HELLO")

    computer = described_class.new(columns: 80, rows: 10, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("cd hello.txt\r")
    computer.run(max_instructions: 1024)

    screen = computer.terminal.lines.join("\n")

    expect(screen).to include("> cd hello.txt")
    expect(screen).to include("Not directory")
  end

  it "prints file contents for the cat command" do
    File.write(File.join(@fs_root, "hello.txt"), "HELLO")

    computer = described_class.new(columns: 80, rows: 10, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("cat hello.txt\r")
    computer.run(max_instructions: 768)

    screen = computer.terminal.lines.join("\n")

    expect(screen).to include("> cat hello.txt")
    expect(screen).to include("HELLO")
  end

  it "prints a friendly error for missing files" do
    File.write(File.join(@fs_root, "hello.txt"), "HELLO")

    computer = described_class.new(columns: 80, rows: 10, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("cat missing.txt\r")
    computer.run(max_instructions: 768)

    screen = computer.terminal.lines.join("\n")

    expect(screen).to include("> cat missing.txt")
    expect(screen).to include("Missing file")
  end

  it "loads a guest file into RAM through the shell" do
    content = "10 PRINT \"HI\""
    File.write(File.join(@fs_root, "program.basic"), content)

    computer = described_class.new(columns: 80, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("load program.basic\r")
    computer.run(max_instructions: 1024)

    screen = computer.terminal.lines.join("\n")
    ram_bytes = content.bytes.each_index.map do |index|
      computer.read_byte(AubergineMachine::MemoryMap::LOAD_BUFFER_START + index)
    end

    expect(screen).to include("> load program.basic")
    expect(screen).to include("Loaded at $0400")
    expect(ram_bytes.pack("C*")).to eq(content)
  end

  it "runs a loaded machine-code payload and returns to the shell" do
    payload = [0xA9, "Z".ord, 0x8D, 0x00, 0x7F, 0x60].pack("C*")
    File.binwrite(File.join(@fs_root, "demo.program"), payload)

    computer = described_class.new(columns: 80, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("load demo.program\rrun\r")
    computer.run(max_instructions: 2048)

    screen = computer.terminal.lines.join("\n")

    expect(screen).to include("> load demo.program")
    expect(screen).to include("Loaded at $0400")
    expect(screen).to include("> run")
    expect(screen).to include("Z")
    expect(screen).to include("> ")
  end

  it "loads and runs a named machine-code payload with run file" do
    payload = [0xA9, "Q".ord, 0x8D, 0x00, 0x7F, 0x60].pack("C*")
    File.binwrite(File.join(@fs_root, "quick.program"), payload)

    computer = described_class.new(columns: 80, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("run quick.program\r")
    computer.run(max_instructions: 2048)

    screen = computer.terminal.lines.join("\n")

    expect(screen).to include("> run quick.program")
    expect(screen).to include("Q")
    expect(screen).to include("> ")
  end

  it "assembles guest source and runs the resulting program through the shell" do
    File.write(File.join(@fs_root, "demo.asm"), <<~ASM)
      lda #'A'
      sta $7F00
      rts
    ASM

    computer = described_class.new(columns: 80, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("asm demo.asm\rrun demo.program\r")
    computer.run(max_instructions: 4096)

    screen = computer.terminal.lines.join("\n")

    expect(screen).to include("> asm demo.asm")
    expect(screen).to include("Assembled /demo.program")
    expect(screen).to include("> run demo.program")
    expect(screen).to include("A")
    expect(File.binread(File.join(@fs_root, "demo.program")).bytes).to eq([0xA9, "A".ord, 0x8D, 0x00, 0x7F, 0x60])
  end

  it "assembles guest source to a requested output path and runs it" do
    File.write(File.join(@fs_root, "demo.asm"), <<~ASM)
      lda #'B'
      sta $7F00
      rts
    ASM

    computer = described_class.new(columns: 80, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("asm demo.asm builds/demo.run\rrun builds/demo.run\r")
    computer.run(max_instructions: 4096)

    screen = computer.terminal.lines.join("\n")

    expect(screen).to include("> asm demo.asm builds/demo.run")
    expect(screen).to include("Assembled /builds/demo.run")
    expect(screen).to include("> run builds/demo.run")
    expect(screen).to include("B")
    expect(File.binread(File.join(@fs_root, "builds", "demo.run")).bytes).to eq([0xA9, "B".ord, 0x8D, 0x00, 0x7F, 0x60])
  end

  it "prints a friendly error when run is used before load" do
    File.write(File.join(@fs_root, "hello.txt"), "HELLO")

    computer = described_class.new(columns: 80, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("run\r")
    computer.run(max_instructions: 512)

    screen = computer.terminal.lines.join("\n")

    expect(screen).to include("> run")
    expect(screen).to include("Nothing loaded")
  end

  it "prints a friendly error when run file targets a missing program" do
    File.write(File.join(@fs_root, "hello.txt"), "HELLO")

    computer = described_class.new(columns: 80, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("run missing.program\r")
    computer.run(max_instructions: 1024)

    screen = computer.terminal.lines.join("\n")

    expect(screen).to include("> run missing.program")
    expect(screen).to include("Missing file")
  end

  it "prints a friendly error when asm targets invalid source" do
    File.write(File.join(@fs_root, "broken.asm"), "lda #\n")

    computer = described_class.new(columns: 80, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("asm broken.asm\r")
    computer.run(max_instructions: 2048)

    screen = computer.terminal.lines.join("\n")

    expect(screen).to include("> asm broken.asm")
    expect(screen).to include("Assembly failed")
  end

  it "prints a friendly error when run is used on text edited in the buffer" do
    File.write(File.join(@fs_root, "hello.txt"), "HELLO")

    computer = described_class.new(columns: 80, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("edit 10 PRINT \"HI\"\rrun\r")
    computer.run(max_instructions: 1536)

    screen = computer.terminal.lines.join("\n")

    expect(screen).to include("> edit 10 PRINT \"HI\"")
    expect(screen).to include("Edited buffer")
    expect(screen).to include("> run")
    expect(screen).to include("Buffer is text")
  end

  it "shows the current text buffer contents" do
    File.write(File.join(@fs_root, "hello.txt"), "HELLO")

    computer = described_class.new(columns: 80, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("edit 10 PRINT \"HI\"\rshow\r")
    computer.run(max_instructions: 2048)

    screen = computer.terminal.lines.join("\n")

    expect(screen).to include("> show")
    expect(screen).to include("10 PRINT \"HI\"")
  end

  it "clears the shared editor buffer for the new command" do
    File.write(File.join(@fs_root, "hello.txt"), "HELLO")

    computer = described_class.new(columns: 80, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("edit 10 PRINT \"HI\"\rnew\rshow\r")
    computer.run(max_instructions: 2048)

    screen = computer.terminal.lines.join("\n")

    expect(screen).to include("> new")
    expect(screen).to include("Buffer cleared")
    expect(screen).to include("> show")
    expect(screen).to include("Buffer empty")
  end

  it "removes the last edited line for the pop command" do
    File.write(File.join(@fs_root, "hello.txt"), "HELLO")

    computer = described_class.new(columns: 80, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("edit 10 PRINT \"HELLO\"\rappend 20 PRINT \"BYE\"\rpop\rshow\r")
    computer.run(max_instructions: 4608)

    lines = computer.terminal.lines
    screen = lines.join("\n")
    show_index = lines.index { |line| line.include?("> show") }

    expect(screen).to include("> pop")
    expect(screen).to include("Removed line")
    expect(screen).to include("> show")
    expect(show_index).not_to be_nil
    expect(lines[show_index + 1]).to include("10 PRINT \"HELLO\"")
    expect(lines[show_index + 2]).not_to include("20 PRINT \"BYE\"")
  end

  it "empties the editor buffer when pop removes the only line" do
    File.write(File.join(@fs_root, "hello.txt"), "HELLO")

    computer = described_class.new(columns: 80, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("edit 10 PRINT \"HI\"\rpop\rshow\r")
    computer.run(max_instructions: 2048)

    screen = computer.terminal.lines.join("\n")

    expect(screen).to include("> pop")
    expect(screen).to include("Removed line")
    expect(screen).to include("> show")
    expect(screen).to include("Buffer empty")
  end

  it "saves the loaded buffer back to the guest filesystem" do
    content = "20 PRINT \"ROUNDTRIP\""
    File.write(File.join(@fs_root, "source.basic"), content)

    computer = described_class.new(columns: 80, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("load source.basic\rsave copy.basic\r")
    computer.run(max_instructions: 2048)

    screen = computer.terminal.lines.join("\n")

    expect(screen).to include("> load source.basic")
    expect(screen).to include("Loaded at $0400")
    expect(screen).to include("> save copy.basic")
    expect(screen).to include("Saved file")
    expect(File.read(File.join(@fs_root, "copy.basic"))).to eq(content)
  end

  it "edits the load buffer in-memory and saves it to the guest filesystem" do
    File.write(File.join(@fs_root, "hello.txt"), "HELLO")

    computer = described_class.new(columns: 80, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("edit 10 PRINT \"HELLO\"\rappend 20 PRINT \"BYE\"\rshow\rsave draft.basic\r")
    computer.run(max_instructions: 4608)

    screen = computer.terminal.lines.join("\n")

    expect(screen).to include("> edit 10 PRINT \"HELLO\"")
    expect(screen).to include("Edited buffer")
    expect(screen).to include("> append 20 PRINT \"BYE\"")
    expect(screen).to include("Appended line")
    expect(screen).to include("> show")
    expect(screen).to include("10 PRINT \"HELLO\"")
    expect(screen).to include("20 PRINT \"BYE\"")
    expect(screen).to include("> save draft.basic")
    expect(screen).to include("Saved file")
    expect(File.read(File.join(@fs_root, "draft.basic"))).to eq("10 PRINT \"HELLO\"\n20 PRINT \"BYE\"")
  end

  it "edits and saves a file through the vi command" do
    File.write(File.join(@fs_root, "note.txt"), "HELLO")

    computer = described_class.new(columns: 40, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("vi note.txt\r")
    computer.terminal.enqueue_text("i!")
    computer.terminal.enqueue_input(0x1B)
    computer.terminal.enqueue_text(":w\r:q\r")
    computer.run(max_instructions: 8192)

    screen = computer.terminal.lines.join("\n")

    expect(screen).to include(":q")
    expect(screen).to include("> ")
    expect(File.read(File.join(@fs_root, "note.txt"))).to eq("!HELLO")
  end

  it "supports append-after-cursor in vi normal mode" do
    File.write(File.join(@fs_root, "note.txt"), "HELLO")

    computer = described_class.new(columns: 40, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("vi note.txt\r")
    computer.terminal.enqueue_text("a!")
    computer.terminal.enqueue_input(0x1B)
    computer.terminal.enqueue_text(":wq\r")
    computer.run(max_instructions: 8192)

    expect(File.read(File.join(@fs_root, "note.txt"))).to eq("H!ELLO")
  end

  it "opens a new line below in vi normal mode" do
    File.write(File.join(@fs_root, "note.txt"), "HELLO")

    computer = described_class.new(columns: 40, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("vi note.txt\r")
    computer.terminal.enqueue_text("oWORLD")
    computer.terminal.enqueue_input(0x1B)
    computer.terminal.enqueue_text(":wq\r")
    computer.run(max_instructions: 12_288)

    expect(File.read(File.join(@fs_root, "note.txt"))).to eq("HELLO\nWORLD")
  end

  it "deletes the current line with dd in vi normal mode" do
    File.write(File.join(@fs_root, "note.txt"), "FIRST\nSECOND")

    computer = described_class.new(columns: 40, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("vi note.txt\r")
    computer.terminal.enqueue_text("dd:wq\r")
    computer.run(max_instructions: 8192)

    expect(File.read(File.join(@fs_root, "note.txt"))).to eq("SECOND")
  end

  it "accepts cursor keys for vi movement" do
    File.write(File.join(@fs_root, "note.txt"), "HELLO")

    computer = described_class.new(columns: 40, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("vi note.txt\r")
    computer.terminal.enqueue_input(AubergineMachine::Devices::TextTerminal::KEY_RIGHT)
    computer.terminal.enqueue_text("x:wq\r")
    computer.run(max_instructions: 8192)

    expect(File.read(File.join(@fs_root, "note.txt"))).to eq("HLLO")
  end

  it "moves to the start of the line with 0 in vi normal mode" do
    File.write(File.join(@fs_root, "note.txt"), "HELLO")

    computer = described_class.new(columns: 40, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("vi note.txt\r")
    computer.terminal.enqueue_text("ll0x:wq\r")
    computer.run(max_instructions: 8192)

    expect(File.read(File.join(@fs_root, "note.txt"))).to eq("ELLO")
  end

  it "moves to the end of the line with $ in vi normal mode" do
    File.write(File.join(@fs_root, "note.txt"), "HELLO")

    computer = described_class.new(columns: 40, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("vi note.txt\r")
    computer.terminal.enqueue_text("$x:wq\r")
    computer.run(max_instructions: 8192)

    expect(File.read(File.join(@fs_root, "note.txt"))).to eq("HELL")
  end

  it "moves to the next word with w in vi normal mode" do
    File.write(File.join(@fs_root, "note.txt"), "HELLO THERE")

    computer = described_class.new(columns: 40, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("vi note.txt\r")
    computer.terminal.enqueue_text("wx:wq\r")
    computer.run(max_instructions: 8192)

    expect(File.read(File.join(@fs_root, "note.txt"))).to eq("HELLO HERE")
  end

  it "moves to the previous word with b in vi normal mode" do
    File.write(File.join(@fs_root, "note.txt"), "HELLO THERE")

    computer = described_class.new(columns: 40, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("vi note.txt\r")
    computer.terminal.enqueue_text("wbx:wq\r")
    computer.run(max_instructions: 8192)

    expect(File.read(File.join(@fs_root, "note.txt"))).to eq("ELLO THERE")
  end

  it "moves to the end of the current word with e in vi normal mode" do
    File.write(File.join(@fs_root, "note.txt"), "HELLO THERE")

    computer = described_class.new(columns: 40, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("vi note.txt\r")
    computer.terminal.enqueue_text("ex:wq\r")
    computer.run(max_instructions: 8192)

    expect(File.read(File.join(@fs_root, "note.txt"))).to eq("HELL THERE")
  end

  it "appends at the end of the line with A in vi normal mode" do
    File.write(File.join(@fs_root, "note.txt"), "HELLO")

    computer = described_class.new(columns: 40, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("vi note.txt\r")
    computer.terminal.enqueue_text("A!")
    computer.terminal.enqueue_input(0x1B)
    computer.terminal.enqueue_text(":wq\r")
    computer.run(max_instructions: 8192)

    expect(File.read(File.join(@fs_root, "note.txt"))).to eq("HELLO!")
  end

  it "opens a new line above with O in vi normal mode" do
    File.write(File.join(@fs_root, "note.txt"), "HELLO")

    computer = described_class.new(columns: 40, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("vi note.txt\r")
    computer.terminal.enqueue_text("OWORLD")
    computer.terminal.enqueue_input(0x1B)
    computer.terminal.enqueue_text(":wq\r")
    computer.run(max_instructions: 12_288)

    expect(File.read(File.join(@fs_root, "note.txt"))).to eq("WORLD\nHELLO")
  end

  it "moves to the top of the file with gg in vi normal mode" do
    File.write(File.join(@fs_root, "note.txt"), "TOP\nMIDDLE\nBOTTOM")

    computer = described_class.new(columns: 40, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("vi note.txt\r")
    computer.terminal.enqueue_text("Gggx:wq\r")
    computer.run(max_instructions: 12_288)

    expect(File.read(File.join(@fs_root, "note.txt"))).to eq("OP\nMIDDLE\nBOTTOM")
  end

  it "moves to the bottom of the file with G in vi normal mode" do
    File.write(File.join(@fs_root, "note.txt"), "TOP\nMIDDLE\nBOTTOM")

    computer = described_class.new(columns: 40, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("vi note.txt\r")
    computer.terminal.enqueue_text("Gx:wq\r")
    computer.run(max_instructions: 12_288)

    expect(File.read(File.join(@fs_root, "note.txt"))).to eq("TOP\nMIDDLE\nBOTTO")
  end

  it "deletes the current word with dw in vi normal mode" do
    File.write(File.join(@fs_root, "note.txt"), "HELLO THERE")

    computer = described_class.new(columns: 40, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("vi note.txt\r")
    computer.terminal.enqueue_text("dw:wq\r")
    computer.run(max_instructions: 8192)

    expect(File.read(File.join(@fs_root, "note.txt"))).to eq("THERE")
  end

  it "changes the current word with cw in vi normal mode" do
    File.write(File.join(@fs_root, "note.txt"), "HELLO THERE")

    computer = described_class.new(columns: 40, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("vi note.txt\r")
    computer.terminal.enqueue_text("cwHI")
    computer.terminal.enqueue_input(0x1B)
    computer.terminal.enqueue_text(":wq\r")
    computer.run(max_instructions: 12_288)

    expect(File.read(File.join(@fs_root, "note.txt"))).to eq("HI THERE")
  end

  it "replaces the current character with r in vi normal mode" do
    File.write(File.join(@fs_root, "note.txt"), "HELLO")

    computer = described_class.new(columns: 40, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("vi note.txt\r")
    computer.terminal.enqueue_text("rY:wq\r")
    computer.run(max_instructions: 8192)

    expect(File.read(File.join(@fs_root, "note.txt"))).to eq("YELLO")
  end

  it "joins the next line with J in vi normal mode" do
    File.write(File.join(@fs_root, "note.txt"), "HELLO\nWORLD")

    computer = described_class.new(columns: 40, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("vi note.txt\r")
    computer.terminal.enqueue_text("J:wq\r")
    computer.run(max_instructions: 12_288)

    expect(File.read(File.join(@fs_root, "note.txt"))).to eq("HELLO WORLD")
  end

  it "duplicates the current line with yy and p in vi normal mode" do
    File.write(File.join(@fs_root, "note.txt"), "HELLO\nBYE")

    computer = described_class.new(columns: 40, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("vi note.txt\r")
    computer.terminal.enqueue_text("yyp:wq\r")
    computer.run(max_instructions: 12_288)

    expect(File.read(File.join(@fs_root, "note.txt"))).to eq("HELLO\nHELLO\nBYE")
  end

  it "undoes the last vi change with u in normal mode" do
    File.write(File.join(@fs_root, "note.txt"), "HELLO")

    computer = described_class.new(columns: 40, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("vi note.txt\r")
    computer.terminal.enqueue_text("xu:wq\r")
    computer.run(max_instructions: 8192)

    expect(File.read(File.join(@fs_root, "note.txt"))).to eq("HELLO")
  end

  it "yanks a word with yw and pastes it before the cursor with P" do
    File.write(File.join(@fs_root, "note.txt"), "HELLO THERE")

    computer = described_class.new(columns: 40, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("vi note.txt\r")
    computer.terminal.enqueue_text("ywP:wq\r")
    computer.run(max_instructions: 12_288)

    expect(File.read(File.join(@fs_root, "note.txt"))).to eq("HELLO HELLO THERE")
  end

  it "searches with / and repeats with n in vi normal mode" do
    File.write(File.join(@fs_root, "note.txt"), "ONE\nHELLO\nBYE\nHELLO")

    computer = described_class.new(columns: 40, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("vi note.txt\r")
    computer.terminal.enqueue_text("/HELLO\rnx:wq\r")
    computer.run(max_instructions: 16_384)

    expect(File.read(File.join(@fs_root, "note.txt"))).to eq("ONE\nHELLO\nBYE\nELLO")
  end

  it "searches for the current word forward with * in vi normal mode" do
    File.write(File.join(@fs_root, "note.txt"), "ONE\nHELLO\nBYE\nHELLO")

    computer = described_class.new(columns: 40, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("vi note.txt\r")
    computer.terminal.enqueue_text("j*x:wq\r")
    computer.run(max_instructions: 16_384)

    expect(File.read(File.join(@fs_root, "note.txt"))).to eq("ONE\nHELLO\nBYE\nELLO")
  end

  it "searches for the current word backward with # in vi normal mode" do
    File.write(File.join(@fs_root, "note.txt"), "ONE\nHELLO\nBYE\nHELLO")

    computer = described_class.new(columns: 40, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("vi note.txt\r")
    computer.terminal.enqueue_text("jjj#x:wq\r")
    computer.run(max_instructions: 16_384)

    expect(File.read(File.join(@fs_root, "note.txt"))).to eq("ONE\nELLO\nBYE\nHELLO")
  end

  it "searches backward with ? in vi normal mode" do
    File.write(File.join(@fs_root, "note.txt"), "ALPHA\nBETA\nALPHA")

    computer = described_class.new(columns: 40, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("vi note.txt\r")
    computer.terminal.enqueue_text("G?ALPHA\rx:wq\r")
    computer.run(max_instructions: 16_384)

    expect(File.read(File.join(@fs_root, "note.txt"))).to eq("ALPHA\nBETA\nLPHA")
  end

  it "repeats the opposite search direction with N in vi normal mode" do
    File.write(File.join(@fs_root, "note.txt"), "ONE\nHELLO\nBYE\nHELLO")

    computer = described_class.new(columns: 40, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("vi note.txt\r")
    computer.terminal.enqueue_text("/HELLO\rNx:wq\r")
    computer.run(max_instructions: 16_384)

    expect(File.read(File.join(@fs_root, "note.txt"))).to eq("ONE\nHELLO\nBYE\nELLO")
  end

  it "quits without saving through :q!" do
    File.write(File.join(@fs_root, "note.txt"), "HELLO")

    computer = described_class.new(columns: 40, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("vi note.txt\r")
    computer.terminal.enqueue_text("x:q!\r")
    computer.run(max_instructions: 8192)

    expect(File.read(File.join(@fs_root, "note.txt"))).to eq("HELLO")
  end

  it "jumps to the matching delimiter with % in vi normal mode" do
    File.write(File.join(@fs_root, "note.txt"), "(A(B)C)")

    computer = described_class.new(columns: 40, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("vi note.txt\r")
    computer.terminal.enqueue_text("%x:wq\r")
    computer.run(max_instructions: 12_288)

    expect(File.read(File.join(@fs_root, "note.txt"))).to eq("(A(B)C")
  end

  it "jumps backward from a closing delimiter with % in vi normal mode" do
    File.write(File.join(@fs_root, "note.txt"), "(A(B)C)")

    computer = described_class.new(columns: 40, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("vi note.txt\r")
    computer.terminal.enqueue_text("$%x:wq\r")
    computer.run(max_instructions: 12_288)

    expect(File.read(File.join(@fs_root, "note.txt"))).to eq("A(B)C)")
  end

  it "prints a friendly error when save is used before load" do
    File.write(File.join(@fs_root, "hello.txt"), "HELLO")

    computer = described_class.new(columns: 80, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("save copy.basic\r")
    computer.run(max_instructions: 768)

    screen = computer.terminal.lines.join("\n")

    expect(screen).to include("> save copy.basic")
    expect(screen).to include("Nothing loaded")
  end

  it "writes a guest file through the shell" do
    File.write(File.join(@fs_root, "hello.txt"), "HELLO")

    computer = described_class.new(columns: 80, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("write notes.txt HI FROM GUEST\r")
    computer.run(max_instructions: 1536)

    screen = computer.terminal.lines.join("\n")

    expect(screen).to include("> write notes.txt HI FROM GUEST")
    expect(screen).to include("Wrote file")
    expect(File.read(File.join(@fs_root, "notes.txt"))).to eq("HI FROM GUEST")
  end

  it "copies a guest file through the shell" do
    File.write(File.join(@fs_root, "source.txt"), "HELLO COPY")

    computer = described_class.new(columns: 80, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("cp source.txt backup.txt\r")
    computer.run(max_instructions: 1536)

    screen = computer.terminal.lines.join("\n")

    expect(screen).to include("> cp source.txt backup.txt")
    expect(screen).to include("Copied file")
    expect(File.read(File.join(@fs_root, "backup.txt"))).to eq("HELLO COPY")
  end

  it "creates guest directories through the shell" do
    File.write(File.join(@fs_root, "hello.txt"), "HELLO")

    computer = described_class.new(columns: 80, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("mkdir programs\r")
    computer.run(max_instructions: 1024)
    computer.terminal.enqueue_text("mkdir programs/basic\r")
    computer.run(max_instructions: 1536)
    computer.terminal.enqueue_text("ls\r")
    computer.run(max_instructions: 768)

    screen = computer.terminal.lines.join("\n")

    expect(screen).to include("> mkdir programs")
    expect(screen).to include("> mkdir programs/basic")
    expect(screen).to include("Created directory")
    expect(screen).to include("> ls")
    expect(screen).to include("programs")
    expect(Dir.exist?(File.join(@fs_root, "programs", "basic"))).to be(true)
  end

  it "creates empty guest files through the shell" do
    File.write(File.join(@fs_root, "hello.txt"), "HELLO")

    computer = described_class.new(columns: 80, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("touch blank.txt\r")
    computer.run(max_instructions: 1024)
    computer.terminal.enqueue_text("ls\r")
    computer.run(max_instructions: 768)

    screen = computer.terminal.lines.join("\n")

    expect(screen).to include("> touch blank.txt")
    expect(screen).to include("Touched file")
    expect(screen).to include("blank.txt")
    expect(File.read(File.join(@fs_root, "blank.txt"))).to eq("")
  end

  it "moves a guest file through the shell" do
    File.write(File.join(@fs_root, "draft.txt"), "MOVE ME")

    computer = described_class.new(columns: 80, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("mv draft.txt archive.txt\r")
    computer.run(max_instructions: 2048)

    screen = computer.terminal.lines.join("\n")

    expect(screen).to include("> mv draft.txt archive.txt")
    expect(screen).to include("Moved file")
    expect(File.exist?(File.join(@fs_root, "draft.txt"))).to be(false)
    expect(File.read(File.join(@fs_root, "archive.txt"))).to eq("MOVE ME")
  end

  it "prints a friendly error when mv targets a missing source file" do
    File.write(File.join(@fs_root, "hello.txt"), "HELLO")

    computer = described_class.new(columns: 80, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("mv missing.txt archive.txt\r")
    computer.run(max_instructions: 1024)

    screen = computer.terminal.lines.join("\n")

    expect(screen).to include("> mv missing.txt archive.txt")
    expect(screen).to include("Missing file")
  end

  it "prints a friendly error when cp targets a missing source file" do
    File.write(File.join(@fs_root, "hello.txt"), "HELLO")

    computer = described_class.new(columns: 80, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("cp missing.txt backup.txt\r")
    computer.run(max_instructions: 1024)

    screen = computer.terminal.lines.join("\n")

    expect(screen).to include("> cp missing.txt backup.txt")
    expect(screen).to include("Missing file")
  end

  it "removes a guest file through the shell" do
    File.write(File.join(@fs_root, "delete-me.txt"), "BYE")

    computer = described_class.new(columns: 80, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("rm delete-me.txt\r")
    computer.run(max_instructions: 768)

    screen = computer.terminal.lines.join("\n")

    expect(screen).to include("> rm delete-me.txt")
    expect(screen).to include("Removed file")
    expect(File.exist?(File.join(@fs_root, "delete-me.txt"))).to be(false)
  end

  it "prints a friendly error when rm targets a missing file" do
    File.write(File.join(@fs_root, "hello.txt"), "HELLO")

    computer = described_class.new(columns: 80, rows: 12, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("rm missing.txt\r")
    computer.run(max_instructions: 768)

    screen = computer.terminal.lines.join("\n")

    expect(screen).to include("> rm missing.txt")
    expect(screen).to include("Missing file")
  end

  it "prints an error for unknown commands" do
    File.write(File.join(@fs_root, "hello.txt"), "HELLO")

    computer = described_class.new(columns: 80, rows: 8, fs_root: @fs_root)

    computer.power_on.run(max_instructions: 1024)
    computer.terminal.enqueue_text("xyz\r")
    computer.run(max_instructions: 384)

    screen = computer.terminal.lines.join("\n")

    expect(screen).to include("> xyz")
    expect(screen).to include("Unknown command")
  end
end
