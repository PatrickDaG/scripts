#!/bin/bash

set -uo pipefail
#Should really try not to leak shit and

function notify() {
	curl\
		-H "Title: Borg-backup"\
		-d "$1"\
		https://ntfy.lel.lol/borg-backup
}

function die() {
	curl\
		-H "Title: Borg-backup"\
		-H "Priority: urgent"\
		-d "$1"\
		https://ntfy.lel.lol/borg-backup
	exit 1
}

function sendlogmail() {
	sendmail -t patrickdgro@gmail.com <<EOF
From: server@grossmannpoing.de
Subject: $1

$2
EOF
}
# to not leak any things
source borg.conf \
	|| die "error sourcing config file"

# todo
notify "Have you thought to enable ssh mounting???"
#sshfs "$SSH_REPO": /media/backup

for i in "${BORG_DATASETS[@]}"
do
	DATE=$(date -u "+%Y-%m-%dT%H:%M:%SZ")
	SNAPSHOT="b""o""r""g""-""$DATE"
	notify "Started backup of $i"
	zfs snapshot "$i""@""$SNAPSHOT" \
		|| die "error in snapshot creation"
	MOUNT_PATH=$(zfs get mountpoint -H -o value "$i") \
		|| die "error in getting mountpoint"
	if [[ $MOUNT_PATH == "none" ]];then
		notify "$i not mounted"
		continue
	fi
	SNAP_PATH="$MOUNT_PATH/.zfs/snapshot/$SNAPSHOT"
	cd "$SNAP_PATH" \
		|| die "error in changing into snap path"
	# backup everything
	RESULT=$(borg create --stats --exclude-caches --compression zstd \
		"::${i//\//%}@$SNAPSHOT" "$SNAP_PATH" \
		2>&1 ) \
		|| die "error in borg create"
	notify "Finished backup of $i"
	sendlogmail "borg backup finished" "$RESULT"
	# prune old files
	RESULT=$(borg prune \
		--stats \
		--list \
		--prefix "borg-" \
		--keep-weekly 21 \
		--keep-monthly 48 \
		--keep-yearly 50 \
		"::" \
		2>&1
	) \
		|| die "error in borg prune"
	sendlogmail "borg prune finished" "$RESULT"
	notify "Finished prune of $i"
done
#fusermount3 -u /media/backup

