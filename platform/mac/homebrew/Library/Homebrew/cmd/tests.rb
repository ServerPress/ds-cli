module Homebrew
  def tests
    (HOMEBREW_LIBRARY/"Homebrew/test").cd do
      ENV["TESTOPTS"] = "-v" if ARGV.verbose?
      ENV["HOMEBREW_TESTS_COVERAGE"] = "1" if ARGV.include? "--coverage"
      ENV["HOMEBREW_NO_COMPAT"] = "1" if ARGV.include? "--no-compat"

      # Override author/committer as global settings might be invalid and thus
      # will cause silent failure during the setup of dummy Git repositories.
      %w[AUTHOR COMMITTER].each do |role|
        ENV["GIT_#{role}_NAME"] = "brew tests"
        ENV["GIT_#{role}_EMAIL"] = "brew-tests@localhost"
      end

      Homebrew.install_gem_setup_path! "bundler"
      unless quiet_system("bundle", "check")
        system "bundle", "install", "--path", "vendor/bundle"
      end

      args = []
      args << "--trace" if ARGV.include? "--trace"
      args += ARGV.named
      system "bundle", "exec", "rake", "test", *args

      Homebrew.failed = !$?.success?

      if (fs_leak_log = HOMEBREW_LIBRARY/"Homebrew/test/fs_leak_log").file?
        fs_leak_log_content = fs_leak_log.read
        unless fs_leak_log_content.empty?
          opoo "File leak is detected"
          puts fs_leak_log_content
          Homebrew.failed = true
        end
      end
    end
  end
end
