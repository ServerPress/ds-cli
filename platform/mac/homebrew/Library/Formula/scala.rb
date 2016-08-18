class Scala < Formula
  desc "JVM-based programming language"
  homepage "http://www.scala-lang.org/"

  stable do
    url "http://www.scala-lang.org/files/archive/scala-2.11.7.tgz"
    sha256 "ffe4196f13ee98a66cf54baffb0940d29432b2bd820bd0781a8316eec22926d0"

    depends_on :java => "1.6+"

    resource "docs" do
      url "http://www.scala-lang.org/files/archive/scala-docs-2.11.7.zip"
      sha256 "90981bf388552465ce07761c8f991c13be332ee07e97ff44f4b8be278f489667"
    end

    resource "src" do
      url "https://github.com/scala/scala/archive/v2.11.7.tar.gz"
      sha256 "1679ee604bc4e881b0d325e164c39c02dcfa711d53cd3115f5a6c9676c5915ef"
    end
  end

  bottle do
    cellar :any_skip_relocation
    sha256 "dcc350cf8dcc527b283b52d81ce27f0ee19403f1b805c6de74cbbd1c00571483" => :el_capitan
    sha256 "abe3bdb7c49c2d8542731b5bff8ddd2b64b361e5fbc104217ca2f2423b73fbb9" => :yosemite
    sha256 "87619ccc086a0636f89fec974759ae952dc1979948567f7e7d6200b7be64dffc" => :mavericks
    sha256 "44c9502a3195a7cd25699162948b4eb80676547a24ed0a001520320d6a54aac7" => :mountain_lion
  end

  devel do
    url "http://www.scala-lang.org/files/archive/scala-2.12.0-M3.tgz"
    sha256 "67ee3394ff5f9a98f9579accc9e20e0c9911d6f0bce96d70cf63cbb676643802"
    version "2.12.0-M3"

    depends_on :java => "1.8+"

    resource "docs" do
      url "http://www.scala-lang.org/files/archive/scala-docs-2.12.0-M3.zip"
      sha256 "f5c5bc3635c08dde2e938b8051974404bb7126c27039753de337f7e3fa4e5844"
      version "2.12.0-M3"
    end

    resource "src" do
      url "https://github.com/scala/scala/archive/v2.12.0-M3.tar.gz"
      sha256 "104a5ec973bfc40bfd1cd1bbaeec43b767555367c65fa7880a615f2285550d70"
      version "2.12.0-M3"
    end
  end

  option "with-docs", "Also install library documentation"
  option "with-src", "Also install sources for IDE support"

  resource "completion" do
    url "https://raw.githubusercontent.com/scala/scala-dist/v2.11.4/bash-completion/src/main/resources/completion.d/2.9.1/scala"
    sha256 "95aeba51165ce2c0e36e9bf006f2904a90031470ab8d10b456e7611413d7d3fd"
  end

  def install
    rm_f Dir["bin/*.bat"]
    doc.install Dir["doc/*"]
    share.install "man"
    libexec.install "bin", "lib"
    bin.install_symlink Dir["#{libexec}/bin/*"]
    bash_completion.install resource("completion")
    doc.install resource("docs") if build.with? "docs"
    libexec.install resource("src").files("src") if build.with? "src"

    # Set up an IntelliJ compatible symlink farm in 'idea'
    idea = prefix/"idea"
    idea.install_symlink libexec/"src", libexec/"lib"
    idea.install_symlink doc => "doc"
  end

  def caveats; <<-EOS.undent
    To use with IntelliJ, set the Scala home to:
      #{opt_prefix}/idea
    EOS
  end

  test do
    file = testpath/"Test.scala"
    file.write <<-EOS.undent
      object Test {
        def main(args: Array[String]) {
          println(s"${2 + 2}")
        }
      }
    EOS

    out = shell_output("#{bin}/scala #{file}").strip
    # Shut down the compile server so as not to break Travis
    system bin/"fsc", "-shutdown"

    assert_equal "4", out
  end
end
