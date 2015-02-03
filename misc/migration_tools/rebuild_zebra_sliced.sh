#!/bin/sh

usage() {
    local scriptname=$(basename $0)
    cat <<EOF
$scriptname

Index Koha records by chunks. It is useful when a record causes errors and
stops the indexing process. With this script, if indexing of one chunk fails,
that chunk is split into two or more chunks, and indexing continues on these chunks.
rebuild_zebra.pl is called only once to export records. Splitting and indexing
is handled by this script (using zebraidx for indexing).

Usage:
$scriptname [-t type] [-l X] [-o X] [-s X] [-d /export/dir] [-L /log/dir] [-r] [-f] [--reset-index]
$scriptname -h

    -o | --offset         Offset parameter of rebuild_zebra.pl.
                          Default: $OFFSET
    -l | --length         Length parameter of rebuild_zebra.pl. If omitted, the
                          length is automatically calculated to index all
                          records
    -s | --chunks-size    Initial chunk size (number of records indexed at once)
                          Default: $CHUNKSSIZE
    -d | --export-dir     Where rebuild_zebra.pl will export data
                          Default: $EXPORTDIR
    -x | --exclude-export Do not export Biblios from Koha, but use the existing
                          export-dir
    -L | --log-dir        Log directory
                          Default: $LOGDIR
    -r | --remove-logs    Clean log directory before start
                          Default: $RMLOGS
    -t | --type           Record type ('biblios' or 'authorities')
                          Default: $TYPE
    -f | --force          Don't ask for confirmation before start
    -h | --help           Display this help message
    --reset-index         Reset Zebra index for 'type'
EOF
}

splitfile() {
    local file=$1
    local prefix=$2
    local size=$3
    local script='
        my $indexmode = '"$INDEXMODE"';
        my $prefix = '"\"$prefix\""';
        my $size = '"$size"';
        my ($i,$count) = (0,0);
        open(my $fh, "<", '"\"$file\""');
        open(my $out, ">", sprintf("$prefix%02d", $i));
        my $closed = 0;
        while (<$fh>) {
            my $line = $_;
            if ($closed) {
                open($out, ">", sprintf("$prefix%02d", $i));
                $closed = 0;
                if ($indexmode eq "dom" && $line !~ /<collection>/) {
                    print $out "<collection>";
                }
            }
            print $out $line;
            $count++ if ($line =~ m|^</record>|);
            if ($count == $size) {
                if ($indexmode eq "dom" && $line !~ m|</collection>|) {
                    print $out "</collection>";
                }
                $count = 0;
                $i++;
                close($out);
                $closed = 1;
            }
        }
    '
    $PERL -e "$script"
}

indexfile() {
    local file=$1
    local chunkssize=$2

    if [ $chunkssize -lt 1 ]; then
        echo "Fail on file $file"
    else

        local prefix="${file}_${chunkssize}_"
        echo "Splitting file in chunks of $chunkssize records"
        splitfile $file $prefix $chunkssize

        dir=$(dirname $prefix)
        local files="$(find $dir -regex $prefix[0-9]+ | sort | tr '\n' ' ')"
        for chunkfile in $files; do
            echo "Indexing $chunkfile"
            size=$(grep '^</record>' $chunkfile | wc -l)
            logfile="$LOGDIR/zebraidx.$(basename $chunkfile).log"
            ZEBRAIDX_CMD="$ZEBRAIDX -c $CONFIGFILE -d $TYPE -g marcxml update $chunkfile"
            $ZEBRAIDX_CMD >$logfile 2>&1
            grep "Records: $size" $logfile >/dev/null 2>&1
            if [ $? -ne 0 ]; then
                echo "Indexing failed. See log file $logfile"
                echo "Split file and continue..."
                indexfile $chunkfile $(($chunkssize/2))
            else
                ZEBRAIDX_CMD="$ZEBRAIDX -c $CONFIGFILE -d $TYPE -g marcxml commit"
                $ZEBRAIDX_CMD >> $logfile 2>&1
            fi
        done
    fi
}

OFFSET=0
LENGTH=
CHUNKSSIZE=10000
EXPORTDIR=/tmp/rebuild/export
EXCLUDEEXPORT=no
LOGDIR=/tmp/rebuild/logs
RMLOGS=no
NOCONFIRM=no
TYPE=biblios
HELP=no
RESETINDEX=no

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
        -x | --exclude-export )
            EXCLUDEEXPORT=yes
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
        -h | --help )
            HELP=yes
            ;;
        --reset-index )
            RESETINDEX=yes
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

if [ -z $KOHA_CONF ]; then
    echo "KOHA_CONF is not set"
    exit 1
fi

if [ -z $PERL5LIB ]; then
    echo "PERL5LIB is not set"
    exit 1
fi


TYPESWITCH=
SQLTABLE=
case $TYPE in
    biblios )
        TYPESWITCH=-b
        SQLTABLE="biblio"
        ;;
    authorities )
        TYPESWITCH=-a
        SQLTABLE="auth_header"
        ;;
    * )
        echo "'$TYPE' is an unknown type. Defaulting to 'biblios'"
        TYPESWITCH=-b
        TYPE=biblios
        SQLTABLE="biblio"
esac

PERL=`which perl`
if [ -z $PERL ]; then
    echo "perl not found"
    exit 1
fi

if [ -z $LENGTH ]; then
    LENGTH=$($PERL -e '
        use C4::Context;
        my ($count) = C4::Context->dbh->selectrow_array(qq{
            SELECT COUNT(*) FROM '"$SQLTABLE"'
        });
        print $count;
    ')
fi

ZEBRAIDX=`which zebraidx`
if [ -z $ZEBRAIDX ]; then
    echo "zebraidx not found"
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
echo "KOHA_CONF: $KOHA_CONF"
echo "PERL5LIB: $PERL5LIB"
echo "-------------------------------------------------------------------------"
echo "Start at offset: $OFFSET"
echo "Total number of records to index: $LENGTH"
echo "Initial chunk size: $CHUNKSSIZE"
echo "Export directory: $EXPORTDIR"
echo "Exclude re-exporting: $EXCLUDEEXPORT"
echo "Log directory: $LOGDIR"
echo "Remove logs before start? $RMLOGS"
echo "Type of record: $TYPE"
echo "Reset index before start? $RESETINDEX"
echo "-------------------------------------------------------------------------"
echo "zebraidx path: $ZEBRAIDX"
echo "rebuild_zebra path: $REBUILDZEBRA"
echo "perl path: $PERL"
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

if [ $EXCLUDEEXPORT = "no" ]; then
    REBUILDZEBRA_CMD="$REBUILDZEBRA $TYPESWITCH -v -x -k -d $EXPORTDIR --offset $OFFSET --length $LENGTH --skip-index"
    echo "\n$REBUILDZEBRA_CMD"
    $REBUILDZEBRA_CMD
fi

EXPORTFILE=
case $TYPE in
    biblios )
        EXPORTFILE="$EXPORTDIR/biblio/exported_records"
        indexmode_config_name="zebra_bib_index_mode"
        ;;
    authorities )
        EXPORTFILE="$EXPORTDIR/authority/exported_records"
        indexmode_config_name="zebra_auth_index_mode"
        ;;
    * )
        echo "Error: TYPE '$TYPE' is not supported"
        exit 1
esac

INDEXMODE=$(perl -e '
    use C4::Context;
    print C4::Context->config('"$indexmode_config_name"');
')

CONFIGFILE=$(perl -e '
    use C4::Context;
    my $zebra_server = ('"$TYPE"' eq "biblios") ? "biblioserver" : "authorityserver";
    print C4::Context->zebraconfig($zebra_server)->{config};
')

if [ $RESETINDEX = "yes" ]; then
    RESETINDEX_CMD="$ZEBRAIDX -c $CONFIGFILE init"
    echo "\n$RESETINDEX_CMD"
    $RESETINDEX_CMD
    echo ""
fi

indexfile $EXPORTFILE $CHUNKSSIZE
