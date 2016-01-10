class Mediaconch < Formula
  desc "Conformance checker and technical metadata reporter"
  homepage "https://mediaarea.net/MediaConch"
  url "https://mediaarea.net/download/binary/mediaconch/15.12/MediaConch_CLI_15.12hotfix1_GNU_FromSource.tar.bz2"
  version "15.12"
  sha256 "4899d43c097c552b2f970da6362407f002c61f93b11e8be3cf79b29c4733fd06"
  revision 1

  bottle do
    cellar :any
    sha256 "bffc87d94bad05bade06059d46f88871343805f186a4fd5bbede69d6d625fd8d" => :el_capitan
    sha256 "253897aaff0f219252f044b1516f019e810a9059ac30228dddd6c646691a0825" => :yosemite
    sha256 "349ce3bd26b6a56d9efaebcfacb0894d0bb73ed8ce23dac388ccaf68e36542cb" => :mavericks
  end

  depends_on "pkg-config" => :build
  depends_on "jansson"
  depends_on "libevent"
  depends_on "sqlite"
  # fails to build against Leopard's older libcurl
  depends_on "curl" if MacOS.version < :snow_leopard

  def install
    cd "ZenLib/Project/GNU/Library" do
      system "./configure", "--disable-debug", "--disable-dependency-tracking",
                            "--prefix=#{prefix}"
      system "make"
    end

    cd "MediaInfoLib/Project/GNU/Library" do
      args = ["--disable-debug",
              "--disable-dependency-tracking",
              "--with-libcurl",
              "--prefix=#{prefix}",
              # mediaconch installs libs/headers at the same paths as mediainfo
              "--libdir=#{lib}/mediaconch",
              "--includedir=#{include}/mediaconch"]
      system "./configure", *args
      system "make", "install"
    end

    cd "MediaConch/Project/GNU/CLI" do
      system "./configure", "--disable-debug", "--disable-dependency-tracking",
                            "--prefix=#{prefix}"
      system "make", "install"
    end
  end

  test do
    pipe_output("#{bin}/mediaconch", test_fixtures("test.mp3"))
  end
end
