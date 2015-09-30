#!/usr/bin/perl

eval "use NKF;";
if (! $@) {
	$use_NKF = 1;
	$CONV = "-e";
	$MIME_DECODE = "-m -e";
} else {
	$use_NKF = 0;
#	$CONV = "w3m -dump -e";
	$CONV = "/usr/local/bin/nkf -e";
	$MIME_DECODE = "/usr/local/bin/nkf -m -e";
}
$MIME_TYPE = "$ENV{'HOME'}/.mime.types";

$SCRIPT_NAME = $ENV{'SCRIPT_NAME'} || $0;
$CGI = "file://$SCRIPT_NAME";

if ($ENV{'REQUEST_METHOD'} eq 'POST') {
	sysread(STDIN, $query, $ENV{'CONTENT_LENGTH'});
} elsif (defined($ENV{'QUERY_STRING'})) {
	$query = $ENV{'QUERY_STRING'};
}
if (defined($query)) {
	for (split('&', $query)) {
		s/^([^=]*)=//;
		$v{$1} = $_;
	}
	$file = &form_decode($v{'file'});
	$boundary = &form_decode($v{'boundary'});
} else {
	$file = $ARGV[0];
	if (@ARGV >= 2) {
		$boundary = $ARGV[1];
	}
}
(-f $file) || exit(1);
open(F, "< $file") || exit(1);
$end = 0;
$mbody = '';
if (defined($boundary)) {
	while(<F>) {
		s/\r?\n$//;
		($_ eq "--$boundary") && last;
		($_ eq "--$boundary--") && ($end = 1, last);
		$mbody .= "$_\n";
	}
} else {
	while(<F>) {
		s/\r?\n$//;
		if (s/^\-\-//) {
			$boundary = $_;
			last;
		}
		$mbody .= "$_\n";
	}
}

if (defined($v{'count'})) {
	$count = 0;
	while($count < $v{'count'}) {
		while(<F>) {
			s/\r?\n$//;
			($_ eq "--$boundary") && last;
		}
		eof(F) && exit;
		$count++;
	}

	%header = ();
	$hbody = '';
	while(<F>) {
		/^\s*$/ && last;
		$x = $_;
		s/\r?\n$//;
		if (/=\?/) {
			$_ = &decode($_, $MIME_DECODE);
		}
		if (s/^(\S+)\s*:\s*//) {
			$h = $&;
			if ($h =~ /^w3m-control/i) {
				$h = "WARNING: $h";
			}
			$hbody .= "$h$_\n";
			$p = $1;
			$p =~ tr/A-Z/a-z/;
			$header{$p} = $_;
		} elsif (s/^\s+//) {
			chop $hbody;
			$hbody .= "$_\n";
			$header{$p} .= $_;
		}
	}
	$type = $header{"content-type"};
	$dispos = $header{"content-disposition"};
	if ($type =~ /application\/octet-stream/) {
		if ($type =~ /type\=gzip/) {
			print "Content-Encoding: x-gzip\n";
		}
		if ($type =~ /name=\"?([^\"]+)\"?/ ||
			$dispos =~ /filename=\"?([^\"]+)\"?/) {
			$type = &guess_type($1);
			if ($type) {
				print "Content-Type: $type; name=\"$1\"\n";
			} else {
				print "Content-Type: text/plain; name=\"$1\"\n";
			}
		}
	}
	print $hbody;
	print "\n";
	while(<F>) {
		$x = $_;
		s/\r?\n$//;
		($_ eq "--$boundary") && last;
		if ($_ eq "--$boundary--") {
			last;
		}
		print $x;
	}
	close(F);
	exit;
}

$qcgi = &html_quote($CGI);
$qfile = &html_quote($file);
$qboundary = &html_quote($boundary);

if ($mbody =~ /\S/) {
	$_ = $mbody;
	s/\&/\&amp;/g;
	s/\</\&lt;/g;
	s/\>/\&gt;/g;
	print "<pre>\n";
	print $_;
	print "</pre>\n";
}

$count = 0;
while(! $end) {
	%header = ();
	$hbody = '';
	while(<F>) {
		/^\s*$/ && last;
		s/\r?\n$//;
		if (/=\?/) {
			$_ = &decode($_, $MIME_DECODE);
		}
		if (s/^(\S+)\s*:\s*//) {
			$hbody .= "$&$_\n";
			$p = $1;
			$p =~ tr/A-Z/a-z/;
			$header{$p} = $_;
		} elsif (s/^\s+//) {
			chop $hbody;
			$hbody .= "$_\n";
			$header{$p} .= $_;
		}
	}
	$type = $header{"content-type"};
	$dispos = $header{"content-disposition"};
	$plain = 0;
	$image = 0;
	if (! $dispos || $dispos =~ /^inline/i) {
		if (! $type || $type =~ /^text\/plain/i) {
			$plain = 1;
		} elsif ($type =~ /^image\//i) {
			$image = 1;
		}
	}
	$body = '';
	while(<F>) {
		s/\r?\n$//;
		($_ eq "--$boundary") && last;
		if ($_ eq "--$boundary--") {
			$end = 1;
			last;
		}
		if ($plain) {
			$body .= "$_\n";
		}
	}
	$| = 1;
	print "<hr>\n";
	{
		$_ = $hbody;
		s/\&/\&amp;/g;
		s/\</\&lt;/g;
		s/\>/\&gt;/g;
		print "<pre>\n";
		print $_;
		print "</pre>\n";
		if ($type =~ /name=\"?([^\"]+)\"?/ ||
			$dispos =~ /filename=\"?([^\"]+)\"?/) {
			$name = $1;
		} else {
			$name = "Content";
		}
		print "<form action=\"$qcgi\">\n";
		print "<input type=hidden name=file value=\"$qfile\">\n";
		print "<input type=hidden name=boundary value=\"$qboundary\">\n";
		print "<input type=hidden name=count value=\"$count\">\n";
		if ($image) {
			print "<input type=image name=submit src=\"$qcgi?file=",
				&html_quote(&form_encode($file)),
				"&amp;boundary=",
				&html_quote(&form_encode($boundary)),
				"&amp;count=$count\" alt=\"",
				&html_quote($name), "\">\n";
		} else {
			print "<input type=submit name=submit value=\"",
				&html_quote($name), "\">\n";
		}
		print "</form>\n"
	}
	if ($plain) {
		$body = &decode($body, $CONV); 
		$_ = $body;
		s/\&/\&amp;/g;
		s/\</\&lt;/g;
		s/\>/\&gt;/g;
		print "<pre>\n\n";
		print $_;
		print "</pre>\n";
	}
	eof(F) && last;
	$count++;
}
close(F);

sub decode {
if ($use_NKF) {
	local($body, $opt) = @_;
	return nkf($opt, $body);
}
	local($body, @cmd) = @_;
	local($_);

	$| = 1;
	pipe(R, W2);
	pipe(R2, W);
	if (! fork()) {
		close(F);
		close(R);
		close(W);
		open(STDIN, "<&R2");
		open(STDOUT, ">&W2");
		exec @cmd;
		die;
	}
	close(R2);
	close(W2);
	print W $body;
	close(W);
	$body = '';
	while(<R>) {
		$body .= $_;
	}
	close(R);
	return $body;
}

sub html_quote {
  local($_) = @_;
  local(%QUOTE) = (
    '<', '&lt;',
    '>', '&gt;',
    '&', '&amp;',
    '"', '&quot;',
  );
  s/[<>&"]/$QUOTE{$&}/g;
  return $_;
}

sub form_decode {
  local($_) = @_;
  s/\+/ /g;
  s/%([\da-f][\da-f])/pack('c', hex($1))/egi;
  return $_;
}

sub form_encode {
  local($_) = @_;
  s/[\000-\040\+:#?&%<>"\177-\377]/sprintf('%%%02X', unpack('C', $&))/eg;
  return $_;
}

sub guess_type {
	local($_) = @_;

	/\.(\w+)$/ || return "";
	$_ = $1;
	tr/A-Z/a-z/;
	%mime_type = &load_mime_type($MIME_TYPE);
	$mime_type{$_};
}

sub load_mime_type {
	local($file) = @_;
	local(%m, $a, @b, $_);

	open(M, "< $file") || return ();
	while(<M>) {
		/^#/ && next;
		chop;
		(($a, @b) = split(" ")) >= 2 || next;
		for(@b) {
			$m{$_} = $a;
		}
	}
	close(M);
	return %m;
}
