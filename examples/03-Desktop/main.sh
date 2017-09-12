#!/usr/bin/env bash.origin.script

depend {
    "app": "@com.github/pinf-to/to.pinf.com.apple.osx.app#s1"
}


rm -f "$HOME/Desktop/App.app" || true

CALL_app ensureOnDesktop {
    "id": "to.pinf.com.apple.osx.app~03",
    "name": "App",
    "on": {
        "launch": (bash () >>>

            touch "$__DIRNAME__/.launched"

        <<<)
    }
}

if [ ! -e "$HOME/Desktop/App.app" ]; then
    echo "ERROR: No app shortcut detected!"
    exit 1
fi


rm -f "$__DIRNAME__/.launched" || true

open "$HOME/Desktop/App.app"

sleep 1

if [ ! -e "$__DIRNAME__/.launched" ]; then
    echo "ERROR: No launch detected!"
    exit 1
fi
rm -f "$__DIRNAME__/.launched" || true
rm -f "$HOME/Desktop/App.app" || true


echo "OK"
