# Fully Automatic Calibre installer/updater

Growing out of this discussion: [Official Calibre PPA?](http://www.mobileread.com/forums/showthread.php?t=226228), here are some simple scripts to update calibre on different platforms.

Note: This can also perform the first-time install, since the version check returns the same failure for out-of-date as it does if there is no calibre installed.

Thanks to [aleyx](http://www.mobileread.com/forums/member.php?u=81327) for working out the version checking! ![2thumbsup](http://s.mobileread.com/i/smiliesadd1/2thumbsup.gif)

To install the script on linux, run the following command:

```bash
sudo -v && wget -nv -O- https://github.com/eli-schwartz/calibre-installer/raw/master/linux/calibre-installer.sh | sudo sh -
```

To install the script on OSX, run the following command:
```bash
sudo -v && wget -nv -O- https://github.com/eli-schwartz/calibre-installer/raw/master/osx/calibre-installer.sh | sudo sh -
```
