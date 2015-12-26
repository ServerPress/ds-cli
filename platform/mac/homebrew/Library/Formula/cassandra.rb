class Cassandra < Formula
  desc "Eventually consistent, distributed key-value store"
  homepage "https://cassandra.apache.org"
  url "https://www.apache.org/dyn/closer.cgi?path=/cassandra/2.2.3/apache-cassandra-2.2.3-bin.tar.gz"
  mirror "https://archive.apache.org/dist/cassandra/2.2.3/apache-cassandra-2.2.3-bin.tar.gz"
  sha256 "47bc96319d158e051670d067e01c736e6fff1f39b9aeb58ed1d906eec4e6f55e"

  bottle do
    sha256 "d957fb88a54b729487762fc67180911c6336ca568a9f5cb5cf153dad68eeea4e" => :el_capitan
    sha256 "95b0ee300856023058713c2e1c67fb5b263141dbfab6a882701381f42fd39edc" => :yosemite
    sha256 "12702275fe2e9be08d93be7e3e4a1176a1e24ddd5bdd4aaccdbf1197710f2c9a" => :mavericks
  end

  depends_on :python if MacOS.version <= :snow_leopard

  # Only Yosemite has new enough setuptools for successful compile of the below deps.
  resource "setuptools" do
    url "https://pypi.python.org/packages/source/s/setuptools/setuptools-12.0.5.tar.gz"
    sha256 "bda326cad34921060a45004b0dd81f828d471695346e303f4ca53b8ba6f4547f"
  end

  resource "thrift" do
    url "https://pypi.python.org/packages/source/t/thrift/thrift-0.9.2.tar.gz"
    sha256 "08f665e4b033c9d2d0b6174d869273104362c80e77ee4c01054a74141e378afa"
  end

  resource "futures" do
    url "https://pypi.python.org/packages/source/f/futures/futures-2.2.0.tar.gz"
    sha256 "151c057173474a3a40f897165951c0e33ad04f37de65b6de547ddef107fd0ed3"
  end

  resource "six" do
    url "https://pypi.python.org/packages/source/s/six/six-1.9.0.tar.gz"
    sha256 "e24052411fc4fbd1f672635537c3fc2330d9481b18c0317695b46259512c91d5"
  end

  resource "cql" do
    url "https://pypi.python.org/packages/source/c/cql/cql-1.4.0.tar.gz"
    sha256 "7857c16d8aab7b736ab677d1016ef8513dedb64097214ad3a50a6c550cb7d6e0"
  end

  resource "cassandra-driver" do
    url "https://pypi.python.org/packages/source/c/cassandra-driver/cassandra-driver-2.6.0.tar.gz"
    sha256 "753505a02b4c6f9b5ef18dec36a13f17fb458c98925eea62c94a8839d5949717"
  end

  def install
    (var+"lib/cassandra").mkpath
    (var+"log/cassandra").mkpath

    pypath = libexec/"vendor/lib/python2.7/site-packages"
    ENV.prepend_create_path "PYTHONPATH", pypath
    %w[setuptools thrift futures six cql cassandra-driver].each do |r|
      resource(r).stage do
        system "python", *Language::Python.setup_install_args(libexec/"vendor")
      end
    end

    inreplace "conf/cassandra.yaml", "/var/lib/cassandra", "#{var}/lib/cassandra"
    inreplace "conf/cassandra-env.sh", "/lib/", "/"

    inreplace "bin/cassandra", "-Dcassandra.logdir\=$CASSANDRA_HOME/logs", "-Dcassandra.logdir\=#{var}/log/cassandra"
    inreplace "bin/cassandra.in.sh" do |s|
      s.gsub! "CASSANDRA_HOME=\"`dirname \"$0\"`/..\"", "CASSANDRA_HOME=\"#{libexec}\""
      # Store configs in etc, outside of keg
      s.gsub! "CASSANDRA_CONF=\"$CASSANDRA_HOME/conf\"", "CASSANDRA_CONF=\"#{etc}/cassandra\""
      # Jars installed to prefix, no longer in a lib folder
      s.gsub! "\"$CASSANDRA_HOME\"/lib/*.jar", "\"$CASSANDRA_HOME\"/*.jar"
      # The jammm Java agent is not in a lib/ subdir either:
      s.gsub! "JAVA_AGENT=\"$JAVA_AGENT -javaagent:$CASSANDRA_HOME/lib/jamm-", "JAVA_AGENT=\"$JAVA_AGENT -javaagent:$CASSANDRA_HOME/jamm-"
      # Storage path
      s.gsub! "cassandra_storagedir\=\"$CASSANDRA_HOME/data\"", "cassandra_storagedir\=\"#{var}/lib/cassandra\""
    end

    rm Dir["bin/*.bat", "bin/*.ps1"]

    # This breaks on `brew uninstall cassandra && brew install cassandra`
    # https://github.com/Homebrew/homebrew/pull/38309
    (etc+"cassandra").install Dir["conf/*"]

    libexec.install Dir["*.txt", "{bin,interface,javadoc,pylib,lib/licenses}"]
    libexec.install Dir["lib/*.jar"]

    share.install [libexec+"bin/cassandra.in.sh", libexec+"bin/stop-server"]
    inreplace Dir["#{libexec}/bin/cassandra*", "#{libexec}/bin/debug-cql", "#{libexec}/bin/nodetool", "#{libexec}/bin/sstable*"],
              %r{`dirname "?\$0"?`/cassandra.in.sh},
              "#{share}/cassandra.in.sh"

    bin.write_exec_script Dir["#{libexec}/bin/*"]
    rm bin/"cqlsh" # Remove existing exec script
    (bin/"cqlsh").write_env_script libexec/"bin/cqlsh", :PYTHONPATH => pypath
  end

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>KeepAlive</key>
        <true/>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
            <string>#{opt_bin}/cassandra</string>
            <string>-f</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>WorkingDirectory</key>
        <string>#{var}/lib/cassandra</string>
      </dict>
    </plist>
    EOS
  end
end
