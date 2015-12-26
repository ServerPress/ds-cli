require "formula"
require "blacklist"
require "digest"
require "erb"

module Homebrew
  # Create a formula from a tarball URL
  def create
    # Allow searching MacPorts or Fink.
    if ARGV.include? "--macports"
      opoo "`brew create --macports` is deprecated; use `brew search --macports` instead"
      exec_browser "https://www.macports.org/ports.php?by=name&substr=#{ARGV.next}"
    elsif ARGV.include? "--fink"
      opoo "`brew create --fink` is deprecated; use `brew search --fink` instead"
      exec_browser "http://pdb.finkproject.org/pdb/browse.php?summary=#{ARGV.next}"
    end

    raise UsageError if ARGV.named.empty?

    # Ensure that the cache exists so we can fetch the tarball
    HOMEBREW_CACHE.mkpath

    url = ARGV.named.first # Pull the first (and only) url from ARGV

    version = ARGV.next if ARGV.include? "--set-version"
    name = ARGV.next if ARGV.include? "--set-name"

    fc = FormulaCreator.new
    fc.name = name
    fc.version = version
    fc.url = url

    fc.mode = if ARGV.include? "--cmake"
      :cmake
    elsif ARGV.include? "--autotools"
      :autotools
    end

    if fc.name.nil? || fc.name.strip.empty?
      stem = Pathname.new(url).stem
      print "Formula name [#{stem}]: "
      fc.name = __gets || stem
      fc.path = Formulary.path(fc.name)
    end

    # Don't allow blacklisted formula, or names that shadow aliases,
    # unless --force is specified.
    unless ARGV.force?
      if msg = blacklisted?(fc.name)
        raise "#{fc.name} is blacklisted for creation.\n#{msg}\nIf you really want to create this formula use --force."
      end

      if Formula.aliases.include? fc.name
        realname = Formulary.canonical_name(fc.name)
        raise <<-EOS.undent
          The formula #{realname} is already aliased to #{fc.name}
          Please check that you are not creating a duplicate.
          To force creation use --force.
          EOS
      end
    end

    fc.generate!

    puts "Please `brew audit --strict #{fc.name}` before submitting, thanks."
    exec_editor fc.path
  end

  def __gets
    gots = $stdin.gets.chomp
    if gots.empty? then nil else gots end
  end
end

class FormulaCreator
  attr_reader :url, :sha256
  attr_accessor :name, :version, :path, :mode

  def url=(url)
    @url = url
    path = Pathname.new(url)
    if @name.nil?
      case url
      when %r{github\.com/\S+/(\S+)\.git}
        @name = $1
        @head = true
      when %r{github\.com/\S+/(\S+)/archive/}
        @name = $1
      else
        /(.*?)[-_.]?#{path.version}/.match path.basename
        @name = $1
      end
      @path = Formulary.path @name unless @name.nil?
    else
      @path = Formulary.path name
    end
    if @version
      @version = Version.new(@version)
    else
      @version = Pathname.new(url).version
    end
  end

  def fetch?
    !head? && !ARGV.include?("--no-fetch")
  end

  def head?
    @head || ARGV.build_head?
  end

  def generate!
    raise "#{path} already exists" if path.exist?

    if version.nil?
      opoo "Version cannot be determined from URL."
      puts "You'll need to add an explicit 'version' to the formula."
    end

    if fetch? && version
      r = Resource.new
      r.url(url)
      r.version(version)
      r.owner = self
      @sha256 = r.fetch.sha256 if r.download_strategy == CurlDownloadStrategy
    end

    path.write ERB.new(template, nil, ">").result(binding)
  end

  def template; <<-EOS.undent
    # Documentation: https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/Formula-Cookbook.md
    #                http://www.rubydoc.info/github/Homebrew/homebrew/master/Formula
    # PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!

    class #{Formulary.class_s(name)} < Formula
      desc ""
      homepage ""
    <% if head? %>
      head "#{url}"
    <% else %>
      url "#{url}"
    <% unless version.nil? or version.detected_from_url? %>
      version "#{version}"
    <% end %>
      sha256 "#{sha256}"
    <% end %>

    <% if mode == :cmake %>
      depends_on "cmake" => :build
    <% elsif mode.nil? %>
      # depends_on "cmake" => :build
    <% end %>
      depends_on :x11 # if your formula requires any X11/XQuartz components

      def install
        # ENV.deparallelize  # if your formula fails when building in parallel

    <% if mode == :cmake %>
        system "cmake", ".", *std_cmake_args
    <% elsif mode == :autotools %>
        # Remove unrecognized options if warned by configure
        system "./configure", "--disable-debug",
                              "--disable-dependency-tracking",
                              "--disable-silent-rules",
                              "--prefix=\#{prefix}"
    <% else %>
        # Remove unrecognized options if warned by configure
        system "./configure", "--disable-debug",
                              "--disable-dependency-tracking",
                              "--disable-silent-rules",
                              "--prefix=\#{prefix}"
        # system "cmake", ".", *std_cmake_args
    <% end %>
        system "make", "install" # if this fails, try separate make/make install steps
      end

      test do
        # `test do` will create, run in and delete a temporary directory.
        #
        # This test will fail and we won't accept that! It's enough to just replace
        # "false" with the main program this formula installs, but it'd be nice if you
        # were more thorough. Run the test with `brew test #{name}`. Options passed
        # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
        #
        # The installed folder is not in the path, so use the entire path to any
        # executables being tested: `system "\#{bin}/program", "do", "something"`.
        system "false"
      end
    end
    EOS
  end
end
