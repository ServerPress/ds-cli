--- tools/msf_irb_shell.rb	2007-03-25 16:45:06.000000000 -0700
+++ tools/msf_irb_shell.rb	2007-05-29 14:57:34.000000000 -0700
@@ -1,6 +1,6 @@
 #!/usr/bin/env ruby
 
-msfbase = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
+msfbase = File.symlink?(__FILE__) ? File.join(File.expand_path(File.dirname(File.readlink(__FILE__)), File.dirname(__FILE__)), File.basename(__FILE__)) : __FILE__
 $:.unshift(File.join(File.dirname(msfbase), '..', 'lib'))
 
 require 'rex'
