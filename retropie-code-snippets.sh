function get_system_platform() {
    . "$home/RetroPie-Setup/scriptmodules/helpers.sh"
    . "$home/RetroPie-Setup/scriptmodules/system.sh"
    get_platform
    echo "$__platform"
}

function get_screen_resolution_x() {
    if [[ "$(get_system_platform)" != "x86" ]]; then
        local screen_resolution="$(fbset -s | grep -o -P '(?<=").*(?=")')"
        echo "$screen_resolution" | cut -dx -f1
    else
        xdpyinfo | awk -F '[ x]+' '/dimensions:/{print $3}'
    fi
}


function get_screen_resolution_y() {
    if [[ "$(get_system_platform)" != "x86" ]]; then
        local screen_resolution="$(fbset -s | grep -o -P '(?<=").*(?=")')"
        echo "$screen_resolution" | cut -dx -f2
    else
        xdpyinfo | awk -F '[ x]+' '/dimensions:/{print $4}'
    fi
}
