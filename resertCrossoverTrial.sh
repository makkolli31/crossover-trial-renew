#!/usr/bin/env bash

# checck if pidof exists
PIDOF="$(which pidof)"
# and if not - install it
(test "${PIDOF}" && test -f "${PIDOF}") || brew install pidof

# find app in default paths
CO_PWD=~/Applications/CrossOver.app/Contents/MacOS
test -d "${CO_PWD}" || CO_PWD=/Applications/CrossOver.app/Contents/MacOS

test -d "${CO_PWD}" || (echo 'unable to detect app path. exiting...' && exit)

PWD="${CO_PWD}"
cd "${PWD}"

PROC_NAME='CrossOver'

# get all pids of CrossOver
pids=(`pgrep "${PROC_NAME}"`, `pidof "${PROC_NAME}"`, `ps -Ac | grep -m1 "${PROC_NAME}" | awk '{print $1}'`)
pids=`echo ${pids[*]}|tr ',' ' '`

# kills CrossOver process if it is running
[ "${pids}" ] && kill -9 `echo "${pids}"` > /dev/null 2>&1

# wait until app finish
sleep 3

# reset trial start date of crossover
plutil -remove FirstRunDate ~/Library/Preferences/com.codeweavers.CrossOver.plist
plutil -remove FirstRunVersion ~/Library/Preferences/com.codeweavers.CrossOver.plist
# reset trial start date of the bottles
for i in ~/Library/Application\ Support/CrossOver/Bottles/*; do
    if [ -d "$i" ]; then
        sed -i '' '/\[Software\\\\CodeWeavers\\\\CrossOver\\\\cxoffice\].*/,+5d' "$i/system.reg"
    fi
done

/usr/bin/osascript -e "display notification \"Crossover Trial Updated\""