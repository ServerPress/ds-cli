class Nvi < Formula
  desc "44BSD re-implementation of vi"
  homepage "https://sites.google.com/a/bostic.com/keithbostic/vi/"
  url "https://mirrors.ocf.berkeley.edu/debian/pool/main/n/nvi/nvi_1.81.6.orig.tar.gz"
  sha256 "8bc348889159a34cf268f80720b26f459dbd723b5616107d36739d007e4c978d"

  depends_on "berkeley-db4"

  # Patches per MacPorts
  # The first corrects usage of BDB flags.
  patch :p0 do
    url "https://raw.githubusercontent.com/Homebrew/patches/8ef45e8b/nvi/patch-common__db.h"
    sha256 "d6c67a129cec0108a0c90fd649d79de65099dc627b10967a1fad51656f519800"
  end

  patch :p0 do
    url "https://raw.githubusercontent.com/Homebrew/patches/8ef45e8b/nvi/patch-dist__port.h.in"
    sha256 "674adb27810da8f6342ffc912a54375af0ed7769bfa524dce01600165f78a63b"
  end

  patch :p0 do
    url "https://raw.githubusercontent.com/Homebrew/patches/8ef45e8b/nvi/patch-ex_script.c.diff"
    sha256 "742c4578319ddc07b0b86482b4f2b86125026f200749e07c6d2ac67976204728"
  end

  def install
    cd "dist" do
      system "./configure", "--prefix=#{prefix}",
                            "--program-prefix=n",
                            "--disable-dependency-tracking"
      system "make"
      ENV.j1
      system "make", "install"
    end
  end
end
