class Neo4j < Formula
  desc "Robust (fully ACID) transactional property graph database"
  homepage "http://neo4j.com"
  url "http://dist.neo4j.org/neo4j-community-2.3.1-unix.tar.gz"
  version "2.3.1"
  sha256 "7b2f30d73af107eacd9a3a619475ef448a08eecb2cdb42ab1f8a38d091c70ecb"

  devel do
    url "http://dist.neo4j.org/neo4j-community-3.0.0-M02-unix.tar.gz"
    sha256 "2a20f420e94fe4189363ce8ab327c0e5e054df3fc74a0249e9e2c7fe0455a0d6"
    version "3.0.0-M02"
  end

  bottle :unneeded

  def install
    # Remove windows files
    rm_f Dir["bin/*.bat"]

    # Install jars in libexec to avoid conflicts
    libexec.install Dir["*"]

    # Symlink binaries
    bin.install_symlink Dir["#{libexec}/bin/neo4j{,-shell,-import}"]

    # Adjust UDC props
    open("#{libexec}/conf/neo4j-wrapper.conf", "a") do |f|
      f.puts "wrapper.java.additional.4=-Dneo4j.ext.udc.source=homebrew"

      # suppress the empty, focus-stealing java gui
      f.puts "wrapper.java.additional=-Djava.awt.headless=true"
    end
  end
end
