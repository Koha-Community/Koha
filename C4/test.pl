#!/usr/bin/perl
use strict;
require Exporter;
use C4::Database;
use C4::Catalogue;

my $dbh=&C4Connect;
$dbh->do("delete from marc_subfield_table");
$dbh->do("delete from marc_blob_subfield");
&addSubfield(1,'001','a','1 - This is a value',1);
&addSubfield(1,'001','b','2 - This is another value',1);
&addSubfield(1,'001','c',"3 - This is a value very very long. I try to make it longer than 255 char. I need to add something else. will it be long enough now... I'm not sure. That's why i continue to add a few word to this very important sentence. Now I hope it will be enough... Oh, not it need some more characters. So i add stupid strings : xxxxxxxxxxxxxxx dddddddddddddddddddd eeeeeeeeeeeeeeeeeeeeeee rrrrrrrrrrrrrrrrrrr ffffffffffffffffff",1);
&addSubfield(1,'001','d',"4 - This is another value very very long. I try to make it longer than 255 char. I need to add something else. will it be long enough now... I'm not sure. That's why i continue to add a few word to this very important sentence. Now I hope it will be enough... Oh, not it need some more characters. So i add stupid strings : xxxxxxxxxxxxxxx dddddddddddddddddddd eeeeeeeeeeeeeeeeeeeeeee rrrrrrrrrrrrrrrrrrr ffffffffffffffffff",1);
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
my $marcstru={};
$marcstru->{bibid}=58973;
$marcstru->{tags}->{1}->{tag}='110';
$marcstru->{tags}->{1}->{tagorder}=1;
$marcstru->{tags}->{1}->{subfields}->{1}->{mark}='a';
$marcstru->{tags}->{1}->{subfields}->{1}->{subfieldorder}=1;
$marcstru->{tags}->{1}->{subfields}->{1}->{value}='this is a test';
$marcstru->{tags}->{1}->{subfields}->{2}->{mark}='b';
$marcstru->{tags}->{1}->{subfields}->{2}->{subfieldorder}=1;
$marcstru->{tags}->{1}->{subfields}->{2}->{value}='this is another test';

$marcstru->{tags}->{2}->{tag}='220';
$marcstru->{tags}->{2}->{tagorder}=1;
$marcstru->{tags}->{2}->{subfields}->{1}->{mark}='a';
$marcstru->{tags}->{2}->{subfields}->{1}->{subfieldorder}=1;
$marcstru->{tags}->{2}->{subfields}->{1}->{value}='this is a test for 220';
$marcstru->{tags}->{2}->{subfields}->{2}->{mark}='b';
$marcstru->{tags}->{2}->{subfields}->{2}->{subfieldorder}=1;
$marcstru->{tags}->{2}->{subfields}->{2}->{value}='this is another test for 220';
$marcstru->{tags}->{2}->{subfields}->{3}->{mark}='b';
$marcstru->{tags}->{2}->{subfields}->{3}->{subfieldorder}=2;
$marcstru->{tags}->{2}->{subfields}->{3}->{value}='this is a third test for 220';

$marcstru->{tags}->{3}->{tag}='330';
$marcstru->{tags}->{3}->{tagorder}=1;
$marcstru->{tags}->{3}->{subfields}->{1}->{mark}='a';
$marcstru->{tags}->{3}->{subfields}->{1}->{subfieldorder}=1;
$marcstru->{tags}->{3}->{subfields}->{1}->{value}='this is a test for 330';
$marcstru->{tags}->{3}->{subfields}->{2}->{mark}='b';
$marcstru->{tags}->{3}->{subfields}->{2}->{subfieldorder}=1;
$marcstru->{tags}->{3}->{subfields}->{2}->{value}='this is another test for 330';
$marcstru->{tags}->{3}->{subfields}->{3}->{mark}='b';
$marcstru->{tags}->{3}->{subfields}->{3}->{subfieldorder}=2;
$marcstru->{tags}->{3}->{subfields}->{3}->{value}='this is a third test for 330';

&addMarcBiblio($marcstru);
