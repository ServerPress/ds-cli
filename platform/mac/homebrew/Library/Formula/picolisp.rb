class Picolisp < Formula
  desc "Minimal Lisp with integrated database"
  homepage "http://picolisp.com/wiki/?home"
  url "http://software-lab.de/picoLisp-3.1.6.tgz"
  sha256 "8568b5b13002ff7ba35248dc31508e1579e96428c0cef90a2d47b4a5f875cc2c"

  def install
    src_dir = MacOS.prefer_64_bit? ? "src64" : "src"
    system "make", "-C", src_dir
    bin.install "bin/picolisp"
  end

  test do
    path = testpath/"hello.lisp"
    path.write '(prinl "Hello world") (bye)'
    assert_equal "Hello world\n", shell_output("#{bin}/picolisp #{path}")
  end
end
