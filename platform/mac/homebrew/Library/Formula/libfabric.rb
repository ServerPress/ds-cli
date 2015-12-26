class Libfabric < Formula
  desc "OpenFabrics libfabric"
  homepage "https://ofiwg.github.io/libfabric/"
  url "https://downloads.openfabrics.org/downloads/ofi/libfabric-1.1.1.tar.bz2"
  sha256 "228c50d1f9595009a026bb2293f372a04d89ecb3b0f7fcde3905476dbf49fc95"

  bottle do
    sha256 "aba7aa15e9ea1666faa54569e3a84d8bcc8fe194836dd4dbc03eb1eade69269b" => :el_capitan
    sha256 "4b9a5d0f42d6f29531b6b497ed9054afbb1f42dc7587f27fa9dc4f6b9a44f6fd" => :yosemite
    sha256 "0e757a155e62a7a547e17e81eae96b2b3cf77be70872c0a108fe6d9f29995db5" => :mavericks
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#(bin}/fi_info"
  end
end
