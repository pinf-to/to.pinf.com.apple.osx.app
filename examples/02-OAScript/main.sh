#!/usr/bin/env bash.origin.script

depend {
    "app": "@com.github/pinf-to/to.pinf.com.apple.osx.app#s1"
}

CALL_app ensure {
    "id": "to.pinf.com.apple.osx.app~02",
    "on": {
        "launch": (oascript () >>>

tell application "iTerm2"
	activate
    # TODO: Optionally open specific iterm session profile with bash shell so we do not need to enter our own bash shell.
    set newWindow to (create window with default profile)
    tell newWindow
        tell current session
            # TODO: Optionally do not exit parent shell (drop exit at the end) if opened workspace shell exits (say if in verbose mode)
            write text "touch \"$__DIRNAME__/.launched\""
        end tell
    end tell
end tell

        <<<)
    }
}


rm -f "$__DIRNAME__/.launched" || true

open "$__DIRNAME__/.rt/to.pinf.com.apple.osx.app~/launch.app"

sleep 1

osascript <<EOD
    tell application "iTerm2"
        activate
        tell current session of current window
            close
        end tell
    end tell
EOD

if [ ! -e "$__DIRNAME__/.launched" ]; then
    echo "ERROR: No launch detected!"
    exit 1
fi
rm -f "$__DIRNAME__/.launched" || true


echo "OK"
