# -*- buffer-read-only: t -*-
#
# This file is auto-generated. ***ANY*** changes here will be lost
#

package Errno;
require Exporter;
use Config;
use strict;

"$Config{'archname'}-$Config{'osvers'}" eq
"darwin-thread-multi-2level-12.5.0" or
	die "Errno architecture (darwin-thread-multi-2level-12.5.0) does not match executable architecture ($Config{'archname'}-$Config{'osvers'})";

our $VERSION = "1.15";
$VERSION = eval $VERSION;
our @ISA = 'Exporter';

my %err;

BEGIN {
    %err = (
	EPERM => 1,
	ENOENT => 2,
	ESRCH => 3,
	EINTR => 4,
	EIO => 5,
	ENXIO => 6,
	E2BIG => 7,
	ENOEXEC => 8,
	EBADF => 9,
	ECHILD => 10,
	EDEADLK => 11,
	ENOMEM => 12,
	EACCES => 13,
	EFAULT => 14,
	ENOTBLK => 15,
	EBUSY => 16,
	EEXIST => 17,
	EXDEV => 18,
	ENODEV => 19,
	ENOTDIR => 20,
	EISDIR => 21,
	EINVAL => 22,
	ENFILE => 23,
	EMFILE => 24,
	ENOTTY => 25,
	ETXTBSY => 26,
	EFBIG => 27,
	ENOSPC => 28,
	ESPIPE => 29,
	EROFS => 30,
	EMLINK => 31,
	EPIPE => 32,
	EDOM => 33,
	ERANGE => 34,
	EWOULDBLOCK => 35,
	EAGAIN => 35,
	EINPROGRESS => 36,
	EALREADY => 37,
	ENOTSOCK => 38,
	EDESTADDRREQ => 39,
	EMSGSIZE => 40,
	EPROTOTYPE => 41,
	ENOPROTOOPT => 42,
	EPROTONOSUPPORT => 43,
	ESOCKTNOSUPPORT => 44,
	ENOTSUP => 45,
	EPFNOSUPPORT => 46,
	EAFNOSUPPORT => 47,
	EADDRINUSE => 48,
	EADDRNOTAVAIL => 49,
	ENETDOWN => 50,
	ENETUNREACH => 51,
	ENETRESET => 52,
	ECONNABORTED => 53,
	ECONNRESET => 54,
	ENOBUFS => 55,
	EISCONN => 56,
	ENOTCONN => 57,
	ESHUTDOWN => 58,
	ETOOMANYREFS => 59,
	ETIMEDOUT => 60,
	ECONNREFUSED => 61,
	ELOOP => 62,
	ENAMETOOLONG => 63,
	EHOSTDOWN => 64,
	EHOSTUNREACH => 65,
	ENOTEMPTY => 66,
	EPROCLIM => 67,
	EUSERS => 68,
	EDQUOT => 69,
	ESTALE => 70,
	EREMOTE => 71,
	EBADRPC => 72,
	ERPCMISMATCH => 73,
	EPROGUNAVAIL => 74,
	EPROGMISMATCH => 75,
	EPROCUNAVAIL => 76,
	ENOLCK => 77,
	ENOSYS => 78,
	EFTYPE => 79,
	EAUTH => 80,
	ENEEDAUTH => 81,
	EPWROFF => 82,
	EDEVERR => 83,
	EOVERFLOW => 84,
	EBADEXEC => 85,
	EBADARCH => 86,
	ESHLIBVERS => 87,
	EBADMACHO => 88,
	ECANCELED => 89,
	EIDRM => 90,
	ENOMSG => 91,
	EILSEQ => 92,
	ENOATTR => 93,
	EBADMSG => 94,
	EMULTIHOP => 95,
	ENODATA => 96,
	ENOLINK => 97,
	ENOSR => 98,
	ENOSTR => 99,
	EPROTO => 100,
	ETIME => 101,
	EOPNOTSUPP => 102,
	ENOPOLICY => 103,
	ENOTRECOVERABLE => 104,
	EOWNERDEAD => 105,
	ELAST => 106,
	EQFULL => 106,
    );
    # Generate proxy constant subroutines for all the values.
    # Well, almost all the values. Unfortunately we can't assume that at this
    # point that our symbol table is empty, as code such as if the parser has
    # seen code such as C<exists &Errno::EINVAL>, it will have created the
    # typeglob.
    # Doing this before defining @EXPORT_OK etc means that even if a platform is
    # crazy enough to define EXPORT_OK as an error constant, everything will
    # still work, because the parser will upgrade the PCS to a real typeglob.
    # We rely on the subroutine definitions below to update the internal caches.
    # Don't use %each, as we don't want a copy of the value.
    foreach my $name (keys %err) {
        if ($Errno::{$name}) {
            # We expect this to be reached fairly rarely, so take an approach
            # which uses the least compile time effort in the common case:
            eval "sub $name() { $err{$name} }; 1" or die $@;
        } else {
            $Errno::{$name} = \$err{$name};
        }
    }
}

our @EXPORT_OK = keys %err;

our %EXPORT_TAGS = (
    POSIX => [qw(
	E2BIG EACCES EADDRINUSE EADDRNOTAVAIL EAFNOSUPPORT EAGAIN EALREADY
	EBADF EBUSY ECHILD ECONNABORTED ECONNREFUSED ECONNRESET EDEADLK
	EDESTADDRREQ EDOM EDQUOT EEXIST EFAULT EFBIG EHOSTDOWN EHOSTUNREACH
	EINPROGRESS EINTR EINVAL EIO EISCONN EISDIR ELOOP EMFILE EMLINK
	EMSGSIZE ENAMETOOLONG ENETDOWN ENETRESET ENETUNREACH ENFILE ENOBUFS
	ENODEV ENOENT ENOEXEC ENOLCK ENOMEM ENOPROTOOPT ENOSPC ENOSYS ENOTBLK
	ENOTCONN ENOTDIR ENOTEMPTY ENOTSOCK ENOTTY ENXIO EOPNOTSUPP EPERM
	EPFNOSUPPORT EPIPE EPROCLIM EPROTONOSUPPORT EPROTOTYPE ERANGE EREMOTE
	EROFS ESHUTDOWN ESOCKTNOSUPPORT ESPIPE ESRCH ESTALE ETIMEDOUT
	ETOOMANYREFS ETXTBSY EUSERS EWOULDBLOCK EXDEV
    )]
);

sub TIEHASH { bless \%err }

sub FETCH {
    my (undef, $errname) = @_;
    return "" unless exists $err{$errname};
    my $errno = $err{$errname};
    return $errno == $! ? $errno : 0;
}

sub STORE {
    require Carp;
    Carp::confess("ERRNO hash is read only!");
}

*CLEAR = *DELETE = \*STORE; # Typeglob aliasing uses less space

sub NEXTKEY {
    each %err;
}

sub FIRSTKEY {
    my $s = scalar keys %err;	# initialize iterator
    each %err;
}

sub EXISTS {
    my (undef, $errname) = @_;
    exists $err{$errname};
}

tie %!, __PACKAGE__; # Returns an object, objects are true.

__END__

=head1 NAME

Errno - System errno constants

=head1 SYNOPSIS

    use Errno qw(EINTR EIO :POSIX);

=head1 DESCRIPTION

C<Errno> defines and conditionally exports all the error constants
defined in your system C<errno.h> include file. It has a single export
tag, C<:POSIX>, which will export all POSIX defined error numbers.

C<Errno> also makes C<%!> magic such that each element of C<%!> has a
non-zero value only if C<$!> is set to that value. For example:

    use Errno;

    unless (open(FH, "/fangorn/spouse")) {
        if ($!{ENOENT}) {
            warn "Get a wife!\n";
        } else {
            warn "This path is barred: $!";
        } 
    } 

If a specified constant C<EFOO> does not exist on the system, C<$!{EFOO}>
returns C<"">.  You may use C<exists $!{EFOO}> to check whether the
constant is available on the system.

=head1 CAVEATS

Importing a particular constant may not be very portable, because the
import will fail on platforms that do not have that constant.  A more
portable way to set C<$!> to a valid value is to use:

    if (exists &Errno::EFOO) {
        $! = &Errno::EFOO;
    }

=head1 AUTHOR

Graham Barr <gbarr@pobox.com>

=head1 COPYRIGHT

Copyright (c) 1997-8 Graham Barr. All rights reserved.
This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

# ex: set ro:
