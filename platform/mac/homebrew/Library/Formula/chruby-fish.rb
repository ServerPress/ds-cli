class ChrubyFish < Formula
  desc "Thin wrapper around chruby to make it work with the Fish shell"
  homepage "https://github.com/JeanMertz/chruby-fish#readme"
  url "https://github.com/JeanMertz/chruby-fish/archive/v0.6.0.tar.gz"
  sha256 "9549a195bf2ffc2d613124f891253c85a1e17066fa100f5bf423537dffd7e6d8"
  head "https://github.com/JeanMertz/chruby-fish.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "cde63210e63e1d5a03eeac56d6b00a86edf295c0419598a7cccd2d241aa496e2" => :el_capitan
    sha256 "f98806017cb055f4e2c71efce426d7e57c22f0b0751310d87aad9aa2f2a9a8b1" => :yosemite
    sha256 "62da82999031b2d4ac9b4cf82e512c3509522db334e0144c46af87eb34ddff27" => :mavericks
  end

  depends_on "chruby" => :recommended

  def install
    system "make", "install", "PREFIX=#{prefix}"
  end
end
