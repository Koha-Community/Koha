#!/bin/sh

# determine what directory this script is in, because the packages files
# should be there too.
DIR=`dirname $0`

#determine which vbersion of ubuntu
VERSION=`lsb_release -r | cut -f2 -d'	'`
UBUNTU_PACKAGES=$DIR/ubuntu.$VERSION.packages

# sanity checks
if [ ! -e $UBUNTU_PACKAGES ]; then
   echo "WARNING! We strongly recommend an LTS release."
   UBUNTU_PACKAGES=$DIR/ubuntu.packages
fi
echo "Using the $UBUNTU_PACKAGES file."

# main
UBUNTU_PACKAGES_LIST=`awk '{print $1}' $UBUNTU_PACKAGES | grep -v '^\s*#' | grep -v '^\s*$'`
for F in $UBUNTU_PACKAGES_LIST; do
   UBUNTU_PKG_POLICY=`apt-cache policy $F 2> /dev/null | grep "Installed:"`
   if [ "${#UBUNTU_PKG_POLICY}" -eq "0" ]; then
      UBUNTU_PKG_POLICY="Installed: \(none\)\*"
   fi
   UBUNTU_PKG_VERSION=`echo $UBUNTU_PKG_POLICY | awk '{print $2}'`
   echo "$F = $UBUNTU_PKG_VERSION"
done
