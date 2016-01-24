require "language/go"

class DockerMachineDriverXhyve < Formula
  desc "Docker Machine driver for xhyve"
  homepage "https://github.com/zchee/docker-machine-driver-xhyve"
  url "https://github.com/zchee/docker-machine-driver-xhyve/archive/v0.2.2.tar.gz"
  sha256 "bdf43f7657c08974a752bceec69840d3025d6f6442a79ebbd3ff4c3453fef04e"

  head "https://github.com/zchee/docker-machine-driver-xhyve.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "d6550fd4f152d40760e7e2ab008b6a376aeeb05c1e81fb1dc29997c028b10075" => :el_capitan
    sha256 "8806ff664735c5a5ea06e0ab675d8f47bea87c0e42fcc9219a3e212e1bdc17c8" => :yosemite
  end

  depends_on :macos => :yosemite
  depends_on "go" => :build
  depends_on "docker-machine"

  def install
    (buildpath/"gopath/src/github.com/zchee/docker-machine-driver-xhyve").install Dir["{*,.git,.gitignore}"]

    ENV["GOPATH"] = "#{buildpath}/gopath"
    ENV["GO15VENDOREXPERIMENT"] = "1"

    cd buildpath/"gopath/src/github.com/zchee/docker-machine-driver-xhyve" do
      if build.head?
        git_hash = `git rev-parse --short HEAD --quiet`.chomp
        git_hash = " HEAD-#{git_hash}"
      end
      system "go", "build", "-o", bin/"docker-machine-driver-xhyve",
      "-ldflags",
      "'-w -s'",
      "-ldflags",
      "-X 'github.com/zchee/docker-machine-driver-xhyve/xhyve.GitCommit=Homebrew#{git_hash}'",
      "./main.go"
    end
  end

  test do
    assert_match "xhyve-memory-size",
    shell_output("#{Formula["docker-machine"].bin}/docker-machine create --driver xhyve -h")
  end
end
