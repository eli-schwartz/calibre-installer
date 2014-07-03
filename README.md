# Fully Automatic Calibre installer/updater

Growing out of this discussion: [Official Calibre PPA?](http://www.mobileread.com/forums/showthread.php?t=226228), here is a simple bash script to update calibre on linux.
Note: This can also perform the first-time install, since the version check returns the same failure for out-of-date as it does if there is no calibre installed.

Thanks to [aleyx](http://www.mobileread.com/forums/member.php?u=81327) for working out the version checking! ![2thumbsup](http://s.mobileread.com/i/smiliesadd1/2thumbsup.gif)

The following script will be saved as "/usr/bin/calibre-upgrade.sh".

```bash
#!/bin/bash

calibre-debug -c "import urllib as u; from calibre.constants import numeric_version; raise SystemExit(int(numeric_version < (tuple(map(int, u.urlopen('http://calibre-ebook.com/downloads/latest_version').read().split('.'))))))"

UP_TO_DATE=$?

if [ $UP_TO_DATE = 0 ]; then
	echo "Calibre is up-to-date."
else
	calibre --shutdown-running-calibre
	killall calibre-server

	sudo -v; wget -nv -O- https://github.com/kovidgoyal/calibre/raw/master/setup/linux-installer.py | sudo python -c "import sys; main=lambda:sys.stderr.write('Download Failed\n'); exec(sys.stdin.read()); main()"
fi
```
