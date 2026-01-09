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

source ~/.bashrc.ghettopt
source ~/.bashrc.funcs
source ~/.bashrc.pathfuncs

#######################################################################
# Non-interactive settings
#######################################################################

# Bash settings
# -------------

shopt -s cdspell
shopt -s checkwinsize
shopt -s extglob
shopt -s globstar

shopt -s cmdhist histappend histreedit
HISTIGNORE='\ *:&'
HISTSIZE=10000
#HISTTIMEFORMAT='%Y%m%d-%H%M%S '

# don't bug me about mail
unset MAILCHECK

# TERM
source ~/.bashrc.term

# ghostty oddity
if [[ $PWD == *?/ ]]; then
  cd "${PWD%/}"
fi

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

# Set up mise. We do this even if non-interactive, so that mise-supplied tools
# will be available on the path.
[[ -r ~/.bashrc.preexec ]] && source ~/.bashrc.preexec
[[ -r ~/.bashrc.mise ]] && source ~/.bashrc.mise

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

[[ -r ~/.bashrc.prompt ]] && source ~/.bashrc.prompt
[[ -r ~/.bashrc.tmux ]] && source ~/.bashrc.tmux  # after .bashrc.prompt

if [[ -r /usr/local/lib/powerline/bindings/bash/powerline.sh ]]; then
  # We don't want the actual prompt, just the tmux support.
  POWERLINE_NO_SHELL_PROMPT=1
  source /usr/local/lib/powerline/bindings/bash/powerline.sh
fi

# https://gnunn1.github.io/tilix-web/manual/vteconfig/
if [[ $(type -t __vte_prompt_command) == function ]]; then
  precmd_functions+=(__vte_prompt_command)
fi

# https://github.com/atuinsh/atuin?tab=readme-ov-file#bash
type -f atuin &>/dev/null && eval "$(atuin init bash --disable-up-arrow)"

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

# remove the Red Hat default alias,
# otherwise setting the 'ls' function will be an error
unalias ls 2>/dev/null

LS_VERSION=$(command ls --version 2>/dev/null || echo non-gnu)

ls() {
  declare all=true header=true human=true d=.

  # Show all files except in homedir
  if [[ $# -gt 0 && ${!#} != -* ]]; then
    d=${!#}
  fi
  if [[ $d -ef ~ ]]; then
    all=false
  fi

  # Use human-readable sizes on coreutils
  [[ $LS_VERSION == *coreutils* ]] || human=false

  # Use header on terminal
  if [[ ! -t 1 ]]; then
    header=false
  fi

  # exa works, I'm just not sure I care about the improvements it brings over
  # ls. And ls -lt breaks, so that's annoying.
  if false && type exa &>/dev/null; then
    exa $($all && echo -a) $($header && echo --header) \
      -F --git --group --group-directories-first "$@"
  elif [[ $LS_VERSION == non-gnu ]]; then
    command ls $($all && echo -A) -F "$@"
  else
    command ls $($all && echo -A) $($human && echo -h) \
      --color=tty -p "$@"
  fi
}

# git -- override what can't be aliased
git() {
  case $1 in
    push)
      if [[ " $* " == " --force " ]]; then
        echo "push --force disallowed by shell function" >&2
        return 1
      fi
      ;;
    stash)
      set -- -c commit.gpgsign=false "$@"
      ;;
  esac
  command git "$@"
}

# fedora /usr/bin/vi is vim-minimal
#alias vi=vim

# fedora has a stupid vim alias
unalias vim &>/dev/null

# Load user-specific settings
[[ ! -r ~/.bashrc.mine ]] || source ~/.bashrc.mine
[[ ! -r ~/.bashrc.local ]] || source ~/.bashrc.local

#======================================================================
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
# vim:shiftwidth=2 expandtab smarttab filetype=sh
