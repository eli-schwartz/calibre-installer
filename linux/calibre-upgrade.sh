#!/bin/bash

# Unset git development source
export CALIBRE_DEVELOP_FROM=
# by default, switch is off
force_upgrade=0


# Functions

calibre_is_installed()
{
    command -v calibre >/dev/null 2>&1
}

usage()
{
	cat <<- _EOF_
		Usage: calibre-upgrade.sh [OPTIONS]
		Upgrades calibre installation. Automatically checks if the current version is up to date.
		Must be run as root.

		OPTIONS
		    -f, --force       Force an update. This is only useful if binaries
		                        were updated for a critical error. :shrug:
		    -p, --prefix      Root of installation. calibre is installed by default to /opt
		    -h, --help        Displays this help message.
_EOF_
}

do_upgrade()
{
    if calibre_is_installed; then
        # shutdown calibre as each logged-in user.
        for i in $(users | tr ' ' '\n' | sort -u); do
            sudo -u ${i} calibre --shutdown-running-calibre
        done
        killall -q -v calibre-server && echo -e "Restart when upgrade is finished. ;)\n\n" || echo -e "No running calibre servers.\n\n"
    fi
    wget -nv -O- https://github.com/kovidgoyal/calibre/raw/master/setup/linux-installer.py | python -c "import sys; main=lambda x,y:sys.stderr.write('Download failed\n'); exec(sys.stdin.read()); main('${prefix}')"
}

# Options
while [ "$1" != "" ]; do
    case $1 in
        -h|--help)
            usage
            exit
            ;;
        -f|--force)
            force_upgrade=1
            ;;
        -p|--prefix)
            shift
            prefix="${1}"
            ;;
        *)
            echo "calibre-upgrade.sh: unrecognized option '$1'"
            echo "Try 'calibre-upgrade.sh --help' for more information."
            exit 1
    esac
    shift
done

# Main

## Check that we are running as root
if [[ ${EUID} -ne 0 ]]; then
    echo -e "You can only install calibre if you have root permission."
    exit 1
fi



if calibre_is_installed; then
    calibre-debug -c "import urllib as u; from calibre.constants import numeric_version; raise SystemExit(int(numeric_version  < (tuple(map(int, u.urlopen('http://code.calibre-ebook.com/latest').read().split('.'))))))"
    UP_TO_DATE=$?
else
    echo -e "Calibre is not installed, installing...\n\n"
    UP_TO_DATE=1
fi

if [ "${UP_TO_DATE}" = 0 ]; then
    echo "Calibre is up-to-date"

    if [ "${force_upgrade}" = 1 ]; then
        echo ""
        echo "Forcing upgrade anyway -- are you sure you want to continue? [y/n]"
        read answer

        if [[ "${answer}" = "y" || "${answer}" = "yes" ]]; then
            do_upgrade
        else
            echo "Exiting..."
            exit 1
        fi
    fi
else
    calibre_is_installed && echo -e "Calibre is out-of-date. Upgrading...\n\n"
    do_upgrade
fi
