# Enable Plymouth integration so GDM takes over Plymouth shutdown.
# Without this, GDM's service file has empty Conflicts=/After= for
# plymouth-quit.service, allowing it to kill the splash prematurely.
# With Plymouth enabled, GDM:
#   1. Conflicts with plymouth-quit.service (prevents it from running)
#   2. Internally calls plymouth deactivate + plymouth quit --retain-splash
#   3. Provides seamless visual handoff from splash to login screen
PACKAGECONFIG:append = " plymouth"
