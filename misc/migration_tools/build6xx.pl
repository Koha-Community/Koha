#!/usr/bin/perl
# script that rebuild thesaurus from biblio table.

# delete  FROM  `marc_subfield_table`  WHERE tag =  "606" AND subfieldcode = 9;
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
my ($version, $verbose, $test_parameter, $field,$delete,$category,$subfields);
GetOptions(
    'h' => \$version,
    'd' => \$delete,
    't' => \$test_parameter,
    's:s' => \$subfields,
    'v' => \$verbose,
    'c:s' => \$category,
);

if ($version || ($category eq '')) {
    print <<EOF
small script to recreate a authority table into Koha.
parameters :
\tc : thesaurus category. Can be filled with anything, the NC is hardcoded. But mandatory to confirm that you want to rebuild 6xx
\d : delete every entry of the selected category before doing work.

SAMPLES :
 ./build6xx.pl -c NC -d 
EOF
;#
die;
}

my $dbh = C4::Context->dbh;
my @subf = $subfields =~ /(##\d\d\d##.)/g;
if ($delete) {
    print "deleting thesaurus\n";
    my $del1 = $dbh->prepare("delete from auth_subfield_table where authid=?");
    my $del2 = $dbh->prepare("delete from auth_word where authid=?");
    my $sth = $dbh->prepare("select authid from auth_header where authtypecode='NC'");
    $sth->execute;
    while (my ($authid) = $sth->fetchrow) {
        $del1->execute($authid);
        $del2->execute($authid);
    }
    $dbh->do("delete from auth_header where authtypecode='NC'");
    $dbh->do("delete from marc_subfield_table where tag='606' and subfieldcode='9'");
    $dbh->do("delete from marc_word where tagsubfield='6069'");
}

if ($test_parameter) {
    print "TESTING MODE ONLY\n    DOING NOTHING\n===============\n";
}
$|=1; # flushes output
my $starttime = gettimeofday;
my $sth = $dbh->prepare("select bibid from marc_biblio");
$sth->execute;
my $i=1;
my %alreadydone;

# search biblios to "connect" to an authority with any number of $x (limited to 4 $x in this script)
my $sthBIBLIOS = $dbh->prepare("select distinct m1.bibid,m1.tag,m1.tagorder,m1.subfieldorder from marc_subfield_table as m1 where tag in (606) and subfieldcode='a' and subfieldvalue=?");
my $sthBIBLIOSx = $dbh->prepare("select distinct m1.bibid,m1.tag,m1.tagorder,m1.subfieldorder from marc_subfield_table as m1 left join marc_subfield_table as m2 on m1.bibid=m2.bibid where m1.tag in (606) and m1.subfieldcode='a' and m2.subfieldcode='x' and m1.subfieldvalue=? and m2.subfieldvalue=?");
my $sthBIBLIOSxx = $dbh->prepare("select distinct m1.bibid,m1.tag,m1.tagorder,m1.subfieldorder from marc_subfield_table as m1 left join marc_subfield_table as m2 on m1.bibid=m2.bibid left join marc_subfield_table as m3 on m1.bibid=m3.bibid where m1.tag in (606) and m1.subfieldcode='a' and m2.subfieldcode='x' and m3.subfieldcode='x' and m1.subfieldvalue=? and m2.subfieldvalue=? and m3.subfieldvalue=?");
my $sthBIBLIOSxxx = $dbh->prepare("select distinct m1.bibid,m1.tag,m1.tagorder,m1.subfieldorder from marc_subfield_table as m1 left join marc_subfield_table as m2 on m1.bibid=m2.bibid left join marc_subfield_table as m3 on m1.bibid=m4.bibid left join marc_subfield_table as m4 on m1.bibid=m4.bibid where m1.tag in (606) and m1.subfieldcode='a' and m2.subfieldcode='x' and m3.subfieldcode='x' and m4.subfieldcode='x' and m1.subfieldvalue=? and m2.subfieldvalue=? and m3.subfieldvalue=? and m4.subfieldvalue=?");
my $sthBIBLIOSxxxx = $dbh->prepare("select distinct m1.bibid,m1.tag,m1.tagorder,m1.subfieldorder from marc_subfield_table as m1 left join marc_subfield_table as m2 on m1.bibid=m2.bibid left join marc_subfield_table as m3 on m1.bibid=m4.bibid left join marc_subfield_table as m4 on m1.bibid=m4.bibid left join marc_subfield_table as m5 on m1.bibid=m5.bibid where m1.tag in (606) and m1.subfieldcode='a' and m2.subfieldcode='x' and m3.subfieldcode='x' and m4.subfieldcode='x' and m5.subfieldcode='x' and m1.subfieldvalue=? and m2.subfieldvalue=? and m3.subfieldvalue=? and m4.subfieldvalue=? and m5.subfieldvalue=?");

# loop through each biblio
while (my ($bibid) = $sth->fetchrow) {
    my $record = GetMarcBiblio($bibid);
    my $timeneeded = gettimeofday - $starttime;
    print "$i in $timeneeded s\n" unless ($i % 50);
    foreach my $field ($record->field(995)) {
        $record->delete_field($field);
    }
    my $totdone=0;
    my $authid;
    # search the 606 field(s)
    foreach my $field ($record->field("606")) {
        foreach my $authentry ($field->subfield("a")) {
            # the hashentry variable contains all $x fields and the $a in a single string. Used to differenciate
            # $xsomething$aelse and $asomething else
            my $hashentry = $authentry;
            foreach my $x ($field->subfield('x')) {
                $hashentry.=" -- $x";
            }
            # remove ��$e...
            # all the same for mysql, but NOT for perl hashes !
            # without those lines, t� is not tot and pat� is not patee
            $hashentry =~ s/���e/g;
            $hashentry =~ s/��a/g;
            $hashentry =~ s/�i/g;
            $hashentry =~ s/�o/g;
            $hashentry =~ s/|/u/g;
            # uppercase all, in case of typing error.
            $hashentry = uc($hashentry);
            $totdone++;
            if ($alreadydone{$hashentry}) {
                $authid = $alreadydone{$hashentry};
                print ".";
            } else {
                print "*";
                #create authority.
                my $authorityRecord = MARC::Record->new();
                my $newfield = MARC::Field->new(250,'','','a' => "".$authentry);
                foreach my $x ($field->subfield('x')) {
                    $newfield->add_subfields('x' => $x);
                }
                foreach my $z ($field->subfield('z')) {
                    $newfield->add_subfields('z' => $z);
                }
                $authorityRecord->insert_fields_ordered($newfield);
                $authid=AUTHaddauthority($dbh,$authorityRecord,'','NC');
                $alreadydone{$hashentry} = $authid;
                # we have the authority number, now we update all biblios that use this authority...
                my @x = $field->subfield('x'); # depending on the number of $x in the subfield
                if ($#x eq -1) { # no $x
                    $sthBIBLIOS->execute($authentry);
                    while (my ($bibid,$tag,$tagorder,$subfieldorder) = $sthBIBLIOS->fetchrow) {
                        # check that the field does not already have a $x (if it has, it will or has been managed by another authority
                        my $inbiblio = GetMarcBiblio($bibid);
                        my $isOK = 0;
                        # loop in each 606 field
                        foreach my $in606 ($inbiblio->field('606')) {
                            my $inEntry = $in606->subfield('a');
                            # and rebuild the $x -- $x -- $a string (like for $hashentry, few lines before)
                            foreach my $x ($in606->subfield('x')) {
                                $inEntry.=" -- $x";
                            }
                            $inEntry =~ s/���e/g;
                            $inEntry =~ s/��a/g;
                            $inEntry =~ s/�i/g;
                            $inEntry =~ s/�o/g;
                            $inEntry =~ s/|/u/g;
                            $inEntry = uc($inEntry);
                            # ok, it's confirmed that we must add the $9 subfield for this biblio, so...
                            $isOK=1 if $inEntry eq $hashentry;
                        }
                        # ... add it !
                        C4::Biblio::MARCaddsubfield($dbh,$bibid,$tag,'',$tagorder,9,$subfieldorder,$authid) if $isOK;
                    }
                }
                if ($#x eq 0) { # one $x
                    $sthBIBLIOSx->execute($authentry,$x[0]);
                    while (my ($bibid,$tag,$tagorder,$subfieldorder) = $sthBIBLIOSx->fetchrow) {
                        my $inbiblio = GetMarcBiblio($bibid);
                        my $isOK = 0;
                        foreach my $in606 ($inbiblio->field('606')) {
                            my $inEntry = $in606->subfield('a');
                            foreach my $x ($in606->subfield('x')) {
                                $inEntry.=" -- $x";
                            }
                            $inEntry =~ s/���e/g;
                            $inEntry =~ s/��a/g;
                            $inEntry =~ s/�i/g;
                            $inEntry =~ s/�o/g;
                            $inEntry =~ s/|/u/g;
                            $inEntry = uc($inEntry);
                            $isOK=1 if $inEntry eq $hashentry;
                        }
                        C4::Biblio::MARCaddsubfield($dbh,$bibid,$tag,'',$tagorder,9,$subfieldorder,$authid) if $isOK;
                    }
                }
                if ($#x eq 1) { # two $x
                    $sthBIBLIOSxx->execute($authentry,$x[0],$x[1]);
                    while (my ($bibid,$tag,$tagorder,$subfieldorder) = $sthBIBLIOSxx->fetchrow) {
                        my $inbiblio = GetMarcBiblio($bibid);
                        my $isOK = 0;
                        foreach my $in606 ($inbiblio->field('606')) {
                            my $inEntry = $in606->subfield('a');
                            foreach my $x ($in606->subfield('x')) {
                                $inEntry.=" -- $x";
                            }
                            $inEntry =~ s/���e/g;
                            $inEntry =~ s/��a/g;
                            $inEntry =~ s/�i/g;
                            $inEntry =~ s/�o/g;
                            $inEntry =~ s/|/u/g;
                            $inEntry = uc($inEntry);
                            $isOK=1 if $inEntry eq $hashentry;
                        }
                        C4::Biblio::MARCaddsubfield($dbh,$bibid,$tag,'',$tagorder,9,$subfieldorder,$authid) if $isOK;
                    }
                }
                if ($#x eq 2) { # 3 $x
                    $sthBIBLIOSxxx->execute($authentry,$x[0],$x[1],$x[2]);
                    while (my ($bibid,$tag,$tagorder,$subfieldorder) = $sthBIBLIOSxxx->fetchrow) {
                        my $inbiblio = GetMarcBiblio($bibid);
                        my $isOK = 0;
                        foreach my $in606 ($inbiblio->field('606')) {
                            my $inEntry = $in606->subfield('a');
                            foreach my $x ($in606->subfield('x')) {
                                $inEntry.=" -- $x";
                            }
                            $inEntry =~ s/���e/g;
                            $inEntry =~ s/��a/g;
                            $inEntry =~ s/�i/g;
                            $inEntry =~ s/�o/g;
                            $inEntry =~ s/|/u/g;
                            $inEntry = uc($inEntry);
                            $isOK=1 if $inEntry eq $hashentry;
                        }
                        C4::Biblio::MARCaddsubfield($dbh,$bibid,$tag,'',$tagorder,9,$subfieldorder,$authid) if $isOK;
                    }
                }
                if ($#x eq 3) { # 3 $x
                    $sthBIBLIOSxxxx->execute($authentry,$x[0],$x[1],$x[2],$x[3]);
                    while (my ($bibid,$tag,$tagorder,$subfieldorder) = $sthBIBLIOSxxxx->fetchrow) {
                        my $inbiblio = GetMarcBiblio($bibid);
                        my $isOK = 0;
                        foreach my $in606 ($inbiblio->field('606')) {
                            my $inEntry = $in606->subfield('a');
                            foreach my $x ($in606->subfield('x')) {
                                $inEntry.=" -- $x";
                            }
                            $inEntry =~ s/���e/g;
                            $inEntry =~ s/��a/g;
                            $inEntry =~ s/�i/g;
                            $inEntry =~ s/�o/g;
                            $inEntry =~ s/|/u/g;
                            $inEntry = uc($inEntry);
                            $isOK=1 if $inEntry eq $hashentry;
                        }
                        C4::Biblio::MARCaddsubfield($dbh,$bibid,$tag,'',$tagorder,9,$subfieldorder,$authid) if $isOK;
                    }
                }
                if ($#x >4) {
                    # too many $x, not handled, warn the developper that tries to migrate
                    print "warning there is ".$#x.'$x values';
                }
            }
        }
    }
    $i++;
}
my $timeneeded = gettimeofday - $starttime;
print "$i entries done in $timeneeded seconds (".($i/$timeneeded)." per second)\n";
