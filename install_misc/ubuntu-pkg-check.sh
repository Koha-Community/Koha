#!/bin/sh

UBUNTU_PACKAGES=`dirname $0`/ubuntu.packages

# sanity checks

if [ ! -e $UBUNTU_PACKAGES ]; then
  echo ERROR:  Could not find $UBUNTU_PACKAGES file for running check.
  exit
fi

# main

UBUNTU_PACKAGES_LIST=`awk '{print $1}' $UBUNTU_PACKAGES | grep -v '^\s*#' | grep -v '^\s*$'`
for F in $UBUNTU_PACKAGES_LIST; do
  UBUNTU_PKG_POLICY=`apt-cache policy $F | grep "Installed:"`
  UBUNTU_PKG_VERSION=`echo $UBUNTU_PKG_POLICY | awk '{print $2}'`
  echo "$F = $UBUNTU_PKG_VERSION"
done
