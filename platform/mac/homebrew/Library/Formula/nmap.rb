class Nmap < Formula
  desc "Port scanning utility for large networks"
  homepage "https://nmap.org/"
  head "https://guest:@svn.nmap.org/nmap/", :using => :svn
  url "https://nmap.org/dist/nmap-7.00.tar.bz2"
  sha256 "9f442301c615c608a385831c3505cdfed9b0795cd100f1a258b04509802802ae"

  bottle do
    sha256 "bae238a841b62906063ed10160235804d648b21fecb4f0871fb360c292e6fea1" => :el_capitan
    sha256 "668190150ece1d4a50872ac84c013d5e9becda6bd345abbcc86a8ec4b3c45e6f" => :yosemite
    sha256 "2d9ff311503dd7c839fb1e914ca82182bd144309e9e2811c81b7945978b23851" => :mavericks
  end

  depends_on "openssl"

  conflicts_with "ndiff", :because => "both install `ndiff` binaries"

  fails_with :llvm do
    build 2334
  end

  def install
    ENV.deparallelize

    args = %W[
      --prefix=#{prefix}
      --with-libpcre=included
      --with-liblua=included
      --with-openssl=#{Formula["openssl"].opt_prefix}
      --without-nmap-update
      --without-zenmap
      --disable-universal
    ]

    system "./configure", *args
    system "make" # separate steps required otherwise the build fails
    system "make", "install"
  end

  test do
    system "#{bin}/nmap", "-p80,443", "google.com"
  end
end
