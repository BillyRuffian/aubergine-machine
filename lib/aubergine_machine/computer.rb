# frozen_string_literal: true

module AubergineMachine
  class Computer
    attr_reader :machine, :terminal, :boot_rom, :filesystem, :filesystem_device

    def initialize(columns: 40, rows: 25, banner: Roms::BootRom::DEFAULT_BANNER, fs_root: VirtualFilesystem.default_root)
      @terminal = Devices::TextTerminal.new(columns:, rows:)
      @boot_rom = Roms::BootRom.new(banner:, terminal_columns: columns, terminal_rows: rows)
      @filesystem = VirtualFilesystem.new(root: fs_root)
      @filesystem_device = Devices::FilesystemDevice.new(filesystem:)
      @machine = MOS6502::Machine.new

      machine.map_ram(
        start_address: MemoryMap::RAM_START,
        end_address: MemoryMap::RAM_END
      )
      machine.map_device(
        terminal,
        start_address: MemoryMap::TERMINAL_START,
        end_address: MemoryMap::TERMINAL_END
      )
      machine.map_device(
        filesystem_device,
        start_address: MemoryMap::FILESYSTEM_START,
        end_address: MemoryMap::FILESYSTEM_END
      )
      machine.map_rom(
        boot_rom.image,
        start_address: MemoryMap::ROM_START,
        end_address: MemoryMap::ROM_END
      )
    end

    def cpu
      machine.cpu
    end

    def power_on
      machine.power_on
      self
    end

    def reset
      power_on
    end

    def step
      machine.step
      self
    end

    def run(max_instructions:)
      machine.run(max_instructions:)
      self
    end

    def read_byte(address)
      cpu.read_byte(address)
    end

    def read_bytes(address, length)
      length.times.map { |offset| read_byte(address + offset) }
    end

    def snapshot
      cpu.snapshot
    end

    def filesystem_indicator_label
      filesystem.indicator_label
    end

    def editor_active?
      read_byte(MemoryMap::EDITOR_ACTIVE_ADDRESS) != 0x00
    end

    def editor_search_term
      length = read_byte(MemoryMap::EDITOR_SEARCH_LENGTH_ADDRESS)
      return "" if length.zero?

      read_bytes(MemoryMap::EDITOR_SEARCH_BUFFER_START, length).pack("C*")
    end
  end
end
