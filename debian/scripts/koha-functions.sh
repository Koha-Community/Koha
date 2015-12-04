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

    if find /etc/koha/sites -mindepth 1 -maxdepth 1 \
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

get_instances()
{
    find /etc/koha/sites -mindepth 1 -maxdepth 1\
                         -type d -printf '%f\n' | sort
}

get_loglevels()
{
    local instancename=$1
    local retval=$(xmlstarlet sel -t -v 'yazgfs/config/zebra_loglevels' /etc/koha/sites/$instancename/koha-conf.xml)
    if [ "$retval" != "" ]; then
        echo "$retval"
    else
        echo "none,fatal,warn"
    fi

}
