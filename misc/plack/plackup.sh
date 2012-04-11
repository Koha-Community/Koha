#!/bin/sh -e

# This is plack startup script for Koha

# ./plackup.sh [site] [intranet]

site=$1
test ! -z "$site" && shift || ( echo "usage: $0 [site] [i[tranet]]" ; exit 1 )

# extract useful paths from koha-conf.xml
export KOHA_CONF=/etc/koha/sites/$site/koha-conf.xml
export LOGDIR="$( sudo -u $site-koha xmlstarlet sel -t -v 'yazgfs/config/logdir' $KOHA_CONF )"
export INTRANETDIR="$( sudo -u $site-koha xmlstarlet sel -t -v 'yazgfs/config/intranetdir' $KOHA_CONF )"
export OPACDIR="$( sudo -u $site-koha xmlstarlet sel -t -v 'yazgfs/config/opacdir' $KOHA_CONF | sed 's,/cgi-bin/opac,,' )"

dir=`dirname $0`

# enable memcache - it's safe even on installation which don't have it
# since Koha has check on C4::Context
#export MEMCACHED_SERVERS=localhost:11211
# pass site name as namespace to perl code
export MEMCACHED_NAMESPACE=$site
#export MEMCACHED_DEBUG=1

if [ ! -e "$INTRANETDIR/C4" ] ; then
	echo "intranetdir in $KOHA_CONF doesn't point to Koha git checkout"
	exit 1
fi

if [ -z "$1" ] ; then # type anything after site name for intranet!
	INTRANET=0
	PORT=5000
else
	INTRANET=1
	PORT=5001
	shift # pass rest of arguments to plackup
fi
export INTRANET # pass to plack

# uncomment to enable logging
#opt="$opt --access-log $LOGDIR/opac-access.log --error-log $LOGDIR/opac-error.log"

# --max-requests 50 decreased from 1000 to keep memory usage sane
# --workers 4       number of cores on machine
#test "$INTRANET" != 1 && \ # don't use Starman for intranet
opt="$opt --server Starman -M FindBin --max-requests 50 --workers 4"

# -E deployment     turn off access log on STDOUT
opt="$opt -E deployment"

# comment out reload in production!
opt="$opt --reload -R $INTRANETDIR/C4 -R $INTRANETDIR/Koha"

sudo -E -u $site-koha plackup --port $PORT -I $INTRANETDIR -I $INTRANETDIR/installer $opt $* $dir/koha.psgi
