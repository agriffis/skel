# Directories to search for scripts when calling source or use
$env.NU_LIB_DIRS = [
  ($nu.config-path | path dirname | path join scripts)
]

# Directories to search for plugin binaries when calling register
$env.NU_PLUGIN_DIRS = [
  ($nu.config-path | path dirname | path join plugins)
]

######################################################################
# STARSHIP
######################################################################

$env.STARSHIP_SHELL = "nu"

def create_left_prompt [] {
  starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
}

# Use nushell functions to define your right and left prompt
$env.PROMPT_COMMAND = { || create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = ""

# The prompt indicators are environmental variables that represent
# the state of the prompt
$env.PROMPT_INDICATOR = ""
$env.PROMPT_INDICATOR_VI_INSERT = ""
$env.PROMPT_INDICATOR_VI_NORMAL = ""
$env.PROMPT_MULTILINE_INDICATOR = "::: "

######################################################################
# UTILITIES
######################################################################

def 'split paths' [] {
  $in | split row (char esep) | path expand --no-symlink
}

def 'paths join' [] {
  $in | str join (char esep)
}

def not-empty [] {
  not ($in | is-empty)
}

def when-empty [d: closure] {
  if ($in | is-empty) {do $d} else {$in}
}

def default-empty [d] {
  when-empty {|| $d}
}

def is-available [] {
  not (which $in | is-empty)
}

def first-available [] {
  for cmd in $in {
    if ($cmd | is-available) {
      return $cmd
    }
  }
}

def first-exists [] {
  for path in $in {
    if ($path | path exists) {
      return $path
    }
  }
}

def 'path starts-with' [d: path] {
  ($in + '/') | str starts-with ($d + '/')
}

######################################################################
# ENV CONVERSIONS
#
# Specifies how environment variables are:
# - converted from string to value on startup (from_string)
# - converted back to a string for external commands (to_string)
#
# Note: The conversions happen *after* config.nu is loaded.
######################################################################

$env.ENV_CONVERSIONS = {
  PATH: {
    from_string: {|s| $s | split paths}
    to_string: {|v| $v | paths join}
  }
  MANPATH: {
    from_string: {|s| $s | split paths}
    to_string: {|v| $v | paths join}
  }
}

######################################################################
# ENV VARS
######################################################################

# Sometimes USER isn't set so just use LOGNAME if available.
if ('USER' not-in $env) and ('LOGNAME' in $env) {
  $env.USER = $env.LOGNAME
}

$env.JAVA_HOME = ([/opt/graalvm /usr/java/latest /usr/lib/jvm/java] | first-exists)

# https://docs.volta.sh/advanced/installers#skipping-volta-setup
$env.VOLTA_HOME = ('~/.volta' | path expand)
# https://docs.volta.sh/advanced/pnpm
$env.VOLTA_FEATURE_PNPM = '1'

# Convert PATH immediately and manipulate.
$env.PATH = (
  $env | get -i 'PATH' | default '' | split paths |
  prepend [
    ~/bin                    # personal and overrides
    ([$env.VOLTA_HOME 'bin'] | path join) # volta node/pnpm
    ~/.local/bin             # npm i -g, make install
    ~/node_modules/.bin      # yarn global add
    ~/go/bin                 # go install
    ~/.gem/bin               # gem install --user-install --bindir ~/.gem/bin
    ~/.cask/bin              # homebrew
    ~/.cargo/bin             # cargo install
    /usr/lib64/ccache/bin    # ccache on gentoo
    /usr/lib64/ccache        # ccache on debian/fedora
    /usr/local/bin /usr/local/sbin
    (if ($env.JAVA_HOME | not-empty) {[$env.JAVA_HOME 'bin'] | path join})
  ] |
  append [
    /usr/bin /bin /usr/sbin /sbin
    /var/lib/flatpak/exports/bin # avoid needing "flatpak run ..."
  ] |
  compact |
  path expand --no-symlink | uniq
)

$env.MANPATH = (
  $env | get -i 'MANPATH' |
  (when-empty {|| (do -i {^manpath} | str trim)}) |
  (default-empty '/usr/local/share/man:/usr/share/man') |
  split paths |
  prepend [ ~/.local/share/man /usr/local/share/man ] |
  append [ /usr/share/man ] |
  path expand --no-symlink | uniq
)

# unset ${!LC_*}
for it in ($env | transpose k) {if $it.k =~ '^LC_' {hide-env $it.k}}
$env.LANG = 'en_US.UTF-8'
$env.LC_COLLATE = 'C'

$env.COLORPAGER = 'less'
$env.EDITOR = ([nvim vim vi] | first-available)
$env.FZF_DEFAULT_COMMAND = 'fd --type f --hidden'
$env.FZF_DEFAULT_OPTS = '--reverse'
$env.GIT_EDITOR = $env.EDITOR
$env.GPG = (do -i {^tty} | str trim)
$env.LESS = '-isXFRQ'
$env.LESSCHARSET = 'utf-8'
$env.LESSOPEN = '||/usr/bin/lesspipe.sh %s'
$env.MANPAGER = "sh -c 'col -bx | bat -l man -p'"
$env.MANROFFOPT = '-c'
$env.PAGER = 'less'
$env.PYTHONSTARTUP = ('~/.pythonstartup' | path expand -n)
$env.RIPGREP_CONFIG_PATH = ('~/.config/ripgrep/ripgreprc' | path expand -n)
$env.RSYNC_RSH = 'ssh'
$env.STEAM_RUNTIME_PREFER_HOST_LIBRARIES = '1'
$env.VAGRANT_CHECKPOINT_DISABLE = 'yes'
$env.VIRSH_DEFAULT_CONNECT_URI = 'qemu:///system'

$env.TERM = (
  # Start with whatever is in TERM already.
  ($env | get -i 'TERM' | default-empty 'xterm') |

  # Do some replacements, optimistically upgrading xterm to xterm-256color for
  # the moment.
  (
    if $in == 'ansi' {'vt100'}
    else if ($in == 'xterm') {'xterm-256color'}
    else if ($in =~ '^screen|^tmux') {$in}
    else if (($env | get -i 'COLORTERM' | default '') =~
      '^roxterm$|^Terminal$|^gnome-terminal$') {'xterm-256color'}
    else {$in}
  ) |

  # Convert to list with fallbacks, for example:
  #   xterm-kitty -> [xterm-kitty xterm-256color xterm]
  (
    if (['alacritty' 'xterm-256color' 'xterm-kitty'] | any {|it| str contains $it}) {
      [$in 'xterm-256color' 'xterm']
    } else if ($in | str starts-with 'rxvt-') {
      [$in 'rxvt' 'xterm']
    } else if ($in | str starts-with 'screen') {
      ['screen-256color' $in 'screen']
    } else if ($in | str starts-with 'tmux') {
      ['tmux-256color' 'screen-256color' $in 'tmux' 'screen']
    } else {
      [$in]
    }
  ) |

  # Now that we have a prioritized list with fallbacks, choose the first that
  # is available on the current system.
  (do {
    let terms = $in
    # Don't call external toe command. It's slow and doesn't work the same on
    # all Linux distros.
    let toes = (
      ['~/.terminfo' '/etc/terminfo' '/lib/terminfo' '/usr/share/terminfo'] |
      reduce -f [] {|d, acc|
        $acc ++ (
          try {ls ([$d * *] | path join) | get name | path basename}
          catch {[]}
        )
      }
    )
    for term in $terms {
      if ($toes | any {|toe| $term == $toe}) {
        return $term
      }
    }
    return ($terms | last) # most conservative
  })
)

######################################################################
# COMMANDS
######################################################################

alias 'core cd' = cd

def-env cd [arg: path = ~] {
  if $arg == '^' {
    core cd (topdir)
  } else if ($arg | path type) == 'file' {
    core cd ($arg | path expand | path dirname)
  } else {
    core cd $arg
  }
}

def topdir [d?: path] {
  if ($d | is-empty) and (not ($env | get -i 'TOPDIR' | is-empty)) {
    return $env.TOPDIR
  }

  # Calling cd avoids needing our own error handling for bad args.
  cd ($d | default-empty $env.PWD)
  let $d = $env.PWD

  # Check for PYTHONPATH match.
  # This overrides any marker file matching.
  if not (($env | get -i 'PYTHONPATH') | is-empty) {
    let pp = ($env.PYTHONPATH | path expand)
    if ($d | path starts-with $pp) {
      return $pp
    }
  }

  # Check for end of line.
  if ($d == '/') or ($d == ('~' | path expand)) {
    error make {msg: "Can't find topdir"}
  }

  # Check for marker file.
  if ([
    '.bzr'
    '.git'
    '.hg'
    '.project'
    '.topdir'
    'package.json'
    'pom.xml'
    'yarn.lock'
  ] | any {|it| $it | path exists}) {
    return $d
  }

  # Climb the tree.
  topdir ($d | path dirname)
}

source ~/.config/nushell/mine.nu
source ~/.config/nushell/local.nu
