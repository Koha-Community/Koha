#!/bin/sh

usage() {
    local scriptname=$(basename $0)
    cat <<EOF
$scriptname

Index Koha records by chunks. It is useful when a record causes errors and
stops the indexing process. With this script, if indexing of one chunk fails,
that chunk is split into two or more chunks, and indexing continues on these chunks.
rebuild_zebra.pl is called only once to export records. Splitting and indexing
is handled by this script (using yaz-marcdump and zebraidx).

Usage:
$scriptname -t type -l X [-o X] [-s X] [-d /export/dir] [-L /log/dir] [-r] [-f]
$scriptname -h

    -o | --offset         Offset parameter of rebuild_zebra.pl
    -l | --length         Length parameter of rebuild_zebra.pl
    -s | --chunks-size    Initial chunk size (number of records indexed at once)
    -d | --export-dir     Where rebuild_zebra.pl will export data
    -L | --log-dir        Log directory
    -r | --remove-logs    Clean log directory before start
    -t | --type           Record type ('biblios' or 'authorities')
    -f | --force          Don't ask for confirmation before start
    -h | --help           Display this help message
EOF
}

indexfile() {
    local file=$1
    local chunkssize=$2

    if [ $chunkssize -lt 1 ]; then
        echo "Fail on file $file"
    else

        local prefix="${file}_${chunkssize}_"
        echo "Splitting file in chunks of $chunkssize records"
        YAZMARCDUMP_CMD="$YAZMARCDUMP -n -s $prefix -C $chunkssize $file"
        $YAZMARCDUMP_CMD

        dir=$(dirname $prefix)
        local files="$(find $dir -regex $prefix[0-9]+ | sort | tr '\n' ' ')"
        for chunkfile in $files; do
            echo "Indexing $chunkfile"
            size=$($YAZMARCDUMP -p $chunkfile | grep '<!-- Record [0-9]\+ offset .* -->' | wc -l)
            logfile="$LOGDIR/zebraidx.$(basename $chunkfile).log"
            ZEBRAIDX_CMD="$ZEBRAIDX -c $CONFIGFILE -d $TYPE -g iso2709 update $chunkfile"
            $ZEBRAIDX_CMD >$logfile 2>&1
            grep "Records: $size" $logfile >/dev/null 2>&1
            if [ $? -ne 0 ]; then
                echo "Indexing failed. Split file and continue..."
                indexfile $chunkfile $(($chunkssize/2))
            else
                ZEBRAIDX_CMD="$ZEBRAIDX -c $CONFIGFILE -d $TYPE -g iso2709 commit"
                $ZEBRAIDX_CMD >> $logfile 2>&1
            fi
        done
    fi
}

OFFSET=0
LENGTH=
CHUNKSSIZE=10000
EXPORTDIR=/tmp/rebuild/export
LOGDIR=/tmp/rebuild/logs
RMLOGS=no
NOCONFIRM=no
TYPE=biblios
HELP=no

# Get parameters
while [ $1 ]; do
    case $1 in
        -o | --offset )
            shift
            OFFSET=$1
            ;;
        -l | --length )
            shift
            LENGTH=$1
            ;;
        -s | --chunks-size )
            shift
            CHUNKSSIZE=$1
            ;;
        -d | --export-dir )
            shift
            EXPORTDIR=$1
            ;;
        -L | --log-dir )
            shift
            LOGDIR=$1
            ;;
        -r | --remove-logs )
            RMLOGS=yes
            ;;
        -t | --type )
            shift
            TYPE=$1
            ;;
        -f | --force )
            NOCONFIRM=yes
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

if [ $HELP = "yes" ]; then
    usage
    exit 0
fi

if [ -z $LENGTH ]; then
    echo "--length parameter is mandatory"
    exit 1
fi

TYPESWITCH=
case $TYPE in
    biblios )
        TYPESWITCH=-b
        ;;
    authorities )
        TYPESWITCH=-a
        ;;
    * )
        echo "'$TYPE' is an unknown type. Defaulting to 'biblios'"
        TYPESWITCH=-b
        TYPE=biblios
esac

ZEBRAIDX=`which zebraidx`
if [ -z $ZEBRAIDX ]; then
    echo "zebraidx not found"
    exit 1
fi

YAZMARCDUMP=`which yaz-marcdump`
if [ -z $YAZMARCDUMP ]; then
    echo "yaz-marcdump not found"
    exit 1
fi

REBUILDZEBRA="`dirname $0`/rebuild_zebra.pl"
if [ ! -f $REBUILDZEBRA ]; then
    echo "$REBUILDZEBRA: file not found"
    exit 1
fi

echo ""
echo "Configuration"
echo "========================================================================="
echo "Start at offset: $OFFSET"
echo "Total number of records to index: $LENGTH"
echo "Initial chunk size: $CHUNKSSIZE"
echo "Export directory: $EXPORTDIR"
echo "Log directory: $LOGDIR"
echo "Remove logs before start? $RMLOGS"
echo "Type of record: $TYPE"
echo "-------------------------------------------------------------------------"
echo "zebraidx path: $ZEBRAIDX"
echo "yaz-marcdump path: $YAZMARCDUMP"
echo "rebuild_zebra path: $REBUILDZEBRA"
echo "========================================================================="

if [ $NOCONFIRM != "yes" ]; then
    confirm=y
    echo -n "Confirm ? [Y/n] "
    read response
    if [ $response ] && [ $response != "yes" ] && [ $response != "y" ]; then
        confirm=n
    fi

    if [ $confirm = "n" ]; then
        exit 0
    fi
fi

mkdir -p $EXPORTDIR
if [ $? -ne 0 ]; then
    echo "Failed to create directory $EXPORTDIR. Aborting."
    exit 1
fi

mkdir -p $LOGDIR
if [ $? -ne 0 ]; then
    echo "Failed to create directory $LOGDIR. Aborting."
    exit 1
fi

if [ $RMLOGS = "yes" ]; then
    rm -f $LOGDIR/*.log
fi

REBUILDZEBRA_CMD="$REBUILDZEBRA $TYPESWITCH -v -k -d $EXPORTDIR --offset $OFFSET --length $LENGTH --skip-index"
echo "\n$REBUILDZEBRA_CMD"
$REBUILDZEBRA_CMD

EXPORTFILE=
case $TYPE in
    biblios )
        EXPORTFILE="$EXPORTDIR/biblio/exported_records"
        ;;
    authorities )
        EXPORTFILE="$EXPORTDIR/authority/exported_records"
        ;;
    * )
        echo "Error: TYPE '$TYPE' is not supported"
        exit 1
esac

CONFIGFILE="$(dirname $KOHA_CONF)/zebradb/zebra-$TYPE.cfg"


indexfile $EXPORTFILE $CHUNKSSIZE
