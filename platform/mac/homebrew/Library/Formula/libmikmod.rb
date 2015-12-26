class Libmikmod < Formula
  desc "Portable sound library"
  homepage "http://mikmod.shlomifish.org"
  url "https://downloads.sourceforge.net/project/mikmod/libmikmod/3.3.7/libmikmod-3.3.7.tar.gz"
  sha256 "4cf41040a9af99cb960580210ba900c0a519f73ab97b503c780e82428b9bd9a2"

  bottle do
    cellar :any
    revision 1
    sha256 "e67080feaae93927e28c2bf9858e0fc1fb46c255cfa83b63a5f1502dcb1c06f7" => :el_capitan
    sha256 "248fd8f4c14cb6b26f5af74d64768dc4814f3314a8ee28afde508ae5a5b56bdf" => :yosemite
    sha256 "5b8181c542d780090a3ba51a2d41b5b36faa64ceb794735aeab088f1610cd899" => :mavericks
    sha256 "cccac33725e09722e0c501fc25cf1b63548a502e98171b826a30ee01d844266a" => :mountain_lion
  end

  option "with-debug", "Enable debugging symbols"

  def install
    ENV.O2 if build.with? "debug"

    # OSX has CoreAudio, but ALSA is not for this OS nor is SAM9407 nor ULTRA.
    args = %W[
      --prefix=#{prefix}
      --disable-alsa
      --disable-sam9407
      --disable-ultra
    ]
    args << "--with-debug" if build.with? "debug"
    mkdir "macbuild" do
      system "../configure", *args
      system "make", "install"
    end
  end

  test do
    system "#{bin}/libmikmod-config", "--version"
  end
end
