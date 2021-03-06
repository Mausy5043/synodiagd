# synodiagd
**Diagnostics Gatherer for Synology NAS**

This repository provides a number of python-based daemons that gather various system diagnostics. Although specifically targeted at my own Synology NAS (DS411j), most will probably work (with minor modifications) on any Synology product and probably also on comparable (`busybox`-based systems).
The result of each deamon is a file containing comma-separated-values created in `/tmp/synodiagd/`

The code used to daemonise python code was borrowed from previous work by:
- Sander Marechal (see: http://www.jejik.com/articles/2007/02/a_simple_unix_linux_daemon_in_python/)
- Charles Menguy (see: http://stackoverflow.com/questions/10217067/implementing-a-full-python-unix-style-daemon-process)

and modified for my particular use-case. This includes a bash-scripts that keeps the daemons running.

NO code is provided for further processing of the data. E.g. adding the data to a rrdtool-database and/or graphing the data. This functionality is offered elsewhere.

Following daemons are provided:
- daemon12 - CPU load (from `/proc/loadavg` and `dstat`; requires `dstat` installed by e.g. `ipkg`)
- daemon13 - Network interfaces (bytes in/out from `/proc/net/dev`)
- daemon14 - Memory usage (from `/proc/meminfo`)
- daemon15 - Size of logfiles (`kern.log`, `messages` and `syslog.log`)
- daemon19 - Temperature of the disk-array in degC
- daemon99 - Data uploading to the server
