class RubyBuild < Formula
  desc "Install various Ruby versions and implementations"
  homepage "https://github.com/rbenv/ruby-build"
  url "https://github.com/rbenv/ruby-build/archive/v20151216.tar.gz"
  sha256 "90e63530134ff47a981d5875f8716ccfa5a235251231e7359bd2b8c147c335c1"

  bottle :unneeded

  head "https://github.com/rbenv/ruby-build.git"

  depends_on "autoconf" => [:recommended, :run]
  depends_on "pkg-config" => [:recommended, :run]
  depends_on "openssl" => :recommended

  def install
    ENV["PREFIX"] = prefix
    system "./install.sh"
  end

  test do
    system "#{bin}/ruby-build", "--definitions"
  end
end
