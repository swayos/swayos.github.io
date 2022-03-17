# needed for history and autosuggestions
export HISTFILE=~/.zhistory
export HISTSIZE=10000
export SAVEHIST=10000
# enable autosuggestions
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
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
# make qt apps look like gtk2 and gtk3 apps
export QT_QPA_PLATFORMTHEME=gtk2
# called when executing a command
function preexec {
    print -Pn "\e]0;${(q)1}\e\\"
}
# startup sway on login on terminal 1
if [ "$(tty)" = "/dev/tty1" ] ; then
    # Your environment variables
    export QT_QPA_PLATFORM=wayland
    export XDG_SESSION_TYPE=wayland
    export XDG_CURRENT_DESKTOP=sway
    exec sway
fi
