#!/bin/bash

## Set defaults
sourcefiles="https://github.com/eli-schwartz/calibre-installer/raw/master/linux/"
destdir=""
installwith="wget -nv -P"

# Functions

do_install()
{
    ${installwith} "${destdir}${bindir}" "${sourcefiles}/calibre-upgrade.sh"
    chmod 755 "${destdir}${bindir}/calibre-upgrade.sh"
}

add_to_cron()
{
    echo "Installing cron job..."
    # Don't add a duplicate job. http://stackoverflow.com/questions/11532157/unix-removing-duplicate-lines-without-sorting
    (crontab -l 2>/dev/null; echo "0 6 * * 5 ${bindir}/calibre-upgrade.sh > /dev/null 2>&1") | cat -n - |sort -uk2 |sort -nk1 | cut -f2-| crontab -
}

add_systemd_timer()
{
    echo "Installing systemd timer..."
    ${installwith} "${destdir}/usr/lib/systemd/system" "${sourcefiles}/calibre-upgrade.timer"
    ${installwith} "${destdir}/usr/lib/systemd/system" "${sourcefiles}/calibre-upgrade.service"
    if [[ -z "${destdir}" ]]; then
        echo "Activating systemd timer..."
        systemctl enable calibre-upgrade.timer
        systemctl start calibre-upgrade.timer
    fi
}

usage()
{
	cat <<- _EOF_
		Usage: calibre-installer.sh [OPTIONS]
		Installs the calibre-upgrade command and creates a cron job to regularly update calibre.

		OPTIONS
		    -h, --help        Shows this help message.
		    -l, --local       Use currentdir for resource files.
		    -d, --destdir     Install root (for packaging purposes).
_EOF_
}

# Options
while [ "$1" != "" ]; do
    case $1 in
        -h|--help)
            usage
            exit
            ;;
        -l|--local)
            installwith="install -Dm644 -t"
            sourcefiles="./"
            ;;
        -d|--destdir)
            shift
            destdir="${1}"
            ;;
        *)
            echo "calibre-installer.sh: unrecognized option '$1'"
            echo "Try 'calibre-installer.sh --help' for more information."
            exit 1
            ;;
    esac
    shift
done

# Main

# Apparently Fedora demands you stick the script in /usr/local/sbin
bindir="/usr/bin"
if [[ -f /etc/redhat-release ]]; then
    bindir="/usr/local/sbin"
fi

## Check that we are running as root
if [[ ${EUID} -ne 0 ]]; then
    echo -e "You can only install calibre if you have root permission."
    exit 1
fi

do_install

if  [[ -d /usr/lib/systemd ]]; then
    add_systemd_timer
elif (command -v crontab > /dev/null 2>&1);then
    echo "Systemd not found, falling back on cron for scheduling."
    add_to_cron
else
    echo "Failed to install a systemd timer or cron job -- system does not have systemd or cron installed."
fi
