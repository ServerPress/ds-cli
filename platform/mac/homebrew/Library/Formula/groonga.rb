class Groonga < Formula
  desc "Fulltext search engine and column store"
  homepage "http://groonga.org/"
  url "http://packages.groonga.org/source/groonga/groonga-5.1.0.tar.gz"
  sha256 "08cd6037e8a1429e36da54d1c10bcdbadfb37aa7111fb6869f324f60344566d4"

  bottle do
    sha256 "6700081b9f3b3aaf0ab072a4d17e27f1792bf5adae567751c1c3c9d744c3d048" => :el_capitan
    sha256 "b89d0e7d809c8a2b6cf9e60c0935170b57c96f638f6394bbd9f79da3b67ae511" => :yosemite
    sha256 "13cc291a0a7034da80c28cfe4e87f343e7015628d9402e5d5d53d65480fa59d8" => :mavericks
  end

  head do
    url "https://github.com/groonga/groonga.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  option "with-benchmark", "With benchmark program for developer use"
  option "with-suggest-plugin", "With suggest plugin for suggesting"

  deprecated_option "enable-benchmark" => "with-benchmark"

  depends_on "pkg-config" => :build
  depends_on "pcre"
  depends_on "msgpack"
  depends_on "mecab" => :optional
  depends_on "lz4" => :optional
  depends_on "openssl"
  depends_on "mecab-ipadic" if build.with? "mecab"
  depends_on "glib" if build.with? "benchmark"

  if build.with? "suggest-plugin"
    depends_on "libevent"
    depends_on "zeromq"
  end

  def install
    args = %W[
      --prefix=#{prefix}
      --with-zlib
      --enable-mruby
      --without-libstemmer
    ]

    # ZeroMQ is an optional dependency that will be auto-detected unless we disable it
    if build.with? "suggest-plugin"
      args << "--enable-zeromq"
    else
      args << "--disable-zeromq"
    end

    args << "--enable-benchmark" if build.with? "benchmark"
    args << "--with-mecab" if build.with? "mecab"
    args << "--with-lz4" if build.with? "lz4"

    if build.head?
      args << "--with-ruby"
      system "./autogen.sh"
    end

    system "./configure", *args
    system "make", "install"
  end

  test do
    io = IO.popen("#{bin}/groonga -n #{testpath}/test.db", "r+")
    io.puts("table_create --name TestTable --flags TABLE_HASH_KEY --key_type ShortText")
    sleep 2
    io.puts("shutdown")
    # expected returned result is like this:
    # [[0,1447502555.38667,0.000824928283691406],true]\n
    assert_match(/[[0,\d+.\d+,\d+.\d+],true]/, io.read)
  end
end
