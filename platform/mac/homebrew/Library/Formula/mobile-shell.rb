class MobileShell < Formula
  desc "Remote terminal application"
  homepage "https://mosh.mit.edu/"

  stable do
    url "https://mosh.mit.edu/mosh-1.2.5.tar.gz"
    sha256 "1af809e5d747c333a852fbf7acdbf4d354dc4bbc2839e3afe5cf798190074be3"

    # Upstream switched to defaulting to CommonCrypto as of
    # https://github.com/mobile-shell/mosh/commit/0eb614809a7ea
    depends_on "openssl"
  end

  bottle do
    sha256 "046b0c48cd1c573d57500e683122e3152a00556ad960938c6caa962b0c2ef460" => :el_capitan
    sha256 "33719bc3df39cf2fdeb4589129f164f3500d2eac1e874666c747b612384545cf" => :yosemite
    sha256 "9460c06ccef476ef1b3feed85168ea989ef4eced753cbd59ed53fd512f5c1aff" => :mavericks
    sha256 "5a244c07094d5d3d30a95888a7bb0df6051fd81cfec7fd35ac861090f1897d6e" => :mountain_lion
  end

  head do
    url "https://github.com/mobile-shell/mosh.git", :shallow => false

    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  option "without-test", "Run build-time tests"

  deprecated_option "without-check" => "without-test"

  depends_on "pkg-config" => :build
  depends_on "protobuf"

  def install
    # teach mosh to locate mosh-client without referring
    # PATH to support launching outside shell e.g. via launcher
    inreplace "scripts/mosh.pl", "'mosh-client", "\'#{bin}/mosh-client"

    # Upstream prefers O2:
    # https://github.com/keithw/mosh/blob/master/README.md
    ENV.O2
    system "./autogen.sh" if build.head?
    system "./configure", "--prefix=#{prefix}", "--enable-completion"
    system "make", "check" if build.with?("test") || build.bottle?
    system "make", "install"
  end

  test do
    ENV["TERM"] = "xterm"
    system "#{bin}/mosh-client", "-c"
  end
end
