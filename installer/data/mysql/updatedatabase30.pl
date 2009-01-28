#!/usr/bin/perl


# Database Updater
# This script checks for required updates to the database.

# Part of the Koha Library Software www.koha.org
# Licensed under the GPL.

# Bugs/ToDo:
# - Would also be a good idea to offer to do a backup at this time...

# NOTE:  If you do something more than once in here, make it table driven.

# NOTE: Please keep the version in kohaversion.pl up-to-date!

use strict;
# use warnings;

# CPAN modules
use DBI;
use Getopt::Long;
# Koha modules
use C4::Context;
use C4::Installer;

use MARC::Record;
use MARC::File::XML ( BinaryEncoding => 'utf8' );
 
# FIXME - The user might be installing a new database, so can't rely
# on /etc/koha.conf anyway.

my $debug = 0;

my (
    $sth, $sti,
    $query,
    %existingtables,    # tables already in database
    %types,
    $table,
    $column,
    $type, $null, $key, $default, $extra,
    $prefitem,          # preference item in systempreferences table
);

my $silent;
GetOptions(
    's' =>\$silent
    );
my $dbh = C4::Context->dbh;
$|=1; # flushes output

=item

    Deal with virtualshelves

=cut

my $DBversion = '3.00.01.000';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    print "Upgrade to $DBversion done (start of 3.0.1)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.00.01.001';
if ( C4::Context->preference('Version') < TransformToNum($DBversion) ) {
    # use statistics where available
    $dbh->do("
        ALTER TABLE statistics ADD KEY  tmp_stats (type, itemnumber, borrowernumber)
    ");
    $dbh->do("
        UPDATE issues iss
        SET issuedate = (
            SELECT max(datetime)
            FROM statistics 
            WHERE type = 'issue'
            AND itemnumber = iss.itemnumber
            AND borrowernumber = iss.borrowernumber
        )
        WHERE issuedate IS NULL;
    ");  
    $dbh->do("ALTER TABLE statistics DROP KEY tmp_stats");

    # default to last renewal date
    $dbh->do("
        UPDATE issues
        SET issuedate = lastreneweddate
        WHERE issuedate IS NULL
        and lastreneweddate IS NOT NULL
    ");

    my $num_bad_issuedates = $dbh->selectrow_array("SELECT COUNT(*) FROM issues WHERE issuedate IS NULL");
    if ($num_bad_issuedates > 0) {
        print STDERR "After the upgrade to $DBversion, there are still $num_bad_issuedates loan(s) with a NULL (blank) loan date. ",
                     "Please check the issues table in your database.";
    }
    print "Upgrade to $DBversion done (bug 2582: set null issues.issuedate to lastreneweddate)";
    SetVersion($DBversion);
}

$DBversion = "3.00.01.002";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('AllowRenewalLimitOverride', '0', 'if ON, allows renewal limits to be overridden on the circulation screen',NULL,'YesNo')");
    print "Upgrade to $DBversion done (add new syspref)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.01.003";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('MergeAuthoritiesOnUpdate', '1', 'if ON, Updateing authorities will automatically updates biblios',NULL,'YesNo')");
    print "Upgrade to $DBversion done (add new syspref)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.01.004";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
  if (lc(C4::Context->preference('marcflavour')) eq "unimarc"){
    $dbh->do("INSERT IGNORE INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES ('099', 'Informations locales', '', 0, 0, '', '');");
    $dbh->do("INSERT IGNORE INTO `marc_tag_structure` (`frameworkcode`,`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`) SELECT DISTINCT(frameworkcode),'099', 'Informations locales', '', 0, 0, '' from biblio_framework");
    $dbh->do(<<ENDOFSQL);
INSERT IGNORE INTO marc_subfield_structure (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `seealso`, `link`, `defaultvalue`,frameworkcode )
VALUES ('099', 'c', 'date creation notice (koha)', '', 0, 0, 'biblio.datecreated', -1, '', '', '', NULL, 0, '', '', NULL, ''),
('099', 'd', 'date modification notice (koha)', '', 0, 0, 'biblio.timestamp', -1, '', '', '', NULL, 0, '', '', NULL, ''),
('995', '2', 'Perdu', '', 0, 0, 'items.itemlost', 10, '', '', '', NULL, 1, '', NULL, NULL, '');
ENDOFSQL
    $dbh->do(<<ENDOFSQL1);
INSERT IGNORE INTO marc_subfield_structure (`frameworkcode`,`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, seealso, link, defaultvalue )
SELECT DISTINCT(frameworkcode), '099', 'c', 'date creation notice (koha)', '', 0, 0, 'biblio.datecreated', -1, '', '', '', NULL, 0, '', '', NULL from biblio_framework;
ENDOFSQL1
    $dbh->do(<<ENDOFSQL2);
INSERT IGNORE INTO marc_subfield_structure (`frameworkcode`,`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, seealso, link, defaultvalue )
SELECT DISTINCT(frameworkcode), '099', 'd', 'date modification notice (koha)', '', 0, 0, 'biblio.timestamp', -1, '', '', '', NULL, 0, '', '', NULL from biblio_framework;
ENDOFSQL2
    $dbh->do(<<ENDOFSQL3);
INSERT IGNORE INTO marc_subfield_structure (`frameworkcode`,`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, seealso, link, defaultvalue )
SELECT DISTINCT(frameworkcode), '995', '2', 'Perdu', '', 0, 0, 'items.itemlost', 10, '', '', '', NULL, 1, '', NULL, NULL from biblio_framework;
ENDOFSQL3
      print "Upgrade to $DBversion done (updates MARC framework structure)\n";
    }
    SetVersion ($DBversion);
}

$DBversion = "3.00.01.005";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
   $dbh->do(<<ENDOFNOTFORLOANOVERRIDE);
INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('AllowNotForLoanOverride', '0', 'if ON, enables the librarian to choose when they want to check out a notForLoan regular item',NULL,'YesNo')
ENDOFNOTFORLOANOVERRIDE
      print "Upgrade to $DBversion done (Adding AllowNotForLoanOverride System preference)\n";
}

$DBversion = "3.00.01.005";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE issuingrules ADD COLUMN `finedays` int(11) default NULL AFTER `fine`");
    print "Upgrade to $DBversion done (Adding a field in issuingrules table)\n";
    SetVersion ($DBversion);
}

=item DropAllForeignKeys($table)

  Drop all foreign keys of the table $table

=cut

sub DropAllForeignKeys {
    my ($table) = @_;
    # get the table description
    my $sth = $dbh->prepare("SHOW CREATE TABLE $table");
    $sth->execute;
    my $vsc_structure = $sth->fetchrow;
    # split on CONSTRAINT keyword
    my @fks = split /CONSTRAINT /,$vsc_structure;
    # parse each entry
    foreach (@fks) {
        # isolate what is before FOREIGN KEY, if there is something, it's a foreign key to drop
        $_ = /(.*) FOREIGN KEY.*/;
        my $id = $1;
        if ($id) {
            # we have found 1 foreign, drop it
            $dbh->do("ALTER TABLE $table DROP FOREIGN KEY $id");
            $id="";
        }
    }
}


=item TransformToNum

  Transform the Koha version from a 4 parts string
  to a number, with just 1 .

=cut

sub TransformToNum {
    my $version = shift;
    # remove the 3 last . to have a Perl number
    $version =~ s/(.*\..*)\.(.*)\.(.*)/$1$2$3/;
    return $version;
}

=item SetVersion

    set the DBversion in the systempreferences

=cut

sub SetVersion {
    my $kohaversion = TransformToNum(shift);
    if (C4::Context->preference('Version')) {
      my $finish=$dbh->prepare("UPDATE systempreferences SET value=? WHERE variable='Version'");
      $finish->execute($kohaversion);
    } else {
      my $finish=$dbh->prepare("INSERT into systempreferences (variable,value,explanation) values ('Version',?,'The Koha database version. WARNING: Do not change this value manually, it is maintained by the webinstaller')");
      $finish->execute($kohaversion);
    }
}
exit;

