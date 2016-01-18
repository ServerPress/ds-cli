class Bazel < Formula
  desc "Google's own build tool"
  homepage "http://bazel.io/"
  url "https://github.com/bazelbuild/bazel/archive/0.1.3.tar.gz"
  sha256 "5ba3e69b0867e00c3c765b499a5e836db791e3f2f5112f5684782eef5bab0218"

  bottle do
    cellar :any_skip_relocation
    sha256 "fe665d9ff99da2a40531106ad78cbe9ac41bfeacc17822280960aa86eea23a01" => :el_capitan
    sha256 "e1cefe27d4eaa65a42578d0872b6936bb0670d03f013e790da4dbda27449c6b1" => :yosemite
    sha256 "333a3699765ced173ece8d9f355d9cba8b9007de4a67c5dacb88511ec3bc7774" => :mavericks
  end

  depends_on :java => "1.8+"

  def install
    inreplace "src/main/cpp/blaze_startup_options.cc",
      "/etc/bazel.bazelrc",
      "#{etc}/bazel/bazel.bazelrc"

    ENV["EMBED_LABEL"] = "#{version}-homebrew"

    system "./compile.sh"

    (prefix/"base_workspace").mkdir
    cp_r Dir["base_workspace/*"], (prefix/"base_workspace"), :dereference_root => true
    bin.install "output/bazel" => "bazel"
    (prefix/"etc/bazel.bazelrc").write <<-EOS.undent
      build --package_path=%workspace%:#{prefix}/base_workspace
      query --package_path=%workspace%:#{prefix}/base_workspace
      fetch --package_path=%workspace%:#{prefix}/base_workspace
    EOS
    (etc/"bazel").install prefix/"etc/bazel.bazelrc"
  end

  test do
    touch testpath/"WORKSPACE"

    (testpath/"ProjectRunner.java").write <<-EOS.undent
      public class ProjectRunner {
        public static void main(String args[]) {
          System.out.println("Hi!");
        }
      }
    EOS

    (testpath/"BUILD").write <<-EOS.undent
      java_binary(
        name = "bazel-test",
        srcs = glob(["*.java"]),
        main_class = "ProjectRunner",
      )
    EOS

    system "#{bin}/bazel", "build", "//:bazel-test"
    system "bazel-bin/bazel-test"
  end
end
