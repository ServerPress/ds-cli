class Upscaledb < Formula
  desc "Database for embedded devices"
  homepage "http://upscaledb.com/"
  url "http://files.upscaledb.com/dl/upscaledb-2.1.12.tar.gz"
  sha256 "f68c7e7b8f5aaf41ab47d60e351db35506f96ebf8be2ad695a0d8a12035001df"

  bottle do
    cellar :any
    sha256 "9f10d82a1189c8de362efb53e7cb0a67fd6e804f1c64626087f089dd882bbef0" => :el_capitan
    sha256 "fb96b299611a38359cbbc6befbfcf8a43a3cd6807248e1e685d73d344e1c3fa8" => :yosemite
    sha256 "9ba5cc10a0be221f02f43b700754a4dee74c7de70db47e2cf342e6134d2fe349" => :mavericks
  end

  head do
    url "https://github.com/cruppstahl/upscaledb.git"

    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
  end

  option "without-java", "Do not build the Java wrapper"
  option "without-remote", "Disable access to remote databases"

  depends_on "boost"
  depends_on "gnutls"
  depends_on "openssl"
  depends_on :java => :recommended
  depends_on "protobuf" if build.with? "remote"

  resource "libuv" do
    url "https://github.com/libuv/libuv/archive/v0.10.36.tar.gz"
    sha256 "421087044cab642f038c190f180d96d6a1157be89adb4630881930495b8f5228"
  end

  fails_with :clang do
    build 503
    cause "error: member access into incomplete type 'const std::type_info"
  end
  fails_with :llvm do
    build 2336
    cause "error: forward declaration of 'const struct std::type_info'"
  end

  def install
    system "./bootstrap.sh" if build.head?

    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --prefix=#{prefix}
    ]

    if build.with? "java"
      args << "JDK=#{ENV["JAVA_HOME"]}"
    else
      args << "--disable-java"
    end

    if build.with? "remote"
      resource("libuv").stage do
        system "make", "libuv.dylib", "SO_LDFLAGS=-Wl,-install_name,#{libexec}/libuv/lib/libuv.dylib"
        (libexec/"libuv/lib").install "libuv.dylib"
        (libexec/"libuv").install "include"
      end

      ENV.prepend "LDFLAGS", "-L#{libexec}/libuv/lib"
      ENV.prepend "CFLAGS", "-I#{libexec}/libuv/include"
      ENV.prepend "CPPFLAGS", "-I#{libexec}/libuv/include"
    else
      args << "--disable-remote"
    end

    system "./configure", *args
    system "make", "install"
    # https://github.com/cruppstahl/upscaledb/commit/b435cc4fdfd8750aa3e717321608ef0c059d15ca
    mv include/"ham", include/"ups" if build.stable?

    share.install "samples"
  end

  test do
    system ENV.cc, "-I#{include}", "-L#{lib}", "-lupscaledb",
           share/"samples/db1.c", "-o", "test"
    system "./test"
  end
end
