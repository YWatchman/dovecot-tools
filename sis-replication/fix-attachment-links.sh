#!/bin/bash
# 
# 

USERNAME="${1}"

# Catch all attachments with failures
ALLERR="$(doveadm fetch -u $USERNAME text all 2>&1 1>/dev/null | rg 'open\((.*[0-9])\)' -or '$1')"

for attachment in $ALLERR; do
    echo "Analyzing new attachment..."
    echo $attachment
    attachment_wo_lpart=$(echo $attachment | rev | cut -f3- -d - | rev)
    # Find attachment which this is deduplicated from but lost
    original_attachment=$(ls $attachment_wo_lpart*)
    echo $original_attachment
    echo "linking attachment..."
    ln -s $original_attachment $attachment
    echo "----"
done

# After all of this, you still have to run an index until the mailbox doesn't argue the existence of the attachment
# $ doveadm -Dv index -u <username> text all
