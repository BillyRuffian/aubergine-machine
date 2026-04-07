# frozen_string_literal: true

require "tmpdir"

RSpec.describe AubergineMachine::VirtualFilesystem do
  around do |example|
    Dir.mktmpdir("aubergine-machine-fs") do |dir|
      @root = dir
      example.run
    end
  end

  subject(:filesystem) { described_class.new(root: @root) }

  it "writes and reads files inside the guest root" do
    filesystem.write("notes/hello.txt", "HELLO")

    expect(filesystem.exist?("notes/hello.txt")).to be(true)
    expect(filesystem.read("notes/hello.txt")).to eq("HELLO")
    expect(filesystem.list("notes")).to eq(["hello.txt"])
  end

  it "creates directories inside the guest root" do
    filesystem.mkdir("programs/basic")

    expect(filesystem.exist?("programs/basic")).to be(true)
    expect(filesystem.list("programs")).to eq(["basic"])
  end

  it "supports guest absolute paths and working-directory changes" do
    filesystem.mkdir("programs/basic")
    working_directory = filesystem.chdir("programs")
    filesystem.write("hello.txt", "HI", base: working_directory)

    expect(working_directory).to eq("/programs")
    expect(filesystem.read("hello.txt", base: "/programs")).to eq("HI")
    expect(filesystem.list("/programs")).to eq(["basic", "hello.txt"])
    expect(filesystem.guest_path_for("../programs/basic", base: "/programs")).to eq("/programs/basic")
  end

  it "rejects paths that escape the guest root" do
    expect do
      filesystem.write("../escape.txt", "nope")
    end.to raise_error(AubergineMachine::FilesystemError, /escapes filesystem root/)
  end

  it "reports file activity for the TUI indicator" do
    filesystem.write("notes.txt", "HELLO")

    expect(filesystem.indicator_state).to eq(:active)
    expect(filesystem.indicator_label).to eq("file write")
  end

  it "shares activity indicators across filesystem instances on the same root" do
    other = described_class.new(root: @root)

    filesystem.write("notes.txt", "HELLO")

    expect(other.indicator_state).to eq(:active)
    expect(other.indicator_label).to eq("file write")
  end

  it "does not expose the activity metadata file in directory listings" do
    filesystem.write("notes.txt", "HELLO")

    expect(filesystem.list(".")).to eq(["notes.txt"])
  end
end
