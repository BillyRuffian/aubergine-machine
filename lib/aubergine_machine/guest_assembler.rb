# frozen_string_literal: true

module AubergineMachine
  class AssemblyFailedError < StandardError; end

  class GuestAssembler
    DEFAULT_OUTPUT_EXTENSION = ".program".freeze

    attr_reader :filesystem, :origin, :output_extension

    def initialize(filesystem:, origin: MemoryMap::LOAD_BUFFER_START, output_extension: DEFAULT_OUTPUT_EXTENSION)
      @filesystem = filesystem
      @origin = origin
      @output_extension = output_extension
    end

    def assemble(path, base: "/", output_path: nil)
      source = filesystem.read(path, base:)
      program = MOS6502::Assembler.new.assemble(normalized_source(source))
      binary = program.to_flat_binary(origin:)
      destination = output_path || default_output_path(path)

      filesystem.write(destination, binary, base:)
      filesystem.guest_path_for(destination, base:)
    rescue MOS6502::AssemblyError => e
      raise AssemblyFailedError, e.message
    end

    private

    def normalized_source(source)
      return source if explicit_origin?(source)

      format(".org $%04X\n%s", origin, source)
    end

    def explicit_origin?(source)
      source.each_line.any? do |line|
        stripped = line.sub(/;.*/, "").strip.downcase
        stripped.start_with?(".org")
      end
    end

    def default_output_path(path)
      source_path = path.to_s
      base = source_path.sub(/\.[^.\/]+\z/, "")
      "#{base}#{output_extension}"
    end
  end
end
