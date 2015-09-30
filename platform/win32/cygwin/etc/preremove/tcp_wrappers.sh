if [ -f /etc/hosts.allow ] && cmp -s /etc/defaults/etc/hosts.allow /etc/hosts.allow
then
    rm /etc/hosts.allow
fi

if [ -f /etc/hosts.deny ] && cmp -s /etc/defaults/etc/hosts.deny /etc/hosts.deny
then
    rm /etc/hosts.deny
fi

