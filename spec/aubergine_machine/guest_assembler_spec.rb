# frozen_string_literal: true

require "tmpdir"

RSpec.describe AubergineMachine::GuestAssembler do
  around do |example|
    Dir.mktmpdir("aubergine-machine-guest-assembler") do |dir|
      @filesystem = AubergineMachine::VirtualFilesystem.new(root: dir)
      example.run
    end
  end

  it "assembles guest source into a runnable .program image at $0400 by default" do
    @filesystem.write("demo.asm", <<~ASM)
      lda #'Z'
      sta $7F00
      rts
    ASM

    assembler = described_class.new(filesystem: @filesystem)
    output_path = assembler.assemble("demo.asm")

    expect(output_path).to eq("/demo.program")
    expect(@filesystem.read("demo.program").bytes).to eq([0xA9, "Z".ord, 0x8D, 0x00, 0x7F, 0x60])
  end

  it "respects an explicit .org in the source file" do
    @filesystem.write("offset.asm", <<~ASM)
      .org $0402
      .byte $11, $22
    ASM

    assembler = described_class.new(filesystem: @filesystem)
    assembler.assemble("offset.asm")

    expect(@filesystem.read("offset.program").bytes).to eq([0x00, 0x00, 0x11, 0x22])
  end

  it "writes to a caller-provided output path when requested" do
    @filesystem.write("demo.asm", <<~ASM)
      lda #'X'
      sta $7F00
      rts
    ASM

    assembler = described_class.new(filesystem: @filesystem)
    output_path = assembler.assemble("demo.asm", output_path: "builds/demo.run")

    expect(output_path).to eq("/builds/demo.run")
    expect(@filesystem.read("builds/demo.run").bytes).to eq([0xA9, "X".ord, 0x8D, 0x00, 0x7F, 0x60])
  end

  it "raises a project-specific error for assembly failures" do
    @filesystem.write("broken.asm", "lda #\n")

    assembler = described_class.new(filesystem: @filesystem)

    expect { assembler.assemble("broken.asm") }.to raise_error(AubergineMachine::AssemblyFailedError)
  end
end
