class Poppler < Formula
  desc "PDF rendering library (based on the xpdf-3.0 code base)"
  homepage "http://poppler.freedesktop.org"
  url "http://poppler.freedesktop.org/poppler-0.40.0.tar.xz"
  sha256 "bc0da278d6038ffc9cd2b8c1bba530a6ec7c072a593219a48f0a52a600ee6ead"

  bottle do
    sha256 "0d7bd1a214efd23f0e442aefa0c895b20abe11029da59a618f4fed899eee9dda" => :el_capitan
    sha256 "b48472f8508e928eceac6db8d1363b85e13d76ef6f05bfa12b6a976569199030" => :yosemite
    sha256 "62bc115a80c66f19de6a058ce0f2a56de97084e14844b0b617b40e540e461af6" => :mavericks
  end

  option "with-qt", "Build Qt backend"
  option "with-qt5", "Build Qt5 backend"
  option "with-little-cms2", "Use color management system"

  deprecated_option "with-qt4" => "with-qt"
  deprecated_option "with-lcms2" => "with-little-cms2"

  depends_on "pkg-config" => :build
  depends_on "cairo"
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "gettext"
  depends_on "glib"
  depends_on "gobject-introspection"
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "openjpeg"

  depends_on "qt" => :optional
  depends_on "qt5" => :optional
  depends_on "little-cms2" => :optional

  conflicts_with "pdftohtml", :because => "both install `pdftohtml` binaries"

  resource "font-data" do
    url "http://poppler.freedesktop.org/poppler-data-0.4.7.tar.gz"
    sha256 "e752b0d88a7aba54574152143e7bf76436a7ef51977c55d6bd9a48dccde3a7de"
  end

  def install
    ENV["LIBOPENJPEG_CFLAGS"] = "-I#{Formula["openjpeg"].opt_include}/openjpeg-1.5"

    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --enable-xpdf-headers
      --enable-poppler-glib
      --disable-gtk-test
      --enable-introspection=yes
    ]

    if build.with?("qt") && build.with?("qt5")
      raise "poppler: --with-qt and --with-qt5 cannot be used at the same time"
    elsif build.with? "qt"
      args << "--enable-poppler-qt4"
    elsif build.with? "qt5"
      args << "--enable-poppler-qt5"
    else
      args << "--disable-poppler-qt4" << "--disable-poppler-qt5"
    end

    args << "--enable-cms=lcms2" if build.with? "little-cms2"

    system "./configure", *args
    system "make", "install"
    resource("font-data").stage do
      system "make", "install", "prefix=#{prefix}"
    end
  end

  test do
    system "#{bin}/pdfinfo", test_fixtures("test.pdf")
  end
end
