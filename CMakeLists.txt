# mod-playerbots-bis — AzerothCore module build registration.
#
# Sources are auto-collected from src/ (recursively) by AzerothCore's module
# system; AC_ADD_SCRIPT registers the script-loader path. The module compiles
# into the shared `modules` static library alongside mod-playerbots, so its
# subclasses of the playerbots engine classes link directly.
#
# REQUIRES mod-playerbots to be present and enabled — this is a playerbots
# extension, not a standalone module. It does NOT modify mod-playerbots: it
# registers replacement "item usage" / "item upgrade" values into the shared
# value contexts, which the playerbots engine resolves by name.
#
# THE DIRECTORY NAME MATTERS. AzerothCore derives the loader entry point from
# the module folder name, so this module must live in modules/mod-playerbots-bis
# for Addmod_playerbots_bisScripts() to be called. Cloning it under any other
# folder name builds fine and then does nothing at runtime.

AC_ADD_SCRIPT("${CMAKE_CURRENT_LIST_DIR}/src")
