#!/bin/bash

# Set the location of calibre-upgrade and launchd plist.
upgrade_script=https://github.com/eli-schwartz/calibre-installer/raw/master/osx/calibre-upgrade.sh
launchd_plist=https://github.com/eli-schwartz/calibre-installer/raw/master/osx/com.calibre.updater.plist

# Functions

do_install()
{
    wget -nv -O /usr/local/bin/calibre-upgrade.sh $upgrade_script
    chmod 755 /usr/local/bin/calibre-upgrade.sh
}

add_launchd()
{
    echo "Installing launchd global daemon..."
    wget -nv -O /Library/LaunchDaemons/com.calibre.updater.plist $launchd_plist
    chmod 644 /Library/LaunchDaemons/com.calibre.updater.plist
}

usage()
{
	cat <<- _EOF_
		Usage: calibre-installer.sh [OPTIONS]
		Installs the calibre-upgrade command and creates a Launchd daemon to regularly update calibre.

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
add_launchd
