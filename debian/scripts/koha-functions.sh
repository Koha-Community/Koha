#!/bin/sh
#
# koha-functions.sh -- shared library of helper functions for koha-* scripts
# Copyright 2014 - Tomas Cohen Arazi
#                  Universidad Nacional de Cordoba
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


die()
{
    echo "$@" 1>&2
    exit 1
}

warn()
{
    echo "$@" 1>&2
}

get_apache_config_for()
{
    local site=$1
    local sitefile="/etc/apache2/sites-available/$site"

    if is_instance $site; then
        if [ -f "$sitefile.conf" ]; then
            echo "$sitefile.conf"
        elif [ -f "$sitefile" ]; then
            echo "$sitefile"
        fi
    fi
}

get_opacdomain_for()
{
    local site=$1

    if [ -e /etc/koha/koha-sites.conf ]; then
        . /etc/koha/koha-sites.conf
    else
        echo "Error: /etc/koha/koha-sites.conf not present." 1>&2
        exit 1
    fi
    local opacdomain="$OPACPREFIX$site$OPACSUFFIX$DOMAIN"
    echo "$opacdomain"
}

get_intradomain_for()
{
    local site=$1

    if [ -e /etc/koha/koha-sites.conf ]; then
        . /etc/koha/koha-sites.conf
    else
        echo "Error: /etc/koha/koha-sites.conf not present." 1>&2
        exit 1
    fi
    local intradomain="$INTRAPREFIX$site$INTRASUFFIX$DOMAIN"
    echo "$intradomain"
}

letsencrypt_get_opacdomain_for()
{
    local site=$1

    if [ -e /var/lib/koha/$site/letsencrypt.enabled ]; then
        . /var/lib/koha/$site/letsencrypt.enabled
    else
        local opacdomain=$(get_opacdomain_for $site)
    fi
    echo "$opacdomain"
}

is_enabled()
{
    local site=$1
    local instancefile=$(get_apache_config_for $site)

    if [ "$instancefile" = "" ]; then
        return 1
    fi

    if grep -q '^[[:space:]]*Include /etc/koha/apache-shared-disable.conf' \
            "$instancefile" ; then
        return 1
    else
        return 0
    fi
}

is_instance()
{
    local instancename=$1

    if find -L /etc/koha/sites -mindepth 1 -maxdepth 1 \
                         -type d -printf '%f\n'\
          | grep -q -x "$instancename" ; then
        return 0
    else
        return 1
    fi
}

is_email_enabled()
{
    local instancename=$1

    if [ -e /var/lib/koha/$instancename/email.enabled ]; then
        return 0
    else
        return 1
    fi
}

is_letsencrypt_enabled()
{
    local instancename=$1

    if [ -e /var/lib/koha/$instancename/letsencrypt.enabled ]; then
        return 0
    else
        return 1
    fi
}

is_sip_enabled()
{
    local instancename=$1

    if [ -e /etc/koha/sites/$instancename/SIPconfig.xml ]; then
        return 0
    else
        return 1
    fi
}

is_sitemap_enabled()
{
    local instancename=$1

    if [ -e /var/lib/koha/$instancename/sitemap.enabled ]; then
        return 0
    else
        return 1
    fi
}

is_zebra_running()
{
    local instancename=$1

    if daemon --name="$instancename-koha-zebra" \
            --pidfiles="/var/run/koha/$instancename/" \
            --user="$instancename-koha.$instancename-koha" \
            --running ; then
        return 0
    else
        return 1
    fi
}

is_indexer_running()
{
    local instancename=$1

    if daemon --name="$instancename-koha-indexer" \
            --pidfiles="/var/run/koha/$instancename/" \
            --user="$instancename-koha.$instancename-koha" \
            --running ; then
        return 0
    else
        return 1
    fi
}

is_plack_enabled()
{
    local site=$1
    local instancefile=$(get_apache_config_for $site)

    if [ "$instancefile" = "" ]; then
        return 1
    fi

    if grep -q '^[[:space:]]*Include /etc/koha/apache-shared-opac-plack.conf' \
            "$instancefile" && \
       grep -q '^[[:space:]]*Include /etc/koha/apache-shared-intranet-plack.conf' \
            "$instancefile" ; then
        return 0
    else
        return 1
    fi
}

is_plack_running()
{
    local instancename=$1

    if start-stop-daemon --pidfile "/var/run/koha/${instancename}/plack.pid" \
            --status ; then
        return 0
    else
        return 1
    fi
}

adjust_paths_dev_install()
{
# Adjust KOHA_HOME, PERL5LIB for dev installs, as indicated by
# corresponding tag in koha-conf.xml

    local instancename=$1
    local dev_install=""

    if [ "$instancename" != "" ] && is_instance $instancename; then
        dev_install=$(run_safe_xmlstarlet $instancename dev_install)
    fi

    if [ "$dev_install" != "" ] && [ "$dev_install" != "0" ]; then
        DEV_INSTALL=1
        KOHA_HOME=$(run_safe_xmlstarlet $instancename intranetdir)
        PERL5LIB=$KOHA_HOME
    else
        DEV_INSTALL=""
    fi
}

get_instances()
{
    find -L /etc/koha/sites -mindepth 1 -maxdepth 1\
                         -type d -printf '%f\n' | sort
}

get_loglevels()
{
    local instancename=$1
    local retval=$(run_safe_xmlstarlet $instancename zebra_loglevels)
    if [ "$retval" != "" ]; then
        echo "$retval"
    else
        echo "none,fatal,warn"
    fi
}

get_tmpdir()
{
    if [ "$TMPDIR" != "" ]; then
        if [ -d "$TMPDIR" ]; then
            echo $TMPDIR
            return 0
        fi
        # We will not unset TMPDIR but just default to /tmp here
        # Note that mktemp (used later) would look at TMPDIR
        echo "/tmp"
        return 0
    fi
    local retval=$(mktemp -u)
    if [ "$retval" = "" ]; then
        echo "/tmp"
        return 0
    fi
    echo $(dirname $retval)
}

run_safe_xmlstarlet()
{
    # When a bash script sets -e (errexit), calling xmlstarlet on an
    # unexisting key would halt the script. This is resolved by calling
    # this function in a subshell. It will always returns true, while not
    # affecting the exec env of the caller. (Otherwise, errexit is cleared.)
    local instancename=$1
    local myexpr=$2
    set +e; # stay on the safe side
    echo $(xmlstarlet sel -t -v "yazgfs/config/$myexpr" /etc/koha/sites/$instancename/koha-conf.xml)
    return 0
}
