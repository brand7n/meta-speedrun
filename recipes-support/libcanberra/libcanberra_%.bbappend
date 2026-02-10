# Disable GTK2 module only - GTK3 module needed by gnome-settings-daemon (libcanberra-gtk3)
PACKAGECONFIG:remove = "gtk"
