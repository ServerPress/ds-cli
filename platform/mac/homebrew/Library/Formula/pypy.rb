class Pypy < Formula
  desc "Implementation of Python 2 in Python"
  homepage "http://pypy.org/"
  url "https://bitbucket.org/pypy/pypy/downloads/pypy-4.0.1-src.tar.bz2"
  sha256 "29f5aa6ba17b34fd980e85172dfeb4086fdc373ad392b1feff2677d2d8aea23c"

  bottle do
    cellar :any
    sha256 "fc1f5dde107fd9887c49bfbbe6207db6623e162acae98786c4dc37d4c661753d" => :el_capitan
    sha256 "a299cfdc148e56f982b4573482e589c62c7ae6630538db2d024c8076f0d9252a" => :yosemite
    sha256 "80225ff2367f678288e2790cc0c265570209f41a2d2fc8f60655d7d5463a08fb" => :mavericks
  end

  depends_on :arch => :x86_64
  depends_on "pkg-config" => :build
  depends_on "gdbm" => :recommended
  depends_on "sqlite" => :recommended
  depends_on "openssl"

  option "without-bootstrap", "Translate Pypy with system Python instead of " \
                              "downloading a Pypy binary distribution to " \
                              "perform the translation (adds 30-60 minutes " \
                              "to build)"

  resource "bootstrap" do
    url "https://bitbucket.org/pypy/pypy/downloads/pypy-2.5.0-osx64.tar.bz2"
    sha256 "30b392b969b54cde281b07f5c10865a7f2e11a229c46b8af384ca1d3fe8d4e6e"
  end

  resource "setuptools" do
    url "https://pypi.python.org/packages/source/s/setuptools/setuptools-19.4.tar.gz"
    sha256 "214bf29933f47cf25e6faa569f710731728a07a19cae91ea64f826051f68a8cf"
  end

  resource "pip" do
    url "https://pypi.python.org/packages/source/p/pip/pip-8.0.2.tar.gz"
    sha256 "46f4bd0d8dfd51125a554568d646fe4200a3c2c6c36b9f2d06d2212148439521"
  end

  # https://bugs.launchpad.net/ubuntu/+source/gcc-4.2/+bug/187391
  fails_with :gcc

  def install
    # Having PYTHONPATH set can cause the build to fail if another
    # Python is present, e.g. a Homebrew-provided Python 2.x
    # See https://github.com/Homebrew/homebrew/issues/24364
    ENV["PYTHONPATH"] = ""
    ENV["PYPY_USESSION_DIR"] = buildpath

    python = "python"
    if build.with?("bootstrap") && OS.mac? && MacOS.preferred_arch == :x86_64
      resource("bootstrap").stage buildpath/"bootstrap"
      python = buildpath/"bootstrap/bin/pypy"
    end

    cd "pypy/goal" do
      system python, buildpath/"rpython/bin/rpython",
             "-Ojit", "--shared", "--cc", ENV.cc, "--verbose",
             "--make-jobs", ENV.make_jobs, "targetpypystandalone.py"
    end

    libexec.mkpath
    cd "pypy/tool/release" do
      package_args = %w[--archive-name pypy --targetdir . --nostrip]
      package_args << "--without-gdbm" if build.without? "gdbm"
      system python, "package.py", *package_args
      system *%W[tar -C #{libexec} --strip-components 1 -xzf pypy.tar.bz2]
    end

    (libexec/"lib").install libexec/"bin/libpypy-c.dylib"
    system *%W[install_name_tool -change @rpath/libpypy-c.dylib #{libexec}/lib/libpypy-c.dylib #{libexec}/bin/pypy]

    # The PyPy binary install instructions suggest installing somewhere
    # (like /opt) and symlinking in binaries as needed. Specifically,
    # we want to avoid putting PyPy's Python.h somewhere that configure
    # scripts will find it.
    bin.install_symlink libexec/"bin/pypy"
    lib.install_symlink libexec/"lib/libpypy-c.dylib"
  end

  def post_install
    # Post-install, fix up the site-packages and install-scripts folders
    # so that user-installed Python software survives minor updates, such
    # as going from 1.7.0 to 1.7.1.

    # Create a site-packages in the prefix.
    prefix_site_packages.mkpath

    # Symlink the prefix site-packages into the cellar.
    libexec.install_symlink prefix_site_packages

    # Tell distutils-based installers where to put scripts
    scripts_folder.mkpath
    (distutils+"distutils.cfg").atomic_write <<-EOF.undent
      [install]
      install-scripts=#{scripts_folder}
    EOF

    %w[setuptools pip].each do |pkg|
      resource(pkg).stage do
        system bin/"pypy", "-s", "setup.py", "--no-user-cfg", "install",
               "--force", "--verbose"
      end
    end

    # Symlinks to easy_install_pypy and pip_pypy
    bin.install_symlink scripts_folder/"easy_install" => "easy_install_pypy"
    bin.install_symlink scripts_folder/"pip" => "pip_pypy"

    # post_install happens after linking
    %w[easy_install_pypy pip_pypy].each { |e| (HOMEBREW_PREFIX/"bin").install_symlink bin/e }
  end

  def caveats; <<-EOS.undent
    A "distutils.cfg" has been written to:
      #{distutils}
    specifying the install-scripts folder as:
      #{scripts_folder}

    If you install Python packages via "pypy setup.py install", easy_install_pypy,
    or pip_pypy, any provided scripts will go into the install-scripts folder
    above, so you may want to add it to your PATH *after* #{HOMEBREW_PREFIX}/bin
    so you don't overwrite tools from CPython.

    Setuptools and pip have been installed, so you can use easy_install_pypy and
    pip_pypy.
    To update setuptools and pip between pypy releases, run:
        pip_pypy install --upgrade pip setuptools

    See: https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/Homebrew-and-Python.md
    EOS
  end

  # The HOMEBREW_PREFIX location of site-packages
  def prefix_site_packages
    HOMEBREW_PREFIX+"lib/pypy/site-packages"
  end

  # Where setuptools will install executable scripts
  def scripts_folder
    HOMEBREW_PREFIX+"share/pypy"
  end

  # The Cellar location of distutils
  def distutils
    libexec+"lib-python/2.7/distutils"
  end

  test do
    system bin/"pypy", "-c", "print('Hello, world!')"
    system scripts_folder/"pip", "list"
  end
end
