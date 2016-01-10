class Weboob < Formula
  desc "Web Outside of Browsers"
  homepage "http://weboob.org/"
  url "https://symlink.me/attachments/download/289/weboob-1.0.tar.gz"
  sha256 "2500823b6de62161d4da11382181f5def0d91823b23cebd9a470479714844068"
  head "git://git.symlink.me/pub/weboob/stable.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "65149686e5324c2899c254c20b84eace15541fef0bbdfacb73c4c27cf3657438" => :el_capitan
    sha256 "5264b1509bc30f59dcbc4428afb87eb47aa26f10a6d42e877851b718509c32f8" => :yosemite
    sha256 "fbd9aad5e5c443e01da7047d84d3989c015cdb9b763a4855d357389c2f97278b" => :mavericks
  end

  depends_on :python if MacOS.version <= :snow_leopard
  depends_on "libyaml"
  depends_on :gpg
  depends_on "pyqt"

  resource "termcolor" do
    url "https://pypi.python.org/packages/source/t/termcolor/termcolor-1.1.0.tar.gz"
    sha256 "1d6d69ce66211143803fbc56652b41d73b4a400a2891d7bf7a1cdf4c02de613b"
  end

  resource "requests" do
    url "https://pypi.python.org/packages/source/r/requests/requests-2.7.0.tar.gz"
    sha256 "398a3db6d61899d25fd4a06c6ca12051b0ce171d705decd7ed5511517b4bb93d"
  end

  resource "mechanize" do
    url "https://pypi.python.org/packages/source/m/mechanize/mechanize-0.2.5.tar.gz"
    sha256 "2e67b20d107b30c00ad814891a095048c35d9d8cb9541801cebe85684cc84766"
  end

  resource "prettytable" do
    url "https://pypi.python.org/packages/source/P/PrettyTable/prettytable-0.7.2.tar.bz2"
    sha256 "853c116513625c738dc3ce1aee148b5b5757a86727e67eff6502c7ca59d43c36"
  end

  def install
    ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python2.7/site-packages"
    resources.each do |r|
      r.stage do
        system "python", *Language::Python.setup_install_args(libexec/"vendor")
      end
    end

    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python2.7/site-packages"
    system "python", *Language::Python.setup_install_args(libexec)

    bin.install Dir[libexec/"bin/*"]
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    system "#{bin}/weboob-config", "update"
    system "#{bin}/weboob-config", "applications"
  end
end
