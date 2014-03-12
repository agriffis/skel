#!/bin/bash

main() {
    cd
    exec >> .xsession-errors 2>&1
    source .bash_profile

    echo
    echo "-----------------------------------------"
    echo "Starting xsession: $(date)"
    echo "-----------------------------------------"
    echo

    set -x

    FQDN=$(hostname --long)
    XSERVER=${DISPLAY%%:*}
    [[ -n $XSERVER ]] && export XSERVER || unset XSERVER
    declare CHAIN=()
    #setup-agents
    #setup-keychain
    setup-pulseaudio
    setup-mpd
    setup-x11
    #setup-pycl
    setup-ipython
    setup-synergy
    setup-crashplan
    setup-redshift
    setup-transmission
    setup-emacs
    setup-desktop
    exec "${CHAIN[@]}"
}

link() {
    CHAIN=( "${CHAIN[@]}" "$@" )
}

linkf() {
    link bash -c "
        $(type $1 | sed 1d)
        $1
        \"\$@\"" --
}

setup-x11() {
    xset fp- ~/.fonts; xset fp+ ~/.fonts
    xset b off
    xset r rate 300 40
    xsetroot -solid '#555555'
    xrdb .Xdefaults
    xhost +local:
}

setup-super() {
    # Remap CapsLock to Super_R. We don't use Super_L because the gnome-shell
    # grabs that, but Super_R is part of Mod4, so this works!!
    xmodmap -e 'clear lock'
    xmodmap -e 'keycode 66 = Super_R'   # was CapsLock
    # Remap the left win-key to Super_R for the same reason.
    xmodmap -e 'keycode 133 = Super_R'  # was Super_L
}

setup-super2() {
    # The following hack protects super-p from being bound by
    # gnome-settings-daemon. We bind it to kill xbindkeys the first time it's
    # pressed.
    (
	exec xbindkeys -n -f /dev/stdin <<EOT
"kill $BASHPID"
 mod4 + p
EOT
    ) &
}

setup-scroll() {
    # Reverse buttons 4/5 and 6/7 to get mac-like scrolling
    declare x ids=$(xinput | grep 'slave.*pointer' | grep -o 'id=[0-9]*' | awk -F= '{print $2}')
    for x in $ids; do
        xinput set-button-map $x 1 2 3 5 4 7 6
    done
}

setup-agents() {
    if type gnome-keyring-daemon &>/dev/null; then
        _gkdfunc() {
            export $(gnome-keyring-daemon)
            trap "kill $GNOME_KEYRING_PID;exit" 0 1 2 3 15
        }
        linkf _gkdfunc
    else
        link ssh-agent
        link gpg-agent --daemon
    fi
}

setup-keychain() {
    # this doesn't really run keychain.
    # it just uses the keychain storage area.
    _kcfunc() {
        rm -f ~/.keychain/$HOSTNAME-*
        for v in SSH_AUTH_SOCK GPG_AGENT_INFO; do
            [[ -n ${!v} ]] || continue
            mkdir -p ~/.keychain
            printf "%s=%q; export %s\n" $v "${!v}" $v >> ~/.keychain/$HOSTNAME-sh
        done
    }
    linkf _kcfunc
}

setup-synergy() {
    case ${HOSTNAME%%.*} in
        gargan)
            _synergys() {
                synergys -f --config /home/aron/.quicksynergy/synergy.conf &
                trap "kill $!;exit" 0 1 2 3 15
            }
            linkf _synergys
            ;;
        frabjous|jasperodus)
            _synergyc() {
                synergyc -f gargan.jupiter &
                trap "kill $!;exit" 0 1 2 3 15
            }
            linkf _synergyc
            ;;
    esac
}

setup-pulseaudio() {
    if [[ -n $XSERVER ]]; then
        pax11publish -e -S $XSERVER
    fi
}

setup-mpd() {
    if [[ -n $XSERVER ]]; then
        export MPD_HOST=$XSERVER
    fi
}

setup-pywo() {
    ( cd src/pywo.hg && python pywo.py --daemon ) &
}

setup-pycl() {
    link chainlink skel/bin/pycl.py --
}

setup-ipython() {
    ipython notebook --port=8001 --no-browser &
}

setup-crashplan() {
    ( cd .crashplan/bin; ./CrashPlanEngine start )
}

setup-redshift() {
    if type -P redshift-gtk &>/dev/null; then
        _redshift() {
            ( sleep 10; redshift-gtk -l 42.75:-71.6 -t 6500:4500 ) &
            trap "kill $!; exit" 0 1 2 3 15
        }
        linkf _redshift
    fi
}

setup-transmission() {
    if [[ ${HOSTNAME%%.*} == gargan ]]; then
        _transmission() {
            ( sleep 10; transmission-gtk -m ) &
            trap "kill $!; exit" 0 1 2 3 15
        }
        linkf _transmission
    fi
}

setup-emacs() {
    if [[ $USER == aron ]]; then
        emacs --daemon
    fi
}

setup-gnome() {
    #setup-super
    #setup-super2
    ( sleep 10; setup-scroll ) &
    link gnome-session
}

setup-kde4() {
    export WINDOW_MANAGER=$(type -P ${wm:-kwin})
    export KDEWM=$WINDOW_MANAGER
    link startkde
}

setup-xfce4() {
    setup-super
    export WINDOW_MANAGER=$(type -P ${wm:-xfwm4})
    link xfce4-session
}

setup-awesome() {
    setup-super
    setup-scroll
    link dbus-launch --exit-with-session
    link chainlink dropbox start --
    link chainlink insync start --
    link awesome
}

setup-mate() {
    link mate-session
}

setup-desktop() {
    unset wm
    case $XSERVER:${HOSTNAME%%.*}:$USER in
        (*:gargan:aron)    setup-gnome ;; # twm & xterm ;;
        (*:frabjous:aron)  setup-kde4 ;; # twm & xterm ;;
        (*:oliva:amg)      wm=sawfish; setup-gnome ;; # Amy's workstation
        (*) setup-gnome ;; # fall-through default
    esac
}

[[ ${0##*/} != .xsession ]] || main "$@"
