#!/bin/bash

# Copyright 2012 Universidad Nacional de Cordoba
# Written by Tomas Cohen Arazi
#            Mark Tompsett
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

# Output simple help
usage() {
    local scriptname=$(basename $0)
    cat <<EOF
$scriptname

Query for missing dependencies. Print the install command for them if specified.

Usage:
$scriptname -r
$scriptname -ic
$scriptname -h

    -r  | --report             Report the status of Koha's dependencies
    -ic | --install-command    Display the install command for the missing dependencies
    -h  | --help               Display this help message
EOF
}

# Check if the package is installed
packageInstalled() {
    local package=$1
    local package_status=`dpkg-query --showformat='${Status}' \
                          -W $package 2> /dev/null`

    if [ "$package_status" == "install ok installed" ] ; then
        echo "yes"
    else
        echo "no"
    fi
}

# Get the installed package version
getPackageVersion() {
    local package=$1
    dpkg-query --showformat='${Version}' -W $package
}

# A parameter is required.
if [ "$#" -eq "0" ]; then
    usage
    exit 1
fi

# Initialize variables
CHECK=no
INSTALLCMD=no
HELP=no

# Loop over parameters
while (( "$#" )); do
    case $1 in
        -r | --report )
            CHECK=yes
            ;;
        -ic | --install-command )
            INSTALLCMD=yes
            ;;
        -h | --help)
            HELP=yes
            ;;
        * )
            usage
            exit 1
    esac
    shift
done

if [ "$HELP" = "yes" ]; then
    usage
    exit 0
fi

# Determine what directory this script is in, the packages files
# should be in the same path.
DIR=`dirname $0`

# Determine the Ubuntu release
UBUNTU_RELEASE=`lsb_release -r | cut -f2 -d'	'`
UBUNTU_PACKAGES_FILE=$DIR/ubuntu.$UBUNTU_RELEASE.packages

# Check for the release-specific packages file. Default to the general one
# but warn the user about LTS releases recommended, if they are attempting
# to do an install command option.
if [ ! -e $UBUNTU_PACKAGES_FILE ]; then
    UBUNTU_PACKAGES_FILE=$DIR/ubuntu.packages
    if [ "$INSTALLCMD" == "yes" ]; then
        echo "# There's no packages file for your distro/release"
        echo "# WARNING! We strongly recommend an LTS release."
    fi
fi

# We where asked to print the packages list and current versions (if any)
UBUNTU_PACKAGES=`awk '{print $1}' $UBUNTU_PACKAGES_FILE | grep -v '^\s*#' | grep -v '^\s*$'`

# Only output this on an install command option in order to maintain
# output equivalence to the former script, in the case of reporting
# only.
if [ "$INSTALLCMD" == "yes" ]; then

    # Tell them which file being used to determine the output.
    echo "# Using the $UBUNTU_PACKAGES_FILE file as source"

    # Comment for skiping the dots if needed ....
    if [ "$CHECK" == "no" ]; then
        echo -n "#"
    fi
fi

# Initialize variable to accumulate missing packages in.
MISSING_PACKAGES=""

# Loop used to accumulate the missing packages and display package information if requested to report.
for PACKAGE in $UBUNTU_PACKAGES; do

    # If an install command option is running, but not a report option,
    # There is no need to determine the version number. If it was
    # This would run even slower!

    # Test if the package is installed
    PACKAGE_INSTALLED=`packageInstalled $PACKAGE`

    # Determine the package version if it is installed.
    if [ "$PACKAGE_INSTALLED" == "yes" ]; then
        PACKAGE_VERSION=`getPackageVersion $PACKAGE`

    # otherwise default to 'none'.
    else
        PACKAGE_VERSION="none"
        MISSING_PACKAGES="$PACKAGE $MISSING_PACKAGES"
    fi

    # If we are supposed to report...
    if [ "$CHECK" == "yes" ]; then


        # report the package name and version number.
        echo "$PACKAGE = $PACKAGE_VERSION"

    # Otherwise, we'll just echo a dot for the impatient.
    else
        echo -n "."
    fi

done

# If we aren't reporting, then the last echo didn't have a newline.
if [ ! "$CHECK" == "yes" ]; then
    echo
fi

# If the install command was requested...
if [ "$INSTALLCMD" == "yes" ]; then

    # Give them a nicely indented command to copy, if dependencies are missing.
    if [ "${#MISSING_PACKAGES}" -gt "0" ]; then
        cat <<EOF
# Copy and paste the following command to install all Koha's dependencies on your system:
# Note: this command will run with admin privileges. Make sure your user has sudo rights
EOF

        echo -e "\tsudo apt-get install $MISSING_PACKAGES"

    # Otherwise tell them all is well.
    else
        echo -e "# All dependencies installed!"
        echo -e "# Please confirm the version numbers are sufficient"
        echo -e "# By running koha_perl_deps.pl -m -u."
    fi

fi

exit 0
