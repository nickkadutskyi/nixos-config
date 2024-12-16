#!/bin/zsh

b=$(tput bold)
n=$(tput sgr0)

AL=$(which alacritty)
TMSOCK="alacritty"
TMCONF="$HOME/.config/alacritty/.tmux.conf"
TMEXEC="$(which tmux)"

FORMAT_PANES="#{session_id}:#{window_id}:#{pane_id}:#{pane_current_command}:#W:#{?session_attached,a,n}"
CMD_PANES=$TMEXEC' -L '$TMSOCK' list-panes -a -F "'$FORMAT_PANES'" | grep ":n$"'
CMD_PANES_KILL=$TMEXEC' -L '$TMSOCK' kill-pane -t $(echo {1} | cut -w -f1)'
CMD_PANES_FORMAT='awk -F: '\''{prefix=sprintf("%s:%s.%s", $1,$2,$3); printf "%-11s  (%s) %s\n", prefix, $4, $5}'\'
CMD_PANES_RELOAD=$CMD_PANES' | '$CMD_PANES_FORMAT

export FZF_DEFAULT_OPTS_FILE=~/.fzfrc

# Create a new alacritty window and attach to a new tmux session
function new-window() {
    $AL msg create-window -e $TMEXEC -L $TMSOCK new \; source-file $TMCONF
}

# Reattach to all tmux windows in alacritty group
function reattach-all() {
    $TMEXEC -L $TMSOCK list-sessions \
        -F "#{session_name}:#{?session_attached,a,n}" |
        grep ":n$" |
        while read -r ses; do
            name=$(echo $ses | cut -d: -f1)
            $AL msg create-window -e $TMEXEC -L $TMSOCK attach -d -t $name
        done
}

function init-select-pane() {
    panes=$(eval $CMD_PANES)
    if [ ! -z "$panes" ]; then
        $AL msg create-window -e /bin/zsh \
            -c "~/.config/alacritty/scripts.sh select-pane '$panes'"
    fi
}

function select-pane() {
    printf '\e]0;%s\e\\' "Manage persistent shells"
    if [ -z "$1" ]; then
        echo "No panes provided"
        exit 1
    fi
    sel_pane=$(
        echo $1 | eval $CMD_PANES_FORMAT |
            fzf --sort --reverse \
                --header=$'Manage persistent shells\nENTER: attach, CTRL-K: kill, CTRL-C: cancel' \
                --header-first \
                --bind 'enter:accept' \
                --bind 'ctrl-k:execute('$CMD_PANES_KILL')+reload('$CMD_PANES_RELOAD')'
    )
    pane=$(echo $sel_pane | cut -w -f1)
    if [ ! -z "$pane" ]; then
        $TMEXEC -L $TMSOCK a -d -t $pane
    else
        echo "No pane selected"
    fi
}

function usage() {
    echo "${b}Usage:${n} $1 [command [args]]"
    echo "${b}Commands:${n}"
    echo "  ${b}init-select-pane${n}             Init tmux pane selector in a new alacritty window."
    echo "  ${b}select-pane${n} [list of panes]  Prompt user to select a tmux pane to attach to."
    echo "  ${b}new-window${n}                   Create a new alacritty window and attach to a new tmux session."
    echo "  ${b}reattach-all${n}                 Reattach to all tmux widows in $TMSOCK group."
}

case "$1" in

"new-window")
    new-window
    ;;
"reattach-all")
    reattach-all
    ;;
"init-select-pane")
    init-select-pane
    ;;
"select-pane")
    select-pane $2
    ;;
*)
    usage $0
    exit 1
    ;;
esac
