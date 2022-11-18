#!/usr/local/bin/bash
# This script will backup a location as a tar and move to a specified location
# The script will also clean up any tars left over at that location older than the specified time frame

BACKUP_STORAGE_LOCATION="$HOME/OneDrive/backups"
BACKUP_FILE_PREFIX="backup-projects"
BACKUP_LOCATION="$HOME/Projects"
TIME="2w"
FORMAT="%Y-%m-%d-%H-%M"

TITLE="Backup Script"

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

DATE_TO_CLEAN=$(date -v-$TIME +$FORMAT)
TODAY=$(date +$FORMAT)

backup_function () {
    if ! [[ -d "${BACKUP_LOCATION}" ]]; then
        echo "Creating backup folder"
        mkdir $BACKUP_LOCATION
    fi

    echo "Creating backup file ${BACKUP_FILE_PREFIX}-${TODAY}.tar.gz"
    tar -zcf "${BACKUP_STORAGE_LOCATION}/${BACKUP_FILE_PREFIX}-${TODAY}.tar.gz" "${BACKUP_LOCATION}" > /dev/null 2>&1 &
    PREVIOUS_PID=$!
    wait -f $PREVIOUS_PID
    declare -a FILE=$(find ${BACKUP_STORAGE_LOCATION} -name ${BACKUP_FILE_PREFIX}-${TODAY}.tar.gz)
    FILE_LENGTH=${#FILE[@]}

    if [[ $FILE_LENGTH -gt 0 ]] && [[ $FILE_LENGTH -lt 2 ]]; then
        return 0
    elif [[ $FILE_LENGTH -gt 1 ]]; then
        return 1
    else
        return 2
    fi 
}

# Backup and make directory if it doesn't exist
backup_function &
PID_BACKUP=$!
wait -f $PID_BACKUP

# Cleanup
declare -a RESULTS=$(find "${BACKUP_STORAGE_LOCATION}" -name "${BACKUP_FILE_PREFIX}*.tar.gz")
for FILE_TO_CHECK in $RESULTS
do
    FILE_NAME="`echo $FILE_TO_CHECK | sed -e s~${BACKUP_STORAGE_LOCATION}/~~`"

    DATE_TO_CHECK="`echo $FILE_TO_CHECK | sed -e s~${BACKUP_STORAGE_LOCATION}/${BACKUP_FILE_PREFIX}-~~`"
    DATE_TO_CHECK="`echo $DATE_TO_CHECK | sed -e s~.tar.gz~~`"
    if [[ $(date -jf $FORMAT $DATE_TO_CHECK +%s) -lt $(date -jf $FORMAT $DATE_TO_CLEAN +%s) ]]; then
        rm -f $FILE_TO_CHECK
        echo "Removed File: $FILE_NAME"
    fi
done

if [ -f "${BACKUP_STORAGE_LOCATION}/${BACKUP_FILE_PREFIX}-${TODAY}.tar.gz" ]
then
    osascript $SCRIPT_DIR/notify.scpt "The backup completed successfully" "$TITLE -- SUCCESS" "nosound"
else
    osascript $SCRIPT_DIR/notify.scpt "The backup failed" "$TITLE -- ERROR" "sound"
fi
