#!/usr/bin/perl
# script that rebuild thesaurus from biblio table.

use strict;

# Koha modules used
use MARC::File::USMARC;
use MARC::Record;
use MARC::Batch;
use C4::Context;
use C4::Biblio;
use C4::AuthoritiesMarc;
use Time::HiRes qw(gettimeofday);

use Getopt::Long;
my ($version, $verbose, $mergefrom,$mergeto,$noconfirm,$batch);
GetOptions(
    'h' => \$version,
    'f:s' => \$mergefrom,
    'v' => \$verbose,
	'n' => \$noconfirm,
	'b' => \$batch,
);

if ($version || ($mergefrom eq '' && !$batch)) {
	print <<EOF
Script to merge an authority into another
parameters :
\th : this version/help screen
\tv : verbose mode (show many things on screen)
\tf : the authority number to merge (the one that can be deleted after the merge).
\tt : the authority number where to merge
\tb : batch merging.
\tn : don't ask for confirmation (useful for batch mergings, should not be used on command line)

All biblios with the authority in -t will be modified and the authority entry removed
SAMPLE :
./delete_authority.pl -f 2457

BATCH MODE :
./delete_authority.pl -b

(don't forget to export PERL5LIB and KOHA_CONF. Here is my cron job :
SHELL=/bin/bash
*/5 * * * *       export PERL5LIB=/home/httpd/koha;export KOHA_CONF=/etc/mykoha.conf;/home/httpd/koha/scripts/misc/delete_authority.pl -b -n

EOF
;#
exit;
}#

my $dbh = C4::Context->dbh;
# my @subf = $subfields =~ /(##\d\d\d##.)/g;

$|=1; # flushes output
my $starttime = gettimeofday;
if ($batch) {
	my @authlist;
	my $cgidir = C4::Context->intranetdir ."/cgi-bin";
	unless (opendir(DIR, "$cgidir/localfile/deleted_authorities")) {
		$cgidir = C4::Context->intranetdir;
		opendir(DIR, "$cgidir/localfile/deleted_authorities") || die "can't opendir $cgidir/localfile/deleted_authorities: $!";
	} 
	while (my $authid = readdir(DIR)) {
		if ($authid =~ /\.authid$/) {
			$authid =~ s/\.authid$//;
			print "managing $authid\n" if $verbose;
			my $MARCauth = AUTHgetauthority($dbh,$authid);
			&merge($dbh,$authid,$MARCauth,$authid,$MARCauth) if ($MARCauth);
			unlink $cgidir.'/localfile/deleted_authorities/'.$authid.'.authid';
		}
	}
	closedir DIR;
} else {
	my $MARCfrom = AUTHgetauthority($dbh,$mergefrom);
	&del_auth($dbh,$mergefrom,$MARCfrom);
}
my $timeneeded = gettimeofday - $starttime;
print "Done in $timeneeded seconds" unless $noconfirm;

sub del_auth {
	my ($dbh,$mergefrom,$MARCfrom) = @_;
	# return if authority does not exist
	my $authtypecodefrom = AUTHfind_authtypecode($dbh,$mergefrom);
	my @X = $MARCfrom->fields();
	return if $#X == -1;
	unless ($noconfirm) {
		print "************\n";
		print "You will delete authority : $mergefrom \n".$MARCfrom->as_formatted;
		print "\n*************\n";
		print "\n\nDo you confirm (enter YES)?";
		my $confirm = <STDIN>;
		chop $confirm;
		unless (uc($confirm) eq 'YES') {
			print "Deletion cancelled\n";
			exit;
		}
	}
	print "Deleting\n" unless $noconfirm;
	
	# search the tag to report
	my $sth = $dbh->prepare("select auth_tag_to_report from auth_types where authtypecode=?");
	$sth->execute($authtypecodefrom);
	my ($auth_tag_to_report) = $sth->fetchrow;
	# my $record_to_report = $MARCto->field($auth_tag_to_report);
	print "Deleting authority tag $auth_tag_to_report :\n" if $verbose;
	my @record_from;
	@record_from = $MARCfrom->field($auth_tag_to_report)->subfields() if $MARCfrom->field($auth_tag_to_report);
	
	# search all biblio tags using this authority.
	$sth = $dbh->prepare("select distinct tagfield from marc_subfield_structure where authtypecode=?");
	$sth->execute($authtypecodefrom);
	my $tags_using_authtype;
	while (my ($tagfield) = $sth->fetchrow) {
		$tags_using_authtype.= "'".$tagfield."',";
	}
	chop $tags_using_authtype;
	# now, find every biblio using this authority
	my $query = "select bibid,tag,tag_indicator,tagorder,subfieldcode,subfieldorder from marc_subfield_table where tag in ($tags_using_authtype) and subfieldcode='9' and subfieldvalue='$mergefrom'";
	$sth = $dbh->prepare($query);
	$sth->execute;
# 	my $nbdone;
	# and delete entries
	while (my ($bibid,$tag,$tag_indicator,$tagorder,$subfieldcode,$subfieldorder) = $sth->fetchrow) {
		my $biblio = MARCgetbiblio($dbh,$bibid);
		print "BEFORE : ".$biblio->as_formatted."\n" if $verbose;
		# now, we know what uses the authority & where.
		# delete all subfields that are in the same tag/tagorder and that are in the authority (& that are not in tab ignore in the biblio)
		# then recreate them with the new authority.
		foreach my $subfield (@record_from) {
			&MARCdelsubfield($dbh,$bibid,$tag,$tagorder,$subfield->[0]);
		}
		&MARCdelsubfield($dbh,$bibid,$tag,$tagorder,'9');
		my $biblio = MARCgetbiblio($dbh,$bibid);
		print "AFTER : ".$biblio->as_formatted."\n" if $verbose;
# 		$nbdone++;
	# 	&MARCdelsubfield($dbh,$bibid,$tag,$tagorder,$subfieldcode,$subfieldorder);
	}
}