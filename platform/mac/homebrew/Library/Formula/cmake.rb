class Cmake < Formula
  desc "Cross-platform make"
  homepage "https://www.cmake.org/"
  url "https://cmake.org/files/v3.4/cmake-3.4.2.tar.gz"
  sha256 "da7cc34e1ce1d82e67a32ab081c02c2845534cd8bf2e09d88077a1b282e97392"
  head "https://cmake.org/cmake.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "94ee520c3ce327ed25d28107aad84afce47cbb853c4d18f643234544084fc188" => :el_capitan
    sha256 "910db06295e604f546592f2a0236ed47a343eb7986bb4d583145b7af644bb708" => :yosemite
    sha256 "a8f145e6701e2e119565a93f6da6a158a36e69f32f92fadd8596d41615a6cf98" => :mavericks
  end

  option "without-docs", "Don't build man pages"
  option "with-completion", "Install Bash completion (Has potential problems with system bash)"

  depends_on "sphinx-doc" => :build if build.with? "docs"

  # The `with-qt` GUI option was removed due to circular dependencies if
  # CMake is built with Qt support and Qt is built with MySQL support as MySQL uses CMake.
  # For the GUI application please instead use brew install caskroom/cask/cmake.

  def install
    args = %W[
      --prefix=#{prefix}
      --no-system-libs
      --parallel=#{ENV.make_jobs}
      --datadir=/share/cmake
      --docdir=/share/doc/cmake
      --mandir=/share/man
      --system-zlib
      --system-bzip2
    ]

    # https://github.com/Homebrew/homebrew/issues/45989
    if MacOS.version <= :lion
      args << "--no-system-curl"
    else
      args << "--system-curl"
    end

    if build.with? "docs"
      # There is an existing issue around OS X & Python locale setting
      # See https://bugs.python.org/issue18378#msg215215 for explanation
      ENV["LC_ALL"] = "en_US.UTF-8"
      args << "--sphinx-man" << "--sphinx-build=#{Formula["sphinx-doc"].opt_bin}/sphinx-build"
    end

    system "./bootstrap", *args
    system "make"
    system "make", "install"

    if build.with? "completion"
      cd "Auxiliary/bash-completion/" do
        bash_completion.install "ctest", "cmake", "cpack"
      end
    end

    (share/"emacs/site-lisp/cmake").install "Auxiliary/cmake-mode.el"
  end

  test do
    (testpath/"CMakeLists.txt").write("find_package(Ruby)")
    system "#{bin}/cmake", "."
  end
end
