class Snzip < Formula
  desc "Compression/decompression tool based on snappy"
  homepage "https://github.com/kubo/snzip"
  url "https://bintray.com/artifact/download/kubo/generic/snzip-1.0.2.tar.gz"
  sha256 "b4e4175b9ee74da6c7ee4681d7c8c1b92d7c4aaa4eb79559a2300ab9b2e8eb1b"

  bottle do
    cellar :any
    sha256 "dab2db159fc08d16d1b526c2abb2913cbacf64ad862aaef885ec8062626ecbaa" => :yosemite
    sha256 "cfb1f8addadcb6a7c1a57d5ea5a0177a30e896d8c7d029167412a5740c0824b1" => :mavericks
    sha256 "46c35841df6c0cd60cec8e45e31bce5d8c64ef67ace33aa6c2d71e3dc6fa9071" => :mountain_lion
  end

  depends_on "snappy"

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.out").write "test"
    system "#{bin}/snzip", "test.out"
    system "#{bin}/snzip", "-d", "test.out.sz"
  end
end
