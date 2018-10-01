#!/bin/bash

# See parse_MARC21_format_definition in C4/MarcFormatChecker.pm
DATADIR="cataloguing/MARC21formatXML"


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

if [ "z$KOHA_CONF" != "z" -a -e "$KOHA_CONF" ]; then
    INTRANETDIR=$(grep '<intranetdir>' "$KOHA_CONF" | cut -d'>' -f 2- | cut -d'<' -f 1)
fi

if [ "z$INTRANETDIR" != "z" -a -d "$INTRANETDIR" ]; then
    mkdir -p "$INTRANETDIR/$DATADIR"
    cd "$INTRANETDIR"
    getfiles "$BIBDIR" $BIBFILES
    echo "XML files saved to $INTRANETDIR/$DATADIR"
else
    echo "Could not figure out koha conf file."
    echo "MARC21 Format checking will not work without the XML files."
    echo "Sorry."
fi
