#!/usr/bin/env bash.origin.script


if [ ! -e "$__DIRNAME__/node_modules" ]; then
    pushd "$__DIRNAME__" > /dev/null
        BO_run_npm install
    popd > /dev/null
fi


function EXPORTS_ensure {

    # TODO: Use instance ID
    local tplBaseDir="$__DIRNAME__/tpl"
    local targetBaseDir="$(pwd)/.rt/to.pinf.com.apple.osx.app~/launch.app"

    rm -Rf "${targetBaseDir}" || true
    mkdir -p "$(dirname "${targetBaseDir}")"
    cp -Rf "${tplBaseDir}/launch.app" "${targetBaseDir}"


    iconPath=$(BO_run_recent_node --eval '
        const PATH = require("path");
        const config = JSON.parse(process.argv[1]);
        process.stdout.write(config.iconPath || PATH.join("'${tplBaseDir}'", "icon.png"));
    ' "$1")


    function makeICNS {
        __sourcePath="$1"
        __targetPath="$2"
        if [ ! -e "$(dirname __targetPath)" ]; then
            mkdir -p "$(dirname __targetPath)"
        fi
        rm -f "${__targetPath}" || true
        __tmpPath="${__targetPath}.iconset"
        rm -Rf "${__tmpPath}" || true
        mkdir "${__tmpPath}"
        if ! BO_has "sips"; then
            BO_exit_error "'sips' command not found!"
        fi
        if ! BO_has "iconutil"; then
            BO_exit_error "'iconutil' command not found!"
        fi
        sips -z 16 16 ${__sourcePath} --out "${__tmpPath}/icon_16x16.png" > /dev/null
        sips -z 32 32 ${__sourcePath} --out "${__tmpPath}/icon_32x32.png" > /dev/null
        sips -z 128 128 ${__sourcePath} --out "${__tmpPath}/icon_128x128.png" > /dev/null
        sips -z 256 256 ${__sourcePath} --out "${__tmpPath}/icon_256x256.png" > /dev/null
        sips -z 512 512 ${__sourcePath} --out "${__tmpPath}/icon_512x512.png" > /dev/null
        sips -z 32 32 ${__sourcePath} --out "${__tmpPath}/icon_16x16@2x.png" > /dev/null
        sips -z 64 64 ${__sourcePath} --out "${__tmpPath}/icon_32x32@2x.png" > /dev/null
        sips -z 256 256 ${__sourcePath} --out "${__tmpPath}/icon_128x128@2x.png" > /dev/null
        sips -z 512 512 ${__sourcePath} --out "${__tmpPath}/icon_256x256@2x.png" > /dev/null
        sips -z 1024 1024 ${__sourcePath} --out "${__tmpPath}/icon_512x512@2x.png" > /dev/null
        iconutil -c icns "${__tmpPath}" -o "${__targetPath}" > /dev/null
        rm -Rf "${__tmpPath}"
    }

    makeICNS "${iconPath}" "${targetBaseDir}/Contents/Resources/launchIcon.icns"


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
            code = code.replace(/%%BO_ROOT_SCRIPT_PATH%%/g, process.env.BO_ROOT_SCRIPT_PATH || "\$HOME/.bash.origin");

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
