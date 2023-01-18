#!/bin/bash

USERNAME="${1}"

# Catch all attachments with failures
ALLERR="$(doveadm fetch -u $USERNAME text all 2>&1 1>/dev/null | rg 'open\((.*[0-9])\)' -or '$1')"

TOTAL="$(echo $ALLERR | tr ' ' "\n")"
if [ -z "$TOTAL" ]; then
	TOTAL=$((0))
else
	TOTAL="$(echo $ALLERR | tr ' ' "\n" | wc -l)"
	echo "TOTAAL: $TOTAL"
	TOTAL="$(($TOTAL))"
fi
CURRENT=0

if [ $TOTAL -eq 0 ]; then
	echo "All done now!"
	exit 0;
fi

for attachment in $ALLERR; do
    ((CURRENT=$CURRENT+1))
    echo "Analyzing new attachment..."
    echo $attachment
    attachment_wo_lpart=$(echo $attachment | rev | cut -f3- -d - | rev)
    # Find attachment which this is deduplicated from but lost
    original_attachment=$(ls $attachment_wo_lpart*)
    echo $original_attachment
    echo "linking attachment..."
    ln -P $original_attachment $attachment
    echo "setting correct ownership..."
    chown vmail:vmail $attachment
    echo "---- $CURRENT/$TOTAL"
done

# After all of this, you still have to run an index until the mailbox doesn't argue the existence of the attachment
# $ doveadm -Dv index -u <username> '*'
until doveadm -Dv index -u $USERNAME '*'
do
    echo "trying again..."
done

exit 1
