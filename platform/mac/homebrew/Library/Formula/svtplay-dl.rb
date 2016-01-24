class SvtplayDl < Formula
  desc "Download videos from http://svtplay.se"
  homepage "https://svtplay-dl.se"
  url "https://pypi.python.org/packages/source/s/svtplay-dl/svtplay-dl-0.30.2016.1.10.tar.gz"
  sha256 "0f043c83f8e1619d5d37ca44283416c3839df622e638872ce98db75ba9fb0ab6"

  bottle do
    cellar :any
    sha256 "cb19a87fe1f10921c4a5d687730df31a5573d411db21b687e5429055ce241f11" => :el_capitan
    sha256 "ee0f3cd942da6daada70ee615aa7ac9e122f94317b7dadf634685992c20e1525" => :yosemite
    sha256 "715638ac542ce6f7e240b79b86493d2fa78864d624e23c02346e1cd849b69366" => :mavericks
  end

  # for request security
  resource "cffi" do
    url "https://pypi.python.org/packages/source/c/cffi/cffi-1.4.2.tar.gz"
    sha256 "8f1d177d364ea35900415ae24ca3e471be3d5334ed0419294068c49f45913998"
  end

  resource "cryptography" do
    url "https://pypi.python.org/packages/source/c/cryptography/cryptography-1.1.2.tar.gz"
    sha256 "7f51459f84d670444275e615839f4542c93547a12e938a0a4906dafe5f7de153"
  end

  resource "enum34" do
    url "https://pypi.python.org/packages/source/e/enum34/enum34-1.1.2.tar.gz"
    sha256 "2475d7fcddf5951e92ff546972758802de5260bf409319a9f1934e6bbc8b1dc7"
  end

  resource "idna" do
    url "https://pypi.python.org/packages/source/i/idna/idna-2.0.tar.gz"
    sha256 "16199aad938b290f5be1057c0e1efc6546229391c23cea61ca940c115f7d3d3b"
  end

  resource "ndg-httpsclient" do
    url "https://pypi.python.org/packages/source/n/ndg-httpsclient/ndg_httpsclient-0.4.0.tar.gz"
    sha256 "e8c155fdebd9c4bcb0810b4ed01ae1987554b1ee034dd7532d7b8fdae38a6274"
  end

  resource "pyasn1" do
    url "https://pypi.python.org/packages/source/p/pyasn1/pyasn1-0.1.9.tar.gz"
    sha256 "853cacd96d1f701ddd67aa03ecc05f51890135b7262e922710112f12a2ed2a7f"
  end

  resource "pycparser" do
    url "https://pypi.python.org/packages/source/p/pycparser/pycparser-2.14.tar.gz"
    sha256 "7959b4a74abdc27b312fed1c21e6caf9309ce0b29ea86b591fd2e99ecdf27f73"
  end

  resource "requests" do
    url "https://pypi.python.org/packages/source/r/requests/requests-2.9.1.tar.gz"
    sha256 "c577815dd00f1394203fc44eb979724b098f88264a9ef898ee45b8e5e9cf587f"
  end

  resource "six" do
    url "https://pypi.python.org/packages/source/s/six/six-1.10.0.tar.gz"
    sha256 "105f8d68616f8248e24bf0e9372ef04d3cc10104f1980f54d57b2ce73a5ad56a"
  end

  ########

  resource "pycrypto" do
    url "https://pypi.python.org/packages/source/p/pycrypto/pycrypto-2.6.1.tar.gz"
    sha256 "f2ce1e989b272cfcb677616763e0a2e7ec659effa67a88aa92b3a65528f60a3c"
  end

  depends_on "rtmpdump"

  def install
    ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python2.7/site-packages"
    resources.each do |r|
      r.stage do
        system "python", *Language::Python.setup_install_args(libexec/"vendor")
      end
    end

    # ndg is a namespace package and .pth files aren't read from our
    # vendor site-packages
    touch libexec/"vendor/lib/python2.7/site-packages/ndg/__init__.py"

    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python2.7/site-packages"
    system "python", *Language::Python.setup_install_args(libexec)

    bin.install Dir[libexec/"bin/*"]
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end
end
