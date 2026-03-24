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
# along with this program.  If not, see <https://www.gnu.org/licenses/>.


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

    if [ -e /var/lib/koha/$instancename/sip.enabled ]; then
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

# --- Service management abstraction ---
# Systemd is the primary path. Legacy daemon/start-stop-daemon is the fallback.

_KOHA_INIT_BACKEND=""

koha_init_backend()
{
    if [ -z "$_KOHA_INIT_BACKEND" ]; then
        if [ -d /run/systemd/system ] && \
           systemctl list-unit-files koha-plack@.service >/dev/null 2>&1; then
            _KOHA_INIT_BACKEND="systemd"
        else
            _KOHA_INIT_BACKEND="sysv"
        fi
    fi
    echo "$_KOHA_INIT_BACKEND"
}

# Map service + queue to systemd unit name
_koha_systemd_unit()
{
    local service=$1 instance=$2 queue=$3

    if [ "$service" = "worker" ] && [ -n "$queue" ] && [ "$queue" != "default" ]; then
        echo "koha-worker-${queue}@${instance}.service"
    else
        echo "koha-${service}@${instance}.service"
    fi
}

# Unified service control: start|stop|restart|reload|status
koha_service_ctl()
{
    local action=$1 service=$2 instance=$3 queue=$4

    local unit=$(_koha_systemd_unit "$service" "$instance" "$queue")

    case "$action" in
        start|stop|restart)
            systemctl "$action" "$unit" ;;
        reload)
            systemctl reload-or-restart "$unit" ;;
        status)
            systemctl status "$unit" ;;
    esac
}

# --- is_*_running: systemd-aware with legacy fallback ---

is_sip_running()
{
    local instancename=$1
    if [ "$(koha_init_backend)" = "systemd" ]; then
        systemctl is-active --quiet "$(_koha_systemd_unit sip $instancename)"
        return
    fi
    daemon --name="$instancename-koha-sip" \
        --pidfiles="/var/run/koha/$instancename/" \
        --user="$instancename-koha.$instancename-koha" \
        --running
}

is_zebra_running()
{
    local instancename=$1
    if [ "$(koha_init_backend)" = "systemd" ]; then
        systemctl is-active --quiet "$(_koha_systemd_unit zebra $instancename)"
        return
    fi
    daemon --name="$instancename-koha-zebra" \
        --pidfiles="/var/run/koha/$instancename/" \
        --user="$instancename-koha.$instancename-koha" \
        --running
}

is_indexer_running()
{
    local instancename=$1
    if [ "$(koha_init_backend)" = "systemd" ]; then
        systemctl is-active --quiet "$(_koha_systemd_unit indexer $instancename)"
        return
    fi
    daemon --name="$instancename-koha-indexer" \
        --pidfiles="/var/run/koha/$instancename/" \
        --user="$instancename-koha.$instancename-koha" \
        --running
}

is_es_indexer_running()
{
    local instancename=$1
    if [ "$(koha_init_backend)" = "systemd" ]; then
        systemctl is-active --quiet "$(_koha_systemd_unit es-indexer $instancename)"
        return
    fi
    daemon --name="$instancename-koha-es-indexer" \
        --pidfiles="/var/run/koha/$instancename/" \
        --user="$instancename-koha.$instancename-koha" \
        --running
}

is_worker_running()
{
    local instancename=$1
    local queue=$2

    if [ "$(koha_init_backend)" = "systemd" ]; then
        systemctl is-active --quiet "$(_koha_systemd_unit worker $instancename $queue)"
        return
    fi
    local name=$(get_worker_name "$instancename" "$queue")
    daemon --name="$name" \
        --pidfiles="/var/run/koha/$instancename/" \
        --user="$instancename-koha.$instancename-koha" \
        --running
}

get_worker_name()
{
    local name=$1
    local queue=$2

    if [ "$queue" = "" ] || [ "$queue" = "default" ]; then
        echo "${name}-koha-worker"
    else
        echo "${name}-koha-worker-${queue}"
    fi
}

get_worker_queues()
{
    for queue in default long_tasks; do
        echo $queue
    done;
}

is_plack_enabled_opac()
{
    local instancefile=$1

    if [ "$instancefile" = "" ]; then
        return 1
    fi

    # remember 0 means success/true in bash.
    if grep -q '^[[:space:]]*Include /etc/koha/apache-shared-opac-plack.conf' \
            "$instancefile" ; then
        return 0
    else
        return 1
    fi
}

is_plack_enabled_intranet()
{
    local instancefile=$1

    if [ "$instancefile" = "" ]; then
        return 1
    fi

    # remember 0 means success/true in bash.
    if grep -q '^[[:space:]]*Include /etc/koha/apache-shared-intranet-plack.conf' \
            "$instancefile" ; then
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

    if is_plack_enabled_opac $instancefile ; then
        enabledopac=1
    else
        enabledopac=0
    fi
    if is_plack_enabled_intranet $instancefile ; then
        enabledintra=1
    else
        enabledintra=0
    fi

    # remember 0 means success/true in bash.
    if [ "$enabledopac" != "$enabledintra" ] ; then
        echo "$site has a plack configuration error. Enable or disable plack to correct this."
        return 0
    elif [ "$enabledopac" = "1" ] ; then
        return 0
    else
        return 1
    fi
}

is_plack_running()
{
    local instancename=$1
    if [ "$(koha_init_backend)" = "systemd" ]; then
        systemctl is-active --quiet "$(_koha_systemd_unit plack $instancename)"
        return
    fi
    start-stop-daemon --pidfile "/var/run/koha/${instancename}/plack.pid" \
        --user="$instancename-koha" --status
}

is_z3950_enabled()
{
    local instancename=$1

    if [ -e /etc/koha/sites/$instancename/z3950/config.xml ]; then
        return 0
    else
        return 1
    fi
}

is_z3950_running()
{
    local instancename=$1
    if [ "$(koha_init_backend)" = "systemd" ]; then
        systemctl is-active --quiet "$(_koha_systemd_unit z3950 $instancename)"
        return
    fi
    start-stop-daemon --pidfile "/var/run/koha/${instancename}/z3950-responder.pid" \
        --user="$instancename-koha" --status
}

is_elasticsearch_enabled()
{
    local instancename=$1

    # is querying the DB fails then $searching won't match 'Elasticsearch'. Ditching STDERR
    search_engine=$(koha-shell $instancename -c "/usr/share/koha/bin/admin/koha-preferences get SearchEngine 2> /dev/null")

    if [ "$search_engine" = "Elasticsearch" ]; then
        return 0
    else
        return 1
    fi
}

adjust_paths_git_install()
{
# Adjust KOHA_HOME, PERL5LIB, KOHA_BINDIR for git installs

    local instancename=$1

    if is_git_install $instancename; then
        KOHA_HOME=$(run_safe_xmlstarlet $instancename intranetdir)
        PERL5LIB="$KOHA_HOME:$KOHA_HOME/lib"
        KOHA_BINDIR=misc
    else
        KOHA_BINDIR=bin
    fi
}

is_git_install()
{
    local instancename=$1 git_install

    # env var GIT_INSTALL overrules koha-conf entry
    if [ -n "$GIT_INSTALL" ]; then
        if [ "$GIT_INSTALL" != "0" ]; then return 0; else return 1; fi
    fi

    # now check koha-conf; looking at dev_install as historical fallback
    if [ "$instancename" != "" ] && is_instance $instancename; then
        git_install=$(run_safe_xmlstarlet $instancename git_install)
        if [ -z "$git_install" ]; then git_install=$(run_safe_xmlstarlet $instancename dev_install); fi
    fi
    if [ -n "$git_install" ] && [ "$git_install" != "0" ]; then
        return 0; # true
    else
        return 1
    fi
}

is_debug_mode()
{
    local instancename=$1 debug_mode

    # env var DEBUG_MODE overrules koha-conf entry
    if [ -n "$DEBUG_MODE" ]; then
        if [ "$DEBUG_MODE" != "0" ]; then return 0; else return 1; fi
    fi

    # now check koha-conf
    if [ "$instancename" != "" ] && is_instance $instancename; then
        debug_mode=$(run_safe_xmlstarlet $instancename debug_mode)
    fi
    if [ -n "$debug_mode" ] && [ "$debug_mode" != "0" ]; then
        return 0; # true
    else
        return 1
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

get_max_record_size()
{
    local instancename=$1
    local retval=$(xmlstarlet sel -t -v 'yazgfs/config/zebra_max_record_size' /etc/koha/sites/$instancename/koha-conf.xml)
    if [ "$retval" != "" ]; then
        echo "$retval"
    else
        echo "1024"
    fi
}

get_tmp_path()
{
    local instancename=$1
    local retval=$(run_safe_xmlstarlet $instancename tmp_path)
    if [ "$retval" != "" ]; then
        echo "$retval"
        return 0
    fi
}

get_upload_path()
{
    local instancename=$1
    local retval=$(run_safe_xmlstarlet $instancename upload_path)
    if [ "$retval" != "" ]; then
        echo "$retval"
        return 0
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

get_es_indexer_batch_size()
{
    local instancename=$1
    local retval=$(xmlstarlet sel -t -v 'yazgfs/config/es_indexer_batch_size' /etc/koha/sites/$instancename/koha-conf.xml)
    if [ "$retval" != "" ]; then
        echo "$retval"
    else
        echo "10"
    fi
}

# --- Legacy (SysV) lifecycle functions ---
# These are the fallback implementations used when systemd is not available.
# They rely on globals set by the calling script (e.g. $STARMAN, $ZEBRA_DAEMON,
# $worker_DAEMON, $verbose, $debugger, etc.)

_sysv_start_plack()
{
    local instancename=$1

    local PIDFILE="/var/run/koha/${instancename}/plack.pid"
    local PLACKSOCKET="/var/run/koha/${instancename}/plack.sock"
    local PSGIFILE="/etc/koha/plack.psgi"
    local NAME="${instancename}-koha-plack"

    if [ -e "/etc/koha/sites/${instancename}/plack.psgi" ]; then
        PSGIFILE="/etc/koha/sites/${instancename}/plack.psgi"
    fi

    _check_and_fix_plack_perms $instancename

    PLACK_MAX_REQUESTS=$(run_safe_xmlstarlet $instancename plack_max_requests)
    [ -z $PLACK_MAX_REQUESTS ] && PLACK_MAX_REQUESTS="50"
    PLACK_WORKERS=$(run_safe_xmlstarlet $instancename plack_workers)
    [ -z $PLACK_WORKERS ] && PLACK_WORKERS="2"

    instance_user="${instancename}-koha"

    if is_debug_mode ${instancename} || [ -n "$development_environment" ]; then
        environment="development"
    else
        environment="deployment"
    fi
    daemonize="--daemonize"
    logging="--access-log /var/log/koha/${instancename}/plack.log \
             --error-log /var/log/koha/${instancename}/plack-error.log"
    max_requests_and_workers="--max-requests ${PLACK_MAX_REQUESTS} --workers ${PLACK_WORKERS}"

    if [ "$debugger" = "yes" ] && [ "$environment" = "development" ]; then
        daemonize=""
        logging=""
        max_requests_and_workers="--workers 1"
        STARMAN="/usr/bin/perl -d ${STARMAN}"
    fi

    STARMANOPTS="-M FindBin ${max_requests_and_workers} \
                 --user=${instance_user} --group ${instancename}-koha \
                 --pid ${PIDFILE} ${daemonize} ${logging} \
                 -E ${environment} --socket ${PLACKSOCKET} ${PSGIFILE}"

    if ! is_plack_running ${instancename}; then
        export KOHA_CONF="/etc/koha/sites/${instancename}/koha-conf.xml"

        log_daemon_msg "Starting Plack daemon for ${instancename}"

        current_dir=$(pwd)
        eval cd ~$instance_user

        if ${STARMAN} ${STARMANOPTS}; then
            log_end_msg 0
        else
            log_end_msg 1
        fi
        cd "$current_dir"
    else
        log_daemon_msg "Error: Plack already running for ${instancename}"
        log_end_msg 1
    fi
}

_sysv_stop_plack()
{
    local instancename=$1
    local PIDFILE="/var/run/koha/${instancename}/plack.pid"

    if is_plack_running ${instancename}; then
        log_daemon_msg "Stopping Plack daemon for ${instancename}"
        if start-stop-daemon --pidfile ${PIDFILE} --user="${instancename}-koha" --stop --retry=QUIT/30/KILL/5; then
            log_end_msg 0
        else
            log_end_msg 1
        fi
    else
        log_daemon_msg "Error: Plack not running for ${instancename}"
        log_end_msg 1
    fi
}

_sysv_restart_plack()
{
    local instancename=$1

    if is_plack_running ${instancename}; then
        _sysv_stop_plack $instancename && _sysv_start_plack $instancename
    else
        log_warning_msg "Plack not running for ${instancename}."
        _sysv_start_plack $instancename
    fi
}

_sysv_reload_plack()
{
    local instancename=$1
    local PIDFILE="/var/run/koha/${instancename}/plack.pid"

    if is_plack_running ${instancename}; then
        log_daemon_msg "Reloading Plack daemon for ${instancename}"
        if start-stop-daemon --pidfile ${PIDFILE} --user="${instancename}-koha" --stop --signal HUP; then
            log_end_msg 0
        else
            log_end_msg 1
        fi
    else
        log_daemon_msg "Error: Plack not running for ${instancename}"
        log_end_msg 1
    fi
}

_sysv_plack_status()
{
    local name=$1

    if is_plack_running ${name}; then
        log_daemon_msg "Plack running for ${name}"
        log_end_msg 0
    else
        log_daemon_msg "Plack not running for ${name}"
        log_end_msg 3
    fi
}

_check_and_fix_plack_perms()
{
    local instance=$1
    local files="/var/log/koha/${instance}/plack.log \
                 /var/log/koha/${instance}/plack-error.log"
    for file in ${files}; do
        if [ ! -e "${file}" ]; then
            touch ${file}
        fi
        chown "${instance}-koha":"${instance}-koha" ${file}
    done
}

_sysv_start_zebra()
{
    local name=$1
    local loglevels=$(get_loglevels ${name})
    local max_record_size=$(get_max_record_size ${name})

    if ! is_zebra_running $name; then
        _check_and_fix_zebra_perms ${name}

        DAEMONOPTS="--name=${name}-koha-zebra \
                    --pidfiles=/var/run/koha/${name}/ \
                    --errlog=/var/log/koha/${name}/zebra-error.log \
                    --output=/var/log/koha/${name}/zebra-output.log \
                    --verbose=1 --respawn --delay=30 \
                    --user=${name}-koha.${name}-koha"

        ZEBRA_PARAMS="-v $loglevels \
                      -k $max_record_size \
                      -f /etc/koha/sites/${name}/koha-conf.xml"
        ZEBRA_TIMEFORMAT='%FT%T'

        [ "$verbose" != "no" ] && \
            log_daemon_msg "Starting Koha Zebra daemon for ${name}"

        if daemon $DAEMONOPTS -- $ZEBRA_DAEMON $ZEBRA_PARAMS -m "$ZEBRA_TIMEFORMAT"; then
            ([ "$verbose" != "no" ] && log_end_msg 0) || return 0
        else
            ([ "$verbose" != "no" ] && log_end_msg 1) || return 1
        fi
    else
        if [ "$verbose" != "no" ]; then
            log_daemon_msg "Error: Zebra already running for ${name}"
            log_end_msg 1
        else
            return 1
        fi
    fi
}

_sysv_stop_zebra()
{
    local name=$1

    if is_zebra_running $name; then
        DAEMONOPTS="--name=${name}-koha-zebra \
                    --pidfiles=/var/run/koha/${name}/ \
                    --errlog=/var/log/koha/${name}/zebra-error.log \
                    --output=/var/log/koha/${name}/zebra-output.log \
                    --verbose=1 --respawn --delay=30 \
                    --user=${name}-koha.${name}-koha"

        [ "$verbose" != "no" ] && \
            log_daemon_msg "Stopping Koha Zebra daemon for ${name}"

        if daemon $DAEMONOPTS --stop -- $ZEBRA_DAEMON $ZEBRA_PARAMS; then
            ([ "$verbose" != "no" ] && log_end_msg 0) || return 0
        else
            ([ "$verbose" != "no" ] && log_end_msg 1) || return 1
        fi
    else
        if [ "$verbose" != "no" ]; then
            log_daemon_msg "Error: Zebra not running for ${name}"
            log_end_msg 1
        else
            return 1
        fi
    fi
}

_sysv_restart_zebra()
{
    local name=$1

    if is_zebra_running ${name}; then
        local noLF="-n"
        [ "$verbose" != "no" ] && noLF=""
        echo $noLF `_sysv_stop_zebra ${name}`
        echo $noLF `_sysv_start_zebra ${name}`
    else
        if [ "$verbose" != "no" ]; then
            log_warning_msg "Zebra not running for ${name}."
        fi
        _sysv_start_zebra ${name}
    fi
}

_sysv_zebra_status()
{
    local name=$1

    if is_zebra_running ${name}; then
        log_daemon_msg "Zebra running for ${name}"
        log_end_msg 0
    else
        log_daemon_msg "Zebra not running for ${name}"
        log_end_msg 3
    fi
}

_check_and_fix_zebra_perms()
{
    local name=$1
    local files="/var/log/koha/${name}/zebra-output.log \
                 /var/log/koha/${name}/zebra-error.log"
    for file in ${files}; do
        if [ ! -e "${file}" ]; then
            touch ${file}
        fi
        chown "${name}-koha":"${name}-koha" ${file}
    done
}

_sysv_start_worker()
{
    local name=$1
    local queues=$2
    local error_count=0

    for queue in $queues; do
        if ! is_worker_running "$name" "$queue"; then
            worker_name=$(get_worker_name "$name" "$queue")
            export KOHA_CONF="/etc/koha/sites/${name}/koha-conf.xml"

            DAEMONOPTS="--name=${worker_name} \
                --errlog=/var/log/koha/${name}/worker-error.log \
                --output=/var/log/koha/${name}/worker-output.log \
                --pidfiles=/var/run/koha/${name}/ \
                --verbose=1 --respawn --delay=30 \
                --user=${name}-koha.${name}-koha"

            echo "Starting Koha worker daemon for ${name} (${queue})"
            if ! daemon $DAEMONOPTS -- "$worker_DAEMON" --queue "$queue"; then
                ((error_count++))
            fi
        else
            echo "Error: worker already running for ${name} (${queue})"
            ((error_count++))
        fi
    done
    log_end_msg $error_count
}

_sysv_stop_worker()
{
    local name=$1
    local queues=$2
    local error_count=0

    for queue in $queues; do
        if is_worker_running "$name" "$queue"; then
            export KOHA_CONF="/etc/koha/sites/${name}/koha-conf.xml"
            worker_name=$(get_worker_name "$name" "$queue")

            DAEMONOPTS="--name=${worker_name} \
                --errlog=/var/log/koha/${name}/worker-error.log \
                --output=/var/log/koha/${name}/worker-output.log \
                --pidfiles=/var/run/koha/${name}/ \
                --verbose=1 --respawn --delay=30 \
                --user=${name}-koha.${name}-koha"

            echo "Stopping Koha worker daemon for ${name} (${queue})"
            if ! daemon $DAEMONOPTS --stop -- "$worker_DAEMON" --queue "$queue"; then
                ((error_count++))
            fi
        else
            echo "Error: worker not running for ${name} (${queue})"
            ((error_count++))
        fi
    done
    log_end_msg $error_count
}

_sysv_restart_worker()
{
    local name=$1
    local queues=$2
    local error_count=0

    for queue in $queues; do
        if is_worker_running "$name" "$queue"; then
            export KOHA_CONF="/etc/koha/sites/${name}/koha-conf.xml"
            worker_name=$(get_worker_name "$name" "$queue")

            DAEMONOPTS="--name=${worker_name} \
                --errlog=/var/log/koha/${name}/worker-error.log \
                --output=/var/log/koha/${name}/worker-output.log \
                --pidfiles=/var/run/koha/${name}/ \
                --verbose=1 --respawn --delay=30 \
                --user=${name}-koha.${name}-koha"

            echo "Restarting Koha worker daemon for ${name} (${queue})"
            if ! daemon $DAEMONOPTS --restart -- "$worker_DAEMON" --queue "$queue"; then
                ((error_count++))
            fi
        else
            echo "Worker not running for ${name} (${queue})."
            _sysv_start_worker $name $queue
        fi
    done
    log_end_msg $error_count
}

_sysv_worker_status()
{
    local name=$1
    local queues=$2

    for queue in $queues; do
        if is_worker_running "$name" "$queue"; then
            log_daemon_msg "worker running for ${name} (${queue})"
            log_end_msg 0
        else
            log_daemon_msg "worker not running for ${name} (${queue})"
            log_end_msg 3
        fi
    done
}

_sysv_start_indexer()
{
    local name=$1

    if ! is_indexer_running $name; then
        export KOHA_CONF="/etc/koha/sites/$name/koha-conf.xml"

        DAEMONOPTS="--name=$name-koha-indexer \
            --errlog=/var/log/koha/$name/indexer-error.log \
            --output=/var/log/koha/$name/indexer-output.log \
            --pidfiles=/var/run/koha/$name/ \
            --verbose=1 --respawn --delay=30 \
            --user=$name-koha.$name-koha"

        log_daemon_msg "Starting Koha indexing daemon for $name"
        if daemon $DAEMONOPTS -- $INDEXER_DAEMON $INDEXER_PARAMS; then
            log_end_msg 0
        else
            log_end_msg 1
        fi
    else
        log_daemon_msg "Error: Indexer already running for $name"
        log_end_msg 1
    fi
}

_sysv_stop_indexer()
{
    local name=$1

    if is_indexer_running $name; then
        export KOHA_CONF="/etc/koha/sites/$name/koha-conf.xml"

        DAEMONOPTS="--name=$name-koha-indexer \
            --errlog=/var/log/koha/$name/indexer-error.log \
            --output=/var/log/koha/$name/indexer-output.log \
            --pidfiles=/var/run/koha/$name/ \
            --verbose=1 --respawn --delay=30 \
            --user=$name-koha.$name-koha"

        log_daemon_msg "Stopping Koha indexing daemon for $name"
        if daemon $DAEMONOPTS --stop -- $INDEXER_DAEMON $INDEXER_PARAMS; then
            log_end_msg 0
        else
            log_end_msg 1
        fi
    else
        log_daemon_msg "Error: Indexer not running for $name"
        log_end_msg 1
    fi
}

_sysv_restart_indexer()
{
    local name=$1

    if is_indexer_running $name; then
        export KOHA_CONF="/etc/koha/sites/$name/koha-conf.xml"

        DAEMONOPTS="--name=$name-koha-indexer \
            --errlog=/var/log/koha/$name/indexer-error.log \
            --output=/var/log/koha/$name/indexer-output.log \
            --pidfiles=/var/run/koha/$name/ \
            --verbose=1 --respawn --delay=30 \
            --user=$name-koha.$name-koha"

        log_daemon_msg "Restarting Koha indexing daemon for $name"
        if daemon $DAEMONOPTS --restart -- $INDEXER_DAEMON $INDEXER_PARAMS; then
            log_end_msg 0
        else
            log_end_msg 1
        fi
    else
        log_warning_msg "Indexer not running for $name."
        _sysv_start_indexer $name
    fi
}

_sysv_indexer_status()
{
    local name=$1

    if is_indexer_running ${name}; then
        log_daemon_msg "Indexer running for ${name}"
        log_end_msg 0
    else
        log_daemon_msg "Indexer not running for ${name}"
        log_end_msg 3
    fi
}

_sysv_start_es_indexer()
{
    local name=$1

    if ! is_es_indexer_running $name; then
        export KOHA_CONF="/etc/koha/sites/$name/koha-conf.xml"

        DAEMONOPTS="--name=$name-koha-es-indexer \
            --errlog=/var/log/koha/$name/es-indexer-error.log \
            --output=/var/log/koha/$name/es-indexer-output.log \
            --pidfiles=/var/run/koha/$name/ \
            --verbose=1 --respawn --delay=30 \
            --user=$name-koha.$name-koha"

        log_daemon_msg "Starting Koha ES indexing daemon for $name"
        if daemon $DAEMONOPTS -- $worker_DAEMON --batch_size ${batch_size}; then
            log_end_msg 0
        else
            log_end_msg 1
        fi
    else
        log_daemon_msg "Error: ES indexing daemon already running for $name"
        log_end_msg 1
    fi
}

_sysv_stop_es_indexer()
{
    local name=$1

    if is_es_indexer_running $name; then
        export KOHA_CONF="/etc/koha/sites/$name/koha-conf.xml"

        DAEMONOPTS="--name=$name-koha-es-indexer \
            --errlog=/var/log/koha/$name/es-indexer-error.log \
            --output=/var/log/koha/$name/es-indexer-output.log \
            --pidfiles=/var/run/koha/$name/ \
            --verbose=1 --respawn --delay=30 \
            --user=$name-koha.$name-koha"

        log_daemon_msg "Stopping Koha ES indexing daemon for $name"
        if daemon $DAEMONOPTS --stop -- $worker_DAEMON; then
            log_end_msg 0
        else
            log_end_msg 1
        fi
    else
        log_daemon_msg "Error: ES indexing daemon not running for $name"
        log_end_msg 1
    fi
}

_sysv_restart_es_indexer()
{
    local name=$1

    if is_es_indexer_running $name; then
        export KOHA_CONF="/etc/koha/sites/$name/koha-conf.xml"

        DAEMONOPTS="--name=$name-koha-es-indexer \
            --errlog=/var/log/koha/$name/es-indexer-error.log \
            --output=/var/log/koha/$name/es-indexer-output.log \
            --pidfiles=/var/run/koha/$name/ \
            --verbose=1 --respawn --delay=30 \
            --user=$name-koha.$name-koha"

        log_daemon_msg "Restarting Koha ES indexing daemon for $name"
        if daemon $DAEMONOPTS --restart -- $worker_DAEMON --batch_size ${batch_size}; then
            log_end_msg 0
        else
            log_end_msg 1
        fi
    else
        log_warning_msg "ES indexing daemon not running for $name."
        _sysv_start_es_indexer $name
    fi
}

_sysv_es_indexer_status()
{
    local name=$1

    if is_es_indexer_running $name; then
        log_daemon_msg "ES indexing daemon running for ${name}"
        log_end_msg 0
    else
        log_daemon_msg "ES indexing daemon not running for ${name}"
        log_end_msg 3
    fi
}

_sysv_start_sip()
{
    local name=$1

    _check_and_fix_sip_perms $name

    if ! is_sip_running $name; then
        if [ ! -f "/etc/koha/sites/${name}/SIPconfig.xml" ] || [ ! -f "/var/lib/koha/${name}/sip.enabled" ] ; then
            echo "SIP is disabled, or you do not have a SIPconfig.xml file."
        else
            adjust_paths_git_install $name
            export KOHA_HOME PERL5LIB

            if ! is_git_install $name; then
                LIBDIR=$KOHA_HOME/lib
            else
                LIBDIR=$KOHA_HOME
            fi

            DAEMONOPTS="--name=${name}-koha-sip \
                    --errlog=/var/log/koha/${name}/sip-error.log \
                    --output=/var/log/koha/${name}/sip-output.log \
                    --verbose=1 --respawn --delay=30 \
                    --pidfiles=/var/run/koha/${name} \
                    --user=${name}-koha.${name}-koha"

            SIP_PARAMS="$LIBDIR/C4/SIP/SIPServer.pm \
                    /etc/koha/sites/${name}/SIPconfig.xml"

            [ "$verbose" != "no" ] && \
                log_daemon_msg "Starting SIP server for ${name}"

            if daemon $DAEMONOPTS -- perl $SIP_PARAMS; then
                ([ "$verbose" != "no" ] && log_end_msg 0) || return 0
            else
                ([ "$verbose" != "no" ] && log_end_msg 1) || return 1
            fi
        fi
    else
        if [ "$verbose" != "no" ]; then
            log_daemon_msg "Warning: SIP server already running for ${name}"
            log_end_msg 0
        else
            return 0
        fi
    fi
}

_sysv_stop_sip()
{
    local name=$1
    local PIDFILE="/var/run/koha/${name}/${name}-koha-sip.pid"

    if is_sip_running $name; then
        [ "$verbose" != "no" ] && \
            log_daemon_msg "Stopping SIP server for ${name}"

        if start-stop-daemon --pidfile $PIDFILE --user ${name}-koha --stop --retry=TERM/30/KILL/5; then
            ([ "$verbose" != "no" ] && log_end_msg 0) || return 0
        else
            ([ "$verbose" != "no" ] && log_end_msg 1) || return 1
        fi
    else
        if [ "$verbose" != "no" ]; then
            log_daemon_msg "Warning: SIP server not running for ${name}"
            log_end_msg 0
        else
            return 0
        fi
    fi
}

_sysv_restart_sip()
{
    local name=$1

    if is_sip_running ${name}; then
        local noLF="-n"
        [ "$verbose" != "no" ] && noLF=""
        echo $noLF `_sysv_stop_sip ${name}`

        MAX_ITERATION=10
        while is_sip_running ${name}; do
            i=$((i+1))
            if [ $MAX_ITERATION -lt $i ]; then
                break
            fi
            sleep 1;
        done
        echo $noLF `_sysv_start_sip ${name}`
    else
        if [ "$verbose" != "no" ]; then
            log_warning_msg "Warning: SIP server not running for ${name}."
        fi
        _sysv_start_sip ${name}
    fi
}

_sysv_sip_status()
{
    local name=$1

    if is_sip_running ${name}; then
        log_daemon_msg "SIP server running for ${name}"
        log_end_msg 0
    else
        log_daemon_msg "SIP server not running for ${name}"
        log_end_msg 3
    fi
}

_check_and_fix_sip_perms()
{
    local name=$1
    local files="/var/log/koha/${name}/sip-error.log /var/log/koha/${name}/sip-output.log"
    for file in ${files}; do
        if [ ! -e "${file}" ]; then
            touch ${file}
        fi
        chown "${name}-koha":"${name}-koha" ${file}
    done
}

_sysv_start_z3950()
{
    local instancename=$1

    local PIDFILE="/var/run/koha/${instancename}/z3950-responder.pid"
    local NAME="${instancename}-koha-z3950-responder"
    local CONFIGDIR="/etc/koha/z3950"

    if [ -e "/etc/koha/sites/${instancename}/z3950/config.xml" ]; then
        CONFIGDIR="/etc/koha/sites/${instancename}/z3950"
    fi

    _check_and_fix_z3950_perms $instancename

    instance_user="${instancename}-koha"

    daemonize="-D -d ${instancename}-koha-z3950"
    logging="-l /var/log/koha/${instancename}/z3950.log"

    Z3950RESPONDER="/usr/bin/perl $KOHA_HOME/$KOHA_BINDIR/z3950_responder.pl"
    if [ "$debugger" = "yes" ] && is_debug_mode $instancename; then
        daemonize=""
        logging=""
        Z3950RESPONDER="/usr/bin/perl -d $KOHA_HOME/$KOHA_BINDIR/z3950_responder.pl"
    elif [ "$debugger" = "yes" ]; then
        warn "Not a test system, disabling debugger"
    fi

    Z3950OPTS="-c ${CONFIGDIR} \
               -u ${instance_user} \
               -p ${PIDFILE} ${daemonize} ${logging}"

    if ! is_z3950_running ${instancename}; then
        export KOHA_CONF="/etc/koha/sites/${instancename}/koha-conf.xml"

        if [[ ! $Z3950_ADDITIONAL_OPTS ]]; then
            Z3950_ADDITIONAL_OPTS="$( xmlstarlet sel -t -v 'yazgfs/config/z3950_responder_options' "$CONFIGDIR/config.xml" || true )"
        fi

        log_daemon_msg "Starting Z39.50/SRU daemon for ${instancename}"

        current_dir=$(pwd)
        eval cd ~$instance_user

        if ${Z3950RESPONDER} ${Z3950_ADDITIONAL_OPTS} ${Z3950OPTS}; then
            log_end_msg 0
        else
            log_end_msg 1
        fi
        cd "$current_dir"
    else
        log_daemon_msg "Error: Z39.50/SRU already running for ${instancename}"
        log_end_msg 1
    fi
}

_sysv_stop_z3950()
{
    local instancename=$1
    local PIDFILE="/var/run/koha/${instancename}/z3950-responder.pid"

    if is_z3950_running ${instancename}; then
        log_daemon_msg "Stopping Z39.50/SRU daemon for ${instancename}"
        if start-stop-daemon --pidfile ${PIDFILE} --stop --retry=TERM/30/KILL/5; then
            log_end_msg 0
        else
            log_end_msg 1
        fi
    else
        log_daemon_msg "Error: Z39.50/SRU not running for ${instancename}"
        log_end_msg 1
    fi
}

_sysv_restart_z3950()
{
    local instancename=$1

    if is_z3950_running ${instancename}; then
        log_daemon_msg "Restarting Z39.50/SRU daemon for ${instancename}"
        if _sysv_stop_z3950 $instancename && _sysv_start_z3950 $instancename; then
            log_end_msg 0
        else
            log_end_msg 1
        fi
    else
        log_warning_msg "Z39.50/SRU not running for ${instancename}."
        _sysv_start_z3950 $instancename
    fi
}

_check_and_fix_z3950_perms()
{
    local instance=$1
    local files="/var/log/koha/${instance}/z3950.log"
    for file in ${files}; do
        if [ ! -e "${file}" ]; then
            touch ${file}
        fi
        chown "${instance}-koha":"${instance}-koha" ${file}
    done
}
