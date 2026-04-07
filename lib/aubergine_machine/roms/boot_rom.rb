# frozen_string_literal: true

module AubergineMachine
  module Roms
    class BootRom
      HELP_LENGTH = 0x04
      CLEAR_LENGTH = 0x05
      LS_LENGTH = 0x02
      LS_MIN_LENGTH = 0x04
      LS_ARGUMENT_OFFSET = 0x03
      PWD_LENGTH = 0x03
      CD_MIN_LENGTH = 0x04
      CD_ARGUMENT_OFFSET = 0x03
      VI_MIN_LENGTH = 0x04
      VI_ARGUMENT_OFFSET = 0x03
      ASM_MIN_LENGTH = 0x05
      ASM_ARGUMENT_OFFSET = 0x04
      SHOW_LENGTH = 0x04
      CAT_MIN_LENGTH = 0x05
      CAT_ARGUMENT_OFFSET = 0x04
      CP_MIN_LENGTH = 0x04
      CP_ARGUMENT_OFFSET = 0x03
      MKDIR_MIN_LENGTH = 0x07
      MKDIR_ARGUMENT_OFFSET = 0x06
      LOAD_MIN_LENGTH = 0x06
      LOAD_ARGUMENT_OFFSET = 0x05
      NEW_LENGTH = 0x03
      POP_LENGTH = 0x03
      RUN_LENGTH = 0x03
      RUN_MIN_LENGTH = 0x05
      RUN_ARGUMENT_OFFSET = 0x04
      SAVE_MIN_LENGTH = 0x06
      SAVE_ARGUMENT_OFFSET = 0x05
      EDIT_MIN_LENGTH = 0x05
      EDIT_ARGUMENT_OFFSET = 0x05
      APPEND_MIN_LENGTH = 0x07
      APPEND_ARGUMENT_OFFSET = 0x07
      MV_MIN_LENGTH = 0x04
      MV_ARGUMENT_OFFSET = 0x03
      TOUCH_MIN_LENGTH = 0x06
      TOUCH_ARGUMENT_OFFSET = 0x06
      WRITE_MIN_LENGTH = 0x06
      WRITE_ARGUMENT_OFFSET = 0x06
      RM_MIN_LENGTH = 0x04
      RM_ARGUMENT_OFFSET = 0x03

      DEFAULT_BANNER = "AubergineOS says hello.\r\nType commands.\r\n".freeze
      DEFAULT_DIRECTORY_HEADER = "Files:\r\n".freeze
      DEFAULT_PROMPT = "> ".freeze
      DEFAULT_HELP = "Commands: help clear ls pwd\r\ncat cd cp mv mkdir touch\r\nvi asm load new pop run save\r\nedit show append write rm\r\n".freeze
      DEFAULT_UNKNOWN = "Unknown command\r\n".freeze
      DEFAULT_FILESYSTEM_ERROR = "FS ERR\r\n".freeze
      DEFAULT_MISSING_FILE = "Missing file\r\n".freeze
      DEFAULT_MISSING_PATH = "Missing path\r\n".freeze
      DEFAULT_NOT_DIRECTORY = "Not directory\r\n".freeze
      DEFAULT_CD_USAGE = "Usage: cd <path>\r\n".freeze
      DEFAULT_CD_OK = "Changed directory\r\n".freeze
      DEFAULT_VI_USAGE = "Usage: vi <file>\r\n".freeze
      DEFAULT_ASM_USAGE = "Usage: asm <file> [output]\r\n".freeze
      DEFAULT_ASM_OK_PREFIX = "Assembled ".freeze
      DEFAULT_ASSEMBLY_FAILED = "Assembly failed\r\n".freeze
      DEFAULT_CP_USAGE = "Usage: cp <src> <dst>\r\n".freeze
      DEFAULT_CP_OK = "Copied file\r\n".freeze
      DEFAULT_MKDIR_USAGE = "Usage: mkdir <path>\r\n".freeze
      DEFAULT_MKDIR_OK = "Created directory\r\n".freeze
      DEFAULT_MV_USAGE = "Usage: mv <src> <dst>\r\n".freeze
      DEFAULT_MV_OK = "Moved file\r\n".freeze
      DEFAULT_TOUCH_USAGE = "Usage: touch <file>\r\n".freeze
      DEFAULT_TOUCH_OK = "Touched file\r\n".freeze
      DEFAULT_LOAD_USAGE = "Usage: load <file>\r\n".freeze
      DEFAULT_LOAD_OK = "Loaded at $0400\r\n".freeze
      DEFAULT_LOAD_TRUNCATED = "Load truncated\r\n".freeze
      DEFAULT_RUN_MISSING = "Nothing loaded\r\n".freeze
      DEFAULT_RUN_TEXT = "Buffer is text\r\n".freeze
      DEFAULT_SAVE_USAGE = "Usage: save <file>\r\n".freeze
      DEFAULT_SAVE_OK = "Saved file\r\n".freeze
      DEFAULT_EDIT_USAGE = "Usage: edit <text>\r\n".freeze
      DEFAULT_EDIT_OK = "Edited buffer\r\n".freeze
      DEFAULT_NEW_OK = "Buffer cleared\r\n".freeze
      DEFAULT_POP_OK = "Removed line\r\n".freeze
      DEFAULT_SHOW_EMPTY = "Buffer empty\r\n".freeze
      DEFAULT_APPEND_USAGE = "Usage: append <text>\r\n".freeze
      DEFAULT_APPEND_OK = "Appended line\r\n".freeze
      DEFAULT_BUFFER_FULL = "Buffer full\r\n".freeze
      DEFAULT_WRITE_USAGE = "Usage: write <file> <text>\r\n".freeze
      DEFAULT_WRITE_OK = "Wrote file\r\n".freeze
      DEFAULT_RM_USAGE = "Usage: rm <file>\r\n".freeze
      DEFAULT_RM_OK = "Removed file\r\n".freeze

      attr_reader :banner, :directory_header, :prompt, :help_text, :unknown_text, :filesystem_error_text,
                  :missing_file_text, :missing_path_text, :not_directory_text, :cd_usage_text, :cd_ok_text,
                  :vi_usage_text, :asm_usage_text, :asm_ok_prefix_text, :assembly_failed_text,
                  :cp_usage_text, :cp_ok_text, :mkdir_usage_text, :mkdir_ok_text,
                  :mv_usage_text, :mv_ok_text, :touch_usage_text, :touch_ok_text,
                  :load_usage_text, :load_ok_text,
                  :load_truncated_text, :run_missing_text,
                  :run_text_text, :save_usage_text, :save_ok_text, :edit_usage_text, :edit_ok_text,
                  :new_ok_text, :pop_ok_text,
                  :show_empty_text, :append_usage_text, :append_ok_text, :buffer_full_text,
                  :write_usage_text, :write_ok_text, :rm_usage_text, :rm_ok_text

      def initialize(
        banner: DEFAULT_BANNER,
        directory_header: DEFAULT_DIRECTORY_HEADER,
        prompt: DEFAULT_PROMPT,
        terminal_columns: 40,
        terminal_rows: 25,
        help_text: DEFAULT_HELP,
        unknown_text: DEFAULT_UNKNOWN,
        filesystem_error_text: DEFAULT_FILESYSTEM_ERROR,
        missing_file_text: DEFAULT_MISSING_FILE,
        missing_path_text: DEFAULT_MISSING_PATH,
        not_directory_text: DEFAULT_NOT_DIRECTORY,
        cd_usage_text: DEFAULT_CD_USAGE,
        cd_ok_text: DEFAULT_CD_OK,
        vi_usage_text: DEFAULT_VI_USAGE,
        asm_usage_text: DEFAULT_ASM_USAGE,
        asm_ok_prefix_text: DEFAULT_ASM_OK_PREFIX,
        assembly_failed_text: DEFAULT_ASSEMBLY_FAILED,
        cp_usage_text: DEFAULT_CP_USAGE,
        cp_ok_text: DEFAULT_CP_OK,
        mkdir_usage_text: DEFAULT_MKDIR_USAGE,
        mkdir_ok_text: DEFAULT_MKDIR_OK,
        mv_usage_text: DEFAULT_MV_USAGE,
        mv_ok_text: DEFAULT_MV_OK,
        touch_usage_text: DEFAULT_TOUCH_USAGE,
        touch_ok_text: DEFAULT_TOUCH_OK,
        load_usage_text: DEFAULT_LOAD_USAGE,
        load_ok_text: DEFAULT_LOAD_OK,
        load_truncated_text: DEFAULT_LOAD_TRUNCATED,
        run_missing_text: DEFAULT_RUN_MISSING,
        run_text_text: DEFAULT_RUN_TEXT,
        save_usage_text: DEFAULT_SAVE_USAGE,
        save_ok_text: DEFAULT_SAVE_OK,
        edit_usage_text: DEFAULT_EDIT_USAGE,
        edit_ok_text: DEFAULT_EDIT_OK,
        new_ok_text: DEFAULT_NEW_OK,
        pop_ok_text: DEFAULT_POP_OK,
        show_empty_text: DEFAULT_SHOW_EMPTY,
        append_usage_text: DEFAULT_APPEND_USAGE,
        append_ok_text: DEFAULT_APPEND_OK,
        buffer_full_text: DEFAULT_BUFFER_FULL,
        write_usage_text: DEFAULT_WRITE_USAGE,
        write_ok_text: DEFAULT_WRITE_OK,
        rm_usage_text: DEFAULT_RM_USAGE,
        rm_ok_text: DEFAULT_RM_OK
      )
        @banner = banner
        @directory_header = directory_header
        @prompt = prompt
        @terminal_columns = terminal_columns
        @terminal_rows = terminal_rows
        @help_text = help_text
        @unknown_text = unknown_text
        @filesystem_error_text = filesystem_error_text
        @missing_file_text = missing_file_text
        @missing_path_text = missing_path_text
        @not_directory_text = not_directory_text
        @cd_usage_text = cd_usage_text
        @cd_ok_text = cd_ok_text
        @vi_usage_text = vi_usage_text
        @asm_usage_text = asm_usage_text
        @asm_ok_prefix_text = asm_ok_prefix_text
        @assembly_failed_text = assembly_failed_text
        @cp_usage_text = cp_usage_text
        @cp_ok_text = cp_ok_text
        @mkdir_usage_text = mkdir_usage_text
        @mkdir_ok_text = mkdir_ok_text
        @mv_usage_text = mv_usage_text
        @mv_ok_text = mv_ok_text
        @touch_usage_text = touch_usage_text
        @touch_ok_text = touch_ok_text
        @load_usage_text = load_usage_text
        @load_ok_text = load_ok_text
        @load_truncated_text = load_truncated_text
        @run_missing_text = run_missing_text
        @run_text_text = run_text_text
        @save_usage_text = save_usage_text
        @save_ok_text = save_ok_text
        @edit_usage_text = edit_usage_text
        @edit_ok_text = edit_ok_text
        @new_ok_text = new_ok_text
        @pop_ok_text = pop_ok_text
        @show_empty_text = show_empty_text
        @append_usage_text = append_usage_text
        @append_ok_text = append_ok_text
        @buffer_full_text = buffer_full_text
        @write_usage_text = write_usage_text
        @write_ok_text = write_ok_text
        @rm_usage_text = rm_usage_text
        @rm_ok_text = rm_ok_text
      end

      def program
        @program ||= MOS6502::Assembler.new.assemble(source)
      end

      def image
        program.to_flat_binary(
          origin: MemoryMap::ROM_START,
          size: MemoryMap::ROM_END - MemoryMap::ROM_START + 1,
          fill_byte: 0xEA
        )
      end

      def source
        template
          .gsub("%TERMINAL_ADDRESS%", format("$%04X", MemoryMap::TERMINAL_START))
          .gsub("%STATUS_ADDRESS%", format("$%04X", MemoryMap::TERMINAL_START + 1))
          .gsub("%TERMINAL_CONTROL_ADDRESS%", format("$%04X", MemoryMap::TERMINAL_START + Devices::TextTerminal::CONTROL_REGISTER))
          .gsub("%TERMINAL_CURSOR_COLUMN_ADDRESS%", format("$%04X", MemoryMap::TERMINAL_START + Devices::TextTerminal::CURSOR_COLUMN_REGISTER))
          .gsub("%TERMINAL_CURSOR_ROW_ADDRESS%", format("$%04X", MemoryMap::TERMINAL_START + Devices::TextTerminal::CURSOR_ROW_REGISTER))
          .gsub("%KEY_LEFT%", format("$%02X", Devices::TextTerminal::KEY_LEFT))
          .gsub("%KEY_RIGHT%", format("$%02X", Devices::TextTerminal::KEY_RIGHT))
          .gsub("%KEY_UP%", format("$%02X", Devices::TextTerminal::KEY_UP))
          .gsub("%KEY_DOWN%", format("$%02X", Devices::TextTerminal::KEY_DOWN))
          .gsub("%COMMAND_LENGTH_ADDRESS%", format("$%04X", MemoryMap::SHELL_SCRATCH_START))
          .gsub("%EDITOR_CURSOR_INDEX_ADDRESS%", format("$%04X", MemoryMap::SHELL_SCRATCH_START + 1))
          .gsub("%PRINT_POINTER_LOW_ADDRESS%", format("$%04X", MemoryMap::SHELL_SCRATCH_START + 2))
          .gsub("%PRINT_POINTER_HIGH_ADDRESS%", format("$%04X", MemoryMap::SHELL_SCRATCH_START + 3))
          .gsub("%WRITE_SEPARATOR_INDEX_ADDRESS%", format("$%04X", MemoryMap::SHELL_SCRATCH_START + 4))
          .gsub("%WRITE_DATA_LENGTH_ADDRESS%", format("$%04X", MemoryMap::SHELL_SCRATCH_START + 5))
          .gsub("%LOAD_PRESENT_ADDRESS%", format("$%04X", MemoryMap::SHELL_SCRATCH_START + 6))
          .gsub("%LOAD_LENGTH_LOW_ADDRESS%", format("$%04X", MemoryMap::SHELL_SCRATCH_START + 7))
          .gsub("%LOAD_LENGTH_HIGH_ADDRESS%", format("$%04X", MemoryMap::SHELL_SCRATCH_START + 8))
          .gsub("%LOAD_RUNNABLE_ADDRESS%", format("$%04X", MemoryMap::SHELL_SCRATCH_START + 9))
          .gsub("%EDITOR_MODE_ADDRESS%", format("$%04X", MemoryMap::SHELL_SCRATCH_START + 10))
          .gsub("%EDITOR_COMMAND_LENGTH_ADDRESS%", format("$%04X", MemoryMap::SHELL_SCRATCH_START + 11))
          .gsub("%EDITOR_PATH_LENGTH_ADDRESS%", format("$%04X", MemoryMap::SHELL_SCRATCH_START + 12))
          .gsub("%EDITOR_DIRTY_ADDRESS%", format("$%04X", MemoryMap::SHELL_SCRATCH_START + 13))
          .gsub("%EDITOR_TARGET_COLUMN_ADDRESS%", format("$%04X", MemoryMap::SHELL_SCRATCH_START + 14))
          .gsub("%EDITOR_PENDING_KEY_ADDRESS%", format("$%04X", MemoryMap::SHELL_SCRATCH_START + 15))
          .gsub("%COMMAND_BUFFER_ADDRESS%", format("$%04X", MemoryMap::COMMAND_BUFFER_START))
          .gsub("%COMMAND_BUFFER_MAX_INDEX%", format("$%02X", MemoryMap::COMMAND_BUFFER_SIZE - 1))
          .gsub("%EDITOR_PATH_BUFFER_ADDRESS%", format("$%04X", MemoryMap::EDITOR_PATH_BUFFER_START))
          .gsub("%EDITOR_COMMAND_BUFFER_ADDRESS%", format("$%04X", MemoryMap::EDITOR_COMMAND_BUFFER_START))
          .gsub("%EDITOR_COMMAND_BUFFER_MAX_INDEX%", format("$%02X", MemoryMap::EDITOR_COMMAND_BUFFER_SIZE - 1))
          .gsub("%EDITOR_YANK_BUFFER_ADDRESS%", format("$%04X", MemoryMap::EDITOR_YANK_BUFFER_START))
          .gsub("%EDITOR_YANK_BUFFER_SIZE%", format("$%02X", MemoryMap::EDITOR_YANK_BUFFER_SIZE))
          .gsub("%EDITOR_UNDO_BUFFER_ADDRESS%", format("$%04X", MemoryMap::EDITOR_UNDO_BUFFER_START))
          .gsub("%EDITOR_UNDO_LENGTH_ADDRESS%", format("$%04X", MemoryMap::EDITOR_UNDO_META_START))
          .gsub("%EDITOR_UNDO_CURSOR_ADDRESS%", format("$%04X", MemoryMap::EDITOR_UNDO_META_START + 1))
          .gsub("%EDITOR_UNDO_VALID_ADDRESS%", format("$%04X", MemoryMap::EDITOR_UNDO_META_START + 2))
          .gsub("%EDITOR_UNDO_PRESENT_ADDRESS%", format("$%04X", MemoryMap::EDITOR_UNDO_META_START + 3))
          .gsub("%EDITOR_UNDO_DIRTY_ADDRESS%", format("$%04X", MemoryMap::EDITOR_UNDO_META_START + 4))
          .gsub("%EDITOR_SEARCH_BUFFER_ADDRESS%", format("$%04X", MemoryMap::EDITOR_SEARCH_BUFFER_START))
          .gsub("%EDITOR_SEARCH_BUFFER_SIZE%", format("$%02X", MemoryMap::EDITOR_SEARCH_BUFFER_SIZE))
          .gsub("%EDITOR_SEARCH_LENGTH_ADDRESS%", format("$%04X", MemoryMap::EDITOR_SEARCH_LENGTH_ADDRESS))
          .gsub("%EDITOR_SEARCH_DIRECTION_ADDRESS%", format("$%04X", MemoryMap::EDITOR_SEARCH_DIRECTION_ADDRESS))
          .gsub("%EDITOR_ACTIVE_ADDRESS%", format("$%04X", MemoryMap::EDITOR_ACTIVE_ADDRESS))
          .gsub("%LOAD_BUFFER_MAX_INDEX%", format("$%02X", MemoryMap::LOAD_BUFFER_SIZE - 1))
          .gsub("%TERMINAL_COLUMNS%", format("$%02X", @terminal_columns))
          .gsub("%TERMINAL_LAST_ROW%", format("$%02X", @terminal_rows - 1))
          .gsub("%TERMINAL_TEXT_LAST_ROW%", format("$%02X", @terminal_rows - 2))
          .gsub("%HELP_LENGTH%", format("$%02X", HELP_LENGTH))
          .gsub("%CLEAR_LENGTH%", format("$%02X", CLEAR_LENGTH))
          .gsub("%LS_LENGTH%", format("$%02X", LS_LENGTH))
          .gsub("%LS_MIN_LENGTH%", format("$%02X", LS_MIN_LENGTH))
          .gsub("%LS_ARGUMENT_OFFSET%", format("$%02X", LS_ARGUMENT_OFFSET))
          .gsub("%PWD_LENGTH%", format("$%02X", PWD_LENGTH))
          .gsub("%CD_MIN_LENGTH%", format("$%02X", CD_MIN_LENGTH))
          .gsub("%CD_ARGUMENT_OFFSET%", format("$%02X", CD_ARGUMENT_OFFSET))
          .gsub("%VI_MIN_LENGTH%", format("$%02X", VI_MIN_LENGTH))
          .gsub("%VI_ARGUMENT_OFFSET%", format("$%02X", VI_ARGUMENT_OFFSET))
          .gsub("%ASM_MIN_LENGTH%", format("$%02X", ASM_MIN_LENGTH))
          .gsub("%ASM_ARGUMENT_OFFSET%", format("$%02X", ASM_ARGUMENT_OFFSET))
          .gsub("%SHOW_LENGTH%", format("$%02X", SHOW_LENGTH))
          .gsub("%CAT_MIN_LENGTH%", format("$%02X", CAT_MIN_LENGTH))
          .gsub("%CAT_ARGUMENT_OFFSET%", format("$%02X", CAT_ARGUMENT_OFFSET))
          .gsub("%CP_MIN_LENGTH%", format("$%02X", CP_MIN_LENGTH))
          .gsub("%CP_ARGUMENT_OFFSET%", format("$%02X", CP_ARGUMENT_OFFSET))
          .gsub("%MKDIR_MIN_LENGTH%", format("$%02X", MKDIR_MIN_LENGTH))
          .gsub("%MKDIR_ARGUMENT_OFFSET%", format("$%02X", MKDIR_ARGUMENT_OFFSET))
          .gsub("%LOAD_MIN_LENGTH%", format("$%02X", LOAD_MIN_LENGTH))
          .gsub("%LOAD_ARGUMENT_OFFSET%", format("$%02X", LOAD_ARGUMENT_OFFSET))
          .gsub("%NEW_LENGTH%", format("$%02X", NEW_LENGTH))
          .gsub("%POP_LENGTH%", format("$%02X", POP_LENGTH))
          .gsub("%RUN_LENGTH%", format("$%02X", RUN_LENGTH))
          .gsub("%RUN_MIN_LENGTH%", format("$%02X", RUN_MIN_LENGTH))
          .gsub("%RUN_ARGUMENT_OFFSET%", format("$%02X", RUN_ARGUMENT_OFFSET))
          .gsub("%SAVE_MIN_LENGTH%", format("$%02X", SAVE_MIN_LENGTH))
          .gsub("%SAVE_ARGUMENT_OFFSET%", format("$%02X", SAVE_ARGUMENT_OFFSET))
          .gsub("%EDIT_MIN_LENGTH%", format("$%02X", EDIT_MIN_LENGTH))
          .gsub("%EDIT_ARGUMENT_OFFSET%", format("$%02X", EDIT_ARGUMENT_OFFSET))
          .gsub("%APPEND_MIN_LENGTH%", format("$%02X", APPEND_MIN_LENGTH))
          .gsub("%APPEND_ARGUMENT_OFFSET%", format("$%02X", APPEND_ARGUMENT_OFFSET))
          .gsub("%MV_MIN_LENGTH%", format("$%02X", MV_MIN_LENGTH))
          .gsub("%MV_ARGUMENT_OFFSET%", format("$%02X", MV_ARGUMENT_OFFSET))
          .gsub("%TOUCH_MIN_LENGTH%", format("$%02X", TOUCH_MIN_LENGTH))
          .gsub("%TOUCH_ARGUMENT_OFFSET%", format("$%02X", TOUCH_ARGUMENT_OFFSET))
          .gsub("%WRITE_MIN_LENGTH%", format("$%02X", WRITE_MIN_LENGTH))
          .gsub("%WRITE_ARGUMENT_OFFSET%", format("$%02X", WRITE_ARGUMENT_OFFSET))
          .gsub("%RM_MIN_LENGTH%", format("$%02X", RM_MIN_LENGTH))
          .gsub("%RM_ARGUMENT_OFFSET%", format("$%02X", RM_ARGUMENT_OFFSET))
          .gsub("%FS_STATUS_ADDRESS%", format("$%04X", MemoryMap::FILESYSTEM_START + Devices::FilesystemDevice::STATUS_REGISTER))
          .gsub("%FS_COMMAND_ADDRESS%", format("$%04X", MemoryMap::FILESYSTEM_START + Devices::FilesystemDevice::COMMAND_REGISTER))
          .gsub("%FS_PATH_LENGTH_ADDRESS%", format("$%04X", MemoryMap::FILESYSTEM_START + Devices::FilesystemDevice::PATH_LENGTH_REGISTER))
          .gsub("%FS_DATA_LENGTH_LOW_ADDRESS%", format("$%04X", MemoryMap::FILESYSTEM_START + Devices::FilesystemDevice::DATA_LENGTH_LOW_REGISTER))
          .gsub("%FS_DATA_LENGTH_HIGH_ADDRESS%", format("$%04X", MemoryMap::FILESYSTEM_START + Devices::FilesystemDevice::DATA_LENGTH_HIGH_REGISTER))
          .gsub("%FS_RESULT_LENGTH_LOW_ADDRESS%", format("$%04X", MemoryMap::FILESYSTEM_START + Devices::FilesystemDevice::RESULT_LENGTH_LOW_REGISTER))
          .gsub("%FS_ERROR_CODE_ADDRESS%", format("$%04X", MemoryMap::FILESYSTEM_START + Devices::FilesystemDevice::ERROR_CODE_REGISTER))
          .gsub("%FS_PATH_BUFFER_ADDRESS%", format("$%04X", MemoryMap::FILESYSTEM_START + Devices::FilesystemDevice::PATH_BUFFER_START))
          .gsub("%FS_DATA_BUFFER_ADDRESS%", format("$%04X", MemoryMap::FILESYSTEM_START + Devices::FilesystemDevice::DATA_BUFFER_START))
          .gsub("%LOAD_BUFFER_ADDRESS%", format("$%04X", MemoryMap::LOAD_BUFFER_START))
          .gsub("%FS_COMMAND_LIST%", format("$%02X", Devices::FilesystemDevice::COMMAND_LIST))
          .gsub("%FS_COMMAND_READ%", format("$%02X", Devices::FilesystemDevice::COMMAND_READ))
          .gsub("%FS_COMMAND_WRITE%", format("$%02X", Devices::FilesystemDevice::COMMAND_WRITE))
          .gsub("%FS_COMMAND_DELETE%", format("$%02X", Devices::FilesystemDevice::COMMAND_DELETE))
          .gsub("%FS_COMMAND_MKDIR%", format("$%02X", Devices::FilesystemDevice::COMMAND_MKDIR))
          .gsub("%FS_COMMAND_CHDIR%", format("$%02X", Devices::FilesystemDevice::COMMAND_CHDIR))
          .gsub("%FS_COMMAND_PWD%", format("$%02X", Devices::FilesystemDevice::COMMAND_PWD))
          .gsub("%FS_COMMAND_ASSEMBLE%", format("$%02X", Devices::FilesystemDevice::COMMAND_ASSEMBLE))
          .gsub("%FS_ERROR_NOT_FOUND%", format("$%02X", Devices::FilesystemDevice::ERROR_NOT_FOUND))
          .gsub("%FS_ERROR_NOT_DIRECTORY%", format("$%02X", Devices::FilesystemDevice::ERROR_NOT_DIRECTORY))
          .gsub("%FS_ERROR_ASSEMBLY_FAILED%", format("$%02X", Devices::FilesystemDevice::ERROR_ASSEMBLY_FAILED))
          .gsub("%TERMINAL_CLEAR_CONTROL%", format("$%02X", Devices::TextTerminal::CONTROL_CLEAR))
          .gsub("%BANNER_BYTES%", encoded_bytes(banner))
          .gsub("%DIRECTORY_HEADER_BYTES%", encoded_bytes(directory_header))
          .gsub("%PROMPT_BYTES%", encoded_bytes(prompt))
          .gsub("%HELP_BYTES%", encoded_bytes(help_text))
          .gsub("%UNKNOWN_BYTES%", encoded_bytes(unknown_text))
          .gsub("%FS_ERROR_BYTES%", encoded_bytes(filesystem_error_text))
          .gsub("%MISSING_FILE_BYTES%", encoded_bytes(missing_file_text))
          .gsub("%MISSING_PATH_BYTES%", encoded_bytes(missing_path_text))
          .gsub("%NOT_DIRECTORY_BYTES%", encoded_bytes(not_directory_text))
          .gsub("%CD_USAGE_BYTES%", encoded_bytes(cd_usage_text))
          .gsub("%CD_OK_BYTES%", encoded_bytes(cd_ok_text))
          .gsub("%VI_USAGE_BYTES%", encoded_bytes(vi_usage_text))
          .gsub("%ASM_USAGE_BYTES%", encoded_bytes(asm_usage_text))
          .gsub("%ASM_OK_PREFIX_BYTES%", encoded_bytes(asm_ok_prefix_text))
          .gsub("%ASSEMBLY_FAILED_BYTES%", encoded_bytes(assembly_failed_text))
          .gsub("%CP_USAGE_BYTES%", encoded_bytes(cp_usage_text))
          .gsub("%CP_OK_BYTES%", encoded_bytes(cp_ok_text))
          .gsub("%MKDIR_USAGE_BYTES%", encoded_bytes(mkdir_usage_text))
          .gsub("%MKDIR_OK_BYTES%", encoded_bytes(mkdir_ok_text))
          .gsub("%MV_USAGE_BYTES%", encoded_bytes(mv_usage_text))
          .gsub("%MV_OK_BYTES%", encoded_bytes(mv_ok_text))
          .gsub("%TOUCH_USAGE_BYTES%", encoded_bytes(touch_usage_text))
          .gsub("%TOUCH_OK_BYTES%", encoded_bytes(touch_ok_text))
          .gsub("%LOAD_USAGE_BYTES%", encoded_bytes(load_usage_text))
          .gsub("%LOAD_OK_BYTES%", encoded_bytes(load_ok_text))
          .gsub("%LOAD_TRUNCATED_BYTES%", encoded_bytes(load_truncated_text))
          .gsub("%RUN_MISSING_BYTES%", encoded_bytes(run_missing_text))
          .gsub("%RUN_TEXT_BYTES%", encoded_bytes(run_text_text))
          .gsub("%SAVE_USAGE_BYTES%", encoded_bytes(save_usage_text))
          .gsub("%SAVE_OK_BYTES%", encoded_bytes(save_ok_text))
          .gsub("%EDIT_USAGE_BYTES%", encoded_bytes(edit_usage_text))
          .gsub("%EDIT_OK_BYTES%", encoded_bytes(edit_ok_text))
          .gsub("%NEW_OK_BYTES%", encoded_bytes(new_ok_text))
          .gsub("%POP_OK_BYTES%", encoded_bytes(pop_ok_text))
          .gsub("%SHOW_EMPTY_BYTES%", encoded_bytes(show_empty_text))
          .gsub("%APPEND_USAGE_BYTES%", encoded_bytes(append_usage_text))
          .gsub("%APPEND_OK_BYTES%", encoded_bytes(append_ok_text))
          .gsub("%BUFFER_FULL_BYTES%", encoded_bytes(buffer_full_text))
          .gsub("%WRITE_USAGE_BYTES%", encoded_bytes(write_usage_text))
          .gsub("%WRITE_OK_BYTES%", encoded_bytes(write_ok_text))
          .gsub("%RM_USAGE_BYTES%", encoded_bytes(rm_usage_text))
          .gsub("%RM_OK_BYTES%", encoded_bytes(rm_ok_text))
      end

      private

      def template
        @template ||= begin
          _, data = File.read(__FILE__).split(/^__END__\n/, 2)
          raise "Missing ROM template in #{__FILE__}" unless data

          data
        end
      end

      def encoded_bytes(text)
        text.bytes.map { |byte| format("$%02X", byte) }.join(", ")
      end
    end
  end
end
__END__
; AubergineMachine boot ROM

.org $8000

; Zero-page scratch layout:
; %COMMAND_LENGTH_ADDRESS% = current command length
; %PRINT_POINTER_LOW_ADDRESS%/%PRINT_POINTER_HIGH_ADDRESS% = pointer used by print_string
; %WRITE_SEPARATOR_INDEX_ADDRESS% = separator index for "write"
; %WRITE_DATA_LENGTH_ADDRESS% = data length for "write"
; %LOAD_PRESENT_ADDRESS% = nonzero when the load buffer holds data
; %LOAD_LENGTH_LOW_ADDRESS% = length of the current load buffer
; %LOAD_LENGTH_HIGH_ADDRESS% = unused load high byte in shell mode, yank metadata in vi mode
; %LOAD_RUNNABLE_ADDRESS% = nonzero when the load buffer can be executed with "run"
; %COMMAND_BUFFER_ADDRESS% = shell command buffer
; %EDITOR_YANK_BUFFER_ADDRESS% = vi yank buffer for copied/deleted text
; %EDITOR_UNDO_BUFFER_ADDRESS% = vi undo snapshot buffer
; %EDITOR_SEARCH_BUFFER_ADDRESS% = vi last-search buffer
; %EDITOR_SEARCH_DIRECTION_ADDRESS% = 0 for "/", 1 for "?"
; %EDITOR_ACTIVE_ADDRESS% = nonzero while the full-screen vi editor is active
; %LOAD_BUFFER_ADDRESS% = load buffer for guest-side program and text work
;
; Command parser conventions:
; - *_LENGTH and *_MIN_LENGTH include the keyword and any required space.
; - *_ARGUMENT_OFFSET points at the first byte after the separating space.
; - The load buffer is shared by both loaded machine code and edited text.
; - The line editor currently supports replace, append, clear, show, and pop.
; - The vi editor stores yanked text in a separate RAM buffer so command mode and
;   paste operations do not fight over the same workspace.
; - The vi editor keeps a one-step undo snapshot of the whole edit buffer.
; - "/" uses the command buffer for live prompt entry, then copies the confirmed
;   term into a persistent search buffer so "n" can repeat it later.
; - "%" only does bracket matching when the cursor is already on (), [], or {}.
; - Multi-argument commands like "write", "cp", and "mv" scan for later spaces in
;   the handler so the recognizer can stay cheap.
; - Single-path filesystem commands like "cat", "cd", "load", "mkdir", "rm",
;   and "touch" reuse the same path-buffer copy pattern.

; Boot banner, initial directory listing, then drop into the shell loop.
reset:
  lda #$00
  sta %COMMAND_LENGTH_ADDRESS%
  sta %LOAD_PRESENT_ADDRESS%
  sta %LOAD_LENGTH_LOW_ADDRESS%
  sta %LOAD_LENGTH_HIGH_ADDRESS%
  sta %LOAD_RUNNABLE_ADDRESS%
  jsr print_banner
  jsr print_directory_header
  jsr print_directory_listing
  jsr print_prompt
  jmp main_loop

; Poll for terminal input, echo printable characters into the command buffer,
; and dispatch on return.
main_loop:
  lda %STATUS_ADDRESS%
  and #$02
  beq main_loop

  lda %TERMINAL_ADDRESS%
  cmp #$08
  beq handle_backspace
  cmp #$0D
  beq handle_return
  cmp #$20
  bcc main_loop
  cmp #$7F
  bcs main_loop

  ldx %COMMAND_LENGTH_ADDRESS%
  cpx #%COMMAND_BUFFER_MAX_INDEX%
  bcs main_loop
  sta %COMMAND_BUFFER_ADDRESS%, x
  inx
  stx %COMMAND_LENGTH_ADDRESS%
  jsr write_terminal_byte
  jmp main_loop

; Treat backspace as a simple destructive erase in the line buffer.
handle_backspace:
  ldx %COMMAND_LENGTH_ADDRESS%
  beq main_loop
  dex
  stx %COMMAND_LENGTH_ADDRESS%
  lda #$08
  jsr write_terminal_byte
  jmp main_loop

; Null-terminate the line in RAM, execute it, then prompt again.
handle_return:
  ldx %COMMAND_LENGTH_ADDRESS%
  lda #$00
  sta %COMMAND_BUFFER_ADDRESS%, x
  lda #$0D
  jsr write_terminal_byte
  lda #$0A
  jsr write_terminal_byte
  jsr dispatch_command
  lda #$00
  sta %COMMAND_LENGTH_ADDRESS%
  jsr print_prompt
  jmp main_loop

; Very small command dispatcher. Each command matcher checks only the
; command prefix and leaves any argument parsing to the handler itself.
dispatch_command:
  lda %COMMAND_LENGTH_ADDRESS%
  bne dispatch_check_help
  rts

dispatch_check_help:
  jsr command_is_help
  bcc dispatch_check_clear
  jsr print_help
  rts

dispatch_check_clear:
  jsr command_is_clear
  bcc dispatch_check_ls
  ; Clear only affects the terminal device. The shell prompt is redrawn later
  ; by handle_return after the command handler returns.
  jsr clear_terminal
  rts

dispatch_check_ls:
  jsr command_is_ls
  bcc dispatch_check_pwd
  jsr print_directory_header
  jsr print_directory_listing
  rts

dispatch_check_pwd:
  jsr command_is_pwd
  bcc dispatch_check_cat
  jsr print_working_directory
  rts

dispatch_check_cat:
  jsr command_is_cat
  bcc dispatch_check_cd
  jsr print_file_contents
  rts

dispatch_check_cd:
  jsr command_is_cd
  bcc dispatch_check_cp
  ; Cd updates the filesystem device's working directory, which all later
  ; relative-path commands will use automatically.
  jsr change_directory
  rts

dispatch_check_cp:
  jsr command_is_cp
  bcc dispatch_check_mkdir
  ; Copy reads the source file through the filesystem device, then writes the
  ; returned buffer back out under the destination path.
  jsr copy_file
  rts

dispatch_check_mkdir:
  jsr command_is_mkdir
  bcc dispatch_check_mv
  ; Mkdir creates guest directories through the filesystem device.
  jsr make_directory
  rts

dispatch_check_mv:
  jsr command_is_mv
  bcc dispatch_check_touch
  ; Move performs the same guest-side copy, then deletes the source path.
  jsr move_file
  rts

dispatch_check_touch:
  jsr command_is_touch
  bcc dispatch_check_vi
  ; Touch creates an empty file through the filesystem write command.
  jsr touch_file
  rts

dispatch_check_vi:
  jsr command_is_vi
  bcc dispatch_check_asm
  ; Vi enters the full-screen editor loop on the shared text buffer.
  jsr edit_file_in_vi
  rts

dispatch_check_asm:
  jsr command_is_asm
  bcc dispatch_check_load
  ; Asm asks the host-side assembler service to turn guest source into a
  ; runnable .program image under the guest filesystem.
  jsr assemble_guest_source
  rts

dispatch_check_load:
  jsr command_is_load
  bcc dispatch_check_new
  ; Load replaces the shared buffer with file contents and marks it runnable.
  jsr load_file_to_ram
  rts

dispatch_check_new:
  jsr command_is_new
  bcc dispatch_check_pop
  ; New clears the shared buffer so the line editor can start fresh.
  jsr new_buffer
  rts

dispatch_check_pop:
  jsr command_is_pop
  bcc dispatch_check_run
  ; Pop removes the last line from the shared text buffer.
  jsr pop_buffer_line
  rts

dispatch_check_run:
  jsr command_is_run
  bcc dispatch_check_save
  ; Run without arguments executes the active buffer. Run with a path first
  ; loads the named image into RAM, then JSRs into it.
  jsr run_loaded_program
  rts

dispatch_check_save:
  jsr command_is_save
  bcc dispatch_check_edit
  ; Save writes the current shared buffer back to the guest filesystem.
  jsr save_file_from_ram
  rts

dispatch_check_edit:
  jsr command_is_edit
  bcc dispatch_check_show
  ; Edit replaces the shared buffer with one line of text and marks it non-runnable.
  jsr edit_buffer_from_command
  rts

dispatch_check_show:
  jsr command_is_show
  bcc dispatch_check_append
  ; Show renders the shared buffer as text back into the terminal.
  jsr show_buffer_contents
  rts

dispatch_check_append:
  jsr command_is_append
  bcc dispatch_check_write
  ; Append adds another text line to the shared buffer.
  jsr append_buffer_from_command
  rts

dispatch_check_write:
  jsr command_is_write
  bcc dispatch_check_rm
  jsr write_file_contents
  rts

dispatch_check_rm:
  jsr command_is_rm
  bcc dispatch_unknown
  jsr remove_file
  rts

dispatch_unknown:
  jsr print_unknown

dispatch_done:
  rts

; Command recognizers.
; These only verify the command verb and any mandatory separating space.
; Argument content and length handling are left to the command handlers.
command_is_help:
  lda %COMMAND_LENGTH_ADDRESS%
  cmp #%HELP_LENGTH%
  bne command_is_help_no
  lda %COMMAND_BUFFER_ADDRESS%
  cmp #'h'
  bne command_is_help_no
  lda %COMMAND_BUFFER_ADDRESS% + 1
  cmp #'e'
  bne command_is_help_no
  lda %COMMAND_BUFFER_ADDRESS% + 2
  cmp #'l'
  bne command_is_help_no
  lda %COMMAND_BUFFER_ADDRESS% + 3
  cmp #'p'
  bne command_is_help_no
  sec
  rts

command_is_help_no:
  clc
  rts

command_is_clear:
  lda %COMMAND_LENGTH_ADDRESS%
  cmp #%CLEAR_LENGTH%
  bne command_is_clear_no
  lda %COMMAND_BUFFER_ADDRESS%
  cmp #'c'
  bne command_is_clear_no
  lda %COMMAND_BUFFER_ADDRESS% + 1
  cmp #'l'
  bne command_is_clear_no
  lda %COMMAND_BUFFER_ADDRESS% + 2
  cmp #'e'
  bne command_is_clear_no
  lda %COMMAND_BUFFER_ADDRESS% + 3
  cmp #'a'
  bne command_is_clear_no
  lda %COMMAND_BUFFER_ADDRESS% + 4
  cmp #'r'
  bne command_is_clear_no
  sec
  rts

command_is_clear_no:
  clc
  rts

command_is_ls:
  lda %COMMAND_LENGTH_ADDRESS%
  cmp #%LS_LENGTH%
  beq command_is_ls_exact
  cmp #%LS_MIN_LENGTH%
  bcc command_is_ls_no
  lda %COMMAND_BUFFER_ADDRESS%
  cmp #'l'
  bne command_is_ls_no
  lda %COMMAND_BUFFER_ADDRESS% + 1
  cmp #'s'
  bne command_is_ls_no
  lda %COMMAND_BUFFER_ADDRESS% + %LS_ARGUMENT_OFFSET% - 1
  cmp #' '
  bne command_is_ls_no
  sec
  rts

command_is_ls_exact:
  lda %COMMAND_BUFFER_ADDRESS%
  cmp #'l'
  bne command_is_ls_no
  lda %COMMAND_BUFFER_ADDRESS% + 1
  cmp #'s'
  bne command_is_ls_no
  sec
  rts

command_is_ls_no:
  clc
  rts

command_is_pwd:
  lda %COMMAND_LENGTH_ADDRESS%
  cmp #%PWD_LENGTH%
  bne command_is_pwd_no
  lda %COMMAND_BUFFER_ADDRESS%
  cmp #'p'
  bne command_is_pwd_no
  lda %COMMAND_BUFFER_ADDRESS% + 1
  cmp #'w'
  bne command_is_pwd_no
  lda %COMMAND_BUFFER_ADDRESS% + 2
  cmp #'d'
  bne command_is_pwd_no
  sec
  rts

command_is_pwd_no:
  clc
  rts

command_is_cat:
  lda %COMMAND_LENGTH_ADDRESS%
  cmp #%CAT_MIN_LENGTH%
  bcc command_is_cat_no
  lda %COMMAND_BUFFER_ADDRESS%
  cmp #'c'
  bne command_is_cat_no
  lda %COMMAND_BUFFER_ADDRESS% + 1
  cmp #'a'
  bne command_is_cat_no
  lda %COMMAND_BUFFER_ADDRESS% + 2
  cmp #'t'
  bne command_is_cat_no
  lda %COMMAND_BUFFER_ADDRESS% + %CAT_ARGUMENT_OFFSET% - 1
  cmp #' '
  bne command_is_cat_no
  sec
  rts

command_is_cat_no:
  clc
  rts

command_is_cd:
  lda %COMMAND_LENGTH_ADDRESS%
  cmp #%CD_MIN_LENGTH%
  bcc command_is_cd_no
  lda %COMMAND_BUFFER_ADDRESS%
  cmp #'c'
  bne command_is_cd_no
  lda %COMMAND_BUFFER_ADDRESS% + 1
  cmp #'d'
  bne command_is_cd_no
  lda %COMMAND_BUFFER_ADDRESS% + %CD_ARGUMENT_OFFSET% - 1
  cmp #' '
  bne command_is_cd_no
  sec
  rts

command_is_cd_no:
  clc
  rts

command_is_cp:
  lda %COMMAND_LENGTH_ADDRESS%
  cmp #%CP_MIN_LENGTH%
  bcc command_is_cp_no
  lda %COMMAND_BUFFER_ADDRESS%
  cmp #'c'
  bne command_is_cp_no
  lda %COMMAND_BUFFER_ADDRESS% + 1
  cmp #'p'
  bne command_is_cp_no
  lda %COMMAND_BUFFER_ADDRESS% + %CP_ARGUMENT_OFFSET% - 1
  cmp #' '
  bne command_is_cp_no
  sec
  rts

command_is_cp_no:
  clc
  rts

command_is_mkdir:
  lda %COMMAND_LENGTH_ADDRESS%
  cmp #%MKDIR_MIN_LENGTH%
  bcc command_is_mkdir_no
  lda %COMMAND_BUFFER_ADDRESS%
  cmp #'m'
  bne command_is_mkdir_no
  lda %COMMAND_BUFFER_ADDRESS% + 1
  cmp #'k'
  bne command_is_mkdir_no
  lda %COMMAND_BUFFER_ADDRESS% + 2
  cmp #'d'
  bne command_is_mkdir_no
  lda %COMMAND_BUFFER_ADDRESS% + 3
  cmp #'i'
  bne command_is_mkdir_no
  lda %COMMAND_BUFFER_ADDRESS% + 4
  cmp #'r'
  bne command_is_mkdir_no
  lda %COMMAND_BUFFER_ADDRESS% + %MKDIR_ARGUMENT_OFFSET% - 1
  cmp #' '
  bne command_is_mkdir_no
  sec
  rts

command_is_mkdir_no:
  clc
  rts

command_is_mv:
  lda %COMMAND_LENGTH_ADDRESS%
  cmp #%MV_MIN_LENGTH%
  bcc command_is_mv_no
  lda %COMMAND_BUFFER_ADDRESS%
  cmp #'m'
  bne command_is_mv_no
  lda %COMMAND_BUFFER_ADDRESS% + 1
  cmp #'v'
  bne command_is_mv_no
  lda %COMMAND_BUFFER_ADDRESS% + %MV_ARGUMENT_OFFSET% - 1
  cmp #' '
  bne command_is_mv_no
  sec
  rts

command_is_mv_no:
  clc
  rts

command_is_touch:
  lda %COMMAND_LENGTH_ADDRESS%
  cmp #%TOUCH_MIN_LENGTH%
  bcc command_is_touch_no
  lda %COMMAND_BUFFER_ADDRESS%
  cmp #'t'
  bne command_is_touch_no
  lda %COMMAND_BUFFER_ADDRESS% + 1
  cmp #'o'
  bne command_is_touch_no
  lda %COMMAND_BUFFER_ADDRESS% + 2
  cmp #'u'
  bne command_is_touch_no
  lda %COMMAND_BUFFER_ADDRESS% + 3
  cmp #'c'
  bne command_is_touch_no
  lda %COMMAND_BUFFER_ADDRESS% + 4
  cmp #'h'
  bne command_is_touch_no
  lda %COMMAND_BUFFER_ADDRESS% + %TOUCH_ARGUMENT_OFFSET% - 1
  cmp #' '
  bne command_is_touch_no
  sec
  rts

command_is_touch_no:
  clc
  rts

command_is_vi:
  lda %COMMAND_LENGTH_ADDRESS%
  cmp #%VI_MIN_LENGTH%
  bcc command_is_vi_no
  lda %COMMAND_BUFFER_ADDRESS%
  cmp #'v'
  bne command_is_vi_no
  lda %COMMAND_BUFFER_ADDRESS% + 1
  cmp #'i'
  bne command_is_vi_no
  lda %COMMAND_BUFFER_ADDRESS% + %VI_ARGUMENT_OFFSET% - 1
  cmp #' '
  bne command_is_vi_no
  sec
  rts

command_is_vi_no:
  clc
  rts

command_is_asm:
  lda %COMMAND_LENGTH_ADDRESS%
  cmp #%ASM_MIN_LENGTH%
  bcc command_is_asm_no
  lda %COMMAND_BUFFER_ADDRESS%
  cmp #'a'
  bne command_is_asm_no
  lda %COMMAND_BUFFER_ADDRESS% + 1
  cmp #'s'
  bne command_is_asm_no
  lda %COMMAND_BUFFER_ADDRESS% + 2
  cmp #'m'
  bne command_is_asm_no
  lda %COMMAND_BUFFER_ADDRESS% + %ASM_ARGUMENT_OFFSET% - 1
  cmp #' '
  bne command_is_asm_no
  sec
  rts

command_is_asm_no:
  clc
  rts

command_is_load:
  lda %COMMAND_LENGTH_ADDRESS%
  cmp #%LOAD_MIN_LENGTH%
  bcc command_is_load_no
  lda %COMMAND_BUFFER_ADDRESS%
  cmp #'l'
  bne command_is_load_no
  lda %COMMAND_BUFFER_ADDRESS% + 1
  cmp #'o'
  bne command_is_load_no
  lda %COMMAND_BUFFER_ADDRESS% + 2
  cmp #'a'
  bne command_is_load_no
  lda %COMMAND_BUFFER_ADDRESS% + 3
  cmp #'d'
  bne command_is_load_no
  lda %COMMAND_BUFFER_ADDRESS% + %LOAD_ARGUMENT_OFFSET% - 1
  cmp #' '
  bne command_is_load_no
  sec
  rts

command_is_load_no:
  clc
  rts

command_is_new:
  lda %COMMAND_LENGTH_ADDRESS%
  cmp #%NEW_LENGTH%
  bne command_is_new_no
  lda %COMMAND_BUFFER_ADDRESS%
  cmp #'n'
  bne command_is_new_no
  lda %COMMAND_BUFFER_ADDRESS% + 1
  cmp #'e'
  bne command_is_new_no
  lda %COMMAND_BUFFER_ADDRESS% + 2
  cmp #'w'
  bne command_is_new_no
  sec
  rts

command_is_new_no:
  clc
  rts

command_is_pop:
  lda %COMMAND_LENGTH_ADDRESS%
  cmp #%POP_LENGTH%
  bne command_is_pop_no
  lda %COMMAND_BUFFER_ADDRESS%
  cmp #'p'
  bne command_is_pop_no
  lda %COMMAND_BUFFER_ADDRESS% + 1
  cmp #'o'
  bne command_is_pop_no
  lda %COMMAND_BUFFER_ADDRESS% + 2
  cmp #'p'
  bne command_is_pop_no
  sec
  rts

command_is_pop_no:
  clc
  rts

command_is_run:
  lda %COMMAND_LENGTH_ADDRESS%
  cmp #%RUN_LENGTH%
  beq command_is_run_exact
  cmp #%RUN_MIN_LENGTH%
  bcc command_is_run_no
  lda %COMMAND_BUFFER_ADDRESS%
  cmp #'r'
  bne command_is_run_no
  lda %COMMAND_BUFFER_ADDRESS% + 1
  cmp #'u'
  bne command_is_run_no
  lda %COMMAND_BUFFER_ADDRESS% + 2
  cmp #'n'
  bne command_is_run_no
  lda %COMMAND_BUFFER_ADDRESS% + %RUN_ARGUMENT_OFFSET% - 1
  cmp #' '
  bne command_is_run_no
  sec
  rts

command_is_run_exact:
  lda %COMMAND_BUFFER_ADDRESS%
  cmp #'r'
  bne command_is_run_no
  lda %COMMAND_BUFFER_ADDRESS% + 1
  cmp #'u'
  bne command_is_run_no
  lda %COMMAND_BUFFER_ADDRESS% + 2
  cmp #'n'
  bne command_is_run_no
  sec
  rts

command_is_run_no:
  clc
  rts

command_is_save:
  lda %COMMAND_LENGTH_ADDRESS%
  cmp #%SAVE_MIN_LENGTH%
  bcc command_is_save_no
  lda %COMMAND_BUFFER_ADDRESS%
  cmp #'s'
  bne command_is_save_no
  lda %COMMAND_BUFFER_ADDRESS% + 1
  cmp #'a'
  bne command_is_save_no
  lda %COMMAND_BUFFER_ADDRESS% + 2
  cmp #'v'
  bne command_is_save_no
  lda %COMMAND_BUFFER_ADDRESS% + 3
  cmp #'e'
  bne command_is_save_no
  lda %COMMAND_BUFFER_ADDRESS% + %SAVE_ARGUMENT_OFFSET% - 1
  cmp #' '
  bne command_is_save_no
  sec
  rts

command_is_save_no:
  clc
  rts

command_is_edit:
  lda %COMMAND_LENGTH_ADDRESS%
  cmp #%EDIT_MIN_LENGTH%
  bcc command_is_edit_no
  lda %COMMAND_BUFFER_ADDRESS%
  cmp #'e'
  bne command_is_edit_no
  lda %COMMAND_BUFFER_ADDRESS% + 1
  cmp #'d'
  bne command_is_edit_no
  lda %COMMAND_BUFFER_ADDRESS% + 2
  cmp #'i'
  bne command_is_edit_no
  lda %COMMAND_BUFFER_ADDRESS% + 3
  cmp #'t'
  bne command_is_edit_no
  lda %COMMAND_BUFFER_ADDRESS% + %EDIT_ARGUMENT_OFFSET% - 1
  cmp #' '
  bne command_is_edit_no
  sec
  rts

command_is_edit_no:
  clc
  rts

command_is_show:
  lda %COMMAND_LENGTH_ADDRESS%
  cmp #%SHOW_LENGTH%
  bne command_is_show_no
  lda %COMMAND_BUFFER_ADDRESS%
  cmp #'s'
  bne command_is_show_no
  lda %COMMAND_BUFFER_ADDRESS% + 1
  cmp #'h'
  bne command_is_show_no
  lda %COMMAND_BUFFER_ADDRESS% + 2
  cmp #'o'
  bne command_is_show_no
  lda %COMMAND_BUFFER_ADDRESS% + 3
  cmp #'w'
  bne command_is_show_no
  sec
  rts

command_is_show_no:
  clc
  rts

command_is_append:
  lda %COMMAND_LENGTH_ADDRESS%
  cmp #%APPEND_MIN_LENGTH%
  bcc command_is_append_no
  lda %COMMAND_BUFFER_ADDRESS%
  cmp #'a'
  bne command_is_append_no
  lda %COMMAND_BUFFER_ADDRESS% + 1
  cmp #'p'
  bne command_is_append_no
  lda %COMMAND_BUFFER_ADDRESS% + 2
  cmp #'p'
  bne command_is_append_no
  lda %COMMAND_BUFFER_ADDRESS% + 3
  cmp #'e'
  bne command_is_append_no
  lda %COMMAND_BUFFER_ADDRESS% + 4
  cmp #'n'
  bne command_is_append_no
  lda %COMMAND_BUFFER_ADDRESS% + 5
  cmp #'d'
  bne command_is_append_no
  lda %COMMAND_BUFFER_ADDRESS% + 6
  cmp #' '
  bne command_is_append_no
  sec
  rts

command_is_append_no:
  clc
  rts

command_is_write:
  lda %COMMAND_LENGTH_ADDRESS%
  cmp #%WRITE_MIN_LENGTH%
  bcc command_is_write_no
  lda %COMMAND_BUFFER_ADDRESS%
  cmp #'w'
  bne command_is_write_no
  lda %COMMAND_BUFFER_ADDRESS% + 1
  cmp #'r'
  bne command_is_write_no
  lda %COMMAND_BUFFER_ADDRESS% + 2
  cmp #'i'
  bne command_is_write_no
  lda %COMMAND_BUFFER_ADDRESS% + 3
  cmp #'t'
  bne command_is_write_no
  lda %COMMAND_BUFFER_ADDRESS% + 4
  cmp #'e'
  bne command_is_write_no
  lda %COMMAND_BUFFER_ADDRESS% + %WRITE_ARGUMENT_OFFSET% - 1
  cmp #' '
  bne command_is_write_no
  sec
  rts

command_is_write_no:
  clc
  rts

command_is_rm:
  lda %COMMAND_LENGTH_ADDRESS%
  cmp #%RM_MIN_LENGTH%
  bcc command_is_rm_no
  lda %COMMAND_BUFFER_ADDRESS%
  cmp #'r'
  bne command_is_rm_no
  lda %COMMAND_BUFFER_ADDRESS% + 1
  cmp #'m'
  bne command_is_rm_no
  lda %COMMAND_BUFFER_ADDRESS% + %RM_ARGUMENT_OFFSET% - 1
  cmp #' '
  bne command_is_rm_no
  sec
  rts

command_is_rm_no:
  clc
  rts

; Tiny print helpers. They all set the shared string pointer and tail-call
; into print_string.
print_banner:
  lda #<banner
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>banner
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_directory_header:
  lda #<directory_header
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>directory_header
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_prompt:
  lda #<prompt
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>prompt
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_help:
  lda #<help_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>help_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_unknown:
  lda #<unknown_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>unknown_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_filesystem_error:
  lda #<filesystem_error_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>filesystem_error_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_missing_file:
  lda #<missing_file_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>missing_file_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_missing_path:
  lda #<missing_path_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>missing_path_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_not_directory:
  lda #<not_directory_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>not_directory_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_cd_usage:
  lda #<cd_usage_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>cd_usage_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_cd_ok:
  lda #<cd_ok_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>cd_ok_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_vi_usage:
  lda #<vi_usage_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>vi_usage_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_asm_usage:
  lda #<asm_usage_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>asm_usage_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_asm_ok_prefix:
  lda #<asm_ok_prefix_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>asm_ok_prefix_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_assembly_failed:
  lda #<assembly_failed_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>assembly_failed_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_cp_usage:
  lda #<cp_usage_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>cp_usage_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_cp_ok:
  lda #<cp_ok_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>cp_ok_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_mkdir_usage:
  lda #<mkdir_usage_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>mkdir_usage_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_mkdir_ok:
  lda #<mkdir_ok_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>mkdir_ok_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_mv_usage:
  lda #<mv_usage_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>mv_usage_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_mv_ok:
  lda #<mv_ok_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>mv_ok_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_touch_usage:
  lda #<touch_usage_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>touch_usage_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_touch_ok:
  lda #<touch_ok_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>touch_ok_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_load_usage:
  lda #<load_usage_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>load_usage_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_load_ok:
  lda #<load_ok_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>load_ok_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_load_truncated:
  lda #<load_truncated_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>load_truncated_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_run_missing:
  lda #<run_missing_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>run_missing_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_run_text:
  lda #<run_text_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>run_text_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_save_usage:
  lda #<save_usage_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>save_usage_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_save_ok:
  lda #<save_ok_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>save_ok_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_edit_usage:
  lda #<edit_usage_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>edit_usage_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_edit_ok:
  lda #<edit_ok_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>edit_ok_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_new_ok:
  lda #<new_ok_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>new_ok_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_pop_ok:
  lda #<pop_ok_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>pop_ok_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_show_empty:
  lda #<show_empty_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>show_empty_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_append_usage:
  lda #<append_usage_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>append_usage_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_append_ok:
  lda #<append_ok_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>append_ok_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_buffer_full:
  lda #<buffer_full_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>buffer_full_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_write_usage:
  lda #<write_usage_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>write_usage_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_write_ok:
  lda #<write_ok_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>write_ok_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_rm_usage:
  lda #<rm_usage_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>rm_usage_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

print_rm_ok:
  lda #<rm_ok_text
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>rm_ok_text
  sta %PRINT_POINTER_HIGH_ADDRESS%
  jmp print_string

; Print a zero-terminated string via the terminal data register.
print_string:
  ldy #$00
print_string_loop:
  lda (%PRINT_POINTER_LOW_ADDRESS%), y
  beq print_string_done
  jsr write_terminal_byte
  iny
  bne print_string_loop
print_string_done:
  rts

write_terminal_byte:
  sta %TERMINAL_ADDRESS%
  rts

; Clear the terminal device and return to the shell prompt on a fresh screen.
clear_terminal:
  lda #%TERMINAL_CLEAR_CONTROL%
  sta %TERMINAL_CONTROL_ADDRESS%
  rts

; Ask the filesystem device for a directory listing of "." and print the
; returned newline-delimited buffer into the terminal.
print_directory_listing:
  lda %COMMAND_LENGTH_ADDRESS%
  beq print_directory_listing_use_current
  cmp #%LS_LENGTH%
  beq print_directory_listing_use_current
  sec
  sbc #%LS_ARGUMENT_OFFSET%
  sta %FS_PATH_LENGTH_ADDRESS%
  tax
  dex
  bmi print_directory_listing_issue_command

print_directory_listing_copy_path_loop:
  lda %COMMAND_BUFFER_ADDRESS% + %LS_ARGUMENT_OFFSET%, x
  sta %FS_PATH_BUFFER_ADDRESS%, x
  dex
  bpl print_directory_listing_copy_path_loop
  jmp print_directory_listing_issue_command

print_directory_listing_use_current:
  lda #$00
  sta %FS_PATH_LENGTH_ADDRESS%

print_directory_listing_issue_command:
  lda #%FS_COMMAND_LIST%
  sta %FS_COMMAND_ADDRESS%
  lda %FS_STATUS_ADDRESS%
  and #$02
  beq print_directory_listing_data
  lda %FS_ERROR_CODE_ADDRESS%
  cmp #%FS_ERROR_NOT_FOUND%
  beq print_directory_listing_missing
  cmp #%FS_ERROR_NOT_DIRECTORY%
  beq print_directory_listing_not_directory
  jmp print_filesystem_error

print_directory_listing_missing:
  jmp print_missing_path

print_directory_listing_not_directory:
  jmp print_not_directory

print_directory_listing_data:
  lda %FS_STATUS_ADDRESS%
  and #$04
  beq print_directory_listing_done
  ldx #$00
print_directory_listing_loop:
  cpx %FS_RESULT_LENGTH_LOW_ADDRESS%
  beq print_directory_listing_done
  lda %FS_DATA_BUFFER_ADDRESS%, x
  cmp #$0A
  beq print_directory_newline
  jsr write_terminal_byte
  inx
  jmp print_directory_listing_loop

print_directory_newline:
  lda #$0D
  jsr write_terminal_byte
  lda #$0A
  jsr write_terminal_byte
  inx
  jmp print_directory_listing_loop

print_directory_listing_done:
  lda #$0D
  jsr write_terminal_byte
  lda #$0A
  jsr write_terminal_byte
  rts

; Ask the filesystem device for the current working directory and print the
; returned guest path. The device owns cwd state so every later file command
; sees the same location.
print_working_directory:
  lda #%FS_COMMAND_PWD%
  sta %FS_COMMAND_ADDRESS%
  lda %FS_STATUS_ADDRESS%
  and #$02
  beq print_working_directory_data
  jmp print_filesystem_error

print_working_directory_data:
  lda %FS_STATUS_ADDRESS%
  and #$04
  beq print_working_directory_done
  ldx #$00
print_working_directory_loop:
  cpx %FS_RESULT_LENGTH_LOW_ADDRESS%
  beq print_working_directory_done
  lda %FS_DATA_BUFFER_ADDRESS%, x
  jsr write_terminal_byte
  inx
  jmp print_working_directory_loop

print_working_directory_done:
  lda #$0D
  jsr write_terminal_byte
  lda #$0A
  jsr write_terminal_byte
  rts

; Copy the path that follows "cat " into the filesystem path buffer, issue a
; read command, and stream the returned bytes to the terminal.
print_file_contents:
  lda %COMMAND_LENGTH_ADDRESS%
  sec
  sbc #%CAT_ARGUMENT_OFFSET%
  sta %FS_PATH_LENGTH_ADDRESS%
  tax
  dex
  bmi print_file_contents_issue_read
print_file_contents_copy_loop:
  lda %COMMAND_BUFFER_ADDRESS% + %CAT_ARGUMENT_OFFSET%, x
  sta %FS_PATH_BUFFER_ADDRESS%, x
  dex
  bpl print_file_contents_copy_loop
print_file_contents_issue_read:
  lda #%FS_COMMAND_READ%
  sta %FS_COMMAND_ADDRESS%
  lda %FS_STATUS_ADDRESS%
  and #$02
  beq print_file_contents_data
  lda %FS_ERROR_CODE_ADDRESS%
  cmp #%FS_ERROR_NOT_FOUND%
  beq print_file_contents_missing
  jmp print_filesystem_error

print_file_contents_missing:
  jmp print_missing_file

print_file_contents_data:
  lda %FS_STATUS_ADDRESS%
  and #$04
  beq print_file_contents_done
  ldx #$00
print_file_contents_loop:
  cpx %FS_RESULT_LENGTH_LOW_ADDRESS%
  beq print_file_contents_done
  lda %FS_DATA_BUFFER_ADDRESS%, x
  cmp #$0A
  beq print_file_contents_newline
  jsr write_terminal_byte
  inx
  jmp print_file_contents_loop

print_file_contents_newline:
  lda #$0D
  jsr write_terminal_byte
  lda #$0A
  jsr write_terminal_byte
  inx
  jmp print_file_contents_loop

print_file_contents_done:
  lda #$0D
  jsr write_terminal_byte
  lda #$0A
  jsr write_terminal_byte
  rts

; Parse "cd <path>" and ask the filesystem device to update its current
; working directory. Relative paths stay in the device, so other commands do
; not need to duplicate path-join logic in ROM.
change_directory:
  lda %COMMAND_LENGTH_ADDRESS%
  sec
  sbc #%CD_ARGUMENT_OFFSET%
  beq change_directory_usage
  sta %FS_PATH_LENGTH_ADDRESS%
  tax
  dex
  bmi change_directory_issue_command

change_directory_copy_path_loop:
  lda %COMMAND_BUFFER_ADDRESS% + %CD_ARGUMENT_OFFSET%, x
  sta %FS_PATH_BUFFER_ADDRESS%, x
  dex
  bpl change_directory_copy_path_loop

change_directory_issue_command:
  lda #%FS_COMMAND_CHDIR%
  sta %FS_COMMAND_ADDRESS%
  lda %FS_STATUS_ADDRESS%
  and #$02
  beq change_directory_done
  lda %FS_ERROR_CODE_ADDRESS%
  cmp #%FS_ERROR_NOT_FOUND%
  beq change_directory_missing
  cmp #%FS_ERROR_NOT_DIRECTORY%
  beq change_directory_bad_target
  jmp print_filesystem_error

change_directory_missing:
  jmp print_missing_path

change_directory_bad_target:
  jmp print_not_directory

change_directory_done:
  jmp print_cd_ok

change_directory_usage:
  jmp print_cd_usage

; Parse "cp <src> <dst>", read the source into the filesystem data buffer,
; then write that same buffer back out under the destination path.
copy_file:
  ldx #%CP_ARGUMENT_OFFSET%
  cpx %COMMAND_LENGTH_ADDRESS%
  bcc copy_file_find_separator
  jmp copy_file_usage

copy_file_find_separator:
  cpx %COMMAND_LENGTH_ADDRESS%
  bcc copy_file_check_separator
  jmp copy_file_usage

copy_file_check_separator:
  lda %COMMAND_BUFFER_ADDRESS%, x
  cmp #' '
  beq copy_file_separator_found
  inx
  jmp copy_file_find_separator

copy_file_separator_found:
  stx %WRITE_SEPARATOR_INDEX_ADDRESS%
  txa
  sec
  sbc #%CP_ARGUMENT_OFFSET%
  bne copy_file_store_source_length
  jmp copy_file_usage

copy_file_store_source_length:
  sta %FS_PATH_LENGTH_ADDRESS%
  tax
  dex
  bmi copy_file_issue_read

copy_file_source_loop:
  lda %COMMAND_BUFFER_ADDRESS% + %CP_ARGUMENT_OFFSET%, x
  sta %FS_PATH_BUFFER_ADDRESS%, x
  dex
  bpl copy_file_source_loop

copy_file_issue_read:
  lda #%FS_COMMAND_READ%
  sta %FS_COMMAND_ADDRESS%
  lda %FS_STATUS_ADDRESS%
  and #$02
  beq copy_file_prepare_destination
  lda %FS_ERROR_CODE_ADDRESS%
  cmp #%FS_ERROR_NOT_FOUND%
  beq copy_file_missing
  jmp print_filesystem_error

copy_file_missing:
  jmp print_missing_file

copy_file_prepare_destination:
  lda %COMMAND_LENGTH_ADDRESS%
  sec
  sbc %WRITE_SEPARATOR_INDEX_ADDRESS%
  sec
  sbc #$01
  bne copy_file_store_destination_length
  jmp copy_file_usage

copy_file_store_destination_length:
  sta %WRITE_DATA_LENGTH_ADDRESS%
  sta %FS_PATH_LENGTH_ADDRESS%
  ldx %WRITE_SEPARATOR_INDEX_ADDRESS%
  inx
  ldy #$00

copy_file_destination_loop:
  cpy %WRITE_DATA_LENGTH_ADDRESS%
  beq copy_file_prepare_write
  lda %COMMAND_BUFFER_ADDRESS%, x
  sta %FS_PATH_BUFFER_ADDRESS%, y
  inx
  iny
  jmp copy_file_destination_loop

copy_file_prepare_write:
  lda %FS_RESULT_LENGTH_LOW_ADDRESS%
  sta %FS_DATA_LENGTH_LOW_ADDRESS%
  lda #$00
  sta %FS_DATA_LENGTH_HIGH_ADDRESS%
  lda #%FS_COMMAND_WRITE%
  sta %FS_COMMAND_ADDRESS%
  lda %FS_STATUS_ADDRESS%
  and #$02
  beq copy_file_done
  jmp print_filesystem_error

copy_file_done:
  jmp print_cp_ok

copy_file_usage:
  jmp print_cp_usage

; Parse "mkdir <path>" and hand the path to the filesystem mkdir command.
; This keeps directory creation in the same guest-visible protocol as files.
make_directory:
  lda %COMMAND_LENGTH_ADDRESS%
  sec
  sbc #%MKDIR_ARGUMENT_OFFSET%
  beq make_directory_usage
  sta %FS_PATH_LENGTH_ADDRESS%
  tax
  dex
  bmi make_directory_issue_command

make_directory_copy_path_loop:
  lda %COMMAND_BUFFER_ADDRESS% + %MKDIR_ARGUMENT_OFFSET%, x
  sta %FS_PATH_BUFFER_ADDRESS%, x
  dex
  bpl make_directory_copy_path_loop

make_directory_issue_command:
  lda #%FS_COMMAND_MKDIR%
  sta %FS_COMMAND_ADDRESS%
  lda %FS_STATUS_ADDRESS%
  and #$02
  beq make_directory_done
  jmp print_filesystem_error

make_directory_done:
  jmp print_mkdir_ok

make_directory_usage:
  jmp print_mkdir_usage

; Parse "mv <src> <dst>", copy the source into the destination, then remove
; the original source path through the filesystem device.
move_file:
  ldx #%MV_ARGUMENT_OFFSET%
  cpx %COMMAND_LENGTH_ADDRESS%
  bcc move_file_find_separator
  jmp move_file_usage

move_file_find_separator:
  cpx %COMMAND_LENGTH_ADDRESS%
  bcc move_file_check_separator
  jmp move_file_usage

move_file_check_separator:
  lda %COMMAND_BUFFER_ADDRESS%, x
  cmp #' '
  beq move_file_separator_found
  inx
  jmp move_file_find_separator

move_file_separator_found:
  stx %WRITE_SEPARATOR_INDEX_ADDRESS%
  txa
  sec
  sbc #%MV_ARGUMENT_OFFSET%
  bne move_file_store_source_length
  jmp move_file_usage

move_file_store_source_length:
  sta %FS_PATH_LENGTH_ADDRESS%
  tax
  dex
  bmi move_file_issue_read

move_file_source_loop:
  lda %COMMAND_BUFFER_ADDRESS% + %MV_ARGUMENT_OFFSET%, x
  sta %FS_PATH_BUFFER_ADDRESS%, x
  dex
  bpl move_file_source_loop

move_file_issue_read:
  lda #%FS_COMMAND_READ%
  sta %FS_COMMAND_ADDRESS%
  lda %FS_STATUS_ADDRESS%
  and #$02
  beq move_file_prepare_destination
  lda %FS_ERROR_CODE_ADDRESS%
  cmp #%FS_ERROR_NOT_FOUND%
  beq move_file_missing
  jmp print_filesystem_error

move_file_missing:
  jmp print_missing_file

move_file_prepare_destination:
  lda %COMMAND_LENGTH_ADDRESS%
  sec
  sbc %WRITE_SEPARATOR_INDEX_ADDRESS%
  sec
  sbc #$01
  bne move_file_store_destination_length
  jmp move_file_usage

move_file_store_destination_length:
  sta %WRITE_DATA_LENGTH_ADDRESS%
  sta %FS_PATH_LENGTH_ADDRESS%
  ldx %WRITE_SEPARATOR_INDEX_ADDRESS%
  inx
  ldy #$00

move_file_destination_loop:
  cpy %WRITE_DATA_LENGTH_ADDRESS%
  beq move_file_issue_write
  lda %COMMAND_BUFFER_ADDRESS%, x
  sta %FS_PATH_BUFFER_ADDRESS%, y
  inx
  iny
  jmp move_file_destination_loop

move_file_issue_write:
  lda %FS_RESULT_LENGTH_LOW_ADDRESS%
  sta %FS_DATA_LENGTH_LOW_ADDRESS%
  lda #$00
  sta %FS_DATA_LENGTH_HIGH_ADDRESS%
  lda #%FS_COMMAND_WRITE%
  sta %FS_COMMAND_ADDRESS%
  lda %FS_STATUS_ADDRESS%
  and #$02
  beq move_file_prepare_delete
  jmp print_filesystem_error

move_file_prepare_delete:
  lda %WRITE_SEPARATOR_INDEX_ADDRESS%
  sec
  sbc #%MV_ARGUMENT_OFFSET%
  sta %FS_PATH_LENGTH_ADDRESS%
  tax
  dex
  bmi move_file_issue_delete

move_file_restore_source_loop:
  lda %COMMAND_BUFFER_ADDRESS% + %MV_ARGUMENT_OFFSET%, x
  sta %FS_PATH_BUFFER_ADDRESS%, x
  dex
  bpl move_file_restore_source_loop

move_file_issue_delete:
  lda #%FS_COMMAND_DELETE%
  sta %FS_COMMAND_ADDRESS%
  lda %FS_STATUS_ADDRESS%
  and #$02
  beq move_file_done
  lda %FS_ERROR_CODE_ADDRESS%
  cmp #%FS_ERROR_NOT_FOUND%
  beq move_file_missing
  jmp print_filesystem_error

move_file_done:
  jmp print_mv_ok

move_file_usage:
  jmp print_mv_usage

; Parse "touch <file>" and issue a zero-length write. The filesystem layer
; already handles creating parent directories for writes, so touch can stay
; very small here.
touch_file:
  lda %COMMAND_LENGTH_ADDRESS%
  sec
  sbc #%TOUCH_ARGUMENT_OFFSET%
  beq touch_file_usage
  sta %FS_PATH_LENGTH_ADDRESS%
  tax
  dex
  bmi touch_file_issue_write

touch_file_copy_path_loop:
  lda %COMMAND_BUFFER_ADDRESS% + %TOUCH_ARGUMENT_OFFSET%, x
  sta %FS_PATH_BUFFER_ADDRESS%, x
  dex
  bpl touch_file_copy_path_loop

touch_file_issue_write:
  lda #$00
  sta %FS_DATA_LENGTH_LOW_ADDRESS%
  sta %FS_DATA_LENGTH_HIGH_ADDRESS%
  lda #%FS_COMMAND_WRITE%
  sta %FS_COMMAND_ADDRESS%
  lda %FS_STATUS_ADDRESS%
  and #$02
  beq touch_file_done
  jmp print_filesystem_error

touch_file_done:
  jmp print_touch_ok

touch_file_usage:
  jmp print_touch_usage

; Parse "asm <file> [output]", ask the host-side assembler service to build a
; runnable image from that guest source file, then print the output path that
; was produced so the user can `run` it immediately.
assemble_guest_source:
  ldx #%ASM_ARGUMENT_OFFSET%
  cpx %COMMAND_LENGTH_ADDRESS%
  bcc assemble_guest_source_find_separator
  jmp assemble_guest_source_usage

assemble_guest_source_find_separator:
  cpx %COMMAND_LENGTH_ADDRESS%
  bcc assemble_guest_source_check_separator
  jmp assemble_guest_source_store_source_only

assemble_guest_source_check_separator:
  lda %COMMAND_BUFFER_ADDRESS%, x
  cmp #' '
  beq assemble_guest_source_separator_found
  inx
  jmp assemble_guest_source_find_separator

assemble_guest_source_separator_found:
  stx %WRITE_SEPARATOR_INDEX_ADDRESS%
  txa
  sec
  sbc #%ASM_ARGUMENT_OFFSET%
  bne assemble_guest_source_store_source_length
  jmp assemble_guest_source_usage

assemble_guest_source_store_source_length:
  sta %FS_PATH_LENGTH_ADDRESS%
  tax
  dex
  bmi assemble_guest_source_prepare_output

assemble_guest_source_copy_source_loop:
  lda %COMMAND_BUFFER_ADDRESS% + %ASM_ARGUMENT_OFFSET%, x
  sta %FS_PATH_BUFFER_ADDRESS%, x
  dex
  bpl assemble_guest_source_copy_source_loop

assemble_guest_source_prepare_output:
  lda %COMMAND_LENGTH_ADDRESS%
  sec
  sbc %WRITE_SEPARATOR_INDEX_ADDRESS%
  sec
  sbc #$01
  bne assemble_guest_source_store_output_length
  jmp assemble_guest_source_usage

assemble_guest_source_store_output_length:
  sta %WRITE_DATA_LENGTH_ADDRESS%
  sta %FS_DATA_LENGTH_LOW_ADDRESS%
  lda #$00
  sta %FS_DATA_LENGTH_HIGH_ADDRESS%
  ldx %WRITE_SEPARATOR_INDEX_ADDRESS%
  inx
  ldy #$00

assemble_guest_source_copy_output_loop:
  cpy %WRITE_DATA_LENGTH_ADDRESS%
  beq assemble_guest_source_issue_command
  lda %COMMAND_BUFFER_ADDRESS%, x
  sta %FS_DATA_BUFFER_ADDRESS%, y
  inx
  iny
  jmp assemble_guest_source_copy_output_loop

assemble_guest_source_store_source_only:
  lda %COMMAND_LENGTH_ADDRESS%
  sec
  sbc #%ASM_ARGUMENT_OFFSET%
  bne assemble_guest_source_store_source_only_length
  jmp assemble_guest_source_usage

assemble_guest_source_store_source_only_length:
  sta %FS_PATH_LENGTH_ADDRESS%
  tax
  dex
  lda #$00
  sta %FS_DATA_LENGTH_LOW_ADDRESS%
  sta %FS_DATA_LENGTH_HIGH_ADDRESS%
  bmi assemble_guest_source_issue_command

assemble_guest_source_copy_source_only_loop:
  lda %COMMAND_BUFFER_ADDRESS% + %ASM_ARGUMENT_OFFSET%, x
  sta %FS_PATH_BUFFER_ADDRESS%, x
  dex
  bpl assemble_guest_source_copy_source_only_loop

assemble_guest_source_issue_command:
  lda #%FS_COMMAND_ASSEMBLE%
  sta %FS_COMMAND_ADDRESS%
  lda %FS_STATUS_ADDRESS%
  and #$02
  beq assemble_guest_source_print_result
  lda %FS_ERROR_CODE_ADDRESS%
  cmp #%FS_ERROR_NOT_FOUND%
  beq assemble_guest_source_missing
  cmp #%FS_ERROR_ASSEMBLY_FAILED%
  beq assemble_guest_source_failed
  jmp print_filesystem_error

assemble_guest_source_missing:
  jmp print_missing_file

assemble_guest_source_failed:
  jmp print_assembly_failed

assemble_guest_source_print_result:
  jsr print_asm_ok_prefix
  ldx #$00

assemble_guest_source_result_loop:
  cpx %FS_RESULT_LENGTH_LOW_ADDRESS%
  beq assemble_guest_source_done
  lda %FS_DATA_BUFFER_ADDRESS%, x
  jsr write_terminal_byte
  inx
  jmp assemble_guest_source_result_loop

assemble_guest_source_done:
  lda #$0D
  jsr write_terminal_byte
  lda #$0A
  jsr write_terminal_byte
  rts

assemble_guest_source_usage:
  jmp print_asm_usage

; Parse "vi <file>", load the target file if it exists, and enter a modal
; editor loop over the shared load buffer. Missing files start as empty
; buffers so new files can be created from the editor directly.
edit_file_in_vi:
  lda %COMMAND_LENGTH_ADDRESS%
  sec
  sbc #%VI_ARGUMENT_OFFSET%
  bne edit_file_in_vi_store_path_length
  jmp edit_file_in_vi_usage

edit_file_in_vi_store_path_length:
  sta %EDITOR_PATH_LENGTH_ADDRESS%
  tax
  dex
  bmi edit_file_in_vi_issue_read

edit_file_in_vi_copy_path_loop:
  lda %COMMAND_BUFFER_ADDRESS% + %VI_ARGUMENT_OFFSET%, x
  sta %EDITOR_PATH_BUFFER_ADDRESS%, x
  dex
  bpl edit_file_in_vi_copy_path_loop

edit_file_in_vi_issue_read:
  jsr copy_editor_path_to_fs_path
  lda #%FS_COMMAND_READ%
  sta %FS_COMMAND_ADDRESS%
  lda %FS_STATUS_ADDRESS%
  and #$02
  beq edit_file_in_vi_copy_result
  lda %FS_ERROR_CODE_ADDRESS%
  cmp #%FS_ERROR_NOT_FOUND%
  beq edit_file_in_vi_new_file
  jmp print_filesystem_error

edit_file_in_vi_new_file:
  lda #$00
  sta %LOAD_LENGTH_LOW_ADDRESS%
  sta %LOAD_LENGTH_HIGH_ADDRESS%
  lda #$01
  sta %LOAD_PRESENT_ADDRESS%
  lda #$00
  sta %LOAD_RUNNABLE_ADDRESS%
  sta %EDITOR_CURSOR_INDEX_ADDRESS%
  sta %EDITOR_MODE_ADDRESS%
  sta %EDITOR_COMMAND_LENGTH_ADDRESS%
  sta %EDITOR_DIRTY_ADDRESS%
  sta %EDITOR_PENDING_KEY_ADDRESS%
  sta %EDITOR_UNDO_VALID_ADDRESS%
  sta %EDITOR_SEARCH_LENGTH_ADDRESS%
  sta %EDITOR_SEARCH_DIRECTION_ADDRESS%
  lda #$01
  sta %EDITOR_ACTIVE_ADDRESS%
  jsr render_vi_editor
  jmp vi_editor_loop

edit_file_in_vi_copy_result:
  ldx #$00
edit_file_in_vi_copy_result_loop:
  cpx %FS_RESULT_LENGTH_LOW_ADDRESS%
  beq edit_file_in_vi_ready
  lda %FS_DATA_BUFFER_ADDRESS%, x
  sta %LOAD_BUFFER_ADDRESS%, x
  inx
  jmp edit_file_in_vi_copy_result_loop

edit_file_in_vi_ready:
  lda %FS_RESULT_LENGTH_LOW_ADDRESS%
  sta %LOAD_LENGTH_LOW_ADDRESS%
  lda #$00
  sta %LOAD_LENGTH_HIGH_ADDRESS%
  lda #$01
  sta %LOAD_PRESENT_ADDRESS%
  lda #$00
  sta %LOAD_RUNNABLE_ADDRESS%
  sta %EDITOR_CURSOR_INDEX_ADDRESS%
  sta %EDITOR_MODE_ADDRESS%
  sta %EDITOR_COMMAND_LENGTH_ADDRESS%
  sta %EDITOR_DIRTY_ADDRESS%
  sta %EDITOR_PENDING_KEY_ADDRESS%
  sta %EDITOR_UNDO_VALID_ADDRESS%
  sta %EDITOR_SEARCH_LENGTH_ADDRESS%
  sta %EDITOR_SEARCH_DIRECTION_ADDRESS%
  lda #$01
  sta %EDITOR_ACTIVE_ADDRESS%
  jsr render_vi_editor

vi_editor_loop:
  lda %STATUS_ADDRESS%
  and #$02
  beq vi_editor_loop
  lda %TERMINAL_ADDRESS%
  jsr handle_vi_key
  bcs vi_editor_done
  jsr render_vi_editor
  jmp vi_editor_loop

vi_editor_done:
  lda #$00
  sta %EDITOR_ACTIVE_ADDRESS%
  lda #$0D
  jsr write_terminal_byte
  lda #$0A
  jsr write_terminal_byte
  rts

edit_file_in_vi_usage:
  jmp print_vi_usage

copy_editor_path_to_fs_path:
  lda %EDITOR_PATH_LENGTH_ADDRESS%
  sta %FS_PATH_LENGTH_ADDRESS%
  tax
  dex
  bmi copy_editor_path_to_fs_path_done

copy_editor_path_to_fs_path_loop:
  lda %EDITOR_PATH_BUFFER_ADDRESS%, x
  sta %FS_PATH_BUFFER_ADDRESS%, x
  dex
  bpl copy_editor_path_to_fs_path_loop

copy_editor_path_to_fs_path_done:
  rts

; Full-screen editor redraw. The buffer is rendered into the text area, the
; status line is written onto the last row, and then the hardware cursor is
; moved back to the edit position.
render_vi_editor:
  jsr clear_terminal
  ldx #$00
render_vi_editor_buffer_loop:
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  beq render_vi_editor_status
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp #$0A
  beq render_vi_editor_newline
  jsr write_terminal_byte
  inx
  jmp render_vi_editor_buffer_loop

render_vi_editor_newline:
  lda #$0D
  jsr write_terminal_byte
  lda #$0A
  jsr write_terminal_byte
  inx
  jmp render_vi_editor_buffer_loop

render_vi_editor_status:
  lda #$00
  sta %TERMINAL_CURSOR_COLUMN_ADDRESS%
  lda #%TERMINAL_LAST_ROW%
  sta %TERMINAL_CURSOR_ROW_ADDRESS%
  lda %EDITOR_MODE_ADDRESS%
  cmp #$02
  beq render_vi_command_status
  cmp #$03
  beq render_vi_search_status
  cmp #$01
  beq render_vi_insert_status
  jsr print_vi_normal_label
  jmp render_vi_status_path

render_vi_insert_status:
  jsr print_vi_insert_label

render_vi_status_path:
  lda #' '
  jsr write_terminal_byte
  ldx #$00
render_vi_status_path_loop:
  cpx %EDITOR_PATH_LENGTH_ADDRESS%
  beq render_vi_status_dirty
  lda %EDITOR_PATH_BUFFER_ADDRESS%, x
  jsr write_terminal_byte
  inx
  jmp render_vi_status_path_loop

render_vi_status_dirty:
  lda %EDITOR_DIRTY_ADDRESS%
  beq render_vi_set_cursor
  lda #' '
  jsr write_terminal_byte
  lda #'['
  jsr write_terminal_byte
  lda #'+'
  jsr write_terminal_byte
  lda #']'
  jsr write_terminal_byte
  jmp render_vi_set_cursor

render_vi_command_status:
  lda #':'
  jsr write_terminal_byte
  ldx #$00
render_vi_command_status_loop:
  cpx %EDITOR_COMMAND_LENGTH_ADDRESS%
  beq render_vi_set_cursor
  lda %EDITOR_COMMAND_BUFFER_ADDRESS%, x
  jsr write_terminal_byte
  inx
  jmp render_vi_command_status_loop

render_vi_search_status:
  lda %EDITOR_SEARCH_DIRECTION_ADDRESS%
  beq render_vi_search_status_forward
  lda #'?'
  jsr write_terminal_byte
  jmp render_vi_search_status_prompt_done

render_vi_search_status_forward:
  lda #'/'
  jsr write_terminal_byte

render_vi_search_status_prompt_done:
  ldx #$00
render_vi_search_status_loop:
  cpx %EDITOR_COMMAND_LENGTH_ADDRESS%
  beq render_vi_set_cursor
  lda %EDITOR_COMMAND_BUFFER_ADDRESS%, x
  jsr write_terminal_byte
  inx
  jmp render_vi_search_status_loop

render_vi_set_cursor:
  lda %EDITOR_MODE_ADDRESS%
  cmp #$02
  beq render_vi_command_cursor
  cmp #$03
  beq render_vi_command_cursor
  jsr vi_compute_cursor_position
  lda %WRITE_SEPARATOR_INDEX_ADDRESS%
  cmp #%TERMINAL_TEXT_LAST_ROW%
  bcc render_vi_store_cursor
  lda #%TERMINAL_TEXT_LAST_ROW%
  sta %WRITE_SEPARATOR_INDEX_ADDRESS%

render_vi_store_cursor:
  lda %WRITE_DATA_LENGTH_ADDRESS%
  sta %TERMINAL_CURSOR_COLUMN_ADDRESS%
  lda %WRITE_SEPARATOR_INDEX_ADDRESS%
  sta %TERMINAL_CURSOR_ROW_ADDRESS%
  rts

render_vi_command_cursor:
  lda %EDITOR_COMMAND_LENGTH_ADDRESS%
  clc
  adc #$01
  sta %TERMINAL_CURSOR_COLUMN_ADDRESS%
  lda #%TERMINAL_LAST_ROW%
  sta %TERMINAL_CURSOR_ROW_ADDRESS%
  rts

print_vi_normal_label:
  lda #'-'
  jsr write_terminal_byte
  lda #'-'
  jsr write_terminal_byte
  lda #' '
  jsr write_terminal_byte
  lda #'N'
  jsr write_terminal_byte
  lda #'O'
  jsr write_terminal_byte
  lda #'R'
  jsr write_terminal_byte
  lda #'M'
  jsr write_terminal_byte
  lda #'A'
  jsr write_terminal_byte
  lda #'L'
  jsr write_terminal_byte
  lda #' '
  jsr write_terminal_byte
  lda #'-'
  jsr write_terminal_byte
  lda #'-'
  jmp write_terminal_byte

print_vi_insert_label:
  lda #'-'
  jsr write_terminal_byte
  lda #'-'
  jsr write_terminal_byte
  lda #' '
  jsr write_terminal_byte
  lda #'I'
  jsr write_terminal_byte
  lda #'N'
  jsr write_terminal_byte
  lda #'S'
  jsr write_terminal_byte
  lda #'E'
  jsr write_terminal_byte
  lda #'R'
  jsr write_terminal_byte
  lda #'T'
  jsr write_terminal_byte
  lda #' '
  jsr write_terminal_byte
  lda #'-'
  jsr write_terminal_byte
  lda #'-'
  jmp write_terminal_byte

handle_vi_key:
  ldx %EDITOR_MODE_ADDRESS%
  cpx #$01
  bne handle_vi_key_check_command
  jmp handle_vi_insert_key

handle_vi_key_check_command:
  cpx #$02
  bne handle_vi_key_check_search
  jmp handle_vi_command_key

handle_vi_key_check_search:
  cpx #$03
  bne handle_vi_key_normal
  jmp handle_vi_search_key

handle_vi_key_normal:
  jmp handle_vi_normal_key

handle_vi_normal_key:
  tax
  lda %EDITOR_PENDING_KEY_ADDRESS%
  beq handle_vi_normal_key_restore
  cmp #'c'
  beq handle_vi_normal_key_pending_c
  cmp #'d'
  beq handle_vi_normal_key_pending_d
  cmp #'r'
  beq handle_vi_normal_key_pending_r
  cmp #'y'
  beq handle_vi_normal_key_pending_y
  cmp #'g'
  beq handle_vi_normal_key_pending_g
  jmp handle_vi_normal_key_clear_pending

handle_vi_normal_key_pending_c:
  txa
  cmp #'w'
  beq handle_vi_normal_key_run_cw
  jmp handle_vi_normal_key_clear_pending

handle_vi_normal_key_pending_d:
  txa
  cmp #'d'
  beq handle_vi_normal_key_run_dd
  cmp #'w'
  beq handle_vi_normal_key_run_dw
  jmp handle_vi_normal_key_clear_pending

handle_vi_normal_key_pending_r:
  txa
  cmp #$20
  bcc handle_vi_normal_key_clear_pending
  cmp #$7F
  bcs handle_vi_normal_key_clear_pending
  jmp handle_vi_normal_key_run_r

handle_vi_normal_key_pending_y:
  txa
  cmp #'y'
  beq handle_vi_normal_key_run_yy
  cmp #'w'
  beq handle_vi_normal_key_run_yw
  jmp handle_vi_normal_key_clear_pending

handle_vi_normal_key_pending_g:
  txa
  cmp #'g'
  beq handle_vi_normal_key_run_gg
  jmp handle_vi_normal_key_clear_pending

handle_vi_normal_key_run_dd:
  lda #$00
  sta %EDITOR_PENDING_KEY_ADDRESS%
  jmp vi_delete_current_line_key

handle_vi_normal_key_run_cw:
  lda #$00
  sta %EDITOR_PENDING_KEY_ADDRESS%
  jmp vi_change_word_key

handle_vi_normal_key_run_dw:
  lda #$00
  sta %EDITOR_PENDING_KEY_ADDRESS%
  jmp vi_delete_word_key

handle_vi_normal_key_run_r:
  jsr vi_replace_current_char_key
  clc
  rts

handle_vi_normal_key_run_yy:
  lda #$00
  sta %EDITOR_PENDING_KEY_ADDRESS%
  jmp vi_yank_current_line_key

handle_vi_normal_key_run_yw:
  lda #$00
  sta %EDITOR_PENDING_KEY_ADDRESS%
  jmp vi_yank_word_key

handle_vi_normal_key_run_gg:
  lda #$00
  sta %EDITOR_PENDING_KEY_ADDRESS%
  jmp vi_move_file_start

handle_vi_normal_key_clear_pending:
  lda #$00
  sta %EDITOR_PENDING_KEY_ADDRESS%

handle_vi_normal_key_restore:
  txa

handle_vi_normal_key_dispatch:
  cmp #%KEY_LEFT%
  bne handle_vi_normal_key_left_char
  jmp vi_move_left

handle_vi_normal_key_left_char:
  cmp #'h'
  bne handle_vi_normal_key_j
  jmp vi_move_left

handle_vi_normal_key_j:
  cmp #%KEY_DOWN%
  bne handle_vi_normal_key_down_char
  jmp vi_move_down

handle_vi_normal_key_down_char:
  cmp #'j'
  bne handle_vi_normal_key_k
  jmp vi_move_down

handle_vi_normal_key_k:
  cmp #%KEY_UP%
  bne handle_vi_normal_key_up_char
  jmp vi_move_up

handle_vi_normal_key_up_char:
  cmp #'k'
  bne handle_vi_normal_key_l
  jmp vi_move_up

handle_vi_normal_key_l:
  cmp #%KEY_RIGHT%
  bne handle_vi_normal_key_right_char
  jmp vi_move_right

handle_vi_normal_key_right_char:
  cmp #'l'
  bne handle_vi_normal_key_zero
  jmp vi_move_right

handle_vi_normal_key_zero:
  cmp #'0'
  bne handle_vi_normal_key_dollar
  jmp vi_move_line_start

handle_vi_normal_key_dollar:
  cmp #'$'
  bne handle_vi_normal_key_w
  jmp vi_move_line_end

handle_vi_normal_key_w:
  cmp #'w'
  bne handle_vi_normal_key_b
  jmp vi_move_word_forward

handle_vi_normal_key_b:
  cmp #'b'
  bne handle_vi_normal_key_e
  jmp vi_move_word_backward

handle_vi_normal_key_e:
  cmp #'e'
  bne handle_vi_normal_key_g
  jmp vi_move_word_end

handle_vi_normal_key_g:
  cmp #'g'
  bne handle_vi_normal_key_G
  jmp vi_wait_for_double_g

handle_vi_normal_key_G:
  cmp #'G'
  bne handle_vi_normal_key_star
  jmp vi_move_file_end

handle_vi_normal_key_star:
  cmp #'*'
  bne handle_vi_normal_key_hash
  jmp vi_search_current_word_forward_key

handle_vi_normal_key_hash:
  cmp #'#'
  bne handle_vi_normal_key_percent
  jmp vi_search_current_word_reverse_key

handle_vi_normal_key_percent:
  cmp #'%'
  bne handle_vi_normal_key_i
  jmp vi_jump_match_key

handle_vi_normal_key_i:
  cmp #'i'
  bne handle_vi_normal_key_a
  jmp vi_enter_insert_mode

handle_vi_normal_key_a:
  cmp #'a'
  bne handle_vi_normal_key_A
  jmp vi_append_after_cursor

handle_vi_normal_key_A:
  cmp #'A'
  bne handle_vi_normal_key_o
  jmp vi_append_at_line_end

handle_vi_normal_key_o:
  cmp #'o'
  bne handle_vi_normal_key_O
  jmp vi_open_line_below

handle_vi_normal_key_O:
  cmp #'O'
  bne handle_vi_normal_key_J
  jmp vi_open_line_above

handle_vi_normal_key_J:
  cmp #'J'
  bne handle_vi_normal_key_x
  jmp vi_join_line_key

handle_vi_normal_key_x:
  cmp #'x'
  bne handle_vi_normal_key_r
  jmp vi_delete_at_cursor_key

handle_vi_normal_key_r:
  cmp #'r'
  bne handle_vi_normal_key_c
  jmp vi_wait_for_replace

handle_vi_normal_key_c:
  cmp #'c'
  bne handle_vi_normal_key_d
  jmp vi_wait_for_change

handle_vi_normal_key_d:
  cmp #'d'
  bne handle_vi_normal_key_y
  jmp vi_wait_for_double_delete

handle_vi_normal_key_y:
  cmp #'y'
  bne handle_vi_normal_key_p
  jmp vi_wait_for_double_yank

handle_vi_normal_key_p:
  cmp #'p'
  bne handle_vi_normal_key_P
  jmp vi_put_after_cursor_key

handle_vi_normal_key_P:
  cmp #'P'
  bne handle_vi_normal_key_u
  jmp vi_put_before_cursor_key

handle_vi_normal_key_u:
  cmp #'u'
  bne handle_vi_normal_key_slash
  jmp vi_undo_key

handle_vi_normal_key_slash:
  cmp #'/'
  bne handle_vi_normal_key_question
  jmp vi_enter_search_mode

handle_vi_normal_key_question:
  cmp #'?'
  bne handle_vi_normal_key_n
  jmp vi_enter_reverse_search_mode

handle_vi_normal_key_n:
  cmp #'n'
  bne handle_vi_normal_key_N
  jmp vi_repeat_search_forward_key

handle_vi_normal_key_N:
  cmp #'N'
  bne handle_vi_normal_key_colon
  jmp vi_repeat_search_reverse_key

handle_vi_normal_key_colon:
  cmp #':'
  bne handle_vi_normal_key_done
  jmp vi_enter_command_mode

handle_vi_normal_key_done:
  clc
  rts

vi_move_left:
  lda %EDITOR_CURSOR_INDEX_ADDRESS%
  bne vi_move_left_apply
  clc
  rts

vi_move_left_apply:
  dec %EDITOR_CURSOR_INDEX_ADDRESS%
  clc
  rts

vi_move_right:
  lda %EDITOR_CURSOR_INDEX_ADDRESS%
  cmp %LOAD_LENGTH_LOW_ADDRESS%
  bcc vi_move_right_apply
  clc
  rts

vi_move_right_apply:
  inc %EDITOR_CURSOR_INDEX_ADDRESS%
  clc
  rts

; Move to the beginning of the current logical line, stopping just after the
; previous newline when editing multi-line text.
vi_move_line_start:
  ldx %EDITOR_CURSOR_INDEX_ADDRESS%

vi_move_line_start_scan_loop:
  cpx #$00
  beq vi_move_line_start_store
  dex
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp #$0A
  beq vi_move_line_start_after_newline
  jmp vi_move_line_start_scan_loop

vi_move_line_start_after_newline:
  inx

vi_move_line_start_store:
  stx %EDITOR_CURSOR_INDEX_ADDRESS%
  clc
  rts

; Move to the final character of the current logical line. On an empty line we
; simply stay at the line start because there is no character to land on.
vi_move_line_end:
  jsr vi_move_line_end_insert_point
  lda %EDITOR_CURSOR_INDEX_ADDRESS%
  cmp %LOAD_LENGTH_LOW_ADDRESS%
  beq vi_move_line_end_step_back
  ldx %EDITOR_CURSOR_INDEX_ADDRESS%
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp #$0A
  beq vi_move_line_end_step_back
  clc
  rts

vi_move_line_end_step_back:
  lda %EDITOR_CURSOR_INDEX_ADDRESS%
  beq vi_move_line_end_done
  dec %EDITOR_CURSOR_INDEX_ADDRESS%

vi_move_line_end_done:
  clc
  rts

; Find the insertion point at the end of the current logical line. This is
; used by append-style commands that want to type after the line contents.
vi_move_line_end_insert_point:
  ldx %EDITOR_CURSOR_INDEX_ADDRESS%

vi_move_line_end_scan_loop:
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  beq vi_move_line_end_store
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp #$0A
  beq vi_move_line_end_store
  inx
  jmp vi_move_line_end_scan_loop

vi_move_line_end_store:
  stx %EDITOR_CURSOR_INDEX_ADDRESS%
  rts

; Move to the first byte of the file.
vi_move_file_start:
  lda #$00
  sta %EDITOR_CURSOR_INDEX_ADDRESS%
  clc
  rts

; Move to the final editable character in the file, if one exists.
vi_move_file_end:
  lda %LOAD_LENGTH_LOW_ADDRESS%
  beq vi_move_file_end_done
  dec %LOAD_LENGTH_LOW_ADDRESS%
  lda %LOAD_LENGTH_LOW_ADDRESS%
  sta %EDITOR_CURSOR_INDEX_ADDRESS%
  inc %LOAD_LENGTH_LOW_ADDRESS%

vi_move_file_end_trim_newline:
  ldx %EDITOR_CURSOR_INDEX_ADDRESS%
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp #$0A
  bne vi_move_file_end_done
  lda %EDITOR_CURSOR_INDEX_ADDRESS%
  beq vi_move_file_end_done
  dec %EDITOR_CURSOR_INDEX_ADDRESS%
  jmp vi_move_file_end_trim_newline

vi_move_file_end_done:
  clc
  rts

; "w" moves to the first byte of the next word, skipping the current word and
; then any separating spaces or newlines.
vi_move_word_forward:
  ldx %EDITOR_CURSOR_INDEX_ADDRESS%
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  bcc vi_move_word_forward_check_char
  clc
  rts

vi_move_word_forward_check_char:
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp #' '
  beq vi_move_word_forward_skip_space
  cmp #$0A
  beq vi_move_word_forward_skip_space

vi_move_word_forward_skip_current:
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  beq vi_move_word_forward_store
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp #' '
  beq vi_move_word_forward_skip_space
  cmp #$0A
  beq vi_move_word_forward_skip_space
  inx
  jmp vi_move_word_forward_skip_current

vi_move_word_forward_skip_space:
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  beq vi_move_word_forward_store
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp #' '
  beq vi_move_word_forward_skip_space_advance
  cmp #$0A
  beq vi_move_word_forward_skip_space_advance
  jmp vi_move_word_forward_store

vi_move_word_forward_skip_space_advance:
  inx
  jmp vi_move_word_forward_skip_space

vi_move_word_forward_store:
  stx %EDITOR_CURSOR_INDEX_ADDRESS%
  clc
  rts

; "b" moves backward to the first byte of the previous word.
vi_move_word_backward:
  ldx %EDITOR_CURSOR_INDEX_ADDRESS%
  cpx #$00
  beq vi_move_word_backward_done
  dex

vi_move_word_backward_skip_space:
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp #' '
  beq vi_move_word_backward_step_space
  cmp #$0A
  beq vi_move_word_backward_step_space
  jmp vi_move_word_backward_scan_word

vi_move_word_backward_step_space:
  cpx #$00
  beq vi_move_word_backward_store
  dex
  jmp vi_move_word_backward_skip_space

vi_move_word_backward_scan_word:
  cpx #$00
  beq vi_move_word_backward_store
  lda %LOAD_BUFFER_ADDRESS% - 1, x
  cmp #' '
  beq vi_move_word_backward_store
  cmp #$0A
  beq vi_move_word_backward_store
  dex
  jmp vi_move_word_backward_scan_word

vi_move_word_backward_store:
  stx %EDITOR_CURSOR_INDEX_ADDRESS%

vi_move_word_backward_done:
  clc
  rts

; "e" moves to the last byte of the current word, or the next word if the
; cursor is sitting on separating whitespace.
vi_move_word_end:
  ldx %EDITOR_CURSOR_INDEX_ADDRESS%
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  bcc vi_move_word_end_skip_space
  clc
  rts

vi_move_word_end_skip_space:
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp #' '
  beq vi_move_word_end_skip_space_advance
  cmp #$0A
  beq vi_move_word_end_skip_space_advance
  jmp vi_move_word_end_scan_word

vi_move_word_end_skip_space_advance:
  inx
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  bcc vi_move_word_end_skip_space
  dex
  stx %EDITOR_CURSOR_INDEX_ADDRESS%
  clc
  rts

vi_move_word_end_scan_word:
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  beq vi_move_word_end_step_back
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp #' '
  beq vi_move_word_end_step_back
  cmp #$0A
  beq vi_move_word_end_step_back
  inx
  jmp vi_move_word_end_scan_word

vi_move_word_end_step_back:
  dex
  stx %EDITOR_CURSOR_INDEX_ADDRESS%
  clc
  rts

vi_enter_insert_mode:
  lda #$01
  sta %EDITOR_MODE_ADDRESS%
  lda #$00
  sta %EDITOR_PENDING_KEY_ADDRESS%
  clc
  rts

vi_append_after_cursor:
  lda %EDITOR_CURSOR_INDEX_ADDRESS%
  cmp %LOAD_LENGTH_LOW_ADDRESS%
  bcs vi_append_after_cursor_enter
  inc %EDITOR_CURSOR_INDEX_ADDRESS%

vi_append_after_cursor_enter:
  lda #$01
  sta %EDITOR_MODE_ADDRESS%
  lda #$00
  sta %EDITOR_PENDING_KEY_ADDRESS%
  clc
  rts

; "A" jumps to the end of the current line and starts inserting there.
vi_append_at_line_end:
  jsr vi_move_line_end_insert_point
  lda #$01
  sta %EDITOR_MODE_ADDRESS%
  lda #$00
  sta %EDITOR_PENDING_KEY_ADDRESS%
  clc
  rts

; "o" opens a blank line below the current one. We scan forward to the line
; ending (or EOF), insert a newline there, and drop straight into insert mode
; so typed text lands on the new blank line.
vi_open_line_below:
  ldx %EDITOR_CURSOR_INDEX_ADDRESS%

vi_open_line_below_scan_loop:
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  beq vi_open_line_below_insert
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp #$0A
  beq vi_open_line_below_insert
  inx
  jmp vi_open_line_below_scan_loop

vi_open_line_below_insert:
  stx %EDITOR_CURSOR_INDEX_ADDRESS%
  jsr vi_save_undo_snapshot
  lda #$0A
  jsr vi_insert_byte_at_cursor
  lda #$01
  sta %EDITOR_MODE_ADDRESS%
  lda #$00
  sta %EDITOR_PENDING_KEY_ADDRESS%
  clc
  rts

; "O" opens a blank line above the current one by inserting a newline at the
; current line start, then moving the cursor back onto the new blank line.
vi_open_line_above:
  jsr vi_move_line_start
  jsr vi_save_undo_snapshot
  lda #$0A
  jsr vi_insert_byte_at_cursor
  dec %EDITOR_CURSOR_INDEX_ADDRESS%
  lda #$01
  sta %EDITOR_MODE_ADDRESS%
  lda #$00
  sta %EDITOR_PENDING_KEY_ADDRESS%
  clc
  rts

vi_enter_command_mode:
  lda #$02
  sta %EDITOR_MODE_ADDRESS%
  lda #$00
  sta %EDITOR_COMMAND_LENGTH_ADDRESS%
  sta %EDITOR_PENDING_KEY_ADDRESS%
  clc
  rts

vi_enter_search_mode:
  lda #$00
  sta %EDITOR_SEARCH_DIRECTION_ADDRESS%
  lda #$03
  sta %EDITOR_MODE_ADDRESS%
  lda #$00
  sta %EDITOR_COMMAND_LENGTH_ADDRESS%
  sta %EDITOR_PENDING_KEY_ADDRESS%
  clc
  rts

vi_enter_reverse_search_mode:
  lda #$01
  sta %EDITOR_SEARCH_DIRECTION_ADDRESS%
  lda #$03
  sta %EDITOR_MODE_ADDRESS%
  lda #$00
  sta %EDITOR_COMMAND_LENGTH_ADDRESS%
  sta %EDITOR_PENDING_KEY_ADDRESS%
  clc
  rts

vi_delete_at_cursor_key:
  jsr vi_save_undo_snapshot
  jsr vi_delete_at_cursor
  clc
  rts

vi_wait_for_double_delete:
  lda #'d'
  sta %EDITOR_PENDING_KEY_ADDRESS%
  clc
  rts

vi_wait_for_change:
  lda #'c'
  sta %EDITOR_PENDING_KEY_ADDRESS%
  clc
  rts

vi_wait_for_replace:
  lda #'r'
  sta %EDITOR_PENDING_KEY_ADDRESS%
  clc
  rts

vi_wait_for_double_yank:
  lda #'y'
  sta %EDITOR_PENDING_KEY_ADDRESS%
  clc
  rts

vi_wait_for_double_g:
  lda #'g'
  sta %EDITOR_PENDING_KEY_ADDRESS%
  clc
  rts

vi_delete_current_line_key:
  jsr vi_save_undo_snapshot
  jsr vi_delete_current_line
  clc
  rts

vi_delete_word_key:
  jsr vi_save_undo_snapshot
  jsr vi_delete_word
  clc
  rts

vi_change_word_key:
  jsr vi_save_undo_snapshot
  jsr vi_change_word
  lda #$01
  sta %EDITOR_MODE_ADDRESS%
  lda #$00
  sta %EDITOR_PENDING_KEY_ADDRESS%
  clc
  rts

vi_yank_current_line_key:
  jsr vi_yank_current_line
  clc
  rts

vi_yank_word_key:
  jsr vi_yank_word
  clc
  rts

vi_put_after_cursor_key:
  jsr vi_save_undo_snapshot
  jsr vi_put_after_cursor
  clc
  rts

vi_put_before_cursor_key:
  jsr vi_save_undo_snapshot
  jsr vi_put_before_cursor
  clc
  rts

vi_join_line_key:
  jsr vi_save_undo_snapshot
  jsr vi_join_line
  clc
  rts

vi_undo_key:
  jsr vi_restore_undo_snapshot
  clc
  rts

vi_search_current_word_forward_key:
  jsr vi_store_current_word_as_search
  lda %EDITOR_SEARCH_LENGTH_ADDRESS%
  beq vi_search_current_word_done
  lda #$00
  sta %EDITOR_SEARCH_DIRECTION_ADDRESS%
  jsr vi_find_next_search_match

vi_search_current_word_done:
  clc
  rts

vi_search_current_word_reverse_key:
  jsr vi_store_current_word_as_search
  lda %EDITOR_SEARCH_LENGTH_ADDRESS%
  beq vi_search_current_word_reverse_done
  lda #$01
  sta %EDITOR_SEARCH_DIRECTION_ADDRESS%
  jsr vi_find_previous_search_match

vi_search_current_word_reverse_done:
  clc
  rts

vi_jump_match_key:
  jsr vi_jump_match
  clc
  rts

vi_repeat_search_forward_key:
  lda %EDITOR_SEARCH_DIRECTION_ADDRESS%
  beq vi_repeat_search_forward_same
  jsr vi_find_previous_search_match
  clc
  rts

vi_repeat_search_forward_same:
  jsr vi_find_next_search_match
  clc
  rts

vi_repeat_search_reverse_key:
  lda %EDITOR_SEARCH_DIRECTION_ADDRESS%
  beq vi_repeat_search_reverse_previous
  jsr vi_find_next_search_match
  clc
  rts

vi_repeat_search_reverse_previous:
  jsr vi_find_previous_search_match
  clc
  rts

handle_vi_insert_key:
  cmp #%KEY_LEFT%
  beq vi_insert_move_left
  cmp #%KEY_RIGHT%
  beq vi_insert_move_right
  cmp #%KEY_UP%
  beq vi_insert_move_up
  cmp #%KEY_DOWN%
  beq vi_insert_move_down
  cmp #$1B
  beq vi_leave_insert_mode
  cmp #$08
  beq vi_insert_backspace
  cmp #$0D
  beq vi_insert_newline
  cmp #$20
  bcc handle_vi_insert_key_done
  cmp #$7F
  bcs handle_vi_insert_key_done
  pha
  jsr vi_save_undo_snapshot
  pla
  jsr vi_insert_byte_at_cursor
  clc
  rts

handle_vi_insert_key_done:
  clc
  rts

vi_insert_move_left:
  jsr vi_move_left
  clc
  rts

vi_insert_move_right:
  jsr vi_move_right
  clc
  rts

vi_insert_move_up:
  jsr vi_move_up
  clc
  rts

vi_insert_move_down:
  jsr vi_move_down
  clc
  rts

vi_leave_insert_mode:
  lda #$00
  sta %EDITOR_MODE_ADDRESS%
  sta %EDITOR_PENDING_KEY_ADDRESS%
  clc
  rts

vi_insert_backspace:
  jsr vi_save_undo_snapshot
  jsr vi_delete_before_cursor
  clc
  rts

vi_insert_newline:
  jsr vi_save_undo_snapshot
  lda #$0A
  jsr vi_insert_byte_at_cursor
  clc
  rts

handle_vi_command_key:
  cmp #$1B
  beq handle_vi_command_key_escape
  cmp #$08
  beq handle_vi_command_key_backspace
  cmp #$0D
  beq handle_vi_command_key_enter
  cmp #$20
  bcc handle_vi_command_key_done
  cmp #$7F
  bcs handle_vi_command_key_done
  ldx %EDITOR_COMMAND_LENGTH_ADDRESS%
  cpx #%EDITOR_COMMAND_BUFFER_MAX_INDEX%
  bcc handle_vi_command_key_store
  clc
  rts

handle_vi_command_key_store:
  sta %EDITOR_COMMAND_BUFFER_ADDRESS%, x
  inx
  stx %EDITOR_COMMAND_LENGTH_ADDRESS%
  clc
  rts

handle_vi_command_key_escape:
  jmp vi_leave_command_mode

handle_vi_command_key_backspace:
  jmp vi_command_backspace

handle_vi_command_key_enter:
  jmp vi_execute_command

handle_vi_command_key_done:
  clc
  rts

handle_vi_search_key:
  cmp #$1B
  beq handle_vi_search_key_escape
  cmp #$08
  beq handle_vi_search_key_backspace
  cmp #$0D
  beq handle_vi_search_key_enter
  cmp #$20
  bcc handle_vi_search_key_done
  cmp #$7F
  bcs handle_vi_search_key_done
  ldx %EDITOR_COMMAND_LENGTH_ADDRESS%
  cpx #%EDITOR_COMMAND_BUFFER_MAX_INDEX%
  bcc handle_vi_search_key_store
  clc
  rts

handle_vi_search_key_store:
  sta %EDITOR_COMMAND_BUFFER_ADDRESS%, x
  inx
  stx %EDITOR_COMMAND_LENGTH_ADDRESS%
  clc
  rts

handle_vi_search_key_escape:
  jmp vi_leave_search_mode

handle_vi_search_key_backspace:
  jmp vi_search_backspace

handle_vi_search_key_enter:
  jmp vi_execute_search

handle_vi_search_key_done:
  clc
  rts

vi_leave_search_mode:
  lda #$00
  sta %EDITOR_MODE_ADDRESS%
  sta %EDITOR_COMMAND_LENGTH_ADDRESS%
  sta %EDITOR_PENDING_KEY_ADDRESS%
  clc
  rts

vi_search_backspace:
  lda %EDITOR_COMMAND_LENGTH_ADDRESS%
  bne vi_search_backspace_apply
  clc
  rts

vi_search_backspace_apply:
  dec %EDITOR_COMMAND_LENGTH_ADDRESS%
  clc
  rts

vi_execute_search:
  lda %EDITOR_COMMAND_LENGTH_ADDRESS%
  beq vi_leave_search_mode
  sta %EDITOR_SEARCH_LENGTH_ADDRESS%
  ldx #$00

vi_execute_search_copy_loop:
  cpx %EDITOR_COMMAND_LENGTH_ADDRESS%
  beq vi_execute_search_done_copy
  lda %EDITOR_COMMAND_BUFFER_ADDRESS%, x
  sta %EDITOR_SEARCH_BUFFER_ADDRESS%, x
  inx
  jmp vi_execute_search_copy_loop

vi_execute_search_done_copy:
  lda #$00
  sta %EDITOR_MODE_ADDRESS%
  sta %EDITOR_COMMAND_LENGTH_ADDRESS%
  lda %EDITOR_SEARCH_DIRECTION_ADDRESS%
  beq vi_execute_search_forward
  jsr vi_find_previous_search_match
  clc
  rts

vi_execute_search_forward:
  jsr vi_find_next_search_match
  clc
  rts

vi_leave_command_mode:
  lda #$00
  sta %EDITOR_MODE_ADDRESS%
  sta %EDITOR_COMMAND_LENGTH_ADDRESS%
  sta %EDITOR_PENDING_KEY_ADDRESS%
  clc
  rts

vi_command_backspace:
  lda %EDITOR_COMMAND_LENGTH_ADDRESS%
  bne vi_command_backspace_apply
  clc
  rts

vi_command_backspace_apply:
  dec %EDITOR_COMMAND_LENGTH_ADDRESS%
  clc
  rts

vi_execute_command:
  lda %EDITOR_COMMAND_LENGTH_ADDRESS%
  beq vi_leave_command_mode
  cmp #$01
  beq vi_execute_short_command
  cmp #$02
  beq vi_execute_two_char_command
  jmp vi_leave_command_mode

vi_execute_short_command:
  lda %EDITOR_COMMAND_BUFFER_ADDRESS%
  cmp #'w'
  beq vi_execute_write_command
  cmp #'q'
  beq vi_execute_quit_command
  jmp vi_leave_command_mode

vi_execute_two_char_command:
  lda %EDITOR_COMMAND_BUFFER_ADDRESS%
  cmp #'w'
  beq vi_execute_two_char_write
  cmp #'q'
  bne vi_leave_command_mode
  lda %EDITOR_COMMAND_BUFFER_ADDRESS% + 1
  cmp #'!'
  bne vi_leave_command_mode
  jmp vi_execute_quit_command

vi_execute_two_char_write:
  lda %EDITOR_COMMAND_BUFFER_ADDRESS% + 1
  cmp #'q'
  bne vi_leave_command_mode
  jsr save_vi_buffer_to_file
  sec
  rts

vi_execute_write_command:
  jsr save_vi_buffer_to_file
  lda #$00
  sta %EDITOR_MODE_ADDRESS%
  sta %EDITOR_COMMAND_LENGTH_ADDRESS%
  clc
  rts

vi_execute_quit_command:
  sec
  rts

save_vi_buffer_to_file:
  jsr copy_editor_path_to_fs_path
  lda %LOAD_LENGTH_LOW_ADDRESS%
  sta %FS_DATA_LENGTH_LOW_ADDRESS%
  lda #$00
  sta %FS_DATA_LENGTH_HIGH_ADDRESS%
  ldx #$00

save_vi_buffer_copy_loop:
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  beq save_vi_buffer_issue_write
  lda %LOAD_BUFFER_ADDRESS%, x
  sta %FS_DATA_BUFFER_ADDRESS%, x
  inx
  jmp save_vi_buffer_copy_loop

save_vi_buffer_issue_write:
  lda #%FS_COMMAND_WRITE%
  sta %FS_COMMAND_ADDRESS%
  lda %FS_STATUS_ADDRESS%
  and #$02
  beq save_vi_buffer_done
  jmp print_filesystem_error

save_vi_buffer_done:
  lda #$00
  sta %EDITOR_DIRTY_ADDRESS%
  rts

; Save a one-step undo snapshot of the current editor buffer and cursor.
vi_save_undo_snapshot:
  lda %LOAD_LENGTH_LOW_ADDRESS%
  sta %EDITOR_UNDO_LENGTH_ADDRESS%
  lda %EDITOR_CURSOR_INDEX_ADDRESS%
  sta %EDITOR_UNDO_CURSOR_ADDRESS%
  lda %LOAD_PRESENT_ADDRESS%
  sta %EDITOR_UNDO_PRESENT_ADDRESS%
  lda %EDITOR_DIRTY_ADDRESS%
  sta %EDITOR_UNDO_DIRTY_ADDRESS%
  lda #$01
  sta %EDITOR_UNDO_VALID_ADDRESS%
  ldx #$00

vi_save_undo_snapshot_loop:
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  beq vi_save_undo_snapshot_done
  lda %LOAD_BUFFER_ADDRESS%, x
  sta %EDITOR_UNDO_BUFFER_ADDRESS%, x
  inx
  jmp vi_save_undo_snapshot_loop

vi_save_undo_snapshot_done:
  rts

; Restore the most recent one-step undo snapshot when one is available.
vi_restore_undo_snapshot:
  lda %EDITOR_UNDO_VALID_ADDRESS%
  bne vi_restore_undo_snapshot_begin
  rts

vi_restore_undo_snapshot_begin:
  lda %EDITOR_UNDO_LENGTH_ADDRESS%
  sta %LOAD_LENGTH_LOW_ADDRESS%
  lda #$00
  sta %LOAD_LENGTH_HIGH_ADDRESS%
  ldx #$00

vi_restore_undo_snapshot_copy_loop:
  cpx #%LOAD_BUFFER_MAX_INDEX%
  bcc vi_restore_undo_snapshot_copy_body
  beq vi_restore_undo_snapshot_copy_body
  jmp vi_restore_undo_snapshot_finish

vi_restore_undo_snapshot_copy_body:
  cpx %EDITOR_UNDO_LENGTH_ADDRESS%
  bcc vi_restore_undo_snapshot_copy_saved
  lda #$00
  sta %LOAD_BUFFER_ADDRESS%, x
  inx
  jmp vi_restore_undo_snapshot_copy_loop

vi_restore_undo_snapshot_copy_saved:
  lda %EDITOR_UNDO_BUFFER_ADDRESS%, x
  sta %LOAD_BUFFER_ADDRESS%, x
  inx
  jmp vi_restore_undo_snapshot_copy_loop

vi_restore_undo_snapshot_finish:
  lda %EDITOR_UNDO_CURSOR_ADDRESS%
  sta %EDITOR_CURSOR_INDEX_ADDRESS%
  lda %EDITOR_UNDO_PRESENT_ADDRESS%
  sta %LOAD_PRESENT_ADDRESS%
  lda %EDITOR_UNDO_DIRTY_ADDRESS%
  sta %EDITOR_DIRTY_ADDRESS%
  lda #$00
  sta %LOAD_RUNNABLE_ADDRESS%
  sta %EDITOR_PENDING_KEY_ADDRESS%
  sta %EDITOR_UNDO_VALID_ADDRESS%
  rts

vi_insert_byte_at_cursor:
  sta %WRITE_SEPARATOR_INDEX_ADDRESS%
  lda %LOAD_LENGTH_LOW_ADDRESS%
  cmp #%LOAD_BUFFER_MAX_INDEX%
  bcc vi_insert_byte_shift_prepare
  beq vi_insert_byte_shift_prepare
  rts

vi_insert_byte_shift_prepare:
  ldx %LOAD_LENGTH_LOW_ADDRESS%

vi_insert_byte_shift_loop:
  cpx %EDITOR_CURSOR_INDEX_ADDRESS%
  beq vi_insert_byte_write
  lda %LOAD_BUFFER_ADDRESS% - 1, x
  sta %LOAD_BUFFER_ADDRESS%, x
  dex
  jmp vi_insert_byte_shift_loop

vi_insert_byte_write:
  lda %WRITE_SEPARATOR_INDEX_ADDRESS%
  sta %LOAD_BUFFER_ADDRESS%, x
  inc %EDITOR_CURSOR_INDEX_ADDRESS%
  inc %LOAD_LENGTH_LOW_ADDRESS%
  lda #$01
  sta %LOAD_PRESENT_ADDRESS%
  sta %EDITOR_DIRTY_ADDRESS%
  lda #$00
  sta %LOAD_RUNNABLE_ADDRESS%
  rts

vi_delete_before_cursor:
  lda %EDITOR_CURSOR_INDEX_ADDRESS%
  beq vi_delete_before_cursor_done
  dec %EDITOR_CURSOR_INDEX_ADDRESS%
  jmp vi_delete_at_cursor

vi_delete_before_cursor_done:
  rts

vi_delete_at_cursor:
  ldx %EDITOR_CURSOR_INDEX_ADDRESS%
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  bcc vi_delete_at_cursor_apply
  rts

vi_delete_at_cursor_apply:
  lda %LOAD_LENGTH_LOW_ADDRESS%
  sec
  sbc #$01
  sta %WRITE_DATA_LENGTH_ADDRESS%

vi_delete_shift_loop:
  cpx %WRITE_DATA_LENGTH_ADDRESS%
  beq vi_delete_clear_last
  lda %LOAD_BUFFER_ADDRESS% + 1, x
  sta %LOAD_BUFFER_ADDRESS%, x
  inx
  jmp vi_delete_shift_loop

vi_delete_clear_last:
  lda #$00
  sta %LOAD_BUFFER_ADDRESS%, x
  dec %LOAD_LENGTH_LOW_ADDRESS%
  lda #$01
  sta %EDITOR_DIRTY_ADDRESS%
  lda #$00
  sta %LOAD_RUNNABLE_ADDRESS%

vi_delete_done:
  rts

; Copy the current [start, end) range into the vi yank buffer. Bit 7 of the
; metadata byte marks linewise yanks while the low bits hold the copied length.
vi_copy_range_to_yank_buffer:
  sta %PRINT_POINTER_HIGH_ADDRESS%
  lda %COMMAND_LENGTH_ADDRESS%
  sec
  sbc %WRITE_SEPARATOR_INDEX_ADDRESS%
  beq vi_copy_range_to_yank_buffer_empty
  cmp #%EDITOR_YANK_BUFFER_SIZE%
  bcc vi_copy_range_to_yank_buffer_length_ready
  lda #%EDITOR_YANK_BUFFER_SIZE%

vi_copy_range_to_yank_buffer_length_ready:
  sta %WRITE_DATA_LENGTH_ADDRESS%
  ldx %WRITE_SEPARATOR_INDEX_ADDRESS%
  ldy #$00

vi_copy_range_to_yank_buffer_loop:
  cpy %WRITE_DATA_LENGTH_ADDRESS%
  beq vi_copy_range_to_yank_buffer_done
  lda %LOAD_BUFFER_ADDRESS%, x
  sta %EDITOR_YANK_BUFFER_ADDRESS%, y
  inx
  iny
  jmp vi_copy_range_to_yank_buffer_loop

vi_copy_range_to_yank_buffer_done:
  lda %PRINT_POINTER_HIGH_ADDRESS%
  ora %WRITE_DATA_LENGTH_ADDRESS%
  sta %LOAD_LENGTH_HIGH_ADDRESS%
  rts

vi_copy_range_to_yank_buffer_empty:
  lda #$00
  sta %LOAD_LENGTH_HIGH_ADDRESS%
  rts

; Find the current logical line boundaries. The start offset lands on the first
; byte of the line, and the end offset is exclusive, including a trailing
; newline when the line has one.
vi_find_current_line_range:
  lda #$00
  sta %WRITE_SEPARATOR_INDEX_ADDRESS%
  ldx #$00

vi_find_current_line_start_loop:
  cpx %EDITOR_CURSOR_INDEX_ADDRESS%
  beq vi_find_current_line_end_loop
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp #$0A
  bne vi_find_current_line_start_next
  txa
  clc
  adc #$01
  sta %WRITE_SEPARATOR_INDEX_ADDRESS%

vi_find_current_line_start_next:
  inx
  jmp vi_find_current_line_start_loop

vi_find_current_line_end_loop:
  ldx %EDITOR_CURSOR_INDEX_ADDRESS%

vi_find_current_line_end_scan:
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  beq vi_find_current_line_store_end
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp #$0A
  beq vi_find_current_line_include_newline
  inx
  jmp vi_find_current_line_end_scan

vi_find_current_line_include_newline:
  inx

vi_find_current_line_store_end:
  stx %COMMAND_LENGTH_ADDRESS%
  rts

; Delete the current [start, end) range from the shared load buffer.
vi_delete_range:
  lda %COMMAND_LENGTH_ADDRESS%
  sec
  sbc %WRITE_SEPARATOR_INDEX_ADDRESS%
  bne vi_delete_range_apply
  rts

vi_delete_range_apply:
  sta %WRITE_DATA_LENGTH_ADDRESS%
  ldx %WRITE_SEPARATOR_INDEX_ADDRESS%
  ldy %COMMAND_LENGTH_ADDRESS%

vi_delete_range_shift_loop:
  cpy %LOAD_LENGTH_LOW_ADDRESS%
  beq vi_delete_range_shift_done
  lda %LOAD_BUFFER_ADDRESS%, y
  sta %LOAD_BUFFER_ADDRESS%, x
  iny
  inx
  jmp vi_delete_range_shift_loop

vi_delete_range_shift_done:
  lda %LOAD_LENGTH_LOW_ADDRESS%
  sec
  sbc %WRITE_DATA_LENGTH_ADDRESS%
  sta %COMMAND_LENGTH_ADDRESS%
  lda #$00

vi_delete_range_clear_loop:
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  beq vi_delete_range_store_length
  sta %LOAD_BUFFER_ADDRESS%, x
  inx
  jmp vi_delete_range_clear_loop

vi_delete_range_store_length:
  lda %COMMAND_LENGTH_ADDRESS%
  sta %LOAD_LENGTH_LOW_ADDRESS%
  bne vi_delete_range_mark_present
  lda #$00
  sta %LOAD_PRESENT_ADDRESS%
  jmp vi_delete_range_mark_dirty

vi_delete_range_mark_present:
  lda #$01
  sta %LOAD_PRESENT_ADDRESS%

vi_delete_range_mark_dirty:
  lda #$01
  sta %EDITOR_DIRTY_ADDRESS%
  lda #$00
  sta %LOAD_RUNNABLE_ADDRESS%
  rts

; "dd" deletes the whole logical line under the cursor. If the line ends with
; a newline, that newline is removed too so the following line slides up. When
; deleting the final line in a multi-line buffer, we instead remove the
; preceding newline to avoid leaving a trailing blank line behind.
vi_delete_current_line:
  jsr vi_find_current_line_range
  lda %COMMAND_LENGTH_ADDRESS%
  cmp %LOAD_LENGTH_LOW_ADDRESS%
  bne vi_delete_current_line_regular
  lda %WRITE_SEPARATOR_INDEX_ADDRESS%
  beq vi_delete_current_line_regular
  dec %WRITE_SEPARATOR_INDEX_ADDRESS%

vi_delete_current_line_regular:
  lda %WRITE_SEPARATOR_INDEX_ADDRESS%
  sta %EDITOR_CURSOR_INDEX_ADDRESS%
  jmp vi_delete_range

; "dw" deletes the word under the cursor and any trailing spaces on the same
; line. When the cursor starts on spaces, it removes that run of spaces instead.
vi_delete_word:
  lda %EDITOR_CURSOR_INDEX_ADDRESS%
  sta %WRITE_SEPARATOR_INDEX_ADDRESS%
  cmp %LOAD_LENGTH_LOW_ADDRESS%
  bcc vi_delete_word_begin
  rts

vi_delete_word_begin:
  tax
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp #$0A
  beq vi_delete_word_single_newline
  cmp #' '
  beq vi_delete_word_space_run

vi_delete_word_text_run:
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  beq vi_delete_word_store_end
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp #$0A
  beq vi_delete_word_store_end
  cmp #' '
  beq vi_delete_word_trailing_spaces
  inx
  jmp vi_delete_word_text_run

vi_delete_word_trailing_spaces:
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  beq vi_delete_word_store_end
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp #' '
  bne vi_delete_word_store_end
  inx
  jmp vi_delete_word_trailing_spaces

vi_delete_word_space_run:
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  beq vi_delete_word_store_end
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp #' '
  bne vi_delete_word_store_end
  inx
  jmp vi_delete_word_space_run

vi_delete_word_single_newline:
  inx

vi_delete_word_store_end:
  stx %COMMAND_LENGTH_ADDRESS%
  lda #$00
  jsr vi_copy_range_to_yank_buffer
  lda %WRITE_SEPARATOR_INDEX_ADDRESS%
  sta %EDITOR_CURSOR_INDEX_ADDRESS%
  jmp vi_delete_range

; "cw" behaves more like a change-to-end-of-word than "dw": it preserves the
; separating space after a word so replacement text keeps the line shape.
vi_change_word:
  lda %EDITOR_CURSOR_INDEX_ADDRESS%
  sta %WRITE_SEPARATOR_INDEX_ADDRESS%
  cmp %LOAD_LENGTH_LOW_ADDRESS%
  bcc vi_change_word_begin
  rts

vi_change_word_begin:
  tax
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp #$0A
  beq vi_change_word_single_newline
  cmp #' '
  beq vi_change_word_space_run

vi_change_word_text_run:
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  beq vi_change_word_store_end
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp #$0A
  beq vi_change_word_store_end
  cmp #' '
  beq vi_change_word_store_end
  inx
  jmp vi_change_word_text_run

vi_change_word_space_run:
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  beq vi_change_word_store_end
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp #' '
  bne vi_change_word_store_end
  inx
  jmp vi_change_word_space_run

vi_change_word_single_newline:
  inx

vi_change_word_store_end:
  stx %COMMAND_LENGTH_ADDRESS%
  lda #$00
  jsr vi_copy_range_to_yank_buffer
  lda %WRITE_SEPARATOR_INDEX_ADDRESS%
  sta %EDITOR_CURSOR_INDEX_ADDRESS%
  jmp vi_delete_range

; "yw" copies the word under the cursor using the same range rules as "dw".
vi_yank_word:
  lda %EDITOR_CURSOR_INDEX_ADDRESS%
  sta %WRITE_SEPARATOR_INDEX_ADDRESS%
  cmp %LOAD_LENGTH_LOW_ADDRESS%
  bcc vi_yank_word_begin
  rts

vi_yank_word_begin:
  tax
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp #$0A
  beq vi_yank_word_single_newline
  cmp #' '
  beq vi_yank_word_space_run

vi_yank_word_text_run:
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  beq vi_yank_word_store_end
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp #$0A
  beq vi_yank_word_store_end
  cmp #' '
  beq vi_yank_word_trailing_spaces
  inx
  jmp vi_yank_word_text_run

vi_yank_word_trailing_spaces:
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  beq vi_yank_word_store_end
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp #' '
  bne vi_yank_word_store_end
  inx
  jmp vi_yank_word_trailing_spaces

vi_yank_word_space_run:
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  beq vi_yank_word_store_end
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp #' '
  bne vi_yank_word_store_end
  inx
  jmp vi_yank_word_space_run

vi_yank_word_single_newline:
  inx

vi_yank_word_store_end:
  stx %COMMAND_LENGTH_ADDRESS%
  lda #$00
  jmp vi_copy_range_to_yank_buffer

; "yy" copies the current logical line into the vi yank buffer. The linewise
; flag tells "p" to paste the copy below the current line.
vi_yank_current_line:
  jsr vi_find_current_line_range
  lda #$80
  jmp vi_copy_range_to_yank_buffer

; "p" re-inserts the yanked text. Characterwise yanks paste after the cursor,
; while linewise yanks land below the current line.
vi_put_after_cursor:
  lda %LOAD_LENGTH_HIGH_ADDRESS%
  and #$7F
  beq vi_put_after_cursor_done
  sta %WRITE_DATA_LENGTH_ADDRESS%
  lda %LOAD_LENGTH_HIGH_ADDRESS%
  bmi vi_put_after_cursor_linewise
  lda %EDITOR_CURSOR_INDEX_ADDRESS%
  cmp %LOAD_LENGTH_LOW_ADDRESS%
  bcs vi_put_after_cursor_insert
  inc %EDITOR_CURSOR_INDEX_ADDRESS%
  jmp vi_put_after_cursor_insert

vi_put_after_cursor_linewise:
  jsr vi_move_line_end_insert_point
  lda %EDITOR_CURSOR_INDEX_ADDRESS%
  cmp %LOAD_LENGTH_LOW_ADDRESS%
  bne vi_put_after_cursor_after_newline
  lda %LOAD_LENGTH_LOW_ADDRESS%
  beq vi_put_after_cursor_insert
  lda #$0A
  jsr vi_insert_byte_at_cursor
  jmp vi_put_after_cursor_insert

vi_put_after_cursor_after_newline:
  inc %EDITOR_CURSOR_INDEX_ADDRESS%

vi_put_after_cursor_insert:
  ldy #$00

vi_put_after_cursor_loop:
  cpy %WRITE_DATA_LENGTH_ADDRESS%
  beq vi_put_after_cursor_done
  lda %EDITOR_YANK_BUFFER_ADDRESS%, y
  jsr vi_insert_byte_at_cursor
  iny
  jmp vi_put_after_cursor_loop

vi_put_after_cursor_done:
  rts

; "P" re-inserts the yanked text before the cursor, or above the current line
; when the yank was linewise.
vi_put_before_cursor:
  lda %LOAD_LENGTH_HIGH_ADDRESS%
  and #$7F
  beq vi_put_before_cursor_done
  sta %WRITE_DATA_LENGTH_ADDRESS%
  lda %LOAD_LENGTH_HIGH_ADDRESS%
  bmi vi_put_before_cursor_linewise
  jmp vi_put_before_cursor_insert

vi_put_before_cursor_linewise:
  jsr vi_move_line_start

vi_put_before_cursor_insert:
  ldy #$00

vi_put_before_cursor_loop:
  cpy %WRITE_DATA_LENGTH_ADDRESS%
  beq vi_put_before_cursor_done
  lda %EDITOR_YANK_BUFFER_ADDRESS%, y
  jsr vi_insert_byte_at_cursor
  iny
  jmp vi_put_before_cursor_loop

vi_put_before_cursor_done:
  rts

; Replace the byte under the cursor with the current printable key without
; shifting the rest of the buffer around.
vi_replace_current_char_key:
  sta %WRITE_SEPARATOR_INDEX_ADDRESS%
  lda #$00
  sta %EDITOR_PENDING_KEY_ADDRESS%
  ldx %EDITOR_CURSOR_INDEX_ADDRESS%
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  bcc vi_replace_current_char_apply
  rts

vi_replace_current_char_apply:
  lda %WRITE_SEPARATOR_INDEX_ADDRESS%
  sta %LOAD_BUFFER_ADDRESS%, x
  lda #$01
  sta %EDITOR_DIRTY_ADDRESS%
  lda #$00
  sta %LOAD_RUNNABLE_ADDRESS%
  rts

; Join the current logical line with the next one, collapsing the newline and
; any leading whitespace on the following line into a single space when needed.
vi_join_line:
  jsr vi_move_line_end_insert_point
  ldx %EDITOR_CURSOR_INDEX_ADDRESS%
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  bcc vi_join_line_check_newline
  rts

vi_join_line_check_newline:
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp #$0A
  beq vi_join_line_remove_break
  rts

vi_join_line_remove_break:
  jsr vi_delete_at_cursor

vi_join_line_trim_leading:
  ldx %EDITOR_CURSOR_INDEX_ADDRESS%
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  bcc vi_join_line_trim_check
  rts

vi_join_line_trim_check:
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp #' '
  beq vi_join_line_trim_apply
  cmp #$0A
  beq vi_join_line_trim_apply
  jmp vi_join_line_insert_gap

vi_join_line_trim_apply:
  jsr vi_delete_at_cursor
  jmp vi_join_line_trim_leading

vi_join_line_insert_gap:
  lda %EDITOR_CURSOR_INDEX_ADDRESS%
  beq vi_join_line_done
  ldx %EDITOR_CURSOR_INDEX_ADDRESS%
  lda %LOAD_BUFFER_ADDRESS% - 1, x
  cmp #' '
  beq vi_join_line_done
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  bcs vi_join_line_insert_space
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp #' '
  beq vi_join_line_done

vi_join_line_insert_space:
  lda #' '
  jsr vi_insert_byte_at_cursor
  dec %EDITOR_CURSOR_INDEX_ADDRESS%

vi_join_line_done:
  rts

; Copy the current word into the persistent vi search buffer so *, #, n, and N
; can all share the same last-search state.
vi_store_current_word_as_search:
  lda #$00
  sta %EDITOR_SEARCH_LENGTH_ADDRESS%
  ldx %EDITOR_CURSOR_INDEX_ADDRESS%
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  bcc vi_store_current_word_skip_space
  rts

vi_store_current_word_skip_space:
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp #' '
  beq vi_store_current_word_skip_space_advance
  cmp #$0A
  beq vi_store_current_word_skip_space_advance
  jmp vi_store_current_word_find_start

vi_store_current_word_skip_space_advance:
  inx
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  bcc vi_store_current_word_skip_space
  rts

vi_store_current_word_find_start:
  cpx #$00
  beq vi_store_current_word_store_start
  lda %LOAD_BUFFER_ADDRESS% - 1, x
  cmp #' '
  beq vi_store_current_word_store_start
  cmp #$0A
  beq vi_store_current_word_store_start
  dex
  jmp vi_store_current_word_find_start

vi_store_current_word_store_start:
  stx %WRITE_SEPARATOR_INDEX_ADDRESS%

vi_store_current_word_find_end:
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  beq vi_store_current_word_store_end
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp #' '
  beq vi_store_current_word_store_end
  cmp #$0A
  beq vi_store_current_word_store_end
  inx
  jmp vi_store_current_word_find_end

vi_store_current_word_store_end:
  stx %COMMAND_LENGTH_ADDRESS%
  lda %COMMAND_LENGTH_ADDRESS%
  sec
  sbc %WRITE_SEPARATOR_INDEX_ADDRESS%
  beq vi_store_current_word_done
  cmp #%EDITOR_SEARCH_BUFFER_SIZE%
  bcc vi_store_current_word_length_ready
  lda #%EDITOR_SEARCH_BUFFER_SIZE%

vi_store_current_word_length_ready:
  sta %EDITOR_SEARCH_LENGTH_ADDRESS%
  ldx %WRITE_SEPARATOR_INDEX_ADDRESS%
  ldy #$00

vi_store_current_word_copy_loop:
  cpy %EDITOR_SEARCH_LENGTH_ADDRESS%
  beq vi_store_current_word_done
  lda %LOAD_BUFFER_ADDRESS%, x
  sta %EDITOR_SEARCH_BUFFER_ADDRESS%, y
  inx
  iny
  jmp vi_store_current_word_copy_loop

vi_store_current_word_done:
  rts

; Jump between matching (), [], or {} characters under the cursor, keeping
; nested pairs balanced so repeated "%" works sensibly on structured text.
vi_jump_match:
  ldx %EDITOR_CURSOR_INDEX_ADDRESS%
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  bcc vi_jump_match_read
  rts

vi_jump_match_read:
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp #'('
  beq vi_jump_match_open_paren
  cmp #')'
  beq vi_jump_match_close_paren
  cmp #'['
  beq vi_jump_match_open_bracket
  cmp #']'
  beq vi_jump_match_close_bracket
  cmp #'{'
  beq vi_jump_match_open_brace
  cmp #'}'
  beq vi_jump_match_close_brace
  rts

vi_jump_match_open_paren:
  lda #'('
  sta %WRITE_SEPARATOR_INDEX_ADDRESS%
  lda #')'
  sta %WRITE_DATA_LENGTH_ADDRESS%
  jmp vi_jump_match_forward_setup

vi_jump_match_close_paren:
  lda #'('
  sta %WRITE_SEPARATOR_INDEX_ADDRESS%
  lda #')'
  sta %WRITE_DATA_LENGTH_ADDRESS%
  jmp vi_jump_match_backward_setup

vi_jump_match_open_bracket:
  lda #'['
  sta %WRITE_SEPARATOR_INDEX_ADDRESS%
  lda #']'
  sta %WRITE_DATA_LENGTH_ADDRESS%
  jmp vi_jump_match_forward_setup

vi_jump_match_close_bracket:
  lda #'['
  sta %WRITE_SEPARATOR_INDEX_ADDRESS%
  lda #']'
  sta %WRITE_DATA_LENGTH_ADDRESS%
  jmp vi_jump_match_backward_setup

vi_jump_match_open_brace:
  lda #'{'
  sta %WRITE_SEPARATOR_INDEX_ADDRESS%
  lda #'}'
  sta %WRITE_DATA_LENGTH_ADDRESS%
  jmp vi_jump_match_forward_setup

vi_jump_match_close_brace:
  lda #'{'
  sta %WRITE_SEPARATOR_INDEX_ADDRESS%
  lda #'}'
  sta %WRITE_DATA_LENGTH_ADDRESS%
  jmp vi_jump_match_backward_setup

vi_jump_match_forward_setup:
  lda #$01
  sta %COMMAND_LENGTH_ADDRESS%
  inx

vi_jump_match_forward_loop:
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  bcc vi_jump_match_forward_check
  rts

vi_jump_match_forward_check:
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp %WRITE_SEPARATOR_INDEX_ADDRESS%
  beq vi_jump_match_forward_open
  cmp %WRITE_DATA_LENGTH_ADDRESS%
  beq vi_jump_match_forward_close
  inx
  jmp vi_jump_match_forward_loop

vi_jump_match_forward_open:
  inc %COMMAND_LENGTH_ADDRESS%
  inx
  jmp vi_jump_match_forward_loop

vi_jump_match_forward_close:
  dec %COMMAND_LENGTH_ADDRESS%
  lda %COMMAND_LENGTH_ADDRESS%
  beq vi_jump_match_store
  inx
  jmp vi_jump_match_forward_loop

vi_jump_match_backward_setup:
  lda #$01
  sta %COMMAND_LENGTH_ADDRESS%
  txa
  beq vi_jump_match_no_backward
  dex

vi_jump_match_backward_loop:
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp %WRITE_DATA_LENGTH_ADDRESS%
  beq vi_jump_match_backward_close
  cmp %WRITE_SEPARATOR_INDEX_ADDRESS%
  beq vi_jump_match_backward_open
  txa
  beq vi_jump_match_no_backward
  dex
  jmp vi_jump_match_backward_loop

vi_jump_match_backward_close:
  inc %COMMAND_LENGTH_ADDRESS%
  txa
  beq vi_jump_match_no_backward
  dex
  jmp vi_jump_match_backward_loop

vi_jump_match_backward_open:
  dec %COMMAND_LENGTH_ADDRESS%
  lda %COMMAND_LENGTH_ADDRESS%
  beq vi_jump_match_store
  txa
  beq vi_jump_match_no_backward
  dex
  jmp vi_jump_match_backward_loop

vi_jump_match_no_backward:
  rts

vi_jump_match_store:
  stx %EDITOR_CURSOR_INDEX_ADDRESS%
  rts

; Compare the last confirmed search term against the buffer at X. Carry set on
; success, clear on mismatch.
vi_compare_search_at_x:
  txa
  clc
  adc %EDITOR_SEARCH_LENGTH_ADDRESS%
  cmp %LOAD_LENGTH_LOW_ADDRESS%
  bcc vi_compare_search_pointer
  beq vi_compare_search_pointer
  clc
  rts

vi_compare_search_pointer:
  txa
  clc
  adc #<%LOAD_BUFFER_ADDRESS%
  sta %PRINT_POINTER_LOW_ADDRESS%
  lda #>%LOAD_BUFFER_ADDRESS%
  adc #$00
  sta %PRINT_POINTER_HIGH_ADDRESS%
  ldy #$00

vi_compare_search_loop:
  cpy %EDITOR_SEARCH_LENGTH_ADDRESS%
  beq vi_compare_search_match
  lda (%PRINT_POINTER_LOW_ADDRESS%), y
  cmp %EDITOR_SEARCH_BUFFER_ADDRESS%, y
  bne vi_compare_search_miss
  iny
  jmp vi_compare_search_loop

vi_compare_search_match:
  sec
  rts

vi_compare_search_miss:
  clc
  rts

; Search forward from the byte after the current cursor, wrapping once through
; the file so repeated "n" hops through every later match.
vi_find_next_search_match:
  lda %EDITOR_SEARCH_LENGTH_ADDRESS%
  beq vi_find_next_search_done
  lda %LOAD_LENGTH_LOW_ADDRESS%
  beq vi_find_next_search_done
  lda %EDITOR_CURSOR_INDEX_ADDRESS%
  cmp %LOAD_LENGTH_LOW_ADDRESS%
  bcc vi_find_next_search_start_after_cursor
  ldx #$00
  jmp vi_find_next_search_ready

vi_find_next_search_start_after_cursor:
  ldx %EDITOR_CURSOR_INDEX_ADDRESS%
  inx
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  bcc vi_find_next_search_ready
  ldx #$00

vi_find_next_search_ready:
  lda #$00
  sta %COMMAND_LENGTH_ADDRESS%

vi_find_next_search_loop:
  lda %COMMAND_LENGTH_ADDRESS%
  cmp %LOAD_LENGTH_LOW_ADDRESS%
  beq vi_find_next_search_done
  jsr vi_compare_search_at_x
  bcs vi_find_next_search_match_found
  inx
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  bcc vi_find_next_search_advance_count
  ldx #$00

vi_find_next_search_advance_count:
  inc %COMMAND_LENGTH_ADDRESS%
  jmp vi_find_next_search_loop

vi_find_next_search_match_found:
  stx %EDITOR_CURSOR_INDEX_ADDRESS%

vi_find_next_search_done:
  rts

; Search backward from the byte before the current cursor, wrapping once toward
; the end of the file so repeated reverse searches can cycle through matches.
vi_find_previous_search_match:
  lda %EDITOR_SEARCH_LENGTH_ADDRESS%
  beq vi_find_previous_search_done
  lda %LOAD_LENGTH_LOW_ADDRESS%
  beq vi_find_previous_search_done
  lda %EDITOR_CURSOR_INDEX_ADDRESS%
  beq vi_find_previous_search_start_from_end
  ldx %EDITOR_CURSOR_INDEX_ADDRESS%
  dex
  jmp vi_find_previous_search_ready

vi_find_previous_search_start_from_end:
  ldx %LOAD_LENGTH_LOW_ADDRESS%
  beq vi_find_previous_search_done
  dex

vi_find_previous_search_ready:
  lda #$00
  sta %COMMAND_LENGTH_ADDRESS%

vi_find_previous_search_loop:
  lda %COMMAND_LENGTH_ADDRESS%
  cmp %LOAD_LENGTH_LOW_ADDRESS%
  beq vi_find_previous_search_done
  jsr vi_compare_search_at_x
  bcs vi_find_previous_search_match_found
  cpx #$00
  beq vi_find_previous_search_wrap
  dex
  jmp vi_find_previous_search_advance_count

vi_find_previous_search_wrap:
  ldx %LOAD_LENGTH_LOW_ADDRESS%
  dex

vi_find_previous_search_advance_count:
  inc %COMMAND_LENGTH_ADDRESS%
  jmp vi_find_previous_search_loop

vi_find_previous_search_match_found:
  stx %EDITOR_CURSOR_INDEX_ADDRESS%

vi_find_previous_search_done:
  rts

vi_compute_cursor_position:
  lda #$00
  sta %WRITE_SEPARATOR_INDEX_ADDRESS%
  sta %WRITE_DATA_LENGTH_ADDRESS%
  ldx #$00

vi_compute_cursor_position_loop:
  cpx %EDITOR_CURSOR_INDEX_ADDRESS%
  beq vi_compute_cursor_position_done
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp #$0A
  beq vi_compute_cursor_position_newline
  inc %WRITE_DATA_LENGTH_ADDRESS%
  lda %WRITE_DATA_LENGTH_ADDRESS%
  cmp #%TERMINAL_COLUMNS%
  bne vi_compute_cursor_position_next
  lda #$00
  sta %WRITE_DATA_LENGTH_ADDRESS%
  inc %WRITE_SEPARATOR_INDEX_ADDRESS%
  jmp vi_compute_cursor_position_next

vi_compute_cursor_position_newline:
  lda #$00
  sta %WRITE_DATA_LENGTH_ADDRESS%
  inc %WRITE_SEPARATOR_INDEX_ADDRESS%

vi_compute_cursor_position_next:
  inx
  jmp vi_compute_cursor_position_loop

vi_compute_cursor_position_done:
  rts

vi_move_up:
  jsr vi_compute_cursor_position
  lda %WRITE_SEPARATOR_INDEX_ADDRESS%
  bne vi_move_up_apply
  clc
  rts

vi_move_up_apply:
  sec
  sbc #$01
  sta %COMMAND_LENGTH_ADDRESS%
  lda %WRITE_DATA_LENGTH_ADDRESS%
  sta %EDITOR_TARGET_COLUMN_ADDRESS%
  jsr vi_find_cursor_for_target_position
  clc
  rts

vi_move_down:
  jsr vi_compute_cursor_position
  lda %WRITE_SEPARATOR_INDEX_ADDRESS%
  clc
  adc #$01
  sta %COMMAND_LENGTH_ADDRESS%
  lda %WRITE_DATA_LENGTH_ADDRESS%
  sta %EDITOR_TARGET_COLUMN_ADDRESS%
  jsr vi_find_cursor_for_target_position
  clc
  rts

vi_find_cursor_for_target_position:
  lda #$FF
  sta %EDITOR_COMMAND_LENGTH_ADDRESS%
  lda #$00
  sta %WRITE_SEPARATOR_INDEX_ADDRESS%
  sta %WRITE_DATA_LENGTH_ADDRESS%
  ldx #$00

vi_find_cursor_loop:
  lda %WRITE_SEPARATOR_INDEX_ADDRESS%
  cmp %COMMAND_LENGTH_ADDRESS%
  bcc vi_find_cursor_check_end
  bne vi_find_cursor_done
  stx %EDITOR_COMMAND_LENGTH_ADDRESS%
  lda %WRITE_DATA_LENGTH_ADDRESS%
  cmp %EDITOR_TARGET_COLUMN_ADDRESS%
  beq vi_find_cursor_exact

vi_find_cursor_check_end:
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  beq vi_find_cursor_done
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp #$0A
  beq vi_find_cursor_newline
  inc %WRITE_DATA_LENGTH_ADDRESS%
  lda %WRITE_DATA_LENGTH_ADDRESS%
  cmp #%TERMINAL_COLUMNS%
  bne vi_find_cursor_advance
  lda #$00
  sta %WRITE_DATA_LENGTH_ADDRESS%
  inc %WRITE_SEPARATOR_INDEX_ADDRESS%
  jmp vi_find_cursor_advance

vi_find_cursor_newline:
  lda #$00
  sta %WRITE_DATA_LENGTH_ADDRESS%
  inc %WRITE_SEPARATOR_INDEX_ADDRESS%

vi_find_cursor_advance:
  inx
  jmp vi_find_cursor_loop

vi_find_cursor_exact:
  stx %EDITOR_CURSOR_INDEX_ADDRESS%
  rts

vi_find_cursor_done:
  lda %EDITOR_COMMAND_LENGTH_ADDRESS%
  cmp #$FF
  beq vi_find_cursor_done_noop
  sta %EDITOR_CURSOR_INDEX_ADDRESS%

vi_find_cursor_done_noop:
  rts

; Parse "load <file>", read it through the filesystem device, and copy the
; returned bytes into the shared RAM load buffer. The boot shell treats loaded
; files as runnable payloads by default.
load_file_to_ram:
  lda #%LOAD_ARGUMENT_OFFSET%
  sta %WRITE_SEPARATOR_INDEX_ADDRESS%
  jsr load_file_to_ram_from_offset
  lda %FS_STATUS_ADDRESS%
  and #$08
  beq load_file_done
  jsr print_load_ok
  jmp print_load_truncated

load_file_done:
  jmp print_load_ok

load_file_to_ram_from_offset:
  lda #$00
  sta %LOAD_PRESENT_ADDRESS%
  sta %LOAD_LENGTH_LOW_ADDRESS%
  sta %LOAD_LENGTH_HIGH_ADDRESS%
  sta %LOAD_RUNNABLE_ADDRESS%
  lda %COMMAND_LENGTH_ADDRESS%
  sec
  sbc %WRITE_SEPARATOR_INDEX_ADDRESS%
  beq load_file_usage
  sta %FS_PATH_LENGTH_ADDRESS%
  tax
  dex
  bmi load_file_issue_read

load_file_copy_path_loop:
  txa
  clc
  adc %WRITE_SEPARATOR_INDEX_ADDRESS%
  tay
  lda %COMMAND_BUFFER_ADDRESS%, y
  sta %FS_PATH_BUFFER_ADDRESS%, x
  dex
  bpl load_file_copy_path_loop

load_file_issue_read:
  lda #%FS_COMMAND_READ%
  sta %FS_COMMAND_ADDRESS%
  lda %FS_STATUS_ADDRESS%
  and #$02
  beq load_file_copy_result
  lda %FS_ERROR_CODE_ADDRESS%
  cmp #%FS_ERROR_NOT_FOUND%
  beq load_file_missing
  jmp print_filesystem_error

load_file_missing:
  jmp print_missing_file

load_file_copy_result:
  ldx #$00
load_file_copy_result_loop:
  cpx %FS_RESULT_LENGTH_LOW_ADDRESS%
  beq load_file_finish
  lda %FS_DATA_BUFFER_ADDRESS%, x
  sta %LOAD_BUFFER_ADDRESS%, x
  inx
  jmp load_file_copy_result_loop

load_file_finish:
  lda #$01
  sta %LOAD_PRESENT_ADDRESS%
  sta %LOAD_RUNNABLE_ADDRESS%
  lda %FS_RESULT_LENGTH_LOW_ADDRESS%
  sta %LOAD_LENGTH_LOW_ADDRESS%
  lda #$00
  sta %LOAD_LENGTH_HIGH_ADDRESS%
  rts

load_file_usage:
  jmp print_load_usage

; Reset the shared buffer state so text editing and saving can start from a
; truly empty buffer instead of reusing prior contents.
clear_buffer_state:
  lda #$00
  sta %LOAD_PRESENT_ADDRESS%
  sta %LOAD_LENGTH_LOW_ADDRESS%
  sta %LOAD_LENGTH_HIGH_ADDRESS%
  sta %LOAD_RUNNABLE_ADDRESS%
  rts

new_buffer:
  jsr clear_buffer_state
  jmp print_new_ok

; Remove the last text line from the shared buffer. This gives the tiny editor
; one reversible operation without introducing a full cursor-addressable screen
; editor yet.
pop_buffer_line:
  lda %LOAD_PRESENT_ADDRESS%
  bne pop_buffer_check_length
  jmp print_show_empty

pop_buffer_check_length:
  ldx %LOAD_LENGTH_LOW_ADDRESS%
  beq pop_buffer_empty
  dex
  lda #$00
  sta %LOAD_RUNNABLE_ADDRESS%

pop_buffer_scan_loop:
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp #$0A
  beq pop_buffer_found_newline
  txa
  beq pop_buffer_clear
  dex
  jmp pop_buffer_scan_loop

pop_buffer_found_newline:
  stx %LOAD_LENGTH_LOW_ADDRESS%
  lda #$00
  sta %LOAD_LENGTH_HIGH_ADDRESS%
  lda #$01
  sta %LOAD_PRESENT_ADDRESS%
  jmp print_pop_ok

pop_buffer_clear:
  jsr clear_buffer_state
  jmp print_pop_ok

pop_buffer_empty:
  jmp print_show_empty

; Call the loaded payload as a subroutine so small machine-code programs can
; return control to the shell with RTS.
run_loaded_program:
  lda %COMMAND_LENGTH_ADDRESS%
  cmp #%RUN_LENGTH%
  beq run_loaded_program_check_present
  lda #%RUN_ARGUMENT_OFFSET%
  sta %WRITE_SEPARATOR_INDEX_ADDRESS%
  jsr load_file_to_ram_from_offset
  lda %FS_STATUS_ADDRESS%
  and #$08
  beq run_loaded_program_check_present
  jsr print_load_truncated

run_loaded_program_check_present:
  lda %LOAD_PRESENT_ADDRESS%
  bne run_loaded_program_check_type
  jmp print_run_missing

run_loaded_program_check_type:
  lda %LOAD_RUNNABLE_ADDRESS%
  bne run_loaded_program_call
  jmp print_run_text

run_loaded_program_call:
  jsr %LOAD_BUFFER_ADDRESS%
  rts

; Write the current shared buffer back to the guest filesystem under a new path.
save_file_from_ram:
  lda %LOAD_PRESENT_ADDRESS%
  bne save_file_check_path
  jmp print_run_missing

save_file_check_path:
  lda %COMMAND_LENGTH_ADDRESS%
  sec
  sbc #%SAVE_ARGUMENT_OFFSET%
  beq save_file_usage
  sta %FS_PATH_LENGTH_ADDRESS%
  tax
  dex
  bmi save_file_prepare_data

save_file_copy_path_loop:
  lda %COMMAND_BUFFER_ADDRESS% + %SAVE_ARGUMENT_OFFSET%, x
  sta %FS_PATH_BUFFER_ADDRESS%, x
  dex
  bpl save_file_copy_path_loop

save_file_prepare_data:
  lda %LOAD_LENGTH_LOW_ADDRESS%
  sta %FS_DATA_LENGTH_LOW_ADDRESS%
  lda %LOAD_LENGTH_HIGH_ADDRESS%
  sta %FS_DATA_LENGTH_HIGH_ADDRESS%
  ldx #$00

save_file_copy_data_loop:
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  beq save_file_issue_write
  lda %LOAD_BUFFER_ADDRESS%, x
  sta %FS_DATA_BUFFER_ADDRESS%, x
  inx
  jmp save_file_copy_data_loop

save_file_issue_write:
  lda #%FS_COMMAND_WRITE%
  sta %FS_COMMAND_ADDRESS%
  lda %FS_STATUS_ADDRESS%
  and #$02
  beq save_file_done
  jmp print_filesystem_error

save_file_done:
  jmp print_save_ok

save_file_usage:
  jmp print_save_usage

; Parse "edit <text>" and replace the current shared buffer with the supplied
; line. This is the first half of the line-oriented in-guest editor.
edit_buffer_from_command:
  lda #$00
  sta %LOAD_RUNNABLE_ADDRESS%
  lda %COMMAND_LENGTH_ADDRESS%
  sec
  sbc #%EDIT_ARGUMENT_OFFSET%
  beq edit_buffer_usage
  sta %LOAD_LENGTH_LOW_ADDRESS%
  tax
  lda #$00
  sta %LOAD_LENGTH_HIGH_ADDRESS%
  lda #$01
  sta %LOAD_PRESENT_ADDRESS%
  dex
  bmi edit_buffer_done

edit_buffer_copy_loop:
  lda %COMMAND_BUFFER_ADDRESS% + %EDIT_ARGUMENT_OFFSET%, x
  sta %LOAD_BUFFER_ADDRESS%, x
  dex
  bpl edit_buffer_copy_loop

edit_buffer_done:
  jmp print_edit_ok

edit_buffer_usage:
  jmp print_edit_usage

; Print the current shared buffer as text, expanding LF into terminal newlines.
; This gives the line editor a simple "show me the buffer" command.
show_buffer_contents:
  lda %LOAD_PRESENT_ADDRESS%
  bne show_buffer_loop_start
  jmp print_show_empty

show_buffer_loop_start:
  ldx #$00
show_buffer_loop:
  cpx %LOAD_LENGTH_LOW_ADDRESS%
  beq show_buffer_done
  lda %LOAD_BUFFER_ADDRESS%, x
  cmp #$0A
  beq show_buffer_newline
  jsr write_terminal_byte
  inx
  jmp show_buffer_loop

show_buffer_newline:
  lda #$0D
  jsr write_terminal_byte
  lda #$0A
  jsr write_terminal_byte
  inx
  jmp show_buffer_loop

show_buffer_done:
  lda #$0D
  jsr write_terminal_byte
  lda #$0A
  jsr write_terminal_byte
  rts

; Append a line of text to the current shared buffer, inserting a LF when the
; buffer already contains content. The append path reuses zero-page scratch
; slots that are otherwise used by the write command.
append_buffer_from_command:
  lda #$00
  sta %LOAD_RUNNABLE_ADDRESS%
  lda %COMMAND_LENGTH_ADDRESS%
  sec
  sbc #%APPEND_ARGUMENT_OFFSET%
  beq append_buffer_usage
  sta %WRITE_DATA_LENGTH_ADDRESS%
  lda %LOAD_PRESENT_ADDRESS%
  beq append_buffer_start_fresh
  lda %LOAD_LENGTH_LOW_ADDRESS%
  beq append_buffer_start_fresh
  sta %WRITE_SEPARATOR_INDEX_ADDRESS%
  clc
  adc #$01
  clc
  adc %WRITE_DATA_LENGTH_ADDRESS%
  cmp #$80
  bcc append_buffer_existing_ok
  beq append_buffer_existing_ok
  jmp print_buffer_full

append_buffer_existing_ok:
  ldx %WRITE_SEPARATOR_INDEX_ADDRESS%
  ; Keep text files newline-separated internally with plain LF.
  lda #$0A
  sta %LOAD_BUFFER_ADDRESS%, x
  inx
  stx %WRITE_SEPARATOR_INDEX_ADDRESS%
  jmp append_buffer_copy_start

append_buffer_start_fresh:
  lda %WRITE_DATA_LENGTH_ADDRESS%
  cmp #$80
  bcc append_buffer_fresh_ok
  beq append_buffer_fresh_ok
  jmp print_buffer_full

append_buffer_fresh_ok:
  lda #$00
  sta %WRITE_SEPARATOR_INDEX_ADDRESS%

append_buffer_copy_start:
  ldx %WRITE_SEPARATOR_INDEX_ADDRESS%
  ldy #$00
append_buffer_copy_loop:
  cpy %WRITE_DATA_LENGTH_ADDRESS%
  beq append_buffer_done
  lda %COMMAND_BUFFER_ADDRESS% + %APPEND_ARGUMENT_OFFSET%, y
  sta %LOAD_BUFFER_ADDRESS%, x
  iny
  inx
  jmp append_buffer_copy_loop

append_buffer_done:
  stx %LOAD_LENGTH_LOW_ADDRESS%
  lda #$00
  sta %LOAD_LENGTH_HIGH_ADDRESS%
  lda #$01
  sta %LOAD_PRESENT_ADDRESS%
  jmp print_append_ok

append_buffer_usage:
  jmp print_append_usage

; Parse "write <file> <text>" by finding the separator between the filename
; and payload, then copy each part into the filesystem device buffers. Unlike
; save, this command writes directly from the command line instead of the
; shared load/edit buffer.
write_file_contents:
  ldx #%WRITE_ARGUMENT_OFFSET%
  cpx %COMMAND_LENGTH_ADDRESS%
  bcs write_file_usage

write_file_find_separator:
  cpx %COMMAND_LENGTH_ADDRESS%
  bcs write_file_usage
  lda %COMMAND_BUFFER_ADDRESS%, x
  cmp #' '
  beq write_file_separator_found
  inx
  jmp write_file_find_separator

write_file_separator_found:
  stx %WRITE_SEPARATOR_INDEX_ADDRESS%
  txa
  sec
  sbc #$06
  beq write_file_usage
  sta %FS_PATH_LENGTH_ADDRESS%
  tax
  dex
  bmi write_file_prepare_data

write_file_copy_path_loop:
  lda %COMMAND_BUFFER_ADDRESS% + %WRITE_ARGUMENT_OFFSET%, x
  sta %FS_PATH_BUFFER_ADDRESS%, x
  dex
  bpl write_file_copy_path_loop

write_file_prepare_data:
  lda %COMMAND_LENGTH_ADDRESS%
  sec
  sbc %WRITE_SEPARATOR_INDEX_ADDRESS%
  sec
  sbc #$01
  sta %WRITE_DATA_LENGTH_ADDRESS%
  lda %WRITE_DATA_LENGTH_ADDRESS%
  sta %FS_DATA_LENGTH_LOW_ADDRESS%
  lda #$00
  sta %FS_DATA_LENGTH_HIGH_ADDRESS%
  ldy #$00
  ldx %WRITE_SEPARATOR_INDEX_ADDRESS%
  inx

write_file_copy_data_loop:
  cpy %WRITE_DATA_LENGTH_ADDRESS%
  beq write_file_issue_write
  lda %COMMAND_BUFFER_ADDRESS%, x
  sta %FS_DATA_BUFFER_ADDRESS%, y
  iny
  inx
  jmp write_file_copy_data_loop

write_file_issue_write:
  lda #%FS_COMMAND_WRITE%
  sta %FS_COMMAND_ADDRESS%
  lda %FS_STATUS_ADDRESS%
  and #$02
  beq write_file_done
  jmp print_filesystem_error

write_file_done:
  jmp print_write_ok

write_file_usage:
  jmp print_write_usage

; Parse "rm <file>" and hand the path to the filesystem delete command.
remove_file:
  lda %COMMAND_LENGTH_ADDRESS%
  sec
  sbc #%RM_ARGUMENT_OFFSET%
  beq remove_file_usage
  sta %FS_PATH_LENGTH_ADDRESS%
  tax
  dex
  bmi remove_file_issue_delete

remove_file_copy_path_loop:
  lda %COMMAND_BUFFER_ADDRESS% + %RM_ARGUMENT_OFFSET%, x
  sta %FS_PATH_BUFFER_ADDRESS%, x
  dex
  bpl remove_file_copy_path_loop

remove_file_issue_delete:
  lda #%FS_COMMAND_DELETE%
  sta %FS_COMMAND_ADDRESS%
  lda %FS_STATUS_ADDRESS%
  and #$02
  beq remove_file_done
  lda %FS_ERROR_CODE_ADDRESS%
  cmp #%FS_ERROR_NOT_FOUND%
  beq remove_file_missing
  jmp print_filesystem_error

remove_file_missing:
  jmp print_missing_file

remove_file_done:
  jmp print_rm_ok

remove_file_usage:
  jmp print_rm_usage

; ROM strings.
banner:
  .byte %BANNER_BYTES%, $00

directory_header:
  .byte %DIRECTORY_HEADER_BYTES%, $00

prompt:
  .byte %PROMPT_BYTES%, $00

help_text:
  .byte %HELP_BYTES%, $00

unknown_text:
  .byte %UNKNOWN_BYTES%, $00

filesystem_error_text:
  .byte %FS_ERROR_BYTES%, $00

missing_file_text:
  .byte %MISSING_FILE_BYTES%, $00

missing_path_text:
  .byte %MISSING_PATH_BYTES%, $00

not_directory_text:
  .byte %NOT_DIRECTORY_BYTES%, $00

cd_usage_text:
  .byte %CD_USAGE_BYTES%, $00

cd_ok_text:
  .byte %CD_OK_BYTES%, $00

vi_usage_text:
  .byte %VI_USAGE_BYTES%, $00

asm_usage_text:
  .byte %ASM_USAGE_BYTES%, $00

asm_ok_prefix_text:
  .byte %ASM_OK_PREFIX_BYTES%, $00

assembly_failed_text:
  .byte %ASSEMBLY_FAILED_BYTES%, $00

cp_usage_text:
  .byte %CP_USAGE_BYTES%, $00

cp_ok_text:
  .byte %CP_OK_BYTES%, $00

mkdir_usage_text:
  .byte %MKDIR_USAGE_BYTES%, $00

mkdir_ok_text:
  .byte %MKDIR_OK_BYTES%, $00

mv_usage_text:
  .byte %MV_USAGE_BYTES%, $00

mv_ok_text:
  .byte %MV_OK_BYTES%, $00

touch_usage_text:
  .byte %TOUCH_USAGE_BYTES%, $00

touch_ok_text:
  .byte %TOUCH_OK_BYTES%, $00

load_usage_text:
  .byte %LOAD_USAGE_BYTES%, $00

load_ok_text:
  .byte %LOAD_OK_BYTES%, $00

load_truncated_text:
  .byte %LOAD_TRUNCATED_BYTES%, $00

run_missing_text:
  .byte %RUN_MISSING_BYTES%, $00

run_text_text:
  .byte %RUN_TEXT_BYTES%, $00

save_usage_text:
  .byte %SAVE_USAGE_BYTES%, $00

save_ok_text:
  .byte %SAVE_OK_BYTES%, $00

edit_usage_text:
  .byte %EDIT_USAGE_BYTES%, $00

edit_ok_text:
  .byte %EDIT_OK_BYTES%, $00

new_ok_text:
  .byte %NEW_OK_BYTES%, $00

pop_ok_text:
  .byte %POP_OK_BYTES%, $00

show_empty_text:
  .byte %SHOW_EMPTY_BYTES%, $00

append_usage_text:
  .byte %APPEND_USAGE_BYTES%, $00

append_ok_text:
  .byte %APPEND_OK_BYTES%, $00

buffer_full_text:
  .byte %BUFFER_FULL_BYTES%, $00

write_usage_text:
  .byte %WRITE_USAGE_BYTES%, $00

write_ok_text:
  .byte %WRITE_OK_BYTES%, $00

rm_usage_text:
  .byte %RM_USAGE_BYTES%, $00

rm_ok_text:
  .byte %RM_OK_BYTES%, $00

; Reset vector.
.org $FFFC
  .word reset
