class JpegTurbo < Formula
  desc "JPEG image codec that aids compression and decompression"
  homepage "http://www.libjpeg-turbo.org/"
  url "https://downloads.sourceforge.net/project/libjpeg-turbo/1.4.2/libjpeg-turbo-1.4.2.tar.gz"
  sha256 "521bb5d3043e7ac063ce3026d9a59cc2ab2e9636c655a2515af5f4706122233e"

  bottle do
    cellar :any
    sha256 "2a3e9656a87bd0e31bac5c5cd94fa9e09523afa506b7240d082b7d1072aac89a" => :el_capitan
    sha256 "fc478fdd8d2c25e1fd1c077c782315c5ea147073baede28f7e9ee6eb95bf9b40" => :yosemite
    sha256 "9f2996c10e583b034d16860e9c70eb56084d5502a6ef60275661fa30e5ccbc53" => :mavericks
  end

  option "without-test", "Skip build-time checks (Not Recommended)"

  depends_on "libtool" => :build

  keg_only "libjpeg-turbo is not linked to prevent conflicts with the standard libjpeg."

  # https://github.com/Homebrew/homebrew/issues/41023
  # http://sourceforge.net/p/libjpeg-turbo/mailman/message/34219546/
  # Should be safe to remove once nasm 2.11.09 lands - Check first.
  resource "nasm" do
    url "http://www.nasm.us/pub/nasm/releasebuilds/2.11.06/nasm-2.11.06.tar.xz"
    sha256 "90f60d95a15b8a54bf34d87b9be53da89ee3d6213ea739fb2305846f4585868a"
  end

  def install
    cp Dir["#{Formula["libtool"].opt_share}/libtool/*/config.{guess,sub}"], buildpath
    args = %W[--disable-dependency-tracking --prefix=#{prefix} --with-jpeg8 --mandir=#{man}]

    if MacOS.prefer_64_bit?
      resource("nasm").stage do
        system "./configure", "--prefix=#{buildpath}/nasm"
        system "make", "install"
      end

      ENV.prepend_path "PATH", buildpath/"nasm/bin"
      args << "NASM=#{buildpath}/nasm/bin/nasm"
    end

    system "./configure", *args
    system "make"
    system "make", "test" if build.with? "test"
    ENV.j1 # Stops a race condition error: file exists
    system "make", "install"
  end

  test do
    system "#{bin}/jpegtran", "-crop", "1x1",
                              "-transpose", "-perfect",
                              "-outfile", "out.jpg",
                              test_fixtures("test.jpg")
  end
end
