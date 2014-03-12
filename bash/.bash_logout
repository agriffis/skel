# $Id: bash_logout 1799 2006-06-28 16:22:20Z agriffis $

# invalidate the gpm selection buffer if logging out from a
# virtual terminal
if /sbin/consoletype &>/dev/null && [[ -r /var/run/gpm.pid ]]; then
    kill -USR2 "$(</var/run/gpm.pid)" 2>/dev/null
fi
