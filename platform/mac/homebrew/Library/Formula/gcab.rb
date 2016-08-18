class Gcab < Formula
  desc "Windows installer (.MSI) tool"
  homepage "https://wiki.gnome.org/msitools"
  url "https://download.gnome.org/sources/gcab/0.4/gcab-0.4.tar.xz"
  sha256 "f907b16f1246fbde9397363d9c4ad2291f2a8a53dcd4f5979d3912bb856991b8"

  depends_on "intltool" => :build
  depends_on "pkg-config" => :build
  depends_on "vala" => :build
  depends_on "gettext"
  depends_on "glib"
  depends_on "gobject-introspection"

  # work around ld not understanding --version-script argument
  # upstream bug: https://bugzilla.gnome.org/show_bug.cgi?id=708257
  patch :DATA

  def install
    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end

__END__
diff --git a/Makefile.in b/Makefile.in
index 2264c17..7782d62 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -474,7 +474,7 @@ libgcab_1_0_la_CPPFLAGS = \
 libgcab_1_0_la_LIBADD = -lz $(GLIB_LIBS)
 libgcab_1_0_la_LDFLAGS = \
 	-version-info 0:0:0				\
-	-Wl,--version-script=${srcdir}/libgcab.syms	\
+	-Wl                                     	\
 	-no-undefined					\
 	$(NULL)

