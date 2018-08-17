#!/bin/bash

DATADIR="data"
OUTFILE="MARC21formatBibs.xml"

BIBDIR="bib"
BIBFILES="000 001-006 007 008 01X-04X 05X-08X 1XX 20X-24X 250-270 3XX 4XX 50X-53X 53X-58X 6XX 70X-75X 76X-78X 80X-830 841-88X 9XX"

function getfiles() {
 SDIR=$1
 shift
 FILES=$@
 for x in $FILES; do
    FNAME="$DATADIR/$SDIR-${x}.xml"
    if [ ! -e "$FNAME" ]; then
	wget "http://marc21.kansalliskirjasto.fi/$SDIR/${x}.xml" -O "$FNAME"
    fi
 done
}

if [[ ! -x "$(which xsltproc)" ]]; then
    echo "ERROR: Install xsltproc"
    exit 1
fi


mkdir -p "$DATADIR"

getfiles $BIBDIR $BIBFILES


xsltproc bib.xslt "$DATADIR/$BIBDIR-000.xml" > "$OUTFILE"


if [ "z$KOHA_CONF" != "z" -a -e "$KOHA_CONF" ]; then
    INTRANETDIR=$(grep '<intranetdir>' "$KOHA_CONF" | cut -d'>' -f 2- | cut -d'<' -f 1)
fi

if [ "z$INTRANETDIR" != "z" -a -d "$INTRANETDIR" ]; then
    cp "$OUTFILE" "$INTRANETDIR/cataloguing/"
    echo "$OUTFILE copied to $INTRANETDIR/cataloguing/"
else
    echo "Could not figure out koha conf file."
    echo "Copy $OUTFILE to the intranet cgi-bin cataloguing-dir."
fi
