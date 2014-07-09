#!/bin/bash

# Unset git development source
export CALIBRE_DEVELOP_FROM=
# by default, switch is off
force_upgrade=0


# Functions

usage()
{
	cat <<- _EOF_
		Usage: calibre-upgrade.sh [OPTIONS]
		Upgrades calibre installation. Automaticaly checks if the current version is up to date.

		OPTIONS
		    -f, --force       Force an update. This is only useful if binaries
		                      were updated for a critical error. :shrug:
		    -h, --help        Displays this help message.
_EOF_
}

do_upgrade()
{
    calibre --shutdown-running-calibre
    killall calibre-server
    wget -nv -O- https://github.com/kovidgoyal/calibre/raw/master/setup/linux-installer.py | python -c "import sys; main=lambda x,y:sys.stderr.write('Download failed\n'); exec(sys.stdin.read()); main()"
}

# Options
while [ "$1" != "" ]; do
    case $1 in
        -h|--help)      usage
                        exit
                        ;;
        -f|--force)     shift
                        force_upgrade=1
                        ;;
        *)              echo "calibre-upgrade.sh: unrecognized option '$1'"
                        echo "Try 'calibre-upgrade.sh --help' for more information."
                        exit 1
    esac
    shift
done

# Main

    calibre-debug -c "import urllib as u; from calibre.constants import numeric_version; raise SystemExit(int(numeric_version  < (tuple(map(int, u.urlopen('http://calibre-ebook.com/downloads/latest_version').read().split('.'))))))"

UP_TO_DATE=$?


if [ "$UP_TO_DATE" = 0 ]; then
    echo "Calibre is up-to-date"

    if [ "$force_upgrade" = 1 ]; then
        echo ""
        echo "Forcing upgrade anyway -- are you sure you want to continue? [y/n]"
        read answer

        if [[ "$answer" = "y" || "$answer" = "yes" ]]; then
            do_upgrade
        else
            echo "Exiting..."
            exit 1
        fi
    fi
else
    do_upgrade
fi
