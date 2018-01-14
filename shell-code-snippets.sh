function check_version() {
    local tag="$(curl -u "hiulit:a07204881fe7a38dc8fcd4f37f6f49544a21848a" --silent "https://api.github.com/repos/hiulit/RetroPie-Fun-Facts-Splashscreens/releases/latest" |
        grep '"tag_name":' |
        sed -E 's/.*"([^"]+)".*/\1/')"
    echo "$tag"
}

function get_last_commit() {
    local last_commit="$(curl -u "hiulit:a07204881fe7a38dc8fcd4f37f6f49544a21848a" --silent "https://api.github.com/repos/hiulit/RetroPie-Fun-Facts-Splashscreens/commits/master" |
    grep '"date":' |
    sed -E 's/.*"([^"]+)".*/\1/' |
    tail -1)"
    last_commit="$(echo "$last_commit" | sed 's/\(.*\)T\([0-9]*:[0-9]*\).*/\1 \2/')"
    last_commit="$(date --date "$last_commit $offset_s sec" +%F\ %T)"
    echo "$last_commit"
}

function date_to_stamp() {
    date --utc --date "$1" +%s
}

function stamp_to_date() {
    date --utc --date "1970-01-01 $1 sec" "+%Y-%m-%d %T"
}

function date_diff() {
    case "$1" in
        -s) sec=1; shift;;
        -m) sec=60; shift;;
        -h) sec=3600; shift;;
        -d) sec=86400; shift;;
        -w) sec=604800; shift;;
        -M) sec=2629744; shift;;
        -y) sec=31556926; shift;;
        *) sec=1;;
    esac
    date1="$(date_to_stamp "$1")"
    date2="$(date_to_stamp "$2")"
    diff_sec="$((date2-date1))"
    if [[ "$diff_sec" -lt 0 ]]; then
        abs=-1
    else
        abs=1
    fi
    echo "$((diff_sec/sec*abs))"
}

function round() {
    echo "$((($1 + $2 / 2) / $2))"
}

version="$(check_version)"
now="$(date +%F\ %T)"
offset="$(date +%::z)"
offset="${offset#+}"
offset_s="$(echo "$offset" | awk -F: '{print ($1*3600) + ($2*60) + $3}')"
last_commit="$(get_last_commit)"
diff_s="$(date_diff "$last_commit" "$now")"
if (( "$diff_s" < 60 )); then
    time_diff="$diff_s"
    [[ "$time_diff" -eq 1 ]] && smh="second" || smh="seconds"
elif (( "$diff_s" >= 60 && "$diff_s" < 3600 )); then
    time_diff="$(round $diff_s 60)"
    [[ "$time_diff" -eq 1 ]] && smh="minute" || smh="minutes"
elif (( "diff_s" >= 3600 && "$diff_s" < 86400  )); then
    time_diff="$(round $diff_s 3600)"
    [[ "$time_diff" -eq 1 ]] && smh="hour" || smh="hours"
elif (( "$diff_s" >= 86400 && "$diff_s" < 604800 )); then
    time_diff="$(round $diff_s 86400)"
    [[ "$time_diff" -eq 1 ]] && smh="day" || smh="days"
elif (( "$diff_s" >= 604800 && "$diff_s" < 2629744 )); then
    time_diff="$(round $diff_s 604800)"
    [[ "$time_diff" -eq 1 ]] && smh="week" || smh="weeks"
elif (( "$diff_s" >= 2629744 && "$diff_s" < 31556926 )); then
    time_diff="$(round $diff_s 2629744)"
    [[ "$time_diff" -eq 1 ]] && smh="month" || smh="months"
elif (( "$diff_s" >= 31556926 )); then
    time_diff="$(round $diff_s 31556926)"
    [[ "$time_diff" -eq 1 ]] && smh="year" || smh="years"
fi
last_commit="About $time_diff $smh ago"
