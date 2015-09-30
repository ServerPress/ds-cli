divert(-1)
#
# Copyright (c) 1998, 1999 Proofpoint, Inc. and its suppliers.
#	All rights reserved.
# Copyright (c) 1983 Eric P. Allman.  All rights reserved.
# Copyright (c) 1988, 1993
#	The Regents of the University of California.  All rights reserved.
#
# By using this file, you agree to the terms and conditions set
# forth in the LICENSE file which can be found at the top level of
# the sendmail distribution.
#
#

#
#  This is a generic configuration file for Linux.
#  It has support for local and SMTP mail only.  If you want to
#  customize it, copy it to a name appropriate for your environment
#  and do the modifications there.
#

divert(0)
VERSIONID(`$Id: generic-linux.mc,v 8.2 2014-08-13 20:51:08 dboland Exp $')
OSTYPE(linux)
DOMAIN(generic)
FEATURE(`virtusertable', `hash -o /etc/mail/virtusertable')
define(`confRUN_AS_USER', `smmsp')
dnl define(`ALIAS_FILE', `/etc/aliases')
dnl define(`confLOG_LEVEL', `23')
dnl # With STARTTLS (enables SMTPS port 587)
dnl define(`CERT_DIR', `MAIL_SETTINGS_DIR`'certs')
dnl define(`confCACERT_PATH', `CERT_DIR')
dnl define(`confCACERT', `CERT_DIR/domain.pem')
dnl define(`confSERVER_CERT', `CERT_DIR/domain.pem')
dnl define(`confSERVER_KEY', `CERT_DIR/domain.pem')
dnl define(`confCLIENT_CERT', `CERT_DIR/domain.pem')
dnl define(`confCLIENT_KEY', `CERT_DIR/domain.pem')
dnl # With AUTH (enables SMTPSA port 465, disables SMTP port 25)
dnl # Also called 'Secure Password Authentification' by mail clients
dnl DAEMON_OPTIONS(`Family=inet, Address=0.0.0.0, Port=465, Name=MTA-SMTPSA, M=s')
dnl DAEMON_OPTIONS(`Family=inet6, Address=::, Port=465, Name=MTA-SMTPSA, M=s')
MAILER(local)
MAILER(smtp)
