# Security focused umask
# umask 077

# https://wiki.archlinux.org/title/GnuPG#Home_directory

if [ ! -d "$GNUPGHOME" ]; then
    mkdir -p $GNUPGHOME
fi

find $GNUPGHOME -type d -exec chmod 0700 {} \;
find $GNUPGHOME -type f -exec chmod 0600 {} \;
