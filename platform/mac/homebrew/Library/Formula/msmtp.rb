class Msmtp < Formula
  desc "SMTP client that can be used as an SMTP plugin for Mutt"
  homepage "http://msmtp.sourceforge.net"
  url "https://downloads.sourceforge.net/project/msmtp/msmtp/1.6.3/msmtp-1.6.3.tar.xz"
  sha256 "f982be069c0772c3ee83925f552f5dac5fb307d2d1c68202f9926bb13b757355"

  bottle do
    sha256 "d13d88fa1421f1880468f20823701f11b26e98c41583b6b807f03ca68da1a26e" => :el_capitan
    sha256 "69b705be25fe23c3a963d0c802f7486f80d817ab3fa42839cf0f7c8abe2ffda4" => :yosemite
    sha256 "7d5777359ecd6252cc8acabb17192ed180c326d25731682328d73a9fe797837a" => :mavericks
  end

  option "with-gsasl", "Use GNU SASL authentication library"

  depends_on "pkg-config" => :build
  depends_on "openssl"
  depends_on "gsasl" => :optional

  def install
    args = %W[
      --disable-dependency-tracking
      --with-macosx-keyring
      --prefix=#{prefix}
      --with-tls=openssl
    ]

    args << "--with-libsasl" if build.with? "gsasl"

    system "./configure", *args
    system "make", "install"
    (share/"msmtp/scripts").install "scripts/msmtpq"
  end
end
