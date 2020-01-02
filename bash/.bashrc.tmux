# .bashrc.tmux
#
# Keep inner tmux shell updated from outer tmux environment
#
# Written in 2015 by Aron Griffis <aron@arongriffis.com>
#
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.
#
# CC0 Public Domain Dedication at
# http://creativecommons.org/publicdomain/zero/1.0/
#======================================================================

[[ -z $TMUX ]] && return

ps1_mod_tmux_env() {
  declare line name value

  while read line; do
    case $line in
      -*)
        unset ${line#-}
        ;;
      *=*)
        name=${line%%=*}
        value=${line#*=}
        eval "export $name=$(printf %q "$value")"
        ;;
    esac
  done <<<"$(tmux showenv)"
}

if [[ $(type -t ps1_add) == function ]]; then
  ps1_add tmux_env
else
  append_cmd PROMPT_COMMAND ps1_mod_tmux_env
fi


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
