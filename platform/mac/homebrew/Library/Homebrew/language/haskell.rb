module Language
  module Haskell
    module Cabal
      def self.included(base)
        # use llvm-gcc on Lion or below, as when building GHC)
        base.fails_with(:clang) if MacOS.version <= :lion
      end

      def cabal_sandbox(options = {})
        pwd = Pathname.pwd
        home = options[:home] || pwd

        # pretend HOME is elsewhere, so that ~/.cabal is kept as untouched
        # as possible (except for ~/.cabal/setup-exe-cache)
        # https://github.com/haskell/cabal/issues/1234
        saved_home = ENV["HOME"]
        ENV["HOME"] = home

        system "cabal", "sandbox", "init"
        cabal_sandbox_bin = pwd/".cabal-sandbox/bin"
        mkdir_p cabal_sandbox_bin

        # make available any tools that will be installed in the sandbox
        saved_path = ENV["PATH"]
        ENV.prepend_path "PATH", cabal_sandbox_bin

        # avoid updating the cabal package database more than once
        system "cabal", "update" unless (home/".cabal/packages").exist?

        yield

        # remove the sandbox and all build products
        rm_rf [".cabal-sandbox", "cabal.sandbox.config", "dist"]

        # avoid installing any Haskell libraries, as a matter of policy
        rm_rf lib unless options[:keep_lib]

        # restore the environment
        ENV["HOME"] = saved_home
        ENV["PATH"] = saved_path
      end

      def cabal_sandbox_add_source(*args)
        system "cabal", "sandbox", "add-source", *args
      end

      def cabal_install(*args)
        system "cabal", "install", "--jobs=#{ENV.make_jobs}", *args
      end

      def cabal_install_tools(*tools)
        # install tools sequentially, as some tools can depend on other tools
        tools.each { |tool| cabal_install tool }

        # unregister packages installed as dependencies for the tools, so
        # that they can't cause dependency conflicts for the main package
        rm_rf Dir[".cabal-sandbox/*packages.conf.d/"]
      end

      def install_cabal_package(*args)
        options = if args[-1].kind_of?(Hash) then args.pop else {} end

        cabal_sandbox do
          cabal_install_tools(*options[:using]) if options[:using]

          # install dependencies in the sandbox
          cabal_install "--only-dependencies", *args

          # install the main package in the destination dir
          cabal_install "--prefix=#{prefix}", *args

          yield if block_given?
        end
      end
    end
  end
end
