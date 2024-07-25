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

source ~/.bashrc.funcs
source ~/.bashrc.pathfuncs

frontpath PATH /usr/local/bin /usr/local/sbin
addpath PATH /usr/bin /bin /usr/sbin /sbin

# ccache on Gentoo and Debian respectively
frontpath PATH /usr/lib{64,}/ccache/bin /usr/lib{64,}/ccache

# flatpak so you don't have to "flatpak run ..."
addpath PATH /var/lib/flatpak/exports/bin

jh=$(first_test -d "$JAVA_HOME" /opt/graalvm /usr/java/latest /usr/lib/jvm/java)
if [[ -d $jh ]]; then
  export JAVA_HOME="$jh"
  frontpath PATH "$JAVA_HOME/bin"
fi
unset jh

# https://docs.volta.sh/advanced/installers#skipping-volta-setup
export VOLTA_HOME="$HOME/.volta"
# https://docs.volta.sh/advanced/pnpm
export VOLTA_FEATURE_PNPM=1

# https://bun.sh/
export BUN_INSTALL="$HOME/.bun"

frontpath PATH ~/.cargo/bin # cargo install
frontpath PATH ~/.cask/bin # homebrew
frontpath PATH ~/.emacs.d/bin # doom emacs
frontpath PATH ~/.gem/bin # gem install --user-install --bindir ~/.gem/bin
frontpath PATH ~/go/bin # go install
frontpath PATH ~/node_modules/.bin # yarn global add
frontpath PATH ~/.npm-local/bin # npm i -g
frontpath PATH ~/.local/bin # make install
frontpath PATH "$BUN_INSTALL/bin" # bun add -g
frontpath PATH "$VOLTA_HOME/bin" # volta node/pnpm
frontpath PATH ~/bin # personal and overrides

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
  linux*) export LANG=en_US.UTF-8 LC_COLLATE=C ;;
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

export FZF_DEFAULT_COMMAND='fd --type f --hidden'
export FZF_DEFAULT_OPTS=--reverse

# if "less" is available, use it as the pager
type -P less &>/dev/null && export PAGER=less COLORPAGER=less
export LESS=-isXFRQ
export LESSCHARSET=utf-8
if type -P lesspipe &>/dev/null; then
  eval "$(lesspipe)"
fi

# https://github.com/sharkdp/bat
type -P bat &>/dev/null && export MANPAGER="sh -c 'col -bx | bat -l man -p'" MANROFFOPT="-c"

export QUILT_DIFF_ARGS='--color=auto'
export QUILT_DIFF_OPTS='-p'

export RIPGREP_CONFIG_PATH=~/.config/ripgrep/ripgreprc

export RSYNC_RSH=ssh

# make pinentry-curses work for gpg-agent
export GPG_TTY=$(tty)

# Load user-specific settings
[[ ! -r ~/.bash_profile.mine ]] || source ~/.bash_profile.mine
[[ ! -r ~/.bash_profile.local ]] || source ~/.bash_profile.local

source ~/.bashrc
