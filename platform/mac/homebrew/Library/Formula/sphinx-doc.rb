class SphinxDoc < Formula
  desc "Tool to create intelligent and beautiful documentation"
  homepage "http://sphinx-doc.org"
  url "https://pypi.python.org/packages/source/S/Sphinx/Sphinx-1.3.4.tar.gz"
  sha256 "8aacc3f34aa758751fdb44ab9238eab024c66b57d67200f9a35efebf0e368057"

  bottle do
    cellar :any_skip_relocation
    sha256 "820ce4f976e674c5cc9d81502951653cbfd317136ce4e859137f08d7d8f4af53" => :el_capitan
    sha256 "2a4d32e89f808ad2569f8ab9ecbfdc90dc71065b4b7a97be1aa0e2259067437b" => :yosemite
    sha256 "4500a7bbfdeb1748646988b515487265d602f6b1b5104936c5d70f993a33dfae" => :mavericks
  end

  keg_only <<-EOS.undent
    This formula is mainly used internally by other formulae.
    Users are advised to use `pip` to install sphinx-doc.
  EOS

  depends_on :python if MacOS.version <= :snow_leopard

  resource "alabaster" do
    url "https://pypi.python.org/packages/source/a/alabaster/alabaster-0.7.7.tar.gz"
    sha256 "f416a84e0d0ddbc288f6b8f2c276d10b40ca1238562cd9ed5a751292ec647b71"
  end

  resource "Babel" do
    url "https://pypi.python.org/packages/source/B/Babel/Babel-2.2.0.tar.gz"
    sha256 "d8cb4c0e78148aee89560f9fe21587aa57739c975bb89ff66b1e842cc697428f"
  end

  resource "docutils" do
    url "https://pypi.python.org/packages/source/d/docutils/docutils-0.12.tar.gz"
    sha256 "c7db717810ab6965f66c8cf0398a98c9d8df982da39b4cd7f162911eb89596fa"
  end

  resource "Jinja2" do
    url "https://pypi.python.org/packages/source/J/Jinja2/Jinja2-2.8.tar.gz"
    sha256 "bc1ff2ff88dbfacefde4ddde471d1417d3b304e8df103a7a9437d47269201bf4"
  end

  resource "MarkupSafe" do
    url "https://pypi.python.org/packages/source/M/MarkupSafe/MarkupSafe-0.23.tar.gz"
    sha256 "a4ec1aff59b95a14b45eb2e23761a0179e98319da5a7eb76b56ea8cdc7b871c3"
  end

  resource "Pygments" do
    url "https://pypi.python.org/packages/source/P/Pygments/Pygments-2.1.tar.gz"
    sha256 "13a0ef5fafd7b16cf995bc28fe7aab0780dab1b2fda0fc89e033709af8b8a47b"
  end

  resource "pytz" do
    url "https://pypi.python.org/packages/source/p/pytz/pytz-2015.7.tar.bz2"
    sha256 "fbd26746772c24cb93c8b97cbdad5cb9e46c86bbdb1b9d8a743ee00e2fb1fc5d"
  end

  resource "six" do
    url "https://pypi.python.org/packages/source/s/six/six-1.10.0.tar.gz"
    sha256 "105f8d68616f8248e24bf0e9372ef04d3cc10104f1980f54d57b2ce73a5ad56a"
  end

  resource "snowballstemmer" do
    url "https://pypi.python.org/packages/source/s/snowballstemmer/snowballstemmer-1.2.1.tar.gz"
    sha256 "919f26a68b2c17a7634da993d91339e288964f93c274f1343e3bbbe2096e1128"
  end

  resource "sphinx_rtd_theme" do
    url "https://pypi.python.org/packages/source/s/sphinx_rtd_theme/sphinx_rtd_theme-0.1.9.tar.gz"
    sha256 "273846f8aacac32bf9542365a593b495b68d8035c2e382c9ccedcac387c9a0a1"
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
    system bin/"sphinx-quickstart", "-pPorject", "-aAuthor", "-v1.0", "-q"
    system bin/"sphinx-build", testpath, testpath/"build"
    assert File.exist?("build/index.html")
  end
end
