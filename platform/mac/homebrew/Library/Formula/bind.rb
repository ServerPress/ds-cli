class Bind < Formula
  desc "Implementation of the DNS protocols"
  homepage "https://www.isc.org/downloads/bind/"
  url "https://ftp.isc.org/isc/bind9/9.10.3-P2/bind-9.10.3-P2.tar.gz"
  mirror "https://fossies.org/linux/misc/dns/bind9/9.10.3-P2/bind-9.10.3-P2.tar.gz"
  version "9.10.3-P2"
  sha256 "4a6c1911ac0d4b6be635b63de3429b6c168ea244043f12bbc8a4eb3368fd6ecd"
  head "https://source.isc.org/git/bind9.git"

  bottle do
    sha256 "906b61df1c9ec5d4995dcc96c8a02a0c79d82119c4ec4219242885d482548367" => :el_capitan
    sha256 "5b2926cfaf6e33a0cf2cea54f5e93b41ebe932b70ca755f5d0239bd4f4264824" => :yosemite
    sha256 "45311a20a9a29025f6797e05591500ccae6ee33eff887fda89b9c02c109bade1" => :mavericks
  end

  depends_on "openssl"
  depends_on "json-c" => :optional

  def install
    ENV.libxml2
    # libxml2 appends one inc dir to CPPFLAGS but bind ignores CPPFLAGS
    ENV.append "CFLAGS", ENV.cppflags

    json = build.with?("json-c") ? "yes" : "no"
    system "./configure", "--prefix=#{prefix}",
                          "--enable-threads",
                          "--enable-ipv6",
                          "--with-openssl=#{Formula["openssl"].opt_prefix}",
                          "--with-libjson=#{json}"

    # From the bind9 README: "Do not use a parallel "make"."
    ENV.deparallelize
    system "make"
    system "make", "install"

    (buildpath+"named.conf").write named_conf
    system "#{sbin}/rndc-confgen", "-a", "-c", "#{buildpath}/rndc.key"
    etc.install "named.conf", "rndc.key"
  end

  def post_install
    (var+"log/named").mkpath

    # Create initial configuration/zone/ca files.
    # (Mirrors Apple system install from 10.8)
    unless (var+"named").exist?
      (var+"named").mkpath
      (var+"named/localhost.zone").write localhost_zone
      (var+"named/named.local").write named_local
    end
  end

  def named_conf; <<-EOS.undent
    //
    // Include keys file
    //
    include "#{etc}/rndc.key";

    // Declares control channels to be used by the rndc utility.
    //
    // It is recommended that 127.0.0.1 be the only address used.
    // This also allows non-privileged users on the local host to manage
    // your name server.

    //
    // Default controls
    //
    controls {
        inet 127.0.0.1 port 54 allow { any; }
        keys { "rndc-key"; };
    };

    options {
        directory "#{var}/named";
        /*
         * If there is a firewall between you and nameservers you want
         * to talk to, you might need to uncomment the query-source
         * directive below.  Previous versions of BIND always asked
         * questions using port 53, but BIND 8.1 uses an unprivileged
         * port by default.
         */
        // query-source address * port 53;
    };
    //
    // a caching only nameserver config
    //
    zone "localhost" IN {
        type master;
        file "localhost.zone";
        allow-update { none; };
    };

    zone "0.0.127.in-addr.arpa" IN {
        type master;
        file "named.local";
        allow-update { none; };
    };

    logging {
            category default {
                    _default_log;
            };

            channel _default_log  {
                    file "#{var}/log/named/named.log";
                    severity info;
                    print-time yes;
            };
    };
    EOS
  end

  def localhost_zone; <<-EOS.undent
    $TTL    86400
    $ORIGIN localhost.
    @            1D IN SOA    @ root (
                        42        ; serial (d. adams)
                        3H        ; refresh
                        15M        ; retry
                        1W        ; expiry
                        1D )        ; minimum

                1D IN NS    @
                1D IN A        127.0.0.1
    EOS
  end

  def named_local; <<-EOS.undent
    $TTL    86400
    @       IN      SOA     localhost. root.localhost.  (
                                          1997022700 ; Serial
                                          28800      ; Refresh
                                          14400      ; Retry
                                          3600000    ; Expire
                                          86400 )    ; Minimum
                  IN      NS      localhost.

    1       IN      PTR     localhost.
    EOS
  end

  plist_options :startup => true

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>EnableTransactions</key>
      <true/>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>RunAtLoad</key>
      <true/>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_sbin}/named</string>
        <string>-f</string>
        <string>-c</string>
        <string>#{etc}/named.conf</string>
      </array>
      <key>ServiceIPC</key>
      <false/>
    </dict>
    </plist>
    EOS
  end

  test do
    system bin/"dig", "-v"
    system bin/"dig", "brew.sh"
  end
end
