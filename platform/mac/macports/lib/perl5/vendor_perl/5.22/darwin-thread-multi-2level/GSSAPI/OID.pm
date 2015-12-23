package GSSAPI::OID;

require 5.005_62;
use strict;
use warnings;

require Exporter;

use overload
	'""' => "stringify";

our @ISA = qw(Exporter GSSAPI);

our %EXPORT_TAGS = ( 'all' => [ qw(
	gss_nt_user_name
	gss_nt_machine_uid_name
	gss_nt_string_uid_name
	gss_nt_service_name
	gss_nt_exported_name
	gss_nt_service_name_v2
	gss_nt_krb5_name
	gss_nt_krb5_principal
	gss_mech_krb5
	gss_mech_krb5_old
	gss_mech_spnego
	gss_mech_krb5_v2

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT    = ( @{ $EXPORT_TAGS{'all'} } );

sub stringify($$$) {
    my $self = shift;
    my($status, $str);
    $status = $self->to_str($str)		or die $status;
    $str
}

1;
__END__

=head1 NAME

GSSAPI::OID - methods for handling GSSAPI OIDs and some constant OIDs

=head1 SYNOPSIS

  use GSSAPI;

  #$oid = GSSAPI::OID->new;		# rarely needed or wanted

  $status = GSSAPI::OID->from_str($oid, "{ 1 2 840 113554 1 2 1 1 }");
  #
  # only supported on MIT Kerberos
  #

  $status = $oid->to_str($str);
  #
  # only supported on MIT Kerberos
  #

  $status = $oid->inquire_names($oidset);

  # Constant OIDs provided:
  $oid = gss_nt_user_name;
  $oid = gss_nt_machine_uid_name;
  $oid = gss_nt_string_uid_name;
  $oid = gss_nt_service_name;
  $oid = gss_nt_exported_name;
  $oid = gss_nt_service_name_v2;
  $oid = gss_nt_krb5_name;
  $oid = gss_nt_krb5_principal;
  $oid = gss_mech_krb5;
  $oid = gss_mech_krb5_old;
  $oid = gss_mech_krb5_v2;

  $oid = gss_mech_spnego;

  # if your GSSAPI implementation supports
  # SPNEGO (Heimdal 0.7 for example
  # you can  use mechtype OID::gss_mech_spnego.
  #
  # use GSSAPI::indicate_mechs( $oidset );
  # to get the of mechtypes your implementation supports


  $oid = gss_nt_hostbased_service; # GSS_C_NT_HOSTBASED_SERVICE


=head1 DESCRIPTION

C<GSSAPI::OID> objects are used as unique indentifiers/constants
for 'mechanisisms' -- the particular protocol and version being
used -- and for the encodings used to represent names.  In many
cases you can request the default mechanism or encoding for the
implmentation by using GSS_C_NO_OID.  Check the description of the
routine in rfc2743 if you're not sure.

=head1 AUTHOR

maintained by Achim Grolms <perl@grolmsnet.de>

originally written by
Philip Guenther <pguen@cpan.org>

=head1 SEE ALSO

perl(1)
GSSAPI(3p)
GSSAPI::OID::Set(3p)
RFC2743

=cut
