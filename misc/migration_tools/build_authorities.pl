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
my ( $input_marc_file, $number) = ('',0);
my ($version, $verbose, $delete, $confirm, $howmany);
GetOptions(
    'h' => \$version,
    'd' => \$delete,
    'v' => \$verbose,
    'c' => \$confirm,
# this $howmany parameter & other commented code was here to enable incremental building of the authorities, but it does not work well.
# 	'n:s' => \$howmany,
);

if ($version || (!$confirm)) {
	print <<EOF
Script to recreate a authority tables into Koha from biblios
parameters :
\th : this version/help screen
\tc : confirm. this script run without -c shows this help, pls run it with -c to execute it
\tv : verbose mode.
\td : delete the thesaurus before doing work. This deleting is smart enough to delete only the categories to rebuild. However, it is quite slow. Don''t be surprised...
\tn X : do only X entries, then stop. As the script is incremental, you can create authorities X by X until done.

BEFORE RUNNING this script, you MUST edit it & adapt the %whattodo hash to fit your needs. It contains :
* as key, the code of the authority to be created. It's the one you've choosen (or will choose) in Koha >> parameters >> thesaurus structure >> add). It can be whatever you want. NP/CO/NG/TI/NC in CVS refers to UNIMARC french RAMEAU category codes.
* in values a sub-hash with the following values :
\ttaglist : the list of MARC tags using this authority
\tkey : the list of MARC subfields used as key for authority. 2 entries in biblio having the same key will be considered as the same.
\tother : the list of MARC subfields not used as key, but to be copied in authority.
\tauthtag : the field in authority that will be reported in biblio. Remember that all subfields in tag "authtag" will be reported in the same subfield of the biblio (in MARC tags that are in "taglist")

don't forget to define the itemfield. In UNIMARC, it should be 995, in MARC21, probably 852

Any warning will be stored in the warnings.log file.
EOF
;#'
die;
}

my $dbh = C4::Context->dbh;

my $itemfield = '995'; # enter the TAG number where your items are stored.

my %whattodo = (
	# authority code (the one you've choosen (or will choose) in Koha >> parameters >> thesaurus structure >> add)
	TU =>	{	taglist	=> "500",
				key		=> "a|i|x|k|l|m|n|q|y|z",
				other	=> "",
				authtag => "230",
			},
	
	SAUT =>	{
				taglist	=> "600",
				key		=> "a|b|c|d|f|x|y|z",
				other	=> "j",
				authtag => "200",
			},
	SAUTTIT =>	{
				taglist	=> "604",
				key		=> "a|b|c|d|f|x|y|z",
				other	=> "j",
				authtag => "240",
			},
	SCO =>	{	taglist	=> "601",
				key		=> "a|b",
				other	=> "c|d|f|g|p",
				authtag => "210",
			},
	STU =>	{	taglist	=> "605",
				key		=> "a|i|x|k|l|m|n|q|y|z",
				other	=> "",
				authtag => "230",
			},
	SNG =>	{	taglist	=> "607",
				key		=> "a|x|y|z",
				other	=> "",
				authtag => "215",
			},
	SNC => 	{	taglist	=> "606",
				key		=> "a|x|y|z",
				other	=> "",
				authtag => "250",
			},
	
	NP =>	{
				# the list of MARC tags using this authority
				taglist	=> "700|701|702",
				# the list of MARC subfields used as key for authority. 2 entries in biblio having the same key will be considered as the same.
				key		=> "a|b|c|d|f|x|y|z",
				# the list of MARC subfields not used as key, but to be copied in authority.
				other	=> "j",
				# the field in authority that will be reported in biblio. Remember that all subfields in tag "authtag" will be reported in the same subfield of the biblio (in MARC tags that are in "taglist")
				authtag => "200",
			},
	CO =>	{	taglist	=> "710|711|712",
				key		=> "a|b",
				other	=> "c|d|f|g|p",
				authtag => "210",
			},
);
my %authorities;

open WARNING_FILE,">","warnings.log";

my $field_list;
my $category_list;
foreach (keys %whattodo) {
	$field_list .= $whattodo{$_}->{taglist}.'|';
	$category_list.= "'".$_."',"
}
chop $field_list;

if ($delete) {
	print "deleting thesaurus step 1\n";
	chop $category_list;
	my $del1 = $dbh->prepare("delete from auth_subfield_table where authid=?");
	my $del2 = $dbh->prepare("delete from auth_word where authid=?");
	my $sth = $dbh->prepare("select authid from auth_header where authtypecode in ($category_list)");
	$sth->execute;
	while (my ($authid) = $sth->fetchrow) {
		$del1->execute($authid);
		$del2->execute($authid);
	}
	print "deleting thesaurus step 2\n";
	$dbh->do("delete from auth_header where authtypecode in ($category_list)");
	$dbh->do("delete from marc_subfield_table where tag in ('".join("','",split('\|',$field_list))."') and subfieldcode='9'");
	$dbh->do("delete from marc_word where tagsubfield in ('".join("9','",split('\|',$field_list))."9')");
# 	die;
}

$|=1; # flushes output
my $starttime = gettimeofday;
my $sth = $dbh->prepare("select bibid from marc_biblio");
$sth->execute;
my $i=1;

my $modified;
my $alreadydone;
my $totalskipped;
while (my ($bibid) = $sth->fetchrow) {
	my $record = MARCgetbiblio($dbh,$bibid);
	$modified=0;
	$i++;
# 	print "i : $i / howmany : $howmany\n";
# 	exit if $i>$howmany;
	
	# skip what has already been done...
# 	$alreadydone=0;
# 	foreach my $field ($record->fields) {
# 		if ($field->tag() =~ /$field_list/) {
# # 			print "F : $field_list ".$field->tag()." => ".$field->as_formatted."\n";
# 			if ($field->subfield('9')) {
# 				$alreadydone++;
# 			} else {
# 				if ($alreadydone) {
# 					print "ERROR : biblio partially done, some \$9 (authority link) missing : ".$record->as_formatted."\n======= You should run the script again using -d to delete everything";
# 					die;
# 				}
# 			}
# 		}
# 	}
# 	$totalskipped++ if $alreadydone;
# 	next if $alreadydone;
# 	my $timeneeded = gettimeofday - $starttime;
	print " $i in ".(gettimeofday-$starttime)." s\n" unless ($i % 100);
	# be careful, as the last entry may have been 
	# delete ITEM field, we only deal with BIBLIOS
	foreach my $field ($record->field($itemfield)) {
		$record->delete_field($field);
	}
	my $totdone=0;
# 	my $authid;
	# on passe tous les champs
	foreach my $field ($record->fields) {
		foreach my $DOauthtype (keys %whattodo) {
			my $DOtaglist = $whattodo{$DOauthtype}->{taglist};
			my $DOkey = $whattodo{$DOauthtype}->{key};
			my $DOother = $whattodo{$DOauthtype}->{other};
			my $DOauthtag = $whattodo{$DOauthtype}->{authtag};
			if ($field->tag() =~ /$DOtaglist/) {
				# try to find the authority in %NP ...
				# build the "key"
				my $authPrimaryKey;
				foreach (split '\|',$DOkey) {
					$authPrimaryKey .= join('|',$field->subfield($_))."|" if $field->subfield($_);
				}
				# if authority exist, check it can't be completed by subfields not previously seen.
				# otherwise, create if with whatever available.
				if ($authorities{$DOauthtype}->{$authPrimaryKey}) {
					# check that the existing authority has all the datas. Otherwise, add them, but don't modify already parsed biblios.
					# at the end of the script, all authorities will be updated. So, the "merge_authority.pl" tool can be used to update all biblios.
					foreach my $subfieldtotest (split '\|',$DOother) {
						if ($field->subfield($subfieldtotest)) {
							if ($authorities{$DOauthtype}->{$authPrimaryKey}->{record}->field($DOauthtag)->subfield($subfieldtotest) 
												ne
													$field->subfield($subfieldtotest)) {
								print WARNING_FILE "========\nERROR ON $i $subfieldtotest authorities seems to differ, can't choose between : \n".$authorities{$DOauthtype}->{$authPrimaryKey}->{record}->field($DOauthtag)->as_formatted()." \n====== AND ======\n ".$field->as_formatted()."\n=======\n";
								print "W";
							}
							# $c was not here, add it...
							unless ($authorities{$DOauthtype}->{$authPrimaryKey}->{record}->field($DOauthtag)->subfield($subfieldtotest)) {
								my $fieldA= $authorities{$DOauthtype}->{$authPrimaryKey}->{record}->field($DOauthtag)->clone();
								$fieldA->add_subfields($subfieldtotest => $field->subfield($subfieldtotest));
								$authorities{$DOauthtype}->{$authPrimaryKey}->{record}->field($DOauthtag)->replace_with($fieldA);
								$authorities{$DOauthtype}->{$authPrimaryKey}->{modified} = 1;
							}
						}
					}
				} else {
					my $authrecord = MARC::Record->new();
					my $authfield;
					foreach (split '\|',$DOkey) {
						if ($authfield) {
							$authfield->add_subfields($_ => join ('|',$field->subfield($_))) if $field->subfield($_);
						} else {
							$authfield = MARC::Field->new( $DOauthtag,'','',$_ => join ('|',$field->subfield($_)));
						}
					}
					foreach (split '\|',$DOother) {
						if ($authfield) {
							$authfield->add_subfields($_ => join ('|',$field->subfield($_))) if $field->subfield($_);
						} else {
							$authfield = MARC::Field->new( $DOauthtag,'','',$_ => join ('|',$field->subfield($_)));
						}
					}
					$authrecord->insert_fields_ordered($authfield);
					my $authid = AUTHaddauthority($dbh,$authrecord,'',$DOauthtype);
					$authorities{$DOauthtype}->{$authPrimaryKey}->{authid} = $authid;
					$authorities{$DOauthtype}->{$authPrimaryKey}->{record} = $authrecord->clone;
					$authorities{$DOauthtype}->{$authPrimaryKey}->{modified} = 0;
				}
				print "ERROR !!!! \$9 already exists in $authPrimaryKey / ".$field->as_formatted."\n" if $field->subfield('9');
				my $fieldC = $field->clone();
				$fieldC->add_subfields('9' => $authorities{$DOauthtype}->{$authPrimaryKey}->{authid});
				$field->replace_with($fieldC);
	# 			print $NP{$keyNP}->{authid}." => ".$record->as_formatted."\n";
				$modified++;
			}
		}
	}
#
# NC
#
# OK, done, now store modified biblio if it has been modified
	if ($modified) {
		my $frameworkcode=MARCfind_frameworkcode($dbh,$bibid);
		NEWmodbiblio($dbh,$record,$bibid,$frameworkcode);
# 		print "skipped $totalskipped biblios in ".(gettimeofday-$starttime)." s\n" if $totalskipped;
# 		$totalskipped=0;
		print "$modified";
	} else {
		# if $totalskipped is not null, we are in a biblio that has no authorities entry, but inside an already done part of the job
		# ++ totalskipped & don't show a useless *
# 		if ($totalskipped) {
# 			$totalskipped++;
# 		} else {
			print "*";
# 		}
	}
}

#
# now, parse authorities & modify them if they have been modified/completed by a subfield not existing on the 1st biblio using this authority.
#
foreach my $authtype (keys %whattodo) {
	foreach my $authentry (keys %{$authorities{$authtype}}) {
# 		print "AUTH : $authentry\n" if $authorities{$authtype}->{$authentry}->{modified};
		AUTHmodauthority($dbh,$authorities{$authtype}->{$authentry}->{authid},$authorities{$authtype}->{$authentry}->{record}) if $authorities{$authtype}->{$authentry}->{modified};
	}
}
#
my $timeneeded = gettimeofday - $starttime;
print "$i entries done in $timeneeded seconds (".($i/$timeneeded)." per second)\n";
close WARNING_FILE;