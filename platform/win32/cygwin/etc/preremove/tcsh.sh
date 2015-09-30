if [ -f /etc/csh.cshrc ] && cmp -s /etc/defaults/etc/csh.cshrc /etc/csh.cshrc
then
    rm /etc/csh.cshrc
fi

if [ -f /etc/csh.login ] && cmp -s /etc/defaults/etc/csh.login /etc/csh.login
then
    rm /etc/csh.login
fi

if [ -f /etc/profile.d/bindkey.tcsh ] && cmp -s /etc/defaults/etc/profile.d/bindkey.tcsh /etc/profile.d/bindkey.tcsh
then
    rm /etc/profile.d/bindkey.tcsh
fi

if [ -f /etc/profile.d/complete.tcsh ] && cmp -s /etc/defaults/etc/profile.d/complete.tcsh /etc/profile.d/complete.tcsh
then
    rm /etc/profile.d/complete.tcsh
fi

