class Sdl < Formula
  desc "Low-level access to audio, keyboard, mouse, joystick and graphics"
  homepage "https://www.libsdl.org/"
  url "https://www.libsdl.org/release/SDL-1.2.15.tar.gz"
  sha256 "d6d316a793e5e348155f0dd93b979798933fb98aa1edebcc108829d6474aad00"

  bottle do
    cellar :any
    revision 2
    sha256 "c9c66beaee50897468330709dc618246b298d63854309863e958e6b46ecec06a" => :el_capitan
    sha256 "ec2202243209e378fc50bb9ad1bd7c7cff0ae893f81780228113b542059e3a92" => :yosemite
    sha256 "92f71a40ad275455e0db75057fcfd29ca35abbf583de73e106ccb903541405af" => :mavericks
    sha256 "10f73b430cc6794a9fe16382ffe9616ab6bf541f46f6bda903472699369a7856" => :mountain_lion
  end

  head do
    url "https://hg.libsdl.org/SDL", :branch => "SDL-1.2", :using => :hg

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  option "with-x11", "Compile with support for X11 video driver"
  option "with-test", "Compile and install the tests"
  option :universal

  deprecated_option "with-x11-driver" => "with-x11"
  deprecated_option "with-tests" => "with-test"

  depends_on :x11 => :optional

  if build.with? "x11"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build

    # Fix build against recent libX11; requires regenerating configure script
    patch do
      url "https://hg.libsdl.org/SDL/raw-rev/91ad7b43317a"
      sha256 "04fa6aaf1ae1043e82d85f367fdb3bea5532e60aa944ce17357030ee93bb856c"
    end
  end

  # Fix for a bug preventing SDL from building at all on OSX 10.9 Mavericks
  # Related ticket: https://bugzilla.libsdl.org/show_bug.cgi?id=2085
  patch do
    url "https://bugzilla-attachments.libsdl.org/attachment.cgi?id=1320"
    sha256 "ba0bf2dd8b3f7605db761be11ee97a686c8516a809821a4bc79be738473ddbf5"
  end

  # Fix compilation error on 10.6 introduced by the above patch
  patch do
    url "https://bugzilla-attachments.libsdl.org/attachment.cgi?id=1324"
    sha256 "ee7eccb51cefff15c6bf8313a7cc7a3f347dc8e9fdba7a3c3bd73f958070b3eb"
  end

  def install
    # we have to do this because most build scripts assume that all sdl modules
    # are installed to the same prefix. Consequently SDL stuff cannot be
    # keg-only but I doubt that will be needed.
    inreplace %w[sdl.pc.in sdl-config.in], "@prefix@", HOMEBREW_PREFIX

    ENV.universal_binary if build.universal?

    system "./autogen.sh" if build.head? || build.with?("x11")

    args = %W[--prefix=#{prefix}]
    args << "--disable-nasm" unless MacOS.version >= :mountain_lion # might work with earlier, might only work with new clang
    # LLVM-based compilers choke on the assembly code packaged with SDL.
    args << "--disable-assembly" if ENV.compiler == :llvm || (ENV.compiler == :clang && MacOS.clang_build_version < 421)
    args << "--without-x" if build.without? "x11"
    args << "--with-x" if build.with? "x11"

    system "./configure", *args
    system "make", "install"

    # Copy source files needed for Ojective-C support.
    libexec.install Dir["src/main/macosx/*"] if build.stable?

    if build.with? "test"
      ENV.prepend_path "PATH", "#{bin}"
      # This is stupid but necessary. Blurgh. Otherwise, test building fails, even
      # with various flags, prepending & pkg_config_path tinkering.
      inreplace "#{bin}/sdl-config", "prefix=#{HOMEBREW_PREFIX}", "prefix=#{prefix}"
      cd "test" do
        system "./configure"
        system "make"
        # Upstream - Why no make install? Why?
        (share/"tests").install %w[checkkeys graywin loopwave testalpha testbitmap testblitspeed testcdrom
                                   testcursor testdyngl testerror testfile testgamma testgl testhread testiconv
                                   testjoystick testkeys testloadso testlock testoverlay testoverlay2 testpalette
                                   testplatform testsem testsprite testtimer testver testvidinfo testwin testwm
                                   threadwin torturethread]
        (share/"test_extras").install %w[icon.bmp moose.dat picture.xbm sail.bmp sample.bmp sample.wav]
        bin.write_exec_script Dir["#{share}/tests/*"]
      end
      # And then we undo stupid but necessary so it doesn't break all the other things.
      inreplace "#{bin}/sdl-config", "prefix=#{prefix}", "prefix=#{HOMEBREW_PREFIX}"
    end
  end

  test do
    system "#{bin}/sdl-config", "--version"
  end
end
