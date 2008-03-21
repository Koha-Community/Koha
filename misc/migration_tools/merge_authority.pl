#!/usr/bin/perl
# script that rebuild thesaurus from biblio table.

use strict;
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/kohalib.pl" };
}

# Koha modules used
use C4::Context;
use C4::Biblio;
use C4::AuthoritiesMarc;
use Time::HiRes qw(gettimeofday);

use Getopt::Long;
my ($version, $verbose, $mergefrom,$mergeto,$noconfirm);
GetOptions(
    'h' => \$version,
    'f:s' => \$mergefrom,
    't:s' => \$mergeto,
    'v' => \$verbose,
    'n' => \$noconfirm,
);

if ($version || ($mergefrom eq '')) {
    print <<EOF
Script to merge an authority into another
parameters :
\th : this version/help screen
\tv : verbose mode (show many things on screen)
\tf : the authority number to merge (the one that can be deleted after the merge).
\tt : the authority number where to merge
\tn : don't ask for confirmation (useful for batch mergings, should not be used on command line)

All biblios with the authority in -t will be modified to be "connected" to authority -f
SAMPLE :
./merge_authority.pl -f 2457 -t 531

Before doing anything, the script will show both authorities and ask for confirmation. Of course, you can merge only 2 authorities of the same kind.
EOF
;#
die;
}#/'

my $dbh = C4::Context->dbh;
# my @subf = $subfields =~ /(##\d\d\d##.)/g;

$|=1; # flushes output
my $authfrom = AUTHgetauthority($mergefrom);
my $authto = AUTHgetauthority($mergeto);

my $authtypecodefrom = AUTHfind_authtypecode($mergefrom);
my $authtypecodeto = AUTHfind_authtypecode($mergeto);

unless ($noconfirm) {
    print "************\n";
    print "You will merge authority : $mergefrom ($authtypecodefrom)\n".$authfrom->as_formatted;
    print "\n*************\n";
    print "Into authority : $mergeto ($authtypecodeto)\n".$authto->as_formatted;
    print "\n\nDo you confirm (enter YES)?";
    my $confirm = <STDIN>;
    chop $confirm;
    unless (uc($confirm) eq 'YES' and $authtypecodefrom eq $authtypecodeto) {
        print "IMPOSSIBLE : authorities are not of the same type ($authtypecodefrom vs $authtypecodeto) !!!\n" if $authtypecodefrom ne $authtypecodeto;
        print "Merge cancelled\n";
        exit;
    }
}
my $starttime = gettimeofday;
print "Merging\n" unless $noconfirm;

# search the tag to report
my $sth = $dbh->prepare("select auth_tag_to_report from auth_types where authtypecode=?");
$sth->execute($authtypecodefrom);
my ($auth_tag_to_report) = $sth->fetchrow;
# my $record_to_report = $authto->field($auth_tag_to_report);
print "Reporting authority tag $auth_tag_to_report :\n" if $verbose;
my @record_to = $authto->field($auth_tag_to_report)->subfields();
my @record_from = $authfrom->field($auth_tag_to_report)->subfields();

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
my $nbdone;
# and delete entries before recreating them
while (my ($bibid,$tag,$tag_indicator,$tagorder,$subfieldcode,$subfieldorder) = $sth->fetchrow) {
    my $biblio = GetMarcBiblio($bibid);
    print "BEFORE : ".$biblio->as_formatted."\n" if $verbose;
    # now, we know what uses the authority & where.
    # delete all subfields that are in the same tag/tagorder and that are in the authority (& that are not in tab ignore in the biblio)
    # then recreate them with the new authority.
    foreach my $subfield (@record_from) {
        &MARCdelsubfield($bibid,$tag,$tagorder,$subfield->[0]);
    }
    &MARCdelsubfield($dbh,$bibid,$tag,$tagorder,'9');
    foreach my $subfield (@record_to) {
        &MARCaddsubfield($bibid,$tag,$tag_indicator,$tagorder,$subfield->[0],$subfieldorder,$subfield->[1]);
    }
    &MARCaddsubfield($bibid,$tag,$tag_indicator,$tagorder,'9',$subfieldorder,$mergeto);
    $biblio = GetMarcBiblio($bibid);
    print "AFTER : ".$biblio->as_formatted."\n" if $verbose;
    $nbdone++;
#     &MARCdelsubfield($dbh,$bibid,$tag,$tagorder,$subfieldcode,$subfieldorder);
    
}
my $timeneeded = gettimeofday - $starttime;
print "$nbdone authorities done in $timeneeded seconds" unless $noconfirm;
