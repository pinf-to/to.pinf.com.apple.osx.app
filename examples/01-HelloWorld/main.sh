#!/usr/bin/env bash.origin.script

depend {
    "app": "@com.github/pinf-to/to.pinf.com.apple.osx.app#s1"
}

CALL_app ensure {
    "id": "to.pinf.com.apple.osx.app~01",
    "on": {
        "launch": (bash () >>>

            touch "$__DIRNAME__/.launched"

        <<<)
    }
}


rm -f "$__DIRNAME__/.launched" || true

open "$__DIRNAME__/.rt/to.pinf.com.apple.osx.app~/launch.app"

if [ ! -e "$__DIRNAME__/.launched" ]; then
    echo "ERROR: No launch detected!"
    exit 1
fi
rm -f "$__DIRNAME__/.launched" || true


echo "OK"
