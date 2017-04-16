# .bash_profile
#
# Environment settings that should only be reset for new logins
# (rather than all new shells).
#
# Written in 2003-2016 by Aron Griffis <aron@arongriffis.com>
#
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.
#
# CC0 Public Domain Dedication at
# http://creativecommons.org/publicdomain/zero/1.0/
#======================================================================

# indicate to bashrc that bash_profile has been sourced
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

[[ $HOME == / ]] || frontpath PATH \
  ~/bin ~/.local/bin ~/node_modules/.bin ~/.cargo/bin ~/.cask/bin

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
  darwin*) export LANG=en_US.UTF-8 LC_COLLATE=C ;;
  *) export LANG=en_US.ISO8859-1 LC_COLLATE=C ;;
esac

# Set the EDITOR to vim. Override this in .bash_profile.mine if you prefer
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

# make pinentry-curses work for gpg-agent
export GPG_TTY=$(tty)

# Load user-specific settings
[[ ! -r ~/.bash_profile.mine ]] || source ~/.bash_profile.mine
[[ ! -r ~/.bash_profile.local ]] || source ~/.bash_profile.local

source ~/.bashrc
