#!/usr/bin/perl

$rcsid = q$Id: w3mmail.cgi.in,v 1.14 2004/08/30 16:32:24 ukai Exp $;
($id = $rcsid) =~ s/^.*,v ([\d\.]*).*/$1/;
($prog=$0) =~ s/.*\///;

$query = $ENV{'QUERY_STRING'};
$cookie_file = $ENV{'LOCAL_COOKIE_FILE'};
$local_cookie = '';
$SENDMAIL = '/usr/lib/sendmail';
$SENDMAIL = '/usr/sbin/sendmail' if -x '/usr/sbin/sendmail';
$SENDMAIL_OPT = '-oi -t';

if (-f $cookie_file) {
    open(F, "< $cookie_file");
    $local_cookie = <F>;
    close(F);
}
if ($query =~ s/^\w+://) {
    $url = $query;
    $qurl = &html_quote($url);
    $to = $query;
    $opt = '';
    if ($to =~ /^([^?]*)\?(.*)$/) {
	$to = $1;
	$opt = $2;
    }
    $to = &url_unquote($to);
    %opt = &parse_opt($opt);

    @to = ($to);
    push(@to, $opt{'to'}) if ($opt{'to'});
    $opt{'to'} = join(',', @to);
    if ($ENV{'REQUEST_METHOD'} eq 'POST') {
	sysread(STDIN, $body, $ENV{'CONTENT_LENGTH'});
	$content_type = $ENV{'CONTENT_TYPE'};
	if ($content_type =~ /^multipart\/form-data;\s+boundary=(.*)$/) {
	    $boundary = $1;
	}
    } else {
	$body = $opt{'body'};
	delete $opt{'body'};
    }
    &lang_setup;

    print "Content-Type: text/html; charset=$charset\r\n";
    print "w3m-control: END\r\n";
    print "w3m-control: PREV_LINK\r\n";
    print "\r\n";
    print "<html><head><title>W3M Mailer: $qurl</title></head>\n";
    print "<body><h1>W3M Mailer: $qurl</h1>\n";
    print "<form action=\"file://$0\" method='POST'>\n";
    $local_cookie = &html_quote($local_cookie);
    print "<input type='hidden' name='cookie' value=\"$local_cookie\">\n";
    print "<table>\n";
    foreach $h ('from', 'to', 'cc', 'bcc', 'subject') {
	$v = &lang_html_quote($opt{$h});
	print "<tr><td>\u$h:<td><input type='text' name=\"$h\" value=\"$v\">\n";
	delete $opt{$h};
    }
    if ($boundary) {
	$boundary = &html_quote($boundary);
	print "<tr><td>Content-Type:<td>multipart/form-data; boundary=\"$boundary\"\n";
	print "<input type='hidden' name='boundary' value=\"$boundary\">\n";
    }
    foreach $h (keys %opt) {
	$qh = &html_quote($h);
	$v = &lang_html_quote($opt{$h});
	print "<tr><td>\u$h:<td>$v\n";
	print "<input type='hidden' name=\"$qh\" value=\"$v\">\n";
    }
    print "<tr><td colspan=2>\n";
    print "<textarea cols=40 rows=10 name='body'>\n";
    if ($body) {
	print &lang_html_quote($body);
    }
    print "</textarea>\n";
    print "</table>\n";
    print "<input type='submit' name='action' value='Preview'>\n";
    print "</form>\n";
    print "</body></html>\n";
    exit(0);
} else {
    sysread(STDIN, $req, $ENV{'CONTENT_LENGTH'});
    %opt = &parse_opt($req);
    if ($local_cookie ne $opt{'cookie'}) {
	print "Content-Type: text/plain\r\n";
	print "\r\n";
	print "Local cookie doesn't match: It may be an illegal execution\n";
	exit 1;
    }
    delete $opt{'cookie'};
    $body = $opt{'body'};
    delete $opt{'body'};
    $act = $opt{'action'};
    delete $opt{'action'};
    $boundary = $opt{'boundary'};
    delete $opt{'boundary'};
    &lang_setup;

    if ($act eq "Preview") {
	print "Content-Type: text/html; charset=$charset\r\n";
	print "w3m-control: DELETE_PREVBUF\r\n";
	print "w3m-control: NEXT_LINK\r\n";
	print "\r\n";
	print "<html><head><title>W3M Mailer</title></head>\n";
	print "<body>\n";
	print "<h1>W3M Mailer: preview</h1>\n";
	print "<form action=\"file://$0\" method='POST'>\n";
	$local_cookie = &html_quote($local_cookie);
	print "<input type='hidden' name='cookie' value=\"$local_cookie\">\n";
	print "<hr>\n";
	print "<pre>\n";
	foreach $h (keys %opt) {
	    $qh = &html_quote($h);
	    $v{$h} = &lang_html_quote($opt{$h});
	    if ($v{$h}) {
		print "\u$qh: $v{$h}\n";
	    }
	}
	($cs,$cte,$body) = &lang_body(&lang_html_quote($body), 0);
	print "Mime-Version: 1.0\n";
	if ($boundary) {
	    $boundary = &html_quote($boundary);
	    print "Content-Type: multipart/form-data;\n";
	    print "    boundary=\"$boundary\"\n";
	} else {
	    print "Content-Type: text/plain; charset=$cs\n";
	}
#	print "Content-Transfer-Encoding: $cte\n";
	print "User-Agent: ", &html_quote("$ENV{'SERVER_SOFTWARE'} $prog/$id"),
		"\n";
	print "\n";
	print $body;
	print "\n" if ($body !~ /\n$/);
	print "</pre>\n";
	print "<input type='submit' name='action' value='Send'>\n";
	print "<hr>\n";
	print "<table>\n";
	foreach $h ('from', 'to', 'cc', 'bcc', 'subject') {
	    print "<tr><td>\u$h:<td><input type='text' name=\"$h\" value=\"$v{$h}\">\n";
	    delete $opt{$h};
	}
	if ($boundary) {
	    print "<tr><td>Content-Type:<td>Content-Type: multipart/form-data; boundary=\"$boundary\"\n";
	    print "<input type='hidden' name=\"boundary\" value=\"$boundary\">\n";
	}
	foreach $h (keys %opt) {
	    $qh = &html_quote($h);
	    print "<tr><td>\u$qh:<td>$v{$h}\n";
	    print "<input type='hidden' name=\"$qh\" value=\"$v{$h}\">\n";
	}
	print "<tr><td colspan=2>\n";
	print "<textarea cols=40 rows=10 name=body>\n";
	if ($body) {
	    print $body;
	}
	print "</textarea>\n";
	print "</table>\n";
	print "<input type='submit' name='action' value='Preview'><br>\n";
	print "</body></html>\n";
    } else {
# XXX: quote?
#	if ($opt{'from'}) {
#	    $sendmail_fromopt = '-f' . $opt{'from'};
#	}
	unless (open(MAIL, "|$SENDMAIL $SENDMAIL_OPT")) {
	    print "Content-Type: text/html\r\n";
	    print "\r\n";
	    print "<html><head><title>W3M Mailer</title></head>\n";
	    print "<body><h1>W3M Mailer: open sendmail failed</h1>\n";
	    print "<p>", &html_quote($@), "</p>\n";
	    print "</body></html>\n";
	    exit(0);
	}
	foreach $h (keys %opt) {
	    $v = &lang_header($opt{$h});
	    if ($v) {
		print MAIL "\u$h: $v\n";
	    }
	}
	($cs,$cte,$body) = &lang_body($body, 1);
	$body =~ s/\r//g;
	print MAIL "Mime-Version: 1.0\n";
	if ($boundary) {
	    print MAIL "Content-Type: multipart/form-data;\n";
	    print MAIL "    boundary=\"$boundary\"\n";
	} else {
	    print MAIL "Content-Type: text/plain; charset=$cs\n";
	}
	print MAIL "Content-Transfer-Encoding: $cte\n";
	print MAIL "User-Agent: $ENV{'SERVER_SOFTWARE'} $prog/$id\n";
	print MAIL "\n";
	print MAIL $body;
	if (close(MAIL)) {
	    print "w3m-control: DELETE_PREVBUF\r\n";
	    print "w3m-control: BACK\r\n";
	    print "\r\n";
	} else {
	    print "Content-Type: text/html\r\n";
	    print "\r\n";
	    print "<html><head><title>W3M Mailer</title></head>\n";
	    print "<body><h1>W3M Mailer: close sendmail failed</h1>\n";
	    print "<p>", &html_quote($@), "</p>\n";
	    print "</body></html>\n";
	}
    }
}

sub lang_setup {
    $lang = $ENV{'LC_ALL'} || $ENV{'LC_CTYPE'} || $ENV{'LANG'};
    if ($lang =~ /^ja/i) {
	eval "use NKF;";
	if (! $@) {
	    $use_NKF = 1;
	} else {
	    $use_NKF = 0;
	}
	$charset = "EUC-JP";
    } else {
	$charset = &guess_charset($lang);
    }
}

sub lang_header {
    if ($lang =~ /^ja/i) {
	return &lang_header_ja(@_);
    } else {
	return &lang_header_default(@_);
    }
}

sub lang_body {
    if ($lang =~ /^ja/i) {
	return &lang_body_ja(@_);
    } else {
	return &lang_body_default(@_);
    }
}

sub lang_html_quote {
    local($_) = @_;
    if ($lang =~ /^ja/i) {
	if (/[\x80-\xFF]/ || /\033[\$\(][BJ@]/) {
	    $_ = &conv_nkf("-e", $_);
	}
    }
    return &html_quote($_);
}

sub lang_header_default {
    local($h) = @_;
    if ($h =~ s/([=_?\x80-\xFF])/sprintf("=%02x", ord($1))/ge) {
	return "=?$charset?Q?$h?=";
    } else {
	return $h;
    }
}

sub lang_body_default { 
    local($body, $_7bit) = @_;
    if ($body =~ /[\x80-\xFF]/) {
	if ($_7bit) {
	    $body =~ s/([=\x80-\xFF])/sprintf("=%02x", ord($1))/ge;
	    return ($charset, "quoted-printable", $body);
	} else {
	    return ($charset, "8bit", $body);
	}
    } else {
	return ("US-ASCII", "7bit", $body);
    }
}

sub lang_header_ja {
    local($h) = @_;
    if ($h =~ /[\x80-\xFF]/ || $h =~ /\033[\$\(][BJ@]/) {
	$h = &conv_nkf("-j", $h);
	&conv_nkf("-M", $h);
    } else {
	return $h;
    }
}

sub lang_body_ja {
    local($body, $_7bit) = @_;
    if ($body =~ /[\x80-\xFF]/ || $body =~ /\033[\$\(][BJ@]/) {
	if ($_7bit) {
	    $body = &conv_nkf("-j", $body);
	}
	return ("ISO-2022-JP", "7bit", $body);
    } else {
	return ("US-ASCII", "7bit", $body);
    }
}

sub conv_nkf {
    local(@opt) = @_;
    if ($use_NKF) {
	return nkf(@opt);
    }
    local($body) = pop(@opt);
    $body =~ s/\r+\n/\n/g;
    $| = 1;
    pipe(R, W2);
    pipe(R2, W);
    if (! fork()) {
	close(F);
	close(R);
	close(W);
	open(STDIN, "<&R2");
	open(STDOUT, ">&W2");
	exec "nkf", @opt;
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
};



sub parse_opt {
  local($opt) = @_;
  local(%opt) = ();
  if ($opt) {	
      foreach $o (split('&', $opt)) {
	  if ($o =~ /(\w+)=(.*)/) {
	      $opt{"\L$1"} = &url_unquote($2);
	  }
      }
  }
  return %opt;
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

sub url_unquote {
    local($_) = @_;
    s/\+|%([0-9A-Fa-f][0-9A-Fa-f])/$& eq '+' ? ' ' : pack('c', hex($1))/ge;
    return $_;
}

sub guess_charset {
    local(%lang_charset) = (
	'cs', 'iso-8859-2',
	'el', 'iso-8859-7',
	'iw', 'iso-8859-8',
	'ja', 'EUC-JP',
	'ko', 'EUC-KR',
	'hu', 'iso-8859-2',
	'pl', 'iso-8859-2',
	'ro', 'iso-8859-2',
	'ru', 'iso-8859-5',
	'sk', 'iso-8859-2',
	'sl', 'iso-8859-2',
	'tr', 'iso-8859-9',
	'zh', 'GB2312',
    );
    local($_) = @_;
    local($lang);

    if (! s/\.(.*)$//) {
        if (/^zh_tw/i) {
	    return 'Big5';
	}
	/^(..)/;
	return $lang_charset{$1} || 'iso-8859-1';
    }
    $lang = $_;
    $_ = $1;
    if (/^euc/i) {
	if (/^euc$/i) {
	    $lang =~ /^zh_tw/ && return 'EUC-TW';
	    $lang =~ /^zh/ && return 'GB2312';
	    $lang =~ /^ko/ && return 'EUC-KR';
	    return 'EUC-JP';
	}
	/^euccn/i && return 'GB2312';
	s/[\-_]//g;
	s/^euc/EUC-/i;
	tr/a-z/A-Z/;
    } elsif (/^iso8859/i) {
	s/[\-_]//g;
	s/^iso8859/iso-8859-/i;
    }
    return $_;
}
