# frozen_string_literal: true

require "fileutils"
require "thread"

module AubergineMachine
  class FilesystemError < StandardError; end
  class MissingPathError < FilesystemError; end
  class NotDirectoryError < FilesystemError; end
  class NotFileError < FilesystemError; end

  class VirtualFilesystem
    ACTIVE_WINDOW = 0.75
    ACTIVITY_FILENAME = ".aubergine-machine-activity".freeze

    attr_reader :root

    def self.default_root
      File.expand_path("../../guest_fs", __dir__)
    end

    def initialize(root: self.class.default_root)
      @root = File.expand_path(root)
      FileUtils.mkdir_p(@root)
      @mutex = Mutex.new
      @activity_cache = nil
      @activity_cache_mtime = nil
    end

    def list(path = ".", base: "/")
      directory = resolve_path(path, base:)
      raise MissingPathError, "Missing path: #{path}" unless File.exist?(directory)
      raise NotDirectoryError, "Not a directory: #{path}" unless File.directory?(directory)

      entries = Dir.children(directory).reject { |entry| entry == ACTIVITY_FILENAME }.sort
      record_activity(:list)
      entries
    end

    def read(path, base: "/")
      file = resolve_path(path, base:)
      raise MissingPathError, "Missing path: #{path}" unless File.exist?(file)
      raise NotFileError, "Not a file: #{path}" unless File.file?(file)

      File.binread(file).tap { record_activity(:read) }
    end

    def write(path, content, base: "/")
      file = resolve_path(path, base:)
      FileUtils.mkdir_p(File.dirname(file))
      File.binwrite(file, content)
      record_activity(:write)
      file
    end

    def mkdir(path, base: "/")
      directory = resolve_path(path, base:)
      FileUtils.mkdir_p(directory)
      record_activity(:mkdir)
      directory
    end

    def delete(path, base: "/")
      target = resolve_path(path, base:)
      raise MissingPathError, "Missing path: #{path}" unless File.exist?(target)

      FileUtils.rm_rf(target)
      record_activity(:delete)
      target
    end

    def chdir(path, base: "/")
      directory = resolve_path(path, base:)
      raise MissingPathError, "Missing path: #{path}" unless File.exist?(directory)
      raise NotDirectoryError, "Not a directory: #{path}" unless File.directory?(directory)

      guest_path(directory)
    end

    def guest_path_for(path, base: "/")
      guest_path(resolve_path(path, base:))
    end

    def exist?(path, base: "/")
      File.exist?(resolve_path(path, base:))
    end

    def indicator_state(now: wallclock_now)
      activity = activity_snapshot
      return :idle unless activity

      (now - activity.fetch(:timestamp)) <= ACTIVE_WINDOW ? :active : :idle
    end

    def indicator_label
      activity = activity_snapshot
      return "file idle" if indicator_state == :idle || activity.nil?

      "file #{activity.fetch(:operation)}"
    end

    private

    def resolve_path(path, base: "/")
      guest_path = path.to_s
      base_directory = resolve_base(base)
      expanded = if guest_path.start_with?("/")
                   File.expand_path(".#{guest_path}", root)
                 else
                   File.expand_path(guest_path.empty? ? "." : guest_path, base_directory)
                 end
      return expanded if expanded == root || expanded.start_with?("#{root}/")

      raise FilesystemError, "Path escapes filesystem root: #{path}"
    end

    def resolve_base(base)
      base_path = base.to_s
      expanded = if base_path.start_with?("/")
                   File.expand_path(".#{base_path}", root)
                 else
                   File.expand_path(base_path.empty? ? "." : base_path, root)
                 end
      return expanded if expanded == root || expanded.start_with?("#{root}/")

      raise FilesystemError, "Path escapes filesystem root: #{base}"
    end

    def guest_path(host_path)
      return "/" if host_path == root

      "/#{host_path.delete_prefix("#{root}/")}"
    end

    def record_activity(operation)
      timestamp = wallclock_now
      File.write(activity_path, "#{timestamp}\t#{operation}\n")

      @mutex.synchronize do
        @activity_cache = { timestamp:, operation: operation.to_s }
        @activity_cache_mtime = File.mtime(activity_path)
      end
    end

    def activity_snapshot
      @mutex.synchronize do
        if File.exist?(activity_path)
          mtime = File.mtime(activity_path)
          return @activity_cache if @activity_cache && @activity_cache_mtime == mtime

          timestamp, operation = File.read(activity_path).strip.split("\t", 2)
          @activity_cache = { timestamp: timestamp.to_f, operation: operation }
          @activity_cache_mtime = mtime
        end

        @activity_cache
      end
    end

    def activity_path
      File.join(root, ACTIVITY_FILENAME)
    end

    def wallclock_now
      Time.now.to_f
    end
  end
end
