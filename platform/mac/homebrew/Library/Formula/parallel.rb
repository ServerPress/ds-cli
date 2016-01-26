class Parallel < Formula
  desc "GNU parallel shell command"
  homepage "https://savannah.gnu.org/projects/parallel/"
  url "http://ftpmirror.gnu.org/parallel/parallel-20151222.tar.bz2"
  mirror "https://ftp.gnu.org/gnu/parallel/parallel-20151222.tar.bz2"
  sha256 "ae927c260fb86c24e0a2717d3b214996a9547d1a2be4ff3bfebd9f23b5bd9f0d"
  head "http://git.savannah.gnu.org/r/parallel.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "00bab4fc10a58fe7d65be554ea3e7faae2621924ba207252f154e53f874a4706" => :el_capitan
    sha256 "4cc4ded92bf8a0e13a62c2dfa5b73c7b8adafffaf959b2d7d5885ef36644bc76" => :yosemite
    sha256 "3e57cb2666afc3e6824d0debf1fa4549a2ca1731c96c8c405a87e7215259d2bf" => :mavericks
  end

  conflicts_with "moreutils", :because => "both install a 'parallel' executable."

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    assert_equal "test\ntest\n",
                 shell_output("#{bin}/parallel --will-cite echo ::: test test")
  end
end
