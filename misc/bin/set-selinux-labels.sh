#!/bin/sh
#
# This script changes selinux file labels for cgi scripts.
# It may be useful for Linux installations with SELinux (like CentOS, Fedora,
# RedHat among others) and having it enabled (enforcing mode).
#
# Copyright 2012 Rijksmuseum
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

usage() {
    echo "Usage: set-selinux-labels [-h] [-u] [-r] [-s] [-v]"
    echo "  -h prints help information."
    echo "  -u updates the selinux label for scripts in Koha installation."
    echo "    Note: you should be in the root directory of a Koha install."
    echo "  -r uses restorecon on scripts to restore default label."
    echo "  -s shows all files (incl. scripts), not having default label."
    echo "  -v provides (verbose) diagnostics per file (for update/restore)."
    echo
    echo "The output of -s may be confusing, but it does not reset any labels. It only prints informational messages from restorecon with -n flag."
}

updatelabel() {
    #Now set perl scripts to httpd_sys_script_exec_t
    #We skip scripts in: misc docs t xt and atomicupdate
    find -name "*.pl" -and ! -path "./docs/*" -and ! -path "./misc/*" -and ! -path "./t/*" -and ! -path "./xt/*" -and ! -path "./installer/data/mysql/atomicupdate/*" | xargs chcon $verbose -t httpd_sys_script_exec_t

    #Handle exceptions to the rule: scripts without .pl
    chcon $verbose -t httpd_sys_script_exec_t opac/unapi
    find opac/svc -type f | xargs chcon $verbose -t httpd_sys_script_exec_t
    find svc -type f | xargs chcon $verbose -t httpd_sys_script_exec_t
}

restorelabel() {
    find -name "*.pl" -and ! -path "./docs/*" -and ! -path "./misc/*" -and ! -path "./t/*" -and ! -path "./xt/*" -and ! -path "./installer/data/mysql/atomicupdate/*" | xargs restorecon $verbose
    restorecon $verbose opac/unapi
    find opac/svc -type f | xargs restorecon $verbose
    find svc -type f | xargs restorecon $verbose
}

showlabel() {
    restorecon -r -n -v *
}

#First: check on chcon xargs restorecon
chcon --help >/dev/null 2>&1
retval=$?
if [ $retval -ne 0 ]; then
    echo "Chcon command not found. Exiting script now.";
    exit;
fi
xargs --help >/dev/null 2>&1
retval=$?
if [ $retval -ne 0 ]; then
    echo "Xargs command not found. Exiting script now.";
    exit;
fi
restorecon -n >/dev/null 2>&1
retval=$?
if [ $retval -ne 0 ]; then
    echo "Restorecon command not found. Exiting script now.";
    exit;
fi

#No arguments?
if [ $# -eq 0 ]; then
    usage
    exit
fi

#Check command line options
restore=0
show=0
update=0
verbose=
while getopts "hrsuv" option; do
    case $option in
    h)
        usage
        exit;;
    r)
        restore=1;;
    s)
        show=1;;
    u)
        update=1;;
    v)
        verbose="-v";;
    esac
done

#Check if you are on root level of Koha installation
if [ ! -e kohaversion.pl ]; then
    echo "You are not in root directory of Koha install. Cannot continue. Bye.";
    exit;
fi

#Cannot update and restore together
if [ $update -eq 1 ] && [ $restore -eq 1 ]; then
    echo "You cannot run update and restore at the same time."
    exit;
fi

#Now run the job or print usage
if [ $update -eq 1 ]; then updatelabel; exit; fi
if [ $restore -eq 1 ]; then restorelabel; exit; fi
if [ $show -eq 1 ]; then showlabel; exit; fi
usage
