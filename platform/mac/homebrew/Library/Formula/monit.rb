class Monit < Formula
  desc "Manage and monitor processes, files, directories, and devices"
  homepage "https://mmonit.com/monit/"
  url "https://mmonit.com/monit/dist/monit-5.15.tar.gz"
  mirror "https://mirrors.kernel.org/debian/pool/main/m/monit/monit_5.15.orig.tar.gz"
  sha256 "deada8153dc7e8755f572bc4d790143a92c7a8668dccb563ae4dbd73af56697c"

  bottle do
    cellar :any
    sha256 "76948f1edb602486f131a7879726abc437d7d673674e0d8f458157355c09ce14" => :el_capitan
    sha256 "08aa2c3b4d1662643d3a843f1a31b63f9f1ae7e367d4d2b56621a78d95ed9bcb" => :yosemite
    sha256 "e14e2dabf05055a9f3392a626718c5a24d481e6104f6ff7770b49dfe63475f08" => :mavericks
  end

  depends_on "openssl"

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--localstatedir=#{var}/monit",
                          "--sysconfdir=#{etc}/monit",
                          "--with-ssl-dir=#{Formula["openssl"].opt_prefix}"
    system "make", "install"
    (share/"monit").install "monitrc"
  end

  test do
    system bin/"monit", "-c", share/"monit/monitrc", "-t"
  end
end
