# $Id: bash_profile 4902 2013-10-15 13:17:43Z aron $
#
# .bash_profile
#       Environment settings that should only be reset for new logins
#       (rather than all new shells).

export _BASH_PROFILE=1

# sometimes USER isn't set so just use LOGNAME
: ${USER:=$LOGNAME}

# make sure subprocesses know Bash rules :-)
export SHELL=$BASH

# PATH
# ----

source ~/.bashrc.pathfuncs

frontpath PATH \
  /usr/local/bin /usr/local/sbin \
  /usr/bin /bin /usr/sbin /sbin \
  /usr/X11R6/bin /usr/games /usr/games/bin
[[ $HOME == / ]] || frontpath PATH ~/bin ~/.local/bin ~/node_modules/.bin

# ccache on Gentoo and Debian respectively
frontpath PATH /usr/lib{64,}/ccache/bin /usr/lib{64,}/ccache

# remove . security hole from PATH, added by some foolish sysadmins
rmpath PATH .

# fix for POSIX.2 idiocy that assumes you mean . when there's an empty
# element in PATH
rmpath PATH ''
export PATH

# locale
# ------

unset LANG ${!LC_*}
case $OSTYPE in
  linux*) export LANG=en_US.utf8 LC_COLLATE=C ;;
  *)      export LANG=en_US.ISO8859-1 LC_COLLATE=C ;;
esac

# Set the EDITOR to vim.  Override this in .bashrc.mine if you prefer
# something else.
if type -P vim >/dev/null; then
  export EDITOR=vim
else
  export EDITOR=vi
fi

# if "less" is available, use it as the pager
type -P less &>/dev/null && export PAGER=less COLORPAGER=less
export LESS=-isXFRQ
export LESSCHARSET=utf-8
if type -P lesspipe &>/dev/null; then
  eval "$(lesspipe)"
fi

export QUILT_DIFF_ARGS='--color=auto'
export QUILT_DIFF_OPTS='-p'

export RSYNC_RSH=ssh
export CVS_RSH=ssh
export SVN_SSH="ssh -l $USER"

if [[ -z $JAVA_HOME || ! -d $JAVA_HOME ]]; then
    export JAVA_HOME=/usr/java/latest
fi

# Load user-specific settings
[[ ! -r ~/.bash_profile.mine ]] || source ~/.bash_profile.mine
[[ ! -r ~/.bash_profile.local ]] || source ~/.bash_profile.local

source ~/.bashrc
