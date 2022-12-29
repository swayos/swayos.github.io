# needed for history and autosuggestions
export HISTFILE=~/.zhistory
export HISTSIZE=10000
export SAVEHIST=10000
# enable autosuggestions
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
else
    # for FreeBSD currently
    source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
# make midnight commander colorful
export TERM=xterm-256color
# by default backspace deletes whole word
bindkey "^H" backward-delete-char
# up/down should search in history not step
bindkey '\e[A' history-beginning-search-backward
bindkey '\e[B' history-beginning-search-forward
# colored prompt
autoload -U colors && colors
PS1="%{$fg[red]%}%n%{$reset_color%}@%{$fg[blue]%}%m %{$fg[yellow]%}%/ %{$reset_color%}% "
# called when executing a command
function preexec {
    print -Pn "\e]0;${(q)1}\e\\"
}

# startup sway on login on terminal 1
if [ "$(tty)" = "/dev/tty1" ] || [ "$(tty)" = "/dev/ttyv0" ] ; then
    if [ -z "$XDG_RUNTIME_DIR" ]; then
	export XDG_RUNTIME_DIR="$HOME/.config/xdg"
	rm -rf $XDG_RUNTIME_DIR
	mkdir -p $XDG_RUNTIME_DIR
	#chmod 0777 $XDG_RUNTIME_DIR
    fi
    export QT_QPA_PLATFORMTHEME=gtk2
    export QT_QPA_PLATFORM=wayland
    export GDK_BACKEND=wayland
    export XDG_SESSION_TYPE=wayland
    export XDG_CURRENT_DESKTOP=sway
    export WLR_NO_HARDWARE_CURSORS=1
    XDG_CURRENT_DESKTOP=sway dbus-run-session sway
    #exec sway
fi
