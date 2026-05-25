#!/bin/bash

print_usage(){
    echo "$0 : generates PDF files from html files in directorys and prints them";
    echo "usage :";
    echo "$0 directory [css [printer_host [printername]]]"
    echo " - directory      directory to use to apply html2pdf transform";
    echo " - css            css file to apply to html ";
    echo " - printer_host   Network Name or IP of the printer (port possibly included) ";
    echo " - printer_name   printername ";
    echo "Note that css printerhost and printername are optional parameters ";
    echo "Note that this script uses weasyprint command ";

    exit 1;
}
if [ $# -lt 1 ]
then
    print_usage
fi
if [[ ! -d $1  ]]
then
    echo "$1 : directory expected";
    exit 1;
fi
if [[ -n $2 && -f $2 ]]
then
    cssopt="-s $2";
fi
if [[ -n $3 ]]
then
    optprinter="-h $3";
fi
if [[ -n $4 ]]
then
    optprinter="$optprinter -d $4";
fi

for i in $(ls $1/*.html 2>/dev/null)
do
    outputfile=$(echo $i | sed 's/\.html/.pdf/')
    weasyprint $cssopt $i $outputfile;
done

if [[ -n $optprinter ]]
then
    lp $optprinter  $1/*.pdf;
fi

tar cvfzP $1`date "+%Y%m%d"`.tar.gz  $1/*.pdf;
