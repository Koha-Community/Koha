#!/usr/bin/perl
use strict;
require Exporter;
use C4::Database;
use C4::Catalogue;

my $dbh=&C4Connect;
$dbh->do("delete from marc_subfield_table");
$dbh->do("delete from marc_blob_subfield");
&addSubfield(1,'001','a',1,'1 - This is a value');
&addSubfield(1,'001','b',1,'2 - This is another value');
&addSubfield(1,'001','c',1,"3 - This is a value very very long. I try to make it longer than 255 char. I need to add something else. will it be long enough now... I'm not sure. That's why i continue to add a few word to this very important sentence. Now I hope it will be enough... Oh, not it need some more characters. So i add stupid strings : xxxxxxxxxxxxxxx dddddddddddddddddddd eeeeeeeeeeeeeeeeeeeeeee rrrrrrrrrrrrrrrrrrr ffffffffffffffffff");
&addSubfield(1,'001','d',1,"4 - This is another value very very long. I try to make it longer than 255 char. I need to add something else. will it be long enough now... I'm not sure. That's why i continue to add a few word to this very important sentence. Now I hope it will be enough... Oh, not it need some more characters. So i add stupid strings : xxxxxxxxxxxxxxx dddddddddddddddddddd eeeeeeeeeeeeeeeeeeeeeee rrrrrrrrrrrrrrrrrrr ffffffffffffffffff");
print "change 1\n";
&changeSubfield(1,"1new - this is a changed value");
print "change 2\n";
&changeSubfield(2,"2new - go from short to long subfield... uuuuuuuuuuuuuuuuuuuuuuuu yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy tttttttttttttttttttttttttttttttt rrrrrrrrrrrrrrrrrrrrrr eeeeeeeeeeeeeeeeeeeeeeeee zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq ssssssssssssssssssssssssss ddddddddddddddddddddddddddddddd fffffffffffffffffffffffff ggggggggggggggggggggggggg hhhhhhhhhhhhhhhhhhhhhhhhhh jjjjjjjjjjjjjjjjjjjjjkkkkkkkkkkkkkkkkkkkkkkkk");
print "change 3\n";
&changeSubfield(3,"3new - go from long to short subfield...");
print "change 4\n";
&changeSubfield(4,"4new - stay with blob subfield...uuuuuuuuuuuuuuuuuuuuuuuu yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy tttttttttttttttttttttttttttttttt rrrrrrrrrrrrrrrrrrrrrr eeeeeeeeeeeeeeeeeeeeeeeee zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq ssssssssssssssssssssssssss ddddddddddddddddddddddddddddddd fffffffffffffffffffffffff ggggggggggggggggggggggggg hhhhhhhhhhhhhhhhhhhhhhhhhh jjjjjjjjjjjjjjjjjjjjjkkkkkkkkkkkkkkkkkkkkkkkk");
my $x= &findSubfield(1,'001','a','',1);
print "subfieldid : $x\n";
my $record={};
#$marcstru->{bibid}=58973; # calculated auto_increment in addMarcBiblio
$record->{bibid}=58973;
$record->{tags}->{110}->{1}->{indicator}='##';
$record->{tags}->{110}->{1}->{subfields}->{a}->{1}='first text';
$record->{tags}->{110}->{1}->{subfields}->{a}->{2}='second text';
$record->{tags}->{110}->{1}->{subfields}->{b}->{3}='third text';

$record->{tags}->{120}->{1}->{indicator}='##';
$record->{tags}->{120}->{1}->{subfields}->{a}->{1}='last text ??';

$record->{tags}->{120}->{2}->{indicator}='01';
$record->{tags}->{120}->{2}->{subfields}->{n}->{1}='no, another text';
print "NEXT IS : ".nextsubfieldid($record->{tags}->{110}->{1}->{subfields})."\n";

&addMarcBiblio($record);
