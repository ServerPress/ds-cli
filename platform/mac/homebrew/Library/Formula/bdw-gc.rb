class BdwGc < Formula
  desc "Garbage collector for C and C++"
  homepage "http://www.hboehm.info/gc/"
  url "http://www.hboehm.info/gc/gc_source/gc-7.4.2.tar.gz"
  sha256 "63320ad7c45460e4a40e03f5aa4c6893783f21a16416c3282b994f933312afa2"

  bottle do
    revision 2
    sha256 "ba0257546369cd1879d66d3f1302194ae39767ccb5b012a20d16fdf5595b4326" => :el_capitan
    sha256 "bb654d5b6952c8b22ce74d0081f900f3fd8628bb79105ba1b1ddc672fea6b067" => :yosemite
    sha256 "ebbedf4fe84fbc6ccf621c7da954623443f1bc7596ca8c95efe72d4cba353d25" => :mavericks
    sha256 "e5725f4c6b23ce7dc75e3e8fff51cd1f9f90858bad20d1ce00cf33499edf8f6b" => :mountain_lion
  end

  head do
    url "https://github.com/ivmai/bdwgc.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool"  => :build
  end

  option :universal

  depends_on "pkg-config" => :build
  depends_on "libatomic_ops" => :build

  def install
    ENV.universal_binary if build.universal?

    system "./autogen.sh" if build.head?
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-cplusplus"
    system "make"
    system "make", "check"
    system "make", "install"
  end
end
