#!/usr/bin/perl

#
# Modified saas@users.sf.net 12:00 01 April 2001
# The biblioitemnumber was not correctly initialised
# The max(barcode) value was broken - koha 'barcode' is a string value!
# - If left blank, barcode value now defaults to max(biblionumber) 

#
# TODO
#
# Error checking for pre-existing barcodes, biblionumbers and maybe others
#
# Add info on biblioitems and items already entered as you enter new ones

use C4::Database;
use CGI;
use strict;
use C4::Acquisitions;
use C4::Biblio;
use C4::Output;
use C4::Circulation::Circ2;

my $input = new CGI;
my $dbh=C4Connect;

my $isbn=$input->param('isbn');
my $q_isbn=$dbh->quote($isbn);
my $biblioitemnumber;

print $input->header;
print startpage();
print startmenu('acquisitions');

($input->param('checkforbiblio')) && (checkforbiblio());
($input->param('newbiblioitem')) && (newbiblioitem());
($input->param('newitem')) && (newitem());

sub checkforbiblio {
    my $title=$input->param('title');
    my $q_title=$dbh->quote($title);
    my $author=$input->param('author');
    my $q_author=$dbh->quote($author);
    my $seriestitle=$input->param('seriestitle');
    my $serial=0;
    ($seriestitle) && ($serial=1);
    my $q_seriestitle=$dbh->quote($seriestitle);
    my $copyrightdate=$input->param('copyrightdate');
    my $q_copyrightdate=$dbh->quote($copyrightdate);
    my $notes=$input->param('notes');
    my $q_notes=$dbh->quote($notes);
    my $subtitle=$input->param('subtitle');
    my $q_subtitle=$dbh->quote($subtitle);
    my $sth=$dbh->prepare("select biblionumber from biblio where title=$q_title
	and author=$q_author and copyrightdate=$q_copyrightdate");
    $sth->execute;
    my $biblionumber=0;
    if ($sth->rows) {
	($biblionumber) = $sth->fetchrow;
    } else {
	print "Adding new biblio for <i>$title</i> by $author<br>\n";
	my $sth=$dbh->prepare("select max(biblionumber) from biblio");
	$sth->execute;
	($biblionumber) = $sth->fetchrow;
	$biblionumber++;
	$sth=$dbh->prepare("insert into biblio (biblionumber, title, author,
	    serial, seriestitle, copyrightdate, notes) values ($biblionumber,
	    $q_title, $q_author, $serial, $q_seriestitle, $q_copyrightdate,
	    $q_notes)");
	$sth->execute;
	$sth=$dbh->prepare("insert into bibliosubtitle (subtitle, biblionumber)
	    values ($q_subtitle, $biblionumber)");
	$sth->execute;
    }
    my $itemtypeselect='';
    $sth=$dbh->prepare("select itemtype,description from itemtypes");
    $sth->execute;
    while (my ($itemtype, $description) = $sth->fetchrow) {
	$itemtypeselect.="<option value=$itemtype>$itemtype - $description\n";
    }
    my $authortext="by $author";
    ($author) || ($authortext='');
    sectioninfo();
    $sth=$dbh->prepare("select BI.isbn,IT.description,BI.volume,BI.number,BI.volumeddesc,BI.dewey,BI.subclass from biblioitems BI, itemtypes IT where BI.itemtype=IT.itemtype and biblionumber=$biblionumber");
    $sth->execute;
    my $biblioitemdata='';
    while (my ($isbn, $itemtype, $volume, $number, $volumeddesc, $dewey, $subclass) = $sth->fetchrow) {
	my $volumeinfo='';
	if ($volume) {
	    if ($number) {
		$volumeinfo="V$volume, N$number";
	    } else {
		$volumeinfo="Vol $volume";
	    }
	}
	if ($volumeddesc) {
	    $volumeinfo.=" $volumeddesc";
	}
	$dewey=~s/0*$//;
	$biblioitemdata.="<tr><td>$isbn</td><td align=center>$itemtype</td><td align=center>$volumeinfo</td><td align=center>$dewey$subclass</td></tr>\n";

    }
    if ($biblioitemdata) {
	print << "EOF";
<center>
<p>
<table border=1 bgcolor=#dddddd>
<tr>
<th colspan=4>Existing entries using Biblio number $biblionumber</th>
</tr>
<tr>
<th>ISBN</th><th>Item Type</th><th>Volume</th><th>Classification</th></tr>
$biblioitemdata
</table>
</center>

EOF
    }
    print << "EOF";
<center>
<form>
<table border=1 bgcolor=#dddddd>
<tr><th colspan=4>Section Two: Publication Information for<br><i>$title</i>
    $authortext</th></tr>

<tr><td align=right>Publisher</td><td colspan=3><input name=publishercode size=30></td></tr>
<tr><td align=right>Publication Year</td><td><input name=publicationyear size=10></td>
<td align=right>Place of Publication</td><td><input name=place size=20></td></tr>
<tr><td align=right>Illustrator</td><td colspan=3><input name=illus size=20></td></tr>
<tr><td align=right>Additional Authors<br>(One author per line)</td><td colspan=3><textarea
    name=additionalauthors rows=4 cols=30></textarea></td></tr>
<tr><td align=right>Subject Headings<br>(One subject per line)</td><td colspan=3><textarea
    name=subjectheadings rows=4 cols=30></textarea></td></tr>
<tr><td align=right>Item Type</td><td colspan=3><select name=itemtype>$itemtypeselect</select></td></tr>
<tr><td align=right>Dewey</td><td><input name=dewey size=10></td>
<td align=right>Dewey Subclass</td><td><input name=subclass size=10></td></tr>
<tr><td align=right>ISSN</td><td colspan=3><input name=issn size=10></td></tr>
<tr><td align=right>LCCN</td><td colspan=3><input name=lccn size=10></td></tr>
<tr><td align=right>Volume</td><td><input name=volume size=10></td>
<td align=right>Number</td><td><input name=number size=10></td></tr>
<tr><td align=right>Volume Description</td><td colspan=3><input name=volumeddesc size=40></td></tr>
<tr><td align=right>Pages</td><td><input name=pages size=10></td>
<td align=right>Size</td><td><input name=size size=10></td></tr>

<tr><td align=right>Notes</td><td colspan=3><textarea name=notes rows=4 cols=50
    wrap=physical></textarea></td></tr>

</table>
<input type=submit value="Add New Bibliography Item">
</center>
<input type=hidden name=biblionumber value=$biblionumber>
<input type=hidden name=isbn value=$isbn>
<input type=hidden name=newbiblioitem value=1>
</form>
EOF
    print endmenu();
    print endpage();
    exit;
}


sub newbiblioitem {
    #print 
#    print "in here";
    my $biblionumber=$input->param('biblionumber');
    my $volume=$input->param('volume');
    my $q_volume=$dbh->quote($volume);
    my $number=$input->param('number');
    my $q_number=$dbh->quote($number);
    my $classification=$input->param('classification');
    my $q_classification=$dbh->quote($classification);
    my $itemtype=$input->param('itemtype');
    my $q_itemtype=$dbh->quote($itemtype);
    my $issn=$input->param('issn');
    my $q_issn=$dbh->quote($issn);
    my $lccn=$input->param('lccn');
    my $q_lccn=$dbh->quote($lccn);
    my $dewey=$input->param('dewey');
    my $q_dewey=$dbh->quote($dewey);
    my $subclass=$input->param('subclass');
    my $q_subclass=$dbh->quote($subclass);
    my $publicationyear=$input->param('publicationyear');
    my $q_publicationyear=$dbh->quote($publicationyear);
    my $publishercode=$input->param('publishercode');
    my $q_publishercode=$dbh->quote($publishercode);
    my $volumedate=$input->param('volumedate');
    my $q_volumedate=$dbh->quote($volumedate);
    my $volumeddesc=$input->param('volumeddesc');
    my $q_volumeddesc=$dbh->quote($volumeddesc);
    my $illus=$input->param('illus');
    my $q_illus=$dbh->quote($illus);
    my $pages=$input->param('pages');
    my $q_pages=$dbh->quote($pages);
    my $notes=$input->param('notes');
    my $q_notes=$dbh->quote($notes);
    my $size=$input->param('size');
    my $q_size=$dbh->quote($size);
    my $place=$input->param('place');
    my $q_place=$dbh->quote($place);
    my $subjectheadings=$input->param('subjectheadings');
    my $additionalauthors=$input->param('additionalauthors');
    my $sth=$dbh->prepare("select max(biblioitemnumber) from biblioitems");
    $sth->execute;
    ($biblioitemnumber) = $sth->fetchrow;
    $biblioitemnumber++;
#    print STDERR "NEW BiblioItemNumber: $biblioitemnumber \n";
    ($q_isbn='') if ($q_isbn eq 'NULL');
    my $query="insert into biblioitems (biblioitemnumber,
    biblionumber, volume, number, classification, itemtype, isbn, issn, lccn, dewey, subclass,
    publicationyear, publishercode, volumedate, volumeddesc, illus, pages,
    notes, size, place) values ($biblioitemnumber, $biblionumber, $q_volume,
    $q_number, $q_classification, $q_itemtype, $q_isbn, $q_issn, $q_lccn, $q_dewey, $q_subclass,
    $q_publicationyear, $q_publishercode, $q_volumedate, $q_volumeddesc,
    $q_illus, $q_pages, $q_notes, $q_size, $q_place)";
    $sth=$dbh->prepare($query);
#    print $query;
    $sth->execute;
    my @subjectheadings=split(/\n/,$subjectheadings);
    my $subjectheading;
    foreach $subjectheading (@subjectheadings) {
	# remove any line ending characters (Ctrl-J or M)
	$subjectheading=~s/\013//g;
	$subjectheading=~s/\010//g;
	# convert to upper case
	$subjectheading=uc($subjectheading);
	print STDERR "S: $biblionumber, $subjectheading  ";
	chomp ($subjectheading);
	print STDERR "B: ".ord(substr($subjectheading, length($subjectheading)-1, 1))." ";
	while (ord(substr($subjectheading, length($subjectheading)-1, 1))<14) {
	    chop $subjectheading;
	}
	print STDERR "A: ".ord(substr($subjectheading, length($subjectheading)-1, 1))."\n";
	# quote value
	my $q_subjectheading=$dbh->quote($subjectheading);
	$sth=$dbh->prepare("insert into bibliosubject (biblionumber,subject)
	    values ($biblionumber, $q_subjectheading)");
	$sth->execute;
    }
    my @additionalauthors=split(/\n/,$additionalauthors);
    my $additionalauthor;
    foreach $additionalauthor (@additionalauthors) {
	# remove any line ending characters (Ctrl-L or Ctrl-M)
	$additionalauthor=~s/\013//g;
	$additionalauthor=~s/\010//g;
	# convert to upper case
	$additionalauthor=uc($additionalauthor);
	# quote value
	my $q_additionalauthor=$dbh->quote($additionalauthor);
	$sth=$dbh->prepare("insert into additionalauthors (biblionumber,author)
	    values ($biblionumber, $q_additionalauthor)");
	$sth->execute;
    }
}

sub newitem {
    my $biblionumber=$input->param('biblionumber');
    my $biblioitemnumber=$input->param('biblioitemnumber');
    my $barcode=$input->param('barcode');
    my $itemnotes=$input->param('notes');
    my $q_itemnotes=$dbh->quote($itemnotes);
    my $replacementprice=$input->param('replacementprice');
    ($replacementprice) || ($replacementprice=0);
    my $sth=$dbh->prepare("select max(itemnumber) from items");
    $sth->execute;
    my ($itemnumber) = $sth->fetchrow;
    $itemnumber++;
    my @datearr=localtime(time);
    my $date=(1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
    my $q_homebranch=$dbh->quote($input->param('homebranch'));
    my $query="insert into items (itemnumber, biblionumber,
    biblioitemnumber,barcode, itemnotes, holdingbranch, homebranch, dateaccessioned, replacementprice) values ($itemnumber,
    $biblionumber, $biblioitemnumber, $barcode, $q_itemnotes, $q_homebranch, $q_homebranch, '$date', $replacementprice)";
    $sth=$dbh->prepare($query);
    $sth->execute;
#    print $query;
}

if ($isbn) {
    my $sth;
    if ($isbn eq 'NULL') {
        # set biblioitemnumber if not already initialised...
	if ($biblioitemnumber eq '') {
	   $sth=$dbh->prepare("select max(biblioitemnumber) from biblioitems");
	   $sth->execute;
	   ($biblioitemnumber) = $sth->fetchrow;
	   $biblioitemnumber++;
#           print STDERR "BiblioItemNumber was missing: $biblioitemnumber \n";
	   }
	$sth=$dbh->prepare("select biblionumber,biblioitemnumber from
	biblioitems where biblioitemnumber=$biblioitemnumber");
    } else {
	$sth=$dbh->prepare("select biblionumber, biblioitemnumber from
	biblioitems where isbn=$q_isbn");
    }
    $sth->execute;
    if (my ($biblionumber, $biblioitemnumber) = $sth->fetchrow) {
	sectioninfo();
	$sth=$dbh->prepare("select I.barcode,I.itemnotes,B.title,B.author from items I, biblio B where B.biblionumber=I.biblionumber and biblioitemnumber=$biblioitemnumber");
	$sth->execute;
	my $itemdata='';
	while (my ($barcode, $itemnotes, $title, $author) = $sth->fetchrow) {
	    $itemdata.="<tr><td align=center>$barcode</td><td><u>$title</u></td><td>$author</td><td>$itemnotes</td></tr>\n";

	}

	if ($itemdata) {
	    print << "EOF";
    <center>
    <p>
    <table border=1 bgcolor=#dddddd>
    <tr>
    <th colspan=4>Existing Items with ISBN $isbn</th>
    </tr>
    <tr>
    <th>Barcode</th><th>Title</th><th>Author</th><th>Notes</th></tr>
    $itemdata
    </table>
    </center>

EOF
	}
#	my $sth=$dbh->prepare("select max(barcode) from items");
#	$sth->execute;
#	my ($maxbarcode) = $sth->fetchrow;
#	$maxbarcode++;
#       print STDERR "MaxBarcode: $maxbarcode \n";
	print << "EOF";
<center>
<h2>Section Three: Specific Item Information</h2>
<form>
<input type=hidden name=newitem value=1>
<input type=hidden name=biblionumber value=$biblionumber>
<input type=hidden name=biblioitemnumber value=$biblioitemnumber>
<table>
<!-- tr><td>BARCODE</td><td><input name=barcode size=10 value=\$maxbarcode --> 
<tr><td>BARCODE</td><td><input name=barcode size=10 value=$biblionumber> 
Home Branch: <select name=homebranch>
EOF
	  
my $branches=getbranches();
foreach my $key (sort(keys %$branches)) {
     print "<option value=\"$key\">$branches->{$key}->{'branchname'}</option>";
}  
print << "EOF";
	  </select></td></tr>
</tr><td colspan=2>Replacement Price: <input name=replacementprice size=10></td></tr>
<tr><td>Notes</td><td><textarea name=notes rows=4 cols=40
wrap=physical></textarea></td></tr>
</table>
<input type=submit value="Add Item">
</form>
<h3>ISBN $isbn Information</h3>

</center>
EOF
    } else {
	sectioninfo();
print << "EOF";
<center>
<form>
<input type=hidden name=isbn value='$isbn'>
<input type=hidden name=checkforbiblio value=1>
<table border=0>
<tr><th colspan=2>Section One: Copyright Information</th></tr>
<tr><td>Title</td><td><input name=title size=40></td></tr>
<tr><td>Subtitle</td><td><input name=subtitle size=40></td></tr>
<tr><td>Author</td><td><input name=author size=40></td></tr>
<tr><td>Series Title<br>(if applicable)</td><td><input name=seriestitle
    size=40></td></tr>
<tr><td>Copyright Date</td><td><input name=copyrightdate size=10></td></tr>
<tr><td>Notes</td><td><textarea name=notes rows=4 cols=40
    wrap=physical></textarea></td></tr>
</table>
<input type=submit value="Add new Bibliography">
</center>
EOF
    }
} else {
    print << "EOF";
<h2>Adding new items to the Library Inventory</h2>
To add a new item, scan or type the ISBN number:
<br>
<form>
ISBN: <input name=isbn>
</form>
<p>
<a href=addbooks.pl?isbn=NULL>Enter book with no ISBN</a>
<hr>
<p>
<h2>Tools for importing MARC records into Koha</h2>
<ul>
<li><a href=marcimport.pl?menu=z3950>Z39.50 Search Tool</a>
<li><a href=marcimport.pl?menu=uploadmarc>Upload MARC records</a>
</ul>

EOF
}
print endmenu();
print endpage();


sub sectioninfo {
    print << "EOF";
    <center>
    <table border=1 width=70% bgcolor=#bbddbb>
    <tr>
    <td>
    <center>
    Koha stores data in three sections.
    </center>
    <ol>
    <li>The first section records bibliographic data such as title, author and
    copyright for a particular work.
    <li>The second records bibliographic data for a particular publication of that
    work, such as ISBN number, physical description, publisher information, etc.
    <li>The third section holds specific item information, such as the bar code
    number.
    </ul>
    </td>
    </tr>
    </table>
    </center>
EOF

}
