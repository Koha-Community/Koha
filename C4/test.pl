#!/usr/bin/perl
package C4::test;

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

use strict;
require Exporter;
use C4::Context;
use C4::Catalogue;
use C4::Biblio;
use MARC::Record;
use MARC::File::USMARC;

our $dbh = C4::Context->dbh;
$dbh->do("delete from marc_subfield_table");
$dbh->do("delete from marc_blob_subfield");
&MARCaddSubfield(1,'001',1,'##','a',1,'1 - This is a value');
&MARCaddSubfield(1,'001',1,'##','b',1,'2 - This is another value');
# FIXME - Just use "a"x1024 to generate very long strings.
&MARCaddSubfield(1,'001',1,'##','c',1,"3 - This is a value very very long. I try to make it longer than 255 char. I need to add something else. will it be long enough now... I'm not sure. That's why i continue to add a few word to this very important sentence. Now I hope it will be enough... Oh, not it need some more characters. So i add stupid strings : xxxxxxxxxxxxxxx dddddddddddddddddddd eeeeeeeeeeeeeeeeeeeeeee rrrrrrrrrrrrrrrrrrr ffffffffffffffffff");
&MARCaddSubfield(1,'001',1,'##','d',1,"4 - This is another value very very long. I try to make it longer than 255 char. I need to add something else. will it be long enough now... I'm not sure. That's why i continue to add a few word to this very important sentence. Now I hope it will be enough... Oh, not it need some more characters. So i add stupid strings : xxxxxxxxxxxxxxx dddddddddddddddddddd eeeeeeeeeeeeeeeeeeeeeee rrrrrrrrrrrrrrrrrrr ffffffffffffffffff");
print "change 1\n";
&MARCchangeSubfield(1,"1new - this is a changed value");
print "change 2\n";
&MARCchangeSubfield(2,"2new - go from short to long subfield... uuuuuuuuuuuuuuuuuuuuuuuu yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy tttttttttttttttttttttttttttttttt rrrrrrrrrrrrrrrrrrrrrr eeeeeeeeeeeeeeeeeeeeeeeee zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq ssssssssssssssssssssssssss ddddddddddddddddddddddddddddddd fffffffffffffffffffffffff ggggggggggggggggggggggggg hhhhhhhhhhhhhhhhhhhhhhhhhh jjjjjjjjjjjjjjjjjjjjjkkkkkkkkkkkkkkkkkkkkkkkk");
print "change 3\n";
&MARCchangeSubfield(3,"3new - go from long to short subfield...");
print "change 4\n";
&MARCchangeSubfield(4,"4new - stay with blob subfield...uuuuuuuuuuuuuuuuuuuuuuuu yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy tttttttttttttttttttttttttttttttt rrrrrrrrrrrrrrrrrrrrrr eeeeeeeeeeeeeeeeeeeeeeeee zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq ssssssssssssssssssssssssss ddddddddddddddddddddddddddddddd fffffffffffffffffffffffff ggggggggggggggggggggggggg hhhhhhhhhhhhhhhhhhhhhhhhhh jjjjjjjjjjjjjjjjjjjjjkkkkkkkkkkkkkkkkkkkkkkkk");
my $x= &MARCfindSubfield(1,'001','a','',1);
my $record= MARC::Record->new();
$record->leader("58973");
$record->add_fields('100',1,'',a => 'Logan, Robert K.', d => '1000-');
$record->add_fields('110',1,'',d => '1939-');

my $record2=MARCkoha2marc("123456","author","title","unititle","notes","abstract",
	"serial","seriestitle","copyrightdate","biblioitemnumber","volume","number",
	"classification","itemtype","isbn","issn",
	"dewey","subclass","publicationyear","publishercode",
	"volumedate","illus","pages","notes",
	"size","place","lccn");
&MARCaddMarcBiblio($record2);
# parse all subfields
#my @fields = $record->fields();
#foreach my $field (@fields) {
#    my @subf=$field->subfields;
#    for my $i (0..$#subf) {
#    print $field->tag(), " ", $field->indicator(1),$field->indicator(2), "subf: ", $subf[$i][0]," =",$subf[$i][1]," <-- \n";
#}
#}
#print $record->as_formatted();
#my $file = MARC::File::USMARC->in("/home/paul/courriers/koha/exemples_unimarc/env179.1.txt");
## get a marc record from the MARC::File object
## $record will be a MARC::Record object
#while (my $record = $file->next()) {
## print the title contained in the record
#    print $record->as_formatted(),"\n";
#}
## we're done so close the file
#    $file->close();
