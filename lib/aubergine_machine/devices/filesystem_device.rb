# frozen_string_literal: true

module AubergineMachine
  module Devices
    class FilesystemDevice < MOS6502::Device
      STATUS_REGISTER = 0x00
      COMMAND_REGISTER = 0x01
      PATH_LENGTH_REGISTER = 0x02
      DATA_LENGTH_LOW_REGISTER = 0x03
      DATA_LENGTH_HIGH_REGISTER = 0x04
      RESULT_LENGTH_LOW_REGISTER = 0x05
      RESULT_LENGTH_HIGH_REGISTER = 0x06
      ERROR_CODE_REGISTER = 0x07

      PATH_BUFFER_START = 0x10
      PATH_BUFFER_SIZE = 64
      PATH_BUFFER_END = PATH_BUFFER_START + PATH_BUFFER_SIZE - 1

      DATA_BUFFER_START = 0x50
      DATA_BUFFER_SIZE = 128
      DATA_BUFFER_END = DATA_BUFFER_START + DATA_BUFFER_SIZE - 1

      STATUS_READY = 0x01
      STATUS_ERROR = 0x02
      STATUS_DATA_READY = 0x04
      STATUS_TRUNCATED = 0x08

      COMMAND_NONE = 0x00
      COMMAND_LIST = 0x01
      COMMAND_READ = 0x02
      COMMAND_WRITE = 0x03
      COMMAND_DELETE = 0x04
      COMMAND_MKDIR = 0x05
      COMMAND_CHDIR = 0x06
      COMMAND_PWD = 0x07
      COMMAND_ASSEMBLE = 0x08

      ERROR_NONE = 0x00
      ERROR_BAD_COMMAND = 0x01
      ERROR_FILESYSTEM = 0x02
      ERROR_PATH_TOO_LONG = 0x03
      ERROR_DATA_TOO_LONG = 0x04
      ERROR_NOT_FOUND = 0x05
      ERROR_NOT_DIRECTORY = 0x06
      ERROR_ASSEMBLY_FAILED = 0x07

      SIZE = DATA_BUFFER_END + 1

      attr_reader :filesystem, :assembler, :current_directory

      def initialize(filesystem:, assembler: GuestAssembler.new(filesystem:))
        super()
        @filesystem = filesystem
        @assembler = assembler
        reset
      end

      def size
        SIZE
      end

      def reset
        @path_length = 0
        @data_length = 0
        @result_length = 0
        @error_code = ERROR_NONE
        @status = STATUS_READY
        @current_directory = "/"
        @path_buffer = Array.new(PATH_BUFFER_SIZE, 0x00)
        @data_buffer = Array.new(DATA_BUFFER_SIZE, 0x00)
        self
      end

      def read_byte(address)
        case address
        when STATUS_REGISTER
          @status
        when COMMAND_REGISTER
          COMMAND_NONE
        when PATH_LENGTH_REGISTER
          @path_length
        when DATA_LENGTH_LOW_REGISTER
          @data_length & 0xFF
        when DATA_LENGTH_HIGH_REGISTER
          (@data_length >> 8) & 0xFF
        when RESULT_LENGTH_LOW_REGISTER
          @result_length & 0xFF
        when RESULT_LENGTH_HIGH_REGISTER
          (@result_length >> 8) & 0xFF
        when ERROR_CODE_REGISTER
          @error_code
        when PATH_BUFFER_START..PATH_BUFFER_END
          @path_buffer[address - PATH_BUFFER_START]
        when DATA_BUFFER_START..DATA_BUFFER_END
          @data_buffer[address - DATA_BUFFER_START]
        else
          0x00
        end
      end

      def write_byte(address, value)
        byte = value & 0xFF

        case address
        when COMMAND_REGISTER
          execute_command(byte)
        when PATH_LENGTH_REGISTER
          @path_length = [byte, PATH_BUFFER_SIZE].min
        when DATA_LENGTH_LOW_REGISTER
          @data_length = (@data_length & 0xFF00) | byte
        when DATA_LENGTH_HIGH_REGISTER
          @data_length = ((byte << 8) & 0xFF00) | (@data_length & 0x00FF)
        when PATH_BUFFER_START..PATH_BUFFER_END
          @path_buffer[address - PATH_BUFFER_START] = byte
        when DATA_BUFFER_START..DATA_BUFFER_END
          @data_buffer[address - DATA_BUFFER_START] = byte
        end

        byte
      end

      private

      def execute_command(command)
        clear_result_state

        case command
        when COMMAND_LIST
          store_result(filesystem.list(command_path("."), base: current_directory).join("\n"))
        when COMMAND_READ
          store_result(filesystem.read(command_path, base: current_directory))
        when COMMAND_WRITE
          filesystem.write(command_path, data_text, base: current_directory)
        when COMMAND_DELETE
          filesystem.delete(command_path, base: current_directory)
        when COMMAND_MKDIR
          filesystem.mkdir(command_path, base: current_directory)
        when COMMAND_CHDIR
          @current_directory = filesystem.chdir(command_path("."), base: current_directory)
        when COMMAND_PWD
          store_result(current_directory)
        when COMMAND_ASSEMBLE
          store_result(assembler.assemble(command_path, base: current_directory, output_path: assemble_output_path))
        else
          set_error(ERROR_BAD_COMMAND)
        end
      rescue MissingPathError
        set_error(ERROR_NOT_FOUND)
      rescue NotDirectoryError
        set_error(ERROR_NOT_DIRECTORY)
      rescue AssemblyFailedError
        set_error(ERROR_ASSEMBLY_FAILED)
      rescue FilesystemError
        set_error(ERROR_FILESYSTEM)
      end

      def clear_result_state
        @error_code = ERROR_NONE
        @result_length = 0
        @status = STATUS_READY
      end

      def set_error(code)
        @error_code = code
        @status = STATUS_READY | STATUS_ERROR
      end

      def store_result(text)
        bytes = text.bytes
        truncated = bytes.length > DATA_BUFFER_SIZE
        bytes = bytes.first(DATA_BUFFER_SIZE)
        overwrite_buffer(@data_buffer, bytes)
        @result_length = bytes.length
        @status = STATUS_READY | STATUS_DATA_READY
        @status |= STATUS_TRUNCATED if truncated
      end

      def command_path(default = "")
        bytes = @path_buffer.first(clamped_path_length)
        text = bytes.pack("C*")
        text.empty? ? default : text
      end

      def data_text
        bytes = @data_buffer.first(clamped_data_length)
        bytes.pack("C*")
      end

      def assemble_output_path
        length = clamped_data_length
        return nil if length.zero?

        @data_buffer.first(length).pack("C*")
      end

      def clamped_path_length
        if @path_length > PATH_BUFFER_SIZE
          set_error(ERROR_PATH_TOO_LONG)
          PATH_BUFFER_SIZE
        else
          @path_length
        end
      end

      def clamped_data_length
        if @data_length > DATA_BUFFER_SIZE
          set_error(ERROR_DATA_TOO_LONG)
          DATA_BUFFER_SIZE
        else
          @data_length
        end
      end

      def overwrite_buffer(buffer, bytes)
        buffer.fill(0x00)
        bytes.each_with_index { |byte, index| buffer[index] = byte }
      end
    end
  end
end
