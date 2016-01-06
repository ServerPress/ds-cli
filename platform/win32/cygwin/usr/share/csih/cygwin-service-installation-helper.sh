#    --  #!/bin/bash  --
# cygwin-service-installation-helper.sh
#
# Copyright (c) 2010-2015 Charles S. Wilson, Corinna Vinschen,
#                    Pierre Humblett, and others listed in
#                    AUTHORS
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE
#
# -#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
#
# This is a script library used to assist installing cygwin
# services, such as sshd.  It is derived in part from various
# other sources (see AUTHORS).
#
# Do not attempt to run this file. Instead, it should be "sourced" by
# configuration scripts (such as a newer version of ssh-host-config,
# syslog-config, or iu-config) -- and that script should then use
# the shell functions defined here.
#
# -#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
#
# REQUIREMENTS:
#   SHELL must be bash
#
# PROVIDES:
#    csih_error
#    csih_error_multi
#    csih_error_recoverable
#    csih_warning
#    csih_inform
#    csih_verbose
#    csih_request
#    csih_get_value
#    csih_get_cygenv
#    csih_is_nt
#    csih_is_2k
#    csih_is_xp
#    csih_is_nt2003
#    csih_is_vista
#    csih_is_windows7
#    csih_is_windows8
#    csih_is_windows8_1
#    csih_is_windows10
#    csih_is_exactly_vista
#    csih_is_exactly_server2008
#    csih_is_exactly_windows7
#    csih_is_exactly_windows8
#    csih_is_exactly_windows8_1
#    csih_is_exactly_windows10
#    csih_is_exactly_server2008r2
#    csih_is_exactly_server2012
#    csih_is_exactly_server2012r2
#    csih_is_exactly_server2016
#    csih_version_ge
#    csih_version_le
#    csih_version_gt
#    csih_version_lt
#    csih_version_eq
#    csih_check_program
#    csih_check_program_or_warn
#    csih_check_program_or_error
#    csih_invoke_helper
#    csih_call_winsys32
#    csih_get_localized_account_name
#    csih_get_guest_account_name
#    csih_guest_account_active
#    csih_install_config
#    csih_make_dir
#    csih_get_system_and_admins_ids
#    csih_check_passwd_and_group
#    csih_old_cygwin
#    csih_use_file_etc
#    csih_check_user
#    csih_check_dir_perms
#    csih_check_access
#    csih_check_sys_mount
#    csih_privileged_accounts
#    csih_privileged_account_exists
#    csih_account_has_necessary_privileges
#    csih_select_privileged_username
#    csih_create_privileged_user
#    csih_create_unprivileged_user
#    csih_create_local_group
#    csih_service_should_run_as
#    csih_disable_color
#    csih_enable_color
#    csih_path_supports_acls
#    csih_cygver
#    csih_cygver_is_oneseven
#    csih_cygwin_is_64bit
#    csih_win_product_name
#    csih_writable_tmpdir
#    csih_mktemp
#
# DEBUG SUPPORT:
#    csih_stacktrace
#    csih_trace_on
#    csih_trace_off
#
# MUTABLE VARIABLES:
#   csih_sanity_check_server
#       if "yes", the initial sanity check will test for tools only used when
#       installing a service.  As of the time of writing these are "cygrunsrv"
#       and "editrights".
#       This variable must be set in the calling installer script *before*
#       sourcing cygwin-service-installation-helper.sh, otherwise it has no
#       effect.
#   csih_required_commands[]
#       This variable, too, must be set in the calling installer script *before*
#       sourcing cygwin-service-installation-helper.sh, otherwise it has no
#       effect.
#       An array which contains commands used by the calling installer script
#       and the Cygwin package the command is part of.  The commands are tested
#       for existence at startup.  If one or more commands don't exist or are
#       not executable, cygwin-service-installation-helper.sh provides a helpful
#       error message and refuses to run.
#       The array has to be organized in pairs command/package.  The commands
#       *shall* be given with full path, and the installer script *shall* use
#       all external commands always with full paths as well to make sure the
#       required commands are not clobbered by other commands with the same
#       name due to the settings of $PATH.
#       Here's an example how csih_required_commands should be declared in the
#       calling installer script:
#         declare -a csih_required_commands[]=(
#           /usr/bin/ls     coreutils
#           /usr/bin/passwd cygwin
#           /usr/sbin/telnetd inteutils
#         )
#   csih_FORCE_PRIVILEGED_USER
#	if "yes", then create a privileged user even on NT/2k/XP(32)
#       where it is not required (on those versions, LocalSystem
#	will do fine).
#       Set by caller foo-config.
#       NOTE: on NT/2k/XP(32), IF a well-known privileged user already
#             exists and has all necessary capabilities, then it will
#             be used regardless. This variable forces the creation
#             and use of a privileged user, on NT/2k/XP(32), when one does
#             not already exist.
#   SYSCONFDIR
#	default value = "/etc", or set by caller foo-config.
#   LOCALSTATEDIR
#	default value = "/var", or set by caller foo-config.
#   csih_auto_answer
#	default value = "" (no automatic answers)
#       Set by caller foo-config
#   csih_value
#       set by csih_get_value
#       foo-config should treat as read-only
#   csih_cygenv
#       set by csih_get_cygenv
#       foo-config should treat as read-only
#   csih_localized_account_name
#       set by csih_get_localized_account_name, csih_get_guest_account_name
#       foo-config should treat as read-only
#   csih_helper_stdout
#   csih_helper_stderr
#       set by csih_invoke_helper and stores the stdout/stderr of the target
#       program. However, if csih_invoke_helper is called in a subshell (e.g.
#           myResult=$(csih_invoke_helper target arg1 arg2)
#       then these values are not available to the caller outside that subshell.
#       foo-config should treat as read-only
#   csih_ADMINSGID
#   csih_ADMINSUID
#   csih_SYSTEMGID
#   csih_SYSTEMUID
#       these four are set by csih_get_system_and_admins_ids (called by _csih_setup)
#       foo-config should treat as read-only
#   csih_PRIVILEGED_USERNAME
#       Set by csih_select_privileged_username (or by calling
#       csih_create_privileged_user, or as a side-effect of calling
#       csih_service_should_run_as) but may be set explicitly by foo-config
#       foo-config should treat as read-only after first call to any csih_*
#       function
#   csih_PRIVILEGED_USERWINNAME
#	Set by csih_select_privileged_username.  While csih_PRIVILEGED_USERNAME
#	is the Cygwin username, csih_PRIVILEGED_USERWINNAME is the Windows
#	username.  This can be used in conjunction with...
#   csih_PRIVILEGED_USERDOMAIN
#	Set by csih_select_privileged_username.  This is the Windows domain or,
#	on non-domain machines, the machine name.
#   csih_PRIVILEGED_PASSWORD
#       Set by csih_create_privileged_user
#       foo-config treat as read-only. To "prime" the value, pass as first argument
#       when calling csih_create_privileged_user
#   csih_UNPRIVILEGED_USERNAME
#       Set by calling csih_create_unprivileged_user.
#   csih_UNPRIVILEGED_USERWINNAME
#	Set by calling csih_create_unprivileged_user.
#	While csih_UNPRIVILEGED_USERNAME is the Cygwin username,
#	csih_UNPRIVILEGED_USERWINNAME is the Windows username.  This can be
#	used in conjunction with...
#   csih_UNPRIVILEGED_USERDOMAIN
#	Set by calling csih_create_unprivileged_user.  This is the Windows
#	domain or, on non-domain machines, the machine name.
#   csih_LOCAL_GROUPNAME
#       Set by calling csih_create_local_group.
#   csih_LOCAL_GROUPWINNAME
#	Set by calling csih_create_local_group.
#	While csih_LOCAL_GROUPNAME is the Cygwin username,
#	csih_LOCAL_GROUPWINNAME is the Windows username.  This can be
#	used in conjunction with...
#   csih_LOCAL_GROUPDOMAIN
#	Set by calling csih_create_local_group.  This is the Windows
#	domain or, on non-domain machines, the machine name.
#   csih_WIN32_VOLS_WITH_ACLS
#       a ;-separated list of windows volumes that are guaranteed to support
#       ACLS, even if the getVolInfo program doesn't think so. Used to override
#       getVolInfo when it is wrong (use only as a last resort; getVolInfo is
#       actually faster)
#       Set by caller foo-config
#   csih_WIN32_VOLS_WITHOUT_ACLS=
#       a ;-separated list of windows volumes that do NOT support ACLS, even if
#       the getVolInfo program thinks so. Used to override getVolInfo when it
#       is wrong (use only as a last resort; getVolInfo is actually faster)
#       Set by caller foo-config
#
# CONST variables
#   csih_VERSION
#   csih_progname
#   csih_progname_base
#
# ======================================================================
# Initial setup, default values, etc.  PART 1
# ======================================================================
csih_progname=$0
csih_VERSION=0.9.8
readonly csih_progname csih_VERSION

csih_auto_answer=""
csih_value=
csih_cygenv=
csih_localized_account_name=
csih_FORCE_PRIVILEGED_USER=no
csih_ADMINSGID=
csih_ADMINSUID=
csih_SYSTEMGID=
csih_SYSTEMUID=
csih_PRIVILEGED_USERNAME=
csih_PRIVILEGED_USERWINNAME=
csih_PRIVILEGED_USERDOMAIN=
csih_PRIVILEGED_PASSWORD=
csih_UNPRIVILEGED_USERNAME=
csih_UNPRIVILEGED_USERWINNAME=
csih_UNPRIVILEGED_USERDOMAIN=
csih_LOCAL_GROUPNAME=
csih_LOCAL_GROUPWINNAME=
csih_LOCAL_GROUPDOMAIN=
csih_helper_stdout=
csih_helper_stderr=
csih_WIN32_VOLS_WITH_ACLS=
csih_WIN32_VOLS_WITHOUT_ACLS=

# delay initialization
_csih_exec_dir=
_csih_script_dir=

_csih_trace=
_csih_win_product_name="unknown"

if [ -z "${SYSCONFDIR}" ]
then
  SYSCONFDIR=/etc
fi

if [ -z "${LOCALSTATEDIR}" ]
then
  LOCALSTATEDIR=/var
fi

_csih_all_preexisting_privileged_accounts=
_csih_preferred_preexisting_privileged_account=
_csih_setup_already_called=0
_csih_writable_tmpdir_cache_value=
_csih_version_parse_pkg_major=
_csih_version_parse_pkg_minor=
_csih_version_parse_pkg_micro=
_csih_w32vol_as_shell_pattern=
_csih_w32vol_as_shell_pattern_trailing_slash=

_csih_well_known_privileged_accounts="cyg_server
				      sshd_server
				      cron_server
				      $COMPUTERNAME+cyg_server
				      $COMPUTERNAME+sshd_server
				      $COMPUTERNAME+cron_server"
_csih_well_known_privileged_accounts_quoted="'cyg_server'
					     'sshd_server'
					     'cron_server'
					     '$COMPUTERNAME+cyg_server'
					     '$COMPUTERNAME+sshd_server'
					     '$COMPUTERNAME+cron_server'"
readonly _csih_well_known_privileged_accounts _csih_well_known_privileged_accounts_quoted

_csih_ERROR_STR_COLOR="\e[1;31m*** ERROR:\e[0;0m"
_csih_WARN_STR_COLOR="\e[1;33m*** Warning:\e[0;0m"
_csih_INFO_STR_COLOR="\e[1;32m*** Info:\e[0;0m"
_csih_QUERY_STR_COLOR="\e[1;35m*** Query:\e[0;0m"
_csih_STACKTRACE_STR_COLOR="\e[1;36m*** STACKTRACE:\e[0;0m"
readonly _csih_ERROR_STR_COLOR _csih_WARN_STR_COLOR
readonly _csih_INFO_STR_COLOR _csih_QUERY_STR_COLOR _csih_STACKTRACE_STR_COLOR

_csih_ERROR_STR_PLAIN="*** ERROR:"
_csih_WARN_STR_PLAIN="*** Warning:"
_csih_INFO_STR_PLAIN="*** Info:"
_csih_QUERY_STR_PLAIN="*** Query:"
_csih_STACKTRACE_STR_PLAIN="*** STACKTRACE:"
readonly _csih_ERROR_STR_PLAIN _csih_WARN_STR_PLAIN
readonly _csih_INFO_STR_PLAIN _csih_QUERY_STR_PLAIN _csih_STACKTRACE_STR_PLAIN

_csih_ERROR_STR="${_csih_ERROR_STR_COLOR}"
_csih_WARN_STR="${_csih_WARN_STR_COLOR}"
_csih_INFO_STR="${_csih_INFO_STR_COLOR}"
_csih_QUERY_STR="${_csih_QUERY_STR_COLOR}"
_csih_STACKTRACE_STR="${_csih_STACKTRACE_STR_COLOR}"

# ======================================================================
# Routine: csih_disable_color
#   Provided so that scripts which are invoked via postinstall
#   can prevent escape codes from showing up in /var/log/setup.log
# ======================================================================
csih_disable_color()
{
  _csih_ERROR_STR="${_csih_ERROR_STR_PLAIN}"
  _csih_WARN_STR="${_csih_WARN_STR_PLAIN}"
  _csih_INFO_STR="${_csih_INFO_STR_PLAIN}"
  _csih_QUERY_STR="${_csih_QUERY_STR_PLAIN}"
  _csih_STACKTRACE_STR="${_csih_STACKTRACE_STR_PLAIN}"
} # === End of csih_disable_color() === #
readonly -f csih_disable_color

# ======================================================================
# Routine: csih_enable_color
# ======================================================================
csih_enable_color()
{
  _csih_ERROR_STR="${_csih_ERROR_STR_COLOR}"
  _csih_WARN_STR="${_csih_WARN_STR_COLOR}"
  _csih_INFO_STR="${_csih_INFO_STR_COLOR}"
  _csih_QUERY_STR="${_csih_QUERY_STR_COLOR}"
  _csih_STACKTRACE_STR="${_csih_STACKTRACE_STR_COLOR}"
} # === End of csih_enable_color() === #
readonly -f csih_enable_color

# ======================================================================
# Routine: csih_stacktrace
# ======================================================================
csih_stacktrace()
{
  set +x # don''t trace this!
  local -i n=$(( ${#FUNCNAME} - 1 ))
  local val=""
  if [ -n "$_csih_trace" ]
  then
    while [ $n -gt 0 ]
    do
      if [ -n "${FUNCNAME[$n]}" ]
      then
        if [ -z "$val" ]
        then
          val="${FUNCNAME[$n]}[${BASH_LINENO[$(($n-1))]}]"
        else
          val="${val}->${FUNCNAME[$n]}[${BASH_LINENO[$(($n-1))]}]"
        fi
      fi
    n=$(($n-1))
    done
    echo -e "${_csih_STACKTRACE_STR} ${val} ${@}"
  fi
} # === End of csih_stacktrace() === #
readonly -f csih_stacktrace

# ======================================================================
# Routine: csih_trace_on
#   turns on shell tracing of csih functions
# ======================================================================
csih_trace_on()
{
  _csih_trace='set -x'
  trap 'csih_stacktrace "returning with" $?; set -x' RETURN
  set -T
  csih_stacktrace "${@}"
} # === End of csih_trace_on() === #
readonly -f csih_trace_on

# ======================================================================
# Routine: csih_trace_off
#   turns off shell tracing of csih functions
# ======================================================================
csih_trace_off()
{
  trap '' RETURN
  csih_stacktrace "${@}"
  _csih_trace=
  set +x
  set +T
} # === End of csih_trace_off() === #
readonly -f csih_trace_off

# ======================================================================
# Routine: csih_error
#   Prints the (optional) error message $1, then
#   Exits with the error code contained in $? if $? is non-zero, otherwise
#     exits with status 1
#   All other arguments are ignored
# Example: csih_error "missing file"
# NEVER RETURNS
# ======================================================================
csih_error()
{
  local errorcode=$?
  set +x # don't trace this, but we are interested in who called
  csih_stacktrace # we'll see the arguments in the next statement
  if ((errorcode == 0))
  then
    errorcode=1
  fi
  echo -e "${_csih_ERROR_STR} ${1:-no error message provided}"
  exit ${errorcode};
} # === End of csih_error() === #
readonly -f csih_error

# ======================================================================
# Routine: csih_error_multi
#   Prints the (optional) error messages in the positional arguments, one
#     per line, and then
#   Exits with the error code contained in $? if $? is non-zero, otherwise
#     exits with status 1
#   All other arguments are ignored
# Example: csih_error_multi "missing file" "see documentation"
# NEVER RETURNS
# ======================================================================
csih_error_multi()
{
  local errorcode=$?
  set +x # don't trace this, but we are interested in who called
  csih_stacktrace # we'll see the arguments in the next statement
  if ((errorcode == 0))
  then
    errorcode=1
  fi
  while test $# -gt 1
  do
    echo -e "${_csih_ERROR_STR} ${1}"
    shift
  done
  echo -e "${_csih_ERROR_STR} ${1:-no error message provided}"
  exit ${errorcode};
} # === End of csih_error_multi() === #
readonly -f csih_error_multi

# ======================================================================
# Routine: csih_error_recoverable
#   Prints the supplied errormessage, and propagates the $? value
# Example: csih_error_recoverable "an error message"
# ======================================================================
csih_error_recoverable()
{
  local errorcode=$?
  set +x # don't trace this, but we are interested in who called
  csih_stacktrace # we'll see the arguments in the next statement
  echo -e "${_csih_ERROR_STR} ${1}"
  $_csih_trace
  return $errorcode
} # === End of csih_error_recoverable() === #
readonly -f csih_error_recoverable


# ======================================================================
# Routine: csih_warning
#   Prints the supplied warning message
# Example: csih_warning "replacing default file foo"
# ======================================================================
csih_warning()
{
  set +x # don't trace this, but we are interested in who called
  csih_stacktrace # we'll see the arguments in the next statement
  echo -e "${_csih_WARN_STR} ${1}"
  $_csih_trace
} # === End of csih_warning() === #
readonly -f csih_warning

# ======================================================================
# Routine: csih_inform
#   Prints the supplied informational message
# Example: csih_inform "beginning dependency analysis..."
# ======================================================================
csih_inform()
{
  set +x # don't trace this, but we are interested in who called
  csih_stacktrace # we'll see the arguments in the next statement
  echo -e "${_csih_INFO_STR} ${1}"
  $_csih_trace
} # === End of csih_inform() === #
readonly -f csih_inform

# ======================================================================
# Routine: csih_verbose
#   prints the supplied command line
#   executes it
#   returns the error status of the command
# Example: csih_verbose /usr/bin/rm -f /etc/config-file
# ======================================================================
csih_verbose()
{
  set +x # don't trace this, but we are interested in who called
  local rstatus
  csih_stacktrace # we'll see the arguments in the next statement
  echo "${@}" 1>&2
  "${@}"
  rstatus=$?
  $_csih_trace
  return $rstatus
} # === End of csih_verbose() === #
readonly -f csih_verbose

# ======================================================================
# Routine: csih_check_program
#   Check to see that the specified program(s) ($1, $2, ...) are installed
#   and executable by this script.  Returns as soon as it encounters a
#   missing or non-executable program.  Returns 1 if it can't find the
#   program, 2 if it's not executable.
# ======================================================================
csih_check_program()
{
  csih_stacktrace "${@}"
  $_csih_trace
  local prog
  local fullpath

  for prog
  do
    # To maintain backward compatibility, check if hash can find programs
    # which are not given with full path.
    if ! [[ "${prog}" =~ ^/ ]]
    then
      hash "${prog}" 2>/dev/null || return 1
      prog="$(hash -t "${prog}")"
    fi
    test -e ${prog} || return 1
    test -x ${prog} || return 2
  done

  return 0;
} # === End of csih_check_program() === #
readonly -f csih_check_program

# ======================================================================
# Routine: csih_check_program_or_warn
#   Check to see that a specified program ($1) is installed and executable
#   by this script.  If not, warn the user that a particular package
#   ($2) is required and return non-zero (false)
#   Otherwise, return 0 (true)
# ======================================================================
csih_check_program_or_warn()
{
  csih_stacktrace "${@}"
  $_csih_trace
  local prog=${1};
  local pkg=${2:-${1}};

  csih_check_program "${prog}"
  case $? in
  0)
    return 0
    ;;
  1)
    csih_warning "Cannot find required command $prog."
    ;;
  2)
    csih_warning "Cannot execute required program $prog."
    ;;
  esac
  csih_warning "Please (re)install the ${pkg} package.";
  return 1;
} # === End of csih_check_program_or_warn() === #
readonly -f csih_check_program_or_warn

# ======================================================================
# Routine: csih_check_program_or_error
#   Check to see that a specified program ($1) is installed and executable
#   by this script.  If not, inform the user that a particular package
#   ($2) is required, and exit with error
# ======================================================================
csih_check_program_or_error()
{
  csih_stacktrace "${@}"
  $_csih_trace
  local prog=${1};
  local pkg=${2:-${1}};

  csih_check_program "${prog}"
  case $? in
  0)
    return 0
    ;;
  1)
    csih_error_recoverable "Cannot find required command $prog."
    ;;
  2)
    csih_error_recoverable "Cannot execute required program $prog."
    ;;
  esac
  csih_error "Please (re)install the ${pkg} package.";
  return 1;
} # === End of csih_check_program_or_error() === #
readonly -f csih_check_program_or_error

# ======================================================================
# Routine: _csih_sanity_check
#   Check for the set of programs that are used by this script.
#   Exits on failure
# ======================================================================
_csih_sanity_check()
{
  csih_stacktrace "${@}"
  $_csih_trace
  local ret=0
  # Check for programs that this script uses.
  local -a cmd=(
    /usr/bin/awk gawk
    /usr/bin/basename coreutils
    /usr/bin/chmod coreutils
    /usr/bin/cat coreutils
    /usr/bin/chown coreutils
    /usr/bin/cp coreutils
    /usr/bin/cut coreutils
    /usr/bin/cygpath cygwin
    /usr/bin/dirname coreutils
    /usr/bin/expr coreutils
    /usr/bin/getent getent
    /usr/bin/getfacl cygwin
    /usr/bin/grep grep
    /usr/bin/id coreutils
    /usr/bin/ls coreutils
    /usr/bin/mkdir coreutils
    /usr/bin/mkgroup cygwin
    /usr/bin/mkpasswd cygwin
    /usr/bin/mktemp coreutils
    /usr/bin/mount cygwin
    /usr/bin/mv cygwin
    /usr/bin/rm coreutils
    /usr/bin/sed sed
    /usr/bin/setfacl cygwin
    /usr/bin/stat coreutils
    /usr/bin/tr coreutils
    /usr/bin/uname coreutils
    # do not check for editrights and cygrunsrv here -- clients which use this
    # library may not need their functionality.  See below for the function
    # csih_sanity_check_server which can be called by the main script to test
    # for these commands.
  )
  for (( i=0; i < ${#cmd[*]}; i+=2 ))
  do
    csih_check_program_or_warn "${cmd[i]}" "${cmd[i+1]}" || ret=1
  done
  if [ "${csih_sanity_check_server}" = "yes" \
       -o "${csih_sanity_check_server}" = "1" ]
  then
    csih_check_program_or_warn /usr/bin/cygrunsrv cygrunsrv || ret=1
    csih_check_program_or_warn /usr/bin/editrights editrights || ret=1
  fi
  # The calling script may add commands which should be checked.
  # It can do so by defining an array called 'csih_required_commands'.
  # It must consist of pairs command/package, just like the above 'cmd' array.
  for (( i=0; i < ${#csih_required_commands[*]}; i+=2 ))
  do
    if ! [[ "${cmd[@]}" =~ "${csih_required_commands[i]}" ]]
    then
      csih_check_program_or_warn "${csih_required_commands[i]}" "${csih_required_commands[i+1]}" || ret=1
    fi
  done
  if [ $ret -ne 0 ]
  then
    csih_error_multi \
      "There is something badly wrong with your cygwin installation." \
      "" \
      "Please install the missing command(s), and make sure all required" \
      "command are executable.  Otherwise the installation provided by this" \
      "script will fail." \
      "" \
      "To fix this problem, run {rh}setup.exe and (re)install the" \
      "packages mentioned in the warnings above."
  fi
} # === End of _csih_sanity_check() === #
readonly -f _csih_sanity_check

# ======================================================================
# DEPRECATED: csih_sanity_check
#   Stub for backward compatibility
# ======================================================================
function csih_sanity_check()
{
  csih_warning "$csih_progname_base is using deprecated "\
    "function csih_sanity_check. Continuing..."
  true
} # === End of csih_sanity_check() === #
readonly -f csih_sanity_check

# ======================================================================
# Initial setup, default values, etc.  PART 2
#
# This part of the setup has to be deferred since first we have to make
# sure that all required tools are available.  This makes for a bit of
# mess as far as the order of function definitions goes, but since the
# file is sourced, we have to make sure that certain tests are running
# first, especially the test for missing commands used by this script.
#
# Consequentially the call to _csih_sanity_check is done first.
# ======================================================================
_csih_sanity_check

csih_progname_base=$(/usr/bin/basename -- $csih_progname)
readonly csih_progname_base
_csih_sys="$(/usr/bin/uname)"
_csih_xp=0
_csih_nt2003=0
_csih_vista=0
_csih_windows7=0
_csih_windows8=0
_csih_windows8_1=0
_csih_windows10=0
_csih_exactly_server2008=0
_csih_exactly_server2008r2=0
_csih_exactly_server2012=0
_csih_exactly_vista=0
_csih_exactly_windows7=0
_csih_exactly_windows8=0
_csih_exactly_windows8_1=0
_csih_exactly_windows10=0
# If running on NT, check if running under XP(64), 2003 Server, or later
_csih_xp=$(/usr/bin/uname | /usr/bin/awk -F- '{print ( $2 >= 5.1 ) ? 1 : 0;}')
_csih_nt2003=$(/usr/bin/uname | /usr/bin/awk -F- '{print ( $2 >= 5.2 ) ? 1 : 0;}') # also true for XP(64)
_csih_vista=$(/usr/bin/uname | /usr/bin/awk -F- '{print ( $2 >= 6.0 ) ? 1 : 0;}')
_csih_windows7=$(/usr/bin/uname | /usr/bin/awk -F- '{print ( $2 >= 6.1 ) ? 1 : 0;}')
_csih_windows8=$(/usr/bin/uname | /usr/bin/awk -F- '{print ( $2 >= 6.2 ) ? 1 : 0;}')
_csih_windows8_1=$(/usr/bin/uname | /usr/bin/awk -F- '{print ( $2 >= 6.3 ) ? 1 : 0;}')
_csih_windows10=$(/usr/bin/uname | /usr/bin/awk -F- '{print ( $2 >= 6.4 ) ? 1 : 0;}')
readonly _csih_sys _csih_xp _csih_nt2003 _csih_vista _csih_windows7 _csih_windows8 _csih_windows8_1 _csih_windows10
_csih_cygver=$(b=$(/usr/bin/uname -r) && echo "${b%%(*}")
_csih_cygver_is_oneseven=$(echo ${_csih_cygver} | /usr/bin/awk -F. '{print ( $1 > 1 || ($1 == 1 && $2 >= 7) ) ? 1 : 0;}')
_csih_cygwin_is_64bit=$(/usr/bin/uname -m | grep 'x86_64' >/dev/null && echo 1 || echo 0)
readonly _csih_cygver _csih_cygver_is_oneseven _csih_cygwin_is_64bit

# ======================================================================
# Routine: csih_is_nt
#   returns 0 (true)
# ======================================================================
csih_is_nt()
{
  csih_stacktrace "${@}"
  $_csih_trace
  return 0
} # === End of csih_is_nt() === #
readonly -f csih_is_nt
# ======================================================================
# Routine: csih_is_2k
#   returns 0 (true)
# ======================================================================
csih_is_2k()
{
  csih_stacktrace "${@}"
  $_csih_trace
  return 0
} # === End of csih_is_2k() === #
readonly -f csih_is_2k
# ======================================================================
# Routine: csih_is_xp
#   returns 0 (true)
# ======================================================================
csih_is_xp()
{
  csih_stacktrace "${@}"
  $_csih_trace
  return 0
} # === End of csih_is_xp() === #
readonly -f csih_is_xp
# ======================================================================
# Routine: csih_is_nt2003
#   returns 0 (true) if the system is Windows XP 64bit, or Windows
#                    Server 2003 or above.
#   returns 1 (false) otherwise
#
# Note that this routine is somewhat misnamed, since it returns true for
# 64bit Windows XP, but not 32bit Windows XP, as well as the nominal
# "NT Server 2003 and above" operating systems. This is because 64bit XP
# was developed by Microsoft after the release of the 32bit version, and
# unlike the older 32bit XP, the 64bit XP uses the same kernel as the
# (then also under development) Windows Server 2003.  The key point is
# that all Windows operating systems with kernel >= 5.2 (e.g. 64bit
# Windows XP, Windows NT Server 2003, and above) share the same
# restriction with regards to the capabilities of the SYSTEM
# (LocalSystem) account: on those platforms, SYSTEM cannot change the
# effective user.  This is a key capability for services, and many
# 'foo-config' clients use csih_is_nt2003 to check whether a special
# "privileged" user must be created, as do several csih_* functions
# such as csih_select_privileged_username().
# ======================================================================
csih_is_nt2003()
{
  csih_stacktrace "${@}"
  $_csih_trace
  test ${_csih_nt2003} -gt 0
} # === End of csih_is_nt2003() === #
readonly -f csih_is_nt2003
# ======================================================================
# Routine: csih_is_vista
#   returns 0 (true) if the system is Windows Vista/Windows Server 2008
#   or above.
#   returns 1 (false) otherwise
# ======================================================================
csih_is_vista()
{
  csih_stacktrace "${@}"
  $_csih_trace
  test ${_csih_vista} -gt 0
} # === End of csih_is_vista() === #
readonly -f csih_is_vista
# ======================================================================
# Routine: csih_is_windows7
#   returns 0 (true) if the system is Windows 7/Windows Server 2008r2
#   or above.
#   returns 1 (false) otherwise
# ======================================================================
csih_is_windows7()
{
  csih_stacktrace "${@}"
  $_csih_trace
  test ${_csih_windows7} -gt 0
} # === End of csih_is_windows7() === #
readonly -f csih_is_windows7
# ======================================================================
# Routine: csih_is_windows8
#   returns 0 (true) if the system is Windows 8/Windows 8 Server
#   or above.
#   returns 1 (false) otherwise
# ======================================================================
csih_is_windows8()
{
  csih_stacktrace "${@}"
  $_csih_trace
  test ${_csih_windows8} -gt 0
} # === End of csih_is_windows8() === #
readonly -f csih_is_windows8
# ======================================================================
# Routine: csih_is_windows8_1
#   returns 0 (true) if the system is Windows 8.1/Windows 8.1 Server
#   or above.
#   returns 1 (false) otherwise
# ======================================================================
csih_is_windows8_1()
{
  csih_stacktrace "${@}"
  $_csih_trace
  test ${_csih_windows8_1} -gt 0
} # === End of csih_is_windows8_1() === #
readonly -f csih_is_windows8_1
# ======================================================================
# Routine: csih_is_windows10
#   returns 0 (true) if the system is Windows 10/Windows 10 Server
#   or above.
#   returns 1 (false) otherwise
# ======================================================================
csih_is_windows10()
{
  csih_stacktrace "${@}"
  $_csih_trace
  test ${_csih_windows10} -gt 0
} # === End of csih_is_windows10() === #
readonly -f csih_is_windows10
# ======================================================================
# Routine: csih_cygver
#   returns the dotted-triple version number of the currently-running
#      cygwin dll. Avoids forking uname multiple times.
# ======================================================================
csih_cygver()
{
  csih_stacktrace "${@}"
  $_csih_trace
  echo $_csih_cygver
} # === End of csih_cygver() === #
readonly -f csih_cygver
# ======================================================================
# Routine: csih_cygver_is_oneseven
#   returns 0 (true) if the currently-running cygwin dll is version
#      1.7.0 or above (including pre-release betas).
#   returns 1 (false) otherwise
# ======================================================================
csih_cygver_is_oneseven()
{
  csih_stacktrace "${@}"
  $_csih_trace
  return 0
} # === End of csih_cygver_is_oneseven() === #
readonly -f csih_cygver_is_oneseven
# ======================================================================
# Routine: csih_cygwin_is_64bit
#   returns 0 (true) if the currently-running cygwin dll is 64bit
#   returns 1 (false) otherwise
# ======================================================================
csih_cygwin_is_64bit()
{
  csih_stacktrace "${@}"
  $_csih_trace
  test ${_csih_cygwin_is_64bit} -gt 0
} # === End of csih_cygwin_is_64bit() === #
readonly -f csih_cygwin_is_64bit
# ======================================================================
# Routine: csih_is_exactly_vista
#   returns 0 (true) if the system is one of the variants of
#      Windows Vista (Home Basic, Home Premium, Business, etc) but NOT
#      Server2008 or some newer edition (like Windows7)
#   returns 1 (false) otherwise
# ======================================================================
csih_is_exactly_vista()
{
  csih_stacktrace "${@}"
  $_csih_trace
  test ${_csih_exactly_vista} -gt 0
} # === End of csih_is_exactly_vista() === #
#NOTE: do not make _csih_exactly_vista readonly YET

# ======================================================================
# Routine: csih_is_exactly_server2008
#   returns 0 (true) if the system is one of the variants of
#      Windows Server 2008 but NOT one of the variants of Vista, nor
#      some newer edition (like Windows7)
#   returns 1 (false) otherwise
# ======================================================================
csih_is_exactly_server2008()
{
  csih_stacktrace "${@}"
  $_csih_trace
  test ${_csih_exactly_server2008} -gt 0
} # === End of csih_is_exactly_server2008() === #
#NOTE: do not make _csih_exactly_server2008 readonly YET

# ======================================================================
# Routine: csih_is_exactly_windows7
#   returns 0 (true) if the system is one of the variants of
#      Windows 7 (Home Premium, Professional, etc) but NOT Server2008R2
#      or some newer edition like Windows 8.
#   returns 1 (false) otherwise
# ======================================================================
csih_is_exactly_windows7()
{
  csih_stacktrace "${@}"
  $_csih_trace
  test ${_csih_exactly_windows7} -gt 0
} # === End of csih_is_exactly_windows7() === #
#NOTE: do not make _csih_exactly_windows7 readonly YET

# ======================================================================
# Routine: csih_is_exactly_server2008r2
#   returns 0 (true) if the system is one of the variants of
#      Windows Server 2008 R2 but NOT one of the variants of Windows7,
#      nor some newer edition.
#   returns 1 (false) otherwise
# ======================================================================
csih_is_exactly_server2008r2()
{
  csih_stacktrace "${@}"
  $_csih_trace
  test ${_csih_exactly_server2008r2} -gt 0
} # === End of csih_is_exactly_server2008r2() === #
#NOTE: do not make _csih_exactly_server2008r2 readonly YET

# ======================================================================
# Routine: csih_is_exactly_windows8
#   returns 0 (true) if the system is one of the variants of
#      Windows 8 (Home Premium, Professional, etc) but NOT
#      Windows 8 Server or some newer edition.
#   returns 1 (false) otherwise
# ======================================================================
csih_is_exactly_windows8()
{
  csih_stacktrace "${@}"
  $_csih_trace
  test ${_csih_exactly_windows8} -gt 0
} # === End of csih_is_exactly_windows8() === #
#NOTE: do not make _csih_exactly_windows8 readonly YET

# ======================================================================
# Routine: csih_is_exactly_server2012
#   returns 0 (true) if the system is one of the variants of
#      Windows 2012 Server but NOT one of the variants of Windows 8,
#      nor some newer edition.
#   returns 1 (false) otherwise
# ======================================================================
csih_is_exactly_server2012()
{
  csih_stacktrace "${@}"
  $_csih_trace
  test ${_csih_exactly_server2012} -gt 0
} # === End of csih_is_exactly_server2012() === #
#NOTE: do not make _csih_exactly_server2012 readonly YET

# ======================================================================
# Routine: csih_is_exactly_windows8_1
#   returns 0 (true) if the system is one of the variants of
#      Windows 8.1 (Home Premium, Professional, etc) but NOT
#      Windows 8.1 Server or some newer edition.
#   returns 1 (false) otherwise
# ======================================================================
csih_is_exactly_windows8_1()
{
  csih_stacktrace "${@}"
  $_csih_trace
e test ${_csih_exactly_windows8_1} -gt 0
} # === End of csih_is_exactly_windows8_1() === #
#NOTE: do not make _csih_exactly_windows8_1 readonly YET

# ======================================================================
# Routine: csih_is_exactly_server2012r2
#   returns 0 (true) if the system is one of the variants of
#      Windows 2012 Server but NOT one of the variants of Windows 8,
#      nor some newer edition.
#   returns 1 (false) otherwise
# ======================================================================
csih_is_exactly_server2012r2()
{
  csih_stacktrace "${@}"
  $_csih_trace
  test ${_csih_exactly_server2012r2} -gt 0
} # === End of csih_is_exactly_server2012r2() === #
#NOTE: do not make _csih_exactly_server2012r2 readonly YET

# ======================================================================
# Routine: csih_is_exactly_windows10
#   returns 0 (true) if the system is one of the variants of
#      Windows 8 (Home Premium, Professional, etc) but NOT
#      Windows 8 Server or some newer edition.
#   returns 1 (false) otherwise
# ======================================================================
csih_is_exactly_windows10()
{
  csih_stacktrace "${@}"
  $_csih_trace
  test ${_csih_exactly_windows10} -gt 0
} # === End of csih_is_exactly_windows10() === #
#NOTE: do not make _csih_exactly_windows10 readonly YET

# ======================================================================
# Routine: csih_is_exactly_server2016
#   returns 0 (true) if the system is one of the variants of
#      Windows 2016 Server.
#   returns 1 (false) otherwise
# ======================================================================
csih_is_exactly_server2016()
{
  csih_stacktrace "${@}"
  $_csih_trace
  test ${_csih_exactly_server2016} -gt 0
} # === End of csih_is_exactly_server2016() === #
#NOTE: do not make _csih_exactly_server2016 readonly YET

# ======================================================================
# Routine: csih_win_product_name
#   Allows to cache the result of calling winProductName.
# ======================================================================
csih_win_product_name()
{
  csih_stacktrace "${@}"
  $_csih_trace
  echo $_csih_win_product_name
} # === End of csih_win_product_name() === #
#NOTE: do not make _csih_win_product_name readonly YET

# ======================================================================
# Routine: csih_writable_tmpdir
#   Echos to stdout the name of a writable temporary directory, based
#   on the values of $TMP, $TEMP, $TMPDIR, or $HOME, with a fallback to
#   /tmp.  As a last resort, attempts to create /tmp.
#
#   Returns 0 on success, nonzero on error.
# ======================================================================
csih_writable_tmpdir()
{
  csih_stacktrace "${@}"
  $_csih_trace
  local tdir

  if [ -z "${_csih_writable_tmpdir_cache_value}" ]
  then
    if [ -n "${TMP}" -a -d "${TMP}" -a -w "${TMP}" ]
    then
      tdir="${TMP}"
    elif [ -n "${TEMP}" -a -d "${TEMP}" -a -w "${TEMP}" ]
    then
      tdir="${TEMP}"
    elif [ -n "${TMPDIR}" -a -d "${TMPDIR}" -a -w "${TMPDIR}" ]
    then
      tdir="${TMPDIR}"
    elif [ -d "/tmp" -a -w "/tmp" ]
    then
      tdir="/tmp"
    elif [ -n "${HOME}" -a -d "${HOME}" -a -w "${HOME}" ]
    then
      tdir="${HOME}"
    else
      # fall back to creating /tmp manually
      /usr/bin/mkdir -p -m 1777 /tmp
      if [ $? -eq 0 ]
      then
        tdir="/tmp"
      else
        csih_warning "Cannot find or create a writable temporary directory"
        return 1
      fi
    fi
    _csih_writable_tmpdir_cache_value="${tdir}"
  fi
  echo "${_csih_writable_tmpdir_cache_value}"
} # === End of csih_writable_tmpdir() === #
readonly -f csih_writable_tmpdir

# ======================================================================
# Routine: csih_mktemp
#   Safe wrapper around mktemp.  Should be called in a subshell in order
#   to capture the name of the created file: tmpfile="$(csih_mktemp)"
#   By default, mktemp is invoked with
#   --tmpfile="$(csih_writable_tmpdir)"
#   but that may be overridden by explictly specifying a different
#   --tmpdir value.
#
#   Return value is 0 on success, nonzero otherwise.
# ======================================================================
csih_mktemp ()
{
  csih_stacktrace "${@}"
  $_csih_trace

  local __umask=$(umask)
  local rval
  local tmpdir

  tmpdir=$(csih_writable_tmpdir) || return 1

  umask 0077
  /usr/bin/mktemp --tmpdir="${tmpdir}" "$@"
  rval=$?
  umask ${__umask}

  return $rval
} # === End of csih_mktemp() === #
readonly -f csih_mktemp

# ======================================================================
# Routine: csih_version_parse
#   safely parses a version string of the form x.y.z into three
#   separate values.
# ======================================================================
csih_version_parse() {
  local pkg_version="$1"

  # remove any non-digit characters from the version numbers to permit numeric
  _csih_version_parse_pkg_major=$(echo $pkg_version | /usr/bin/cut -d. -f1 | /usr/bin/sed s/[a-zA-Z\-].*//g)
  _csih_version_parse_pkg_minor=$(echo $pkg_version | /usr/bin/cut -d. -f2 | /usr/bin/sed s/[a-zA-Z\-].*//g)
  _csih_version_parse_pkg_micro=$(echo $pkg_version | /usr/bin/cut -d. -f3 | /usr/bin/sed s/[a-zA-Z\-].*//g)
  test -z "$_csih_version_parse_pkg_major" && _csih_version_parse_pkg_major=0
  test -z "$_csih_version_parse_pkg_minor" && _csih_version_parse_pkg_minor=0
  test -z "$_csih_version_parse_pkg_micro" && _csih_version_parse_pkg_micro=0
} # === End of csih_version_parse() === #
readonly -f csih_version_parse

# ======================================================================
# Routine: csih_version_ge
#   Compares two version strings: $1 ad $2 should both be version
#   strings of the form x.y.z
#   returns true if $1 >= $2, when compared as normal version strings
#   returns false otherwise
# Intended use: if client script requires csih of vintage x.y.z or above,
#   if ! csih_version_ge $csih_VERSION x.y.z ; then some error ; fi
# ======================================================================
csih_version_ge() {
  local lh_pkg_version="$1"
  local rh_pkg_version="$2"
  local lh_pkg_major
  local lh_pkg_minor
  local lh_pkg_micro
  local rh_pkg_major
  local rh_pkg_minor
  local rh_pkg_micro

  csih_version_parse "$lh_pkg_version"
  lh_pkg_major=$_csih_version_parse_pkg_major
  lh_pkg_minor=$_csih_version_parse_pkg_minor
  lh_pkg_micro=$_csih_version_parse_pkg_micro

  csih_version_parse "$rh_pkg_version"
  rh_pkg_major=$_csih_version_parse_pkg_major
  rh_pkg_minor=$_csih_version_parse_pkg_minor
  rh_pkg_micro=$_csih_version_parse_pkg_micro

  if [ $lh_pkg_major -gt $rh_pkg_major ]
  then
    return 0
  elif [ $lh_pkg_major -eq $rh_pkg_major ]
  then
    if [ $lh_pkg_minor -gt $rh_pkg_minor ]
    then
      return 0
    elif [ $lh_pkg_minor -eq $rh_pkg_minor ]
    then
      if [ $lh_pkg_micro -ge $rh_pkg_micro ]
      then
        return 0
      fi
    fi
  fi
  return 1
} # === End of csih_version_ge() === #
readonly -f csih_version_ge

# ======================================================================
# Routine: csih_version_le
#   Compares two version strings: $1 ad $2 should both be version
#   strings of the form x.y.z
#   returns true if $1 <= $2, when compared as normal version strings
#   returns false otherwise
# Intended use: if new versions of csih (above x.y.z) break a client script,
# it can warn the user:
#   if ! csih_version_le $csih_VERSION x.y.z ; then some warning ; fi
# (However, rather than adding a warning about an incompatibility, it
# would probably be better to fix the script, or csih...)
# ======================================================================
csih_version_le() {
  local lh_pkg_version="$1"
  local rh_pkg_version="$2"
  local lh_pkg_major
  local lh_pkg_minor
  local lh_pkg_micro
  local rh_pkg_major
  local rh_pkg_minor
  local rh_pkg_micro

  csih_version_parse "$lh_pkg_version"
  lh_pkg_major=$_csih_version_parse_pkg_major
  lh_pkg_minor=$_csih_version_parse_pkg_minor
  lh_pkg_micro=$_csih_version_parse_pkg_micro

  csih_version_parse "$rh_pkg_version"
  rh_pkg_major=$_csih_version_parse_pkg_major
  rh_pkg_minor=$_csih_version_parse_pkg_minor
  rh_pkg_micro=$_csih_version_parse_pkg_micro

  if [ $lh_pkg_major -lt $rh_pkg_major ]
  then
    return 0
  elif [ $lh_pkg_major -eq $rh_pkg_major ]
  then
    if [ $lh_pkg_minor -lt $rh_pkg_minor ]
    then
      return 0
    elif [ $lh_pkg_minor -eq $rh_pkg_minor ]
    then
      if [ $lh_pkg_micro -le $rh_pkg_micro ]
      then
        return 0
      fi
    fi
  fi
  return 1
} # === End of csih_version_le() === #
readonly -f csih_version_le

# ======================================================================
# Routine: csih_version_lt
#   Compares two version strings: $1 ad $2 should both be version
#   strings of the form x.y.z
#   returns true if $1 < $2, when compared as normal version strings
# ======================================================================
csih_version_lt() {
  if csih_version_ge "$1" "$2"
  then
    return 1
  fi
  return 0
} # === End of csih_version_lt() === #
readonly -f csih_version_lt
# ======================================================================
# Routine: csih_version_gt
#   Compares two version strings: $1 ad $2 should both be version
#   strings of the form x.y.z
#   returns true if $1 > $2, when compared as normal version strings
# ======================================================================
csih_version_gt() {
  if csih_version_le "$1" "$2"
  then
    return 1
  fi
  return 0
} # === End of csih_version_gt() === #
readonly -f csih_version_gt
# ======================================================================
# Routine: csih_version_eq
#   Compares two version strings: $1 ad $2 should both be version
#   strings of the form x.y.z
#   returns true if $1 == $2, when compared as normal version strings
# ======================================================================
csih_version_eq() {
  local lh_pkg_version="$1"
  local rh_pkg_version="$2"
  local lh_pkg_major
  local lh_pkg_minor
  local lh_pkg_micro
  local rh_pkg_major
  local rh_pkg_minor
  local rh_pkg_micro

  csih_version_parse "$lh_pkg_version"
  lh_pkg_major=$_csih_version_parse_pkg_major
  lh_pkg_minor=$_csih_version_parse_pkg_minor
  lh_pkg_micro=$_csih_version_parse_pkg_micro

  csih_version_parse "$rh_pkg_version"
  rh_pkg_major=$_csih_version_parse_pkg_major
  rh_pkg_minor=$_csih_version_parse_pkg_minor
  rh_pkg_micro=$_csih_version_parse_pkg_micro

  if [ $lh_pkg_major -eq $rh_pkg_major -a $lh_pkg_minor -eq $rh_pkg_minor -a $lh_pkg_micro -eq $rh_pkg_micro ]
  then
    return 0
  fi
  return 1
} # === End of csih_version_eq() === #
readonly -f csih_version_eq

# ======================================================================
# Routine: _csih_warning_for_etc_file
#   Display a warning message for the user about overwriting the
#   specified file in /etc.
# ======================================================================
_csih_warning_for_etc_file()
{
  csih_stacktrace "${@}"
  csih_warning "The command above overwrites any existing /etc/$1."
  csih_warning "You may want to preserve /etc/$1 before generating"
  csih_warning "a new one, and then compare your saved /etc/$1 file"
  csih_warning "with the newly-generated one in case you need to restore"
  csih_warning "other entries."
} # === End of _csih_warning_for_etc_file() === #
readonly -f _csih_warning_for_etc_file

# ======================================================================
# Routine: csih_request
#   Retrieve user response to a question (in the optional argument $1)
#   Accepts only "yes" or "no", repeats until valid response
#   If csih_auto_answer=="yes", acts as though user entered "yes"
#   If csih_auto_answer=="no", acts as though user entered "no"
#   If "yes" then return 0 (true)
#   If "no" then return 1 (false)
# ======================================================================
csih_request()
{
  csih_stacktrace "${@}"
  local answer=""

  if [ "${csih_auto_answer}" = "yes" ]
  then
    echo -e "${_csih_QUERY_STR} $1 (yes/no) yes"
    return 0
  elif [ "${csih_auto_answer}" = "no" ]
  then
    echo -e "${_csih_QUERY_STR} $1 (yes/no) no"
    return 1
  fi

  while true
  do
    echo -n -e "${_csih_QUERY_STR} $1 (yes/no) "
    if read -e answer
    then
      if [ "X${answer}" = "Xyes" ]
      then
        return 0
      fi
      if [ "X${answer}" = "Xno" ]
      then
        return 1
      fi
    else
      # user did a ^D
      echo -e "Quitting.\n"
      exit 1
    fi
  done
} # === End of csih_request() === #
readonly -f csih_request

# ======================================================================
# Routine: csih_get_value
#   Get a verified non-empty string in variable "csih_value"
#   Prompt with the first argument.
#   The 2nd argument if not empty must be -s. (for "silent" password
#     entry)
# NO AUTOANSWER SUPPORT.
# SETS GLOBAL VARIABLE: csih_value
# ======================================================================
csih_get_value()
{
  csih_stacktrace "${@}"
  local value
  local verify
  while true
  do
    echo -n -e "${_csih_QUERY_STR} "
    if read $2 -p "$1 " value
    then
      [ -n "$2" ] && echo
      if [ -n "${value}" ]
      then
        echo -n -e "${_csih_QUERY_STR} "
        read $2 -p "Reenter: " verify
        [ -n "$2" ] && echo
        [ "${verify}" = "${value}" ] && break
      fi
    else
      # user did a ^D
      echo -e "Quitting.\n"
      exit 1
    fi
  done
  echo
  csih_value="${value}"
  return 0
} # === End of csih_get_value() === #
readonly -f csih_get_value

# ======================================================================
# Routine: csih_get_cygenv
#   Retrieves from user the appropriate value for the CYGWIN environment
#     variable to be used with the installed service.
#   All arguments are interpreted together as the desired default value
#     for CYGWIN.
#
# csih_auto_answer behavior:
#   if set (to either "yes" or "no"), use default value
#
# SETS GLOBAL VARIABLE: csih_cygenv
# ======================================================================
csih_get_cygenv()
{
  csih_stacktrace "${@}"
  $_csih_trace
  local default=$*

  # if there is any auto_answer setting, then accept default
  if [ -n "${csih_auto_answer}" ]
  then
    echo -e "${_csih_QUERY_STR} Enter the value of CYGWIN for the daemon: [${default}] ${default}"
    csih_cygenv="${default}"
    return 0
  fi

  while true
  do
    echo -n -e "${_csih_QUERY_STR} Enter the value of CYGWIN for the daemon: [${default}] "
    if read csih_cygenv
    then
      if [ -z "${csih_cygenv}" ]
      then
        csih_cygenv="${default}"
      fi
      return
    else
      # user did a ^D
      echo -e "Quitting.\n"
      exit 1
    fi
  done
} # === End of csih_get_cygenv() === #
readonly -f csih_get_cygenv

# ======================================================================
# Routine: _csih_get_script_dir
#   private routine to initialize _csih_script_dir
# ======================================================================
_csih_get_script_dir() {
  # should be /usr/share/csih
  local d=$(/usr/bin/dirname -- ${BASH_SOURCE[0]})
  local D=$(cd "$d" && pwd)
  echo "$D"
} # === End of csih_get_script_dir() === #
readonly -f _csih_get_script_dir

# ======================================================================
# Routine: _csih_get_exec_dir
#   private routine to initialize _csih_exec_dir
# ======================================================================
_csih_get_exec_dir() {
  # should be /usr/lib/csih
  local d=$(/usr/bin/dirname -- ${BASH_SOURCE[0]})
  local b=$(/usr/bin/basename -- "$d")
  local D=$(cd "$d/../../lib/$b" >/dev/null 2>&1 && pwd)
  local fullpath=
  if [ -z "$D" ]
  then
    # try /usr/lib/csih explicitly
    if [ -f "/usr/lib/csih/getAccountName.exe" ]
    then
      D=/usr/lib/csih
    else
      # try $PATH
      if hash getAccountName 2>/dev/null
      then
        hash ${prog} 2>/dev/null
        fullpath=$(hash -t getAccountName 2>/dev/null)
        D=$(/usr/bin/dirname -- "$fullpath")
      else
        csih_error_recoverable "Could not locate csih helper programs!"
      fi
    fi
  fi
  echo "$D"
} # === End of csih_get_exec_dir() === #
readonly -f _csih_get_exec_dir

# ======================================================================
# Routine: csih_invoke_helper
#   Launches a helper program shipped with cish
#   returns the exit code of the helper program
#   output:
#     stores stdout in 'csih_helper_stdout', and copies to real stdout
#     stores stderr in 'csih_helper_stderr', and emits as a recoverable
#       error to the real stderr
#   Note that if csih_invoke_helper is executed in a subshell, then
#   the contents of csih_helper_stdout/csih_helper_stderr are not
#   available to the caller.
#
# SETS GLOBAL VARIABLE: csih_helper_stdout csih_helper_stderr
# ======================================================================
csih_invoke_helper()
{
  set +x # don''t trace this, but we are interested in who called
  local result
  local stdout
  local var_out
  local var_err
  local SEP="----- separator -----"
  local helper=
  csih_stacktrace "${@}"
  helper="$1"
  shift
  csih_helper_stdout=""
  csih_helper_stderr=""

  if [ -n "${_csih_exec_dir}" ]
  then
    if [ -f "${_csih_exec_dir}/${helper}" ]
    then
      result=$( { stdout=$("${_csih_exec_dir}/${helper}" "${@}"); } 2>&1; \
        printf "%s\n%d\n%s\n" "${SEP}" $? "${SEP}"; printf "%s" "$stdout" )
      var_out=${result##*${SEP}$'\n'}
      var_err=${result%%$'\n'${SEP}*}
      var_out=${var_out/*${SEP}/}
      var_err=${var_err/${SEP}*/}
      result=${result%$'\n'${SEP}*}
      result=${result#*${SEP}$'\n'}
      if [ -n "${var_err}" ]; then
        csih_helper_stderr=$(echo "$var_err" | /usr/bin/sed -e 's/\r//g')
        csih_error_recoverable "${helper}: ${csih_helper_stderr//\\/\\\\}" 1>&2
      fi
      if [ -n "${var_out}" ]; then
        csih_helper_stdout=$(echo "$var_out" | /usr/bin/sed -e 's/\r//g')
        echo "${csih_helper_stdout}"
      fi
    else
      csih_error "Could not find ${helper} in ${_csih_exec_dir}"
    fi
  else
    csih_error "Could not find csih helper programs!"
  fi

  $_csih_trace
  return $result
} # === End of csih_invoke_helper() === #
readonly -f csih_invoke_helper

# ======================================================================
# Routine: csih_call_winsys32
#   Calls a Windows CLI tool ($1) from the /Windows/System32
#   directory.  The trick here is that we use a full path to call
#   the tool to avoid clobbering by other commands with the same name
#   earlier in $PATH.  In addition, to avoid a problem where different
#   versions of Windows spell the 'system32' directory with different
#   capitalization, AND because we are not sure if the ${SYSTEMROOT}
#   volume is case-sensitive, we exploit a loophole in cygwin's case-
#   sensitive support.  When a command is invoked via a full, DOS-style
#   path, case-insensitive path traversal is used.  Note that
#   'cygpath -m' is used rather than 'cygpath -d' to avoid the
#   "MS-DOS style path detected" warning.
# ======================================================================
csih_call_winsys32()
{
  local tool=$1
  shift
  "$(/usr/bin/cygpath -ma "${SYSTEMROOT}")/system32/${tool}" "$@"
  return $?
}
readonly -f csih_call_winsys32

# ======================================================================
# Routine: csih_get_localized_account_name
#   Obtains the localized account name for the specified well-known
#   account, where $1 indicates by number which account is of interest.
#   The account name is stored in the variable csih_localized_account_name
#   See WELL_KNOWN_SID_TYPE documentation for the association between
#   well known accounts and the $1 numbers accepted here. Of interest:
#      Local Guest:   39
#      Domain Guest:  43
#      Administrator: 38
#   Returns 0 on success, non-zero on failure
#
# SETS GLOBAL VARIABLE: csih_localized_account_name
# ======================================================================
csih_get_localized_account_name()
{
  csih_stacktrace "${@}"
  $_csih_trace
  local rstatus
  local name

  name=$(csih_invoke_helper getAccountName --number $1)
  rstatus=$?
  if [ "$rstatus" -eq 0 ]
  then
    csih_localized_account_name="${name}"
  else
    csih_localized_account_name=""
  fi
  return $rstatus
} # === End of csih_get_localized_account_name() === #
readonly -f csih_get_localized_account_name

# ======================================================================
# Routine: csih_get_guest_account_name
#   Obtains the localized account name for the Guest user.
#   The account name is stored in the variable csih_localized_account_name
#   Returns 0 on success, non-zero on failure
#
# SETS GLOBAL VARIABLE: csih_localized_account_name
# ======================================================================
csih_get_guest_account_name()
{
  csih_stacktrace "${@}"
  $_csih_trace
  local name
  local rstatus

  name=$(csih_invoke_helper getAccountName -g)
  rstatus=$?
  if [ "$rstatus" -eq 0 ]
  then
    csih_localized_account_name="${name}"
  else
    csih_localized_account_name=""
  fi
  return $rstatus
} # === End of csih_get_guest_account_name() === #
readonly -f csih_get_guest_account_name

# ======================================================================
# Routine: _csih_convert_w32vol_to_shell_pattern
#   Converts the path specified as $1 to a shell pattern suitable
#   for use in a case statement.  For instance:
#      E:             -> [Ee]:
#      //server/share -> [\\/][\\/]server[\\/]share
# $1 must be in win32 format
#
# SETS GLOBAL VARIABLES:
#   _csih_w32vol_as_shell_pattern
#   _csih_w32vol_as_shell_pattern_trailing_slash
# ======================================================================
_csih_convert_w32vol_to_shell_pattern()
{
  csih_stacktrace "${@}" 1>&2 # redirect to avoid clobbering stdout
  $_csih_trace
  local has_trailing_slash
  local upperD
  local lowerD
  local w32vol="$1"

  # determine if ends in '/'
  case "${w32vol}" in
  */ ) has_trailing_slash=yes
       w32vol="${w32vol%%/*}"
       ;;
  esac
  # replace all '/' with '[\\/]'
  w32vol="${w32vol//\//[\\\\\/]}"
  # replace leading 'X:' with '[Xx]:'
  if [ "${w32vol:1:1}" = ":" ]
  then
    case "${w32vol:0:1}" in
      [A-Za-z] )
        lowerD=$(echo "${w32vol:0:1}" | /usr/bin/tr '[:upper:]' '[:lower:]')
        upperD=$(echo "${w32vol:0:1}" | /usr/bin/tr '[:lower:]' '[:upper:]')
        w32vol="[${upperD}${lowerD}]:${w32vol:2}"
        ;;
    esac
  fi
  _csih_w32vol_as_shell_pattern="${w32vol}"
  _csih_w32vol_as_shell_pattern_trailing_slash="${has_trailing_slash}"
} # === End of _csih_convert_w32vol_to_shell_pattern() === #
readonly -f _csih_convert_w32vol_to_shell_pattern

# ======================================================================
# Routine: _csih_path_in_volumelist_core
#   Given:
#     $1 == a path in win32 format
#     $2 == a win32-format pathlist (;-separated)
#   Prints 'found' on stdout if
#     $1 is located on one of the volumes specified in $2
#   Silent otherwise
#
# Implementation note: matches are executed in a subshell, so
# we can't use variables to communicate the results. This is why
# stdout is used, and why stacktrace is redirected.
# ======================================================================
_csih_path_in_volumelist_core()
{
  csih_stacktrace "${@}" 1>&2 # redirect to avoid clobbering stdout
  $_csih_trace
  local w32path="$1"
  local volumelist="$2"

  echo "$volumelist" | /usr/bin/tr ';' '\n' | while read p
  do
    _csih_convert_w32vol_to_shell_pattern "$p"
    case "$w32path" in
      ${_csih_w32vol_as_shell_pattern}* )
        printf "found\n"
        ;;
      ${_csih_w32vol_as_shell_pattern}[\\\\/]* )
        if [ -n "${_csih_w32vol_as_shell_pattern_trailing_slash}" ]
        then
          printf "found\n"
        fi
        ;;
    esac
  done
} # === End of _csih_path_in_volumelist_core() === #
readonly -f _csih_path_in_volumelist_core

# ======================================================================
# Routine: _csih_path_in_volumelist
#   Given:
#     $1 == a path in win32 format
#     $2 == a win32-format pathlist (;-separated)
#   Returns 0 if $1 is in $2
#   Returns 1 otherwise
#
# Implementation note; a simple wrapper around *_core(), to hide
# the use of stdout.
# ======================================================================
_csih_path_in_volumelist()
{
  csih_stacktrace "${@}"
  $_csih_trace
  local result=$(_csih_path_in_volumelist_core "$1" "$2")
  if [ "x${result}" = "xfound" ]
  then
    return 0
  fi
  return 1
} # === End of _csih_path_in_volumelist() === #
readonly -f _csih_path_in_volumelist

# ======================================================================
# Routine: csih_path_supports_acls
#   Determines if the specified path is on a volume that supports
#   persistent ACLs. This is used to skip access-permission checks
#   if files are located on a volume that does not support them.
#   Returns 0 on success (yes, path is on a volume that supports ACLs),
#   non-zero on failure (no, it doesn't, or there was some problem making
#   the determination)
#
#   $1 may be in unix or win32 format
#
# NOTE:
#   first checks to see if $1, after conversion to win32 format,
#      is located on one of the volumes listed in the win32-format
#      pathlist csih_WIN32_VOLS_WITH_ACLS. If so, returns true (0).
#      NOTE: the elements of csih_WIN32_VOLS_WITH_ACLS need not
#            exist, although specifying non-existent shares will cause
#            execution delays.
#   then checks to see if $1, after conversion to win32 format,
#      is located on one of the volumes listed in the win32-format
#      pathlist csih_WIN32_VOLS_WITHOUT_ACLS. If so, returns false (1).
#      NOTE: the elements of csih_WIN32_VOLS_WITHOUT_ACLS need not
#            exist, although specifying non-existent shares will cause
#            execution delays.
#   finally, runs the helper program getVolInfo for $1. If the result
#      contains 'FILE_PERSISTENT_ACLS: TRUE', then returns true (0)
#      otherwise, returns false (1)
#      NOTE: this test will return false if $1 specifies a volume that
#            does not exist.
# ======================================================================
csih_path_supports_acls()
{
  csih_stacktrace "${@}"
  $_csih_trace
  local output
  local rstatus
  if [ -z "$1" ]
  then
    csih_warning "Internal: csih_path_supports_acls called with no argument"
    return 1
  fi

  # convert to w32 format
  w32path=$(/usr/bin/cygpath -m "$1")

  if _csih_path_in_volumelist "$w32path" "$csih_WIN32_VOLS_WITH_ACLS"
  then
    return 0
  fi

  if _csih_path_in_volumelist "$w32path" "$csih_WIN32_VOLS_WITHOUT_ACLS"
  then
    return 1
  fi

  output=$(csih_invoke_helper getVolInfo "$1" | /usr/bin/grep "FILE_PERSISTENT_ACLS" 2>/dev/null)
  rstatus=$?
  if [ "$rstatus" -eq 0 ]
  then
      echo "$output" | /usr/bin/grep "TRUE" || rstatus=2
  fi
  return $rstatus
} # === End of csih_path_supports_acls() === #
readonly -f csih_path_supports_acls

# ======================================================================
# Routine: csih_guest_account_active
#   Returns true (0) if the Guest account is active
#   Returns false (non-zero) otherwise.
#
# SETS GLOBAL VARIABLE: csih_localized_account_name
# ======================================================================
csih_guest_account_active() {
  csih_stacktrace "${@}"
  $_csih_trace
  local rstatus=1
  local str

  if csih_get_guest_account_name
  then
    str=$(csih_call_winsys32 net user "$csih_localized_account_name" |\
          /usr/bin/sed -n -e '/^Account active/s/^Account active *//p' |\
          /usr/bin/tr '[:upper:]' '[:lower:]')
    if [ "$str" = "yes" ]
    then
      rstatus=0
      return $rstatus
    fi
  fi
  return $rstatus
} # === End of csih_guest_account_active() === #
readonly -f csih_guest_account_active

# ======================================================================
# Routine: csih_install_config
#   Installs the specified file ($1) by copying the default file
#   located in the defaults directory ($2). Asks before overwriting.
#   ${2}/${1} must exist. All directory components on ${1} must exist.
#   Returns 0 on success, non-zero on failure
# ======================================================================
csih_install_config()
{
  csih_stacktrace "${@}"
  $_csih_trace
  local dest;
  local DEFAULTSDIR;

  if [ -z "$1" ]
  then
    return
  fi
  if [ -z "$2" ]
  then
    return
  fi

  dest=$1;
  DEFAULTSDIR=$2

  if [ -f "$dest" ]
  then
    if ! csih_request "Overwrite existing ${dest} file?"
    then
      return 0
    fi
    /usr/bin/rm -f "${dest}"
    if [ -f "${dest}" ]
    then
      csih_warning "Can't overwrite. ${dest} is write protected."
    fi
  fi


  if [ ! -f "${dest}" ]
  then
    if [ ! -f "${DEFAULTSDIR}/${dest}" ]
    then
      csih_warning "Can't create ${dest} because default version could not be found."
      csih_warning "Check '${DEFAULTSDIR}'"
    else
      csih_inform "Creating default ${dest} file"
      /usr/bin/cp ${DEFAULTSDIR}/${dest} ${dest}
      return $?
    fi
  fi
  return 1
} # === End of csih_install_config() === #
readonly -f csih_install_config

# ======================================================================
# Routine: csih_make_dir
#   Creates the specified directory if it does not already exist.
#   Exits on failure.
# ======================================================================
csih_make_dir()
{
  csih_stacktrace "${@}"
  $_csih_trace
  local DIR;
  if [ -z "$1" ]
  then
    return
  fi
  DIR=$1
  shift

  if [ -e "${DIR}" -a ! -d "${DIR}" ]
  then
    if [ -n "$1" ]
    then
      csih_error_multi "${DIR} exists, but is not a directory." "$1"
    else
      csih_error "${DIR} exists, but is not a directory."
    fi
  fi

  if [ ! -e "${DIR}" ]
  then
    /usr/bin/mkdir -p "${DIR}"
    if [ ! -e "${DIR}" ]
    then
      csih_error "Creating ${DIR} directory failed."
    fi
  fi
} # === End of csih_make_dir() === #
readonly -f csih_make_dir

# ======================================================================
# Routine: csih_get_system_and_admins_ids
#   Get the ADMINs ids from user and group account databases
#   Returns 0 (true) on success, 1 otherwise.
# SETS GLOBAL VARIABLES:
#   csih_ADMINSGID
#   csih_ADMINSUID
#   csih_SYSTEMGID
#   csih_SYSTEMUID
# ======================================================================
csih_get_system_and_admins_ids()
{
  csih_stacktrace "${@}"
  $_csih_trace
  local ret=0

  # require Administrators group and SYSTEM
  csih_ADMINSGID="$(/usr/bin/getent -w group S-1-5-32-544)"
  csih_ADMINSGID="${csih_ADMINSGID#*:}"
  csih_ADMINSGID="${csih_ADMINSGID%%:*}"
  csih_SYSTEMGID="$(/usr/bin/getent -w group S-1-5-18)"
  csih_SYSTEMGID="${csih_SYSTEMGID#*:}"
  csih_SYSTEMGID="${csih_SYSTEMGID%%:*}"
  if [ -z "$csih_ADMINSGID" -o -z "$csih_SYSTEMGID" ]
  then
    csih_warning "It appears that you do not have entries for the local"
    csih_warning "ADMINISTRATORS and/or SYSTEM sids in /etc/group."
    csih_warning ""
    csih_warning "Use the 'mkgroup' utility to generate them or allow \"db\""
    csih_warning "search of group accounts in /etc/nsswitch.conf"
    csih_warning ""
    ret=1;
  fi

  # only require SYSTEM passwd entry; warn if either is missing
  csih_ADMINSUID="$(/usr/bin/getent -w passwd S-1-5-32-544)"
  csih_ADMINSUID="${csih_ADMINSUID#*:}"
  csih_ADMINSUID="${csih_ADMINSUID%%:*}"
  csih_SYSTEMUID="$(/usr/bin/getent -w passwd S-1-5-18)"
  csih_SYSTEMUID="${csih_SYSTEMUID#*:}"
  csih_SYSTEMUID="${csih_SYSTEMUID%%:*}"
  if [ -z "$csih_ADMINSUID" -o -z "$csih_SYSTEMUID" ]
  then
    csih_warning "It appears that you do not have an entry for the local"
    csih_warning "ADMINISTRATORS (group) and/or SYSTEM sids."
    csih_warning ""
    csih_warning "Use the 'mkpasswd' utility to generate it or allow \"db\""
    csih_warning "search of passwd accounts in /etc/nsswitch.conf"
    csih_warning ""
    if [ -z "$csih_SYSTEMUID" ]
    then
      ret=1
    fi
  fi
  return "${ret}"
} # === End of csih_get_system_and_admins_ids() === #
readonly -f csih_get_system_and_admins_ids

# ======================================================================
# Routine: csih_check_passwd_and_group
#   Check to see whether the user's password ID and group exist in the
#   system account databases, respectively.
#   Returns 0 (true) on success, 1 otherwise.
# ======================================================================
csih_check_passwd_and_group()
{
  csih_stacktrace "${@}"
  $_csih_trace
  local ret=0
  # Check for mkpasswd/mkgroup only valid up to Cygwin 1.7.33
  if csih_old_cygwin
  then
    if [ "$(/usr/bin/id -un)" = "mkpasswd" ]
    then
      csih_warning "It appears that you do not have an entry for your user ID"
      csih_warning "in /etc/passwd."
      csih_warning ""
      csih_warning "If so, use the 'mkpasswd' utility to generate an"
      csih_warning "entry for your User ID in the password file:"
      csih_warning "   mkpasswd -l -u User_ID >> /etc/passwd"
      csih_warning "or"
      csih_warning "   mkpasswd -d -u User_ID >> /etc/passwd."
      csih_warning ""
      _csih_warning_for_etc_file passwd
      ret=1
    fi
    if [ "$(/usr/bin/id -gn)" = mkgroup ]
    then
      csih_warning "It appears that you do not have an entry for your group ID"
      csih_warning "in /etc/group.  If this check is incorrect, then re-run"
      csih_warning "this script with the '-f' command-line option."
      csih_warning ""
      csih_warning "Otherwise, use the 'mkgroup' utility to generate an"
      csih_warning "entry for your group ID in the password file:"
      csih_warning "   mkgroup -l -g Group_id  >> /etc/group"
      csih_warning "or"
      csih_warning "   mkgroup -d -g Group_id >> /etc/group."
      csih_warning ""
      _csih_warning_for_etc_file group
      ret=1
    fi
  else
    if ! getent passwd $(/usr/bin/id -un) >/dev/null 2>&1
    then
      csih_warning "It appears that you do not have an entry for your user ID"
      csih_warning "in the user account database."
      csih_warning ""
      csih_warning "Please check the settings in /etc/nsswitch.conf."
      ret=1
    fi
    if ! getent group $(/usr/bin/id -gn) >/dev/null 2>&1
    then
      csih_warning "It appears that you do not have an entry for your user ID"
      csih_warning "in the group account database."
      csih_warning ""
      csih_warning "Please check the settings in /etc/nsswitch.conf."
      ret=1
    fi
  fi
  return "${ret}"
} # === End of csih_check_passwd_and_group() === #
readonly -f csih_check_passwd_and_group


# ======================================================================
# Routine: csih_check_user
#   Check to see that the specified user exists in the user account database
#   Returns 0 (true) if so, 1 otherwise.
# ======================================================================
csih_check_user()
{
  csih_stacktrace "${@}"
  $_csih_trace
  if ! /usr/bin/getent passwd "$1" >/dev/null 2>&1
  then
    csih_warning "User $1 does not appear in the user account database."
    return 1;
  fi
  return 0
} # === End of csih_check_user() === #
readonly -f csih_check_user

# ======================================================================
# Routine: _csih_warning_for_missing_ACL_support
#   Display a warning message for the user about files located on
#   volumes that do not support persistent ACLS -- e.g. FAT drives,
#   noacl, etc.
# ======================================================================
_csih_warning_for_missing_ACL_support()
{
  csih_stacktrace "${@}"
  csih_warning "$1 exists on a volume that does not support accurate"
  csih_warning "permissions (perhaps formatted FAT?).  Therefore, we"
  csih_warning "cannot verify access to the file or directory."
  csih_warning "Please consider, if possible and appropriate, one of the"
  csih_warning "following remedies:"
  csih_warning "  1) converting to NTFS using 'convert.exe'"
  csih_warning "  2) mounting the relevant volume using the 'acl' option"
}
# === End of _csih_warning_for_missing_ACL_support() === #
readonly -f _csih_warning_for_missing_ACL_support

# ======================================================================
# Routine: csih_check_dir_perms
#   Check to see that the specified directory ($1) exists and has the
#   permissions ($2).
#   Returns 0 (true) if so, 1 otherwise.
# ======================================================================
csih_check_dir_perms()
{
  csih_stacktrace "${@}"
  $_csih_trace
  if [ ! -e "$1" ]
  then
    csih_warning "Your computer is missing $1".
    return 1
  fi

  if ! csih_path_supports_acls "$1"
  then
    _csih_warning_for_missing_ACL_support "$1"
    csih_warning "Continuing, but something might break..."
    return 0
  fi

  if /usr/bin/stat -c "%A" "$1" | /usr/bin/grep -Eq ^"$2"
  then
    true
  else
    csih_warning "The permissions on the directory $1 are not correct."
    csih_warning "They must match the regexp $2"
    return 1
  fi
} # === End of csih_check_dir_perms() === #
readonly -f csih_check_dir_perms

# ======================================================================
# Routine: csih_check_access
#   Check to see that the owner and Administrators have
#   proper access to the file or directory.
#     $1 -- the file or directory to check
#     $2 -- three character symbolic permissions: 'rwx'. '.w.', etc.
#   On installations older than Windows 2003 and Vista, allow access
#   by System
# NOTE: must call csih_get_system_and_admins_ids first
# ======================================================================
csih_check_access()
{
  csih_stacktrace "${@}"
  $_csih_trace
  local file="$1"
  local perm="$2"
  local msg="$3"
  local notify=0;
  local ls_result="$(/usr/bin/ls -dLln "$file" 2> /dev/null)"

  if [ -z "$csih_ADMINSGID" ]
  then
    csih_get_system_and_admins_ids
    if [ $? -ne 0 ]
    then
      return $?
    fi
  fi

  if ! csih_path_supports_acls "$file"
  then
    _csih_warning_for_missing_ACL_support "$fild"
    csih_warning "Continuing, but something might break..."
    return 0
  fi

  # If the owner of the file does not have access,
  # then notify the user.
  if [ -z "$(echo "$ls_result" | /usr/bin/sed -n /^."$perm"/p)" ]
  then
    notify=1;

  # If the 'Administrators' group has owner or group access to the file,
  # but does not have the desired access, then notify the user.

  elif ( [ -n "$csih_ADMINSUID" -a "$(echo "$ls_result" | /usr/bin/awk '{ print $3 }')" -eq $csih_ADMINSUID ] || \
         ( ! csih_is_nt2003 && [ -n "$csih_SYSTEMUID" -a "$(echo "$ls_result" | /usr/bin/awk '{ print $3 }')" -eq $csih_SYSTEMUID ] ))
  then
    # Administrators group owns the file, or (on < NT2003,XP64) SYSTEM owns the file
    # this is ok; do nothing.
    true;
  elif ( [ "$(echo "$ls_result" | /usr/bin/awk '{ print $4 }')" -eq $csih_ADMINSGID ] || \
         ( ! csih_is_nt2003 && [ "$(echo "$ls_result" | /usr/bin/awk '{ print $4 }')" -eq $csih_SYSTEMGID ] ))
  then
    # The Administrators group has group access to the file, or
    # (on < NT2003,XP64) SYSTEM has group access to the file.  Check to
    # see if the chmod bits for group allow these groups to have
    # "owner-like" access to the file.  If not, notify.
    [ -z "$(echo "$ls_result" | /usr/bin/sed -n /^...."$perm"/p)" ] && notify=1
  elif ( [ -n "$(/usr/bin/getfacl -n "$file" | /usr/bin/sed -n /^group:"$csih_ADMINSGID":"$perm"/p )" ] || \
         ( ! csih_is_nt2003 && [ -n "$(/usr/bin/getfacl -n "$file" | /usr/bin/sed -e /^group:"$csih_SYSTEMGID":"$perm"/p )" ] ))
  then
    # There exists an extended ACL entry for the Administrators (or
    # SYSTEM group, pre NT2003,XP64), with the desired owner-like permissions.
    # This is ok.
    true;
  else
    # otherwise, we do /not/ have sufficient access to the file.
    notify=1
  fi

  if [ "$notify" -eq 1 ]; then
    csih_warning "The owner and the Administrators need"
    csih_warning "to have $perm permission to $file."
    csih_warning "Here are the current permissions and ACLS:"
    ls_result=$(/usr/bin/ls -dlL "${file}" 2>&1)
    csih_warning "    $ls_result"
    /usr/bin/getfacl "${file}" 2>&1 | while read LN
    do
      csih_warning "    $LN"
    done
    csih_warning "Please change the user and/or group ownership, "
    csih_warning "permissions, or ACLs of $file."
    echo
    [ -z "${msg}" ] || csih_warning "${msg}"
    return 1;
  fi
} # === End of csih_check_access() === #
readonly -f csih_check_access

# ======================================================================
# Routine: csih_check_sys_mount
#   Deprecated.  Always return 0.
# ======================================================================
csih_check_sys_mount()
{
  csih_stacktrace "${@}"
  $_csih_trace
  return 0
} # === End of csih_check_sys_mount() === #
readonly -f csih_check_sys_mount

# ======================================================================
# DEPRECATED: csih_check_basic_mounts
#   Stub for backward compatibility
# ======================================================================
csih_check_basic_mounts()
{
  csih_warning "$csih_progname_base is using deprecated "\
    "function csih_check_basic_mounts. Continuing..."
  true
} # === End of csih_check_basic_mounts() === #
readonly -f csih_check_basic_mounts

# ======================================================================
# Routine: csih_privileged_accounts [-u username]
#   Determines the names of all known "privileged" users already created
#   on this system, or known to this system (e.g. domain users)
#   Checks for cyg_server, sshd_server, cron_server as well as 'username'
#   passed as an argument to the -u option, if specified.  The -u username
#   will be preferred over the default names, but of those default names,
#   cyg_server is preferred.  However, it is taken on faith that if
#   'username' exists, it is, in fact, privileged and not an "ordinary" user.
#   Avoids rechecking if already set.
#
# SETS GLOBAL (PRIVATE) VARIABLES:
#   _csih_all_preexisting_privileged_accounts
#   _csih_preferred_preexisting_privileged_account
# ======================================================================
csih_privileged_accounts()
{
  csih_stacktrace "${@}"
  $_csih_trace
  local opt_username
  local pwd_entries
  local domain
  local username
  local take_it
  local accounts
  local first_account

  # always parse "command line"
  OPTIND=0
  while getopts ":u:" options; do
    case $options in
      u  ) opt_username="$OPTARG" ;;
      \? ) csih_warning "${FUNCNAME[0]} ignoring invalid option: $OPTARG" ;;
      \: ) csih_warning "${FUNCNAME[0]} ignoring option missing required argument: $OPTARG" ;;
    esac
  done
  shift $(($OPTIND - 1))
  [ -n "${1}" ] && opt_servicename="${1}"

  if [ -z "${_csih_all_preexisting_privileged_accounts}" ]
  then
    # First check optional username from command line
    if [ -n "$opt_username" ]
    then
      pwd_entries=$(/usr/bin/getent -w passwd "$opt_username")
      # Extract Cygwin username and Windows domain
      username="${pwd_entries%%:*}"
      domain="${pwd_entries#*:*:}"
      domain="${domain%\\*}"
      take_it=1
      # Local SAM account?  Check privileges
      [ "${COMPUTERNAME,,*}" = "${domain,,*}" ] \
      && ! csih_account_has_necessary_privileges "$username" && take_it=0
      if [ $take_it -eq 0 ]
      then
	# -u $opt_username does NOT have the required privileges,
	# even though it exists.  Warn, and skip
	csih_warning "Privileged account '$opt_username' was specified,"
	csih_warning "but it does not have the necessary privileges."
	csih_warning "Continuing, but will probably use a different account."
      else
	first_account="${username}"
	accounts="'${username}' "
      fi
    fi
    # Then check predefined Cygwin service accounts
    pwd_entries=$(/usr/bin/getent passwd $_csih_well_known_privileged_accounts \
		  | /usr/bin/cut -d: -f 1)
    for username in $pwd_entries
    do
      [ -z "${first_account}" ] && first_account="${username}"
      accounts="${accounts}'${username}' "
    done
    if [ -n "${accounts}" ]
    then
      _csih_all_preexisting_privileged_accounts="${accounts}"
      _csih_preferred_preexisting_privileged_account="${first_account}"
    fi
  fi
} # === End of csih_privileged_accounts() === #
readonly -f csih_privileged_accounts

# ======================================================================
# Routine: csih_privileged_account_exists
#   On Windows NT and above, determines if the specified
#   user ${1} exists and is one of the well-known privileged users
#   (cyg_server, sshd_server, cron_server), or actually does possess
#   the required privileges.
#   Returns 0 (true) if so, 1 otherwise.
# ======================================================================
csih_privileged_account_exists()
{
  csih_stacktrace "${@}"
  $_csih_trace
  csih_privileged_accounts -u "$1"
  if [ -n "${_csih_all_preexisting_privileged_accounts}" ]
  then
    case "${_csih_all_preexisting_privileged_accounts}" in
      *" '$1' "* | "'$1' "* | *" '$1'" | "'$1'") true;;
      *) false;;
    esac
  else
    false
  fi
} # === End of csih_privileged_account_exists() === #
readonly -f csih_privileged_account_exists

# ======================================================================
# Routine: csih_account_has_necessary_privileges
#   On Windows NT and above, checks whether the specified account $1
#   has the privileges necessary to change user contexts.
#   Returns 0 (true) if so, 1 otherwise.
#   Also returns false if $1 is unspecified, or $1 doesn't exist.
# ======================================================================
csih_account_has_necessary_privileges() {
  csih_stacktrace "${@}"
  $_csih_trace

  local user="$1"
  if [ -n "${user}" ]
  then
    if ! csih_check_program_or_warn /usr/bin/editrights editrights
    then
      csih_warning "The 'editrights' program cannot be found or is not executable."
      csih_warning "Unable to ensure that '${user}' has the appropriate privileges."
      return 1
    else
      # Don't attempt to validate membership in Administrators group
      # Instead, just try to set the appropriate rights; if it fails
      # then handle that, instead.
      /usr/bin/editrights -u "${user}" -t SeAssignPrimaryTokenPrivilege >/dev/null 2>&1 &&
      /usr/bin/editrights -u "${user}" -t SeCreateTokenPrivilege        >/dev/null 2>&1 &&
      /usr/bin/editrights -u "${user}" -t SeTcbPrivilege                >/dev/null 2>&1 &&
      /usr/bin/editrights -u "${user}" -t SeServiceLogonRight           >/dev/null 2>&1
      return # status of previous command-list
    fi
  fi
  false
} # === End of csih_account_has_necessary_privileges() === #
readonly -f csih_account_has_necessary_privileges


# ======================================================================
# Routine: _csih_setup
#   Basic checks for all clients of this script. It is the final
#   initialization phase for csih, and unlike the other phases -- which
#   execute as soon as csih is sourced by the client script -- this
#   initialization is peformed at "runtime".  That is, it is called
#   internally by any "public" API function for which the initialiation
#   is needed.
#
#   _csih_setup internally handles repeated calls, and initialization
#   is skipped if already performed.
#
#   Exits if anything is wrong.
# ======================================================================
_csih_setup()
{
  local uid
  local gid
  local user_sid
  local grp_sid
  local perms="d..x..x..[xt]"

  csih_stacktrace "${@}"
  $_csih_trace
  if [ "$_csih_setup_already_called" -eq 0 ]
  then

    if [ -z "${SYSCONFDIR}" ]
    then
      csih_error "Variable SYSCONFDIR is empty (should be '/etc' ?)"
    fi

    if [ -z "${LOCALSTATEDIR}" ]
    then
      csih_error "Variable LOCALSTATEDIR is empty (should be '/var' ?)"
    fi

    if ! csih_get_system_and_admins_ids
    then
      csih_error "Problem with LocalSystem or Adminstrator IDs"
    fi

    uid=$(/usr/bin/stat -c '%u' ${LOCALSTATEDIR})
    gid=$(/usr/bin/stat -c '%g' ${LOCALSTATEDIR})
    user_sid=$(/usr/bin/getent -w passwd $uid | awk -F: '{print $4}')
    grp_sid=$(/usr/bin/getent -w group $gid | awk -F: '{print $4}')

    if [ "${user_sid}" = "${grp_sid}" ]
    then
      perms="d..x.....[xt]"
    fi

    if ! csih_check_dir_perms "${LOCALSTATEDIR}" "${perms}"
    then
      csih_error "Problem with ${LOCALSTATEDIR} directory. Exiting."
    fi

    # attempt to set permissions, but not an error if fail
    # will verify that we actually HAVE correct permissions below.
    csih_make_dir "${LOCALSTATEDIR}/run"
    /usr/bin/chmod 1777 "${LOCALSTATEDIR}/run" >&/dev/null || true
    /usr/bin/setfacl -m u:system:rwx "${LOCALSTATEDIR}/run" >&/dev/null || true
    /usr/bin/setfacl -m g:544:rwx "${LOCALSTATEDIR}/run" >&/dev/null || true

    csih_make_dir "${LOCALSTATEDIR}/log"
    /usr/bin/chmod 1777 "${LOCALSTATEDIR}/log" >&/dev/null || true
    /usr/bin/setfacl -m u:system:rwx "${LOCALSTATEDIR}/log" >&/dev/null || true
    /usr/bin/setfacl -m g:544:rwx "${LOCALSTATEDIR}/log" >&/dev/null || true

    csih_make_dir "${LOCALSTATEDIR}/empty"
    /usr/bin/chmod 755 "${LOCALSTATEDIR}/empty" >&/dev/null || true
    /usr/bin/setfacl -m u:system:r-x "${LOCALSTATEDIR}/empty" >&/dev/null || true
    /usr/bin/setfacl -m g:544:r-x "${LOCALSTATEDIR}/empty" >&/dev/null || true

    # daemons need write access to /var/run to create pid file
    if ! csih_check_access "${LOCALSTATEDIR}/run" .w.
    then
      csih_error "Problem with ${LOCALSTATEDIR}/run directory. Exiting."
    fi
    # daemons need write access to /var/log if they do their own logging
    if ! csih_check_access "${LOCALSTATEDIR}/log" .w.
    then
      csih_error "Problem with ${LOCALSTATEDIR}/log directory. Exiting."
    fi
    # daemons need access to /var/empty for chrooting
    if ! csih_check_access "${LOCALSTATEDIR}/empty" r.x
    then
      csih_error "Problem with ${LOCALSTATEDIR}/empty directory. Exiting."
    fi

    # just ensure that /etc exists. It is up to clients of this
    # script to explicitly check accees to the specific configuration
    # files inside /etc...
    csih_make_dir "${SYSCONFDIR}"
    /usr/bin/chmod 755 "${SYSCONFDIR}" >&/dev/null || true

    _csih_setup_already_called=1
  fi
} # === End of _csih_setup() === #
readonly -f _csih_setup

# ======================================================================
# Routine: csih_old_cygwin
#   Check Cygwin version, account databases are avaiable since 1.7.34
#   On Cygwin versions <= 1.7.33 return 0
#   On Cygwin versions >  1.7.33 return 1
# ======================================================================
csih_old_cygwin()
{
  local old_cygwin

  /usr/bin/uname -r |
  /usr/bin/awk -F. '{
                     if ( $1 < 1 || \
                         ($1 == 1 && $2 < 7) || \
                         ($1 == 1 && $2 == 7 && strtonum($3) <= 33))
                       exit 0;
                     exit 1;
                   }'
  old_cygwin=$?
  return ${old_cygwin}
} # === End of csih_old_cygwin() === #
readonly -f csih_old_cygwin

# ======================================================================
# Routine: csih_use_file_etc passwd|group
#   Check if /etc/passwd or /etc/group file is in use.
#   On Cygwin versions < 1.7.33, files are always used.
#   On Cygwin versions >= 1.7.33 it depends on /etc/nsswitch.conf.
#
#     If /etc/nsswitch.conf doesn't exit, "db" is used and we don't
#     need the files.
#
#     If /etc/nsswitch.conf exists, and passwd/group lines contain
#     the "db" entry, "db" is used and we don't need the files.
#
#     If /etc/nsswitch.conf exists, and no passwd/group lines are
#     present, "db" is used by default and we don't need the files.
#
#     Otherwise, we need the files.
#
#   Returns 0 if files shall be used, 1 otherwise.
# ======================================================================
csih_use_file_etc()
{
  local file="$1"
  local use_file

  if [ "$file" != "passwd" -a "$file" != "group" ]
  then
    csih_error 'Script error: csih_use_file_etc requires argument "passwd" or "group".'
  fi
  csih_old_cygwin ; use_file=$?
  if [ ${use_file} -ne 0 -a -f /etc/nsswitch.conf ]
  then
    if grep -Eq "^${file}:" /etc/nsswitch.conf
    then
      grep -Eq "^${file}:[^#]*\<db\>" /etc/nsswitch.conf || use_file=0
    fi
  fi
  return ${use_file}
} # === End of csih_use_file_etc() === #
readonly -f csih_use_file_etc

# ======================================================================
# Routine: csih_select_privileged_username [-q] [-f] [-u default_user] [service_name]
#   On NT and above, get the desired privileged account name.
#
#   If the optional argument '-q' is specified, then this function will
#      operate in query mode, which is more appropriate for user-config
#      scripts that need information ABOUT a service, but do not
#      themselves install the service.
#
#   If the optional argument '-f' is specified, then no confirmation
#      questions will be asked about the selected username. This is
#      useful mainly in unattended installations.
#
#   If the optional argument '-u' is specified, then the next
#      argument will be used as the "privileged" username -- UNLESS
#      [service_name] is provided, and that service is already
#      installed under some OTHER username.  In the latter case, the
#      current user under which [service_name] is installed will be
#      used, and the value specified by -u will be IGNORED.
#
#   If the optional [service_name] argument is present, then that value
#      may be used in some of the messages. Also, this function will
#      then check to see if [service_name] is already installed. If so,
#      the account under which it is installed will be selected, assuming
#      it passes validation (has necessary permissions, group memberships,
#      etc)
#
# Usually [service_name] and [-q] should be specified together.
#    [-f] can be set regardless of other options.
#
# SETS GLOBAL VARIABLE:
#   csih_PRIVILEGED_USERNAME
#   csih_PRIVILEGED_USERWINNAME
#   csih_PRIVILEGED_USERDOMAIN
#   OPTIND
#   OPTARG
#
# csih_auto_answer=no behavior
#   if [service_name] and [-q] and [service_name] is installed
#     get account under which it is installed
#     validate account (may issue error!)
#     use that account name
#   elif $default_username is specified, exists, and has necessary privileges,
#     use $default_username
#   elif any(cyg_server cron_server sshd_server) exists,
#     use first in list
#   else
#     if csih_is_nt2003 || csih_FORCE_PRIVILEGED_USER # note: csih_is_nt2003 true for XP64 too
#       if $default_username is specified
#          use $default_username
#       else
#          use cyg_server
#     else
#       do nothing (csih_PRIVILEGED_USERNAME="")
#
# ======================================================================
csih_select_privileged_username()
{
  csih_stacktrace "${@}"
  $_csih_trace
  local domain
  local winusername
  local username
  local newname
  local opt_query=0
  local opt_force=0
  local opt_servicename=""
  local opt_default_username=""
  local options
  local theservice
  local map_entry
  local use_files

  _csih_setup

  # always parse "command line"
  OPTIND=0
  while getopts ":qfu:" options; do
    case $options in
      q  ) opt_query=1 ;;
      f  ) opt_force=1 ;;
      u  ) opt_default_username="$OPTARG" ;;
      \? ) csih_warning "${FUNCNAME[0]} ignoring invalid option: $OPTARG" ;;
      \: ) csih_warning "${FUNCNAME[0]} ignoring option missing required argument: $OPTARG" ;;
    esac
  done
  shift $(($OPTIND - 1))
  [ -n "${1}" ] && opt_servicename="${1}"

  # save time if csih_PRIVILEGED_USERNAME already set
  if [ -n "${csih_PRIVILEGED_USERNAME}" ]
  then
    return
  fi

  csih_privileged_accounts -u "$opt_default_username"

  # if query mode and opt_servicename has been specified,
  # first check to see if the service has already been
  # installed.  If so, get the service's account name.
  # If (and only if) that account is privileged, then
  # record it in csih_PRIVILEGED_USERNAME.
  if [ $opt_query -ne 0 -a -n "${opt_servicename}" ]
  then
    if /usr/bin/cygrunsrv -Q "${opt_servicename}" >/dev/null 2>&1
    then
      username=$(/usr/bin/cygrunsrv -V -Q "${opt_servicename}" 2>&1 | /usr/bin/sed -n -e '/^Account/s/^.* : //p')
      domain="${username%\\*}"
      winusername="${username#*\\}"
      if [ "${winusername}" = "LocalSystem" ]
      then
        username=#empty; SYSTEM is not a "privileged user"
      else
	username=$(/usr/bin/getent passwd "${winusername}" "${domain}+${winusername}" | /usr/bin/head -n1 | /usr/bin/cut -d: -f 1)
      fi
      if [ -n "${username}" ]
      then
        if csih_privileged_account_exists "${username}"
        then
          # ${opt_servicename} is installed under account "${username}",
          # which is one of the pre-declared privileged users -- or,
          # we have already validated that ${username} has the necessary
          # privilegeds. Great!
          csih_PRIVILEGED_USERNAME="${username}"
          csih_PRIVILEGED_USERWINNAME="${winusername}"
          csih_PRIVILEGED_USERDOMAIN="${domain}"
          return
        else
          if csih_account_has_necessary_privileges "${username}"
          then
            # ${opt_servicename} is installed under account "${username}",
            # but ${username} is not one of the pre-declared privileged users
            # (cyg_server, sshd_server, cron_server) -- nor had we previously
            # validated that it has the necessary privileges. However, we just
            # did validate that, and it DOES have the necessary privileges.
            # Add it to the list.
            csih_PRIVILEGED_USERNAME="${username}"
	    csih_PRIVILEGED_USERWINNAME="${winusername}"
	    csih_PRIVILEGED_USERDOMAIN="${domain}"
            _csih_all_preexisting_privileged_accounts="${_csih_all_preexisting_privileged_accounts}'${username}' "
            return
          else
            # ${opt_servicename} is installed under account "${username}", but
            # ${username} is not one of the pre-declared privileged users
            # (cyg_server, sshd_server, cron_server), nor does it have the
            # necessary privileges. Ignore it...
            return
          fi
        fi # privileged_user_exists
      else
        # ${opt_servicename} installed under LocalSystem, or there was
        # some error in determining the account name under which it is installed.
        return
      fi # $username empty
    fi # ${opt_servicename} is not installed
  fi # not (opt_query && opt_servicename)

  if [ $opt_query -eq 0 ]
  then
    if csih_is_nt2003
    then
      csih_inform "It's not possible to use the LocalSystem account for services"
      csih_inform "that can change the user id without an explicit password"
      csih_inform "(such as passwordless logins [e.g. public key authentication]"
      csih_inform "via sshd) when having to create the user token from scratch."
      csih_inform "For more information on this requirement, see"
      csih_inform "https://cygwin.com/cygwin-ug-net/ntsec.html#ntsec-nopasswd1"
      echo ""
      csih_inform "If you want to enable that functionality, it's required to create"
      csih_inform "a new account with special privileges (unless such an account"
      csih_inform "already exists). This account is then used to run these special"
      csih_inform "servers."
      echo ""
      csih_inform "Note that creating a new user requires that the current account"
      csih_inform "have Administrator privileges itself."
    elif [ "x$csih_FORCE_PRIVILEGED_USER" = "xyes" ]
    then
      csih_inform "You have requested that a special privileged user be used"
      csih_inform "by the service, and are running on 32 bit Windows XP"
      csih_inform "where this is not actually required (LocalSystem would also work)."
      echo ""
      csih_inform "Note that creating a new user requires that the current account"
      csih_inform "have Administrator privileges itself."
    else
      # hmm. XP(32), but not csih_FORCE_PRIVILEGED_USER
      # in this case, we emit no messages. If a privileged
      # user already exists, we'll use it. Otherwise, don't
      # specify a "privileged" user. Callers will know to
      # silently use LocalSystem.
      :
    fi
  fi

  if [ -n "${_csih_all_preexisting_privileged_accounts}" -a -z "$opt_default_username" ]
  then
    echo ""
    csih_inform "The following privileged accounts were found: ${_csih_all_preexisting_privileged_accounts}."
    username="${_csih_preferred_preexisting_privileged_account}"
  else
    if ( csih_is_nt2003 || [ "x$csih_FORCE_PRIVILEGED_USER" = "xyes" ] )
    then
      if [ $opt_query -eq 0 -a -z "$opt_default_username" ]
      then
        echo ""
        csih_inform "No privileged account could be found."
      fi
      if [ -n "$opt_default_username" ]
      then
        username="$opt_default_username"
      else
        username="cyg_server"
      fi
    else
      # nt/2k/xp32 and not csih_FORCE_PRIVILEGED_USER and username is empty
      # we couldn't find a pre-existing privileged user, but we don't
      # really need one (nt/2k/xp32) and haven't explicitly requested one
      # via csih_FORCE...  In this case, we're done: just return. (this
      # is true regardless of the value of $opt_query)
      return
    fi
  fi

  # if we get here, then $username WILL be set to something
  if [ $opt_query -eq 0 ]
  then
    echo ""
    csih_inform "This script plans to use '${username}'."
    csih_inform "'${username}' will only be used by registered services."
    if [ $opt_force -eq 0 ]
    then
      if csih_request "Do you want to use a different name?"
      then
        csih_get_value "Enter the new user name:"
        username="${csih_value}"
      fi
    fi
  else
    theservice=${opt_servicename:-the service}
    csih_inform "This script will assume that ${theservice} will run"
    csih_inform "under the '${username}' account."
    if [ $opt_force -eq 0 ]
    then
      if csih_request "Will ${theservice} run under a different account?"
      then
        csih_get_value "Enter the user name used by the service:"
        username="${csih_value}"
      fi
    fi
  fi

  # faster than checking SAM -- see if username is one that we
  # already know about
  if csih_privileged_account_exists "$username"
  then
    _csih_preferred_preexisting_privileged_account="${username}"
  else
    # perhaps user specified a pre-existing privileged account we
    # don't know about
    if /usr/bin/getent passwd "${username}" >/dev/null 2>&1
    then
      if ! csih_account_has_necessary_privileges "${username}"
      then
        csih_warning "The specified account '${username}' does not have the"
        csih_warning "required permissions or group memberships. This may"
        csih_warning "cause problems if not corrected; continuing..."
      elif [ ${opt_query} -eq 0 ]
      then
        csih_inform "'${username}' already exists...and has all necessary permissions."
      fi
      # so, add it to our list, so that csih_privileged_account_exists
      # will return true...
      _csih_preferred_preexisting_privileged_account="${username}"
      _csih_all_preexisting_privileged_accounts="${_csih_all_preexisting_privileged_accounts}'${username}' "
    fi
    # if it doesn't exist, we're probably in the midst of creating it.
    # so don't issue any warnings.
  fi

  map_entry=$(/usr/bin/getent -w passwd "${username}")
  if [ -n "${map_entry}" ]
  then
    local dw

    csih_PRIVILEGED_USERNAME="${map_entry%%:*}"
    dw="${map_entry#*:*:}"
    dw="${dw%:*}"
    csih_PRIVILEGED_USERDOMAIN="${dw%\\*}"
    csih_PRIVILEGED_USERWINNAME="${dw#*\\}"
  else
    csih_PRIVILEGED_USERNAME="${username}"
    if ! csih_use_file_etc "passwd"
    then
      # This test succeeds on domain member machines only, not on DCs.
      if [ "\\\\${COMPUTERNAME,,*}" != "${LOGONSERVER,,*}" \
	   -a "${LOGONSERVER}" != "\\\\MicrosoftAccount" ]
      then
	# Lowercase of USERDOMAIN
      	csih_PRIVILEGED_USERNAME="${COMPUTERNAME,,*}+${username}"
      fi
    fi
    csih_PRIVILEGED_USERDOMAIN="${COMPUTERNAME}"
    csih_PRIVILEGED_USERWINNAME="${username}"
  fi

} # === End of csih_select_privileged_username() === #
readonly -f csih_select_privileged_username


# ======================================================================
# Routine: csih_create_privileged_user
#   On 64bit Windows XP, Windows Server 2003 and above (including Windows
#   Vista), or if csih_FORCE_PRIVILEGED_USER == "yes" for Windows NT and
#   above, allows user to select a pre-existing privileged user, or to
#   create a new privileged user.
#   $1 (optional) will be used as the password if non-empty
#
#   NOTE: For using special behaviours triggered by optional parameters
#   to the csih_select_privileged_username function, you should first
#   call that function with all required parameters, and then call this
#   function. The selected username will already be stored in
#   $csih_PRIVILEGED_USERNAME.
#
#   Exits on catastrophic error (or if user enters empty password)
#   Returns 0 on total success
#   Returns 1 on partial success (created user, but could not add
#     to admin group, or set privileges, etc).  Recommend caller
#     check return value, and offer user opportunity to quit.
#
#   On success, the username and password will be available in
#     csih_PRIVILEGED_USERNAME
#     csih_PRIVILEGED_USERDOMAIN
#     csih_PRIVILEGED_USERWINNAME
#     csih_PRIVILEGED_PASSWORD
#
# csih_auto_answer=no behavior
#   if csih_is_nt2003 || FORCE # note: csih_is_nt2003 is true for XP64, too
#     if pre-existing privileged user
#       make sure its group membership and perms are correct
#     else
#       do nothing, return 1
#   else
#     do nothing, return 1
# ======================================================================
csih_create_privileged_user()
{
  csih_stacktrace "${@}"
  $_csih_trace
  local username_in_sam
  local admingroup
  local dos_var_empty
  local _password
  local password_value="$1"
  local passwd_has_expiry_flags
  local ret=0
  local username_in_admingroup
  local username_got_all_rights
  local tmpfile1

  _csih_setup
  csih_select_privileged_username

  if ( csih_is_nt2003 || [ "x$csih_FORCE_PRIVILEGED_USER" = "xyes" ] )
  then
    if ! csih_privileged_account_exists "$csih_PRIVILEGED_USERNAME"
    then
      username_in_sam=no

      # give auto-answer a chance to veto, because we can't enter password
      # from setup.exe...
      if csih_request "Create new privileged user account '${csih_PRIVILEGED_USERDOMAIN}\\\\${csih_PRIVILEGED_USERWINNAME}' (Cygwin name: '${csih_PRIVILEGED_USERNAME}')?"
      then
        dos_var_empty=$(/usr/bin/cygpath -w ${LOCALSTATEDIR}/empty)

	if [ -n "${password_value}" ]
	then
	  _password="${password_value}"
	  # Allow to ask for password if first try fails
	  password_value=""
	else
	  csih_inform "Please enter a password for new user ${csih_PRIVILEGED_USERNAME}.  Please be sure"
	  csih_inform "that this password matches the password rules given on your system."
	  csih_inform "Entering no password will exit the configuration."
	  csih_get_value "Please enter the password:" -s
	  _password="${csih_value}"
	  if [ -z "${_password}" ]
	  then
	    csih_error_multi "Exiting configuration.  No user ${csih_PRIVILEGED_USERNAME} has been created," \
			     "and no services have been installed."
	  fi
	fi
	tmpfile1=$(csih_mktemp) || csih_error "Could not create temp file"
	csih_call_winsys32 net user "${csih_PRIVILEGED_USERWINNAME}" \
		  "${_password}" \
		  /fullname:"Privileged server" \
		  /homedir:"${dos_var_empty}" \
		  /comment:'<cygwin home="/var/empty" shell="/bin/false"/>' \
		  /add /yes > "${tmpfile1}" 2>&1 && username_in_sam=yes
	if [ "${username_in_sam}" != "yes" ]
	then
	  csih_warning "Creating the user '${csih_PRIVILEGED_USERNAME}' failed!  Reason:"
	  /usr/bin/cat "${tmpfile1}"
	  echo
	fi
	/usr/bin/rm -f "${tmpfile1}"

	if [ "${username_in_sam}" = "yes" ]
	then
	  csih_PRIVILEGED_PASSWORD="${_password}"
	  csih_inform "User '${csih_PRIVILEGED_USERNAME}' has been created with password '${_password}'."
	  csih_inform "If you change the password, please remember also to change the"
	  csih_inform "password for the installed services which use (or will soon use)"
	  csih_inform "the '${csih_PRIVILEGED_USERNAME}' account."
	  echo ""

	  if ! passwd -e "${csih_PRIVILEGED_USERNAME}" >/dev/null
	  then
	    csih_warning "Setting password expiry for user '${csih_PRIVILEGED_USERNAME}' failed!"
	    csih_warning "Please check that password never expires or set it to your needs."
	  fi
        fi
      fi # user allowed us to create account
    else
      # ${csih_PRIVILEGED_USERNAME} already exists. Use it, and make no changes.
      # use passed-in value as first guess
      csih_PRIVILEGED_PASSWORD="${password_value}"
      return 0
    fi

    # Username did NOT previously exist, but has been successfully created.
    # set group memberships, privileges, and passwd timeout.
    if [ "$username_in_sam" = "yes" ]
    then
      # always try to set group membership and privileges
      admingroup=$(/usr/bin/getent -w group S-1-5-32-544)
      admingroup="${admingroup#*:*:*\\}"
      admingroup="${admingroup%:*}"
      if [ -z "${admingroup}" ]
      then
        csih_warning "Cannot obtain the Administrators group name from 'getent -w'."
        ret=1
      elif csih_call_winsys32 net localgroup "${admingroup}" | /usr/bin/grep -Eiq "^${csih_PRIVILEGED_USERWINNAME}.?$"
      then
        true
      else
        csih_call_winsys32 net localgroup "${admingroup}" "${csih_PRIVILEGED_USERWINNAME}" /add > /dev/null 2>&1 && username_in_admingroup=yes
        if [ "${username_in_admingroup}" != "yes" ]
        then
          csih_warning "Adding user '${csih_PRIVILEGED_USERNAME}' to local group '${admingroup}' failed!"
          csih_warning "Please add '${csih_PRIVILEGED_USERNAME}' to local group '${admingroup}' before"
          csih_warning "starting any of the services which depend upon this user!"
          ret=1
        fi
      fi

      if ! csih_check_program_or_warn /usr/bin/editrights editrights
      then
        csih_warning "The 'editrights' program cannot be found or is not executable."
        csih_warning "Unable to ensure that '${csih_PRIVILEGED_USERNAME}' has the appropriate privileges."
        ret=1
      else
        /usr/bin/editrights -a SeAssignPrimaryTokenPrivilege -u ${csih_PRIVILEGED_USERNAME} &&
        /usr/bin/editrights -a SeCreateTokenPrivilege -u ${csih_PRIVILEGED_USERNAME} &&
        /usr/bin/editrights -a SeTcbPrivilege -u ${csih_PRIVILEGED_USERNAME} &&
        /usr/bin/editrights -a SeDenyInteractiveLogonRight -u ${csih_PRIVILEGED_USERNAME} &&
        /usr/bin/editrights -a SeDenyRemoteInteractiveLogonRight -u ${csih_PRIVILEGED_USERNAME} &&
        /usr/bin/editrights -a SeServiceLogonRight -u ${csih_PRIVILEGED_USERNAME} &&
        username_got_all_rights="yes"
        if [ "${username_got_all_rights}" != "yes" ]
        then
          csih_warning "Assigning the appropriate privileges to user '${csih_PRIVILEGED_USERNAME}' failed!"
          ret=1
        fi
      fi

      # If we use /etc account DB only, write new account to /etc/passwd
      if csih_use_file_etc passwd
      then
	/usr/bin/mkpasswd -l -u "${username}" >> "${SYSCONFDIR}/passwd"
      fi

      return "${ret}"
    fi # ! username_in_sam
    return 1 # failed to create user (or prevented by auto-answer veto)
  fi # csih_is_nt2003 (also XP64) || csih_FORCE_PRIVILEGED_USER
  return 1   # nt/2k/xp32 without FORCE
} # === End of csih_create_privileged_user() === #
readonly -f csih_create_privileged_user

# ======================================================================
# Routine: csih_create_unprivileged_user
#   Creates a new (unprivileged) user as specified by $1.
#   Useful for running services that do not require elevated privileges,
#     or running servers like sshd in "privilege separation" mode.
#
#   Exits on catastrophic error
#   Returns 0 on total success
#   Returns 1 on failure
#
# csih_auto_answer=no behavior
#   if already exists
#     use it
#   else
#     do nothing, return 1
# ======================================================================
csih_create_unprivileged_user()
{
  csih_stacktrace "${@}"
  $_csih_trace
  local unpriv_user="$1"
  local map_entry
  local user_exists=no
  local dos_var_empty=

  _csih_setup

  map_entry="$(/usr/bin/getent -w passwd "U-${unpriv_user}")"
  if [ -n "${map_entry}" ]
  then
    user_exists=yes
  else
    csih_inform "Note that creating a new user requires that the current account have"
    csih_inform "Administrator privileges.  Should this script attempt to create a"
    # give auto-answer a chance to veto
    if csih_request "new local account '${unpriv_user}'?"
    then
      dos_var_empty=$(/usr/bin/cygpath -w ${LOCALSTATEDIR}/empty)
      csih_call_winsys32 net user "${unpriv_user}" \
		/homedir:"${dos_var_empty}" \
		/comment:'<cygwin home="/var/empty" shell="/bin/false"/>' \
		/add /active:no >/dev/null 2>&1 && user_exists=yes
      if [ "${user_exists}" != "yes" ]
      then
	csih_warning "Creating the user '${unpriv_user}' failed!"
      else
	# If we use /etc account DB only, write new account to /etc/passwd
	if csih_use_file_etc passwd
	then
	  /usr/bin/mkpasswd -l -u "${unpriv_user}" >> "${SYSCONFDIR}/passwd"
	fi
      fi
    fi
  fi

  if [ "${user_exists}" = "yes" ]
  then
    local dw

    map_entry="$(/usr/bin/getent -w passwd "U-${unpriv_user}")"
    csih_UNPRIVILEGED_USERNAME="${map_entry%%:*}"
    dw="${map_entry#*:*:}"
    dw="${dw%:*}"
    csih_UNPRIVILEGED_USERDOMAIN="${dw%\\*}"
    csih_UNPRIVILEGED_USERWINNAME="${dw#*\\}"
    return 0
  fi
  return 1
} # === End of csih_create_unprivileged_user() === #
readonly -f csih_create_unprivileged_user

# ======================================================================
# Routine: csih_create_local_group
#   Creates a new local group as specified by $1.
#
#   Exits on catastrophic error
#   Returns 0 on total success
#   Returns 1 on failure
#
# csih_auto_answer=no behavior
#   if already exists
#     use it
#   else
#     do nothing, return 1
# ======================================================================
csih_create_local_group()
{
  csih_stacktrace "${@}"
  $_csih_trace
  local group="$1"
  local map_entry
  local grp_exists=no

  _csih_setup

  map_entry="$(/usr/bin/getent -w group "U-${group}")"
  if [ -n "${map_entry}" ]
  then
    grp_exists=yes
  else
    csih_inform "Note that creating a new local group requires that the current account have"
    csih_inform "Administrator privileges.  Should this script attempt to create a"
    # give auto-answer a chance to veto
    if csih_request "new local group '${group}'?"
    then
      csih_call_winsys32 net localgroup "${group}" \
		/add >/dev/null 2>&1 && grp_exists=yes
      if [ "${grp_exists}" != "yes" ]
      then
	csih_warning "Creating the group '${group}' failed!"
      else
	# If we use /etc account DB only, write new group to /etc/group
	if csih_use_file_etc group
	then
	  /usr/bin/mkgroup -l -g "${group}" >> "${SYSCONFDIR}/group"
	fi
      fi
    fi
  fi

  if [ "${grp_exists}" = "yes" ]
  then
    local dw

    map_entry="$(/usr/bin/getent -w group "U-${group}")"
    csih_LOCAL_GROUPNAME="${map_entry%%:*}"
    dw="${map_entry#*:*:}"
    dw="${dw%:*}"
    csih_LOCAL_GROUPDOMAIN="${dw%\\*}"
    csih_LOCAL_GROUPWINNAME="${dw#*\\}"
    return 0
  fi
  return 1
} # === End of csih_create_local_group() === #
readonly -f csih_create_local_group

# ======================================================================
# Routine: csih_service_should_run_as [service_name]
#   If [service_name] is specified, check to see if service_name is
#     already installed.  If so, return that user (after verifying
#     that it has the necessary privileges). If not installed, behave
#     as described below.
#     Should call csih_select_privileged_username first, unless SURE
#     that [service_name] has already been installed.
#
#   Otherwise:
#
#     On 64bit Windows XP, Windows Server 2003 and above (including
#     Windows Vista), or if csih_FORCE_PRIVILEGED_USER == "yes"
#       returns the selected privileged account name, IF it exists (e.g.
#       already existed, or was successfully created).  Otherwise,
#       returns "SYSTEM".  Callers should check this and warn.
#
#     On Windows NT/2k/XP32, if csih_FORCE_PRIVILEGED_USER != yes, then
#       if a privileged user already exists, return it
#       else return "SYSTEM"
#
#     MUST call either  csih_select_privileged_username
#                   or  csih_create_privileged_user
#     first.
# ======================================================================
csih_service_should_run_as()
{
  csih_stacktrace "${@}"
  $_csih_trace
  local opt_servicename
  local domain
  local winusername

  # caller specified a service, so first check to see if that service
  # is already installed, and if so, analyze that account.  (If not,
  # fall thru...)
  if [ -n "$1" ]
  then
    opt_servicename="$1"
    if /usr/bin/cygrunsrv -Q "${opt_servicename}" >/dev/null 2>&1
    then
      username=$(/usr/bin/cygrunsrv -V -Q "${opt_servicename}" 2>&1 | /usr/bin/sed -n -e '/^Account/s/^.* : //p')
      domain="${username/\\*/}"
      winusername="${username/*\\/}"
      if [ "${username}" = "LocalSystem" ]
      then
        username=SYSTEM
      else
	username=$(/usr/bin/getent passwd "${winusername}" "${domain}+${winusername}" | /usr/bin/head -n1 | /usr/bin/cut -d: -f 1)
      fi
      if ( csih_is_nt2003 || [ "x$csih_FORCE_PRIVILEGED_USER" = "xyes" ] )
      then
        if [ -n "${username}" -a "${username}" != SYSTEM ]
        then
          if csih_privileged_account_exists "${username}"
          then
            echo "${username}"
            return
          else
            if csih_account_has_necessary_privileges "${username}"
            then
              echo "${username}"
              return
            else
              csih_error_multi \
                "${opt_servicename} is installed under custom account '${username}'," \
                "but '${username}' does not have the necessary permissions or "    \
                "group membership. Please correct this problem before continuing." 1>&2
            fi
          fi
        else
          # two different error cases: -z $username, or $username=SYSTEM
          if [ -z "${username}" ]
          then
            csih_error_multi \
              "${opt_servicename} is installed, but there was a problem determining" \
              "the user account under which it runs. Please correct this problem" \
              "before continuing." 1>&2
          else
            csih_error_multi \
              "${opt_servicename} is installed under account 'SYSTEM', but that"  \
              "conflicts with privileged user requirement. ${opt_servicename}" \
              "must be installed under a special privileged account: either"  \
              "because the OS is 64bit Windows XP, Windows Server 2003, or above," \
              "or you requested -privileged." 1>&2
          fi
        fi
      else
        # not nt2003|xp64 nor (nt && csih_FORCE_PRIVILEGED_USER=yes)
        # we don't care about properties of $username...
        if [ -z "${username}" ]
        then
          csih_error_multi \
            "${opt_servicename} is installed, but there was a problem determining" \
            "the user account under which it runs. Please correct this problem" \
            "before continuing." 1>&2
        else
          echo "${username}"
          return
        fi
      fi
    fi # ${opt_servicename} not installed
  fi # ${opt_servicename} not specified

  # Caller did not specify a specific service, or the specified service
  # is not yet installed, so compute the "expected" account under which
  # privileged services should run.

  # use the following procedure if a privileged account is required:
  if ( csih_is_nt2003 || [ "x$csih_FORCE_PRIVILEGED_USER" = "xyes" ] )
  then
    if [ -z "${csih_PRIVILEGED_USERNAME}" ]
    then
      csih_warning "INTERNAL: should call 'csih_select_privileged_username()' before 'csih_service_should_run_as()'" 1>&2
    fi

    if csih_privileged_account_exists "$csih_PRIVILEGED_USERNAME" 1>&2
    then
      # it already existed before this script was launched
      echo "$csih_PRIVILEGED_USERNAME"
      return
    elif /usr/bin/getent passwd "${csih_PRIVILEGED_USERNAME}" >/dev/null 2>&1
    then
      # we probably just created it
      echo "$csih_PRIVILEGED_USERNAME"
      return
    else
      # a failure somewhere
      csih_warning "Expected privileged user '${csih_PRIVILEGED_USERNAME}' does not exist." 1>&2
      csih_warning "Defaulting to 'SYSTEM'" 1>&2
      echo "SYSTEM"
      return
    fi
  fi

  # not nt2003|xp64, and csih_FORCE_PRIVILEGED != yes).
  # Use fallback: if any privileged user exists, report that. Otherwise,
  # report SYSTEM
  csih_privileged_accounts
  if [ -n "${_csih_preferred_preexisting_privileged_account}" ]
  then
    echo "${_csih_preferred_preexisting_privileged_account}"
  else
    echo "SYSTEM"
  fi
} # === End of csih_service_should_run_as() === #
readonly -f csih_service_should_run_as

# ======================================================================
# Routine: _csih_late_initialization_code
#   Initializes variables that require complex script support, such
#   as csih_invoke_helper.
#
# SETS GLOBAL VARIABLE:
#   _csih_script_dir
#   _csih_exec_dir
#   _csih_exactly_vista
#   _csih_exactly_server2008
#   _csih_exactly_windows7
#   _csih_exactly_server2008r2
#   _csih_exactly_windows8
#   _csih_exactly_server2012
#   _csih_win_product_name
# ======================================================================
_csih_late_initialization_code()
{
  local rstatus
  local productName

  # These two variables must be initialized before calling
  # csih_invoke_helper
  _csih_script_dir=$(_csih_get_script_dir)
  _csih_exec_dir=$(_csih_get_exec_dir)

  productName=$(csih_invoke_helper winProductName)
  rstatus=$?
  if [ "$rstatus" -eq 0 ]
  then
    if   echo "${productName}" | /usr/bin/grep -q " Server 2016 "
    then
    	_csih_exactly_server2016=1
    elif echo "${productName}" | /usr/bin/grep -q " Windows 10 "
    then
        _csih_exactly_windows10=1
    elif echo "${productName}" | /usr/bin/grep -q " Server 2012 R2 "
    then
        _csih_exactly_server2012r2=1
    elif echo "${productName}" | /usr/bin/grep -q " Windows 8\.1 "
    then
        _csih_exactly_windows8_1=1
    elif echo "${productName}" | /usr/bin/grep -q " Server 2012 "
    then
        _csih_exactly_server2012=1
    elif echo "${productName}" | /usr/bin/grep -q " Windows 8 "
    then
        _csih_exactly_windows8=1
    elif   echo "${productName}" | /usr/bin/grep -q " Server 2008 R2 "
    then
        _csih_exactly_server2008r2=1
    elif echo "${productName}" | /usr/bin/grep -q " Windows 7 "
    then
        _csih_exactly_windows7=1
    elif echo "${productName}" | /usr/bin/grep -q " Server 2008 "
    then
        _csih_exactly_server2008=1
    elif echo "${productName}" | /usr/bin/grep -q " Vista "
    then
        _csih_exactly_vista=1
    fi
    _csih_win_product_name="${productName}";
  fi
} # === End of _csih_late_initialization_code() === #
readonly -f _csih_late_initialization_code


# ======================================================================
# Initial setup, default values, etc.  PART 3
#
# This part of the setup has to be deferred to the end of the csih
# script, since we need many of the previously defined functions to
# be available (such as csih_invoke_helper) before the variable values
# can be obtained.  Most of this initialization is encapsulated in the
# _csih_late_initialization_code() function.
#
# Finally, we ensure that this file is being used properly (that is,
# sourced by another script rather than executed directly), and that
# the current cygwin and Windows versions are supported.  csih requires
# WinNT or above and cygwin-1.7.x or above.
# ======================================================================
_csih_late_initialization_code
readonly _csih_script_dir _csih_exec_dir
readonly _csih_exactly_vista _csih_exactly_server2008
readonly _csih_exactly_server2008r2 _csih_exactly_windows7
readonly _csih_exactly_server2012 _csih_exactly_windows8
readonly _csih_exactly_server2012r2 _csih_exactly_windows8_1
readonly _csih_exactly_server2016 _csih_exactly_windows10
readonly _csih_win_product_name

if [ "cygwin-service-installation-helper.sh" = "$csih_progname_base" ]
then
  csih_error "$csih_progname_base should not be executed directly"
fi
