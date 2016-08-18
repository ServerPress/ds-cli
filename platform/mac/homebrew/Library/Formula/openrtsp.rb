class Openrtsp < Formula
  desc "Command-line RTSP client"
  homepage "http://www.live555.com/openRTSP"
  url "http://www.live555.com/liveMedia/public/live.2015.10.29.tar.gz"
  sha256 "05bb03b58c9a758a735a2c5bb0b993c5e157d7a60b08df49cc29619d02fbc962"

  bottle do
    cellar :any_skip_relocation
    sha256 "19ebd75fbe2409869df5c1c9a90c3ffd146bf8f329f223dc6ee251fa44d1a4fc" => :el_capitan
    sha256 "0c1083767885bf851959a9e74590f89b5d3a02b3c04965f3a9309162ec80bb34" => :yosemite
    sha256 "4b65fe1d10e54ee81c429768ae37e0d6836e1cf50fc3c6d168e86e82adfb952a" => :mavericks
  end

  option "32-bit"

  def install
    if build.build_32_bit? || !MacOS.prefer_64_bit?
      ENV.m32
      system "./genMakefiles", "macosx-32bit"
    else
      system "./genMakefiles", "macosx"
    end

    system "make", "PREFIX=#{prefix}", "install"

    # Move the testing executables out of the main PATH
    libexec.install Dir.glob(bin/"test*")
  end

  def caveats; <<-EOS.undent
    Testing executables have been placed in:
      #{libexec}
    EOS
  end
end
