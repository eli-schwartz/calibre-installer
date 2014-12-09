#!/bin/bash

# Set the location of calibre-upgrade.
upgrade_script=https://github.com/eli-schwartz/calibre-installer/raw/master/linux/calibre-upgrade.sh

# Functions

do_install()
{
    wget -nv -O /usr/bin/calibre-upgrade.sh $upgrade_script
    chmod 755 /usr/bin/calibre-upgrade.sh
}

add_to_cron()
{
    echo "Installing crontab..."
    # Don't add a duplicate job. http://stackoverflow.com/questions/11532157/unix-removing-duplicate-lines-without-sorting
    (crontab -l; echo "0 6 * * 5 /usr/bin/calibre-upgrade.sh > /dev/null 2>&1") | cat -n - |sort -uk2 |sort -nk1 | cut -f2-| crontab -
}

usage()
{
	cat <<- _EOF_
		Usage: calibre-installer.sh [OPTIONS]
		Installs the calibre-upgrade command and creates a cron job to regularly update calibre.

		OPTIONS
		    -h, --help        Shows this help message.
_EOF_
}

# Options
while [ "$1" != "" ]; do
    case $1 in
        -h|--help)      usage
                        exit
                        ;;
        *)              echo "calibre-installer.sh: unrecognized option '$1'"
                        echo "Try 'calibre-installer.sh --help' for more information."
                        exit 1
    esac
    shift
done

# Main

## Check that we are running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "You can only install calibre if you have root permission."
    exit 1
fi

do_install

## Must check if cron is installed. Fallback on systemd (Arch Linux)?
##   [[ -d /usr/lib/systemd ]] && echo "Lets use systemd instead."
######################################################################
if (command -v crontab > /dev/null 2>&1);then
    add_to_cron
else
    echo "Failed to install a cron job -- system doesn't have cron installed."
fi
