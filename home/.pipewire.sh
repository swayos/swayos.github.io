# dbus-update-activation-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway &
pipewire &
pipewire-pulse &
sleep 2
wireplumber &
sleep 2
/usr/libexec/xdg-desktop-portal-wlr -r &
sleep 2
/usr/libexec/xdg-desktop-portal -r &
