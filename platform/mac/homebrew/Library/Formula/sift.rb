require "language/go"

class Sift < Formula
  desc "Fast and powerful open source alternative to grep"
  homepage "https://sift-tool.org"
  url "https://github.com/svent/sift/archive/v0.7.0.tar.gz"
  sha256 "a47a771047cb54f8374111d26e2bcb65a9f551613bd2bb4d56272361033e9bfc"

  bottle do
    cellar :any_skip_relocation
    sha256 "aa4d8be0f1d8c1f6f0c4d7563c7df7c48679a60ccf889d29b6b97b264b52255e" => :el_capitan
    sha256 "c4d7102ac05e7fff864278d7be840326a17873f9fd71a62cec71868eefc5737f" => :yosemite
    sha256 "1612e20741c909a12c4da5e5f1cb15ff45b609b864856871ba48cc3dad8c2a84" => :mavericks
  end

  depends_on "go" => :build

  go_resource "github.com/svent/go-flags" do
    url "https://github.com/svent/go-flags.git", :revision => "4bcbad344f0318adaf7aabc16929701459009aa3"
  end

  go_resource "github.com/svent/go-nbreader" do
    url "https://github.com/svent/go-nbreader.git", :revision => "7cef48da76dca6a496faa7fe63e39ed665cbd219"
  end

  go_resource "github.com/svent/sift" do
    url "https://github.com/svent/sift.git", :revision => "865998a4d2d5579a1a67fb9a0282250615667792"
  end

  go_resource "golang.org/x/crypto" do
    url "https://go.googlesource.com/crypto.git", :revision => "552e9d568fde9701ea1944fb01c8aadaceaa7353"
  end

  def install
    ENV["GOPATH"] = buildpath

    Language::Go.stage_deps resources, buildpath/"src"

    system "go", "build", "-o", bin/"sift"
  end

  test do
    (testpath/"test.txt").write "where is foo"
    assert_match(/where is foo/, shell_output("#{bin/"sift"} foo #{testpath}"))
  end
end
