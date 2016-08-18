class Rubberband < Formula
  desc "audio time stretcher tool and library"
  homepage "http://breakfastquay.com/rubberband/"
  url "http://code.breakfastquay.com/attachments/download/34/rubberband-1.8.1.tar.bz2"
  sha256 "ff0c63b0b5ce41f937a8a3bc560f27918c5fe0b90c6bc1cb70829b86ada82b75"
  head "https://bitbucket.org/breakfastquay/rubberband/", :using => :hg

  stable do
    # replace vecLib.h by Accelerate.h
    # already fixed in upstream:
    # https://bitbucket.org/breakfastquay/rubberband/commits/cb02b7ed1500f0c06c0ffd196921c812dbcf6888
    # https://bitbucket.org/breakfastquay/rubberband/commits/9e32f693c6122b656a0df63bc77e6a96d6ba213d
    patch :p1 do
      url "http://tuohela.net/irc/rubberband-1.8.1-yosemite.diff"
      sha1 "76ea7cac0fc0ab99b38081176375ef7c34be678f"
    end
  end
  bottle do
    cellar :any
    sha256 "e1890156ef9c638993fc9410bc4b5ccee113a14bb59861ebd25a6d68501f83d7" => :el_capitan
    sha256 "746b65592ab6a93e990a7930a22aaa5c7c559e1bfdff7da8d3f292168e79e512" => :yosemite
    sha256 "06c1b9d0bea22637edec00a3bd41b118472caee55902b6c1f8ea8941d922a3f7" => :mavericks
  end

  depends_on "pkg-config" => :build
  depends_on "libsamplerate"
  depends_on "libsndfile"

  def install
    system "make", "-f", "Makefile.osx"
    bin.install "bin/rubberband"
    lib.install "lib/librubberband.dylib"
    include.install "rubberband"

    cp "rubberband.pc.in", "rubberband.pc"
    inreplace "rubberband.pc", "%PREFIX%", opt_prefix
    (lib/"pkgconfig").install "rubberband.pc"
  end

  test do
    assert_match /Pass 2: Processing.../, shell_output("rubberband -t2 #{test_fixtures("test.wav")} out.wav 2>&1")
  end
end
