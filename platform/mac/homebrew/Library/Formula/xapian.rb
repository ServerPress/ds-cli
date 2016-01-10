class Xapian < Formula
  desc "C++ search engine library with many bindings"
  homepage "http://xapian.org"
  url "http://oligarchy.co.uk/xapian/1.2.21/xapian-core-1.2.21.tar.xz"
  sha256 "63f48758fbd13fa8456dd4cf9bf3ec35a096e4290f14a51ac7df23f78c162d3f"

  bottle do
    cellar :any
    sha256 "cf95639064497cc1feb65e37d229fba087a1073eea30a75059fa71781b6049e1" => :el_capitan
    sha256 "a9034d7ccda68338fcbc1031b03dd839a4e3136b88419e4405f0c857b736ad5c" => :yosemite
    sha256 "3178b70875da0811ea384c862b57f89c975cf932b12cdf22111c5ac584650bde" => :mavericks
  end

  option "with-java", "Java bindings"
  option "with-php", "PHP bindings"
  option "with-ruby", "Ruby bindings"

  deprecated_option "java" => "with-java"
  deprecated_option "php" => "with-php"
  deprecated_option "ruby" => "with-ruby"

  depends_on :python => :optional

  resource "bindings" do
    url "http://oligarchy.co.uk/xapian/1.2.21/xapian-bindings-1.2.21.tar.xz"
    sha256 "28a39247ac875be2dc1386c273167aab5c9949227c1070b65ca8de603c06d546"
  end

  skip_clean :la

  def install
    build_binds = build.with?("ruby") || build.with?("python") || build.with?("java") || build.with?("php")

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"

    if build_binds
      resource("bindings").stage do
        args = %W[
          --disable-dependency-tracking
          --prefix=#{prefix}
          XAPIAN_CONFIG=#{bin}/xapian-config
          --without-csharp
          --without-tcl
        ]

        if build.with? "java"
          args << "--with-java"
        else
          args << "--without-java"
        end

        if build.with? "ruby"
          ruby_site = lib/"ruby/site_ruby"
          ENV["RUBY_LIB"] = ENV["RUBY_LIB_ARCH"] = ruby_site
          args << "--with-ruby"
        else
          args << "--without-ruby"
        end

        if build.with? "python"
          (lib/"python2.7/site-packages").mkpath
          ENV["PYTHON_LIB"] = lib/"python2.7/site-packages"
          # configure looks for python2 and system python doesn't install one
          ENV["PYTHON"] = which "python"
          args << "--with-python"
        else
          args << "--without-python"
        end

        if build.with? "php"
          extension_dir = lib/"php/extensions"
          extension_dir.mkpath
          args << "--with-php" << "PHP_EXTENSION_DIR=#{extension_dir}"
        else
          args << "--without-php"
        end

        system "./configure", *args
        system "make", "install"
      end
    end
  end

  def caveats
    if build.with? "ruby"
      <<-EOS.undent
        You may need to add the Ruby bindings to your RUBYLIB from:
          #{HOMEBREW_PREFIX}/lib/ruby/site_ruby

      EOS
    end
  end

  test do
    # This test is awful. Feel free to improve it.
    system bin/"xapian-config", "--libs"
  end
end
