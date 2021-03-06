#! /bin/sh

# 00-scriptmanager.sh is run periodically by a private cronjob.
# * It synchronises the local copy of synodiagd with the current github branch
# * It checks the state of and (re-)starts daemons if they are not (yet) running.

CLNT=$(hostname)
branch=$(cat /root/.synodiagd.branch)

cd /root/synodiagd
PATH=$PATH:/opt/bin:/opt/sbin

 # Check which code has changed
 git fetch origin
 # git diff --name-only
 # git log --graph --oneline --date-order --decorate --color --all

 DIFFlibd=$(git --no-pager diff --name-only $branch..origin/$branch -- ./libdaemon.py)
 DIFFlibs=$(git --no-pager diff --name-only $branch..origin/$branch -- ./libsmart.py)
 DIFFd12=$(git --no-pager diff --name-only $branch..origin/$branch -- ./daemon12.py)
 DIFFd13=$(git --no-pager diff --name-only $branch..origin/$branch -- ./daemon13.py)
 DIFFd14=$(git --no-pager diff --name-only $branch..origin/$branch -- ./daemon14.py)
 DIFFd15=$(git --no-pager diff --name-only $branch..origin/$branch -- ./daemon15.py)
 DIFFd19=$(git --no-pager diff --name-only $branch..origin/$branch -- ./daemon19.py)
 DIFFd98=$(git --no-pager diff --name-only $branch..origin/$branch -- ./daemon98.py)
 DIFFd99=$(git --no-pager diff --name-only $branch..origin/$branch -- ./daemon99.py)

  # Synchronise local copy with $branch
 git pull
 git fetch origin
 git checkout $branch
 git reset --hard origin/$branch && \
 git clean -f -d

#python -m compileall .
# Set permissions
chmod -R 744 *

if [[ ! -d /tmp/synodiagd ]]; then
  mkdir /tmp/synodiagd
fi

######## Stop daemons ######

if [[ -n "$DIFFd12" ]]; then
  logger -t synodiagd "Source daemon12 has changed."
  ./daemon12.py stop
fi
if [[ -n "$DIFFd13" ]]; then
  logger -t synodiagd "Source daemon13 has changed."
  ./daemon13.py stop
fi
if [[ -n "$DIFFd14" ]]; then
  logger -t synodiagd "Source daemon14 has changed."
  ./daemon14.py stop
fi
if [[ -n "$DIFFd15" ]]; then
  logger -t synodiagd "Source daemon15 has changed."
  ./daemon15.py stop
fi
if [[ -n "$DIFFd19" ]]; then
  logger -t synodiagd "Source daemon19 has changed."
  ./daemon19.py stop
fi
if [[ -n "$DIFFd98" ]]; then
  logger -t synodiagd "Source daemon98 has changed."
  ./daemon98.py stop
fi
if [[ -n "$DIFFd99" ]]; then
  logger -t synodiagd "Source daemon99 has changed."
  ./daemon99.py stop
fi

if [[ -n "$DIFFlibd" ]]; then
  logger -t synodiagd "Source libdaemon has changed."
  # stop all daemons
  ./daemon12.py stop
  ./daemon13.py stop
  ./daemon14.py stop
  ./daemon15.py stop
  ./daemon19.py stop
  ./daemon98.py stop
  ./daemon99.py stop
  rm ./libdaemon.pyc
fi

if [[ -n "$DIFFlibs" ]]; then
  logger -t ubundiagd "Source libsmart has changed."
  ./daemon19.py stop
  ./daemon99.py stop
  rm libsmart.pyc
fi

######## (Re-)start daemons ######

destale () {
  if [ -e /tmp/synodiagd/$1.pid ]; then
    if ! kill -0 $(cat /tmp/synodiagd/$1.pid)  > /dev/null 2>&1; then
      logger -t synodiagd "Stale daemon$1 pid-file found."
      rm /tmp/synodiagd/$1.pid
      ./daemon$1.py start
    fi
  else
    logger -t synodiagd "Found daemon$1 not running."
    ./daemon$1.py start
  fi
}

destale 12
destale 13
destale 14
destale 15
destale 19
destale 98
destale 99

#popd

# the $MOUNTPOINT is in /etc/fstab
# in the unlikely event that the mount was lost,
# remount it here.
MOUNTPOINT=/mnt/share1
MOUNTDRIVE=boson.lan:/srv/array1/dataspool
if grep -qs $MOUNTPOINT /proc/mounts; then
  # It's mounted.
  echo "mounted"
else
  # Mount the share containing the data
  echo "Mounting $MOUNTDRIVE on $MOUNTPOINT"
  mount $MOUNTDRIVE $MOUNTPOINT
fi
