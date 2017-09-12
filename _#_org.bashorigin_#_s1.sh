#!/usr/bin/env bash.origin.script


function EXPORTS_ensure {

    # TODO: Use instance ID
    local tplBaseDir="$__DIRNAME__/tpl"
    local targetBaseDir="$(pwd)/.rt/to.pinf.com.apple.osx.app~/launch.app"

    rm -Rf "${targetBaseDir}" || true
    mkdir -p "$(dirname "${targetBaseDir}")"
    cp -Rf "${tplBaseDir}/launch.app" "${targetBaseDir}"

    if [ -z "$VERBOSE" ]; then
        "$__DIRNAME__/node_modules/.bin/nicns" \
            --in "${tplBaseDir}/icon.png" \
            --out "${targetBaseDir}/Contents/Resources/launchIcon.icns" \
            > /dev/null
    else
        "$__DIRNAME__/node_modules/.bin/nicns" \
            --in "${tplBaseDir}/icon.png" \
            --out "${targetBaseDir}/Contents/Resources/launchIcon.icns"
    fi

    # TODO: Use 'dec-to-op'
    BO_run_recent_node --eval '
        const PATH = require("path");
        const FS = require("fs");
        const config = require(PATH.join("$__DIRNAME__", "node_modules/codeblock")).thawFromJSON(process.argv[2]);

        if (!config.id) {
            throw new Error("config.id must be set!");
        }

        const commands = [];

        if (config.on.launch.getFormat() === "bash") {

            commands.push(config.on.launch.getCode());

        } else
        if (config.on.launch.getFormat() === "oascript") {

            commands.push([
                "osascript <<EOD",
                config.on.launch.getCode(),
                "EOD"
            ].join("\n"));

        } else {
            throw new Error("Unknown format: " + config.on.launch.getFormat());
            process.exit(1);
        }

        function replaceInPath (path) {
            var code = FS.readFileSync(path, "utf8");

            code = code.replace(/%%ID%%/g, config.id);
            code = code.replace(/%%COMMANDS%%/g, commands);

            FS.writeFileSync(path, code, "utf8");
        }

        replaceInPath(PATH.join(process.argv[1], "Info.plist"));
        replaceInPath(PATH.join(process.argv[1], "MacOS/launch"));

    ' "${targetBaseDir}/Contents" "$1"
}


function EXPORTS_ensureOnDesktop {

    targetPath=$(BO_run_recent_node --eval '
        const PATH = require("path");
        const FS = require("fs");
        const config = require(PATH.join("$__DIRNAME__", "node_modules/codeblock")).thawFromJSON(process.argv[1]);

        if (!config.name) {
            throw new Error("config.name must be set!");
        }

        process.stdout.write(PATH.join(process.env.HOME, "Desktop", config.name + ".app"));

    ' "$1")

    if [ ! -s "$targetPath" ]; then
        if [ -e "$targetPath" ]; then
            echo "ERROR: File already exists at '$targetPath'. Delete it first so we can symlink a new file."
            exit 1
        fi
    else
        return 0
    fi

    EXPORTS_ensure "$1"

    local targetBaseDir="$(pwd)/.rt/to.pinf.com.apple.osx.app~/launch.app"

    BO_log "$VERBOSE" "Linking '$targetBaseDir' to '$targetPath'"

    ln -s "$targetBaseDir" "$targetPath"

}
