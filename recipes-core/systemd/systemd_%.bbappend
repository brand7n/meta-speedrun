# Remove binfmt patch that doesn't apply to systemd 257.6
# The patch hunks fail against the newer units/meson.build
SRC_URI:remove = "file://0001-binfmt-Don-t-install-dependency-links-at-install-tim.patch"
