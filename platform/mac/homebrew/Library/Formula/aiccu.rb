class Aiccu < Formula
  desc "Automatic IPv6 Connectivity Client Utility"
  homepage "https://www.sixxs.net/tools/aiccu/"
  url "https://www.sixxs.net/archive/sixxs/aiccu/unix/aiccu_20070115.tar.gz"
  sha256 "2260f426c13471169ccff8cb4a3908dc5f79fda18ddb6a55363e7824e6c4c760"

  bottle do
    cellar :any_skip_relocation
    sha256 "c49bc224f4ab5bc469a55c9236a74efb585b176f5addff1853d17d753cb3551c" => :el_capitan
    sha256 "00d05929df3a1951fa3c28108071e0dcc88236a37dfb89af37af66142b1746bf" => :yosemite
    sha256 "31117537770464542e1186d32032aba90507a11bd4e41c9f46aa717515e8e3cf" => :mavericks
  end

  # Patches per MacPorts
  patch :DATA

  def install
    inreplace "doc/aiccu.conf", "daemonize true", "daemonize false"
    system "make", "prefix=#{prefix}"
    system "make", "install", "prefix=#{prefix}"

    etc.install "doc/aiccu.conf"
  end

  plist_options :startup => true

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_sbin}/aiccu</string>
        <string>start</string>
        <string>#{etc}/aiccu.conf</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
    </dict>
    </plist>
    EOS
  end

  def caveats
    <<-EOS.undent
      You may also wish to install tuntap:

        The TunTap project provides kernel extensions for Mac OS X that allow
        creation of virtual network interfaces.

        http://tuntaposx.sourceforge.net/

      You can install tuntap with homebrew using brew install tuntap

      Unless it exists already, a aiccu.conf file has been written to:
        #{etc}/aiccu.conf

      Protect this file as it will contain your credentials.

      The 'aiccu' command will load this file by default unless told to use
      a different one.
    EOS
  end

  test do
    system "#{sbin}/aiccu", "version"
  end
end

__END__
diff --git a/Makefile b/Makefile
index 0e96136..78609bd 100644
--- a/Makefile
+++ b/Makefile
@@ -36,10 +36,11 @@ export DESTDIR
 CFLAGS=${RPM_OPT_FLAGS}

 # Destination Paths (relative to DESTDIR)
-dirsbin=/usr/sbin/
-dirbin=/usr/bin/
-diretc=/etc/
-dirdoc=/usr/share/doc/${PROJECT}/
+prefix=
+dirsbin=${prefix}/sbin/
+dirbin=${prefix}/bin/
+diretc=${prefix}/etc/
+dirdoc=${prefix}/share/doc/${PROJECT}/

 # Make sure the lower makefile also knows these
 export PROJECT
@@ -79,21 +80,13 @@ install: aiccu
	@echo "Configuration..."
	@mkdir -p ${DESTDIR}${diretc}
 ifeq ($(shell echo "A${RPM_BUILD_ROOT}"),A)
-	$(shell [ -f ${DESTDIR}${diretc}${PROJECT}.conf ] || cp -R doc/${PROJECT}.conf ${DESTDIR}${diretc}${PROJECT}.conf)
	@echo "Documentation..."
+	@cp doc/${PROJECT}.conf ${DESTDIR}${dirdoc}
	@cp doc/README ${DESTDIR}${dirdoc}
	@cp doc/LICENSE ${DESTDIR}${dirdoc}
	@cp doc/HOWTO  ${DESTDIR}${dirdoc}
-	@echo "Installing Debian-style init.d"
-	@mkdir -p ${DESTDIR}${diretc}init.d
-	@cp doc/${PROJECT}.init.debian ${DESTDIR}${diretc}init.d/${PROJECT}
-else
-	@echo "Installing Redhat-style init.d"
-	@mkdir -p ${DESTDIR}${diretc}init.d
-	@cp doc/${PROJECT}.init.rpm ${DESTDIR}${diretc}init.d/${PROJECT}
-	@cp doc/${PROJECT}.conf ${DESTDIR}${diretc}${PROJECT}.conf
 endif
-	@echo "Installation into ${DESTDIR}/ completed"
+	@echo "Installation into ${DESTDIR}${prefix}/ completed"

 help:
	@echo "$(PROJECT) - $(PROJECT_DESC)"
diff --git a/common/aiccu.h b/common/aiccu.h
index ef65000..5b2eb43 100755
--- a/common/aiccu.h
+++ b/common/aiccu.h
@@ -65,17 +65,17 @@
  * the data. Could be useful in the event
  * where we can't make contact to the main server
  */
-#define AICCU_CACHE	"/var/cache/aiccu.cache"
+#define AICCU_CACHE	"HOMEBREW_PREFIX/var/cache/aiccu.cache"

 /* The PID we are running as when daemonized */
-#define AICCU_PID	"/var/run/aiccu.pid"
+#define AICCU_PID	"HOMEBREW_PREFIX/var/run/aiccu.pid"

 /* AICCU Configuration file */
 #ifdef _WIN32
 /* GetWindowsDirectory() is used to figure out the directory to store the config */
 #define AICCU_CONFIG	"aiccu.conf"
 #else
-#define AICCU_CONFIG	"/etc/aiccu.conf"
+#define AICCU_CONFIG	"HOMEBREW_PREFIX/etc/aiccu.conf"
 #endif

 /* Inbound listen queue */
