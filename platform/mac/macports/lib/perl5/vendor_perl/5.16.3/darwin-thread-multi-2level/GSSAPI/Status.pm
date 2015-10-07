package GSSAPI::Status;

require 5.005_62;
use strict;
use warnings;

use overload
	'bool' => "is_true",
	'!'    => "is_false",
	'""'   => "stringify";

our @ISA = qw(GSSAPI);

sub import { 1 }			# for GSSAPI::import()

sub generic_message ($) {
    my $self = shift;
    display_status($self->major, GSSAPI::GSS_C_GSS_CODE);
}

sub specific_message ($) {
    my $self = shift;
    display_status($self->minor, GSSAPI::GSS_C_MECH_CODE);
}

sub is_true ($$$) {
    my $self = shift;
    ! GSS_ERROR($self->major)
}

sub is_false ($$$) {
    my $self = shift;
    GSS_ERROR($self->major)
}

sub stringify ($$$) {
    my $self = shift;
    join("\n", $self->generic_message, $self->specific_message, '')
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

=head1 NAME

GSSAPI::Status - methods for handlings GSSAPI statuses

=head1 SYNOPSIS

  use GSSAPI;
  
  $status = GSSAPI::Status->new(GSS_S_COMPLETE, 0);

  if (GSS_ERROR($status->major)) {
    die "a horrible death";
  }
  if (! $status) {			# another way of writing the above
    die "a horrible death";
  }

  $status = $some_GSSAPI->someop($args1, etc);
  if ($status) {
    foreach ($status->generic_message, $status->specific_message) {
      print "GSSAPI error: $_\n";
    }
    die "help me";
  }


=head1 DESCRIPTION

C<GSSAPI::Status> objects are returned by most other GSSAPI operations.
Such statuses consist of a GSSAPI generic code and, for most
operations, a mechanism specific code.  These numeric codes can be
accessed via the methods C<major> and C<minor>.  The standard textual
messages that go with the current status can be obtained via the
C<generic_message> and C<specific_message> methods.  Each of these
returns a list of text which should presumably be displayed in
order.

The generic code part of a GSSAPI::Status is composed of three
subfields that can be accessed with the C<GSS_CALLING_ERROR>,
C<GSS_ROUTINE_ERROR>, and C<GSS_SUPPLEMENTARY_INFO> functions.  The
returned values can be compared against the constants whose names
start with C<GSS_S_> if your code wants to handle particular errors
itself.  The C<GSS_ERROR> function returns true if and only if the
given generic code contains neither a calling error nor a routine
error.

When evaluated in a boolean context, a C<GSSAPI::Status> object
will be true if and only if the major status code is C<GSS_S_COMPLETE>.

When evaluated in a string contect, a C<GSSAPI::Status> object will
return the generic and specific messages all joined together with
newlines.  This may or may not make C<die $status> work usefully.

=head1 BUGS

The base objects are currently implmented as a blessed C structure
containing the major and minor status codes.  It should probably
be a blessed array or hash instead, thereby cutting down on the
amount of C code involved and making it more flexible.

=head1 AUTHOR

Philip Guenther <pguen@cpan.org>

=head1 SEE ALSO

perl(1)
RFC2743

=cut
