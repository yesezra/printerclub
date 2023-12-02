#!/usr/bin/bash

newmaildir="$HOME/.printerclub/Maildir/new/"
oldmaildir="$HOME/.printerclub/Maildir/cur/"
attachdir="$HOME/.printerclub/attachments/"

# Get new mail (in quiet mode to suppress errors)
getmail -q

# Ensure attachment directory exists
if [ ! -d "$DIRECTORY" ]; then
  mkdir attachdir
fi

# Extract attachments from new messages, then move the messages to the archive
for entry in `ls $maildir`; do
    mu extract -a $maildir$entry --target-dir=$attachdir
    mv $maildir$entry  $oldmaildir
done

# Print attachments
for attachment in `ls $attachdir`; do
    lp $attachdir$attachment
done

# Delete attachments
if [ -n "$(ls -A $attachdir 2>/dev/null)" ]
then
  rm $attachdir*
fi
