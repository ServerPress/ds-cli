class Libmpc < Formula
  desc "C library for the arithmetic of high precision complex numbers"
  homepage "http://multiprecision.org"
  url "http://ftpmirror.gnu.org/mpc/mpc-1.0.3.tar.gz"
  mirror "http://multiprecision.org/mpc/download/mpc-1.0.3.tar.gz"
  sha256 "617decc6ea09889fb08ede330917a00b16809b8db88c29c31bfbb49cbf88ecc3"

  bottle do
    cellar :any
    sha256 "04280215d9638c3e4dd0296cb1a0fe0e3e159088ebd59b6ab0c16585ada91f87" => :el_capitan
    sha256 "afc56d4ba864a701495e7a8787d53a6375e808fed19fc056a8afea417f924958" => :yosemite
    sha256 "8e20b94ef5014396801c5d3a99899cfd116e6f0e9873b239901f561bb9ff789d" => :mavericks
    sha256 "040e6c55e3b641a1c8775eeb7416d6f9e20698d8670dc51e81d8175abd05283a" => :mountain_lion
  end

  depends_on "gmp"
  depends_on "mpfr"

  def install
    args = [
      "--prefix=#{prefix}",
      "--disable-dependency-tracking",
      "--with-gmp=#{Formula["gmp"].opt_prefix}",
      "--with-mpfr=#{Formula["mpfr"].opt_prefix}"
    ]

    system "./configure", *args
    system "make"
    system "make", "check"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <mpc.h>

      int main()
      {
        mpc_t x;
        mpc_init2 (x, 256);
        mpc_clear (x);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-lgmp", "-lmpfr", "-lmpc", "-o", "test"
    system "./test"
  end
end
