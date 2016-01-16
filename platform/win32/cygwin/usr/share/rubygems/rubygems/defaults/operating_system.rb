module Gem
  class << self

    ##
    # Returns full path of previous but one directory of dir in path
    # E.g. for '/usr/share/ruby', 'ruby', it returns '/usr'

    def previous_but_one_dir_to(path, dir)
      split_path = path.split(File::SEPARATOR)
      File.join(split_path.take_while { |one_dir| one_dir !~ /^#{dir}$/ }[0..-2])
    end
    private :previous_but_one_dir_to

    ##
    # Tries to detect if arguments and environment variables suggest that
    # 'gem install' is executed from cygport.

    def cygport?
     # (ARGV.include?('--install-dir') || ARGV.include?('-i')) &&
      ENV['CYGPORT_PACKAGE_NAME']
    end
    private :cygport?

    ##
    # Default gems locations allowed on FHS system (/usr, /usr/share).
    # The locations are derived from directories specified during build
    # configuration.

    def default_locations
      @default_locations ||= {
        :system => previous_but_one_dir_to(ConfigMap[:vendordir], ConfigMap[:RUBY_INSTALL_NAME]),
        :local => previous_but_one_dir_to(ConfigMap[:sitedir], ConfigMap[:RUBY_INSTALL_NAME])
      }
    end

    ##
    # For each location provides set of directories for binaries (:bin_dir)
    # platform independent (:gem_dir) and dependent (:ext_dir) files.

    def default_dirs
      @libdir ||= case RUBY_PLATFORM
      when 'java'
        ConfigMap[:datadir]
      else
        ConfigMap[:libdir]
      end

      @default_dirs ||= Hash[default_locations.collect do |destination, path|
        [destination, {
          :bin_dir => File.join(path, ConfigMap[:bindir].split(File::SEPARATOR).last),
          :gem_dir => File.join(path, ConfigMap[:datadir].split(File::SEPARATOR).last, 'gems'),
          :ext_dir => File.join(path, @libdir.split(File::SEPARATOR).last, 'gems')
        }]
      end]
    end

    ##
    # Remove methods we are going to override. This avoids "method redefined;"
    # warnings otherwise issued by Ruby.

    remove_method :default_dir if method_defined? :default_dir
    remove_method :default_path if method_defined? :default_path
    remove_method :default_bindir if method_defined? :default_bindir
    remove_method :default_ext_dir_for if method_defined? :default_ext_dir_for

    ##
    # RubyGems default overrides.

    def default_dir
      if cygport?
        Gem.default_dirs[:system][:gem_dir]
      else
        Gem.user_dir
      end
    end

    def default_path
      path = default_dirs.collect {|location, paths| paths[:gem_dir]}
      path.unshift Gem.user_dir if File.exist? Gem.user_home
    end

    def default_bindir
      if cygport?
        Gem.default_dirs[:system][:bin_dir]
      else
        File.join [Dir.home, 'bin']
      end
    end

    def default_ext_dir_for base_dir
      dir = if cygport?
        build_dir = base_dir.chomp Gem.default_dirs[:system][:gem_dir]
        if build_dir != base_dir
          File.join build_dir, Gem.default_dirs[:system][:ext_dir]
        end
      else
        dirs = Gem.default_dirs.detect {|location, paths| paths[:gem_dir] == base_dir}
        dirs && dirs.last[:ext_dir]
      end
      dir && File.join(dir, RbConfig::CONFIG['RUBY_INSTALL_NAME'], File.basename(RbConfig::CONFIG['vendorarchdir']))
    end

    # This method should be available since RubyGems 2.2 until RubyGems 3.0.
    # https://github.com/rubygems/rubygems/issues/749
    if method_defined? :install_extension_in_lib
      remove_method :install_extension_in_lib

      def install_extension_in_lib
        false
      end
    end
  end
end

