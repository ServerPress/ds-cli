class Sdl2 < Formula
  desc "Low-level access to audio, keyboard, mouse, joystick, and graphics"
  homepage "https://www.libsdl.org/"
  url "https://libsdl.org/release/SDL2-2.0.3.tar.gz"
  sha256 "a5a69a6abf80bcce713fa873607735fe712f44276a7f048d60a61bb2f6b3c90c"

  bottle do
    cellar :any
    revision 1
    sha256 "ad55070725fa11d107f1dafbc233cb4a1a5a7d229e5994d97921e4c3bd2e2288" => :el_capitan
    sha256 "ae40b379b1221d9817bc313510dc4c984c05ba0d9643a6335252e8c0bcfe7bc8" => :yosemite
    sha256 "4b2106b8a792079506f271cb4b90f85b179782c04fa3838cb98d572804a787e1" => :mavericks
    sha256 "b9449247a8637da1d558954f931b19b8267b57ef92941173a28aeb56a82c6f11" => :mountain_lion
  end

  head do
    url "http://hg.libsdl.org/SDL", :using => :hg

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  option :universal

  def install
    # we have to do this because most build scripts assume that all sdl modules
    # are installed to the same prefix. Consequently SDL stuff cannot be
    # keg-only but I doubt that will be needed.
    inreplace %w[sdl2.pc.in sdl2-config.in], "@prefix@", HOMEBREW_PREFIX

    ENV.universal_binary if build.universal?

    system "./autogen.sh" if build.head?

    args = %W[--prefix=#{prefix}]
    # LLVM-based compilers choke on the assembly code packaged with SDL.
    args << "--disable-assembly" if ENV.compiler == :llvm || (ENV.compiler == :clang && MacOS.clang_build_version < 421)
    args << "--without-x"

    system "./configure", *args
    system "make", "install"
  end

  test do
    system "#{bin}/sdl2-config", "--version"
  end
end
