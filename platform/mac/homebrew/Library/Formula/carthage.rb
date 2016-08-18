class Carthage < Formula
  desc "Decentralized dependency manager for Cocoa"
  homepage "https://github.com/Carthage/Carthage"
  url "https://github.com/Carthage/Carthage.git", :tag => "0.11",
                                                  :revision => "38cafc2b60df1d4a6d22cd26bdad865d46012414",
                                                  :shallow => false
  head "https://github.com/Carthage/Carthage.git", :shallow => false

  bottle do
    cellar :any
    sha256 "cde78d8aa8b7e920b4d97c4076344c8bf86303e70666f027e4c70426710e1f22" => :el_capitan
    sha256 "767ce68adfdc5aa770c1a8a036428f2db2a9d06b3ab692525ea99968578eccf8" => :yosemite
  end

  depends_on :xcode => ["7.1", :build]

  def install
    system "make", "prefix_install", "PREFIX=#{prefix}"
  end

  test do
    (testpath/"Cartfile").write 'github "jspahrsummers/xcconfigs"'
    system "#{bin}/carthage", "update"
  end
end
