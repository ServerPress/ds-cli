class Wireshark < Formula
  desc "Graphical network analyzer and capture tool"
  homepage "https://www.wireshark.org"
  url "https://www.wireshark.org/download/src/all-versions/wireshark-2.0.1.tar.bz2"
  mirror "https://1.eu.dl.wireshark.org/src/wireshark-2.0.1.tar.bz2"
  sha256 "c9bd07dd0d0045d6ca7537390a1afbcdf33716d193ea7d7084ae4f6c30b683ab"

  bottle do
    sha256 "adaeb1341d1292d42895c05425c16ae247dd8ebf7e2e5636cc4a95a54631f424" => :el_capitan
    sha256 "09cb81722bc6b6a5602581f10c7bcf6adf4e6fb20b00e9776d87fb75f498911b" => :yosemite
    sha256 "09ee4ca55d9cf8c393430180c32248945f8141eeaf58fa58bd23c9cb8088a1df" => :mavericks
  end

  head do
    url "https://code.wireshark.org/review/wireshark", :using => :git

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  option "with-gtk+3", "Build the wireshark command with gtk+3"
  option "with-gtk+", "Build the wireshark command with gtk+"
  option "with-qt", "Build the wireshark-qt command (can be used with or without either GTK option)"
  option "with-qt5", "Build the wireshark-qt command with qt5 (can be used with or without either GTK option)"
  option "with-headers", "Install Wireshark library headers for plug-in development"

  depends_on "pkg-config" => :build

  depends_on "glib"
  depends_on "gnutls"
  depends_on "libgcrypt"
  depends_on "d-bus"

  depends_on "geoip" => :recommended
  depends_on "c-ares" => :recommended

  depends_on "libsmi" => :optional
  depends_on "lua" => :optional
  depends_on "portaudio" => :optional
  depends_on "qt5" => :optional
  depends_on "qt" => :optional
  depends_on "gtk+3" => :optional
  depends_on "gtk+" => :optional
  depends_on "gnome-icon-theme" if build.with? "gtk+3"

  resource "libpcap" do
    url "http://www.tcpdump.org/release/libpcap-1.7.4.tar.gz"
    sha256 "7ad3112187e88328b85e46dce7a9b949632af18ee74d97ffc3f2b41fe7f448b0"
  end

  def install
    if MacOS.version <= :mavericks
      resource("libpcap").stage do
        system "./configure", "--prefix=#{libexec}/vendor",
                              "--enable-ipv6",
                              "--disable-universal"
        system "make", "install"
      end
      ENV.prepend_path "PATH", libexec/"vendor/bin"
      ENV.prepend "CFLAGS", "-I#{libexec}/vendor/include"
      ENV.prepend "LDFLAGS", "-L#{libexec}/vendor/lib"
    end

    no_gui = build.without?("gtk+3") && build.without?("qt") && build.without?("gtk+") && build.without?("qt5")

    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --with-gnutls
    ]

    args << "--disable-wireshark" if no_gui
    args << "--disable-gtktest" if build.without?("gtk+3") && build.without?("gtk+")
    args << "--with-gtk3" if build.with? "gtk+3"
    args << "--with-gtk2" if build.with? "gtk+"

    if build.with?("qt") || build.with?("qt5")
      args << "--with-qt"
    else
      args << "--with-qt=no"
    end

    if build.head?
      args << "--disable-warnings-as-errors"
      system "./autogen.sh"
    end

    system "./configure", *args
    system "make"
    ENV.deparallelize # parallel install fails
    system "make", "install"

    if build.with? "headers"
      (include/"wireshark").install Dir["*.h"]
      (include/"wireshark/epan").install Dir["epan/*.h"]
      (include/"wireshark/epan/crypt").install Dir["epan/crypt/*.h"]
      (include/"wireshark/epan/dfilter").install Dir["epan/dfilter/*.h"]
      (include/"wireshark/epan/dissectors").install Dir["epan/dissectors/*.h"]
      (include/"wireshark/epan/ftypes").install Dir["epan/ftypes/*.h"]
      (include/"wireshark/epan/wmem").install Dir["epan/wmem/*.h"]
      (include/"wireshark/wiretap").install Dir["wiretap/*.h"]
      (include/"wireshark/wsutil").install Dir["wsutil/*.h"]
    end
  end

  def caveats; <<-EOS.undent
    If your list of available capture interfaces is empty
    (default OS X behavior), try the following commands:

      curl https://bugs.wireshark.org/bugzilla/attachment.cgi?id=3373 -o ChmodBPF.tar.gz
      tar zxvf ChmodBPF.tar.gz
      open ChmodBPF/Install\\ ChmodBPF.app

    This adds a launch daemon that changes the permissions of your BPF
    devices so that all users in the 'admin' group - all users with
    'Allow user to administer this computer' turned on - have both read
    and write access to those devices.

    See bug report:
      https://bugs.wireshark.org/bugzilla/show_bug.cgi?id=3760
    EOS
  end

  test do
    system bin/"randpkt", "-b", "100", "-c", "2", "capture.pcap"
    output = shell_output("#{bin}/capinfos -Tmc capture.pcap")
    assert_equal "File name,Number of packets\ncapture.pcap,2\n", output
  end
end
