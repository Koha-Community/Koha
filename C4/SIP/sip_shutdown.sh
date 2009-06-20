#!/bin/bash

. $HOME/.bash_profile

# this is brittle: the primary server must have the lowest PPID
# this is brittle: ps behavior is very platform-specific, only tested on Debian Etch

target="SIPServer";
PROCPID=$(ps x -o pid,ppid,args --sort ppid | grep "$target" | grep -v grep | head -1 | awk '{print $1}');

if [ ! $PROCPID ] ; then
    echo "No processes found for $target";
    exit;
fi

echo "SIP Processes for this user ($USER):";
ps x -o pid,ppid,args --sort ppid | grep "$target" | grep -v grep ;
echo "Killing process #$PROCPID";
kill $PROCPID;
