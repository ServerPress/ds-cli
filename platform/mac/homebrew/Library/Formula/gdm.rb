require "language/go"

class Gdm < Formula
  desc "Go Dependency Manager (gdm)"
  homepage "https://github.com/sparrc/gdm"
  url "https://github.com/sparrc/gdm/archive/v1.1.tar.gz"
  sha256 "dbe0530f85dc85db100b2a3d6270975247537683b4031c72ed5c377a90e10452"

  bottle do
    cellar :any_skip_relocation
    sha256 "a977218e8e6b0b7419b2b5fcb1ebd6977f4e0a56991258a442e4e0bc82239c76" => :el_capitan
    sha256 "0c49f92e76d91f2f303befa1467599a7f93bfbf03bc7cc194f178ca8222e4b90" => :yosemite
    sha256 "88716d7409276f28ccf4f3bdd30e16e0e511a496f1cd75fc9ab297fe5584e270" => :mavericks
  end

  depends_on "go"

  go_resource "golang.org/x/tools" do
    url "https://go.googlesource.com/tools.git",
    :revision => "b48dc8da98ae78c3d11f220e7d327304c84e623a"
  end

  def install
    ENV["GOPATH"] = buildpath
    mkdir_p buildpath/"src/github.com/sparrc"
    ln_sf buildpath, buildpath/"src/github.com/sparrc/gdm"

    Language::Go.stage_deps resources, buildpath/"src"

    cd "src/github.com/sparrc/gdm" do
      system "go", "build", "-o", bin/"gdm",
             "-ldflags", "-X main.Version=#{version}"
    end
  end

  test do
    ENV["GOPATH"] = testpath
    assert_match "#{version}", shell_output("#{bin}/gdm version")
    assert_match "#{testpath}", shell_output("gdm save")
    system "gdm", "restore"
  end
end
