#!/usr/bin/perl

# WARNING : this script is intended to be run as is only on a sample DB.
# in the sample DB downloadable from sourceforge, the aqbookfund table is full of trash data.
# this script drops this table and refill it with correct data.
# some tables have strange data too, so primary key cannot be created.

# if you want to apply this patch on a running DB :
# - do a backup !
# - remove the lines between <FORPRODDEL> and </FORPRODDEL>
# - remove the # before the lines between <FORPRODADD> and </FORPRODADD>
#    this will cause a primary key to be created if possible on your DB
# YOU'VE BEEN WARNING !!!!!


use C4::Database;
use C4::Catalogue;
use DBI;
use C4::Acquisitions;
use C4::Output;

sub droptable {
	my ($dbh,$tablename)=@_;
	if ($tables{$tablename}) {
		print "     - $tablename...\n";
		my $sti=$dbh->prepare("DROP TABLE $tablename");
		$sti->execute;
		return 1;
	}
	return 0;
}
sub dosql {
	my ($dbh,$sql_cmd)=@_;
	my $sti=$dbh->prepare($sql_cmd);
	$sti->execute;
	if ($sti->err) {
		print "error : ".$sti->errstr." \n tried to execute : $sql_cmd\n";
		$sti->finish;
	}
}


my $dbh=C4Connect;

my $sth=$dbh->prepare("show tables");
$sth->execute;
while (my ($table) = $sth->fetchrow) {
    $tables{$table}=1;
    print "table $table\n";
}

#print "creating thesaurus...\n";
#dosql($dbh,"CREATE TABLE bibliothesaurus (code BIGINT not null AUTO_INCREMENT, freelib CHAR (255) not null , stdlib CHAR (255) not null , type CHAR (80) not null , PRIMARY KEY (code), INDEX (freelib),index(stdlib),index(type))");
#	my $sti=$dbh->prepare("select subject from bibliosubject");
#	$sti->execute;
#	$i=0;
#	while ($line =$sti->fetchrow_hashref) {
#		$i++;
#		print "$i $line->{'subject'}\n";
#		$sti2=$dbh->prepare("select count(*) as t from bibliothesaurus where freelib=".$dbh->quote($line->{'subject'}));
#		$sti2->execute;
#		if ($sti2->err) {
#			print "error : ".$sti2->errstr." \n tried to execute : $sql_cmd\n";
#			die;
#		}
#		$line2=$sti2->fetchrow_hashref;
#		if ($line2->{'t'} ==0) {
#			dosql($dbh,"insert into bibliothesaurus (freelib,stdlib) values (".$dbh->quote($line->{'subject'}).",".$dbh->quote($line->{'subject'}).")");
#		} else {
#			print "pas ecriture pour : $line->{'subject'}\n";
#		}
#
#	}

#aqbookfund : the sample db is full of trash data. Delete and recreate
# <FORPRODDEL>
	print "aqbookfund...";
	dosql($dbh,"delete from aqbookfund");
	dosql($dbh,"INSERT INTO aqbookfund VALUES( '5', 'Young Adult Fiction', '3')");
	dosql($dbh,"INSERT INTO aqbookfund VALUES( '4', 'Fiction', '2')");
	dosql($dbh,"INSERT INTO aqbookfund VALUES( '2', 'Talking books', '4')");
	dosql($dbh,"INSERT INTO aqbookfund VALUES( '13', 'Newspapers & journals', '4')");
	dosql($dbh,"INSERT INTO aqbookfund VALUES( '10', 'Te Ao Maori', '1')");
	dosql($dbh,"INSERT INTO aqbookfund VALUES( '15', 'CDs, CD Roms, Maps, etc', '4')");
	dosql($dbh,"INSERT INTO aqbookfund VALUES( '9', 'Junior Fiction', '3')");
	dosql($dbh,"INSERT INTO aqbookfund VALUES( '7', 'Junior Non-Fiction', '3')");
	dosql($dbh,"INSERT INTO aqbookfund VALUES( '72', 'Creative NZ', '4')");
	dosql($dbh,"INSERT INTO aqbookfund VALUES( '11', 'Reference', '1')");
	dosql($dbh,"INSERT INTO aqbookfund VALUES( '12', 'Videos', '4')");
	dosql($dbh,"INSERT INTO aqbookfund VALUES( '8', 'Junior Paperback', '3')");
	dosql($dbh,"INSERT INTO aqbookfund VALUES( '73', 'Large Print Link-up', '2')");
	dosql($dbh,"INSERT INTO aqbookfund VALUES( '3', 'Large Print', '2')");
	dosql($dbh,"INSERT INTO aqbookfund VALUES( '71', 'Creative NZ NonFiction', '1')");
	dosql($dbh,"INSERT INTO aqbookfund VALUES( '6', 'Picture Books', '3')");
	dosql($dbh,"INSERT INTO aqbookfund VALUES( '14', 'Nga pukapuka Maori', '3')");
	dosql($dbh,"INSERT INTO aqbookfund VALUES( '80', 'Donations, junior books', '5')");
	dosql($dbh,"INSERT INTO aqbookfund VALUES( '81', 'Donations, adult books', '5')");
	dosql($dbh,"INSERT INTO aqbookfund VALUES( '82', 'Donations, magazines', '5')");
	dosql($dbh,"INSERT INTO aqbookfund VALUES( '83', 'Donations, non books', '5')");
	dosql($dbh,"INSERT INTO aqbookfund VALUES( '91', 'Vertical File', '5')");
	dosql($dbh,"INSERT INTO aqbookfund VALUES( '100', 'Loans', '6')");
	dosql($dbh,"INSERT INTO aqbookfund VALUES( '1', 'Test', '1')");
#</FORPRODDEL>
	dosql($dbh,"ALTER TABLE aqbookfund DROP PRIMARY KEY, ADD PRIMARY KEY(bookfundid);");
	print "done\n accountlines...";
	dosql($dbh,"ALTER TABLE accountlines CHANGE itemnumber itemnumber INT (11) not null;");
	dosql($dbh,"ALTER TABLE accountlines DROP PRIMARY KEY, ADD PRIMARY KEY(borrowernumber,accountno,itemnumber);");
# accountoffset not done (not possible ?)
#additionalauthor : not possible (no field useable, 1 index OK)
	print "done\n aqbooksellers...";
	dosql($dbh,"ALTER TABLE aqbooksellers CHANGE id id INT (11) not null;");
	dosql($dbh,"ALTER TABLE aqbooksellers DROP PRIMARY KEY, ADD PRIMARY KEY(id);");
	print "done\n aqbudget...";
	dosql($dbh,"ALTER TABLE aqbudget DROP PRIMARY KEY, ADD PRIMARY KEY(bookfundid, bookfundid);");
	print "done\n aqorderbreakdown...";
	dosql($dbh,"ALTER TABLE aqorderbreakdown CHANGE ordernumber ordernumber INT (11) not null;");
	dosql($dbh,"ALTER TABLE aqorderbreakdown CHANGE linenumber linenumber INT (11) not null;");
	dosql($dbh,"ALTER TABLE aqorderbreakdown CHANGE branchcode branchcode CHAR (4) not null;");
#<FORPRODADD>
#	ALTER TABLE aqorderbreakdown DROP PRIMARY KEY, ADD PRIMARY KEY(ordernumber,linenumber,branchcode);");
#</FORPRODADD>

	print "done\n biblio/borrowers...";
	dosql($dbh,"ALTER TABLE aqorderdelivery DROP PRIMARY KEY, ADD PRIMARY KEY(ordernumber);");
	dosql($dbh,"ALTER TABLE aqorders DROP PRIMARY KEY, ADD PRIMARY KEY(ordernumber);");
	dosql($dbh,"ALTER TABLE biblio DROP PRIMARY KEY, ADD PRIMARY KEY(biblionumber);");
	dosql($dbh,"ALTER TABLE biblioitems DROP PRIMARY KEY, ADD PRIMARY KEY(biblionumber, biblioitemnumber)");
#	dosql($dbh,"CREATE INDEX SUBTITLE ON bibliosubtitle (subtitle(80))");
	dosql($dbh,"ALTER TABLE borexp CHANGE borrowernumber borrowernumber INT (11) not null");
	dosql($dbh,"ALTER TABLE borexp CHANGE newexp newexp DATE not null");
	dosql($dbh,"ALTER TABLE branches DROP PRIMARY KEY, ADD PRIMARY KEY(branchcode)");
	dosql($dbh,"ALTER TABLE deletedbiblio DROP PRIMARY KEY, ADD PRIMARY KEY(biblionumber, biblionumber)");
	dosql($dbh,"ALTER TABLE deletedbiblioitems DROP PRIMARY KEY, ADD PRIMARY KEY(biblioitemnumber)");
	dosql($dbh,"ALTER TABLE deletedborrowers DROP PRIMARY KEY, ADD PRIMARY KEY(borrowernumber)");
	dosql($dbh,"ALTER TABLE deleteditems DROP PRIMARY KEY, ADD PRIMARY KEY(itemnumber)");
	dosql($dbh,"ALTER TABLE issues CHANGE date_due date_due DATE not null");
#<FORPRODADD>
# ALTER TABLE issues DROP PRIMARY KEY, ADD PRIMARY KEY(borrowernumber,itemnumber,date_due)");
#</FORPRODADD>
	print "done\n items...";
	dosql($dbh,"ALTER TABLE items DROP PRIMARY KEY, ADD PRIMARY KEY(itemnumber)");
	dosql($dbh,"ALTER TABLE itemsprices CHANGE itemnumber itemnumber INT (11) not null");
	dosql($dbh,"ALTER TABLE itemsprices DROP PRIMARY KEY, ADD PRIMARY KEY(itemnumber)");
	dosql($dbh,"ALTER TABLE itemtypes DROP PRIMARY KEY, ADD PRIMARY KEY(itemtype)");
	print "done\n various...";
	dosql($dbh,"ALTER TABLE categories DROP PRIMARY KEY, ADD PRIMARY KEY(categorycode)");
	dosql($dbh,"ALTER TABLE categoryitem DROP PRIMARY KEY, ADD PRIMARY KEY(categorycode,itemtype)");
	dosql($dbh,"ALTER TABLE currency CHANGE currency currency VARCHAR (10) not null");
	dosql($dbh,"ALTER TABLE currency CHANGE rate rate FLOAT (7,5) not null");
	dosql($dbh,"ALTER TABLE currency DROP PRIMARY KEY, ADD PRIMARY KEY(currency)");
	dosql($dbh,"ALTER TABLE printers CHANGE printername printername CHAR (40) not null");
	dosql($dbh,"ALTER TABLE printers DROP PRIMARY KEY, ADD PRIMARY KEY(printername)");
#<FORPRODADD>
# ALTER TABLE reserves DROP PRIMARY KEY, ADD PRIMARY KEY(borrowernumber,biblionumber,reservedate)
#</FORPRODADD>
	dosql($dbh,"ALTER TABLE stopwords CHANGE word word VARCHAR (255) not null");
	dosql($dbh,"ALTER TABLE stopwords DROP PRIMARY KEY, ADD PRIMARY KEY(word)");
	dosql($dbh,"ALTER TABLE systempreferences DROP PRIMARY KEY, ADD PRIMARY KEY(variable)");
	dosql($dbh,"ALTER TABLE users CHANGE usercode usercode VARCHAR (10) not null");
	dosql($dbh,"ALTER TABLE users DROP PRIMARY KEY, ADD PRIMARY KEY(usercode)");

print "dropping tables...\n";
my $total=0;
$total += droptable($dbh,'branchcategories');
$total += droptable($dbh,'classification');
$total += droptable($dbh,'multipart');
$total += droptable($dbh,'multivolume');
$total += droptable($dbh,'newitems');
$total += droptable($dbh,'procedures');
$total += droptable($dbh,'publisher');
$total += droptable($dbh,'searchstats');
$total += droptable($dbh,'serialissues');
print "         $total tables dropped\n";
