#!/usr/bin/perl

#script to display detailed information
#written 8/11/99

use strict;
use C4::Search;
use CGI;
use C4::Output;

my $input = new CGI;
my $type  = $input->param('type');
my $bib   = $input->param('bib');
my $title = $input->param('title');
my @items = &ItemInfo(undef, $bib, $type);
my @temp  = split('\t', $items[0]);
my $dat   = &bibdata($bib);
my $count = @items;
my ($authorcount, $addauthor) = &addauthor($bib);
my $additional = $addauthor->[0]->{'author'};
my $main;
my $secondary;
my $colour;


if ($type eq '') {
    $type = 'opac';
} # if

# setup colours
if ($type eq 'opac') {
    $main      = '#99cccc';
    $secondary = '#efe5ef';
} else {
    $main      = '#cccc99';
    $secondary = '#ffffcc';
} # else
$colour = $secondary;

for (my $i = 1; $i < $authorcount; $i++) {
    $additional .= "|" . $addauthor->[$i]->{'author'};
} # for

print $input->header;
print startpage();
print startmenu($type);

if ($type ne 'opac'){
    print << "EOF";
<a href=request.pl?bib=$bib><img height=42  WIDTH=120 BORDER="0" src=\"/images/requests.gif\" align="right" border="0"></a>
EOF
} # if

if ($type eq 'catmain'){
  print mkheadr(3,"Catalogue Maintenance");
} # if

if ($dat->{'author'} ne ''){
  print mkheadr(3,"$dat->{'title'} ($dat->{'author'}) $temp[4]");
} else {
  print mkheadr(3,"$dat->{'title'} $temp[4]");
} # if

print << "EOF";
<table cellspacing="0" callpadding="5" border="1" align="left" width="220">
<!-----------------BIBLIO RECORD TABLE--------->
<tr valign="top">
EOF

if ($type ne 'opac') {
    print << "EOF";
<td bgcolor="$main" background="/images/background-mem.gif">
EOF
} else {
    print << "EOF";
<td bgcolor="$main">
EOF
} # else

print << "EOF";
<b>BIBLIO RECORD</b>
EOF

if ($type ne 'opac') {
  print "$bib";
}

print << "EOF";
</td>
</tr>
<tr valign="top">
<td>
EOF

if ($type ne 'opac') {
  print << "EOF";
<form action="/cgi-bin/koha/modbib.pl" method="post">
<input type="hidden" name="bibnum" value="$bib">
<input type="image" name="submit" value="modify" height="42" width="93" border="0" src="/images/modify-mem.gif"> 
<input type="image" name="delete" value="delete" height="42" width="93" border="0" src="/images/delete-mem.gif">
</form>
EOF
} # if

print << "EOF";
<br>
<FONT SIZE=2  face="arial, helvetica">
EOF


if ($type ne 'opac') {
    print << "EOF";
<b>Subtitle:</b> $dat->{'subtitle'}<br>
<b>Author:</b> $dat->{'author'}<br>
<b>Additional Author:</b> $additional<br>
<b>Series Title:</b> $dat->{'seriestitle'}<br>
<b>Subject:</b> $dat->{'subject'}<br>
<b>Copyright:</b> $dat->{'copyrightdate'}<br>
<b>Notes:</b> $dat->{'notes'}<br>
<b>Unititle:</b> $dat->{'unititle'}<br>
<b>Analytical Author:</b> <br>
<b>Analytical Title:</b> <br>
<b>Serial:</b> $dat->{'serial'}<br>
<b>Total Number of Items:</b> $count
<p>
EOF

} else {
    if ($dat->{'subtitle'} ne ''){
	print "<b>Subtitle:</b> $dat->{'subtitle'}<br>";
    } # if
    if ($dat->{'author'} ne ''){
	print "<b>Author:</b> $dat->{'author'}<br>";
    } # if

# Additional Author: <br>
    if ($dat->{'seriestitle'} ne '') {
	print "<b>Seriestitle:</b> $dat->{'seriestitle'}<br>";
    } # if
    if ($dat->{'subject'} ne '') {
	print "<b>Subject:</b> $dat->{'subject'}<br>";
    } # if
    if ($dat->{'copyrightdate'} ne '') {
	print "<b>Copyright:</b> $dat->{'copyrightdate'}<br>";
    } # if
    if ($dat->{'notes'} ne '') {
	print "<b>Notes:</b> $dat->{'notes'}<br>";
    } # if
    if ($dat->{'unititle'} ne '') {
	print "<b>Unititle:</b> $dat->{'unititle'}<br>";
    } # if

# Analytical Author: <br>
# Analytical Title: <br>
    if ($dat->{'serial'} ne '0') {
	print "<b>Serial:</b> Yes<br>";
    } # if

    print << "EOF";
<b>Total Number of Items:</b> $count
<p>
EOF

} # if

print << "EOF";
</font></td>
</tr>
</table>

<img src="/images/holder.gif" width="16" height="300" align="left">
EOF

print center();
print mktablehdr;

if ($type eq 'opac') {
    print mktablerow(6,$main,'Item Type','Class','Branch','Date Due','Last Seen');
    if ($dat->{'url'} ne '') {
	$dat->{'url'} =~ s/^http:\/\///;
	print mktablerow(6, $colour, 'Website', 'WEB', 'Online', 'Available', "<a href=\"http://$dat->{'url'}\">$dat->{'url'}</a>");
    } # if
} else {
    print mktablerow(7,$main,'Itemtype','Class','Location','Date Due','Last Seen','Barcode',"","/images/background-mem.gif");
    if ($dat->{'url'} ne '') {
	$dat->{'url'} =~ s/^http:\/\///;
	print mktablerow(7, $colour, 'WEB', '', 'Online', 'Available', "<a href=\"http://$dat->{'url'}\">$dat->{'url'}</a>");
    } # if
} # else

$colour = 'white';
for (my $i = 0; $i < $count; $i ++) {
    
    my @results = split('\t', $items[$i]);

    if ($type ne 'opac') {
	$results[1] = mklink("/cgi-bin/koha/moredetail.pl?item=$results[5]&bib=$bib&bi=$results[8]&type=$type",$results[1]);
    } # if

    if ($results[2] eq '') {
	$results[2] = 'Available';
    } # if

    if ($type eq 'catmain'){
	$results[10] = mklink("/cgi-bin/koha/maint/catmaintain.pl?type=fixitemtype&bi=$results[8]&item=$results[6]","Fix Itemtype");
    } # if

    if ($type ne 'opac'){
	if ($type eq 'catmain'){
	    print mktablerow(8,$colour,$results[6],$results[4],$results[3],$results[2],$results[7],$results[1],$results[9],$results[10]);
	} else {
	    print mktablerow(7,$colour,$results[6],$results[4],$results[3],$results[2],$results[7],$results[1],$results[9]);
	} # else
    } else {
	$results[6] = ItemType($results[6]);
	print mktablerow(6,$colour,$results[6],$results[4],$results[3],$results[2],$results[7],$results[9]);
    } # else
    
    if ($colour eq $secondary) {
	$colour = 'white';
    } else {
	$colour = $secondary;
    } # else

} # for

print mktableft();
print "<p>";
print mktablehdr();

if ($type ne 'opac') {
    print << "EOF";
<tr valign="top">
<td bgcolor="99cc33" background="/images/background-mem.gif" colspan="2"><p><b>HELP</b><br>
<b>Update Biblio for all Items:</b> Click on the <b>Modify</b> button [left] to amend the biblio.  Any changes you make will update the record for <b>all</b> the items listed above. <p>
<b>Updating the Biblio for only ONE or SOME Items:</b> 
EOF

    if ($type eq 'catmain') {
	print << "EOF";
If some of the items listed above need a different biblio, 
you need to click on the wrong item, then shift the group it belongs to, to the correct biblio.
You will need to know the correct biblio number
<p />
</tr>
EOF

    } else {
	print << "EOF";
If some of the items listed above need a different biblio, or are on the wrong biblio, you must use the <a href="acquisitions/">acquisitions</a> process to fix this. You will need to "re-order" the items, and delete them from this biblio.
<p />
</tr>
EOF

    } # else
} # if

print mktableft();
print endcenter();
print << "EOF";
<br clear=all>
<p />
EOF

if ($type ne 'opac') {
    print << "EOF";
<table border="1" cellspacing="0" cellpadding="5" width="90%">
<tr valign="top">
<td bgcolor="$main" background="/images/background-mem.gif"><b>Abstract</b></td>
</tr>
<tr valign="top">
<td>$dat->{'abstract'}</td>
</tr>
</table>
EOF
} else {
    if ($dat->{'abstract'} ne '') {
	print << "EOF";
<table border="1" cellspacing="0" cellpadding="5" width="90%">
<tr valign="top">
<td bgcolor="$main"><b>Abstract</b></td>
</tr>
<tr valign="top">
<td>$dat->{'abstract'}</td>
</tr>
</table>
EOF
    } # if
} # else

print endmenu($type);
print endpage();
