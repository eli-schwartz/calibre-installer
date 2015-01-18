#!/bin/bash

# Unset git development source
export CALIBRE_DEVELOP_FROM=
# by default, switch is off
force_upgrade=0

# OSX command-line-tools bin
tools=/Applications/calibre.app/Contents/console.app/Contents/MacOS

# Functions

calibre_is_installed()
{
    [[ -e /Applications/calibre.app ]]
}

usage()
{
	cat <<- _EOF_
		Usage: calibre-upgrade.sh [OPTIONS]
		Upgrades calibre installation. Automatically checks if the current version is up to date.

		OPTIONS
		    -f, --force       Force an update. This is only useful if binaries
		                      were updated for a critical error. :shrug:
		    -h, --help        Displays this help message.
_EOF_
}

install_command_line_tools()
{
    ## Check that we are running as root
    if [[ $EUID -ne 0 ]]; then
        echo -e "You can only install the command-line tools if you have root permission."
    else
        #Symlink the command-line tools to /usr/bin
        ln -s $tools/* /usr/bin/
    fi
}

do_upgrade()
{
    if calibre_is_installed; then
        # shutdown calibre as each logged-in user.
        for i in $(users | tr ' ' '\n' | sort -u); do
            sudo -u $i $tools/calibre --shutdown-running-calibre
        done
        killall -q -v $tools/calibre-server && echo -e "Restart when upgrade is finished. ;)\n\n" || echo -e "No running calibre servers.\n\n"
    fi

    # Download and copy the DMG into /Applications
    ver=$(wget -q -O- http://code.calibre-ebook.com/latest)
    wget -nv -O /tmp/calibre-${ver}.dmg http://code.calibre-ebook.com/dist/osx32
    hdiutil attach -mountpoint /Volumes/calibre-${ver} /tmp/calibre-${ver}.dmg
    cp /Volumes/calibre-${ver}/calibre.app /Applications
    hdiutil detach /Volumes/calibre-${ver}

    install_command_line_tools
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

if calibre_is_installed; then
    $tools/calibre-debug -c "import urllib as u; from calibre.constants import numeric_version; raise SystemExit(int(numeric_version  < (tuple(map(int, u.urlopen('http://calibre-ebook.com/downloads/latest_version').read().split('.'))))))"
    UP_TO_DATE=$?
else
    echo -e "Calibre is not installed, installing...\n\n"
    UP_TO_DATE=1
fi

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
    calibre_is_installed && echo -e "Calibre is out-of-date. Upgrading...\n\n"
    do_upgrade
fi
