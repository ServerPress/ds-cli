class TeensyLoaderCli < Formula
  desc "Command-line integration for Teensy USB development boards"
  homepage "https://www.pjrc.com/teensy/loader_cli.html"
  url "https://www.pjrc.com/teensy/teensy_loader_cli.2.1.zip"
  sha256 "dafd040d6748b52e0d4a01846d4136f3354ca27ddc36a55ed00d0a0af0902d46"
  head "https://github.com/PaulStoffregen/teensy_loader_cli.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "6328eeb1ed51edb8527874bd7c0f1a45cdf4052f0c35863dd1a67b5e0644c57e" => :el_capitan
    sha256 "90d5b5bf9adbece0001da72b1881617406bb9eeb76ff97ad5989e779179f5590" => :yosemite
    sha256 "dcd10140babb4d2937ce376c89e9c24a2e8046d2cabdad2cfdbc2542afa14471" => :mavericks
  end

  def install
    ENV["OS"] = "MACOSX"
    ENV["SDK"] = MacOS.sdk_path || "/"
    system "make"
    bin.install "teensy_loader_cli"
  end

  test do
    output = shell_output("#{bin}/teensy_loader_cli 2>&1", 1)
    assert_match /<MCU> = atmega32u4 | at90usb162 | at90usb646 | at90usb1286/, output
  end
end
