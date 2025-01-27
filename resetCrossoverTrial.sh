#!/usr/bin/env bash

# Ensure pidof is installed; install via Homebrew if not present
if ! command -v pidof &>/dev/null; then
    echo "pidof not found. Installing pidof via Homebrew..."
    brew install pidof
fi

# Define the path to CrossOver
CROSSOVER_PATH="/Applications/CrossOver.app/Contents/MacOS"

# Define the process name
PROC_NAME="CrossOver"

while true; do
    # Get all PIDs of CrossOver using various methods
    pids=($(pgrep "$PROC_NAME") $(pidof "$PROC_NAME") $(ps -Ac | grep -m1 "$PROC_NAME\$" | awk '{print $1}'))

    # Remove any duplicate or empty entries
    unique_pids=()
    for pid in "${pids[@]}"; do
        if [[ -n "$pid" && ! " ${unique_pids[@]} " =~ " ${pid} " ]]; then
            unique_pids+=("$pid")
        fi
    done

    # Kill CrossOver processes if any are running
    if [ ${#unique_pids[@]} -gt 0 ]; then
        echo "Killing CrossOver processes: ${unique_pids[@]}"
        kill -9 "${unique_pids[@]}" >/dev/null 2>&1
    else
        echo "No CrossOver processes found."
    fi

    sleep 3

    remaining_pids=($(pgrep "$PROC_NAME") $(pidof "$PROC_NAME") $(ps -Ac | grep -m1 "$PROC_NAME\$" | awk '{print $1}'))
    if [ ${#remaining_pids[@]} -eq 0 ]; then
        break
    fi
done

# Reset trial start date of CrossOver
while true; do
    if /usr/libexec/PlistBuddy -c "Print :FirstRunDate" ~/Library/Preferences/com.codeweavers.CrossOver.plist &>/dev/null; then
        plutil -remove FirstRunDate ~/Library/Preferences/com.codeweavers.CrossOver.plist
    fi

    if /usr/libexec/PlistBuddy -c "Print :FirstRunVersion" ~/Library/Preferences/com.codeweavers.CrossOver.plist &>/dev/null; then
        plutil -remove FirstRunVersion ~/Library/Preferences/com.codeweavers.CrossOver.plist
    fi
    if ! /usr/libexec/PlistBuddy -c "Print :FirstRunDate" /path/to/your.plist &>/dev/null; then
        echo "FirstRunDate not found in plist file. Deletion succesfull."
        break
    fi
done

# Reset trial start date of the bottles
while true; do
for i in ~/Library/Application\ Support/CrossOver/Bottles/*; do
    if [ -d "$i" ]; then
        sed -i '' '/\[Software\\\\CodeWeavers\\\\CrossOver\\\\cxoffice\].*/,+5d' "$i/system.reg"
        break
    fi
    done

    if ! grep -q '\[Software\\\\CodeWeavers\\\\CrossOver\\\\cxoffice\]' "$i/system.reg"; then
        echo "Bottle trial reset succesfull."
        break
    fi
done
/usr/bin/osascript -e "display notification \"Crossover Trial Updated\""