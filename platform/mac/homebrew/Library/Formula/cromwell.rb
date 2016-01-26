class Cromwell < Formula
  desc "Workflow Execution Engine using Workflow Description Language"
  homepage "https://github.com/broadinstitute/cromwell"
  url "https://github.com/broadinstitute/cromwell/releases/download/0.16/cromwell-0.16.jar"
  sha256 "349d150af40db3e112f487ea609287e9b1fa2a39fc16b95d16231baa32679cab"

  head do
    url "https://github.com/broadinstitute/cromwell.git"
    depends_on "sbt" => :build
  end

  bottle :unneeded

  depends_on :java => "1.8+"
  depends_on "akka"

  def install
    if build.head?
      system "sbt", "assembly"
      libexec.install Dir["target/scala-*/cromwell-*.jar"][0]
      bin.write_jar_script Dir[libexec/"cromwell-*.jar"][0], "cromwell"
    else
      libexec.install "cromwell-#{version}.jar"
      bin.write_jar_script libexec/"cromwell-#{version}.jar", "cromwell"
    end
  end

  test do
    (testpath/"hello.wdl").write <<-EOS
      task hello {
        String name

        command {
          echo 'hello ${name}!'
        }
        output {
          File response = stdout()
        }
      }

      workflow test {
        call hello
      }
    EOS

    (testpath/"hello.json").write <<-EOS
      {
        "test.hello.name": "world"
      }
    EOS

    result = shell_output("#{bin}/cromwell run hello.wdl hello.json")

    assert_match /test\.hello\.response/, result
  end
end
