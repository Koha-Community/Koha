#!/usr/bin/perl



####################
# Variable Section #
####################

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

my $pretext='T ';
my $startnumber=1000;
my $pages=2;
my $libraryname='Copper Mountain Elementary';

# Shifts are given in millimeters. Positive numbers move up and to the right.
# These variables shift the whole page to account for printer differences.
my $shiftx=0;
my $shifty=0;

####################



my $leftmargin=5;
my $rightmargin=3;
my $topmargin=18;
my $botmargin=10;


my $rightside=215;
my $topside=280;


my $barcodewidth=length("$pretext$startnumber")+2;

my $bcwidthfactor=8-$barcodewidth/2;
print STDERR "$barcodewidth $bcwidthfactor\n";

my $width=$rightside-($leftmargin+$rightmargin);
my $height=$topside-$topmargin-$botmargin;

print << "EOF";
%!PS-Adobe-2.0
%%Title: barcode.ps
%%Creator: Willem van Schaik
%%CreationDate: aug 1992
%%Pages: 1
%%DocumentFonts: Helvetica Code39
%%BoundingBox: 0 0 595 842
%%EndComments

/newfont 10 dict def
newfont begin
/FontType 3 def
/FontMatrix [0.01 0 0 0.01 0 0] def
/FontBBox [0 0 100 100] def

/Encoding 256 array def
0 1 255 {Encoding exch /.notdef put} for
Encoding 32 /barSpace put
Encoding 36 /barDollar put
Encoding 37 /barPercent put
Encoding 42 /barAsterisk put
Encoding 43 /barPlus put
Encoding 45 /barHyphen put
Encoding 46 /barPeriod put
Encoding 47 /barSlash put
Encoding 48 /bar0 put
Encoding 49 /bar1 put
Encoding 50 /bar2 put
Encoding 51 /bar3 put
Encoding 52 /bar4 put
Encoding 53 /bar5 put
Encoding 54 /bar6 put
Encoding 55 /bar7 put
Encoding 56 /bar8 put
Encoding 57 /bar9 put
Encoding 65 /barA put
Encoding 66 /barB put
Encoding 67 /barC put
Encoding 68 /barD put
Encoding 69 /barE put
Encoding 70 /barF put
Encoding 71 /barG put
Encoding 72 /barH put
Encoding 73 /barI put
Encoding 74 /barJ put
Encoding 75 /barK put
Encoding 76 /barL put
Encoding 77 /barM put
Encoding 78 /barN put
Encoding 79 /barO put
Encoding 80 /barP put
Encoding 81 /barQ put
Encoding 82 /barR put
Encoding 83 /barS put
Encoding 84 /barT put
Encoding 85 /barU put
Encoding 86 /barV put
Encoding 87 /barW put
Encoding 88 /barX put
Encoding 89 /barY put
Encoding 90 /barZ put

/CharProcs 45 dict def
CharProcs begin
/.notdef {} def
/barSpace {0 7 17 17 7 7 7 17 7 7 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/barDollar {0 7 17 7 17 7 17 7 7 7 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/barPercent {0 7 7 7 17 7 17 7 17 7 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/barAsterisk {0 7 17 7 7 17 7 17 7 7 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/barPlus {0 7 17 7 7 7 17 7 17 7 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/barHyphen {0 7 17 7 7 7 7 17 7 17 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/barPeriod {0 17 17 7 7 7 7 17 7 7 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/barSlash {0 7 17 7 17 7 7 7 17 7 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/bar0 {0 7 7 7 17 17 7 17 7 7 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/bar1 {0 17 7 7 17 7 7 7 7 17 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/bar2 {0 7 7 17 17 7 7 7 7 17 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/bar3 {0 17 7 17 17 7 7 7 7 7 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/bar4 {0 7 7 7 17 17 7 7 7 17 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/bar5 {0 17 7 7 17 17 7 7 7 7 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/bar6 {0 7 7 17 17 17 7 7 7 7 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/bar7 {0 7 7 7 17 7 7 17 7 17 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/bar8 {0 17 7 7 17 7 7 17 7 7 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/bar9 {0 7 7 17 17 7 7 17 7 7 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/barA {0 17 7 7 7 7 17 7 7 17 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/barB {0 7 7 17 7 7 17 7 7 17 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/barC {0 17 7 17 7 7 17 7 7 7 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/barD {0 7 7 7 7 17 17 7 7 17 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/barE {0 17 7 7 7 17 17 7 7 7 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/barF {0 7 7 17 7 17 17 7 7 7 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/barG {0 7 7 7 7 7 17 17 7 17 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/barH {0 17 7 7 7 7 17 17 7 7 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/barI {0 7 7 17 7 7 17 17 7 7 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/barJ {0 7 7 7 7 17 17 17 7 7 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/barK {0 17 7 7 7 7 7 7 17 17 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/barL {0 7 7 17 7 7 7 7 17 17 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/barM {0 17 7 17 7 7 7 7 17 7 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/barN {0 7 7 7 7 17 7 7 17 17 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/barO {0 17 7 7 7 17 7 7 17 7 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/barP {0 7 7 17 7 17 7 7 17 7 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/barQ {0 7 7 7 7 7 7 17 17 17 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/barR {0 17 7 7 7 7 7 17 17 7 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/barS {0 7 7 17 7 7 7 17 17 7 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/barT {0 7 7 7 7 17 7 17 17 7 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/barU {0 17 17 7 7 7 7 7 7 17 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/barV {0 7 17 17 7 7 7 7 7 17 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/barW {0 17 17 17 7 7 7 7 7 7 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/barX {0 7 17 7 7 17 7 7 7 17 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/barY {0 17 17 7 7 17 7 7 7 7 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
/barZ {0 7 17 17 7 17 7 7 7 7 newpath 93 0 moveto 5 {dup 0 100 rlineto
neg 0 rlineto 0 -100 rlineto closepath add neg 0 rmoveto} repeat fill} def
end

/BuildChar
{ 100 0 0 0 93 100 setcachedevice
  exch
  begin
    Encoding exch get
    CharProcs exch get
    end
  exec
} def
end

/Code39 newfont definefont pop

%%EndProlog

EOF

my $number=$startnumber;
while ($page<$pages) {
    my $data='';
    for ($i=$leftmargin; $i<$rightside-$rightmargin; $i+=$width/4) {
	for ($j=$botmargin; $j<$topside-$topmargin-$botmargin; $j+=$height/20) {
	    my $x=$i+$width/8;
	    my $y=$j+$height/40;
	    my $schooly=$y+5.8;
	    my $labely=$y-2.2;
	    my $lox=$x-2;
	    my $hix=$x+2;
	    my $loy=$y-2;
	    my $hiy=$y+2;
	    $data.=<<"EOF";
$x $y moveto
/Code39 findfont [$bcwidthfactor 0 0 5 0 0] makefont setfont
(*$pretext$number*) dup stringwidth pop 2 div neg 0 rmoveto show
/Helvetica findfont 1.7 scalefont setfont
$x $schooly moveto
($schoolname) dup stringwidth pop 2 div neg 0 rmoveto show
/Helvetica findfont 2.3 scalefont setfont
$x $labely moveto
($pretext$number) dup stringwidth pop 2 div neg 0 rmoveto show


EOF
	    $number++;
	}
    }


    $page++;
    print << "EOF";
%%Page: $page $page
%%PagerFonts:

$shiftx $shifty translate
72 25.4 div dup scale

/Code39 findfont [4 0 0 5 0 0] makefont setfont
/Times-Roman findfont
1 scalefont
setfont
$data





showpage


EOF
}
print "%%Trailer\n";
