# .bashrc
#
# Interactive and non-interactive bash settings
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

# If this is a login shell or descendent, profile has already been sourced.
# Otherwise force reread of profile now to get updates.
if [[ -z $_BASH_PROFILE ]]; then
  source /etc/profile
  source ~/.bash_profile # sources .bashrc
  return $?
fi

source ~/.bashrc.funcs

#######################################################################
# Non-interactive settings
#######################################################################

# Bash settings
# -------------

shopt -s cdspell
shopt -s checkwinsize
shopt -s extglob

shopt -s cmdhist histappend histreedit
HISTIGNORE='\ *:&'
HISTSIZE=10000
#HISTTIMEFORMAT='%Y%m%d-%H%M%S '

# don't bug me about mail
unset MAILCHECK

# TERM
source ~/.bashrc.term
setup_TERM

# set umask before interactive test; this helps scp.
# shared hosting should use writeable group.
if [[ -e /etc/resolv.conf && \
    $(</etc/resolv.conf) == *+(sourceforge.net|dreamhost.com)* ]]; then
  umask 002
elif [[ $(id -gn) == "$USER" ]]; then
  umask 002
else
  umask 022
fi

# Python virtualenvwrapper wrapper
[[ -r ~/.bashrc.virtualenvwrapper ]] && source ~/.bashrc.virtualenvwrapper

# Ruby rvm -- disabled in favor of JIT loader below
#[[ -r ~/.rvm/scripts/rvm ]] && source ~/.rvm/scripts/rvm

# All done if non-interactive.
# Note that ssh -t doesn't get past here.
if [[ $- != *i* ]]; then
  [[ ! -r ~/.bashrc.mine ]] || source ~/.bashrc.mine
  [[ ! -r ~/.bashrc.local ]] || source ~/.bashrc.local
  return $?
fi

#######################################################################
# Interactive settings
#######################################################################

[[ -r ~/.bashrc.fastls ]] && source ~/.bashrc.fastls
[[ -r ~/.bashrc.prompt ]] && source ~/.bashrc.prompt
[[ -r ~/.bashrc.rvm ]] && source ~/.bashrc.rvm    # after .bashrc.prompt
[[ -r ~/.bashrc.tmux ]] && source ~/.bashrc.tmux  # after .bashrc.prompt

export GPG_TTY=$(tty)

# Aliases
# -------

# Restarting bash by typing 'b' is really nice for experimenting with
# your settings.
b() {
  if [[ -n $(jobs) ]]; then
    echo "Please exit stopped jobs and try again!"
  else
    exec $BASH --login
  fi
}

cd() {
  if [[ $# -gt 0 ]]; then
    if [[ ${!#} == '^' ]]; then
      declare t="$(topdir 2>/dev/null)"
      [[ -z $t ]] || set -- "${@:1:$#-1}" "$t"
    elif [[ -f ${!#} ]]; then
      # If a file is given to cd, then use the parent dir.
      set -- "${@:1:$#-1}" "${!#%/*}"
    fi
  fi
  command cd "$@"
}

# h -- search for a given expression in the history
h() {
  history | grep -e "${@:-}" | tail
}

# git -- override what can't be aliased
git() {
  case $1 in
    stash) set -- -c commit.gpgsign=false "$@" ;;
  esac
  command git "$@"
}

# fedora /usr/bin/vi is vim-minimal
alias vi=vim

# Load user-specific settings
[[ ! -r ~/.bashrc.mine ]] || source ~/.bashrc.mine
[[ ! -r ~/.bashrc.local ]] || source ~/.bashrc.local

# The following lines enforce a consistent indentation for this file.
# Keep this comment at the end of file.
#
# Local Variables:
# mode: shell-script
# sh-basic-offset: 2
# sh-indentation: 2
# evil-shift-width: 2
# indent-tabs-mode: nil
# End:
#
# vim:shiftwidth=2 expandtab smarttab
