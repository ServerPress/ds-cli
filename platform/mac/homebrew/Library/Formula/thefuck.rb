class Thefuck < Formula
  desc "Programatically correct mistyped console commands"
  homepage "https://github.com/nvbn/thefuck"
  url "https://pypi.python.org/packages/source/t/thefuck/thefuck-3.3.tar.gz"
  sha256 "f2e720d3147b259de2bb763f0854fbd2d12da70669bb3958f0dffffd34f95e81"

  head "https://github.com/nvbn/thefuck.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "9c21b012d0cca0b469fef8d45f487c5d30643095fe56beae8cdb031a5ad323f8" => :el_capitan
    sha256 "0af3c42bc8cbbdb9810e013f611f4c2b1a2877d07deef3425631c8c69b79d672" => :yosemite
    sha256 "4d5cea822835b513032699396bd39b174824c709ce353532e78302c731826c02" => :mavericks
  end

  depends_on :python if MacOS.version <= :snow_leopard

  resource "psutil" do
    url "https://pypi.python.org/packages/source/p/psutil/psutil-3.2.1.tar.gz"
    sha256 "7f6bea8bfe2e5cfffd0f411aa316e837daadced1893b44254bb9a38a654340f7"
  end

  resource "pathlib" do
    url "https://pypi.python.org/packages/source/p/pathlib/pathlib-1.0.1.tar.gz"
    sha256 "6940718dfc3eff4258203ad5021090933e5c04707d5ca8cc9e73c94a7894ea9f"
  end

  resource "colorama" do
    url "https://pypi.python.org/packages/source/c/colorama/colorama-0.3.3.tar.gz"
    sha256 "eb21f2ba718fbf357afdfdf6f641ab393901c7ca8d9f37edd0bee4806ffa269c"
  end

  resource "six" do
    url "https://pypi.python.org/packages/source/s/six/six-1.9.0.tar.gz"
    sha256 "e24052411fc4fbd1f672635537c3fc2330d9481b18c0317695b46259512c91d5"
  end

  resource "setuptools" do
    url "https://pypi.python.org/packages/source/s/setuptools/setuptools-18.2.tar.gz"
    sha256 "0994a58df27ea5dc523782a601357a2198b7493dcc99a30d51827a23585b5b1d"
  end

  resource "decorator" do
    url "https://pypi.python.org/packages/source/d/decorator/decorator-4.0.2.tar.gz"
    sha256 "1a089279d5de2471c47624d4463f2e5b3fc6a2cf65045c39bf714fc461a25206"
  end

  def install
    xy = Language::Python.major_minor_version "python"
    ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python#{xy}/site-packages"
    %w[setuptools pathlib psutil colorama six decorator].each do |r|
      resource(r).stage do
        system "python", *Language::Python.setup_install_args(libexec/"vendor")
      end
    end

    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python#{xy}/site-packages"
    system "python", *Language::Python.setup_install_args(libexec)

    bin.install Dir["#{libexec}/bin/*"]
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  def caveats; <<-EOS.undent
    Add the following to your .bash_profile, .bashrc or .zshrc:

      eval "$(thefuck --alias)"

    For other shells, check https://github.com/nvbn/thefuck/wiki/Shell-aliases
    EOS
  end

  test do
    ENV["THEFUCK_REQUIRE_CONFIRMATION"] = "false"
    assert_match /The Fuck #{version} using Python [0-9\.]+/, shell_output("#{bin}/thefuck --version 2>&1").chomp
    assert_match /.+TF_ALIAS.+thefuck.+/, shell_output("#{bin}/thefuck --alias").chomp
    assert_match /git branch/, shell_output("#{bin}/thefuck git branchh").chomp
    assert_match /echo ok/, shell_output("#{bin}/thefuck echho ok").chomp
    assert_match /^Seems like .+fuck.+ alias isn't configured.+/, shell_output("#{bin}/fuck").chomp
  end
end
