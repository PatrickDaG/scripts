#!/bin/bash

set -uo pipefail
#Should really try not to leak shit and

function sendlogmail() {
	sendmail -t patrickdgro@gmail.com <<EOF
From: server@grossmannpoing.de
Subject: $1

$2
EOF
}
# to not leak any things
source /root/borg/borg.conf \
	|| die "error sourcing config file"

umount -l /media/backup
sshfs -o idmap=user "$SSH_REPO" /media/backup \
	|| die "error in ssh mount"

for i in "${BORG_DATASETS[@]}"
do
	DATE=$(date -u "+%Y-%m-%dT%H:%M:%SZ")
	SNAPSHOT="b""o""r""g""-""$DATE"
	zfs snapshot "$i""@""$SNAPSHOT" \
		|| die "error in snapshot creation"
	MOUNT_PATH=$(zfs get mountpoint -H -o value "$i") \
		|| die "error in getting mountpoint"
	if [[ $MOUNT_PATH == "none" ]];then
		continue
	fi
	SNAP_PATH="$MOUNT_PATH/.zfs/snapshot/$SNAPSHOT"
	cd "$SNAP_PATH" \
		|| die "error in changing into snap path"
	# backup everything
	RESULT=$(borg create --stats --exclude-caches --compression zstd \
		"::${i//\//"#"}@$SNAPSHOT" "$SNAP_PATH" \
		2>&1 ) \
		|| die "error in borg create \n \
			$RESULT"
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
		|| die "error in borg prune\n \
		$RESULT"
	sendlogmail "borg prune finished" "$RESULT"
done

umount /media/backup

