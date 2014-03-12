# $Id: bashrc 4898 2013-10-15 13:03:54Z aron $
#
# .bashrc
#       Non-interactive and interactive bash settings

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

if [[ ${BASH_VERSION%%.*} < 2 ]]; then
  command_oriented_history=
  HISTCONTROL=ignoreboth
else
  shopt -s cdspell cmdhist histappend histreedit
  shopt -s checkwinsize
  shopt -s extglob
  # HISTIGNORE supercedes HISTCONTROL.  
  # & matches the previous line in the history.
  HISTIGNORE='\ *:&'
fi

# don't bug me about mail
unset MAILCHECK

# 2000 seems to be a bash compile-time limit
HISTSIZE=2000
HISTFILESIZE=2000

# TERM
# ----

try_TERM() {
  # toe on gentoo searches only /usr/share/terminfo.
  # toe on debian/unbuntu searches only ~/.terminfo and /etc/terminfo.
  # both appear to be broken.

  declare term
  declare -a tried

  for term; do
    [[ " ${tried[*]} " == *" $term "* ]] && continue
    tried+=( "$term" )

    if { toe ~/.terminfo
         toe /etc/terminfo
         toe /usr/share/terminfo
        } 2>/dev/null | grep -q "^$term[[:blank:]]"; then
      TERM=$term
      return 0
    fi
  done

  return 1
}

setup_TERM() {
  # vte-256color messes up emacs with solarized, so use xterm-256color
  # instead. This might be something hardcoded in emacs since the terminfo
  # comparison doesn't show significant differences.
  declare vte=xterm-256color
  declare -a terms

  case $TERM:$COLORTERM in
    ansi:*)
      # probably Windows telnet
      TERM=vt100 ;;

    screen*:*)
      # leave it alone! don't trip on the following vte checks
      ;;

    *:roxterm|xterm:)
      if [[ $ROXTERM_PID == "$PPID" ]]; then
        TERM=$vte
      fi ;;

    *:Terminal|*:gnome-terminal)
      TERM=$vte ;;
  esac

  case $TERM in
    *[-+]256color|rxvt*)
      # Check if the system groks 256color then degrade gracefully.
      # Note that xterm+256color doesn't really work right, so don't
      # attempt to use it unless it's already set.
      # ("less" complains that the terminal isn't fully functional...)
      terms+=(
        "$TERM"               # e.g. xterm+256color
        "${TERM/+/-}"         # e.g. xterm-256color
        "${TERM/#xterm?256color/vte-256color}"
        "${TERM/#rxvt-unicode/rxvt-88color}"
        "${TERM%[-+]*}-16color"  # e.g. xterm-16color
        "${TERM%[-+]*}"       # e.g. xterm or rxvt
        xterm
        dumb
        ) ;;

    screen*)
      terms=(
        # screen-256color-bce-s doesnt seem to work with weechat.
        # The top status bar gets truncated.
        #screen-256color-bce-s
        screen-256color-s
        screen-256color
        screen-16color
        "$TERM"
        screen
        ) ;;
  esac

  if [[ ${#terms[@]} -gt 0 ]]; then
    try_TERM "${terms[@]}"
  fi
}

setup_TERM
unset -f setup_TERM try_TERM

if [[ -s ~/.bashrc.proxies ]]; then
  unset no_proxy http_proxy https_proxy ftp_proxy
  source ~/.bashrc.proxies
  unset NO_PROXY HTTP_PROXY HTTPS_PROXY FTP_PROXY
  [[ -n $no_proxy ]] && export NO_PROXY=$no_proxy
  [[ -n $http_proxy ]] && export HTTP_PROXY=$http_proxy
  [[ -n $https_proxy ]] && export HTTPS_PROXY=$https_proxy
  [[ -n $ftp_proxy ]] && export FTP_PROXY=$ftp_proxy
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

[[ -r ~/.bashrc.prompt ]] && source ~/.bashrc.prompt
[[ -r ~/.bashrc.cd ]]     && source ~/.bashrc.cd
[[ -r ~/.bashrc.fastls ]] && source ~/.bashrc.fastls

# Ruby rvm -- load this after .bashrc.prompt
[[ -r ~/.bashrc.rvm ]] && source ~/.bashrc.rvm

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

# h -- search for a given expression in the history
h() { 
  history | grep -e "${@:-}" | tail
}

# head/tail -- automatically scale based on $LINES
head() {
  if [[ -t 1 ]]; then
    declare lines=$(( LINES - 2 * $(wc -l <<<"$PS1") ))
    [[ $lines -gt 10 ]] && set -- -n$lines "$@"
  fi
  command head "$@"
}
funcdup head tail 'x=${x/command head/command tail}'

# Load user-specific settings
[[ ! -r ~/.bashrc.mine ]] || source ~/.bashrc.mine
[[ ! -r ~/.bashrc.local ]] || source ~/.bashrc.local

# Fix for /tmp_mnt/...
[[ . -ef ~/. ]] && cd
true  # because PS1 might contain $?

# The following line enforces a consistent indentation for this file
# (in Vim at least).  Keep this at the end of file.
# vim:shiftwidth=2 expandtab smarttab
