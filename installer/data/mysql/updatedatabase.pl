#!/usr/bin/perl

# Database Updater
# This script checks for required updates to the database.

# Parts copyright Catalyst IT 2011

# Part of the Koha Library Software www.koha-community.org
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.
#

# Bugs/ToDo:
# - Would also be a good idea to offer to do a backup at this time...

# NOTE:  If you do something more than once in here, make it table driven.

# NOTE: Please keep the version in kohaversion.pl up-to-date!

use strict;
use warnings;

use feature 'say';

# CPAN modules
use DBI;
use Getopt::Long;
# Koha modules
use C4::Context;
use C4::Installer;
use Koha::Database;
use Koha;
use Koha::DateUtils;

use MARC::Record;
use MARC::File::XML ( BinaryEncoding => 'utf8' );

use File::Path qw[remove_tree]; # perl core module
use File::Spec;
use File::Slurp;

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

my $schema = Koha::Database->new()->schema();

my $silent;
GetOptions(
    's' =>\$silent
    );
my $dbh = C4::Context->dbh;
$|=1; # flushes output

local $dbh->{RaiseError} = 0;

# Record the version we are coming from

my $original_version = C4::Context->preference("Version");
my $DBversion;



$DBversion = "3.15.00.023";
if ( CheckVersion($DBversion) ) {
   $dbh->do("
       INSERT INTO systempreferences (variable,value,options,explanation,type)
       VALUES('CardnumberLength', '', '', 'Set a length for card numbers.', 'Free');
    ");
   print "Upgrade to $DBversion done (Bug 10861: Add CardnumberLength syspref)\n";
   SetVersion ($DBversion);
}

$DBversion = "3.15.00.024";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        DELETE FROM systempreferences WHERE variable = 'NoZebraIndexes'
    });
    print "Upgrade to $DBversion done (Bug 10012 - remove last vestiges of NoZebra)\n";
    SetVersion($DBversion);
}

$DBversion = "3.15.00.025";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        DROP TABLE aqorderdelivery;
    });
    print "Upgrade to $DBversion done (Bug 11928 - remove unused table)\n";
    SetVersion($DBversion);
}

$DBversion = "3.15.00.026";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        UPDATE language_descriptions SET description = 'Հայերեն' WHERE subtag = 'hy' AND lang = 'hy';
    });
    print "Upgrade to $DBversion done (Bug 11973 - Fix Armenian language description)\n";
    SetVersion($DBversion);
}

$DBversion = "3.15.00.027";
if (CheckVersion($DBversion)) {
    $dbh->do(q{
        ALTER TABLE opac_news ADD branchcode varchar(10) DEFAULT NULL
                                  AFTER idnew,
                              ADD CONSTRAINT opac_news_branchcode_ibfk
                                  FOREIGN KEY (branchcode)
                                  REFERENCES branches (branchcode)
                                  ON DELETE CASCADE ON UPDATE CASCADE;
    });
    print "Upgrade to $DBversion done (Bug 7567: Add branchcode to opac_news)\n";
    SetVersion($DBversion);
}

$DBversion = "3.15.00.028";
if(CheckVersion($DBversion)) {
    $dbh->do(q{
        ALTER TABLE issuingrules ADD norenewalbefore int(4) default NULL AFTER renewalperiod
    });
    print "Upgrade to $DBversion done (Bug 7413: Allow OPAC renewal x days before due date)\n";
    SetVersion($DBversion);
}

$DBversion = "3.15.00.029";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        UPDATE borrower_debarments SET expiration = NULL WHERE expiration = '9999-12-31'
    });
    print "Upgrade to $DBversion done (Bug 11846 - correct borrower_debarments with expiration 9999-12-31)\n";
    SetVersion($DBversion);
}

$DBversion = "3.15.00.030";
if(CheckVersion($DBversion)) {
    $dbh->do(q|
        INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES ('OPACMySummaryNote','','','Note to display on the patron summary page. This note only appears if the patron is connected.','Free')
    |);
    print "Upgrade to $DBversion done (Bug 12052: Add OPACMySummaryNote syspref)\n";
    SetVersion($DBversion);
}

$DBversion = "3.15.00.031";
if ( CheckVersion($DBversion) ) {
   $dbh->do("INSERT INTO permissions (module_bit, code, description) VALUES ('10', 'writeoff', 'Write off fines and fees')");
   $dbh->do("INSERT INTO permissions (module_bit, code, description) VALUES ('10', 'remaining_permissions', 'Remaining permissions for managing fines and fees')");
   print "Upgrade to $DBversion done (Bug 9448 - Add separate permission for writing off fees)\n";
   SetVersion ($DBversion);
}

$DBversion = "3.15.00.032";
if ( CheckVersion($DBversion) ) {
    $dbh->do("ALTER TABLE aqorders CHANGE notes order_internalnote MEDIUMTEXT;");
    $dbh->do("ALTER TABLE aqorders ADD COLUMN order_vendornote MEDIUMTEXT AFTER order_internalnote;");
    print "Upgrade to $DBversion done (Bug 9416 - In each order, add a new note made for the vendor)\n";
   SetVersion ($DBversion);
}

$DBversion = "3.15.00.033";
if ( CheckVersion($DBversion) ) {
    $dbh->do("INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('NoLoginInstructions', '', '60|10', 'Instructions to display on the OPAC login form when a patron is not logged in', 'Textarea')");
    print "Upgrade to $DBversion done (Bug 10951: Add NoLoginInstructions pref)\n";
    SetVersion($DBversion);
}

$DBversion = "3.15.00.034";
if ( CheckVersion($DBversion) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type) VALUES('AdvancedSearchLanguages','','','ISO 639-2 codes of languages you wish to see appear as an advanced search option.  Example: eng|fra|ita','Textarea')");
    print "Upgrade to $DBversion done (Bug 10986: system preferences to limit languages in advanced search )\n";
    SetVersion ($DBversion);
}

$DBversion = "3.15.00.035";
if ( CheckVersion($DBversion) ) {
    #insert a notice for sharing a list and accepting a share
    $dbh->do("
INSERT INTO letter (module, code, branchcode, name, is_html, title, content)
VALUES ( 'members', 'SHARE_INVITE', '', 'Invitation for sharing a list', '0', 'Share list <<listname>>', 'Dear patron,

One of our patrons, <<borrowers.firstname>> <<borrowers.surname>>, invites you to share a list <<listname>> in our library catalog.

To access this shared list, please click on the following URL or copy-and-paste it into your browser address bar.

<<shareurl>>

In case you are not a patron in our library or do not want to accept this invitation, please ignore this mail. Note also that this invitation expires within two weeks.

Thank you.

Your library.'
    )");
    $dbh->do("
INSERT INTO letter (module, code, branchcode, name, is_html, title, content)
VALUES ( 'members', 'SHARE_ACCEPT', '', 'Notification about an accepted share', '0', 'Share on list <<listname>> accepted', 'Dear patron,

We want to inform you that <<borrowers.firstname>> <<borrowers.surname>> accepted your invitation to share your list <<listname>> in our library catalog.

Thank you.

Your library.'
    )");
    print "Upgrade to $DBversion done (Bug 9032: Share a list)\n";
    SetVersion($DBversion);
}

$DBversion = "3.15.00.036";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
        VALUES('AllowMultipleIssuesOnABiblio',1,'Allow/Don\'t allow patrons to check out multiple items from one biblio','','YesNo')
    });

    print "Upgrade to $DBversion done (Bug 10859 - Add system preference AllowMultipleIssuesOnABiblio)\n";
    SetVersion($DBversion);
}

$DBversion = "3.15.00.037";
if(CheckVersion($DBversion)) {
    $dbh->do(q{
        ALTER TABLE itemtypes ADD sip_media_type VARCHAR( 3 ) DEFAULT NULL AFTER checkinmsgtype
    });
    $dbh->do(q{
        INSERT INTO authorised_values (category, authorised_value, lib) VALUES
         ('SIP_MEDIA_TYPE', '000', 'Other'),
         ('SIP_MEDIA_TYPE', '001', 'Book'),
         ('SIP_MEDIA_TYPE', '002', 'Magazine'),
         ('SIP_MEDIA_TYPE', '003', 'Bound journal'),
         ('SIP_MEDIA_TYPE', '004', 'Audio tape'),
         ('SIP_MEDIA_TYPE', '005', 'Video tape'),
         ('SIP_MEDIA_TYPE', '006', 'CD/CDROM'),
         ('SIP_MEDIA_TYPE', '007', 'Diskette'),
         ('SIP_MEDIA_TYPE', '008', 'Book with diskette'),
         ('SIP_MEDIA_TYPE', '009', 'Book with CD'),
         ('SIP_MEDIA_TYPE', '010', 'Book with audio tape')
    });
    print "Upgrade to $DBversion done (Bug 11351 - Add support for SIP2 media type)\n";
    SetVersion($DBversion);
}

$DBversion = '3.15.00.038';
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT INTO  systempreferences (
            variable,
            value,
            options,
            explanation,
            type
            )
        VALUES (
            'DisplayLibraryFacets',  'holding',  'home|holding|both',  'Defines which library facets to display.',  'Choice'
        );
    });
    print "Upgrade to $DBversion done (Bug 11334 - Add facet for home library)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.15.00.039";
if ( CheckVersion($DBversion) ) {

    $dbh->do( q{
        ALTER TABLE letter ADD COLUMN message_transport_type VARCHAR(20) NOT NULL DEFAULT 'email' AFTER content
    } );

    $dbh->do( q{
        ALTER TABLE letter ADD CONSTRAINT message_transport_type_fk FOREIGN KEY (message_transport_type) REFERENCES message_transport_types(message_transport_type);
    } );

    $dbh->do( q{
        ALTER TABLE letter DROP PRIMARY KEY, ADD PRIMARY KEY (`module`,`code`,`branchcode`, message_transport_type);
    } );

    $dbh->do( q{
        CREATE TABLE overduerules_transport_types(
            id INT(11) NOT NULL AUTO_INCREMENT,
            branchcode varchar(10) NOT NULL DEFAULT '',
            categorycode VARCHAR(10) NOT NULL DEFAULT '',
            letternumber INT(1) NOT NULL DEFAULT 1,
            message_transport_type VARCHAR(20) NOT NULL DEFAULT 'email',
            PRIMARY KEY (id),
            CONSTRAINT overduerules_fk FOREIGN KEY (branchcode, categorycode) REFERENCES overduerules (branchcode, categorycode) ON DELETE CASCADE ON UPDATE CASCADE,
            CONSTRAINT mtt_fk FOREIGN KEY (message_transport_type) REFERENCES message_transport_types (message_transport_type) ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    } );

    my $sth = $dbh->prepare( q{
        SELECT * FROM overduerules;
    } );

    $sth->execute;
    my $sth_insert_mtt = $dbh->prepare( q{
        INSERT INTO overduerules_transport_types (branchcode, categorycode, letternumber, message_transport_type) VALUES ( ?, ?, ?, ? )
    } );
    while ( my $row = $sth->fetchrow_hashref ) {
        my $branchcode = $row->{branchcode};
        my $categorycode = $row->{categorycode};
        for my $letternumber ( 1 .. 3 ) {
            next unless $row->{"letter$letternumber"};
            $sth_insert_mtt->execute(
                $branchcode, $categorycode, $letternumber, 'email'
            );
        }
    }

    print "Upgrade done (Bug 9016: Adds multi transport types management for notices)\n";
    SetVersion($DBversion);
}

$DBversion = "3.15.00.040";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        UPDATE message_transports SET letter_code='HOLD' WHERE letter_code='HOLD_PHONE' OR letter_code='HOLD_PRINT'
    |);
    $dbh->do(q|
        UPDATE letter SET code='HOLD', message_transport_type='print' WHERE code='HOLD_PRINT'
    |);
    $dbh->do(q|
        UPDATE letter SET code='HOLD', message_transport_type='phone' WHERE code='HOLD_PHONE'
    |);
    print "Upgrade to $DBversion done (Bug 10845: Multi transport types for holds)\n";
    SetVersion($DBversion);
}

$DBversion = "3.15.00.041";
if ( CheckVersion($DBversion) ) {
    my ( $name ) = $dbh->selectrow_array(q|
        SELECT name FROM letter WHERE code="HOLD"
    |);
    $dbh->do(q|
        UPDATE letter
        SET code="HOLD",
            message_transport_type="phone",
            name= ?
        WHERE code="HOLD_PHONE"
    |, {}, $name);

    ( $name ) = $dbh->selectrow_array(q|
        SELECT name FROM letter WHERE code="PREDUE"
    |);
    $dbh->do(q|
        UPDATE letter
        SET code="PREDUE",
            message_transport_type="phone",
            name= ?
        WHERE code="PREDUE_PHONE"
    |, {}, $name);

    ( $name ) = $dbh->selectrow_array(q|
        SELECT name FROM letter WHERE code="OVERDUE"
    |);
    $dbh->do(q|
        UPDATE letter
        SET code="OVERDUE",
            message_transport_type="phone",
            name= ?
        WHERE code="OVERDUE_PHONE"
    |, {}, $name);

    print "Upgrade to $DBversion done (Bug 11867: Update letters *_PHONE)\n";
    SetVersion($DBversion);
}

$DBversion = "3.15.00.042";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT INTO systempreferences
            (variable,value,explanation,options,type)
        VALUES
            ('SpecifyReturnDate',0,'Define whether to display \"Specify Return Date\" form in Circulation','','YesNo')
    });
    print "Upgrade to $DBversion done (Bug 10694 - Allow arbitrary backdating of returns)\n";
    SetVersion($DBversion);
}

$DBversion = "3.15.00.043";
if ( CheckVersion($DBversion) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('MarcFieldsToOrder','','Set the mapping values for a new order line created from a MARC record in a staged file. In a YAML format.', NULL, 'textarea')");
   print "Upgrade to $DBversion done (Bug 7180: Added MarcFieldsToOrder syspref)\n";
   SetVersion ($DBversion);
}

$DBversion = "3.15.00.044";
if ( CheckVersion($DBversion) ) {
    $dbh->do("ALTER TABLE currency ADD isocode VARCHAR(5) default NULL AFTER symbol;");
    print "Upgrade to $DBversion done (Added isocode to the currency table)\n";
    SetVersion($DBversion);
}

$DBversion = "3.15.00.045";
if ( CheckVersion($DBversion) ) {
    $dbh->do("
        INSERT INTO systempreferences (variable,value,explanation,options,type)
        VALUES (
            'BlockExpiredPatronOpacActions',
            '0',
            'Set whether an expired patron can perform opac actions such as placing holds or renew books, can be overridden on a per patron-type basis',
            NULL,
            'YesNo'
        )
    ");
    $dbh->do("ALTER TABLE `categories` ADD COLUMN `BlockExpiredPatronOpacActions` TINYINT(1) DEFAULT -1 NOT NULL AFTER category_type");
    print "Upgraded to $DBversion done (Bug 6739 - expired patrons not blocked from opac actions)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.15.00.046";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        ALTER TABLE search_history ADD COLUMN type VARCHAR(16) NOT NULL DEFAULT 'biblio' AFTER query_cgi
    |);
    print "Upgrade to $DBversion done (Bug 10807 - Add db field search_history.type)\n";
    SetVersion($DBversion);
}

$DBversion = "3.15.00.047";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES ('EnableSearchHistory','0','','Enable or disable search history','YesNo')
    |);
    print "Upgrade to $DBversion done (Bug 10862: Add EnableSearchHistory syspref)\n";
    SetVersion($DBversion);
}

$DBversion = "3.15.00.048";
if ( CheckVersion($DBversion) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('OpacSuppressionRedirect','1','Redirect the opac detail page for suppressed records to an explanatory page (otherwise redirect to 404 error page)','','YesNo')");
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('OpacSuppressionMessage', '','Display this message on the redirect page for suppressed biblios','70|10','Textarea')");
    print "Upgrade to $DBversion done (Bug 10195: Records hidden with OpacSuppression can still be accessed)\n";
    SetVersion($DBversion);
}

$DBversion = "3.15.00.049";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("ALTER TABLE biblioitems DROP INDEX isbn");
    $dbh->do("ALTER TABLE biblioitems DROP INDEX issn");
    $dbh->do("ALTER TABLE biblioitems DROP INDEX issn_idx");
    $dbh->do("ALTER TABLE biblioitems
              CHANGE isbn isbn MEDIUMTEXT NULL DEFAULT NULL,
              CHANGE issn issn MEDIUMTEXT NULL DEFAULT NULL
    ");
    $dbh->do("ALTER TABLE biblioitems
              ADD INDEX isbn ( isbn ( 255 ) ),
              ADD INDEX issn ( issn ( 255 ) )
    ");

    $dbh->do("ALTER TABLE deletedbiblioitems DROP INDEX isbn");
    $dbh->do("ALTER TABLE deletedbiblioitems
              CHANGE isbn isbn MEDIUMTEXT NULL DEFAULT NULL,
              CHANGE issn issn MEDIUMTEXT NULL DEFAULT NULL
    ");
    $dbh->do("ALTER TABLE deletedbiblioitems
              ADD INDEX isbn ( isbn ( 255 ) )
    ");

    print "Upgrade to $DBversion done (Bug 5377 - Biblioitems isbn and issn fields too small for multiple ISBN and ISSN)\n";
    SetVersion($DBversion);
}

$DBversion = "3.15.00.050";
if ( CheckVersion($DBversion) ) {
    $dbh->do("
        INSERT INTO systempreferences (
            variable,
            value,
            explanation,
            type
        ) VALUES (
            'AggressiveMatchOnISBN',
            '0',
            'If enabled, attempt to match aggressively by trying all variations of the ISBNs in the imported record as a phrase in the ISBN fields of already cataloged records when matching on ISBN with the record import tool',
            'YesNo'
        )
    ");

    print "Upgrade to $DBversion done (Bug 10500 - Improve isbn matching when importing records)\n";
    SetVersion($DBversion);
}

$DBversion = "3.15.00.051";
if ( CheckVersion($DBversion) ) {
    print "Upgrade to $DBversion done (Koha 3.16 beta)\n";
    SetVersion($DBversion);
}

$DBversion = "3.15.00.052";
if ( CheckVersion($DBversion) ) {
    print "Upgrade to $DBversion done (Koha 3.16 RC)\n";
    SetVersion($DBversion);
}

$DBversion = "3.16.00.000";
if ( CheckVersion($DBversion) ) {
    print "Upgrade to $DBversion done (3.16.0 release)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.17.00.000';
if ( CheckVersion($DBversion) ) {
    print "Upgrade to $DBversion done (there is no time to rest on our laurels)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.17.00.001';
if ( CheckVersion($DBversion) ) {
   $dbh->do("UPDATE systempreferences SET variable = 'AuthoritySeparator' WHERE variable = 'authoritysep'");
   print "Upgrade to $DBversion done (Bug 10330 - Rename system preference authoritysep to AuthoritySeparator)\n";
   SetVersion ($DBversion);
}

$DBversion = "3.17.00.002";
if (CheckVersion($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,type) VALUES('AcqEnableFiles','0','If enabled, allows librarians to upload and attach arbitrary files to invoice records.','YesNo')");
    $dbh->do("
CREATE TABLE IF NOT EXISTS `misc_files` (
  `file_id` int(11) NOT NULL AUTO_INCREMENT,
  `table_tag` varchar(255) NOT NULL,
  `record_id` int(11) NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_type` varchar(255) NOT NULL,
  `file_description` varchar(255) DEFAULT NULL,
  `file_content` longblob NOT NULL, -- file content
  `date_uploaded` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`file_id`),
  KEY `table_tag` (`table_tag`),
  KEY `record_id` (`record_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    ");
    print "Upgrade to $DBversion done (Bug 3050 - Add an option to upload scanned invoices)\n";
    SetVersion($DBversion);
}

$DBversion = "3.17.00.003";
if (CheckVersion($DBversion)) {
    $dbh->do("UPDATE systempreferences SET type = 'Choice', options = '0|1|force' WHERE variable = 'OPACItemHolds'");
    print "Upgrade to $DBversion done (Bug 7825 - Changed OPACItemHolds syspref to Choice)\n";
    SetVersion($DBversion);
}

$DBversion = "3.17.00.004";
if (CheckVersion($DBversion)) {
    $dbh->do("ALTER TABLE categories ADD default_privacy ENUM( 'default', 'never', 'forever' ) NOT NULL DEFAULT 'default' AFTER category_type");
    print "Upgrade to $DBversion done (Bug 6254 - can't set patron privacy by default)\n";
    SetVersion($DBversion);
}

$DBversion = "3.17.00.005";
if (CheckVersion($DBversion)) {
    $dbh->do(q|
        ALTER TABLE issuingrules
        ADD maxsuspensiondays INT(11) DEFAULT NULL AFTER finedays;
    |);
    print "Upgrade to $DBversion done (Bug 12230: Add new issuing rule maxsuspensiondays)\n";
    SetVersion($DBversion);
}

$DBversion = "3.17.00.006";
if ( CheckVersion($DBversion) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type) VALUES ('OpacLocationBranchToDisplay',  'holding',  'holding|home|both',  'In the OPAC, under location show which branch for Location in the record details.',  'Choice')");
    $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type) VALUES ('OpacLocationBranchToDisplayShelving',  'holding',  'holding|home|both',  'In the OPAC, display the shelving location under which which column',  'Choice')");
    print "Upgrade to $DBversion done (Bug 7720 - Ambiguity in OPAC Details location.)\n";
    SetVersion($DBversion);
}

$DBversion = "3.17.00.007";
if (CheckVersion($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type) VALUES('UpdateNotForLoanStatusOnCheckin', '', 'NULL', 'This is a list of value pairs. When an item is checked in, if the not for loan value on the left matches the items not for loan value it will be updated to the right-hand value. E.g. ''-1: 0'' will cause an item that was set to ''Ordered'' to now be available for loan. Each pair of values should be on a separate line.', 'Free');");
    print "Upgrade to $DBversion done (Bug 11629 - Add ability to update not for loan status on checkin)\n";
    SetVersion($DBversion);
}

$DBversion = "3.17.00.008";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES('OPACAcquisitionDetails','0', '','Show the acquisition details at the OPAC','YesNo')
    |);
    print "Upgrade to $DBversion done (Bug 11169 - Add OPACAcquisitionDetails syspref)\n";
    SetVersion($DBversion);
}

$DBversion = "3.17.00.009";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        DELETE FROM systempreferences WHERE variable = 'UseTablesortForCirc'
    });

    print "Upgrade to $DBversion done (Bug 11703 - Remove UseTablesortForCirc syspref)\n";
    SetVersion($DBversion);
}

$DBversion = "3.17.00.010";
if ( CheckVersion($DBversion) ) {
    $dbh->do("DELETE FROM systempreferences WHERE variable='opacsmallimage'");
    print "Upgrade to $DBversion done (Bug 11347 - PROG/CCSR deprecation: Remove opacsmallimage system preference)\n";
    SetVersion($DBversion);
}

$DBversion = "3.17.00.011";
if ( CheckVersion($DBversion) ) {
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'hr', 'language', 'Croatian','2014-07-24' )");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES( 'hr','hrv')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES( 'hr', 'language', 'hr', 'Hrvatski')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES( 'hr', 'language', 'en', 'Croatian')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES( 'hr', 'language', 'fr', 'Croate')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES( 'hr', 'language', 'de', 'Kroatisch')");
    print "Upgrade to $DBversion done (Bug 12649: Add Croatian language)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.17.00.012";
if ( CheckVersion($DBversion) ) {
    $dbh->do("DELETE FROM systempreferences WHERE variable='OpacShowFiltersPulldownMobile'");
    print "Upgrade to $DBversion done ( Bug 12512 - PROG/CCSR deprecation: Remove OpacShowFiltersPulldownMobile system preference )\n";
    SetVersion ($DBversion);
}

$DBversion = "3.17.00.013";
if ( CheckVersion($DBversion) ) {
    $dbh->do("INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES ('maxreserves',50,'System-wide maximum number of holds a patron can place','','Integer')");
    print "Upgrade to $DBversion done (Re-add system preference maxreserves)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.17.00.014';
if ( CheckVersion($DBversion) ) {
    $dbh->do("
        INSERT INTO systempreferences (variable,value,explanation,type) VALUES
        ('OverdueNoticeCalendar',0,'Take calendar into consideration when working out sending overdue notices','YesNo')
    ");
    print "Upgrade to $DBversion done (Bug 12529 - Adding a syspref to allow the overdue notices to consider the calendar when generating notices)\n";
    SetVersion($DBversion);
}

$DBversion = "3.17.00.015";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        CREATE TABLE IF NOT EXISTS columns_settings (
            module varchar(255) NOT NULL,
            page varchar(255) NOT NULL,
            tablename varchar(255) NOT NULL,
            columnname varchar(255) NOT NULL,
            cannot_be_toggled int(1) NOT NULL DEFAULT 0,
            is_hidden int(1) NOT NULL DEFAULT 0,
            PRIMARY KEY(module, page, tablename, columnname)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8
    });
    print "Upgrade to $DBversion done (Bug 10212 - Create new table columns_settings)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.17.00.016";
if ( CheckVersion($DBversion) ) {
    $dbh->do("CREATE TABLE aqcontacts (
        id int(11) NOT NULL auto_increment,
        name varchar(100) default NULL,
        position varchar(100) default NULL,
        phone varchar(100) default NULL,
        altphone varchar(100) default NULL,
        fax varchar(100) default NULL,
        email varchar(100) default NULL,
        notes mediumtext,
        claimacquisition BOOLEAN NOT NULL DEFAULT 0,
        claimissues BOOLEAN NOT NULL DEFAULT 0,
        acqprimary BOOLEAN NOT NULL DEFAULT 0,
        serialsprimary BOOLEAN NOT NULL DEFAULT 0,
        booksellerid int(11) not NULL,
        PRIMARY KEY  (id),
        CONSTRAINT booksellerid_aqcontacts_fk FOREIGN KEY (booksellerid)
            REFERENCES aqbooksellers (id) ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1;");
    $dbh->do("INSERT INTO aqcontacts (name, position, phone, altphone, fax,
            email, notes, booksellerid, claimacquisition, claimissues, acqprimary, serialsprimary)
        SELECT contact, contpos, contphone, contaltphone, contfax, contemail,
            contnotes, id, 1, 1, 1, 1 FROM aqbooksellers;");
    $dbh->do("ALTER TABLE aqbooksellers DROP COLUMN contact,
        DROP COLUMN contpos, DROP COLUMN contphone,
        DROP COLUMN contaltphone, DROP COLUMN contfax,
        DROP COLUMN contemail, DROP COLUMN contnotes;");
    $dbh->do("UPDATE letter SET content = replace(content, '<<aqbooksellers.contact>>', '<<aqcontacts.name>>')");
    $dbh->do("UPDATE letter SET content = replace(content, '<<aqbooksellers.contpos>>', '<<aqcontacts.position>>')");
    $dbh->do("UPDATE letter SET content = replace(content, '<<aqbooksellers.contphone>>', '<<aqcontacts.phone>>')");
    $dbh->do("UPDATE letter SET content = replace(content, '<<aqbooksellers.contaltphone>>', '<<aqcontacts.altphone>>')");
    $dbh->do("UPDATE letter SET content = replace(content, '<<aqbooksellers.contfax>>', '<<aqcontacts.contfax>>')");
    $dbh->do("UPDATE letter SET content = replace(content, '<<aqbooksellers.contemail>>', '<<aqcontacts.contemail>>')");
    $dbh->do("UPDATE letter SET content = replace(content, '<<aqbooksellers.contnotes>>', '<<aqcontacts.contnotes>>')");
    print "Upgrade to $DBversion done (Bug 10402: Move bookseller contacts to separate table)\n";
    SetVersion($DBversion);
}

$DBversion = "3.17.00.017";
if ( CheckVersion($DBversion) ) {
    # Correct invalid recordtypes (should be very exceptional)
    $dbh->do(q{
        UPDATE z3950servers set recordtype='biblio' WHERE recordtype NOT IN ('authority','biblio')
    });
    # Correct invalid server types (should also be very exceptional)
    $dbh->do(q{
        UPDATE z3950servers set type='zed' WHERE type <> 'zed'
    });
    # Adjust table
    $dbh->do(q{
        ALTER TABLE z3950servers
        DROP COLUMN icon,
        DROP COLUMN description,
        DROP COLUMN position,
        MODIFY COLUMN id int NOT NULL AUTO_INCREMENT FIRST,
        MODIFY COLUMN recordtype enum('authority','biblio') NOT NULL DEFAULT 'biblio',
        CHANGE COLUMN name servername mediumtext NOT NULL,
        CHANGE COLUMN type servertype enum('zed','sru') NOT NULL DEFAULT 'zed',
        ADD COLUMN sru_options varchar(255) default NULL,
        ADD COLUMN sru_fields mediumtext default NULL,
        ADD COLUMN add_xslt mediumtext default NULL
    });
    print "Upgrade to $DBversion done (Bug 6536: Z3950 improvements)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.17.00.018";
if ( CheckVersion($DBversion) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('HoldsInNoissuesCharge', '0', 'Hold charges block checkouts (added to noissuescharge).',NULL,'YesNo');");
    print "Upgrade to $DBversion done (Bug 12205: Add HoldsInNoissuesCharge systempreference)\n";
    SetVersion($DBversion);
}

$DBversion = "3.17.00.019";
if ( CheckVersion($DBversion) ) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('NotHighlightedWords','and|or|not',NULL,'List of words to NOT highlight when OpacHighlightedWords is enabled','free')"
    );
    print "Upgrade to $DBversion done (Bug 6149: Operator highlighted in search results)\n";
    SetVersion($DBversion);
}

$DBversion = "3.17.00.020";
if(C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type) VALUES ('ExpireReservesOnHolidays', '1', NULL, 'If false, reserves at a library will not be canceled on days the library is not open.', 'YesNo')");
    print "Upgrade to $DBversion done (Bug 8735 - Expire holds waiting only on days the library is open)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.17.00.021";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    my $pref = C4::Context->preference('HomeOrHoldingBranch');
    $dbh->do("INSERT INTO `systempreferences` (variable,value,options,explanation,type)
       VALUES ('StaffSearchResultsDisplayBranch', ?,'homebranch|holdingbranch','Controls the display of the home or holding branch for staff search results','choice')", undef, $pref);
    print "Upgrade to $DBversion done (Bug 12582 - Control of branch displayed in search results linked to HomeOrHoldingBranch)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.17.00.022';
if ( CheckVersion($DBversion) ) {
    my @temp= $dbh->selectrow_array(qq|
        SELECT count(*)
        FROM marc_subfield_structure
        WHERE kohafield='permanent_location' OR kohafield='items.permanent_location'
    |);
    print "Upgrade to $DBversion done (Bug 7817: Check for permanent_location)\n";
    if( $temp[0] ) {
        print "WARNING for Koha administrator: Your database contains one or more mappings for permanent_location to the MARC structure. This item field however is for internal use and should not be linked to a MARC (sub)field. Please correct it. See also Bugzilla reports 7817 and 12818.\n";
    }
    SetVersion($DBversion);
}

$DBversion = "3.17.00.023";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES('AcqItemSetSubfieldsWhenReceiptIsCancelled','', '','Upon cancelling a receipt, update the items subfields if they were created when placing an order (e.g. o=5|a="bar foo")', 'Free')
    });
    print "Upgrade to $DBversion done (Bug 11169 - Add AcqItemSetSubfieldsWhenReceiptIsCancelled syspref)\n";
    SetVersion($DBversion);
}

$DBversion = "3.17.00.024";
if(CheckVersion($DBversion)) {
    $dbh->do(q{
        ALTER TABLE issues ADD auto_renew BOOLEAN default FALSE AFTER renewals
    });
    $dbh->do(q{
        ALTER TABLE old_issues ADD auto_renew BOOLEAN default FALSE AFTER renewals
    });
    $dbh->do(q{
        ALTER TABLE issuingrules ADD auto_renew BOOLEAN default FALSE AFTER norenewalbefore
    });
    print "Upgrade to $DBversion done (Bug 11577: [ENH] Automatic renewal feature)\n";
    SetVersion($DBversion);
}

$DBversion = '3.17.00.025';
if ( CheckVersion($DBversion) ) {
    $dbh->do(qq{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES('StatisticsFields','location|itype|ccode','Define fields (from the items table) used for statistics members',NULL,'Free')
    });
    print "Upgrade to $DBversion done (Bug 12728: Checked syspref StatisticsFields)\n";
}

$DBversion = "3.17.00.026";
if ( CheckVersion($DBversion) ) {
    if ( C4::Context->preference('marcflavour') eq 'MARC21' ) {
        $dbh->do("UPDATE marc_subfield_structure SET liblibrarian = 'Encoded bitrate', libopac = 'Encoded bitrate' WHERE tagfield = '347' AND tagsubfield = 'f'");
        $dbh->do("UPDATE marc_subfield_structure SET repeatable = 1 WHERE tagfield IN ('110','111','610','611','710','711','810','811') AND tagsubfield = 'c'");
        $dbh->do("UPDATE auth_subfield_structure SET repeatable = 1 WHERE tagfield IN ('110','111','410','411','510','511','710','711') AND tagsubfield = 'c'");
        print "Upgrade to $DBversion done (Bug 12435 - Update MARC21 frameworks to Update No. 18 (April 2014))\n";
    }
    SetVersion($DBversion);
}

$DBversion = "3.17.00.027";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        DELETE FROM systempreferences WHERE variable = 'SearchEngine'
    });
    print "Upgrade to $DBversion done (Bug 12538 - Remove SearchEngine syspref)\n";
    SetVersion($DBversion);
}

$DBversion = "3.17.00.028";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT INTO systempreferences (variable,value) VALUES('OpacCustomSearch','');
    });
    print "Upgrade to $DBversion done (Bug 12296 - search box replaceable with a system preference)\n";
    SetVersion($DBversion);
}

$DBversion = "3.17.00.029";
if ( CheckVersion($DBversion) ) {
    $dbh->do("ALTER TABLE  `items` CHANGE  `cn_sort`  `cn_sort` VARCHAR( 255 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL");
    $dbh->do("ALTER TABLE  `deleteditems` CHANGE  `cn_sort`  `cn_sort` VARCHAR( 255 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL");
    $dbh->do("ALTER TABLE  `biblioitems` CHANGE  `cn_sort`  `cn_sort` VARCHAR( 255 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL");
    $dbh->do("ALTER TABLE  `deletedbiblioitems` CHANGE  `cn_sort`  `cn_sort` VARCHAR( 255 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL");
    print "Upgrade to $DBversion done (Bug 12424 - ddc sorting of call numbers truncates long Cutter parts)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.17.00.030";
if ( CheckVersion($DBversion) ) {
    $dbh->do(
        q{
       INSERT INTO systempreferences (variable, value, options, explanation, type )
       VALUES
        ('UsageStatsCountry', '', NULL, 'The country where your library is located, to be shown on the Hea Koha community website', 'YesNo'),
        ('UsageStatsID', '', NULL, 'This preference is part of Koha but it should not be deleted or updated manually.',  'Free'),
        ('UsageStatsLastUpdateTime', '', NULL, 'This preference is part of Koha but it should not be deleted or updated manually.', 'Free'),
        ('UsageStatsLibraryName', '', NULL, 'The library name to be shown on Hea Koha community website', 'Free'),
        ('UsageStatsLibraryType', 'public', 'public|university', 'The library type to be shown on the Hea Koha community website', 'Choice'),
        ('UsageStatsLibraryUrl', '', NULL, 'The library URL to be shown on Hea Koha community website', 'Free'),
        ('UsageStats', 0, NULL, 'Share anonymous usage data on the Hea Koha community website.', 'YesNo')
    });
    print "Upgrade to $DBversion done (Bug 11926: Add UsageStats systempreferences (HEA))\n";
    SetVersion ($DBversion);
}

$DBversion = "3.17.00.031";
if ( CheckVersion($DBversion) ) {
   $dbh->do("ALTER TABLE saved_sql CHANGE report_name report_name VARCHAR( 255 ) NOT NULL DEFAULT '' ");
   print "Upgrade to $DBversion done (Bug 2969: Report Name should be mandatory for saved reports)\n";
   SetVersion ($DBversion);
}

$DBversion = "3.17.00.032";
if ( CheckVersion($DBversion) ) {
    $dbh->do(
"INSERT INTO systempreferences (variable,value,options,explanation,type) VALUES ('ReplytoDefault',  '',  NULL,  'The default email address to be set as replyto.',  'Free')"
    );
    $dbh->do(
"INSERT INTO systempreferences (variable,value,options,explanation,type) VALUES ('ReturnpathDefault',  '',  NULL,  'The default email address to be set as return-path',  'Free')"
    );
    $dbh->do("ALTER TABLE branches ADD branchreplyto mediumtext AFTER branchemail");
    $dbh->do("ALTER TABLE branches ADD branchreturnpath mediumtext AFTER branchreplyto");
    print "Upgrade to $DBversion done (Bug 9530: Adding replyto and returnpath addresses.)\n";
    SetVersion($DBversion);
}

$DBversion = "3.17.00.033";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable, value, explanation, options, type)
        VALUES('FacetMaxCount', '20','Specify the max facet count for each category',NULL,'Integer')
    });
    print "Upgrade to $DBversion done (Bug 13088 - Allow the user to specify a max amount of facets to show)\n";
    SetVersion($DBversion);
}

$DBversion = "3.17.00.034";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        ALTER TABLE aqorders DROP COLUMN cancelledby;
    |);

    print "Upgrade to $DBversion done (Bug 11007 - DROP column aqorders.cancelledby)\n";
    SetVersion($DBversion);
}

$DBversion = "3.17.00.035";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        ALTER TABLE serial ADD COLUMN claims_count INT(11) DEFAULT 0 after claimdate
    |);
    $dbh->do(q|
        UPDATE serial
        SET claims_count = 1
        WHERE claimdate IS NOT NULL
    |);
    print "Upgrade to $DBversion done (Bug 5342: Add claims_count field in serial table)\n";
    SetVersion($DBversion);
}

$DBversion = "3.17.00.036";
if ( CheckVersion($DBversion) ) {
    $dbh->do("DELETE FROM systempreferences WHERE variable='OpacShowLibrariesPulldownMobile'");
    print "Upgrade to $DBversion done ( Bug 12513 - PROG/CCSR deprecation: Remove OpacShowLibrariesPulldownMobile system preference )\n";
    SetVersion ($DBversion);
}

$DBversion = "3.17.00.037";
if ( CheckVersion($DBversion) ) {
    $dbh->do("DELETE FROM systempreferences WHERE variable='OpacMainUserBlockMobile'");
    print "Upgrade to $DBversion done ( Bug 12246 - PROG/CCSR deprecation: Remove OpacMainUserBlockMobile system preference )\n";
    SetVersion ($DBversion);
}

$DBversion = "3.17.00.038";
if ( CheckVersion($DBversion) ) {
    $dbh->do("DELETE FROM systempreferences WHERE variable='OPACMobileUserCSS'");
    print "Upgrade to $DBversion done ( Bug 12245 - PROG/CCSR deprecation: Remove OPACMobileUserCSS system preference )\n";
    SetVersion ($DBversion);
}

$DBversion = "3.17.00.039";
if ( CheckVersion($DBversion) ) {
    $dbh->do("INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type) VALUES
    ('OPACFallback', 'prog', 'bootstrap|prog', 'Define the fallback theme for the OPAC interface.', 'Themes')");
    print "Upgrade to $DBversion done (Bug 12539 - PROG/CCSR deprecation: Remove hardcoded theme from C4/Templates.pm)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.17.00.040";
if ( CheckVersion($DBversion) ) {
    my $opac_theme = C4::Context->preference( 'opacthemes' );
    if ( !defined $opac_theme || $opac_theme eq 'prog' || $opac_theme eq 'ccsr' ) {
        $dbh->do("UPDATE systempreferences SET value='bootstrap' WHERE variable='opacthemes'");
    }
    print "Upgrade to $DBversion done (Bug 12223: 'prog' and 'ccsr' themes removed)\n";
    SetVersion($DBversion);
}

$DBversion = "3.17.00.041";
if ( CheckVersion($DBversion) ) {
    print "Upgrade to $DBversion done (Bug 11346: Deprecate the 'prog' and 'CCSR' themes)\n";
    SetVersion($DBversion);
}

$DBversion = "3.17.00.042";
if ( CheckVersion($DBversion) ) {
    $dbh->do("DELETE FROM systempreferences WHERE variable='yuipath'");
    print "Upgrade to $DBversion done (Bug 12494: Remove yuipath system preference)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.17.00.043";
if ( CheckVersion($DBversion) ) {
    $dbh->do("
        ALTER TABLE aqorders
        ADD COLUMN cancellationreason TEXT DEFAULT NULL AFTER datecancellationprinted
    ");
    print "Upgrade to $DBversion done (Bug 7162: Add aqorders.cancellationreason)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.17.00.044";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences
            (variable,value,explanation,options,type)
            VALUES('OnSiteCheckouts','0','Enable/Disable the on-site checkouts feature','','YesNo');
    });
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences
            (variable,value,explanation,options,type)
            VALUES('OnSiteCheckoutsForce','0','Enable/Disable the on-site for all cases (Even if a user is debarred, etc.)','','YesNo');
    });
    $dbh->do(q{
        ALTER TABLE issues ADD COLUMN onsite_checkout INT(1) NOT NULL DEFAULT 0 AFTER issuedate;
    });
    $dbh->do(q{
        ALTER TABLE old_issues ADD COLUMN onsite_checkout INT(1) NOT NULL DEFAULT 0 AFTER issuedate;
    });
    print "Upgrade to $DBversion done (Bug 10860: Add new system preference OnSiteCheckouts + fields [old_]issues.onsite_checkout)\n";
    SetVersion($DBversion);
}

$DBversion = "3.17.00.045";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT INTO systempreferences ( variable, value, options, explanation, type ) VALUES
        ('LocalHoldsPriority',  '0', NULL,  'Enables the LocalHoldsPriority feature',  'YesNo'),
        ('LocalHoldsPriorityItemControl',  'holdingbranch',  'holdingbranch|homebranch',  'decides if the feature operates using the item''s home or holding library.',  'Choice'),
        ('LocalHoldsPriorityPatronControl',  'PickupLibrary',  'HomeLibrary|PickupLibrary',  'decides if the feature operates using the library set as the patron''s home library, or the library set as the pickup library for the given hold.',  'Choice')
    });
    print "Upgrade to $DBversion done (Bug 11126 - Make the holds system optionally give precedence to local holds)\n";
    SetVersion($DBversion);
}

$DBversion = "3.17.00.046";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        CREATE TABLE IF NOT EXISTS items_search_fields (
          name VARCHAR(255) NOT NULL,
          label VARCHAR(255) NOT NULL,
          tagfield CHAR(3) NOT NULL,
          tagsubfield CHAR(1) NULL DEFAULT NULL,
          authorised_values_category VARCHAR(16) NULL DEFAULT NULL,
          PRIMARY KEY(name),
          CONSTRAINT items_search_fields_authorised_values_category
            FOREIGN KEY (authorised_values_category) REFERENCES authorised_values (category)
            ON DELETE SET NULL ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    });
    print "Upgrade to $DBversion done (Bug 11425: Add items_search_fields table)\n";
    SetVersion($DBversion);
}

$DBversion = "3.17.00.047";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        ALTER TABLE collections
            CHANGE colBranchcode colBranchcode VARCHAR( 10 ) NULL DEFAULT NULL,
            ADD INDEX ( colBranchcode ),
            ADD CONSTRAINT collections_ibfk_1 FOREIGN KEY (colBranchcode) REFERENCES branches (branchcode) ON DELETE CASCADE ON UPDATE CASCADE
    });
    print "Upgrade to $DBversion done (Bug 8836 - Resurrect Rotating Collections)\n";
    SetVersion($DBversion);
}

$DBversion = "3.17.00.048";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        INSERT INTO systempreferences (variable,value,options,explanation,type) VALUES('RentalFeesCheckoutConfirmation', '0', NULL , 'Allow user to confirm when checking out an item with rental fees.', 'YesNo')
    |);
    print "Upgrade to $DBversion done (Bug 12448 - Add RentalFeesCheckoutConfirmation syspref)\n";
    SetVersion($DBversion);
}

$DBversion = "3.17.00.049";
if ( CheckVersion($DBversion) ) {
    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'am', 'language', 'Amharic','2014-10-29')");
    $dbh->do("INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'am','amh')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'am', 'language', 'am', 'አማርኛ')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'am', 'language', 'en', 'Amharic')");

    $dbh->do("UPDATE language_descriptions SET description = 'لعربية' WHERE subtag = 'ar' AND type = 'language' AND lang = 'ar'");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'az', 'language', 'Azerbaijani','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'az','aze')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'az', 'language', 'az', 'Azərbaycan dili')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'az', 'language', 'en', 'Azerbaijani')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'be', 'language', 'Byelorussian','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'be','bel')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'be', 'language', 'be', 'Беларуская мова')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'be', 'language', 'en', 'Byelorussian')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'bn', 'language', 'Bengali','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'bn','ben')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'bn', 'language', 'bn', 'বাংলা')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'bn', 'language', 'en', 'Bengali')");

    $dbh->do("UPDATE language_descriptions SET description = 'Български' WHERE subtag = 'bg' AND type = 'language' AND lang = 'bg'");
    $dbh->do("UPDATE language_descriptions SET description = 'Ceština' WHERE subtag = 'cs' AND type = 'language' AND lang = 'cs'");
    $dbh->do("UPDATE language_descriptions SET description = 'Ελληνικά' WHERE subtag = 'el' AND type = 'language' AND lang = 'el'");
    $dbh->do("UPDATE language_descriptions SET description = 'Español' WHERE subtag = 'es' AND type = 'language' AND lang = 'es'");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'eu', 'language', 'Basque','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'eu','eus')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'eu', 'language', 'eu', 'Euskera')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'eu', 'language', 'en', 'Basque')");

    $dbh->do("UPDATE language_descriptions SET description = 'فارسى' WHERE subtag = 'fa' AND type = 'language' AND lang = 'fa'");
    $dbh->do("UPDATE language_descriptions SET description = 'Suomi' WHERE subtag = 'fi' AND type = 'language' AND lang = 'fi'");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'fo', 'language', 'Faroese','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'fo','fao')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'fo', 'language', 'fo', 'Føroyskt')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'fo', 'language', 'en', 'Faroese')");

    $dbh->do("UPDATE language_descriptions SET description = 'Français' WHERE subtag = 'fr' AND type = 'language' AND lang = 'fr'");
    $dbh->do("UPDATE language_descriptions SET description = 'עִבְרִית' WHERE subtag = 'he' AND type = 'language' AND lang = 'he'");
    $dbh->do("UPDATE language_descriptions SET description = 'हिन्दी' WHERE subtag = 'hi' AND type = 'language' AND lang = 'hi'");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'is', 'language', 'Icelandic','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'is','ice')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'is', 'language', 'is', 'Íslenska')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'is', 'language', 'en', 'Icelandic')");

    $dbh->do("UPDATE language_descriptions SET description = '日本語' WHERE subtag = 'ja' AND type = 'language' AND lang = 'ja'");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'ka', 'language', 'Kannada','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'ka','kan')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ka', 'language', 'ka', 'ಕನ್ನಡ')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ka', 'language', 'en', 'Kannada')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'km', 'language', 'Khmer','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES( 'km','khm')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'km', 'language', 'km', 'ភាសាខ្មែរ')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES( 'km', 'language', 'en', 'Khmer')");

    $dbh->do("UPDATE language_descriptions SET description = '한국어' WHERE subtag = 'ko' AND type = 'language' AND lang = 'ko'");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'ku', 'language', 'Kurdish','2014-05-13')");
    $dbh->do("INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'ku','kur')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ku', 'language', 'ku', 'کوردی')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ku', 'language', 'en', 'Kurdish')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ku', 'language', 'fr', 'Kurde')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ku', 'language', 'de', 'Kurdisch')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ku', 'language', 'es', 'Kurdo')");

    $dbh->do("UPDATE language_descriptions SET description = 'ພາສາລາວ' WHERE subtag = 'lo' AND type = 'language' AND lang = 'lo'");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'mi', 'language', 'Maori','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'mi','mri')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'mi', 'language', 'mi', 'Te Reo Māori')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'mi', 'language', 'en', 'Maori')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'mn', 'language', 'Mongolian','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'mn','mon')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'mn', 'language', 'mn', 'Mонгол')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'mn', 'language', 'en', 'Mongolian')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'mr', 'language', 'Marathi','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'mr','mar')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'mr', 'language', 'mr', 'मराठी')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'mr', 'language', 'en', 'Marathi')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'ms', 'language', 'Malay','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'ms','may')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ms', 'language', 'ms', 'Bahasa melayu')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ms', 'language', 'en', 'Malay')");

    $dbh->do("UPDATE language_descriptions SET description = 'Norsk bokmål' WHERE subtag = 'nb' AND type = 'language' AND lang = 'nb'");
    $dbh->do("UPDATE language_descriptions SET description = 'Norwegian bokmål' WHERE subtag = 'nb' AND type = 'language' AND lang = 'en'");
    $dbh->do("UPDATE language_descriptions SET description = 'Norvégien bokmål' WHERE subtag = 'nb' AND type = 'language' AND lang = 'fr'");
    $dbh->do("UPDATE language_descriptions SET description = 'Norwegisch bokmål' WHERE subtag = 'nb' AND type = 'language' AND lang = 'de'");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'ne', 'language', 'Nepali','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'ne','nep')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)VALUES ( 'ne', 'language', 'ne', 'नेपाली')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ne', 'language', 'en', 'Nepali')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'pbr', 'language', 'Pangwa','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'pbr','pbr')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'pbr', 'language', 'pbr', 'Ekipangwa')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'pbr', 'language', 'en', 'Pangwa')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'prs', 'language', 'Dari','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'prs','prs')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'prs', 'language', 'prs', 'درى')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'prs', 'language', 'en', 'Dari')");

    $dbh->do("UPDATE language_descriptions SET description = 'Português' WHERE subtag = 'pt' AND type = 'language' AND lang = 'pt'");
    $dbh->do("UPDATE language_descriptions SET description = 'Român' WHERE subtag = 'ro' AND type = 'language' AND lang = 'ro'");
    $dbh->do("UPDATE language_descriptions SET description = 'Русский' WHERE subtag = 'ru' AND type = 'language' AND lang = 'ru'");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'rw', 'language', 'Kinyarwanda','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'rw','kin')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'rw', 'language', 'rw', 'Ikinyarwanda')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'rw', 'language', 'en', 'Kinyarwanda')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'sd', 'language', 'Sindhi','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'sd','snd')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sd', 'language', 'sd', 'سنڌي')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sd', 'language', 'en', 'Sindhi')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'sk', 'language', 'Slovak','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'sk','slk')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sk', 'language', 'sk', 'Slovenčina')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sk', 'language', 'en', 'Slovak')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'sl', 'language', 'Slovene','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'sl','slv')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sl', 'language', 'sl', 'Slovenščina')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sl', 'language', 'en', 'Slovene')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'sq', 'language', 'Albanian','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'sq','sqi')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sq', 'language', 'sq', 'Shqip')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sq', 'language', 'en', 'Albanian')");

    $dbh->do("UPDATE language_descriptions SET description = 'Cрпски' WHERE subtag = 'sr' AND type = 'language' AND lang = 'sr'");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'sw', 'language', 'Swahili','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'sw','swa')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sw', 'language', 'sw', 'Kiswahili')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'sw', 'language', 'en', 'Swahili')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'ta', 'language', 'Tamil','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'ta','tam')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ta', 'language', 'ta', 'தமிழ்')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ta', 'language', 'en', 'Tamil')");

    $dbh->do("UPDATE language_descriptions SET description = 'Tetun' WHERE subtag = 'tet' AND type = 'language' AND lang = 'tet'");
    $dbh->do("UPDATE language_descriptions SET description = 'ภาษาไทย' WHERE subtag = 'th' AND type = 'language' AND lang = 'th'");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'tl', 'language', 'Tagalog','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'tl','tgl')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'tl', 'language', 'tl', 'Tagalog')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'tl', 'language', 'en', 'Tagalog')");

    $dbh->do("UPDATE language_descriptions SET description = 'Türkçe' WHERE subtag = 'tr' AND type = 'language' AND lang = 'tr'");
    $dbh->do("UPDATE language_descriptions SET description = 'Українська' WHERE subtag = 'uk' AND type = 'language' AND lang = 'uk'");
    $dbh->do("UPDATE language_descriptions SET description = 'اردو' WHERE subtag = 'ur' AND type = 'language' AND lang = 'ur'");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'vi', 'language', 'Vietnamese','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'vi','vie')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'vi', 'language', 'vi', '㗂越')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'vi', 'language', 'en', 'Vietnamese')");

    $dbh->do("UPDATE language_descriptions SET description = '中文' WHERE subtag = 'zh' AND type = 'language' AND lang = 'zh'");
    $dbh->do("UPDATE language_descriptions SET description = '' WHERE subtag = 'Arab,script' AND type = 'Arab' AND lang = 'العربية'");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'Armn', 'script', 'Armenian','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'Armn', 'script', 'Armn', 'Հայոց այբուբեն')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES( 'Armn', 'script', 'en', 'Armenian')");

    $dbh->do("UPDATE language_descriptions SET description = 'Кирилица' WHERE subtag = 'Cyrl' AND type = 'script' AND lang = 'Cyrl'");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'Ethi', 'script', 'Ethiopic','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'Ethi', 'script', 'Ethi', 'ግዕዝ')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES( 'Ethi', 'script', 'en', 'Ethiopic')");

    $dbh->do("UPDATE language_descriptions SET description = 'Ελληνικό αλφάβητο' WHERE subtag = 'Grek' AND type = 'script' AND lang = 'Grek'");
    $dbh->do("UPDATE language_descriptions SET description = '简体字' WHERE subtag = 'Hans' AND type = 'script' AND lang = 'Hans'");
    $dbh->do("UPDATE language_descriptions SET description = '繁體字' WHERE subtag = 'Hant' AND type = 'script' AND lang = 'Hant'");
    $dbh->do("UPDATE language_descriptions SET description = 'אָלֶף־בֵּית עִבְרִי' WHERE subtag = 'Hebr' AND type = 'script' AND lang = 'Hebr'");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'Jpan', 'script', 'Japanese','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'Jpan', 'script', 'Jpan', '漢字')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES( 'Jpan', 'script', 'en', 'Japanese')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'Knda', 'script', 'Kannada','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'Knda', 'script', 'Knda', 'ಕನ್ನಡ ಲಿಪಿ')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES( 'Knda', 'script', 'en', 'Kannada')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'Kore', 'script', 'Korean','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'Kore', 'script', 'Kore', '한글')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES( 'Kore', 'script', 'en', 'Korean')");

    $dbh->do("UPDATE language_descriptions SET description = 'ອັກສອນລາວ' WHERE subtag = 'Laoo' AND type = 'script' AND lang = 'Laoo'");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'AL', 'region', 'Albania','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'AL', 'region', 'en', 'Albania')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'AL', 'region', 'sq', 'Shqipërisë')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'AZ', 'region', 'Azerbaijan','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'AZ', 'region', 'en', 'Azerbaijan')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'AZ', 'region', 'az', 'Azərbaycan')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'BE', 'region', 'Belgium','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'BE', 'region', 'en', 'Belgium')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'BE', 'region', 'nl', 'België')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'BR', 'region', 'Brazil','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'BR', 'region', 'en', 'Brazil')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'BR', 'region', 'pt', 'Brasil')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'BY', 'region', 'Belarus','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'BY', 'region', 'en', 'Belarus')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'BY', 'region', 'be', 'Беларусь')");

    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'CA', 'region', 'fr', 'Canada')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'CH', 'region', 'Switzerland','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'CH', 'region', 'en', 'Switzerland')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'CH', 'region', 'de', 'Schweiz')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'CN', 'region', 'China','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'CN', 'region', 'en', 'China')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'CN', 'region', 'zh', '中国')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'CZ', 'region', 'Czech Republic','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'CZ', 'region', 'en', 'Czech Republic')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'CZ', 'region', 'cs', 'Česká republika')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'DE', 'region', 'Germany','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'DE', 'region', 'en', 'Germany')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'DE', 'region', 'de', 'Deutschland')");

    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'DK', 'region', 'en', 'Denmark')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'ES', 'region', 'Spain','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ES', 'region', 'en', 'Spain')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ES', 'region', 'es', 'España')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'FI', 'region', 'Finland','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'FI', 'region', 'en', 'Finland')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'FI', 'region', 'fi', 'Suomi')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'FO', 'region', 'Faroe Islands','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'FO', 'region', 'en', 'Faroe Islands')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'FO', 'region', 'fo', 'Føroyar')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'GR', 'region', 'Greece','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'GR', 'region', 'en', 'Greece')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'GR', 'region', 'el', 'Ελλάδα')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'HR', 'region', 'Croatia','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'HR', 'region', 'en', 'Croatia')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'HR', 'region', 'hr', 'Hrvatska')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'HU', 'region', 'Hungary','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'HU', 'region', 'en', 'Hungary')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'HU', 'region', 'hu', 'Magyarország')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'ID', 'region', 'Indonesia','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ID', 'region', 'en', 'Indonesia')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ID', 'region', 'id', 'Indonesia')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'IS', 'region', 'Iceland','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'IS', 'region', 'en', 'Iceland')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'IS', 'region', 'is', 'Ísland')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'IT', 'region', 'Italy','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'IT', 'region', 'en', 'Italy')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'IT', 'region', 'it', 'Italia')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'JP', 'region', 'Japan','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'JP', 'region', 'en', 'Japan')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'JP', 'region', 'ja', '日本')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'KE', 'region', 'Kenya','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'KE', 'region', 'en', 'Kenya')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'KE', 'region', 'rw', 'Kenya')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'KH', 'region', 'Cambodia','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'KH', 'region', 'en', 'Cambodia')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'KH', 'region', 'km', 'កម្ពុជា')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'KP', 'region', 'North Korea','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'KP', 'region', 'en', 'North Korea')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'KP', 'region', 'ko', '조선민주주의인민공화국')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'LK', 'region', 'Sri Lanka','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'LK', 'region', 'en', 'Sri Lanka')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'LK', 'region', 'ta', 'இலங்கை')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'MY', 'region', 'Malaysia','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'MY', 'region', 'en', 'Malaysia')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'MY', 'region', 'ms', 'Malaysia')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'NE', 'region', 'Niger','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'NE', 'region', 'en', 'Niger')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'NE', 'region', 'ne', 'Niger')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'NL', 'region', 'Netherlands','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'NL', 'region', 'en', 'Netherlands')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'NL', 'region', 'nl', 'Nederland')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'NO', 'region', 'Norway','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'NO', 'region', 'en', 'Norway')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'NO', 'region', 'ne', 'Noreg')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'NO', 'region', 'nn', 'Noreg')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'PH', 'region', 'Philippines','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'PH', 'region', 'en', 'Philippines')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'PH', 'region', 'tl', 'Pilipinas')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'PK', 'region', 'Pakistan','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'PK', 'region', 'en', 'Pakistan')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'PK', 'region', 'sd', 'پاكستان')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'PL', 'region', 'Poland','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'PL', 'region', 'en', 'Poland')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'PL', 'region', 'pl', 'Polska')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'PT', 'region', 'Portugal','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'PT', 'region', 'en', 'Portugal')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'PT', 'region', 'pt', 'Portugal')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'RO', 'region', 'Romania','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'RO', 'region', 'en', 'Romania')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'RO', 'region', 'ro', 'România')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'RU', 'region', 'Russia','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'RU', 'region', 'en', 'Russia')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'RU', 'region', 'ru', 'Россия')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'RW', 'region', 'Rwanda','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'RW', 'region', 'en', 'Rwanda')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'RW', 'region', 'rw', 'Rwanda')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'SE', 'region', 'Sweden','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'SE', 'region', 'en', 'Sweden')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'SE', 'region', 'sv', 'Sverige')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'SI', 'region', 'Slovenia','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'SI', 'region', 'en', 'Slovenia')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'SI', 'region', 'sl', 'Slovenija')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'SK', 'region', 'Slovakia','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'SK', 'region', 'en', 'Slovakia')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'SK', 'region', 'sk', 'Slovensko')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'TH', 'region', 'Thailand','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'TH', 'region', 'en', 'Thailand')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'TH', 'region', 'th', 'ประเทศไทย')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'TR', 'region', 'Turkey','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'TR', 'region', 'en', 'Turkey')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'TR', 'region', 'tr', 'Türkiye')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'TW', 'region', 'Taiwan','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'TW', 'region', 'en', 'Taiwan')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'TW', 'region', 'zh', '台灣')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'UA', 'region', 'Ukraine','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'UA', 'region', 'en', 'Ukraine')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'UA', 'region', 'uk', 'Україна')");

    $dbh->do("INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'VN', 'region', 'Vietnam','2014-10-30')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'VN', 'region', 'en', 'Vietnam')");
    $dbh->do("INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'VN', 'region', 'vi', 'Việt Nam')");

    print "Upgrade to $DBversion done (Bug 12250: Update descriptions for languages, scripts and regions)\n";
    SetVersion($DBversion);
}

$DBversion = "3.17.00.050";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        INSERT INTO permissions (module_bit, code, description) VALUES
          (13, 'records_batchdel', 'Perform batch deletion of records (bibliographic or authority)')
    |);
    print "Upgrade to $DBversion done (Bug 12403: Add permission tools_records_batchdelitem)\n";
    SetVersion($DBversion);
}

$DBversion = "3.17.00.051";
if ( CheckVersion($DBversion) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type) VALUES('GoogleIndicTransliteration','0','','GoogleIndicTransliteration on the OPAC.','YesNo')");
    print "Upgrade to $DBversion done (Bug 13211: Added system preferences GoogleIndicTransliteration on the OPAC)\n";
    SetVersion($DBversion);
}

$DBversion = "3.17.00.052";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('OpacAdvSearchOptions','pubdate|itemtype|language|sorting|location','Show search options','pubdate|itemtype|language|subtype|sorting|location','multiple');
    });

    $dbh->do(q{
        INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('OpacAdvSearchMoreOptions','pubdate|itemtype|language|subtype|sorting|location','Show search options for the expanded view (More options)','pubdate|itemtype|language|subtype|sorting|location','multiple');
   });
   print "Upgrade to $DBversion done (Bug 9043: Add system preference OpacAdvSearchOptions and OpacAdvSearchMoreOptions)\n";
   SetVersion ($DBversion);
}

$DBversion = "3.17.00.053";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT INTO permissions (module_bit, code, description) VALUES ('9', 'edit_items_restricted', 'Limit item modification to subfields defined in the SubfieldsToAllowForRestrictedEditing preference (please note that edit_item is still required)');
    });

    $dbh->do(q{
        INSERT INTO permissions (module_bit, code, description) VALUES ('9', 'delete_all_items', 'Delete all items at once');
    });

    $dbh->do(q{
        INSERT INTO permissions (module_bit, code, description) VALUES ('13', 'items_batchmod_restricted', 'Limit batch item modification to subfields defined in the SubfieldsToAllowForRestrictedBatchmod preference (please note that items_batchmod is still required)');
    });

    # The delete_all_items permission should be added to users having the edit_items permission.
    $dbh->do(q{
        INSERT INTO user_permissions (borrowernumber, module_bit, code) SELECT borrowernumber, module_bit, "delete_all_items" FROM user_permissions WHERE code="edit_items";
    });

    # Add 2 new prefs
    $dbh->do(q{
        INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('SubfieldsToAllowForRestrictedEditing','','Define a list of subfields for which edition is authorized when edit_items_restricted permission is enabled, separated by spaces. Example: 995\$f 995\$h 995\$j','','Free');
    });

    $dbh->do(q{
        INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('SubfieldsToAllowForRestrictedBatchmod','','Define a list of subfields for which edition is authorized when items_batchmod_restricted permission is enabled, separated by spaces. Example: 995\$f 995\$h 995\$j','','Free');
    });

    print "Upgrade to $DBversion done (Bug 7673: Adds 2 new prefs (SubfieldsToAllowForRestrictedEditing and SubfieldsToAllowForRestrictedBatchmod) and 3 new permissions (edit_items_restricted and delete_all_items and items_batchmod_restricted))\n";
    SetVersion($DBversion);
}

$DBversion = "3.17.00.054";
if (CheckVersion($DBversion)) {
    $dbh->do(q{
        INSERT INTO systempreferences ( variable, value, options, explanation, type ) VALUES
        ('AllowRenewalIfOtherItemsAvailable','0',NULL,'If enabled, allow a patron to renew an item with unfilled holds if other available items can fill that hold.','YesNo')
    });
    print "Upgrade to $DBversion done (Bug 11634 - Allow renewal of item with unfilled holds if other available items can fill those holds)\n";
    SetVersion($DBversion);
}

$DBversion = "3.17.00.055";
if ( CheckVersion($DBversion) ) {
    $dbh->do("INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('NorwegianPatronDBEnable', '0', NULL, 'Enable communication with the Norwegian national patron database.', 'YesNo')");
    $dbh->do("INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('NorwegianPatronDBEndpoint', '', NULL, 'Which NL endpoint to use.', 'Free')");
    $dbh->do("INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('NorwegianPatronDBUsername', '', NULL, 'Username for communication with the Norwegian national patron database.', 'Free')");
    $dbh->do("INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('NorwegianPatronDBPassword', '', NULL, 'Password for communication with the Norwegian national patron database.', 'Free')");
    $dbh->do("INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('NorwegianPatronDBSearchNLAfterLocalHit','0',NULL,'Search NL if a search has already given one or more local hits?.','YesNo')");
    $dbh->do("
CREATE TABLE borrower_sync (
    borrowersyncid int(11) NOT NULL AUTO_INCREMENT,
    borrowernumber int(11) NOT NULL,
    synctype varchar(32) NOT NULL,
    sync tinyint(1) NOT NULL DEFAULT '0',
    syncstatus varchar(10) DEFAULT NULL,
    lastsync varchar(50) DEFAULT NULL,
    hashed_pin varchar(64) DEFAULT NULL,
    PRIMARY KEY (borrowersyncid),
    KEY borrowernumber (borrowernumber),
    CONSTRAINT borrower_sync_ibfk_1 FOREIGN KEY (borrowernumber) REFERENCES borrowers (borrowernumber) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8"
);
    print "Upgrade to $DBversion done (Bug 11401 - Add support for Norwegian national library card)\n";
    SetVersion($DBversion);
}

$DBversion = "3.17.00.056";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        UPDATE systempreferences SET value = 'pubdate,itemtype,language,sorting,location' WHERE variable='OpacAdvSearchOptions'
    });

    $dbh->do(q{
        UPDATE systempreferences SET value = 'pubdate,itemtype,language,subtype,sorting,location' WHERE variable='OpacAdvSearchMoreOptions'
    });

    print "Upgrade to $DBversion done (Bug 9043 - Update the values for OpacAdvSearchOptions and OpacAdvSearchOptions)\n";
    SetVersion($DBversion);
}

$DBversion = "3.17.00.057";
if ( CheckVersion($DBversion) ) {
    print "Upgrade to $DBversion done (Koha 3.18 beta)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.17.00.058";
if( CheckVersion($DBversion) ){
    $dbh->do("INSERT INTO systempreferences (variable, explanation, type) VALUES('DefaultLongOverdueChargeValue','Charge a lost item to the borrower account when the LOST value of the item changes to n',  'integer')");
    $dbh->do("INSERT INTO systempreferences (variable, explanation, type) VALUES('DefaultLongOverdueLostValue', 'Set the LOST value of an item to n when the item has been overdue for more than defaultlongoverduedays days.', 'integer')");
    $dbh->do("INSERT INTO systempreferences (variable, explanation, type) VALUES('DefaultLongOverdueDays', 'Set the LOST value of an item when the item has been overdue for more than n days.',  'integer')");
    print "Upgrade to $DBversion done (Bug 8337: System preferences for longoverdue cron)\n";
    SetVersion($DBversion);
}

$DBversion = "3.17.00.059";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        UPDATE permissions SET description = "Add and delete budgets (but can't modifiy budgets)" WHERE description = "Add and delete budgets (but cant modify budgets)";
    });
    print "Upgrade to $DBversion done (Bug 10749: Fix typo in budget_add_del permission description)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.17.00.060";
if ( CheckVersion($DBversion) ) {
    my $count_l = $dbh->selectcol_arrayref(q|
        SELECT COUNT(*) FROM letter WHERE message_transport_type='feed'
    |);
    my $count_mq = $dbh->selectcol_arrayref(q|
        SELECT COUNT(*) FROM message_queue WHERE message_transport_type='feed'
    |);
    my $count_ott = $dbh->selectcol_arrayref(q|
        SELECT COUNT(*) FROM overduerules_transport_types WHERE message_transport_type='feed'
    |);
    my $count_mt = $dbh->selectcol_arrayref(q|
        SELECT COUNT(*) FROM message_transports WHERE message_transport_type='feed'
    |);
    my $count_bmtp = $dbh->selectcol_arrayref(q|
        SELECT COUNT(*) FROM borrower_message_transport_preferences WHERE message_transport_type='feed'
    |);

    my $deleted = 0;
    if ( $count_l->[0] == 0 and $count_mq->[0] == 0 and $count_ott->[0] == 0 and $count_mt->[0] == 0 and $count_bmtp->[0] == 0 ) {
        $deleted = $dbh->do(q|
            DELETE FROM message_transport_types where message_transport_type='feed'
        |);
        $deleted = $deleted ne '0E0' ? 1 : 0;
    }

    print "Upgrade to $DBversion done (Bug 12298: Delete the 'feed' message transport type " . ($deleted ? '(deleted!)' : '(not deleted)') . ")\n";
    SetVersion($DBversion);
}

$DBversion = "3.18.00.000";
if ( CheckVersion($DBversion) ) {
    print "Upgrade to $DBversion done (3.18.0 release)\n";
    SetVersion($DBversion);
}

$DBversion = "3.19.00.000";
if ( CheckVersion($DBversion) ) {
    print "Upgrade to $DBversion done (there's life after 3.18)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.19.00.001";
if ( CheckVersion($DBversion) ) {
    $dbh->do("
        UPDATE systempreferences
        SET options = 'public|school|academic|research|private|societyAssociation|corporate|government|religiousOrg|subscription'
        WHERE variable = 'UsageStatsLibraryType'
    ");
    if ( C4::Context->preference("UsageStatsLibraryType") eq "university" ) {
        C4::Context->set_preference("UsageStatsLibraryType", "academic")
    }
    print "Upgrade to $DBversion done (Bug 13436: Add more options to UsageStatsLibraryType)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.19.00.002";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        UPDATE suggestions SET branchcode="" WHERE branchcode="__ANY__"
    |);
    print "upgrade to $DBversion done (Bug 10753: replace __ANY__ with empty string in suggestions.branchcode)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.19.00.003";
if ( CheckVersion($DBversion) ) {
    my ($count) = $dbh->selectrow_array("SELECT COUNT(*) FROM borrowers GROUP BY userid HAVING COUNT(userid) > 1");

    if ( $count ) {
        print "Upgrade to $DBversion done (Bug 1861 - Unique patrons logins not (totally) enforced) FAILED!\n";
        print "Your database has users with duplicate user logins. Please have your administrator deduplicate your user logins.\n";
        print "Afterward, your Koha administrator should execute the following database query: ALTER TABLE borrowers DROP INDEX userid, ADD UNIQUE userid (userid)";
    } else {
        $dbh->do(q{
            ALTER TABLE borrowers
                DROP INDEX userid ,
                ADD UNIQUE userid (userid)
        });
        print "Upgrade to $DBversion done (Bug 1861: Unique patrons logins not (totally) enforced)\n";
    }
    SetVersion ($DBversion);
}

$DBversion = "3.19.00.004";
if ( CheckVersion($DBversion) ) {
    my $pref_value = C4::Context->preference('OpacExportOptions');
    $pref_value =~ s/\|/,/g; # multiple is separated by ,
    $dbh->do(q{
        UPDATE systempreferences
            SET value = ?,
                type = 'multiple'
        WHERE variable = 'OpacExportOptions'
    }, {}, $pref_value );
    print "Upgrade to $DBversion done (Bug 13346: OpacExportOptions is now multiple)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.19.00.005";
if(CheckVersion($DBversion)) {
    $dbh->do(q{
        ALTER TABLE authorised_values MODIFY COLUMN category VARCHAR(32) NOT NULL DEFAULT ''
    });

    $dbh->do(q{
        ALTER TABLE borrower_attribute_types MODIFY COLUMN authorised_value_category VARCHAR(32) DEFAULT NULL
    });

    print "Upgrade to $DBversion done (Bug 13379: Modify authorised_values.category to varchar(32))\n";
    SetVersion($DBversion);
}

$DBversion = "3.19.00.006";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|SET foreign_key_checks = 0|);
    my $sth = $dbh->table_info( '','','','TABLE' );
    my ( $cat, $schema, $name, $type, $remarks );
    while ( ( $cat, $schema, $name, $type, $remarks ) = $sth->fetchrow_array ) {
        my $table_sth = $dbh->prepare(qq|SHOW CREATE TABLE $name|);
        $table_sth->execute;
        my @table = $table_sth->fetchrow_array;
        unless ( $table[1] =~ /COLLATE=utf8mb4_unicode_ci/ ) { #catches utf8mb4 collated tables
            if ( $name eq 'marc_subfield_structure' ) {
                $dbh->do(q|
                    ALTER TABLE marc_subfield_structure
                    MODIFY COLUMN tagfield varchar(3) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
                    MODIFY COLUMN tagsubfield varchar(1) COLLATE utf8_bin NOT NULL DEFAULT '',
                    MODIFY COLUMN liblibrarian varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
                    MODIFY COLUMN libopac varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
                    MODIFY COLUMN kohafield varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
                    MODIFY COLUMN authorised_value varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
                    MODIFY COLUMN authtypecode varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
                    MODIFY COLUMN value_builder varchar(80) COLLATE utf8_unicode_ci DEFAULT NULL,
                    MODIFY COLUMN frameworkcode varchar(4) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
                    MODIFY COLUMN seealso varchar(1100) COLLATE utf8_unicode_ci DEFAULT NULL,
                    MODIFY COLUMN link varchar(80) COLLATE utf8_unicode_ci DEFAULT NULL
                |);
                $dbh->do(qq|ALTER TABLE $name CHARACTER SET utf8 COLLATE utf8_unicode_ci|);
            }
            else {
                $dbh->do(qq|ALTER TABLE $name CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci|);
            }
        }
    }
    $dbh->do(q|SET foreign_key_checks = 1|);;

    print "Upgrade to $DBversion done (Bug 11944: Convert DB tables to utf8_unicode_ci)\n";
    SetVersion($DBversion);
}

$DBversion = "3.19.00.007";
if ( CheckVersion($DBversion) ) {
    my $orphan_budgets = $dbh->selectall_arrayref(q|
        SELECT budget_id, budget_name, budget_code
        FROM aqbudgets
        WHERE   budget_parent_id IS NOT NULL
            AND budget_parent_id NOT IN (
                SELECT DISTINCT budget_id FROM aqbudgets
            )
    |, { Slice => {} } );

    if ( @$orphan_budgets ) {
        for my $b ( @$orphan_budgets ) {
            print "Fund $b->{budget_name} (code:$b->{budget_code}, id:$b->{budget_id}) does not have a parent, it may cause problem\n";
        }
        print "Upgrade to $DBversion done (Bug 12905: Check budget integrity: FAIL)\n";
    } else {
        print "Upgrade to $DBversion done (Bug 12905: Check budget integrity: OK)\n";
    }
    SetVersion ($DBversion);
}

$DBversion = "3.19.00.008";
if ( CheckVersion($DBversion) ) {
    my $number_of_orders_not_linked = $dbh->selectcol_arrayref(q|
        SELECT COUNT(*)
        FROM aqorders o
        WHERE NOT EXISTS (
            SELECT NULL
            FROM aqbudgets b
            WHERE b.budget_id = o.budget_id
        );
    |);

    if ( $number_of_orders_not_linked->[0] > 0 ) {
        $dbh->do(q|
            INSERT INTO aqbudgetperiods(budget_period_startdate, budget_period_enddate, budget_period_active, budget_period_description, budget_period_total) VALUES ( CAST(NOW() AS date), CAST(NOW() AS date), 0, "WARNING: This budget has been automatically created by the updatedatabase script, please see bug 12601 for more information", 0)
        |);
        my $budget_period_id = $dbh->last_insert_id( undef, undef, 'aqbudgetperiods', undef );
        $dbh->do(qq|
            INSERT INTO aqbudgets(budget_code, budget_name, budget_amount, budget_period_id) VALUES ( "BACKUP_TMP", "WARNING: fund created by the updatedatabase script, please see bug 12601", 0, $budget_period_id );
        |);
        my $budget_id = $dbh->last_insert_id( undef, undef, 'aqbudgets', undef );
        $dbh->do(qq|
            UPDATE aqorders o
            SET budget_id = $budget_id
            WHERE NOT EXISTS (
                SELECT NULL
                FROM aqbudgets b
                WHERE b.budget_id = o.budget_id
            )
        |);
    }

    $dbh->do(q|
        ALTER TABLE aqorders
        ADD CONSTRAINT aqorders_budget_id_fk FOREIGN KEY (budget_id) REFERENCES aqbudgets(budget_id) ON DELETE CASCADE ON UPDATE CASCADE
    |);

    print "Upgrade to $DBversion done (Bug 12601: Add new foreign key aqorders.budget_id" . ( ( $number_of_orders_not_linked->[0] > 0 )  ? ' WARNING: temporary budget and fund have been created (search for "BACKUP_TMP"). At least one of your order was not linked to a budget' : '' ) . ")\n";
    SetVersion($DBversion);
}

$DBversion = "3.19.00.009";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        UPDATE suggestions s SET s.budgetid = NULL
        WHERE NOT EXISTS (
            SELECT NULL
            FROM aqbudgets b
            WHERE b.budget_id = s.budgetid
        );
    |);

    $dbh->do(q|
        ALTER TABLE suggestions
        ADD CONSTRAINT suggestions_budget_id_fk FOREIGN KEY (budgetid) REFERENCES aqbudgets(budget_id) ON DELETE SET NULL ON UPDATE CASCADE
    |);

    print "Upgrade to $DBversion done (Bug 13007: Add new foreign key suggestions.budgetid)\n";
    SetVersion($DBversion);
}

$DBversion = "3.19.00.010";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
        VALUES('SessionRestrictionByIP','1','Check for Change in  Remote IP address for Session Security. Disable when remote ip address changes frequently.','','YesNo')
    |);
    print "Upgrade to $DBversion done (Bug 5511: SessionRestrictionByIP)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.19.00.011";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        INSERT INTO userflags (bit, flag, flagdesc, defaulton) VALUES
        (20, 'lists', 'Lists', 0)
    |);
    $dbh->do(q|
        INSERT INTO permissions (module_bit, code, description) VALUES
        (20, 'delete_public_lists', 'Delete public lists')
    |);
    print "Upgrade to $DBversion done (Bug 13417: Add permission to delete public lists)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.19.00.012";
if(CheckVersion($DBversion)) {
    $dbh->do(q{
        ALTER TABLE biblioitems MODIFY COLUMN marcxml longtext
    });

    $dbh->do(q{
        ALTER TABLE deletedbiblioitems MODIFY COLUMN marcxml longtext
    });

    print "Upgrade to $DBversion done (Bug 13523 Remove NOT NULL restriction on field marcxml due to mysql STRICT_TRANS_TABLES)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.19.00.013";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        INSERT INTO permissions (module_bit, code, description) VALUES
          (13, 'records_batchmod', 'Perform batch modification of records (biblios or authorities)')
    |);
    print "Upgrade to $DBversion done (Bug 11395: Add permission tools_records_batchmod)\n";
    SetVersion($DBversion);
}

$DBversion = "3.19.00.014";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        CREATE TABLE aqorder_users (
            ordernumber int(11) NOT NULL,
            borrowernumber int(11) NOT NULL,
            PRIMARY KEY (ordernumber, borrowernumber),
            CONSTRAINT aqorder_users_ibfk_1 FOREIGN KEY (ordernumber) REFERENCES aqorders (ordernumber) ON DELETE CASCADE ON UPDATE CASCADE,
            CONSTRAINT aqorder_users_ibfk_2 FOREIGN KEY (borrowernumber) REFERENCES borrowers (borrowernumber) ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
    |);

    $dbh->do(q|
        INSERT INTO letter(module, code, branchcode, name, title, content, message_transport_type)
        VALUES ('acquisition', 'ACQ_NOTIF_ON_RECEIV', '', 'Notification on receiving', 'Order received', 'Dear <<borrowers.firstname>> <<borrowers.surname>>,\n\n The order <<aqorders.ordernumber>> (<<biblio.title>>) has been received.\n\nYour library.', 'email')
    |);
    print "Upgrade to $DBversion done (Bug 12648: Add letter ACQ_NOTIF_ON_RECEIV )\n";
    SetVersion ($DBversion);
}

$DBversion = "3.19.00.015";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        ALTER TABLE search_history ADD COLUMN id INT(11) NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY(id);
    |);
    print "Upgrade to $DBversion done (Bug 11430: Add primary key for search_history)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.19.00.016";
if(CheckVersion($DBversion)) {
    my @order_cancellation_reason = $dbh->selectrow_array("SELECT count(*) FROM authorised_values WHERE category='ORDER_CANCELLATION_REASON'");
    if ($order_cancellation_reason[0] == 0) {
        $dbh->do(q{
            INSERT INTO authorised_values (category, authorised_value, lib) VALUES
             ('ORDER_CANCELLATION_REASON', 0, 'No reason provided'),
             ('ORDER_CANCELLATION_REASON', 1, 'Out of stock'),
             ('ORDER_CANCELLATION_REASON', 2, 'Restocking')
        });

        my $already_existing_reasons = $dbh->selectcol_arrayref(q{
            SELECT DISTINCT( cancellationreason )
            FROM aqorders;
        }, { Slice => {} });

        my $update_orders_sth = $dbh->prepare(q{
            UPDATE aqorders
            SET cancellationreason = ?
            WHERE cancellationreason = ?
        });

        my $insert_av_sth = $dbh->prepare(q{
            INSERT INTO authorised_values (category, authorised_value, lib) VALUES
             ('ORDER_CANCELLATION_REASON', ?, ?)
        });
        my $i = 3;
        for my $reason ( @$already_existing_reasons ) {
            next unless $reason;
            $insert_av_sth->execute( $i, $reason );
            $update_orders_sth->execute( $i, $reason );
            $i++;
        }
        print "Upgrade to $DBversion done (Bug 13380: Add the ORDER_CANCELLATION_REASON authorised value)\n";
    }
    else {
        print "Upgrade to $DBversion done (Bug 13380: ORDER_CANCELLATION_REASON authorised value already existed from earlier update!)\n";
    }

    SetVersion($DBversion);
}

$DBversion = '3.19.00.017';
if ( CheckVersion($DBversion) ) {
    # First create the column
    $dbh->do("ALTER TABLE issuingrules ADD onshelfholds tinyint(1) default 0 NOT NULL");
    # Now update the column
    if (C4::Context->preference("AllowOnShelfHolds")){
        # Pref is on, set allow for all rules
        $dbh->do("UPDATE issuingrules SET onshelfholds=1");
    } else {
        # If the preference is not set, leave off
        $dbh->do("UPDATE issuingrules SET onshelfholds=0");
    }
    # Remove from the systempreferences table
    $dbh->do("DELETE FROM systempreferences WHERE variable = 'AllowOnShelfHolds'");

    # First create the column
    $dbh->do("ALTER TABLE issuingrules ADD opacitemholds char(1) DEFAULT 'N' NOT NULL");
    # Now update the column
    my $opacitemholds = C4::Context->preference("OPACItemHolds") || '';
    if (lc ($opacitemholds) eq 'force') {
        $opacitemholds = 'F';
    }
    else {
        $opacitemholds = $opacitemholds ? 'Y' : 'N';
    }
    # Set allow for all rules
    $dbh->do("UPDATE issuingrules SET opacitemholds='$opacitemholds'");

    # Remove from the systempreferences table
    $dbh->do("DELETE FROM systempreferences WHERE variable = 'OPACItemHolds'");

    print "Upgrade to $DBversion done (Bug 5786: Move AllowOnShelfHolds to circulation matrix; Move OPACItemHolds system preference to circulation matrix)\n";
    SetVersion ($DBversion);
}


$DBversion = "3.19.00.018";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        UPDATE systempreferences set variable="OpacAdditionalStylesheet" WHERE variable="opaccolorstylesheet"
    |);
    print "Upgrade to $DBversion done (Bug 10328: Rename opaccolorstylesheet to OpacAdditionalStylesheet\n";
    SetVersion ($DBversion);
}

$DBversion = "3.19.00.019";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable, value, explanation, options, type)
        VALUES('Coce','0', 'If on, enables cover retrieval from the configured Coce server', NULL, 'YesNo')
    });
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable, value, explanation, options, type)
        VALUES('CoceHost', NULL, 'Coce server URL', NULL,'Free')
    });
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable, value, explanation, options, type)
        VALUES('CoceProviders', NULL, 'Coce providers', 'aws,gb,ol', 'multiple')
    });
    print "Upgrade to $DBversion done (Bug 9580: Cover image from Coce, a remote image URL cache)\n";
    SetVersion($DBversion);
}

$DBversion = "3.19.00.020";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        ALTER TABLE aqorders DROP COLUMN supplierreference;
    |);

    print "Upgrade to $DBversion done (Bug 11008: DROP column aqorders.supplierreference)\n";
    SetVersion($DBversion);
}

$DBversion = "3.19.00.021";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        ALTER TABLE issues DROP COLUMN issuingbranch
    |);
    $dbh->do(q|
        ALTER TABLE old_issues DROP COLUMN issuingbranch
    |);
    print "Upgrade to $DBversion done (Bug 2806: Remove issuingbranch columns)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.19.00.022';
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        ALTER TABLE suggestions DROP COLUMN mailoverseeing;
    });
    print "Upgrade to $DBversion done (Bug 13006: Drop column suggestion.mailoverseeing)\n";
    SetVersion($DBversion);
}

$DBversion = "3.19.00.023";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        DELETE FROM systempreferences where variable = 'AddPatronLists'
    |);
    print "Upgrade to $DBversion done (Bug 13497: Remove the AddPatronLists system preferences)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.19.00.024";
if ( CheckVersion($DBversion) ) {
    $dbh->do(qq|DROP table patroncards;|);
    print "Upgrade to $DBversion done (Bug 13539: Remove table patroncards from database as it's no longer in use)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.19.00.025";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        INSERT INTO systempreferences ( variable, value, options, explanation, type ) VALUES
        ('SearchWithISBNVariations','0',NULL,'If enabled, search on all variations of the ISBN','YesNo')
    |);
    print "Upgrade to $DBversion done (Bug 13528: Add the SearchWithISBNVariations syspref)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.19.00.026";
if( CheckVersion($DBversion) ) {
    if ( C4::Context->preference('marcflavour') eq 'MARC21' ) {
    $dbh->do(q{
        INSERT IGNORE INTO auth_tag_structure (authtypecode, tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value) VALUES
        ('', '388', 'TIME PERIOD OF CREATION', 'TIME PERIOD OF CREATION', 1, 0, NULL);
    });

    $dbh->do(q{
        INSERT IGNORE INTO auth_subfield_structure (authtypecode, tagfield, tagsubfield, liblibrarian, libopac, repeatable,
        mandatory, tab, authorised_value, value_builder, seealso, isurl, hidden, linkid, kohafield, frameworkcode) VALUES
        ('', '388', '0', 'Authority record control number or standard number', 'Authority record control number or standard number', 1, 0, 3, NULL, NULL, NULL, 0, 0, '', '', ''),
        ('', '388', '2', 'Source of term', 'Source of term', 0, 0, 3, NULL, NULL, NULL, 0, 0, '', '', ''),
        ('', '388', '3', 'Materials specified', 'Materials specified', 0, 0, 3, NULL, NULL, NULL, 0, 0, '', '', ''),
        ('', '388', '6', 'Linkage', 'Linkage', 0, 0, 3, NULL, NULL, NULL, 0, 0, '', '', ''),
        ('', '388', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, 3, NULL, NULL, NULL, 0, 0, '', '', ''),
        ('', '388', 'a', 'Time period of creation term', 'Time period of creation term', 1, 0, 3, NULL, NULL, NULL, 0, 0, '', '', '');
    });

    $dbh->do(q{
        UPDATE IGNORE auth_subfield_structure SET repeatable = 1 WHERE tagsubfield = 'g' AND tagfield IN
        ('100','110','111','130','400','410','411','430','500','510','511','530','700','710','730');
    });

    $dbh->do(q{
        INSERT IGNORE INTO auth_subfield_structure (authtypecode, tagfield, tagsubfield, liblibrarian, libopac, repeatable,
        mandatory, tab, authorised_value, value_builder, seealso, isurl, hidden, linkid, kohafield, frameworkcode) VALUES
        ('', '150', 'g', 'Miscellaneous information', 'Miscellaneous information', 1, 0, 1, NULL, NULL, NULL, 0, 0, '', '', ''),
        ('', '151', 'g', 'Miscellaneous information', 'Miscellaneous information', 1, 0, 1, NULL, NULL, NULL, 0, 0, '', '', ''),
        ('', '450', 'g', 'Miscellaneous information', 'Miscellaneous information', 1, 0, 4, NULL, NULL, NULL, 0, 0, '', '', ''),
        ('', '451', 'g', 'Miscellaneous information', 'Miscellaneous information', 1, 0, 4, NULL, NULL, NULL, 0, 0, '', '', ''),
        ('', '550', 'g', 'Miscellaneous information', 'Miscellaneous information', 1, 0, 5, NULL, NULL, NULL, 0, 0, '', '', ''),
        ('', '551', 'g', 'Miscellaneous information', 'Miscellaneous information', 1, 0, 5, NULL, NULL, NULL, 0, 0, '', '', ''),
        ('', '750', 'g', 'Miscellaneous information', 'Miscellaneous information', 1, 0, 7, NULL, NULL, NULL, 0, 0, '', '', ''),
        ('', '751', 'g', 'Miscellaneous information', 'Miscellaneous information', 1, 0, 7, NULL, NULL, NULL, 0, 0, '', '', ''),
        ('', '748', 'i', 'Relationship information', 'Relationship information', 1, 0, 7, NULL, NULL, NULL, 0, 0, '', '', ''),
        ('', '755', 'i', 'Relationship information', 'Relationship information', 1, 0, 7, NULL, NULL, NULL, 0, 0, '', '', ''),
        ('', '780', 'i', 'Relationship information', 'Relationship information', 1, 0, 7, NULL, NULL, NULL, 0, 0, '', '', ''),
        ('', '781', 'i', 'Relationship information', 'Relationship information', 1, 0, 7, NULL, NULL, NULL, 0, 0, '', '', ''),
        ('', '782', 'i', 'Relationship information', 'Relationship information', 1, 0, 7, NULL, NULL, NULL, 0, 0, '', '', ''),
        ('', '785', 'i', 'Relationship information', 'Relationship information', 1, 0, 7, NULL, NULL, NULL, 0, 0, '', '', ''),
        ('', '710', '4', 'Relationship code', 'Relationship code', 1, 0, 7, NULL, NULL, NULL, 0, 0, '', '', ''),
        ('', '730', '4', 'Relationship code', 'Relationship code', 1, 0, 7, NULL, NULL, NULL, 0, 0, '', '', ''),
        ('', '748', '4', 'Relationship code', 'Relationship code', 1, 0, 7, NULL, NULL, NULL, 0, 0, '', '', ''),
        ('', '750', '4', 'Relationship code', 'Relationship code', 1, 0, 7, NULL, NULL, NULL, 0, 0, '', '', ''),
        ('', '751', '4', 'Relationship code', 'Relationship code', 1, 0, 7, NULL, NULL, NULL, 0, 0, '', '', ''),
        ('', '755', '4', 'Relationship code', 'Relationship code', 1, 0, 7, NULL, NULL, NULL, 0, 0, '', '', ''),
        ('', '762', '4', 'Relationship code', 'Relationship code', 1, 0, 7, NULL, NULL, NULL, 0, 0, '', '', ''),
        ('', '780', '4', 'Relationship code', 'Relationship code', 1, 0, 7, NULL, NULL, NULL, 0, 0, '', '', ''),
        ('', '781', '4', 'Relationship code', 'Relationship code', 1, 0, 7, NULL, NULL, NULL, 0, 0, '', '', ''),
        ('', '782', '4', 'Relationship code', 'Relationship code', 1, 0, 7, NULL, NULL, NULL, 0, 0, '', '', ''),
        ('', '785', '4', 'Relationship code', 'Relationship code', 1, 0, 7, NULL, NULL, NULL, 0, 0, '', '', ''),
        ('', '788', '4', 'Relationship code', 'Relationship code', 1, 0, 7, NULL, NULL, NULL, 0, 0, '', '', '');
    });

    $dbh->do(q{
        UPDATE IGNORE auth_subfield_structure SET liblibrarian = 'Relationship information', libopac = 'Relationship information'
        WHERE tagsubfield = 'i' AND tagfield IN ('700','710','730','750','751','762');
    });

    $dbh->do(q{
        UPDATE IGNORE auth_subfield_structure SET liblibrarian = 'Relationship code', libopac = 'Relationship code'
        WHERE tagsubfield = '4' AND tagfield IN ('700','710');
    });

    $dbh->do(q{
        INSERT IGNORE INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
        ('370', 'ASSOCIATED PLACE', 'ASSOCIATED PLACE', 1, 0, NULL, ''),
        ('388', 'TIME PERIOD OF CREATION', 'TIME PERIOD OF CREATION', 1, 0, NULL, '');
    });

    $dbh->do(q{
        INSERT IGNORE INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory,
        kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
        ('370', '0', 'Authority record control number or standard number', 'Authority record control number or standard number', 1, 0, '', 3, '', '', '', NULL, -6, '', '', '', NULL),
        ('370', '2', 'Source of term', 'Source of term', 0, 0, '', 3, '', '', '', NULL, -6, '', '', '', NULL),
        ('370', '6', 'Linkage', 'Linkage', 0, 0, '', 3, '', '', '', NULL, -6, '', '', '', NULL),
        ('370', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, '', 3, '', '', '', NULL, -6, '', '', '', NULL),
        ('370', 'c', 'Associated country', 'Associated country', 1, 0, '', 3, '', '', '', NULL, -6, '', '', '', NULL),
        ('370', 'f', 'Other associated place', 'Other associated place', 1, 0, '', 3, '', '', '', NULL, -6, '', '', '', NULL),
        ('370', 'g', 'Place of origin of work', 'Place of origin of work', 1, 0, '', 3, '', '', '', NULL, -6, '', '', '', NULL),
        ('370', 's', 'Start period', 'Start period', 0, 0, '', 3, '', '', '', NULL, -6, '', '', '', NULL),
        ('370', 't', 'End period', 'End period', 0, 0, '', 3, '', '', '', NULL, -6, '', '', '', NULL),
        ('370', 'u', 'Uniform Resource Identifier', 'Uniform Resource Identifier', 1, 0, '', 3, '', '', '', NULL, -6, '', '', '', NULL),
        ('370', 'v', 'Source of information', 'Source of information', 1, 0, '', 3, '', '', '', NULL, -6, '', '', '', NULL),
        ('377', 'l', 'Language term', 'Language term', 1, 0, '', 3, '', '', '', NULL, -6, '', '', '', NULL),
        ('382', 's', 'Total number of performers', 'Total number of performers', 0, 0, '', 3, '', '', '', NULL, -6, '', '', '', NULL),
        ('388', '0', 'Authority record control number or standard number', 'Authority record control number or standard number', 1, 0, '', 3, '', '', '', NULL, -6, '', '', '', NULL),
        ('388', '2', 'Source of term', 'Source of term', 0, 0, '', 3, '', '', '', NULL, -6, '', '', '', NULL),
        ('388', '3', ' Materials specified', ' Materials specified', 0, 0, '', 3, '', '', '', NULL, -6, '', '', '', NULL),
        ('388', '6', ' Linkage', ' Linkage', 0, 0, '', 3, '', '', '', NULL, -6, '', '', '', NULL),
        ('388', '8', 'Field link and sequence number', 'Field link and sequence number', 1, 0, '', 3, '', '', '', NULL, -6, '', '', '', NULL),
        ('388', 'a', 'Time period of creation term', 'Time period of creation term', 1, 0, '', 3, '', '', '', NULL, -6, '', '', '', NULL),
        ('650', 'g', 'Miscellaneous information', 'Miscellaneous information', 1, 0, '', 6, '', '', '', 0, -1, '', '', '', NULL),
        ('651', 'g', 'Miscellaneous information', 'Miscellaneous information', 1, 0, '', 6, '', '', '', 0, -1, '', '', '', NULL);
    });

    $dbh->do(q{
        UPDATE IGNORE marc_subfield_structure SET repeatable = 1 WHERE tagsubfield = 'g' AND
        tagfield IN ('100','110','111','130','240','243','246','247','600','610','611','630','700','710','711','730','800','810','811','830');
    });
    }

    print "Upgrade to $DBversion done (Bug 13322: Update MARC21 frameworks to Update No. 19 - October 2014)\n";
    SetVersion($DBversion);
}

$DBversion = '3.19.00.027';
if ( CheckVersion($DBversion) ) {
    $dbh->do("ALTER TABLE items ADD COLUMN itemnotes_nonpublic MEDIUMTEXT AFTER itemnotes");
    $dbh->do("ALTER TABLE deleteditems ADD COLUMN itemnotes_nonpublic MEDIUMTEXT AFTER itemnotes");
    print "Upgrade to $DBversion done (Bug 4222: Nonpublic note not appearing in the staff client) <b>Please check each of your frameworks to ensure your non-public item notes are mapped to items.itemnotes_nonpublic. After doing so please have your administrator run misc/batchRebuildItemsTables.pl </b>)\n";
    SetVersion($DBversion);
}

$DBversion = "3.19.00.028";
if( CheckVersion($DBversion) ) {
    eval {
        local $dbh->{PrintError} = 0;
        $dbh->do(q{
            ALTER TABLE issues DROP PRIMARY KEY
        });
    };

    $dbh->do(q{
        ALTER TABLE old_issues ADD issue_id INT( 11 ) NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST
    });

    $dbh->do(q{
        ALTER TABLE old_issues CHANGE issue_id issue_id INT( 11 ) NOT NULL
    });

    $dbh->do(q{
        ALTER TABLE issues ADD issue_id INT( 11 ) NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST
    });

    $dbh->do(q{
        UPDATE issues SET issue_id = issue_id + ( SELECT COUNT(*) FROM old_issues ) ORDER BY issue_id DESC
    });

    my $max_issue_id = $schema->resultset('Issue')->get_column('issue_id')->max();
    if ($max_issue_id) {
        $max_issue_id++;
        $dbh->do(qq{
            ALTER TABLE issues AUTO_INCREMENT = $max_issue_id
        });
    }

    print "Upgrade to $DBversion done (Bug 13790: Add unique id issue_id to issues and oldissues tables)\n";
    SetVersion($DBversion);
}

$DBversion = "3.19.00.029";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
         ALTER TABLE sessions CHANGE COLUMN a_session a_session MEDIUMTEXT
    |);
    print "Upgrade to $DBversion done (Bug 13606: Upgrade sessions.a_session to MEDIUMTEXT)\n";
    SetVersion($DBversion);
}

$DBversion = "3.19.00.030";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
UPDATE language_subtag_registry SET subtag = 'kn' WHERE subtag = 'ka' AND description = 'Kannada';
    |);
    $dbh->do(q|
UPDATE language_rfc4646_to_iso639 SET rfc4646_subtag = 'kn' WHERE rfc4646_subtag = 'ka' AND iso639_2_code = 'kan';
    |);
    $dbh->do(q|
UPDATE language_descriptions SET subtag = 'kn', lang = 'kn' WHERE subtag = 'ka' AND lang = 'ka' AND description = 'ಕನ್ನಡ';
    |);
    $dbh->do(q|
UPDATE language_descriptions SET subtag = 'kn' WHERE subtag = 'ka' AND description = 'Kannada';
    |);
    $dbh->do(q|
INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'ka', 'language', 'Georgian','2015-04-20');
    |);
    $dbh->do(q|
DELETE FROM language_subtag_registry
       WHERE NOT id IN
         (SELECT id FROM
           (SELECT MIN(id) as id,subtag,type,description,added
            FROM language_subtag_registry
            GROUP BY subtag,type,description,added)
           AS subtable);
    |);
    $dbh->do(q|
INSERT IGNORE INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES ( 'ka', 'geo');
    |);
    $dbh->do(q|
DELETE FROM language_rfc4646_to_iso639
       WHERE NOT id IN
         (SELECT id FROM
           (SELECT MIN(id) as id,rfc4646_subtag,iso639_2_code
            FROM language_rfc4646_to_iso639
            GROUP BY rfc4646_subtag,iso639_2_code)
           AS subtable);
    |);
    $dbh->do(q|
INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ka', 'language', 'ka', 'ქართული');
    |);
    $dbh->do(q|
INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ka', 'language', 'en', 'Georgian');
    |);
    $dbh->do(q|
INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ka', 'language', 'fr', 'Géorgien');
    |);
    $dbh->do(q|
INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ka', 'language', 'de', 'Georgisch');
    |);
    $dbh->do(q|
INSERT IGNORE INTO language_descriptions(subtag, type, lang, description) VALUES ( 'ka', 'language', 'es', 'Georgiano');
    |);
    $dbh->do(q|
DELETE FROM language_descriptions
       WHERE NOT id IN
         (SELECT id FROM
           (SELECT MIN(id) as id,subtag,type,lang,description
            FROM language_descriptions GROUP BY subtag,type,lang,description)
           AS subtable);
    |);
    print "Upgrade to $DBversion done (Bug 14030: Add Georgian language and fix Kannada language code)\n";
    SetVersion($DBversion);
}

$DBversion = "3.19.00.031";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
        VALUES('IdRef','0','Disable/enable the IdRef webservice from the OPAC detail page.',NULL,'YesNo')
    });
    print "Upgrade to $DBversion done (Bug 8992: Add system preference IdRef))\n";
    SetVersion($DBversion);
}

$DBversion = "3.19.00.032";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
        VALUES('AddressFormat','us','Choose format to display postal addresses','','Choice')
    |);
    print "Upgrade to $DBversion done (Bug 4041: Address Format as a I18N/L10N system preference\n";
    SetVersion ($DBversion);
}

$DBversion = "3.19.00.033";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        ALTER TABLE auth_header
        CHANGE COLUMN datemodified modification_time TIMESTAMP NOT NULL default CURRENT_TIMESTAMP
    |);
    $dbh->do(q|
        ALTER TABLE auth_header
        CHANGE COLUMN modification_time modification_time TIMESTAMP NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP
    |);
    print "Upgrade to $DBversion done (Bug 11165: Update auth_header.datemodified when updated)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.19.00.034";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
        VALUES('CardnumberLength', '', '', 'Set a length for card numbers.', 'Free')
    |);
    print "Upgrade to $DBversion done (Bug 13984: CardnumberLength syspref missing on some setups\n";
    SetVersion ($DBversion);
}

$DBversion = "3.19.00.035";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES('useDischarge','','Allows librarians to discharge borrowers and borrowers to request a discharge','','YesNo')
    |);
    $dbh->do(q|
        INSERT IGNORE INTO letter (module, code, name, title, content) VALUES('members', 'DISCHARGE', 'Discharge', 'Discharge for <<borrowers.firstname>> <<borrowers.surname>>', '<h1>Discharge</h1>\r\n\r\nThe library <<borrowers.branchcode>> certifies that the following borrower :\r\n\r\n    <<borrowers.firstname>> <<borrowers.surname>>\r\n   Cardnumber : <<borrowers.cardnumber>>\r\n\r\nreturned all his documents.')
    |);

    $dbh->do(q|
        ALTER TABLE borrower_debarments CHANGE type type ENUM('SUSPENSION','OVERDUES','MANUAL','DISCHARGE') NOT NULL DEFAULT 'MANUAL'
    |);

    $dbh->do(q|
        CREATE TABLE discharges (
          borrower int(11) DEFAULT NULL,
          needed timestamp NULL DEFAULT NULL,
          validated timestamp NULL DEFAULT NULL,
          KEY borrower_discharges_ibfk1 (borrower),
          CONSTRAINT borrower_discharges_ibfk1 FOREIGN KEY (borrower) REFERENCES borrowers (borrowernumber) ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
    |);

    print "Upgrade to $DBversion done (Bug 8007: Add System Preferences useDischarge, the discharge notice and the new table discharges)\n";
    SetVersion($DBversion);
}

$DBversion = "3.19.00.036";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
        VALUES ('CronjobLog','0',NULL,'If ON, log information from cron jobs.','YesNo')
    |);
    print "Upgrade to $DBversion done (Bug 13889: Add cron jobs information to system log)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.19.00.037";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        ALTER TABLE marc_subfield_structure
        MODIFY COLUMN tagsubfield varchar(1) COLLATE utf8_bin NOT NULL DEFAULT ''
    |);
    print "Upgrade to $DBversion done (Bug 13810: Change collate for tagsubfield (utf8_bin))\n";
    SetVersion ($DBversion);
}

$DBversion = "3.19.00.038";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        ALTER TABLE virtualshelves
        ADD COLUMN created_on DATETIME NOT NULL AFTER lastmodified
    |);
    # Set created_on = lastmodified
    # I would say it's better than 0000-00-00
    # Set modified to the existing value (do not get the current ts!)
    $dbh->do(q|
        UPDATE virtualshelves
        SET created_on = lastmodified, lastmodified = lastmodified
    |);
    print "Upgrade to $DBversion done (Bug 13421: Add DB field virtualshelves.created_on)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.19.00.039";
if ( CheckVersion($DBversion) ) {
    print "Upgrade to $DBversion done (Koha 3.20 beta)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.19.00.040";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        ALTER TABLE aqorders DROP COLUMN totalamount
    |);
    print "Upgrade to $DBversion done (Bug 11006: Drop column aqorders.totalamount)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.19.00.041";
if ( CheckVersion($DBversion) ) {
    unless ( index_exists( 'suggestions', 'status' ) ) {
        $dbh->do(q|
            ALTER TABLE suggestions ADD KEY status (STATUS)
        |);
    }
    unless ( index_exists( 'suggestions', 'biblionumber' ) ) {
        $dbh->do(q|
            ALTER TABLE suggestions ADD KEY biblionumber (biblionumber)
        |);
    }
    unless ( index_exists( 'suggestions', 'branchcode' ) ) {
        $dbh->do(q|
            ALTER TABLE suggestions ADD KEY branchcode (branchcode)
        |);
    }
    print "Upgrade to $DBversion done (Bug 14132: suggestions table is missing indexes)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.19.00.042";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        DELETE ass.*
        FROM auth_subfield_structure AS ass
        LEFT JOIN auth_types USING(authtypecode)
        WHERE auth_types.authtypecode IS NULL
    });

    unless ( foreign_key_exists( 'auth_subfield_structure', 'auth_subfield_structure_ibfk_1' ) ) {
        $dbh->do(q{
            ALTER TABLE auth_subfield_structure
            ADD CONSTRAINT auth_subfield_structure_ibfk_1
            FOREIGN KEY (authtypecode) REFERENCES auth_types(authtypecode)
            ON DELETE CASCADE ON UPDATE CASCADE
        });
    }

    print "Upgrade to $DBversion done (Bug 8480: Add foreign key on auth_subfield_structure.authtypecode)\n";
    SetVersion($DBversion);
}

$DBversion = "3.19.00.043";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        INSERT IGNORE INTO authorised_values (category, authorised_value, lib) VALUES
        ('REPORT_GROUP', 'SER', 'Serials')
    |);

    print "Upgrade to $DBversion done (Bug 5338: Add Serial to the report groups if does not exist)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.20.00.000";
if ( CheckVersion($DBversion) ) {
    print "Upgrade to $DBversion done (Koha 3.20)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.21.00.000";
if ( CheckVersion($DBversion) ) {
    print "Upgrade to $DBversion done (El tiempo vuela, un nuevo ciclo comienza.)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.21.00.001";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        UPDATE systempreferences SET variable='IntranetUserJS' where variable='intranetuserjs'
    |);
    print "Upgrade to $DBversion done (Bug 12160: Rename intranetuserjs to IntranetUserJS)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.21.00.002";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        UPDATE systempreferences SET variable='OPACUserJS' where variable='opacuserjs'
    |);
    print "Upgrade to $DBversion done (Bug 12160: Rename opacuserjs to OPACUserJS)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.21.00.003";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added)
        VALUES ( 'IN', 'region', 'India','2015-05-28');
    |);
    $dbh->do(q|
        INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
        VALUES ( 'IN', 'region', 'en', 'India');
    |);
    $dbh->do(q|
        INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
        VALUES ( 'IN', 'region', 'bn', 'ভারত');
    |);
    print "Upgrade to $DBversion done (Bug 14285: Add new region India)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.21.00.004';
if ( CheckVersion($DBversion) ) {
    my $OPACBaseURL = C4::Context->preference('OPACBaseURL');
    if (defined($OPACBaseURL) && substr($OPACBaseURL,0,4) ne "http") {
        my $explanation = q{Specify the Base URL of the OPAC, e.g., http://opac.mylibrary.com, including the protocol (http:// or https://). Otherwise, the http:// will be added automatically by Koha upon saving.};
        $OPACBaseURL = 'http://' . $OPACBaseURL;
        my $sth_OPACBaseURL = $dbh->prepare( q{
            UPDATE systempreferences SET value=?,explanation=?
            WHERE variable='OPACBaseURL'; } );
        $sth_OPACBaseURL->execute($OPACBaseURL,$explanation);
    }
    if (defined($OPACBaseURL)) {
        $dbh->do( q{ UPDATE letter
                     SET content=replace(content,
                                         'http://<<OPACBaseURL>>',
                                         '<<OPACBaseURL>>')
                     WHERE content LIKE "%http://<<OPACBaseURL>>%"; } );
    }

    print "Upgrade to $DBversion done (Bug 5010: Fix OPACBaseURL to include protocol)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.005";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
        VALUES ('ReportsLog','0',NULL,'If ON, log information about reports.','YesNo')
    |);
    print "Upgrade to $DBversion done (Bug 14024: Add reports to action logs)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.21.00.006";
if ( CheckVersion($DBversion) ) {
    # Remove the borrow permission flag (bit 7)
    $dbh->do(q|
        UPDATE borrowers
        SET flags = flags - ( flags & (1<<7) )
        WHERE flags IS NOT NULL
            AND flags > 0
    |);
    $dbh->do(q|
        DELETE FROM userflags WHERE bit=7;
    |);
    print "Upgrade to $DBversion done (Bug 7976: Remove the 'borrow' permission)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.007";
if ( CheckVersion($DBversion) ) {
    unless ( index_exists( 'aqbasket', 'authorisedby' ) ) {
        $dbh->do(q|
            ALTER TABLE aqbasket
                ADD KEY authorisedby (authorisedby)
        |);
    }
    unless ( index_exists( 'aqbooksellers', 'name' ) ) {
        $dbh->do(q|
            ALTER TABLE aqbooksellers
                ADD KEY name (name(255))
        |);
    }
    unless ( index_exists( 'aqbudgets', 'budget_parent_id' ) ) {
        $dbh->do(q|
            ALTER TABLE aqbudgets
                ADD KEY budget_parent_id (budget_parent_id)|);
        }
    unless ( index_exists( 'aqbudgets', 'budget_code' ) ) {
        $dbh->do(q|
            ALTER TABLE aqbudgets
                ADD KEY budget_code (budget_code)|);
    }
    unless ( index_exists( 'aqbudgets', 'budget_branchcode' ) ) {
        $dbh->do(q|
            ALTER TABLE aqbudgets
                ADD KEY budget_branchcode (budget_branchcode)|);
    }
    unless ( index_exists( 'aqbudgets', 'budget_period_id' ) ) {
        $dbh->do(q|
            ALTER TABLE aqbudgets
                ADD KEY budget_period_id (budget_period_id)|);
    }
    unless ( index_exists( 'aqbudgets', 'budget_owner_id' ) ) {
        $dbh->do(q|
            ALTER TABLE aqbudgets
                ADD KEY budget_owner_id (budget_owner_id)|);
    }
    unless ( index_exists( 'aqbudgets_planning', 'budget_period_id' ) ) {
        $dbh->do(q|
            ALTER TABLE aqbudgets_planning
                ADD KEY budget_period_id (budget_period_id)|);
    }
    unless ( index_exists( 'aqorders', 'parent_ordernumber' ) ) {
        $dbh->do(q|
            ALTER TABLE aqorders
                ADD KEY parent_ordernumber (parent_ordernumber)|);
    }
    unless ( index_exists( 'aqorders', 'orderstatus' ) ) {
        $dbh->do(q|
            ALTER TABLE aqorders
                ADD KEY orderstatus (orderstatus)|);
    }
    print "Upgrade to $DBversion done (Bug 14053: Acquisition db tables are missing indexes)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.21.00.008";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        DELETE IGNORE FROM systempreferences
        WHERE variable = 'HomeOrHoldingBranchReturn';
    });
    print "Upgrade to $DBversion done (Bug 7981: Transfer message on return. HomeOrHoldingBranchReturn syspref removed in favour of circulation rules.)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.009";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        UPDATE aqorders SET orderstatus='cancelled'
        WHERE (datecancellationprinted IS NOT NULL OR
               datecancellationprinted<>'0000-00-00');
    |);
    print "Upgrade to $DBversion done (Bug 13993: Correct orderstatus for transferred orders)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.010";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        ALTER TABLE message_queue
            DROP message_id
    |);
    $dbh->do(q|
        ALTER TABLE message_queue
            ADD message_id INT( 11 ) NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST
    |);
    print "Upgrade to $DBversion done (Bug 7793: redefine the field message_id as PRIMARY KEY of message_queue)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.21.00.011";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
        VALUES ('OpacLangSelectorMode','footer','top|both|footer','Select the location to display the language selector','Choice')
    });
    print "Upgrade to $DBversion done (Bug 14252: Make the OPAC language switcher available in the masthead navbar, footer, or both)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.21.00.012";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        INSERT INTO letter (module, code, name, title, content, message_transport_type)
        VALUES
        ('suggestions','TO_PROCESS','Notify fund owner', 'A suggestion is ready to be processed','Dear <<borrowers.firstname>> <<borrowers.surname>>,\n\nA new suggestion is ready to be processed: <<suggestions.title>> by <<suggestions.autho    r>>.\n\nThank you,\n\n<<branches.branchname>>', 'email')
    |);
    print "Upgrade to $DBversion done (Bug 13014: Add the TO_PROCESS letter code)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.013";
if ( CheckVersion($DBversion) ) {
    my $msg;
    if ( C4::Context->preference('OPACPrivacy') ) {
        if ( my $anonymous_patron = C4::Context->preference('AnonymousPatron') ) {
            my $anonymous_patron_exists = $dbh->selectcol_arrayref(q|
                SELECT COUNT(*)
                FROM borrowers
                WHERE borrowernumber=?
            |, {}, $anonymous_patron);
            unless ( $anonymous_patron_exists->[0] ) {
                $msg = "Configuration WARNING: OPACPrivacy is set but AnonymousPatron is not linked to an existing patron";
            }
        }
        else {
            $msg = "Configuration WARNING: OPACPrivacy is set but AnonymousPatron is not";
        }
    }
    else {
        my $patrons_have_required_anonymity = $dbh->selectcol_arrayref(q|
            SELECT COUNT(*)
            FROM borrowers
            WHERE privacy = 2
        |, {} );
        if ( $patrons_have_required_anonymity->[0] ) {
            $msg = "Configuration WARNING: OPACPrivacy is not set but $patrons_have_required_anonymity->[0] patrons have required anonymity (perhaps in a previous configuration). You should fix that asap.";
        }
    }

    $msg //= "Privacy is correctly set";
    print "Upgrade to $DBversion done (Bug 9942: $msg)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.21.00.014";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
        VALUES ('OAI-PMH:DeletedRecord','persistent','Koha\'s deletedbiblio table will never be deleted (persistent) or might be deleted (transient)','transient|persistent','Choice')
    });

    if ( foreign_key_exists( 'oai_sets_biblios', 'oai_sets_biblios_ibfk_1' ) ) {
        $dbh->do(q|
            ALTER TABLE oai_sets_biblios DROP FOREIGN KEY oai_sets_biblios_ibfk_1
        |);
    }
    print "Upgrade to $DBversion done (Bug 3206: OAI repository deleted record support)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.21.00.015";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        UPDATE systempreferences SET value='0' WHERE variable='CalendarFirstDayOfWeek' AND value='Sunday';
    });
    $dbh->do(q{
        UPDATE systempreferences SET value='1' WHERE variable='CalendarFirstDayOfWeek' AND value='Monday';
    });
    $dbh->do(q{
        UPDATE systempreferences SET options='0|1|2|3|4|5|6' WHERE variable='CalendarFirstDayOfWeek';
    });

    print "Upgrade to $DBversion done (Bug 12137: Extend functionality of CalendarFirstDayOfWeek to be any day)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.016";
if ( CheckVersion($DBversion) ) {
    my $rs = $schema->resultset('Systempreference');
    $rs->find_or_create(
        {
            variable => 'DumpTemplateVarsIntranet',
            value    => 0,
            explanation => 'If enabled, dump all Template Toolkit variable to a comment in the html source for the staff intranet.',
            type => 'YesNo',
        }
    );
    $rs->find_or_create(
        {
            variable => 'DumpTemplateVarsOpac',
            value    => 0,
            explanation => 'If enabled, dump all Template Toolkit variable to a comment in the html source for the opac.',
            type => 'YesNo',
        }
    );
    print "Upgrade to $DBversion done (Bug 13948: Add ability to dump template toolkit variables to html comment)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.017";
if ( CheckVersion($DBversion) ) {
    $dbh->do("
        CREATE TABLE uploaded_files (
            id int(11) NOT NULL AUTO_INCREMENT,
            hashvalue CHAR(40) NOT NULL,
            filename TEXT NOT NULL,
            dir TEXT NOT NULL,
            filesize int(11),
            dtcreated timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            categorycode tinytext,
            owner int(11),
            PRIMARY KEY (id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci
    ");

    print "Upgrade to $DBversion done (Bug 6874: New cataloging plugin upload.pl)\n";
    print "This plugin comes with a new config variable (upload_path) and a new table (uploaded_files)\n";
    print "To use it, set 'upload_path' config variable and 'OPACBaseURL' system preference and link this plugin to a subfield (856\$u for instance)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.018";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
        VALUES
            ('RestrictedPageLocalIPs','',NULL,'Beginning of IP addresses considered as local (comma separated ex: \"127.0.0,127.0.2\")','Free'),
            ('RestrictedPageContent','',NULL,'HTML content of the restricted page','TextArea'),
            ('RestrictedPageTitle','',NULL,'Title of the restricted page (breadcrumb and header)','Free')
    });
    print "Upgrade to $DBversion done (Bug 13485: Add a page to display links to restricted sites)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.21.00.019";
if ( CheckVersion($DBversion) ) {
    if ( column_exists( 'reserves', 'constrainttype' ) ) {
        $dbh->do(q{
            ALTER TABLE reserves DROP constrainttype
        });
        $dbh->do(q{
            ALTER TABLE old_reserves DROP constrainttype
        });
    }
    $dbh->do(q{
        DROP TABLE IF EXISTS reserveconstraints
    });
    print "Upgrade to $DBversion done (Bug 9809: Get rid of reserveconstraints)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.21.00.020";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO `systempreferences` (`variable`, `value`, `options`, `explanation`, `type`)
        VALUES ('FeeOnChangePatronCategory','1','','If set, when a patron changes to a category with enrolment fee, a fee is charged','YesNo')
    });
    print "Upgrade to $DBversion done (Bug 13697: Option to don't charge a fee, if the patron changes to a category with enrolment fee)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.021";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
        VALUES ('UseWYSIWYGinSystemPreferences','0','','Show WYSIWYG editor when editing certain HTML system preferences.','YesNo')
    });
    print "Upgrade to $DBversion done (Bug 11584: Add wysiwyg editor to system preferences dealing with HTML)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.022";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        DELETE cr.*
        FROM course_reserves AS cr
        LEFT JOIN course_items USING(ci_id)
        WHERE course_items.ci_id IS NULL
    });

    my ($print_error) = $dbh->{PrintError};
    $dbh->{RaiseError} = 0;
    $dbh->{PrintError} = 0;
    if ( foreign_key_exists('course_reserves', 'course_reserves_ibfk_2') ) {
        $dbh->do(q{ALTER TABLE course_reserves DROP FOREIGN KEY course_reserves_ibfk_2});
        $dbh->do(q{ALTER TABLE course_reserves DROP INDEX course_reserves_ibfk_2});
    }
    $dbh->{PrintError} = $print_error;

    $dbh->do(q{
        ALTER TABLE course_reserves
            ADD CONSTRAINT course_reserves_ibfk_2
                FOREIGN KEY (ci_id) REFERENCES course_items (ci_id)
                ON DELETE CASCADE ON UPDATE CASCADE
    });
    print "Upgrade to $DBversion done (Bug 14205: Deleting an Item/Record does not remove link to course reserve)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.023";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        UPDATE borrowers SET debarred=NULL WHERE debarred='0000-00-00'
    });
    $dbh->do(q{
        UPDATE borrowers SET dateexpiry=NULL where dateexpiry='0000-00-00'
    });
    $dbh->do(q{
        UPDATE borrowers SET dateofbirth=NULL where dateofbirth='0000-00-00'
    });
    $dbh->do(q{
        UPDATE borrowers SET dateenrolled=NULL where dateenrolled='0000-00-00'
    });
    print "Upgrade to $DBversion done (Bug 14717: Prevent 0000-00-00 dates in patron data)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.024";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        ALTER TABLE marc_modification_template_actions
        MODIFY COLUMN action
            ENUM('delete_field','update_field','move_field','copy_field','copy_and_replace_field')
            NOT NULL
    });
    print "Upgrade to $DBversion done (Bug 14098: Regression in Marc Modification Templates)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.025";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
        VALUES ('RisExportAdditionalFields',  '', NULL ,  'Define additional RIS tags to export from MARC records in YAML format as an associative array with either a marc tag/subfield combination as the value, or a list of tag/subfield combinations.',  'textarea')
    });
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
        VALUES ('BibtexExportAdditionalFields',  '', NULL ,  'Define additional BibTex tags to export from MARC records in YAML format as an associative array with either a marc tag/subfield combination as the value, or a list of tag/subfield combinations.',  'textarea')
    });
    print "Upgrade to $DBversion done (Bug 12357: Enhancements to RIS and BibTeX exporting)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.026";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        UPDATE matchpoints
        SET search_index='issn'
        WHERE matcher_id IN (SELECT matcher_id FROM marc_matchers WHERE code = 'ISSN')
    });
    print "Upgrade to $DBversion done (Bug 14472: Wrong ISSN search index in record matching rules)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.027";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        INSERT IGNORE INTO permissions (module_bit, code, description)
        VALUES (1, 'self_checkout', 'Perform self checkout at the OPAC. It should be used for the patron matching the AutoSelfCheckID')
    |);

    my $AutoSelfCheckID = C4::Context->preference('AutoSelfCheckID');

    $dbh->do(q|
        UPDATE borrowers
        SET flags=0
        WHERE userid=?
    |, undef, $AutoSelfCheckID);

    $dbh->do(q|
        DELETE FROM user_permissions
        WHERE borrowernumber=(SELECT borrowernumber FROM borrowers WHERE userid=?)
    |, undef, $AutoSelfCheckID);

    $dbh->do(q|
        INSERT INTO user_permissions(borrowernumber, module_bit, code)
        SELECT borrowernumber, 1, 'self_checkout' FROM borrowers WHERE userid=?
    |, undef, $AutoSelfCheckID);
    print "Upgrade to $DBversion done (Bug 14298: AutoSelfCheckID user should only be able to access SCO)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.028";
if ( CheckVersion($DBversion) ) {
    unless ( column_exists('uploaded_files', 'public') ) {
        $dbh->do(q{
            ALTER TABLE uploaded_files
                ADD COLUMN public tinyint,
                ADD COLUMN permanent tinyint
        });
        $dbh->do(q{
            UPDATE uploaded_files SET public=1, permanent=1
        });
        $dbh->do(q{
            ALTER TABLE uploaded_files
                CHANGE COLUMN categorycode uploadcategorycode tinytext
        });
    }
    print "Upgrade to $DBversion done (Bug 14321: Merge UploadedFile and UploadedFiles into Koha::Upload)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.029";
if ( CheckVersion($DBversion) ) {
    unless ( column_exists('discharges', 'discharge_id') ) {
        $dbh->do(q{
            ALTER TABLE discharges
                ADD COLUMN discharge_id int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST
        });
    }
    print "Upgrade to $DBversion done (Bug 14368: Add discharges history)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.030";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        UPDATE marc_subfield_structure
        SET value_builder='marc21_leader.pl'
        WHERE value_builder='marc21_leader_book.pl'
    });
    $dbh->do(q{
        UPDATE marc_subfield_structure
        SET value_builder='marc21_leader.pl'
        WHERE value_builder='marc21_leader_computerfile.pl'
    });
    $dbh->do(q{
        UPDATE marc_subfield_structure
        SET value_builder='marc21_leader.pl'
        WHERE value_builder='marc21_leader_video.pl'
    });
    print "Upgrade to $DBversion done (Bug 14201: Remove unused code or template from some MARC21 leader plugins )\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.031";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
        VALUES
            ('SMSSendPassword', '', '', 'Password used to send SMS messages', 'free'),
            ('SMSSendUsername', '', '', 'Username/Login used to send SMS messages', 'free')
    });
    print "Upgrade to $DBversion done (Bug 14820: SMSSendUsername and SMSSendPassword are not listed in the system preferences)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.032";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        CREATE TABLE additional_fields (
            id int(11) NOT NULL AUTO_INCREMENT,
            tablename varchar(255) NOT NULL DEFAULT '',
            name varchar(255) NOT NULL DEFAULT '',
            authorised_value_category varchar(16) NOT NULL DEFAULT '',
            marcfield varchar(16) NOT NULL DEFAULT '',
            searchable tinyint(1) NOT NULL DEFAULT '0',
            PRIMARY KEY (id),
            UNIQUE KEY fields_uniq (tablename,name)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci
    });
    $dbh->do(q{
        CREATE TABLE additional_field_values (
            id int(11) NOT NULL AUTO_INCREMENT,
            field_id int(11) NOT NULL,
            record_id int(11) NOT NULL,
            value varchar(255) NOT NULL DEFAULT '',
            PRIMARY KEY (id),
            UNIQUE KEY field_record (field_id,record_id),
            CONSTRAINT afv_fk FOREIGN KEY (field_id) REFERENCES additional_fields (id) ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci
    });
    print "Upgrade to $DBversion done (Bug 10855: Additional fields for subscriptions)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.033";
if ( CheckVersion($DBversion) ) {

    my $done = 0;
    my $count_ethnicity = $dbh->selectrow_arrayref(q|
        SELECT COUNT(*) FROM ethnicity
    |);
    my $count_borrower_modifications = $dbh->selectrow_arrayref(q|
        SELECT COUNT(*)
        FROM borrower_modifications
        WHERE ethnicity IS NOT NULL
            OR ethnotes IS NOT NULL
    |);
    my $count_borrowers = $dbh->selectrow_arrayref(q|
        SELECT COUNT(*)
        FROM borrowers
        WHERE ethnicity IS NOT NULL
            OR ethnotes IS NOT NULL
    |);
    # We don't care about the ethnicity of the deleted borrowers, right?
    if ( $count_ethnicity->[0] == 0
            and $count_borrower_modifications->[0] == 0
            and $count_borrowers->[0] == 0
    ) {
        $dbh->do(q|
            DROP TABLE ethnicity
        |);
        $dbh->do(q|
            ALTER TABLE borrower_modifications
            DROP COLUMN ethnicity,
            DROP COLUMN ethnotes
        |);
        $dbh->do(q|
            ALTER TABLE borrowers
            DROP COLUMN ethnicity,
            DROP COLUMN ethnotes
        |);
        $dbh->do(q|
            ALTER TABLE deletedborrowers
            DROP COLUMN ethnicity,
            DROP COLUMN ethnotes
        |);
        $done = 1;
    }
    if ( $done ) {
        print "Upgrade to $DBversion done (Bug 10020: Drop table ethnicity and columns ethnicity and ethnotes)\n";
    }
    else {
        print "Upgrade to $DBversion done (Bug 10020: This database contains data related to 'ethnicity'. No change will be done on the DB structure but note that the Koha codebase does not use it)\n";
    }

    SetVersion ($DBversion);
}

$DBversion = "3.21.00.034";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
        VALUES('MembershipExpiryDaysNotice',NULL,'Send an account expiration notice that a patron''s card is about to expire after',NULL,'Integer')
    });
    $dbh->do(q{
        INSERT IGNORE INTO letter (module, code, branchcode, name, title, content, message_transport_type)
        VALUES('members','MEMBERSHIP_EXPIRY','','Account expiration','Account expiration','Dear <<borrowers.title>> <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nYour library card will expire soon, on:\r\n\r\n<<borrowers.dateexpiry>>\r\n\r\nThank you,\r\n\r\nLibrarian\r\n\r\n<<branches.branchname>>', 'email')
    });
    print "Upgrade to $DBversion done (Bug 6810: Send membership expiry reminder notices)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.035";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        ALTER TABLE branch_borrower_circ_rules ADD COLUMN maxonsiteissueqty int(4) DEFAULT NULL AFTER maxissueqty;
    |);
    $dbh->do(q|
        UPDATE branch_borrower_circ_rules SET maxonsiteissueqty = maxissueqty;
    |);
    $dbh->do(q|
        ALTER TABLE default_borrower_circ_rules ADD COLUMN maxonsiteissueqty int(4) DEFAULT NULL AFTER maxissueqty;
    |);
    $dbh->do(q|
        UPDATE default_borrower_circ_rules SET maxonsiteissueqty = maxissueqty;
    |);
    $dbh->do(q|
        ALTER TABLE default_branch_circ_rules ADD COLUMN maxonsiteissueqty int(4) DEFAULT NULL AFTER maxissueqty;
    |);
    $dbh->do(q|
        UPDATE default_branch_circ_rules SET maxonsiteissueqty = maxissueqty;
    |);
    $dbh->do(q|
        ALTER TABLE default_circ_rules ADD COLUMN maxonsiteissueqty int(4) DEFAULT NULL AFTER maxissueqty;
    |);
    $dbh->do(q|
        UPDATE default_circ_rules SET maxonsiteissueqty = maxissueqty;
    |);
    $dbh->do(q|
        ALTER TABLE issuingrules ADD COLUMN maxonsiteissueqty int(4) DEFAULT NULL AFTER maxissueqty;
    |);
    $dbh->do(q|
        UPDATE issuingrules SET maxonsiteissueqty = maxissueqty;
    |);
    $dbh->do(q|
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
        VALUES ('ConsiderOnSiteCheckoutsAsNormalCheckouts','1',NULL,'Consider on-site checkouts as normal checkouts','YesNo');
    |);

    print "Upgrade to $DBversion done (Bug 14045: Add DB fields maxonsiteissueqty and pref ConsiderOnSiteCheckoutsAsNormalCheckouts)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.21.00.036";
if ( CheckVersion($DBversion) ) {
   $dbh->do(q{
        ALTER TABLE authorised_values_branches
        DROP FOREIGN KEY authorised_values_branches_ibfk_1,
        DROP FOREIGN KEY authorised_values_branches_ibfk_2
    });
    $dbh->do(q{
        ALTER TABLE authorised_values_branches
        MODIFY av_id INT( 11 ) NOT NULL,
        MODIFY branchcode VARCHAR( 10 ) NOT NULL,
        ADD FOREIGN KEY (`av_id`) REFERENCES `authorised_values` (`id`) ON DELETE CASCADE,
        ADD FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE
   });
   print "Upgrade to $DBversion done (Bug 10363: There is no package for authorised values)\n";
   SetVersion($DBversion);
}

$DBversion = "3.21.00.037";
if ( CheckVersion($DBversion) ) {
   $dbh->do(q{
       INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
       VALUES ('OverduesBlockRenewing','allow','If any of a patron checked out documents is late, should renewal be allowed, blocked only on overdue items or blocked on whatever checked out document','allow|blockitem|block','Choice')
   });
   $dbh->do(q{
       INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
       VALUES ('RestrictionBlockRenewing','0','If patron is restricted, should renewal be allowed or blocked',NULL,'YesNo')
    });
   print "Upgrade to $DBversion done (Bug 8236: Prevent renewing if overdue or restriction)\n";
   SetVersion($DBversion);
}

$DBversion = "3.21.00.038";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        INSERT IGNORE INTO systempreferences ( variable, value, options, explanation, type )
        VALUES ('BatchCheckouts','0','','Enable or disable batch checkouts','YesNo')
    |);
    $dbh->do(q|
        INSERT IGNORE INTO systempreferences ( variable, value, options, explanation, type )
        VALUES ('BatchCheckoutsValidCategories','',NULL,'Patron categories allowed to checkout in a batch','Free')
    |);
    print "Upgrade to $DBversion done (Bug 11759: Add the batch checkout feature)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.039";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        ALTER TABLE creator_layouts ADD COLUMN oblique_title INT(1) NULL DEFAULT 1 AFTER guidebox
    |);
    print "Upgrade to $DBversion done (Bug 12194: Add column oblique_title to layouts)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.040";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        ALTER TABLE itemtypes
            ADD hideinopac TINYINT(1) NOT NULL DEFAULT 0
              AFTER sip_media_type,
            ADD searchcategory VARCHAR(80) DEFAULT NULL
              AFTER hideinopac;
    });
    print "Upgrade to $DBversion done (Bug 10937: Option to hide and group itemtypes from advanced search)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.041";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        ALTER TABLE issuingrules
            ADD chargeperiod_charge_at BOOLEAN NOT NULL DEFAULT  '0' AFTER chargeperiod
    |);
    print "Upgrade to $DBversion done (Bug 13590: Add ability to charge fines at start of charge period)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.042";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        ALTER TABLE items_search_fields
            MODIFY COLUMN authorised_values_category VARCHAR(32) DEFAULT NULL
    |);
    print "Upgrade to $DBversion done (Bug 15069: items_search_fields.authorised_values_category is still a varchar(32))\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.043";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        INSERT IGNORE INTO systempreferences ( variable, value, options, explanation, type )
        VALUES ('EnableAdvancedCatalogingEditor','0','','Enable the Rancor advanced cataloging editor','YesNo')
    |);
    print "Upgrade to $DBversion done (Bug 11559: Professional cataloger's interface)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.044";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        CREATE TABLE localization (
            localization_id int(11) NOT NULL AUTO_INCREMENT,
            entity varchar(16) COLLATE utf8_unicode_ci NOT NULL,
            code varchar(64) COLLATE utf8_unicode_ci NOT NULL,
            lang varchar(25) COLLATE utf8_unicode_ci NOT NULL,
            translation text COLLATE utf8_unicode_ci,
            PRIMARY KEY (localization_id),
            UNIQUE KEY entity_code_lang (entity,code,lang)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci
    |);
    print "Upgrade to $DBversion done (Bug 14100: Generic solution for language overlay)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.045";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        ALTER TABLE opac_news
            ADD borrowernumber int(11) default NULL
                AFTER number
    |);
    $dbh->do(q|
        ALTER TABLE opac_news
            ADD CONSTRAINT borrowernumber_fk
                FOREIGN KEY (borrowernumber)
                REFERENCES borrowers (borrowernumber)
                ON DELETE SET NULL ON UPDATE CASCADE
    |);
    print "Upgrade to $DBversion done (Bug 14246: (newsauthor) Add borrowernumber to koha_news)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.046";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( variable, value, options, explanation, type )
        VALUES ('NewsAuthorDisplay','none','none|opac|staff|both','Display the author name for news items.','Choice')
    });
    print "Upgrade to $DBversion done (Bug 14247: (newsauthor) System preference for news author display)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.047";
if(CheckVersion($DBversion)) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
        VALUES ('IndependentBranchesPatronModifications','0','Show only modification request for the logged in branch','','YesNo')
    });
    print "Upgrade to $DBversion done (Bug 10904: Limit patron update request management by branch)\n";
    SetVersion($DBversion);
}

$DBversion = '3.21.00.048';
if ( CheckVersion($DBversion) ) {
    my $create_table_issues = @{ $dbh->selectall_arrayref(q|SHOW CREATE TABLE issues|) }[0]->[1];
    if ($create_table_issues !~ m|UNIQUE KEY.*itemnumber| ) {
        $dbh->do(q|ALTER TABLE issues ADD CONSTRAINT UNIQUE KEY (itemnumber)|);
    }
    print "Upgrade to $DBversion done (Bug 14978: Make sure issues.itemnumber is a unique key)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.049";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{UPDATE systempreferences SET variable = 'AudioAlerts' WHERE variable = 'soundon'});

    $dbh->do(q{
        CREATE TABLE audio_alerts (
            id int(11) NOT NULL AUTO_INCREMENT,
            precedence smallint(5) unsigned NOT NULL,
            selector varchar(255) NOT NULL,
            sound varchar(255) NOT NULL,
            PRIMARY KEY (id),
            KEY precedence (precedence)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
    });

    $dbh->do(q{
        INSERT IGNORE INTO audio_alerts VALUES
        (1, 1, '.audio-alert-action', 'opening.ogg'),
        (2, 2, '.audio-alert-warning', 'critical.ogg'),
        (3, 3, '.audio-alert-success', 'beep.ogg');
    });

    print "Upgrade to $DBversion done (Bug 11431: Add additional sound options for warnings)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.050";
if(CheckVersion($DBversion)) {
    $dbh->do(q{
        INSERT INTO letter ( module, code, branchcode, name, is_html, title, content, message_transport_type )
        VALUES ( 'circulation', 'OVERDUES_SLIP', '', 'Overdues Slip', '0', 'OVERDUES_SLIP', 'The following item(s) is/are currently overdue:

<item>"<<biblio.title>>" by <<biblio.author>>, <<items.itemcallnumber>>, Barcode: <<items.barcode>> Fine: <<items.fine>></item>
', 'print' )
    });
    print "Upgrade to $DBversion done (Bug 12933: Add ability to print overdue slip from staff intranet)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.051";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        ALTER TABLE virtualshelves
            CHANGE COLUMN sortfield sortfield VARCHAR(16) DEFAULT 'title'
    });
    $dbh->do(q{
        UPDATE virtualshelves
        SET sortfield='title'
            WHERE sortfield IS NULL;
    });
    print "Upgrade to $DBversion done (Bug 14544: Move the list related code to Koha::Virtualshelves)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.052";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        ALTER TABLE serial
            ADD COLUMN publisheddatetext VARCHAR(100) DEFAULT NULL AFTER publisheddate
    });
    print "Upgrade to $DBversion done (Bug 8296: Add descriptive (text) published date field for serials)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.053";
if ( CheckVersion($DBversion) ) {
    my $query = q{ SELECT * FROM itemtypes ORDER BY description };
    my $sth   = C4::Context->dbh->prepare($query);
    $sth->execute;
    my $suggestion_formats = $sth->fetchall_arrayref( {} );

    foreach my $format (@$suggestion_formats) {
        $dbh->do(
            q|
            INSERT IGNORE INTO authorised_values (category, authorised_value, lib, lib_opac, imageurl)
            VALUES (?, ?, ?, ?, ?)
        |, {},
            'SUGGEST_FORMAT', $format->{itemtype}, $format->{description}, $format->{description},
            $format->{imageurl}
        );
    }
    print "Upgrade to $DBversion done (Bug 9468: create new SUGGEST_FORMAT authorised_value list)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.054";
if(CheckVersion($DBversion)) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
        VALUES('MergeReportFields','','Displayed fields for deleted MARC records after merge',NULL,'Free')
    });
    print "Upgrade to $DBversion done (Bug 8064: Merge several biblio records)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.055";
if ( CheckVersion($DBversion) ) {
    print "Upgrade to $DBversion done (Koha 3.22 beta)\n";
    SetVersion($DBversion);
}

$DBversion = "3.21.00.056";
if(CheckVersion($DBversion)) {
    $dbh->do(q{
        UPDATE systempreferences
        SET
            options='metric|us|iso|dmydot',
            explanation='Define global date format (us mm/dd/yyyy, metric dd/mm/yyy, ISO yyyy-mm-dd, DMY separated by dots dd.mm.yyyy)'
        WHERE variable='dateformat'
    });
    print "Upgrade to $DBversion done (Bug 12072: New dateformat dd.mm.yyyy)\n";
    SetVersion($DBversion);
}

$DBversion = "3.22.00.000";
if ( CheckVersion($DBversion) ) {
    print "Upgrade to $DBversion done (Koha 3.22)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.000";
if ( CheckVersion($DBversion) ) {
    print "Upgrade to $DBversion done (The year of the monkey will be here soon.)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.23.00.001";
if(CheckVersion($DBversion)) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( variable, value, options, explanation, type )
        VALUES (
            'DefaultToLoggedInLibraryCircRules',  '0', NULL ,  'If enabled, circ rules editor will default to the logged in library''s rules, rather than the ''all libraries'' rules.',  'YesNo'
        ), (
            'DefaultToLoggedInLibraryNoticesSlips',  '0', NULL ,  'If enabled,slips and notices editor will default to the logged in library''s rules, rather than the ''all libraries'' rules.',  'YesNo'
        )
    });

    print "Upgrade to $DBversion done (Bug 11625 - Add pref DefaultToLoggedInLibraryCircRules and DefaultToLoggedInLibraryNoticesSlips)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.002";
if(CheckVersion($DBversion)) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( variable, value, options, explanation, type )
        VALUES ('DefaultToLoggedInLibraryOverdueTriggers',  '0', NULL,  'If enabled, overdue status triggers editor will default to the logged in library''s rules, rather than the ''default'' rules.',  'YesNo')
    });

    print "Upgrade to $DBversion done (Bug 11747 - add pref DefaultToLoggedInLibraryOverdueTriggers)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.003";
if(CheckVersion($DBversion)) {
    $dbh->do(q{
        UPDATE letter SET name = "Hold Slip" WHERE name = "Reserve Slip"
    });
    $dbh->do(q{
        UPDATE letter SET title = "Hold Slip" WHERE title = "Reserve Slip";
    });

    print "Upgrade to $DBversion done (Bug 8085 - Rename 'Reserve slip' to 'Hold slip')\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.004";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        DROP TABLE IF EXISTS `stopwords`;
    });
    print "Upgrade to $DBversion done (Bug 9819 - stopwords related code should be removed)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.005";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        UPDATE permissions SET description = 'Manage circulation rules' WHERE description = 'manage circulation rules'
    });
    $dbh->do(q{
        UPDATE permissions SET description = 'Manage staged MARC records, including completing and reversing imports' WHERE description = 'Managed staged MARC records, including completing and reversing imports'
    });
    print "Upgrade to $DBversion done (Bug 11569 - Typo in userpermissions.sql)\n";
    SetVersion($DBversion);
}
$DBversion = "3.23.00.006";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
   $dbh->do("
       ALTER TABLE serial
        ADD serialseq_x VARCHAR( 100 ) NULL DEFAULT NULL AFTER serialseq,
        ADD serialseq_y VARCHAR( 100 ) NULL DEFAULT NULL AFTER serialseq_x,
        ADD serialseq_z VARCHAR( 100 ) NULL DEFAULT NULL AFTER serialseq_y
   ");

    my $sth = $dbh->prepare("SELECT * FROM subscription");
    $sth->execute();

    my $sth2 = $dbh->prepare("SELECT * FROM subscription_numberpatterns WHERE id = ?");

    my $sth3 = $dbh->prepare("UPDATE serial SET serialseq_x = ?, serialseq_y = ?, serialseq_z = ? WHERE serialid = ?");

    foreach my $subscription ( $sth->fetchrow_hashref() ) {
        next if !defined($subscription);
        $sth2->execute( $subscription->{numberpattern} );
        my $number_pattern = $sth2->fetchrow_hashref();

        my $numbering_method = $number_pattern->{numberingmethod};
        # Get all the data between the enumeration values, we need
        # to split each enumeration string based on these values.
        my @splits = split( /\{[XYZ]\}/, $numbering_method );
        # Get the order in which the X Y and Z values are used
        my %indexes;
        foreach my $i (qw(X Y Z)) {
            $indexes{$i} = index( $numbering_method, "{$i}" );
            delete $indexes{$i} if $indexes{$i} == -1;
        }
        my @indexes = sort { $indexes{$a} <=> $indexes{$b} } keys(%indexes);

        my @serials = @{
            $dbh->selectall_arrayref(
                "SELECT * FROM serial WHERE subscriptionid = $subscription->{subscriptionid}",
                { Slice => {} }
            )
        };

        foreach my $serial (@serials) {
            my $serialseq = $serial->{serialseq};
            my %enumeration_data;

            ## We cannot split on multiple values at once,
            ## so let's replace each of those values with __SPLIT__
            if (@splits) {
                for my $split_item (@splits) {
                    my $quoted_split = quotemeta($split_item);
                    $serialseq =~ s/$quoted_split/__SPLIT__/;
                }
                (
                    undef,
                    $enumeration_data{ $indexes[0] // q{} },
                    $enumeration_data{ $indexes[1] // q{} },
                    $enumeration_data{ $indexes[2] // q{} }
                ) = split( /__SPLIT__/, $serialseq );
            }
            else
            {    ## Nothing to split on means the only thing in serialseq is a single placeholder e.g. {X}
                $enumeration_data{ $indexes[0] } = $serialseq;
            }

            $sth3->execute(
                    $enumeration_data{'X'},
                    $enumeration_data{'Y'},
                    $enumeration_data{'Z'},
                    $serial->{serialid},
            );
        }
    }

    print "Upgrade to $DBversion done ( Bug 8956 - Split serials enumeration data into separate fields )\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.007";
if ( CheckVersion($DBversion) ) {
    $dbh->do("SET FOREIGN_KEY_CHECKS=0");
    $dbh->do("ALTER TABLE overduerules RENAME old_overduerules");
    $dbh->do("CREATE TABLE overduerules (
        `overduerules_id` int(11) NOT NULL AUTO_INCREMENT,
        `branchcode` varchar(10) NOT NULL DEFAULT '',
        `categorycode` varchar(10) NOT NULL DEFAULT '',
        `delay1` int(4) DEFAULT NULL,
        `letter1` varchar(20) DEFAULT NULL,
        `debarred1` varchar(1) DEFAULT '0',
        `delay2` int(4) DEFAULT NULL,
        `debarred2` varchar(1) DEFAULT '0',
        `letter2` varchar(20) DEFAULT NULL,
        `delay3` int(4) DEFAULT NULL,
        `letter3` varchar(20) DEFAULT NULL,
        `debarred3` int(1) DEFAULT '0',
        PRIMARY KEY (`overduerules_id`),
        UNIQUE KEY `overduerules_branch_cat` (`branchcode`,`categorycode`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
    $dbh->do("INSERT INTO overduerules(branchcode, categorycode, delay1, letter1, debarred1, delay2, debarred2, letter2, delay3, letter3, debarred3) SELECT * FROM old_overduerules");
    $dbh->do("DROP TABLE old_overduerules");
    $dbh->do("ALTER TABLE overduerules_transport_types
              ADD COLUMN overduerules_id int(11) NOT NULL");
    my $mtts = $dbh->selectall_arrayref("SELECT * FROM overduerules_transport_types", { Slice => {} });
    $dbh->do("DELETE FROM overduerules_transport_types");
    $dbh->do("ALTER TABLE overduerules_transport_types
              DROP FOREIGN KEY overduerules_fk,
              ADD FOREIGN KEY overduerules_transport_types_fk (overduerules_id) REFERENCES overduerules (overduerules_id) ON DELETE CASCADE ON UPDATE CASCADE,
              DROP COLUMN branchcode,
              DROP COLUMN categorycode");
    my $s = $dbh->prepare("INSERT INTO overduerules_transport_types (overduerules_id, id, letternumber, message_transport_type) "
                         ." VALUES((SELECT overduerules_id FROM overduerules WHERE branchcode = ? AND categorycode = ?),?,?,?)");
    foreach my $mtt(@$mtts){
        $s->execute($mtt->{branchcode}, $mtt->{categorycode}, $mtt->{id}, $mtt->{letternumber}, $mtt->{message_transport_type} );
    }
    $dbh->do("SET FOREIGN_KEY_CHECKS=1");

    print "Upgrade to $DBversion done (Bug 13624 - Remove columns branchcode, categorytype from table overduerules_transport_types)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.008";
if ( CheckVersion($DBversion) ) {

    $dbh->do(q{ALTER TABLE borrowers ADD privacy_guarantor_checkouts BOOLEAN NOT NULL DEFAULT '0' AFTER privacy});

    $dbh->do(q{ALTER TABLE deletedborrowers ADD privacy_guarantor_checkouts BOOLEAN NOT NULL DEFAULT '0' AFTER privacy});

    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type )
        VALUES (
            'AllowStaffToSetCheckoutsVisibilityForGuarantor',  '0', NULL,
            'If enabled, library staff can set a patron''s checkouts to be visible to linked patrons from the opac.',  'YesNo'
        ), (
            'AllowPatronToSetCheckoutsVisibilityForGuarantor',  '0', NULL,
            'If enabled, the patron can set checkouts to be visible to  his or her guarantor',  'YesNo'
        )
    });

    print "Upgrade to $DBversion done (Bug 9303 - relative's checkouts in the opac)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.009";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type ) VALUES
        ( 'EnablePayPalOpacPayments',  '0', NULL ,  'Enables the ability to pay fees and fines from  the OPAC via PayPal',  'YesNo' ),
        ( 'PayPalChargeDescription',  'Koha fee payment', NULL ,  'This preference defines what the user will see the charge listed as in PayPal',  'Free' ),
        ( 'PayPalPwd',  '', NULL ,  'Your PayPal API password',  'Free' ),
        ( 'PayPalSandboxMode',  '1', NULL ,  'If enabled, the system will use PayPal''s sandbox server for testing, rather than the production server.',  'YesNo' ),
        ( 'PayPalSignature',  '', NULL ,  'Your PayPal API signature',  'Free' ),
        ( 'PayPalUser',  '', NULL ,  'Your PayPal API username ( email address )',  'Free' )
    });

    print "Upgrade to $DBversion done (Bug 11622 - Add ability to pay fees and fines from OPAC via PayPal)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.010";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        ALTER TABLE issuingrules ADD cap_fine_to_replacement_price BOOLEAN NOT NULL DEFAULT '0' AFTER overduefinescap
    });

    print "Upgrade to $DBversion done (Bug 9129 - Add the ability to set the maximum fine for an item to its replacement price)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.011";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES ('HoldFeeMode','not_always','always|not_always','Set the hold fee mode','Choice')
    });

    print "Upgrade to $DBversion done (Bug 13592 - Hold fee not being applied on placing a hold)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.012";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `explanation`, `options`, `type` ) VALUES('MaxSearchResultsItemsPerRecordStatusCheck','20','Max number of items per record for which to check transit and hold status','','Integer')
    });

    print "Upgrade to $DBversion done (Bug 15380 - Move the authority types related code to Koha::Authority::Type[s] - part 1)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.013";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES ('StoreLastBorrower','0','','If ON, the last borrower to return an item will be stored in items.last_returned_by','YesNo')
    });
    $dbh->do(q{
	CREATE TABLE IF NOT EXISTS `items_last_borrower` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `itemnumber` int(11) NOT NULL,
  `borrowernumber` int(11) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `itemnumber` (`itemnumber`),
  KEY `borrowernumber` (`borrowernumber`),
  CONSTRAINT `items_last_borrower_ibfk_2` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `items_last_borrower_ibfk_1` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci
    });

    print "Upgrade to $DBversion done (Bug 14945 - Add the ability to store the last patron to return an item)\n";
    SetVersion($DBversion);

}

$DBversion = "3.23.00.014";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` )
VALUES ('ClaimsBccCopy','0','','Bcc the ClaimAcquisition and ClaimIssues alerts','YesNo')
    });

    print "Upgrade to $DBversion done (Bug 10076 - Add Bcc syspref for claimacquisition and clamissues)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.015";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        UPDATE letter SET code = "HOLD_SLIP" WHERE code = "RESERVESLIP";
    });

    print "Upgrade to $DBversion done (Bug 15443 - Re-code RESERVESLIP as HOLD_SLIP)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.016";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
    INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
    VALUES ('OpacResetPassword',  '0','','Shows the ''Forgot your password?'' link in the OPAC','YesNo');
});
    $dbh->do(q{
    CREATE TABLE IF NOT EXISTS borrower_password_recovery (
      borrowernumber int(11) NOT NULL,
      uuid varchar(128) NOT NULL,
      valid_until timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (borrowernumber),
      KEY borrowernumber (borrowernumber)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
});
    $dbh->do(q{
    INSERT IGNORE INTO `letter` (module, code, branchcode, name, is_html, title, content, message_transport_type)
    VALUES ('members','PASSWORD_RESET','','Online password reset',1,'Koha password recovery','<html>\r\n<p>This email has been sent in response to your password recovery request for the account <strong><<user>></strong>.\r\n</p>\r\n<p>\r\nYou can now create your new password using the following link:\r\n<br/><a href=\"<<passwordreseturl>>\"><<passwordreseturl>></a>\r\n</p>\r\n<p>This link will be valid for 2 days from this email\'s reception, then you must reapply if you do not change your password.</p>\r\n<p>Thank you.</p>\r\n</html>\r\n','email');

    });

    print "Upgrade to $DBversion done (Bug 8753 - Add forgot password link to OPAC)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.017";
if ( CheckVersion($DBversion) ) {

$dbh->do(q{
    DELETE FROM uploaded_files
    WHERE COALESCE(permanent,0)=0 AND dir='koha_upload'
});

my $tmp= File::Spec->tmpdir.'/koha_upload';
remove_tree( $tmp ) if -d $tmp;

    print "Upgrade to $DBversion done (Bug 14893 - Separate temporary storage per instance in Upload.pm)\n";
    SetVersion($DBversion);

}

$DBversion = "3.23.00.018";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        UPDATE systempreferences SET value="0" where type="YesNo" and value="";
    });

    print "Upgrade to $DBversion done (Bug 15446 - Fix systempreferences rows where type=YesNo and value='')\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.019";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        UPDATE `authorised_values` SET `lib`='Non-fiction' WHERE `lib`='Non Fiction';
    });

    print "Upgrade to $DBversion done (Bug 15411 - Change Non Fiction to Non-fiction in authorised_values)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.020";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        CREATE TABLE  sms_providers (
           id INT( 11 ) NOT NULL AUTO_INCREMENT PRIMARY KEY ,
           name VARCHAR( 255 ) NOT NULL ,
           domain VARCHAR( 255 ) NOT NULL ,
           UNIQUE (
               name
           )
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
    });

    $dbh->do(q{
        ALTER TABLE borrowers ADD sms_provider_id INT( 11 ) NULL DEFAULT NULL AFTER smsalertnumber;
    });
    $dbh->do(q{
        ALTER TABLE borrowers ADD FOREIGN KEY ( sms_provider_id ) REFERENCES sms_providers ( id ) ON UPDATE CASCADE ON DELETE SET NULL;
    });
    $dbh->do(q{
        ALTER TABLE deletedborrowers ADD sms_provider_id INT( 11 ) NULL DEFAULT NULL AFTER smsalertnumber;
    });

    print "Upgrade to $DBversion done (Bug 9021 - Add SMS via email as an alternative to SMS services via SMS::Send drivers)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.021";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES ('ShowAllCheckins', '0', '', 'Show all checkins', 'YesNo');
    });

    print "Upgrade to $DBversion done (Bug 15736 - Add a preference to control whether all items should be shown in checked-in items list)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.022";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{ ALTER TABLE tags_all MODIFY COLUMN borrowernumber INT(11) });
    $dbh->do(q{ ALTER TABLE tags_all drop FOREIGN KEY tags_borrowers_fk_1 });
    $dbh->do(q{ ALTER TABLE tags_all ADD CONSTRAINT `tags_borrowers_fk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE });
    $dbh->do(q{ ALTER TABLE tags_approval DROP FOREIGN KEY tags_approval_borrowers_fk_1 });
    $dbh->do(q{ ALTER TABLE tags_approval ADD CONSTRAINT `tags_approval_borrowers_fk_1` FOREIGN KEY (`approved_by`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE });

    print "Upgrade to $DBversion done (Bug 13534 - Deleting staff patron will delete tags approved by this patron)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.023";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
        VALUES('OpenLibrarySearch','0','If Yes Open Library search results will show in OPAC',NULL,'YesNo');
    });

    print "Upgrade to $DBversion done (Bug 6624 - Allow Koha to use the new read API from OpenLibrary)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.024";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        ALTER TABLE deletedborrowers MODIFY COLUMN userid VARCHAR(75) DEFAULT NULL;
    });

    $dbh->do(q{
        ALTER TABLE deletedborrowers MODIFY COLUMN password VARCHAR(60) DEFAULT NULL;
    });

    print "Upgrade to $DBversion done (Bug 15517 - Tables borrowers and deletedborrowers differ again)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.025";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        DROP TABLE IF EXISTS nozebra;
    });

    print "Upgrade to $DBversion done (Bug 15526 - Drop nozebra database table)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.026";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        UPDATE systempreferences SET value = CONCAT_WS('|', IF(value='', NULL, value), "password") WHERE variable="PatronSelfRegistrationBorrowerUnwantedField" AND value NOT LIKE "%password%";
    });

    print "Upgrade to $DBversion done (Bug 15343 - Allow patrons to choose their own password on self registration)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.027";
if ( CheckVersion($DBversion) ) {
    my ( $db_value ) = $dbh->selectrow_array(q|SELECT count(*) FROM branches|);
    my $pref_value = C4::Context->preference("singleBranchMode") || 0;
    if ( $db_value > 1 and $pref_value == 1 ) {
        warn "WARNING: You have more than 1 libraries in your branches tables but the singleBranchMode system preference is on.\n";
        warn "This configuration does not make sense. The system preference is going to be deleted,\n";
        warn "and this parameter will be based on the number of libraries defined.\n";
    }
    $dbh->do(q|DELETE FROM systempreferences WHERE variable="singleBranchMode"|);

    print "Upgrade to $DBversion done (Bug 4941 - Can't set branch in staff client when singleBranchMode is enabled)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.028";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) SELECT 'PatronSelfModificationBorrowerUnwantedField',value,NULL,'Name the fields you don\'t want to display when a patron is editing their information via the OPAC.','free' FROM systempreferences WHERE variable = 'PatronSelfRegistrationBorrowerUnwantedField';
    });

    print "Upgrade to $DBversion done (Bug 14658 - Split PatronSelfRegistrationBorrowerUnwantedField into two preferences for creating and editing)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.029";
if ( CheckVersion($DBversion) ) {

    # move marc21_field_003.pl 040c and 040d to marc21_orgcode.pl
    $dbh->do(q{
        update marc_subfield_structure set value_builder='marc21_orgcode.pl' where value_builder IN ( 'marc21_field_003.pl', 'marc21_field_040c.pl', 'marc21_field_040d.pl' );
    });
    $dbh->do(q{
        update auth_subfield_structure set value_builder='marc21_orgcode.pl' where value_builder IN ( 'marc21_field_003.pl', 'marc21_field_040c.pl', 'marc21_field_040d.pl' );
    });

    print "Upgrade to $DBversion done (Bug 14199 - Unify all organization code plugins)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.030";
if(CheckVersion($DBversion)) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
        VALUES ('OpacMaintenanceNotice','','','A user-defined block of HTML to appear on screen when OpacMaintenace is enabled','Textarea')
    });

    print "Upgrade to $DBversion done (Bug 15311: Let libraries set text to display when OpacMaintenance = on)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.031";
if(CheckVersion($DBversion)) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
        VALUES ('NoRenewalBeforePrecision', 'date', 'Calculate "No renewal before" based on date or exact time. Only relevant for loans calculated in days, hourly loans are not affected.', 'date|exact_time', 'Choice')
    });

    print "Upgrade to $DBversion done (Bug 14395 - Two different ways to calculate 'No renewal before')\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.032";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
   -- Add issue_id to accountlines table
    ALTER TABLE accountlines ADD issue_id INT(11) NULL DEFAULT NULL AFTER accountlines_id;
    });

## Close out any accruing fines with no current issue
    $dbh->do(q{
    UPDATE accountlines LEFT JOIN issues USING ( itemnumber, borrowernumber ) SET accounttype = 'F' WHERE accounttype = 'FU' and issues.issue_id IS NULL;
    });

## Close out any extra not really accruing fines, keep only the latest accring fine
    $dbh->do(q{
    UPDATE accountlines a1
    LEFT JOIN (SELECT MAX(accountlines_id) AS keeper,
                      borrowernumber,
                      itemnumber
               FROM   accountlines
               WHERE  accounttype = 'FU'
               GROUP BY borrowernumber, itemnumber
              ) a2 USING ( borrowernumber, itemnumber )
    SET    a1.accounttype = 'F'
    WHERE  a1.accounttype = 'FU'
    AND  a1.accountlines_id != a2.keeper;
    });

## Update the unclosed fines to add the current issue_id to them
    $dbh->do(q{
    UPDATE accountlines LEFT JOIN issues USING ( itemnumber ) SET accountlines.issue_id = issues.issue_id WHERE accounttype = 'FU'; 
    });

    print "Upgrade to $DBversion done (Bug 15675 - Add issue_id column to accountlines and use it for updating fines)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.033";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
    UPDATE systempreferences SET value = CONCAT_WS('|', IF(value = '', NULL, value), 'cardnumber') WHERE variable = 'PatronSelfRegistrationBorrowerUnwantedField' AND value NOT LIKE '%cardnumber%';
    });

    $dbh->do(q{
    UPDATE systempreferences SET value = CONCAT_WS('|', IF(value = '', NULL, value), 'categorycode') WHERE variable = 'PatronSelfRegistrationBorrowerUnwantedField' AND value NOT LIKE '%categorycode%';
    });

    print "Upgrade to $DBversion done (Bug 14659 - Allow patrons to enter card number and patron category on OPAC registration page)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.034";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do(q{
        ALTER TABLE `items` ADD `new` VARCHAR(32) NULL AFTER `stocknumber`;
    });
    $dbh->do(q{
        ALTER TABLE `deleteditems` ADD `new` VARCHAR(32) NULL AFTER `stocknumber`;
    });
    print "Upgrade to $DBversion done (Bug 11023: Adds field 'new' in items and deleteditems tables)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.035";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES ('HTML5MediaYouTube',0,'Embed|Don\'t embed','YouTube links as videos','YesNo');
    });
    print "Upgrade to $DBversion done (Bug 14168 - enhance streaming cataloging to include youtube)\n";

    SetVersion($DBversion);
    }

$DBversion = "3.23.00.036";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do(q{
    INSERT IGNORE INTO systempreferences (variable,value,explanation,type) VALUES ('HoldsQueueSkipClosed', '0', 'If enabled, any libraries that are closed when the holds queue is built will be ignored for the purpose of filling holds.', 'YesNo');
    });
    print "Upgrade to $DBversion done (Bug 12803 - Add ability to skip closed libraries when generating the holds queue)\n";
    SetVersion($DBversion);
    }

$DBversion = "3.23.00.037";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
## Add the new currency.archived column
    $dbh->do(q{
    ALTER TABLE currency ADD column archived tinyint(1) DEFAULT 0;
    });
## Set currency=NULL if empty (just in case)
    $dbh->do(q{
    UPDATE aqorders SET currency=NULL WHERE currency="";
    });
## Insert the missing currency and mark them as archived before adding the FK
    $dbh->do(q{
    INSERT INTO currency(currency, archived) SELECT distinct currency, 1 FROM aqorders WHERE currency NOT IN (SELECT currency FROM currency);
    });
## Correct the field length in aqorders before adding FK too
    $dbh->do(q{ ALTER TABLE aqorders MODIFY COLUMN currency varchar(10) default NULL; });
## And finally add the FK
    $dbh->do(q{
    ALTER TABLE aqorders ADD FOREIGN KEY (currency) REFERENCES currency(currency) ON DELETE SET NULL ON UPDATE SET null;
    });

    print "Upgrade to $DBversion done (Bug 15084 - Move the currency related code to Koha::Acquisition::Currenc[y|ies])\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.038";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do(q{
    INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES ('decreaseLoanHighHoldsControl', 'static', 'static|dynamic', "Chooses between static and dynamic high holds checking", 'Choice'), ('decreaseLoanHighHoldsIgnoreStatuses', '', 'damaged|itemlost|notforloan|withdrawn', "Ignore items with these statuses for dynamic high holds checking", 'Choice');
    });
    print "Upgrade to $DBversion done (Bug 14694 - Make decreaseloanHighHolds more flexible)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.039";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {

    $dbh->do(q{
    ALTER TABLE suggestions
    MODIFY COLUMN currency varchar(10) default NULL;
    });
    $dbh->do(q{
    ALTER TABLE aqbooksellers
    MODIFY COLUMN currency varchar(10) default NULL;
    });
    print "Upgrade to $DBversion done (Bug 15084 - Move the currency related code to Koha::Acquisition::Currenc[y|ies])\n";
    SetVersion($DBversion);
}


$DBversion = "3.23.00.040";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {

    my $c = $dbh->selectrow_array('SELECT COUNT(*) FROM systempreferences WHERE variable="intranetcolorstylesheet" AND value="blue.css"');

    if ( $c ) {
        print "WARNING: You are using a stylesheeet which has been removed from the Koha codebase.\n";
        print "Update your intranetcolorstylesheet.\n";
    }
    print "Upgrade to $DBversion done (Bug 16019 - Check intranetcolorstylesheet for blue.css)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.041";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {

    my $dbh = C4::Context->dbh;
    my ($print_error) = $dbh->{PrintError};
    $dbh->{RaiseError} = 0;
    $dbh->{PrintError} = 0;
    $dbh->do("ALTER TABLE overduerules_transport_types ADD COLUMN letternumber INT(1) NOT NULL DEFAULT 1 AFTER id");
    $dbh->{PrintError} = $print_error;

    print "Upgrade to $DBversion done (Bug 16007: Make sure overduerules_transport_types.letternumber exists)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.042";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {

    $dbh->do(q{
            ALTER TABLE items CHANGE new new_status VARCHAR(32) NULL;
            });
    $dbh->do(q{
            ALTER TABLE deleteditems CHANGE new new_status VARCHAR(32) NULL;
            });
    $dbh->do(q{
            UPDATE systempreferences SET value=REPLACE(value, '"items.new"', '"items.new_status"') WHERE variable="automatic_item_modification_by_age_configuration";
            });

    print "Upgrade to $DBversion done (Bug 16004 - Replace items.new with items.new_status)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.043";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do(q{
            UPDATE systempreferences SET value="" WHERE value IS NULL;
            });

    print "Upgrade to $DBversion done (Bug 16070 - Empty (undef) system preferences may cause some issues in combination with memcache)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.044";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do(q{
            INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES
            ('GoogleOpenIDConnect', '0', NULL, 'if ON, allows the use of Google OpenID Connect for login', 'YesNo'),
            ('GoogleOAuth2ClientID', '', NULL, 'Client ID for the web app registered with Google', 'Free'),
            ('GoogleOAuth2ClientSecret', '', NULL, 'Client Secret for the web app registered with Google', 'Free'),
            ('GoogleOpenIDConnectDomain', '', NULL, 'Restrict OpenID Connect to this domain (or subdomains of this domain). Leave blank for all Google domains', 'Free');
            });

    print "Upgrade to $DBversion done (Bug 10988 - Allow login via Google OAuth2 (OpenID Connect))\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.045";
if ( CheckVersion($DBversion) ) {
## Holds details for vendors supplying goods by EDI
   $dbh->do(q{
           CREATE TABLE IF NOT EXISTS vendor_edi_accounts (
                   id INT(11) NOT NULL auto_increment,
                   description TEXT NOT NULL,
                   host VARCHAR(40),
                   username VARCHAR(40),
                   password VARCHAR(40),
                   last_activity DATE,
                   vendor_id INT(11) REFERENCES aqbooksellers( id ),
                   download_directory TEXT,
                   upload_directory TEXT,
                   san VARCHAR(20),
                   id_code_qualifier VARCHAR(3) default '14',
                   transport VARCHAR(6) default 'FTP',
                   quotes_enabled TINYINT(1) not null default 0,
                   invoices_enabled TINYINT(1) not null default 0,
                   orders_enabled TINYINT(1) not null default 0,
                   responses_enabled TINYINT(1) not null default 0,
                   auto_orders TINYINT(1) not null default 0,
                   shipment_budget INTEGER(11) REFERENCES aqbudgets( budget_id ),
                   PRIMARY KEY  (id),
                   KEY vendorid (vendor_id),
                   KEY shipmentbudget (shipment_budget),
                   CONSTRAINT vfk_vendor_id FOREIGN KEY ( vendor_id ) REFERENCES aqbooksellers ( id ),
                   CONSTRAINT vfk_shipment_budget FOREIGN KEY ( shipment_budget ) REFERENCES aqbudgets ( budget_id )
                       ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
   });

## Hold the actual edifact messages with links to associated baskets
   $dbh->do(q{
           CREATE TABLE IF NOT EXISTS edifact_messages (
                   id INT(11) NOT NULL auto_increment,
                   message_type VARCHAR(10) NOT NULL,
                   transfer_date DATE,
                   vendor_id INT(11) REFERENCES aqbooksellers( id ),
                   edi_acct  INTEGER REFERENCES vendor_edi_accounts( id ),
                   status TEXT,
                   basketno INT(11) REFERENCES aqbasket( basketno),
                   raw_msg MEDIUMTEXT,
                   filename TEXT,
                   deleted BOOLEAN NOT NULL DEFAULT 0,
                   PRIMARY KEY  (id),
                   KEY vendorid ( vendor_id),
                   KEY ediacct (edi_acct),
                   KEY basketno ( basketno),
                   CONSTRAINT emfk_vendor FOREIGN KEY ( vendor_id ) REFERENCES aqbooksellers ( id ),
                   CONSTRAINT emfk_edi_acct FOREIGN KEY ( edi_acct ) REFERENCES vendor_edi_accounts ( id ),
                   CONSTRAINT emfk_basketno FOREIGN KEY ( basketno ) REFERENCES aqbasket ( basketno )
                       ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
            });

## invoices link back to the edifact message it was generated from
   $dbh->do(q{
           ALTER TABLE aqinvoices ADD COLUMN message_id INT(11) REFERENCES edifact_messages( id );
           });

## clean up link on deletes
   $dbh->do(q{
           ALTER TABLE aqinvoices ADD CONSTRAINT edifact_msg_fk FOREIGN KEY ( message_id ) REFERENCES edifact_messages ( id ) ON DELETE SET NULL;
           });

## Hold the supplier ids from quotes for ordering
## although this is an EAN-13 article number the standard says 35 characters ???
   $dbh->do(q{
           ALTER TABLE aqorders ADD COLUMN line_item_id VARCHAR(35);
           });

## The suppliers unique reference usually a quotation line number ('QLI')
## Otherwise Suppliers unique orderline reference ('SLI')
   $dbh->do(q{
           ALTER TABLE aqorders ADD COLUMN suppliers_reference_number VARCHAR(35);
           });
   $dbh->do(q{
           ALTER TABLE aqorders ADD COLUMN suppliers_reference_qualifier VARCHAR(3);
           });
   $dbh->do(q{
           ALTER TABLE aqorders ADD COLUMN suppliers_report text;
           });

## hold the EAN/SAN used in ordering
   $dbh->do(q{
           CREATE TABLE IF NOT EXISTS edifact_ean (
                   ee_id int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
                   description VARCHAR(128) NULL DEFAULT NULL,
                   branchcode VARCHAR(10) NOT NULL REFERENCES branches (branchcode),
                   ean VARCHAR(15) NOT NULL,
                   id_code_qualifier VARCHAR(3) NOT NULL DEFAULT '14',
                   CONSTRAINT efk_branchcode FOREIGN KEY ( branchcode ) REFERENCES branches ( branchcode )
                   ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
           });

## Add a permission for managing EDI
   $dbh->do(q{
           INSERT INTO permissions (module_bit, code, description) values (11, 'edi_manage', 'Manage EDIFACT transmissions');
           });

   print "Upgrade to $DBversion done (Bug 7736 - Edifact QUOTE and ORDER functionality))\n";
   SetVersion($DBversion);
}

$DBversion = "3.23.00.046";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {

    $dbh->do(q{
    ALTER TABLE vendor_edi_accounts ADD COLUMN plugin VARCHAR(256) NOT NULL DEFAULT "";
    });

    print "Upgrade to $DBversion done (Bug 15630 - Make Edifact module pluggable))\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.047";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {

    $dbh->do(q{
         INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES ('IntranetReportsHomeHTML', '', 'Show the following HTML in a div on the bottom of the reports home page', NULL, 'Free');
         });
    $dbh->do(q{
         INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES ('IntranetCirculationHomeHTML', '', 'Show the following HTML in a div on the bottom of the reports home page', NULL, 'Free');
         });

    print "Upgrade to $DBversion done (Bug 15008 - Add custom HTML areas to circulation and reports home pages)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.048";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do(q{
    INSERT IGNORE INTO `systempreferences` (variable,value,options,explanation,type)  SELECT 'OPACISBD', value, '70|10', 'Allows to define ISBD view in OPAC', 'Textarea' FROM `systempreferences` WHERE variable = 'ISBD';
    });

    print "Upgrade to $DBversion done (Bug 5979 - Add separate OPACISBD system preference)\n";
    SetVersion($DBversion);
}



$DBversion = "3.23.00.049";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
my $dbh = C4::Context->dbh;
my ( $column_has_been_used ) = $dbh->selectrow_array(q|
            SELECT COUNT(*)
                FROM borrower_attributes
                    WHERE password IS NOT NULL
                    |);

if ( $column_has_been_used ) {
        print q|WARNING: The columns borrower_attribute_types.password_allowed and borrower_attributes.password have been removed from the Koha codebase. They were not used. However your installation has at least one borrower_attributes.password defined. In order not to alter your data, the columns have been kept, please save the information elsewhere and remove these columns manually.|;
} else {
        $dbh->do(q|
        ALTER TABLE borrower_attribute_types DROP column password_allowed
        |);
        $dbh->do(q|
        ALTER TABLE borrower_attributes DROP column password;
        |);
    }
    print "Upgrade to $DBversion done (Bug 12267 - Allow password option in Patron Attribute non functional)\n";
        SetVersion($DBversion);
}


$DBversion = "3.23.00.050";
if ( CheckVersion($DBversion) ) {
    use Koha::SearchMarcMaps;
    use Koha::SearchFields;
    use Koha::SearchEngine::Elasticsearch;

    $dbh->do(q|INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
                    VALUES('SearchEngine','Zebra','Choose Search Engine','','Choice')|);


    $dbh->do(q|DROP TABLE IF EXISTS search_marc_to_field|);
    $dbh->do(q|DROP TABLE IF EXISTS search_marc_map|);
    $dbh->do(q|DROP TABLE IF EXISTS search_field|);

# This specifies the fields that will be stored in the search engine.
 $dbh->do(q|
         CREATE TABLE `search_field` (
             `id` int(11) NOT NULL AUTO_INCREMENT, 
             `name` varchar(255) NOT NULL COMMENT 'the name of the field as it will be stored in the search engine',
             `label` varchar(255) NOT NULL COMMENT 'the human readable name of the field, for display', 
             `type` ENUM('', 'string', 'date', 'number', 'boolean', 'sum') NOT NULL COMMENT 'what type of data this holds, relevant when storing it in the search engine',
             PRIMARY KEY (`id`),
             UNIQUE KEY (`name`)
             ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci
         |);
# This contains a MARC field specifier for a given index, marc type, and marc
# field.
$dbh->do(q|
        CREATE TABLE `search_marc_map` (
            id int(11) NOT NULL AUTO_INCREMENT,
            index_name ENUM('biblios','authorities') NOT NULL COMMENT 'what storage index this map is for',
            marc_type ENUM('marc21', 'unimarc', 'normarc') NOT NULL COMMENT 'what MARC type this map is for',
            marc_field VARCHAR(255) NOT NULL COMMENT 'the MARC specifier for this field',
            PRIMARY KEY(`id`),
            unique key( index_name, marc_field, marc_type),
            INDEX (`index_name`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci
        |);

# This joins the two search tables together. We can have any combination:
# one marc field could have many search fields (maybe you want one value
# to go to 'author' and 'corporate-author) and many marc fields could go
# to one search field (e.g. all the various author fields going into
# 'author'.)
#
# a note about the sort field:
# * if all the entries for a mapping are 'null', nothing special is done with that mapping.
# * if any of the entries are not null, then a __sort field is created in ES for this mapping. In this case:
#   * any mapping with sort == false WILL NOT get copied into a __sort field
#   * any mapping with sort == true or is null WILL get copied into a __sort field
#   * any sorts on the field name will be applied to $fieldname.'__sort' instead.
# this means that we can have search for author that includes 1xx, 245$c, and 7xx, but the sort only applies to 1xx.

$dbh->do(q|
        CREATE TABLE `search_marc_to_field` (
            search_marc_map_id int(11) NOT NULL,
            search_field_id int(11) NOT NULL,
            facet boolean DEFAULT FALSE COMMENT 'true if a facet field should be generated for this',
            suggestible boolean DEFAULT FALSE COMMENT 'true if this field can be used to generate suggestions for browse',
            sort boolean DEFAULT NULL COMMENT 'true/false creates special sort handling, null doesn''t',
            PRIMARY KEY(search_marc_map_id, search_field_id),
            FOREIGN KEY(search_marc_map_id) REFERENCES search_marc_map(id) ON DELETE CASCADE ON UPDATE CASCADE,
            FOREIGN KEY(search_field_id) REFERENCES search_field(id) ON DELETE CASCADE ON UPDATE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci
        |);

        # Insert default mappings
        Koha::SearchEngine::Elasticsearch->reset_elasticsearch_mappings;

print "Upgrade to $DBversion done (Bug 12478 - Elasticsearch support for Koha)\n";
    SetVersion($DBversion);
    }


$DBversion = "3.23.00.051";
if ( CheckVersion($DBversion) ) {
$dbh->do(q{
        ALTER TABLE edifact_messages
        DROP FOREIGN KEY emfk_vendor,
        DROP FOREIGN KEY emfk_edi_acct,
        DROP FOREIGN KEY emfk_basketno;
        });

$dbh->do(q{
        ALTER TABLE edifact_messages
        ADD CONSTRAINT emfk_vendor FOREIGN KEY ( vendor_id ) REFERENCES aqbooksellers ( id ) ON DELETE CASCADE ON UPDATE CASCADE,
        ADD CONSTRAINT emfk_edi_acct FOREIGN KEY ( edi_acct ) REFERENCES vendor_edi_accounts ( id ) ON DELETE CASCADE ON UPDATE CASCADE,
        ADD CONSTRAINT emfk_basketno FOREIGN KEY ( basketno ) REFERENCES aqbasket ( basketno ) ON DELETE CASCADE ON UPDATE CASCADE;
        });

    print "Upgrade to $DBversion done (Bug 16354 - Fix FK constraints for edifact_messages table)\n";
    SetVersion($DBversion);
}


$DBversion = "3.23.00.052";
if ( CheckVersion($DBversion) ) {
## Insert permission

    $dbh->do(q{
        INSERT IGNORE INTO permissions (module_bit, code, description) VALUES
        (13, 'upload_general_files', 'Upload any file'),
        (13, 'upload_manage', 'Manage uploaded files');
        });
## Update user_permissions for current users (check count in uploaded_files)
## Note 9 == edit_catalogue and 13 == tools
## We do not insert if someone is superlibrarian, does not have edit_catalogue,
## or already has all tools

        $dbh->do(q{
                INSERT IGNORE INTO user_permissions (borrowernumber, module_bit, code)
                SELECT borrowernumber, 13, 'upload_general_files'
                FROM borrowers bo
                WHERE flags<>1 AND flags & POW(2,13) = 0 AND
                ( flags & POW(2,9) > 0 OR 
                  (SELECT COUNT(*) FROM user_permissions
                   WHERE borrowernumber=bo.borrowernumber AND module_bit=9 ) > 0 )
                AND ( SELECT COUNT(*) FROM uploaded_files ) > 0
                });

    print "Upgrade to $DBversion done (Bug 14686 - New menu option and permission for file uploading)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.053";
if ( CheckVersion($DBversion) ) {
    my $letters = $dbh->selectall_arrayref(
        q|
        SELECT code, name
        FROM letter
        WHERE message_transport_type="email"
        |, { Slice => {} }
    );
    for my $letter (@$letters) {
        $dbh->do(
            q|
                UPDATE letter
                SET name = ?
                WHERE code = ?
                AND message_transport_type <> "email"
                |, undef, $letter->{name}, $letter->{code}
        );
    }

    print "Upgrade to $DBversion done (Bug 16217 - Notice' names may have diverged)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.054";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        ALTER TABLE branch_item_rules ADD COLUMN hold_fulfillment_policy ENUM('any', 'homebranch', 'holdingbranch') NOT NULL DEFAULT 'any' AFTER holdallowed;
    });
    $dbh->do(q{
        ALTER TABLE default_branch_circ_rules ADD COLUMN hold_fulfillment_policy ENUM('any', 'homebranch', 'holdingbranch') NOT NULL DEFAULT 'any' AFTER holdallowed;
    });
    $dbh->do(q{
        ALTER TABLE default_branch_item_rules ADD COLUMN hold_fulfillment_policy ENUM('any', 'homebranch', 'holdingbranch') NOT NULL DEFAULT 'any' AFTER holdallowed;
    });
    $dbh->do(q{
        ALTER TABLE default_circ_rules ADD COLUMN hold_fulfillment_policy ENUM('any', 'homebranch', 'holdingbranch') NOT NULL DEFAULT 'any' AFTER holdallowed;
    });

    print "Upgrade to $DBversion done (Bug 15532 - Add ability to allow only items whose home/holding branch matches the hold's pickup branch to fill a given hold)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.055";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        ALTER TABLE reserves ADD COLUMN itemtype VARCHAR(10) NULL DEFAULT NULL AFTER suspend_until;
    });
    $dbh->do(q{
        ALTER TABLE reserves ADD KEY `itemtype` (`itemtype`);
    });
    $dbh->do(q{
        ALTER TABLE reserves ADD CONSTRAINT `reserves_ibfk_5` FOREIGN KEY (`itemtype`) REFERENCES `itemtypes` (`itemtype`) ON DELETE CASCADE ON UPDATE CASCADE;
    });
    $dbh->do(q{
        ALTER TABLE old_reserves ADD COLUMN itemtype VARCHAR(10) NULL DEFAULT NULL AFTER suspend_until;
    });
    $dbh->do(q{
        ALTER TABLE old_reserves ADD KEY `itemtype` (`itemtype`);
    });
    $dbh->do(q{
        ALTER TABLE old_reserves ADD CONSTRAINT `old_reserves_ibfk_4` FOREIGN KEY (`itemtype`) REFERENCES `itemtypes` (`itemtype`) ON DELETE CASCADE ON UPDATE CASCADE;
    });

    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('AllowHoldItemTypeSelection','0','','If enabled, patrons and staff will be able to select the itemtype when placing a hold','YesNo');
    });

    print "Upgrade to $DBversion done (Bug 15533 - Allow patrons and librarians to select itemtype when placing hold)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.056";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('NoIssuesChargeGuarantees','','','Define maximum amount withstanding before check outs are blocked','Integer');
    });

    print "Upgrade to $DBversion done (Bug 14577 - Allow restriction of checkouts based on fines of guarantor/guarantee)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.057";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        ALTER TABLE aqbasket ADD COLUMN is_standing TINYINT(1) NOT NULL DEFAULT 0 AFTER branch;
    });

    print "Upgrade to $DBversion done (Bug 15531 - Add support for standing orders)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.058";
if ( CheckVersion($DBversion) ) {

    my ($count_imageurl) = $dbh->selectrow_array(q|
        SELECT COUNT(*)
        FROM authorised_values
        WHERE imageurl IS NOT NULL
            AND imageurl <> ""
    |);

    unless ($count_imageurl) {
        if (   C4::Context->preference('AuthorisedValueImages')
            or C4::Context->preference('StaffAuthorisedValueImages') )
        {
            $dbh->do(q|
                UPDATE systempreferences
                SET value = 0
                WHERE variable = "AuthorisedValueImages"
                   or variable = "StaffAuthorisedValueImages"
            |);
            warn "The system preferences AuthorisedValueImages and StaffAuthorisedValueImages have been turned off\n";
            warn "authorised_values.imageurl is not populated, that means you are not using this feature\n";
        }
    }
    else {
        warn "At least one authorised value has an icon defined (imageurl)\n";
        warn "The system preference AuthorisedValueImages or StaffAuthorisedValueImages could be turned off if you are not aware of this feature\n";
    }

    print "Upgrade to $DBversion done (Bug 16041 - StaffAuthorisedValueImages & AuthorisedValueImages preferences - impact on search performance)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.059";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        DELETE FROM systempreferences WHERE variable="AuthorisedValueImages" OR variable="StaffAuthorisedValueImages";
    });

    print "Upgrade to $DBversion done (Bug 16167 - Remove prefs to drive authorised value images)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.060";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( value, variable, options, explanation,type )
        SELECT value ,'EnhancedMessagingPreferencesOPAC', NULL, 'If ON, allows patrons to select to receive additional messages about items due or nearly due.', 'YesNo' FROM systempreferences WHERE variable = 'EnhancedMessagingPreferences';
    });

    print "Upgrade to $DBversion done (Bug 12528 - Enable staff to deny message setting access to patrons on the OPAC)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.061";
if ( CheckVersion($DBversion) ) {
    my ( $cnt ) = $dbh->selectrow_array( q|
        SELECT COUNT(*) FROM items it
        LEFT JOIN biblio bi ON bi.biblionumber=it.biblionumber
        LEFT JOIN biblioitems bii USING (biblioitemnumber)
        WHERE bi.biblionumber IS NULL
    |);
    if( $cnt ) {
        print "WARNING: You have corrupted data in your items table!! The table contains $cnt references to biblio records that do not exist.\nPlease correct your data IMMEDIATELY after this upgrade and manually add the foreign key constraint for biblionumber in the items table.\n";
    } else {
        # now add FK
        $dbh->do( q|
            ALTER TABLE items
            ADD FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE
        |);
        print "Upgrade to $DBversion done (Bug 16170 - Add FK for biblionumber in items)\n";
    }
    SetVersion($DBversion);
}

$DBversion = "3.23.00.062";
if ( CheckVersion($DBversion) ) {
    $dbh->do( q|
            ALTER TABLE aqorders DROP COLUMN budgetgroup_id;
            |);
    print "Upgrade to $DBversion done (Bug 16414 - aqorders.budgetgroup_id has never been used and can be removed)\n";
SetVersion($DBversion);
}

$DBversion = "3.23.00.063";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        UPDATE letter SET branchcode='' WHERE branchcode IS NULL;
    });
    $dbh->do(q{
        ALTER TABLE letter MODIFY COLUMN branchcode varchar(10) NOT NULL DEFAULT ''
    });
    $dbh->do(q{
        ALTER TABLE permissions MODIFY COLUMN code varchar(64) NOT NULL DEFAULT '';
    });
    print "Upgrade to $DBversion done (Bug 16402: Fix DB structure to work on MySQL 5.7)\n";
    SetVersion($DBversion);
}

$DBversion = "3.23.00.064";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        ALTER TABLE creator_layouts MODIFY layout_name char(25) NOT NULL DEFAULT 'DEFAULT';
    });
    print "Upgrade to $DBversion done (Bug 15086 - Creators layout and template sql has warnings)\n";
    SetVersion($DBversion);
}

$DBversion = "16.05.00.000";
if ( CheckVersion($DBversion) ) {
    print "Upgrade to $DBversion done (Koha 16.05)\n";
    SetVersion($DBversion);
}

$DBversion = "16.06.00.000";
if ( CheckVersion($DBversion) ) {
    print "Upgrade to $DBversion done (Koha 16.06 - starting a new dev line at KohaCon16 in Thessaloniki, Greece! Koha is great!)\n";
    SetVersion($DBversion);
}

$DBversion = "16.06.00.001";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        UPDATE accountlines SET accounttype='HE', description=itemnumber WHERE (description REGEXP '^Hold waiting too long [0-9]+') AND accounttype='F';
    });

    print "Upgrade to $DBversion done (Bug 16200 - 'Hold waiting too long' fee has a translation problem)\n";
    SetVersion($DBversion);
}

$DBversion = "16.06.00.002";
if ( CheckVersion($DBversion) ) {
    unless ( column_exists('borrowers', 'updated_on') ) {
        $dbh->do(q{
            ALTER TABLE borrowers
                ADD COLUMN updated_on timestamp NULL DEFAULT CURRENT_TIMESTAMP
                ON UPDATE CURRENT_TIMESTAMP
                AFTER privacy_guarantor_checkouts;
        });
        $dbh->do(q{
            ALTER TABLE deletedborrowers
                ADD COLUMN updated_on timestamp NULL DEFAULT CURRENT_TIMESTAMP
                ON UPDATE CURRENT_TIMESTAMP
                AFTER privacy_guarantor_checkouts;
        });
    }

    print "Upgrade to $DBversion done (Bug 10459 - borrowers should have a timestamp)\n";
    SetVersion($DBversion);
}

$DBversion = "16.06.00.003";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( variable, value, options, explanation, type )
        SELECT 'MaxItemsToProcessForBatchMod', value, NULL, 'Process up to a given number of items in a single item modification batch.', 'Integer' FROM systempreferences WHERE variable='MaxItemsForBatch';
    });
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( variable, value, options, explanation, type )
        SELECT 'MaxItemsToDisplayForBatchDel', value, NULL, 'Display up to a given number of items in a single item deletionbatch.', 'Integer' FROM systempreferences WHERE variable='MaxItemsForBatch';
    });
    $dbh->do(q{
        DELETE FROM systempreferences WHERE variable="MaxItemsForBatch";
    });

    print "Upgrade to $DBversion done (Bug 11490 - MaxItemsForBatch should be split into two new prefs)\n";
    SetVersion($DBversion);
}

$DBversion = '16.06.00.004';
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( variable, value, options, explanation, type )
         SELECT 'OPACXSLTListsDisplay', COALESCE(value,''), '', 'Enable XSLT stylesheet control over lists pages display on OPAC', 'Free'
         FROM systempreferences WHERE variable='OPACXSLTResultsDisplay';
    });

    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( variable, value, options, explanation, type )
         SELECT 'XSLTListsDisplay', COALESCE(value,''), '', 'Enable XSLT stylesheet control over lists pages display on intranet', 'Free'
         FROM systempreferences WHERE variable='XSLTResultsDisplay';
    });

    print "Upgrade to $DBversion done (Bug 15485: Allow choosing different XSLTs for lists)\n";
    SetVersion($DBversion);
}

$DBversion = '16.06.00.005';
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        UPDATE `systempreferences` set options = 'US|FR|CH' where variable = 'CurrencyFormat';
    });

    print "Upgrade to $DBversion done (Bug 16768 - Add official number format for Switzerland: 1'234'567.89)\n";
    SetVersion($DBversion);
}

$DBversion = "16.06.00.006";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        CREATE TABLE `refund_lost_item_fee_rules` (
          `branchcode` varchar(10) NOT NULL default '',
          `refund` tinyint(1) NOT NULL default 0,
          PRIMARY KEY  (`branchcode`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
    });
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
        VALUES( 'RefundLostOnReturnControl',
                'CheckinLibrary',
                'If a lost item is returned, choose which branch to pick rules for refunding.',
                'CheckinLibrary|PatronLibrary|ItemHomeBranch|ItemHoldingbranch',
                'Choice')
    });
    # Pick the old syspref as the default rule
    $dbh->do(q{
        INSERT INTO refund_lost_item_fee_rules (branchcode,refund)
            SELECT '*', COALESCE(value,'1') FROM systempreferences WHERE variable='RefundLostItemFeeOnReturn'
    });
    # Delete the old syspref
    $dbh->do(q{
        DELETE IGNORE FROM systempreferences
        WHERE variable='RefundLostItemFeeOnReturn'
    });

    print "Upgrade to $DBversion done (Bug 14048: Change RefundLostItemFeeOnReturn to be branch specific)\n";
    SetVersion($DBversion);
}

$DBversion = '16.06.00.007';
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) 
        VALUES ('PatronQuickAddFields', '', 'A list of fields separated by "|" to be displayed along with mandatory fields in the patron quick add form if chosen at patron entry', NULL, 'Free');
    });

    print "Upgrade to $DBversion done (Bug 3534 - Patron quick add form)\n";
    SetVersion($DBversion);
}

$DBversion = '16.06.00.008';
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
        VALUES('CheckPrevCheckout','hardno','hardyes|softyes|softno|hardno','By default, for every item checked out, should we warn if the patron has checked out that item in the past?','Choice');
    });
    $dbh->do(q{
        ALTER TABLE categories
        ADD COLUMN `checkprevcheckout` varchar(7) NOT NULL default 'inherit'
        AFTER `default_privacy`;
    });
    $dbh->do(q{
        ALTER TABLE borrowers
        ADD COLUMN `checkprevcheckout` varchar(7) NOT NULL default 'inherit'
        AFTER `privacy_guarantor_checkouts`;
    });
    $dbh->do(q{
        ALTER TABLE deletedborrowers
        ADD COLUMN `checkprevcheckout` varchar(7) NOT NULL default 'inherit'
        AFTER `privacy_guarantor_checkouts`;
    });

    print "Upgrade to $DBversion done (Bug 6906 - show 'Borrower has previously issued \$ITEM' alert on checkout)\n";
    SetVersion($DBversion);
}

$DBversion = '16.06.00.009';
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) 
        VALUES ('IntranetCatalogSearchPulldown','0',NULL,'Show a search field pulldown for \"Search the catalog\" boxes. ','YesNo');
    });

    print "Upgrade to $DBversion done (Bug 14902 - Add qualifier menu to staff side 'Search the Catalog')\n";
    SetVersion($DBversion);
}

$DBversion = '16.06.00.010';
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
        VALUES ('MaxOpenSuggestions','',NULL,'Limit the number of open suggestions a patron can have at once, unlimited if blank','Integer')
    });

    print "Upgrade to $DBversion done (Bug 15128 - Add ability to limit the number of open purchase suggestions a patron can make)\n";
    SetVersion($DBversion);
}

$DBversion = '16.06.00.011';
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES
        ('NovelistSelectStaffEnabled','0',NULL,'Enable  Novelist Select content to the Staff Interface (requires that you have entered in a user profile and password, which can be seen in image links)','YesNo'),
        ('NovelistSelectStaffView','tab','tab|above|below','Where to display Novelist Select content','Choice');
    });

    print "Upgrade to $DBversion done (Bug 11606 - Novelist Select in Staff Client)\n";
    SetVersion($DBversion);
}

$DBversion = '16.06.00.012';
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        ALTER TABLE virtualshelves MODIFY COLUMN created_on DATETIME not NULL;
    });

    print "Upgrade to $DBversion done (Bug 16573 - Web installer fails to load structure and sample data on MySQL 5.7)\n";
    SetVersion($DBversion);
}

$DBversion = '16.06.00.013';
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type) VALUES
        ('OPACResultsLibrary', 'homebranch', 'homebranch|holdingbranch', 'Defines whether the OPAC displays the holding or home branch in search results when using XSLT', 'Choice');
    });

    print "Upgrade to $DBversion done (Bug 7441 - Search results showing wrong branch)\n";
    SetVersion($DBversion);
}

$DBversion = "16.06.00.014";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        ALTER TABLE `action_logs` ADD COLUMN `interface` VARCHAR(30) DEFAULT NULL AFTER `info`;
    });

    $dbh->do(q{
        ALTER TABLE `action_logs` ADD KEY `interface` (`interface`);
    });

    print "Upgrade to $DBversion done (Bug 16829: action_logs should have an 'interface' column)\n";
    SetVersion($DBversion);
}

$DBversion = "16.06.00.015";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( variable, value, options, explanation, type ) VALUES
        ('HoldsLog','0',NULL,'If ON, log create/cancel/suspend/resume actions on holds.','YesNo');
    });

    print "Upgrade to $DBversion done (Bug 14642: Add logging of hold modifications)\n";
    SetVersion($DBversion);
}

$DBversion = "16.06.00.016";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        update marc_subfield_structure set defaultvalue=REPLACE(defaultvalue, 'YYYY', '<<YYYY>>') where defaultvalue like "%YYYY%" and defaultvalue not like "%<<YYYY>>%";
    });
    $dbh->do(q{
        update marc_subfield_structure set defaultvalue=REPLACE(defaultvalue, 'MM', '<<MM>>') where defaultvalue like "%MM%" and defaultvalue not like "%<<MM>>%";
    });
    $dbh->do(q{
        update marc_subfield_structure set defaultvalue=REPLACE(defaultvalue, 'DD', '<<DD>>') where defaultvalue like "%DD%" and defaultvalue not like "%<<DD>>%";
    });
    $dbh->do(q{
        update marc_subfield_structure set defaultvalue=REPLACE(defaultvalue, 'user', '<<USER>>') where defaultvalue like "%user%" and defaultvalue not like "%<<USER>>%";
    });

    print "Upgrade to $DBversion done (Bug 7045 - Default-value substitution inconsistent)\n";
    SetVersion($DBversion);
}

$DBversion = "16.06.00.017";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type`) VALUES ('OPACSuggestionMandatoryFields','title','','Define the mandatory fields for a patron purchase suggestions made via OPAC.','multiple');
    });

    print "Upgrade to $DBversion done (Bug 10848 - Allow configuration of mandatory/required fields on the suggestion form in OPAC)\n";
    SetVersion($DBversion);
}

$DBversion = "16.06.00.018";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        ALTER TABLE issuingrules ADD COLUMN holds_per_record SMALLINT(6) NOT NULL DEFAULT 1 AFTER reservesallowed;
    });

    print "Upgrade to $DBversion done (Bug 14695 - Add ability to place multiple item holds on a given record per patron)\n";
    SetVersion($DBversion);
}

$DBversion = "16.06.00.019";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        ALTER TABLE reviews CHANGE COLUMN approved approved tinyint(4) DEFAULT 0;
    });
    $dbh->do(q{
        UPDATE reviews SET approved=0 WHERE approved IS NULL;
    });

    print "Upgrade to $DBversion done (Bug 15839 - Move the reviews related code to Koha::Reviews)\n";
    SetVersion($DBversion);
}

$DBversion = "16.06.00.020";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES ('SwitchOnSiteCheckouts', '0', 'Automatically switch an on-site checkout to a normal checkout', NULL, 'YesNo');
    });

    print "Upgrade to $DBversion done (Bug 16272 - Transform checkout from on-site checkout to regular checkout)\n";
    SetVersion($DBversion);
}

$DBversion = "16.06.00.021";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES ('PatronSelfRegistrationEmailMustBeUnique', '0', 'If set, the field borrowers.email will be considered as a unique field on self registering', NULL, 'YesNo');
    });

    print "Upgrade to $DBversion done (Bug 16275 - Prevent patron self registration if the email already filled in borrowers.email)\n";
    SetVersion($DBversion);
}

$DBversion = "16.06.00.022";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO `permissions`
        (module_bit, code,             description) VALUES
        (16,         'delete_reports', 'Delete SQL reports');
    });
    $dbh->do(q{
        INSERT IGNORE INTO user_permissions
        (borrowernumber,      module_bit,code)
        SELECT borrowernumber,module_bit,'delete_reports'
            FROM user_permissions
            WHERE module_bit=16 AND code='create_reports';
    });

    print "Upgrade to $DBversion done (Bug 16978 - Add delete reports user permission)\n";
    SetVersion($DBversion);
}

$DBversion = "16.06.00.023";
if ( CheckVersion($DBversion) ) {
    my $pref = C4::Context->preference('timeout');
    if( !$pref || $pref eq '12000000' ) {
        # update if pref is null or equals old default value
        $dbh->do(q|
            UPDATE systempreferences SET value = '1d', type = 'Free'
            WHERE variable = 'timeout'
        |);
        print "Upgrade to $DBversion done (Bug 17187)\nNote: Pref value for timeout has been adjusted.\n";
    } else {
        # only update pref type
        $dbh->do(q|
            UPDATE systempreferences SET type = 'Free'
            WHERE variable = 'timeout'
        |);
        print "Upgrade to $DBversion done (Bug 17187)\nNote: Pref value for timeout has not been adjusted.\n";
    }
    SetVersion($DBversion);
}

$DBversion = "16.06.00.024";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        UPDATE language_descriptions SET description = 'Română' WHERE subtag = 'ro' AND type = 'language' AND lang = 'ro';
    });

    print "Upgrade to $DBversion done (Bug 16311 - Advanced search language limit typo for Romanian)\n";
    SetVersion($DBversion);
}

$DBversion = "16.06.00.025";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        ALTER TABLE `subscription` ADD `itemtype` VARCHAR( 10 ) NULL AFTER reneweddate, ADD `previousitemtype` VARCHAR( 10 ) NULL AFTER itemtype;
    });
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES
        ('makePreviousSerialAvailable','0','make previous serial automatically available when collecting a new serial. Please note that the item-level_itypes syspref must be set to specific item.','','YesNo');
    });

    print "Upgrade to $DBversion done (Bug 7677 - Subscriptions: Ability to define default itemtype and automatically change itemtype of older issues on receive of next issue)\n";
    SetVersion($DBversion);
}

$DBversion = "16.06.00.026";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES ('PatronSelfRegistrationLibraryList', '', 'Only display libraries listed. If empty, all libraries are displayed.', NULL, 'Free');
    });

    print "Upgrade to $DBversion done (Bug 16274 - Make the selfregistration branchcode selection configurable)\n";
    SetVersion($DBversion);
}

$DBversion = "16.06.00.027";
if ( CheckVersion($DBversion) ) {
    unless ( column_exists('borrowers', 'lastseen') ) {
        $dbh->do(q{
            ALTER TABLE borrowers ADD COLUMN lastseen datetime default NULL AFTER updated_on;
        });
        $dbh->do(q{
            ALTER TABLE deletedborrowers ADD COLUMN lastseen datetime default NULL AFTER updated_on;
        });
    }
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES ('TrackLastPatronActivity', '0', 'If set, the field borrowers.lastseen will be updated everytime a patron is seen', NULL, 'YesNo');
    });

    print "Upgrade to $DBversion done (Bug 16274 - Make the selfregistration branchcode selection configurable)\n";
    SetVersion($DBversion);
}

$DBversion = '16.06.00.028';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    {
        print "Attempting upgrade to $DBversion (Bug 17135) ...\n";
        my $maintenance_script = C4::Context->config("intranetdir") . "/installer/data/mysql/fix_unclosed_nonaccruing_fines_bug17135.pl";
        system("perl $maintenance_script --confirm");

        print "Upgrade to $DBversion done (Bug 17135 - Fine for the previous overdue may get overwritten by the next one)\n";

        unless ($original_version < TransformToNum("3.23.00.032")) { ## Bug 15675
            print "WARNING: There is a possibility (= just a possibility, it's configuration dependent etc.) that - due to regression introduced by Bug 15675 - some old fine records for overdued items (items which got renewed 1+ time while being overdue) may have been overwritten in your production 16.05+ database. See Bugzilla reports for Bug 14390 and Bug 17135 for more details.\n";
            print "WARNING: Please note that this upgrade does not try to recover such overwitten old fine records (if any) - it's just an follow-up for Bug 14390, its sole purpose is preventing eventual further-on overwrites from happening in the future. Optional recovery of the overwritten fines (again, if any) is like, totally outside of the scope of this particular upgrade!\n";
        }
        SetVersion ($DBversion);
    }
}

$DBversion = "16.06.00.029";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        UPDATE systempreferences SET type="Choice" WHERE variable="UsageStatsLibraryType";
    });
    $dbh->do(q{
        UPDATE systempreferences SET value="Canada" WHERE variable="UsageStatsCountry" AND value="CANADA";
    });
    $dbh->do(q{
        UPDATE systempreferences SET value="Czech Republic" WHERE variable="UsageStatsCountry" AND value="CZ";
    });
    $dbh->do(q{
        UPDATE systempreferences SET value="United Kingdom" WHERE variable="UsageStatsCountry" AND (value="England" OR value="UK");
    });
    $dbh->do(q{
        UPDATE systempreferences SET value="Spain" WHERE variable="UsageStatsCountry" AND value="España";
    });
    $dbh->do(q{
        UPDATE systempreferences SET value="Greece" WHERE variable="UsageStatsCountry" AND value="GR";
    });
    $dbh->do(q{
        UPDATE systempreferences SET value="Ireland" WHERE variable="UsageStatsCountry" AND value="Irelanbd";
    });
    $dbh->do(q{
        UPDATE systempreferences SET value="Mexico" WHERE variable="UsageStatsCountry" AND value="México";
    });
    $dbh->do(q{
        UPDATE systempreferences SET value="Peru" WHERE variable="UsageStatsCountry" AND value="Perú";
    });
    $dbh->do(q{
        UPDATE systempreferences SET value="Dominican Rep." WHERE variable="UsageStatsCountry" AND value="República Dominicana";
    });
    $dbh->do(q{
        UPDATE systempreferences SET value="Trinidad & Tob." WHERE variable="UsageStatsCountry" AND value="Trinidad";
    });
    $dbh->do(q{
        UPDATE systempreferences SET value="Turkey" WHERE variable="UsageStatsCountry" AND value="Türkiye";
    });
    $dbh->do(q{
        UPDATE systempreferences SET value="USA" WHERE variable="UsageStatsCountry" AND (value="United States" OR value="United States of America" OR value="US");
    });
    $dbh->do(q{
        UPDATE systempreferences SET value="Zimbabwe" WHERE variable="UsageStatsCountry" AND value="Zimbabbwe";
    });

    print "Upgrade to $DBversion done (Bug 14707 - Change UsageStatsCountry from free text to a dropdown list)\n";
    SetVersion($DBversion);
}

$DBversion = "16.06.00.030";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('OPACHoldingsDefaultSortField','first_column','first_column|homebranch|holdingbranch','Default sort field for the holdings table at the OPAC','choice');
    });

    print "Upgrade to $DBversion done (Bug 16552 - Add the ability to change the default holdings sort)\n";
    SetVersion($DBversion);
}

$DBversion = "16.06.00.031";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES ('PatronSelfRegistrationPrefillForm', '1', 'Display password and prefill login form after a patron has self registered', NULL, 'YesNo');
    });

    print "Upgrade to $DBversion done (Bug 16273 - Prevent selfregistration from printing the borrower password and filling the logging form)\n";
    SetVersion($DBversion);
}

$DBversion = "16.06.00.032";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        UPDATE marc_subfield_structure SET authorised_value="WITHDRAWN" WHERE authorised_value="WTHDRAWN";
    });

    print "Upgrade to $DBversion done (Bug 17357 - WTHDRAWN is still used in installer files)\n";
    SetVersion($DBversion);
}


$DBversion = "16.06.00.033";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        CREATE TABLE authorised_value_categories (
        category_name VARCHAR(32) NOT NULL,
        primary key (category_name)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
        });
## Add authorised value categories
    $dbh->do(q{
    INSERT INTO authorised_value_categories (category_name )
    SELECT DISTINCT category FROM authorised_values;
    });
    
## Add special categories
    $dbh->do(q{
    INSERT IGNORE INTO authorised_value_categories( category_name )
    VALUES
    ('Asort1'),
    ('Asort2'),
    ('Bsort1'),
    ('Bsort2'),
    ('SUGGEST'),
    ('DAMAGED'),
    ('LOST'),
    ('REPORT_GROUP'),
    ('REPORT_SUBGROUP'),
    ('DEPARTMENT'),
    ('TERM'),
    ('SUGGEST_STATUS'),
    ('ITEMTYPECAT');
    });

## Add very special categories
    $dbh->do(q{
    INSERT IGNORE INTO authorised_value_categories( category_name )
    VALUES
    ('branches'),
    ('itemtypes'),
    ('cn_source');
    });

    $dbh->do(q{
    INSERT IGNORE INTO authorised_value_categories( category_name )
    VALUES
    ('WITHDRAWN'),
    ('RESTRICTED'),
    ('NOT_LOAN'),
    ('CCODE'),
    ('LOC'),
    ('STACK');
    });

## Update the FK
    $dbh->do(q{
    ALTER TABLE items_search_fields
    DROP FOREIGN KEY items_search_fields_authorised_values_category;
    });

    $dbh->do(q{
    ALTER TABLE items_search_fields
    ADD CONSTRAINT `items_search_fields_authorised_values_category` FOREIGN KEY (`authorised_values_category`) REFERENCES `authorised_value_categories` (`category_name`) ON DELETE SET NULL ON UPDATE CASCADE;
    });

    $dbh->do(q{
    ALTER TABLE authorised_values
    ADD CONSTRAINT `authorised_values_authorised_values_category` FOREIGN KEY (`category`) REFERENCES `authorised_value_categories` (`category_name`) ON DELETE CASCADE ON UPDATE CASCADE;
    });

    $dbh->do(q{
            INSERT IGNORE INTO authorised_value_categories( category_name ) SELECT DISTINCT(authorised_value) FROM marc_subfield_structure;
            });

    $dbh->do(q{
            UPDATE marc_subfield_structure SET authorised_value = NULL WHERE authorised_value = '';
            });

    # If the DB has been created before 3.19.00.006, the default collate for marc_subfield_structure if not set to utf8_unicode_ci and the new FK will not be create (MariaDB or MySQL will raise err 150)
    my $table_sth = $dbh->prepare(qq|SHOW CREATE TABLE marc_subfield_structure|);
    $table_sth->execute;
    my @table = $table_sth->fetchrow_array;
    if ( $table[1] !~ /COLLATE=utf8_unicode_ci/ and $table[1] !~ /COLLATE=utf8mb4_unicode_ci/ ) { #catches utf8mb4 collated tables
        $dbh->do(qq|ALTER TABLE marc_subfield_structure CHARACTER SET utf8 COLLATE utf8_unicode_ci|);
    }
    $dbh->do(q{
            ALTER TABLE marc_subfield_structure
            MODIFY COLUMN authorised_value VARCHAR(32) DEFAULT NULL,
            ADD CONSTRAINT marc_subfield_structure_ibfk_1 FOREIGN KEY (authorised_value) REFERENCES authorised_value_categories (category_name) ON UPDATE CASCADE ON DELETE SET NULL;
            });

      print "Upgrade to $DBversion done (Bug 17216 - Add a new table to store authorized value categories)\n";
      SetVersion($DBversion);
}

$DBversion = "16.06.00.034";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        ALTER TABLE biblioitems DROP COLUMN marc;
    });
    $dbh->do(q{
        ALTER TABLE deletedbiblioitems DROP COLUMN marc;
    });

    print "Upgrade to $DBversion done (Bug 10455 - remove redundant 'biblioitems.marc' field)\n";
    SetVersion($DBversion);
}

$DBversion = '16.06.00.035';
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( variable, value, options, explanation, type )
         SELECT 'AllowItemsOnHoldCheckoutSCO',COALESCE(value,0),'','Do not generate RESERVE_WAITING and RESERVED warning in the SCO module when checking out items reserved to someone else. This allows self checkouts for those items.','YesNo'
         FROM systempreferences WHERE variable='AllowItemsOnHoldCheckout';
    });

    print "Upgrade to $DBversion done (Bug 15131: Give SCO separate control for AllowItemsOnHoldCheckout)\n";
    SetVersion($DBversion);
}

$DBversion = '16.06.00.036';
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        CREATE TABLE IF NOT EXISTS `housebound_profile` (
          `borrowernumber` int(11) NOT NULL, -- Number of the borrower associated with this profile.
          `day` text NOT NULL,  -- The preferred day of the week for delivery.
          `frequency` text NOT NULL, -- The Authorised_Value definining the pattern for delivery.
          `fav_itemtypes` text default NULL, -- Free text describing preferred itemtypes.
          `fav_subjects` text default NULL, -- Free text describing preferred subjects.
          `fav_authors` text default NULL, -- Free text describing preferred authors.
          `referral` text default NULL, -- Free text indicating how the borrower was added to the service.
          `notes` text default NULL, -- Free text for additional notes.
          PRIMARY KEY  (`borrowernumber`),
          CONSTRAINT `housebound_profile_bnfk`
            FOREIGN KEY (`borrowernumber`)
            REFERENCES `borrowers` (`borrowernumber`)
            ON UPDATE CASCADE ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
    });
    $dbh->do(q{
        CREATE TABLE IF NOT EXISTS `housebound_visit` (
          `id` int(11) NOT NULL auto_increment, -- ID of the visit.
          `borrowernumber` int(11) NOT NULL, -- Number of the borrower, & the profile, linked to this visit.
          `appointment_date` date default NULL, -- Date of visit.
          `day_segment` varchar(10),  -- Rough time frame: 'morning', 'afternoon' 'evening'
          `chooser_brwnumber` int(11) default NULL, -- Number of the borrower to choose items  for delivery.
          `deliverer_brwnumber` int(11) default NULL, -- Number of the borrower to deliver items.
          PRIMARY KEY  (`id`),
          CONSTRAINT `houseboundvisit_bnfk`
            FOREIGN KEY (`borrowernumber`)
            REFERENCES `housebound_profile` (`borrowernumber`)
            ON UPDATE CASCADE ON DELETE CASCADE,
          CONSTRAINT `houseboundvisit_bnfk_1`
            FOREIGN KEY (`chooser_brwnumber`)
            REFERENCES `borrowers` (`borrowernumber`)
            ON UPDATE CASCADE ON DELETE CASCADE,
          CONSTRAINT `houseboundvisit_bnfk_2`
            FOREIGN KEY (`deliverer_brwnumber`)
            REFERENCES `borrowers` (`borrowernumber`)
            ON UPDATE CASCADE ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
    });
    $dbh->do(q{
        CREATE TABLE IF NOT EXISTS `housebound_role` (
          `borrowernumber_id` int(11) NOT NULL, -- borrowernumber link
          `housebound_chooser` tinyint(1) NOT NULL DEFAULT 0, -- set to 1 to indicate this patron is a housebound chooser volunteer
          `housebound_deliverer` tinyint(1) NOT NULL DEFAULT 0, -- set to 1 to indicate this patron is a housebound deliverer volunteer
          PRIMARY KEY (`borrowernumber_id`),
          CONSTRAINT `houseboundrole_bnfk`
            FOREIGN KEY (`borrowernumber_id`)
            REFERENCES `borrowers` (`borrowernumber`)
            ON UPDATE CASCADE ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
    });
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences
               (variable,value,options,explanation,type) VALUES
               ('HouseboundModule',0,'',
               'If ON, enable housebound module functionality.','YesNo');
    });
    $dbh->do(q{
        INSERT IGNORE INTO authorised_value_categories( category_name ) VALUES
            ('HSBND_FREQ');
    });
    $dbh->do(q{
        INSERT IGNORE INTO authorised_values (category, authorised_value, lib) VALUES
               ('HSBND_FREQ','EW','Every week');
    });

    print "Upgrade to $DBversion done (Bug 5670 - Housebound Readers Module)\n";
    SetVersion($DBversion);
}

$DBversion = "16.06.00.037";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        ALTER TABLE `issuingrules` ADD `article_requests` ENUM( 'no', 'yes', 'bib_only', 'item_only' ) NOT NULL DEFAULT 'no' AFTER `opacitemholds`;
    });
    $dbh->do(q{
        INSERT INTO `systempreferences` (`variable`, `value`, `options`, `explanation`, `type`) VALUES
            ('ArticleRequests', '0', NULL, 'Enables the article request feature', 'YesNo'),
            ('ArticleRequestsMandatoryFields', '', NULL, 'Comma delimited list of required fields for bibs where article requests rule = ''yes''', 'multiple'),
            ('ArticleRequestsMandatoryFieldsItemsOnly', '', NULL, 'Comma delimited list of required fields for bibs where article requests rule = ''item_only''', 'multiple'),
            ('ArticleRequestsMandatoryFieldsRecordOnly', '', NULL, 'Comma delimited list of required fields for bibs where article requests rule = ''bib_only''', 'multiple');
    });
    $dbh->do(q{
        CREATE TABLE IF NOT EXISTS `article_requests` (
          `id` int(11) NOT NULL AUTO_INCREMENT,
          `borrowernumber` int(11) NOT NULL,
          `biblionumber` int(11) NOT NULL,
          `itemnumber` int(11) DEFAULT NULL,
          `branchcode` varchar(10) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
          `title` text,
          `author` text,
          `volume` text,
          `issue` text,
          `date` text,
          `pages` text,
          `chapters` text,
          `patron_notes` text,
          `status` enum('PENDING','PROCESSING','COMPLETED','CANCELED') NOT NULL DEFAULT 'PENDING',
          `notes` text,
          `created_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
          `updated_on` timestamp NULL DEFAULT NULL,
          PRIMARY KEY (`id`),
          KEY `borrowernumber` (`borrowernumber`),
          KEY `biblionumber` (`biblionumber`),
          KEY `itemnumber` (`itemnumber`),
          KEY `branchcode` (`branchcode`),
          CONSTRAINT `article_requests_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
          CONSTRAINT `article_requests_ibfk_2` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE,
          CONSTRAINT `article_requests_ibfk_3` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE SET NULL ON UPDATE CASCADE,
          CONSTRAINT `article_requests_ibfk_4` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE SET NULL ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
    });
    $dbh->do(q{
        INSERT INTO `letter` (`module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content`, `message_transport_type`) VALUES
        ('circulation', 'AR_CANCELED', '', 'Article Request - Email - Canceled', 0, 'Article Request Canceled', '<<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>)\r\n\r\nYour request for an article from <<biblio.title>> (<<items.barcode>>) has been canceled for the following reason:\r\n\r\n<<article_requests.notes>>\r\n\r\nArticle requested:\r\nTitle: <<article_requests.title>>\r\nAuthor: <<article_requests.author>>\r\nVolume: <<article_requests.volume>>\r\nIssue: <<article_requests.issue>>\r\nDate: <<article_requests.date>>\r\nPages: <<article_requests.pages>>\r\nChapters: <<article_requests.chapters>>\r\nNotes: <<article_requests.patron_notes>>\r\n', 'email'),
        ('circulation', 'AR_COMPLETED', '', 'Article Request - Email - Completed', 0, 'Article Request Completed', '<<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>)\r\n\r\nWe are have completed your request for an article from <<biblio.title>> (<<items.barcode>>).\r\n\r\nArticle requested:\r\nTitle: <<article_requests.title>>\r\nAuthor: <<article_requests.author>>\r\nVolume: <<article_requests.volume>>\r\nIssue: <<article_requests.issue>>\r\nDate: <<article_requests.date>>\r\nPages: <<article_requests.pages>>\r\nChapters: <<article_requests.chapters>>\r\nNotes: <<article_requests.patron_notes>>\r\n\r\nYou may pick your article up at <<branches.branchname>>.\r\n\r\nThank you!', 'email'),
        ('circulation', 'AR_PENDING', '', 'Article Request - Email - Open', 0, 'Article Request Received', '<<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>)\r\n\r\nWe have received your request for an article from <<biblio.title>> (<<items.barcode>>).\r\n\r\nArticle requested:\r\nTitle: <<article_requests.title>>\r\nAuthor: <<article_requests.author>>\r\nVolume: <<article_requests.volume>>\r\nIssue: <<article_requests.issue>>\r\nDate: <<article_requests.date>>\r\nPages: <<article_requests.pages>>\r\nChapters: <<article_requests.chapters>>\r\nNotes: <<article_requests.patron_notes>>\r\n\r\n\r\nThank you!', 'email'),
        ('circulation', 'AR_SLIP', '', 'Article Request - Print Slip', 0, 'Test', 'Article Request:\r\n\r\n<<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>)\r\n\r\nTitle: <<biblio.title>>\r\nBarcode: <<items.barcode>>\r\n\r\nArticle requested:\r\nTitle: <<article_requests.title>>\r\nAuthor: <<article_requests.author>>\r\nVolume: <<article_requests.volume>>\r\nIssue: <<article_requests.issue>>\r\nDate: <<article_requests.date>>\r\nPages: <<article_requests.pages>>\r\nChapters: <<article_requests.chapters>>\r\nNotes: <<article_requests.patron_notes>>\r\n', 'print'),
        ('circulation', 'AR_PROCESSING', '', 'Article Request - Email - Processing', 0, 'Article Request Processing', '<<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>)\r\n\r\nWe are now processing your request for an article from <<biblio.title>> (<<items.barcode>>).\r\n\r\nArticle requested:\r\nTitle: <<article_requests.title>>\r\nAuthor: <<article_requests.author>>\r\nVolume: <<article_requests.volume>>\r\nIssue: <<article_requests.issue>>\r\nDate: <<article_requests.date>>\r\nPages: <<article_requests.pages>>\r\nChapters: <<article_requests.chapters>>\r\nNotes: <<article_requests.patron_notes>>\r\n\r\nThank you!', 'email');
    });

    print "Upgrade to $DBversion done (Bug 14610 - Add ability to place article requests in Koha)\n";
    SetVersion($DBversion);
}

$DBversion = '16.06.00.038';
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('DefaultPatronSearchFields','surname,firstname,othernames,cardnumber,userid',NULL,'Comma separated list defining the default fields to be used during a patron search','free');
    });

    print "Upgrade to $DBversion done (Bug 14874 - Add ability to search for patrons by date of birth from checkout and patron quick searches)\n";
    SetVersion($DBversion);
}

$DBversion = "16.06.00.039";
if ( CheckVersion($DBversion) ) {

    my $sth = $dbh->prepare(q{
        SELECT s.itemnumber, i.itype, b.itemtype
        FROM
         ( SELECT DISTINCT itemnumber
           FROM statistics
           WHERE ( type = "return" OR type = "localuse" ) AND
                 itemtype IS NULL
         ) s
        LEFT JOIN
         ( SELECT itemnumber,biblionumber, itype
             FROM items
           UNION
           SELECT itemnumber,biblionumber, itype
             FROM deleteditems
         ) i
        ON (s.itemnumber=i.itemnumber)
        LEFT JOIN
         ( SELECT biblionumber, itemtype
             FROM biblioitems
           UNION
           SELECT biblionumber, itemtype
             FROM deletedbiblioitems
         ) b
        ON (i.biblionumber=b.biblionumber);
    });
    $sth->execute();

    my $update_sth = $dbh->prepare(q{
        UPDATE statistics
        SET itemtype=?
        WHERE itemnumber=? AND itemtype IS NULL
    });
    my $ilevel_itypes = C4::Context->preference('item-level_itypes');

    while ( my ($itemnumber,$item_itype,$biblio_itype) = $sth->fetchrow_array ) {

        my $effective_itemtype = $ilevel_itypes
                                    ? $item_itype // $biblio_itype
                                    : $biblio_itype;
        warn "item-level_itypes set but no itype defined for item ($itemnumber)"
            if $ilevel_itypes and !defined $item_itype;
        $update_sth->execute( $effective_itemtype, $itemnumber );
    }

    print "Upgrade to $DBversion done (Bug 14598: itemtype is not set on statistics by C4::Circulation::AddReturn)\n";
    SetVersion($DBversion);
}

$DBversion = '16.06.00.040';
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        ALTER TABLE `aqcontacts` ADD `orderacquisition` BOOLEAN NOT NULL DEFAULT 0 AFTER `notes`;
    });
    $dbh->do(q{
        INSERT IGNORE INTO `letter` (module, code, name, title, content, message_transport_type) VALUES
        ('orderacquisition','ACQORDER','Acquisition order','Order','<<aqbooksellers.name>>\r\n<<aqbooksellers.address1>>\r\n<<aqbooksellers.address2>>\r\n<<aqbooksellers.address3>>\r\n<<aqbooksellers.address4>>\r\n<<aqbooksellers.phone>>\r\n\r\nPlease order for the library:\r\n\r\n<order>Ordernumber <<aqorders.ordernumber>> (<<biblio.title>>) (quantity: <<aqorders.quantity>>) ($<<aqorders.listprice>> each).</order>\r\n\r\nThank you,\n\n<<branches.branchname>>', 'email');
    });

    print "Upgrade to $DBversion done (Bug 5260 - Add option to send an order by e-mail to the acquisition module)\n";
    SetVersion($DBversion);
}

$DBversion = '16.06.00.041';
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES ('AggressiveMatchOnISSN','0','If enabled, attempt to match aggressively by trying all variations of the ISSNs in the imported record as a phrase in the ISSN fields of already cataloged records when matching on ISSN with the record import tool','','YesNo')
    });

    print "Upgrade to $DBversion done (Bug 14629 - Add aggressive ISSN matching feature equivalent to the aggressive ISBN matcher)\n";
    SetVersion($DBversion);
}

$DBversion = '16.06.00.042';
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        ALTER TABLE aqorders
            ADD COLUMN unitprice_tax_excluded decimal(28,6) default NULL AFTER unitprice,
            ADD COLUMN unitprice_tax_included decimal(28,6) default NULL AFTER unitprice_tax_excluded,
            ADD COLUMN rrp_tax_excluded decimal(28,6) default NULL AFTER rrp,
            ADD COLUMN rrp_tax_included decimal(28,6) default NULL AFTER rrp_tax_excluded,
            ADD COLUMN ecost_tax_excluded decimal(28,6) default NULL AFTER ecost,
            ADD COLUMN ecost_tax_included decimal(28,6) default NULL AFTER ecost_tax_excluded,
            ADD COLUMN tax_value decimal(6,4) default NULL AFTER gstrate
    |);

    # rename gstrate with tax_rate
    $dbh->do(q|ALTER TABLE aqorders CHANGE COLUMN gstrate tax_rate decimal(6,4) DEFAULT NULL|);
    $dbh->do(q|ALTER TABLE aqbooksellers CHANGE COLUMN gstrate tax_rate decimal(6,4) DEFAULT NULL|);

    # Fill the new columns
    my $orders = $dbh->selectall_arrayref(q|
        SELECT * FROM aqorders
    |, { Slice => {} } );

    my $sth_update_order = $dbh->prepare(q|
        UPDATE aqorders
        SET unitprice_tax_excluded = ?,
            unitprice_tax_included = ?,
            rrp_tax_excluded = ?,
            rrp_tax_included = ?,
            ecost_tax_excluded = ?,
            ecost_tax_included = ?,
            tax_value = ?
        WHERE ordernumber = ?
    |);

    my $sth_get_bookseller = $dbh->prepare(q|
        SELECT aqbooksellers.*
        FROM aqbooksellers
        LEFT JOIN aqbasket ON aqbasket.booksellerid = aqbooksellers.id
        LEFT JOIN aqorders ON aqorders.basketno = aqbasket.basketno
        WHERE ordernumber = ?
    |);

    require Koha::Number::Price;
    for my $order ( @$orders ) {
        $sth_get_bookseller->execute( $order->{ordernumber} );
        my ( $bookseller ) = $sth_get_bookseller->fetchrow_hashref;
        $order->{rrp}   = Koha::Number::Price->new( $order->{rrp} )->round;
        $order->{ecost} = Koha::Number::Price->new( $order->{ecost} )->round;
        $order->{tax_rate} ||= 0 ; # tax_rate can be NULL in DB
        # Ordering
        if ( $bookseller->{listincgst} ) {
            $order->{rrp_tax_included} = $order->{rrp};
            $order->{rrp_tax_excluded} = Koha::Number::Price->new(
                $order->{rrp_tax_included} / ( 1 + $order->{tax_rate} ) )->round;
            $order->{ecost_tax_included} = $order->{ecost};
            $order->{ecost_tax_excluded} = Koha::Number::Price->new(
                $order->{ecost} / ( 1 + $order->{tax_rate} ) )->round;
        }
        else {
            $order->{rrp_tax_excluded} = $order->{rrp};
            $order->{rrp_tax_included} = Koha::Number::Price->new(
                $order->{rrp} * ( 1 + $order->{tax_rate} ) )->round;
            $order->{ecost_tax_excluded} = $order->{ecost};
            $order->{ecost_tax_included} = Koha::Number::Price->new(
                $order->{ecost} * ( 1 + $order->{tax_rate} ) )->round;
        }

        #receiving
        if ( $bookseller->{listincgst} ) {
            $order->{unitprice_tax_included} = Koha::Number::Price->new( $order->{unitprice} )->round;
            $order->{unitprice_tax_excluded} = Koha::Number::Price->new(
              $order->{unitprice_tax_included} / ( 1 + $order->{tax_rate} ) )->round;
        }
        else {
            $order->{unitprice_tax_excluded} = Koha::Number::Price->new( $order->{unitprice} )->round;
            $order->{unitprice_tax_included} = Koha::Number::Price->new(
              $order->{unitprice_tax_excluded} * ( 1 + $order->{tax_rate} ) )->round;
        }

        # If the order is received, the tax is calculated from the unit price
        if ( $order->{orderstatus} eq 'complete' ) {
            $order->{tax_value} = Koha::Number::Price->new(
              ( $order->{unitprice_tax_included} - $order->{unitprice_tax_excluded} )
              * $order->{quantity} )->round;
        } else {
            # otherwise the ecost is used
            $order->{tax_value} = Koha::Number::Price->new(
                ( $order->{ecost_tax_included} - $order->{ecost_tax_excluded} ) *
                  $order->{quantity} )->round;
        }

        $sth_update_order->execute(
            $order->{unitprice_tax_excluded},
            $order->{unitprice_tax_included},
            $order->{rrp_tax_excluded},
            $order->{rrp_tax_included},
            $order->{ecost_tax_excluded},
            $order->{ecost_tax_included},
            $order->{tax_value},
            $order->{ordernumber},
        );
    }

    print "Upgrade to $DBversion done (Bug 13321 - Tax and prices calculation need to be fixed)\n";
    SetVersion($DBversion);
}

$DBversion = '16.06.00.043';
if ( CheckVersion($DBversion) ) {
    # Add the new columns
    $dbh->do(q|
        ALTER TABLE aqorders
            ADD COLUMN tax_rate_on_ordering   decimal(6,4) default NULL AFTER tax_rate,
            ADD COLUMN tax_rate_on_receiving  decimal(6,4) default NULL AFTER tax_rate_on_ordering,
            ADD COLUMN tax_value_on_ordering  decimal(28,6) default NULL AFTER tax_value,
            ADD COLUMN tax_value_on_receiving decimal(28,6) default NULL AFTER tax_value_on_ordering
    |);

    my $orders = $dbh->selectall_arrayref(q|
        SELECT * FROM aqorders
    |, { Slice => {} } );

    my $sth_update_order = $dbh->prepare(q|
        UPDATE aqorders
        SET tax_rate_on_ordering = tax_rate,
            tax_rate_on_receiving = tax_rate,
            tax_value_on_ordering = ?,
            tax_value_on_receiving = ?
        WHERE ordernumber = ?
    |);

    require Koha::Number::Price;
    for my $order (@$orders) {
        my $tax_value_on_ordering =
          $order->{quantity} *
          $order->{ecost_tax_excluded} *
          $order->{tax_rate};

        my $tax_value_on_receiving =
          ( defined $order->{unitprice_tax_excluded} )
          ? $order->{quantity} * $order->{unitprice_tax_excluded} * $order->{tax_rate}
          : undef;

        $sth_update_order->execute( $tax_value_on_ordering,
            $tax_value_on_receiving, $order->{ordernumber} );
    }

    # Remove the old columns
    $dbh->do(q|
        ALTER TABLE aqorders
            CHANGE COLUMN tax_value tax_value_bak  decimal(28,6) default NULL,
            CHANGE COLUMN tax_rate tax_rate_bak decimal(6,4) default NULL
    |);

    print "Upgrade to $DBversion done (Bug 13323 - Change the tax rate on receiving)\n";
    SetVersion($DBversion);
}

$DBversion = '16.06.00.044';
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        ALTER TABLE `messages`
        ADD `manager_id` int(11) NULL,
        ADD FOREIGN KEY (`manager_id`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL;
    });

    print "Upgrade to $DBversion done (Bug 17397 - Show name of librarian who created circulation message)\n";
    SetVersion($DBversion);
}

$DBversion = '16.06.00.045';
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        UPDATE systempreferences SET options = "now|dateexpiry|combination", explanation = "Set whether the borrower renewal date should be counted from the dateexpiry, from the current date or by combination: if the dateexpiry is in future use dateexpiry, else use current date " WHERE variable = "BorrowerRenewalPeriodBase";
    });

    print "Upgrade to $DBversion done (Bug 17443 - Make possible to renew patron by later of expiry and current date)\n";
    SetVersion($DBversion);
}

$DBversion = '16.06.00.046';
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        ALTER TABLE issuingrules ADD COLUMN no_auto_renewal_after INT(4) DEFAULT NULL AFTER auto_renew;
    });

    print "Upgrade to $DBversion done (Bug 15581 - Add a circ rule to not allow auto-renewals after defined loan period)\n";
    SetVersion($DBversion);
}

$DBversion = '16.06.00.047';
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        UPDATE language_descriptions SET description = 'Čeština' WHERE subtag = 'cs' AND type = 'language' AND lang = 'cs'
    });

    print "Upgrade to $DBversion done (Bug 17518: Displayed language name for Czech is wrong)\n";
    SetVersion($DBversion);
}

$DBversion = '16.06.00.048';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q|
        INSERT IGNORE INTO permissions (module_bit, code, description) VALUES
        (13, 'upload_general_files', 'Upload any file'),
        (13, 'upload_manage', 'Manage uploaded files');
    |);

    # Update user_permissions for current users (check count in uploaded_files)
    # Note 9 == edit_catalogue and 13 == tools
    # We do not insert if someone is superlibrarian, does not have edit_catalogue,
    # or already has all tools
    $dbh->do(q|
        INSERT IGNORE INTO user_permissions (borrowernumber, module_bit, code)
        SELECT borrowernumber, 13, 'upload_general_files'
        FROM borrowers bo
        WHERE flags<>1 AND flags & POW(2,13) = 0 AND
            ( flags & POW(2,9) > 0 OR (
                SELECT COUNT(*) FROM user_permissions
                WHERE borrowernumber=bo.borrowernumber AND module_bit=9 ) > 0 )
            AND ( SELECT COUNT(*) FROM uploaded_files ) > 0;
    |);

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 17663 - Forgotten userpermissions)\n";
}

$DBversion = '16.06.00.049';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q|
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) 
        VALUES ('ReplytoDefault',  '',  NULL,  'The default email address to be set as replyto.',  'Free');
    |);

    $dbh->do(q|
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
        VALUES ('ReturnpathDefault',  '',  NULL,  'The default email address to be set as return-path',  'Free');
    |);

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 17391 - ReturnpathDefault and ReplyToDefault missing from syspref.sql)\n";
}

$DBversion = "16.06.00.050";
if ( CheckVersion($DBversion) ) {

    # If index issn_idx still exists, we assume that dbrev 3.15.00.049 failed,
    # and we repeat it (partially).
    # Note: the db rev only pertains to biblioitems and is not needed for
    # deletedbiblioitems.

    my $temp = $dbh->selectall_arrayref( "SHOW INDEXES FROM biblioitems WHERE key_name = 'issn_idx'" );

    if( @$temp > 0 ) {
        $dbh->do( "ALTER TABLE biblioitems DROP INDEX isbn" );
        $dbh->do( "ALTER TABLE biblioitems DROP INDEX issn" );
        $dbh->do( "ALTER TABLE biblioitems DROP INDEX issn_idx" );
        $dbh->do( "ALTER TABLE biblioitems CHANGE isbn isbn MEDIUMTEXT NULL DEFAULT NULL, CHANGE issn issn MEDIUMTEXT NULL DEFAULT NULL" );
        $dbh->do( "ALTER TABLE biblioitems ADD INDEX isbn ( isbn ( 255 ) ), ADD INDEX issn ( issn ( 255 ) )" );
        print "Upgrade to $DBversion done (Bug 8835). Removed issn_idx.\n";
    } else {
        print "Upgrade to $DBversion done (Bug 8835). Everything is fine.\n";
    }

    SetVersion($DBversion);
}

$DBversion = "16.11.00.000";
if ( CheckVersion($DBversion) ) {
    print "Upgrade to $DBversion done (Koha 16.11)\n";
    SetVersion($DBversion);
}

$DBversion = "16.12.00.000";
if ( CheckVersion($DBversion) ) {
    print "Upgrade to $DBversion done (Koha 16.12 - Our battered suitcases were piled on the sidewalk again; we had longer ways to go. But no matter, the road is life.)\n";
    SetVersion($DBversion);
}

$DBversion = "16.12.00.001";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        ALTER TABLE borrower_modifications
        ADD COLUMN extended_attributes text DEFAULT NULL
        AFTER privacy
    });

    print "Upgrade to $DBversion done (Bug 17767 - Let Koha::Patron::Modification handle extended attributes)\n";
    SetVersion($DBversion);
}

$DBversion = '16.12.00.002';
if ( CheckVersion($DBversion) ) {
    unless (column_exists( 'branchtransfers', 'branchtransfer_id' )
        and index_exists( 'branchtransfers', 'PRIMARY' ) )
    {
        $dbh->do(
            "ALTER TABLE branchtransfers
                 ADD COLUMN branchtransfer_id int(12) NOT NULL auto_increment FIRST, ADD CONSTRAINT PRIMARY KEY (branchtransfer_id);"
        );
    }

    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 14187 - branchtransfer needs a primary key (id) for DBIx and common sense.)\n";
}

$DBversion = '16.12.00.003';
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{DELETE FROM systempreferences WHERE variable="Persona"});
    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 17486 - Remove 'Mozilla Persona' as an authentication method)\n";
}

$DBversion = '16.12.00.004';
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        CREATE TABLE biblio_metadata (
            `id` INT(11) NOT NULL AUTO_INCREMENT,
            `biblionumber` INT(11) NOT NULL,
            `format` VARCHAR(16) NOT NULL,
            `marcflavour` VARCHAR(16) NOT NULL,
            `metadata` LONGTEXT NOT NULL,
            PRIMARY KEY(id),
            UNIQUE KEY `biblio_metadata_uniq_key` (`biblionumber`,`format`,`marcflavour`),
            CONSTRAINT `biblio_metadata_fk_1` FOREIGN KEY (biblionumber) REFERENCES biblio (biblionumber) ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
    });
    $dbh->do(q{
        CREATE TABLE deletedbiblio_metadata (
            `id` INT(11) NOT NULL AUTO_INCREMENT,
            `biblionumber` INT(11) NOT NULL,
            `format` VARCHAR(16) NOT NULL,
            `marcflavour` VARCHAR(16) NOT NULL,
            `metadata` LONGTEXT NOT NULL,
            PRIMARY KEY(id),
            UNIQUE KEY `deletedbiblio_metadata_uniq_key` (`biblionumber`,`format`,`marcflavour`),
            CONSTRAINT `deletedbiblio_metadata_fk_1` FOREIGN KEY (biblionumber) REFERENCES deletedbiblio (biblionumber) ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
    });
    $dbh->do(q{
        INSERT INTO biblio_metadata ( biblionumber, format, marcflavour, metadata ) SELECT biblionumber, 'marcxml', 'CHANGEME', marcxml FROM biblioitems;
    });
    $dbh->do(q{
        INSERT INTO deletedbiblio_metadata ( biblionumber, format, marcflavour, metadata ) SELECT biblionumber, 'marcxml', 'CHANGEME', marcxml FROM deletedbiblioitems;
    });
    $dbh->do(q{
        UPDATE biblio_metadata SET marcflavour = (SELECT value FROM systempreferences WHERE variable="marcflavour");
    });
    $dbh->do(q{
        UPDATE deletedbiblio_metadata SET marcflavour = (SELECT value FROM systempreferences WHERE variable="marcflavour");
    });
    $dbh->do(q{
        ALTER TABLE biblioitems DROP COLUMN marcxml;
    });
    $dbh->do(q{
        ALTER TABLE deletedbiblioitems DROP COLUMN marcxml;
    });
    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 17196 - Move marcxml out of the biblioitems table)\n";
}

$DBversion = '16.12.00.005';
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES('AuthorityMergeMode','loose','loose|strict','Authority merge mode','Choice')");

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 17913 - AuthorityMergeMode)\n";
}

$DBversion = "16.12.00.006";
if ( CheckVersion($DBversion) ) {
    unless (     column_exists( 'borrower_attributes', 'id' )
             and index_exists( 'borrower_attributes', 'PRIMARY' ) )
    {
        $dbh->do(q{
            ALTER TABLE `borrower_attributes`
                ADD `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST
        });
    }

    print "Upgrade to $DBversion done (Bug 17813: Table borrower_attributes needs a primary key\n";
    SetVersion($DBversion);
}

$DBversion = "16.12.00.007";
if( CheckVersion( $DBversion ) ) {

    if ( column_exists('opac_news', 'new' ) ) {
        $dbh->do(q|ALTER TABLE opac_news CHANGE COLUMN new content text NOT NULL|);
    }

    $dbh->do(q|
        UPDATE letter SET content = REPLACE(content, "<<opac_news.new>>", "<<opac_news.content>>") WHERE content LIKE "%<<opac_news.new>>%"
    |);

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 17960 - Rename opac_news with opac_news.content (template notices have been updated!))\n";
}

$DBversion = "16.12.00.008";
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES
        ('MarcItemFieldsToOrder','','Set the mapping values for new item records created from a MARC record in a staged file. In a YAML format.', NULL, 'textarea');
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 15503 - Grab Item Information from Order Files)\n";
}

$DBversion = "16.12.00.009";
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES
        ('OPACHoldsIfAvailableAtPickup','1','','Allow to pickup up holds at libraries where the item is available','YesNo');
    });

    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES
        ('OPACHoldsIfAvailableAtPickupExceptions','','','List the patron categories not affected by OPACHoldsIfAvailableAtPickup if off','Free');
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 17453 - Inter-site holds improvement)\n";
}

$DBversion = "16.12.00.010";
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        ALTER TABLE borrowers ADD overdrive_auth_token text default NULL AFTER lastseen;
    });

    $dbh->do(q{
        ALTER TABLE deletedborrowers ADD overdrive_auth_token text default NULL AFTER lastseen;
    });

    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
        VALUES ('OverDriveCirculation','0','Enable client to see their OverDrive account','','YesNo');
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 16034 - Integration with OverDrive Patron API)\n";
}

$DBversion = "16.12.00.011";
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        ALTER TABLE search_field CHANGE COLUMN type type ENUM('', 'string', 'date', 'number', 'boolean', 'sum') NOT NULL
        COMMENT 'what type of data this holds, relevant when storing it in the search engine';
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 17260 - updatedatabase.pl fails on invalid entries in ENUM and BOOLEAN columns)\n";
}

$DBversion = "16.12.00.012";
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO `systempreferences` (`variable`, `value`, `options`, `explanation`, `type`)
        VALUES ('OpacNewsLibrarySelect', '0', '', 'Show selector for branches on OPAC news page', 'YesNo');
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 14764 - Add OPAC News branch selector)\n";
}

$DBversion = "16.12.00.013";
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type`)
        VALUES ('CircSidebar','0','','Activate or deactivate the navigation sidebar on all Circulation pages','YesNo');
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 16530 - Add a circ sidebar navigation menu)\n";
}

$DBversion = "16.12.00.014";
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
            INSERT INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('LoadSearchHistoryToTheFirstLoggedUser', '1', NULL, 'If ON, the next user will automatically get the last searches in his history', 'YesNo');
            });
            SetVersion( $DBversion );
            print "Upgrade to $DBversion done (Bug 8010 - Search history can be added to the wrong patron)\n";
            }

$DBversion = "16.12.00.015";
if( CheckVersion( $DBversion ) ) {
    unless( column_exists( 'branches', 'geolocation' ) ) {
        $dbh->do(q|
                ALTER TABLE branches ADD COLUMN geolocation VARCHAR(255) DEFAULT NULL after opac_info
                |);
    }

    $dbh->do(q|
            INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type ) VALUES ('UsageStatsGeolocation', '', NULL, 'Geolocation of the main library', 'Free');
            |);
    $dbh->do(q|
            INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type ) VALUES ('UsageStatsLibrariesInfo', '', NULL, 'Share libraries information', 'YesNo');
            |);
    $dbh->do(q|
            INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type ) VALUES ('UsageStatsPublicID', '', NULL, 'Public ID for Hea website', 'Free');
            |);
        
        SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18066 - Hea version 2)\n";
}

$DBversion = "16.12.00.016";
if ( CheckVersion($DBversion) ) {
    unless ( column_exists( 'borrower_attribute_types', 'opac_editable' ) )
    {
        $dbh->do(q{
            ALTER TABLE borrower_attribute_types
                ADD COLUMN `opac_editable` tinyint(1) NOT NULL default 0 AFTER `opac_display`
        });
    }

    print "Upgrade to $DBversion done (Bug 13757: Make patron attributes editable in the opac if set to 'editable in OPAC)'\n";
    SetVersion($DBversion);
}

$DBversion = "16.12.00.017";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
        VALUES ('CumulativeRestrictionPeriods',  0,  NULL,  'Cumulate the restriction periods instead of keeping the highest',  'YesNo')
    });

    print "Upgrade to $DBversion done (Bug 14146 - Additional days are not added to restriction period when checking-in several overdues for same patron)'\n";
    SetVersion($DBversion);
}

$DBversion = "16.12.00.018";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( variable, value, options, explanation, type )
            SELECT 'ExportCircHistory', COUNT(*), NULL, "Display the export circulation options",  'YesNo'
            FROM systempreferences
            WHERE ( variable = 'ExportRemoveFields' AND value != "" AND value IS NOT NULL )
                OR ( variable = 'ExportWithCsvProfile' AND value != "" AND value IS NOT NULL );
    });

    $dbh->do(q{
        DELETE FROM systempreferences WHERE variable="ExportWithCsvProfile";
    });

    print "Upgrade to $DBversion done (Bug 15498 - Replace ExportWithCsvProfile with ExportCircHistory)'\n";
    SetVersion($DBversion);
}

$DBversion = "16.12.00.019";
if( CheckVersion( $DBversion ) ) {
    if ( column_exists( 'issues', 'return' ) ) {
        $dbh->do(q|ALTER TABLE issues DROP column `return`|);
    }

    if ( column_exists( 'old_issues', 'return' ) ) {
        $dbh->do(q|ALTER TABLE old_issues DROP column `return`|);
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18173 - Remove issues.return DB field)\n";
}

$DBversion = "16.12.00.020";
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        UPDATE systempreferences SET options="any_time_is_placed|not_always|any_time_is_collected" WHERE variable="HoldFeeMode";
    });

    $dbh->do(q{
        UPDATE systempreferences SET value="any_time_is_placed" WHERE variable="HoldFeeMode" AND value="always";
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 17560 - Hold fee placement at point of checkout)\n";
}

$DBversion = "16.12.00.021";
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('RenewalLog','0','','If ON, log information about renewals','YesNo');
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 17708 - Renewal log seems empty)\n";
}

$DBversion = "16.12.00.022";
if( CheckVersion( $DBversion ) ) {
    print "NOTE: The sender for claim notifications has been corrected. The email address of the staff member is no longer used. We will use the branch email address or KohaAdminEmailAddress, as is done for other notices.\n";
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 17866 - Change sender for serial claim notifications)\n";
}

$DBversion = '16.12.00.023';
if( CheckVersion( $DBversion ) ) {
    my $oldval = C4::Context->preference('dontmerge');
    my $newval = $oldval ? 0 : 50;

    # Remove dontmerge, add AuthorityMergeLimit
    $dbh->do(q{
        DELETE FROM systempreferences WHERE variable = 'dontmerge';
    });
    $dbh->do(qq{
        INSERT IGNORE INTO systempreferences ( variable, value, options, explanation, type ) VALUES ('AuthorityMergeLimit','$newval',NULL,'Maximum number of biblio records updated immediately when an authority record has been modified.','integer');
    });

    $dbh->do(q{
        ALTER TABLE need_merge_authorities
            ADD COLUMN authid_new BIGINT AFTER authid,
            ADD COLUMN reportxml text AFTER authid_new,
            ADD COLUMN timestamp timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;
    });

    $dbh->do(q{
        UPDATE need_merge_authorities SET authid_new=authid WHERE done <> 1
    });

    SetVersion( $DBversion );
    if( $newval == 0 ) {
        print "NOTE: Since dontmerge was enabled, we have initialized AuthorityMergeLimit to 0 records. Please consider raising this value. This will allow for performing smaller merges directly and only postponing larger merges.\n";
    }
    print "IMPORTANT NOTE: If you are not using a Debian package install, please verify that you no longer use misc/migration_tools/merge_authority.pl in your cron files AND add misc/cronjobs/merge_authorities.pl to cron now. This job is no longer optional! You need it to perform larger authority merges.\n";
    print "Upgrade to $DBversion done (Bug 9988 - Add AuthorityMergeLimit)\n";
}

$DBversion = '16.12.00.024';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        UPDATE systempreferences SET variable="NoticeBcc" WHERE variable="OverdueNoticeBcc";
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 14537 - The system preference 'OverdueNoticeBcc' is mis-named.)\n";
}

$DBversion = '16.12.00.025';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q|
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` )
        VALUES ('UploadPurgeTemporaryFilesDays','',NULL,'If not empty, number of days used when automatically deleting temporary uploads','integer');
    |);

    my ( $cnt ) = $dbh->selectrow_array( "SELECT COUNT(*) FROM uploaded_files WHERE permanent IS NULL or permanent=0" );
    if( $cnt ) {
        print "NOTE: You have $cnt temporary uploads. You could benefit from setting pref UploadPurgeTemporaryFilesDays now to automatically delete them.\n";
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 17669 - Introduce preference for deleting temporary uploads)\n";
}

$DBversion = '16.12.00.026';
if( CheckVersion( $DBversion ) ) {

    # In order to be overcomplete, we check if the situation is what we expect
    if( !index_exists( 'serialitems', 'PRIMARY' ) ) {
        if( index_exists( 'serialitems', 'serialitemsidx' ) ) {
            $dbh->do(q|
                ALTER TABLE serialitems ADD PRIMARY KEY (itemnumber), DROP INDEX serialitemsidx;
            |);
        } else {
            $dbh->do(q|ALTER TABLE serialitems ADD PRIMARY KEY (itemnumber)|);
        }
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18427 - Add a primary key to serialitems)\n";
}

$DBversion = '16.12.00.027';
if( CheckVersion( $DBversion ) ) {

    $dbh->do(q{
        CREATE TABLE IF NOT EXISTS club_templates (
          id int(11) NOT NULL AUTO_INCREMENT,
          `name` tinytext NOT NULL,
          description text,
          is_enrollable_from_opac tinyint(1) NOT NULL DEFAULT '0',
          is_email_required tinyint(1) NOT NULL DEFAULT '0',
          branchcode varchar(10) NULL DEFAULT NULL,
          date_created timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
          date_updated timestamp NULL DEFAULT NULL,
          is_deletable tinyint(1) NOT NULL DEFAULT '1',
          PRIMARY KEY (id),
          KEY ct_branchcode (branchcode),
          CONSTRAINT `club_templates_ibfk_1` FOREIGN KEY (branchcode) REFERENCES `branches` (branchcode) ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
    });

    $dbh->do(q{
        CREATE TABLE IF NOT EXISTS clubs (
          id int(11) NOT NULL AUTO_INCREMENT,
          club_template_id int(11) NOT NULL,
          `name` tinytext NOT NULL,
          description text,
          date_start date DEFAULT NULL,
          date_end date DEFAULT NULL,
          branchcode varchar(10) NULL DEFAULT NULL,
          date_created timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
          date_updated timestamp NULL DEFAULT NULL,
          PRIMARY KEY (id),
          KEY club_template_id (club_template_id),
          KEY branchcode (branchcode),
          CONSTRAINT clubs_ibfk_1 FOREIGN KEY (club_template_id) REFERENCES club_templates (id) ON DELETE CASCADE ON UPDATE CASCADE,
          CONSTRAINT clubs_ibfk_2 FOREIGN KEY (branchcode) REFERENCES branches (branchcode)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
    });

    $dbh->do(q{
        CREATE TABLE IF NOT EXISTS club_enrollments (
          id int(11) NOT NULL AUTO_INCREMENT,
          club_id int(11) NOT NULL,
          borrowernumber int(11) NOT NULL,
          date_enrolled timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
          date_canceled timestamp NULL DEFAULT NULL,
          date_created timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
          date_updated timestamp NULL DEFAULT NULL,
          branchcode varchar(10) NULL DEFAULT NULL,
          PRIMARY KEY (id),
          KEY club_id (club_id),
          KEY borrowernumber (borrowernumber),
          KEY branchcode (branchcode),
          CONSTRAINT club_enrollments_ibfk_1 FOREIGN KEY (club_id) REFERENCES clubs (id) ON DELETE CASCADE ON UPDATE CASCADE,
          CONSTRAINT club_enrollments_ibfk_2 FOREIGN KEY (borrowernumber) REFERENCES borrowers (borrowernumber) ON DELETE CASCADE ON UPDATE CASCADE,
          CONSTRAINT club_enrollments_ibfk_3 FOREIGN KEY (branchcode) REFERENCES branches (branchcode) ON DELETE SET NULL ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
    });

    $dbh->do(q{
        CREATE TABLE IF NOT EXISTS club_template_enrollment_fields (
          id int(11) NOT NULL AUTO_INCREMENT,
          club_template_id int(11) NOT NULL,
          `name` tinytext NOT NULL,
          description text,
          authorised_value_category varchar(16) DEFAULT NULL,
          PRIMARY KEY (id),
          KEY club_template_id (club_template_id),
          CONSTRAINT club_template_enrollment_fields_ibfk_1 FOREIGN KEY (club_template_id) REFERENCES club_templates (id) ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
    });

    $dbh->do(q{
        CREATE TABLE IF NOT EXISTS club_enrollment_fields (
          id int(11) NOT NULL AUTO_INCREMENT,
          club_enrollment_id int(11) NOT NULL,
          club_template_enrollment_field_id int(11) NOT NULL,
          `value` text NOT NULL,
          PRIMARY KEY (id),
          KEY club_enrollment_id (club_enrollment_id),
          KEY club_template_enrollment_field_id (club_template_enrollment_field_id),
          CONSTRAINT club_enrollment_fields_ibfk_1 FOREIGN KEY (club_enrollment_id) REFERENCES club_enrollments (id) ON DELETE CASCADE ON UPDATE CASCADE,
          CONSTRAINT club_enrollment_fields_ibfk_2 FOREIGN KEY (club_template_enrollment_field_id) REFERENCES club_template_enrollment_fields (id) ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
    });

    $dbh->do(q{
        CREATE TABLE IF NOT EXISTS club_template_fields (
          id int(11) NOT NULL AUTO_INCREMENT,
          club_template_id int(11) NOT NULL,
          `name` tinytext NOT NULL,
          description text,
          authorised_value_category varchar(16) DEFAULT NULL,
          PRIMARY KEY (id),
          KEY club_template_id (club_template_id),
          CONSTRAINT club_template_fields_ibfk_1 FOREIGN KEY (club_template_id) REFERENCES club_templates (id) ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
    });

    $dbh->do(q{
        CREATE TABLE IF NOT EXISTS club_fields (
          id int(11) NOT NULL AUTO_INCREMENT,
          club_template_field_id int(11) NOT NULL,
          club_id int(11) NOT NULL,
          `value` text,
          PRIMARY KEY (id),
          KEY club_template_field_id (club_template_field_id),
          KEY club_id (club_id),
          CONSTRAINT club_fields_ibfk_3 FOREIGN KEY (club_template_field_id) REFERENCES club_template_fields (id) ON DELETE CASCADE ON UPDATE CASCADE,
          CONSTRAINT club_fields_ibfk_4 FOREIGN KEY (club_id) REFERENCES clubs (id) ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
    });

    $dbh->do(q{
        INSERT IGNORE INTO userflags (bit, flag, flagdesc, defaulton) VALUES (21, 'clubs', 'Patron clubs', '0');
    });

    $dbh->do(q{
        INSERT IGNORE INTO permissions (module_bit, code, description) VALUES
           (21, 'edit_templates', 'Create and update club templates'),
           (21, 'edit_clubs', 'Create and update clubs'),
           (21, 'enroll', 'Enroll patrons in clubs')
        ;
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 12461 - Add patron clubs feature)\n";
}

$DBversion = '16.12.00.028';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        UPDATE systempreferences  SET options = 'us|de|fr' WHERE variable = 'AddressFormat';
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18110 - Adds FR to the syspref AddressFormat)\n";
}

$DBversion = '16.12.00.029';
if( CheckVersion( $DBversion ) ) {
    unless( column_exists( 'issues', 'note' ) ) {
        $dbh->do(q|ALTER TABLE issues ADD note mediumtext default NULL AFTER onsite_checkout|);
    }
    unless( column_exists( 'issues', 'notedate' ) ) {
        $dbh->do(q|ALTER TABLE issues ADD notedate datetime default NULL AFTER note|);
    }
    unless( column_exists( 'old_issues', 'note' ) ) {
        $dbh->do(q|ALTER TABLE old_issues ADD note mediumtext default NULL AFTER onsite_checkout|);
    }
    unless( column_exists( 'old_issues', 'notedate' ) ) {
        $dbh->do(q|ALTER TABLE old_issues ADD notedate datetime default NULL AFTER note|);
    }

    $dbh->do(q|
        INSERT IGNORE INTO letter (`module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content`, `message_transport_type`)
        VALUES ('circulation', 'PATRON_NOTE', '', 'Patron note on item', '0', 'Patron issue note', '<<borrowers.firstname>> <<borrowers.surname>> has added a note to the item <<biblio.item>> - <<biblio.author>> (<<biblio.biblionumber>>).','email');
    |);

    $dbh->do(q|
        INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`,`type`)
        VALUES ('AllowCheckoutNotes', '0', NULL, 'Allow patrons to submit notes about checked out items.','YesNo');
    |);

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 14224: Add column issues.note and issues.notedate)\n";
}

$DBversion = '16.12.00.030';
if( CheckVersion( $DBversion ) ) {
    unless( column_exists( 'issuingrules', 'no_auto_renewal_after_hard_limit' ) ) {
        $dbh->do(q{
            ALTER TABLE issuingrules ADD COLUMN no_auto_renewal_after_hard_limit DATE DEFAULT NULL AFTER no_auto_renewal_after;
        });
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 16344 - Add a circ rule to limit the auto renewals given a specific date)\n";
}

$DBversion = '16.12.00.031';
if( CheckVersion( $DBversion ) ) {
    if ( !index_exists( 'biblioitems', 'timestamp' ) ) {
        $dbh->do("ALTER TABLE biblioitems ADD KEY `timestamp` (`timestamp`);");
    }
    if ( !index_exists( 'deletedbiblioitems', 'timestamp' ) ) {
        $dbh->do("ALTER TABLE deletedbiblioitems ADD KEY `timestamp` (`timestamp`);");
    }
    if ( !index_exists( 'items', 'timestamp' ) ) {
        $dbh->do("ALTER TABLE items ADD KEY `timestamp` (`timestamp`);");
    }
    if ( !index_exists( 'deleteditems', 'timestamp' ) ) {
        $dbh->do("ALTER TABLE deleteditems ADD KEY `timestamp` (`timestamp`);");
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 15108: OAI-PMH provider improvements)\n";
}

$DBversion = '16.12.00.032';
if( CheckVersion( $DBversion ) ) {
    require Koha::Calendar;
    require Koha::Holds;

    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) 
        VALUES ('ExcludeHolidaysFromMaxPickUpDelay', '0', 'If ON, reserves max pickup delay takes into account the closed days.', NULL, 'Integer');
    });

    my $waiting_holds = Koha::Holds->search({ found => 'W', priority => 0 });
    my $max_pickup_delay = C4::Context->preference("ReservesMaxPickUpDelay");
    while ( my $hold = $waiting_holds->next ) {

        my $requested_expiration;
        if ($hold->expirationdate) {
            $requested_expiration = dt_from_string($hold->expirationdate);
        }

        my $calendar = Koha::Calendar->new( branchcode => $hold->branchcode );
        my $expirationdate = dt_from_string();
        $expirationdate->add(days => $max_pickup_delay);

        if ( C4::Context->preference("ExcludeHolidaysFromMaxPickUpDelay") ) {
            $expirationdate = $calendar->days_forward( dt_from_string(), $max_pickup_delay );
        }

        my $cmp = $requested_expiration ? DateTime->compare($requested_expiration, $expirationdate) : 0;
        $hold->expirationdate($cmp == -1 ? $requested_expiration->ymd : $expirationdate->ymd)->store;
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 12063 - Update reserves.expirationdate)\n";
}

$DBversion = '16.12.00.033';
if( CheckVersion( $DBversion ) ) {

    if( !column_exists( 'letter', 'lang' ) ) {
        $dbh->do( "ALTER TABLE letter ADD COLUMN lang VARCHAR(25) NOT NULL DEFAULT 'default' AFTER message_transport_type" );
    }

    if( !column_exists( 'borrowers', 'lang' ) ) {
        $dbh->do( "ALTER TABLE borrowers ADD COLUMN lang VARCHAR(25) NOT NULL DEFAULT 'default' AFTER lastseen" );
        $dbh->do( "ALTER TABLE deletedborrowers ADD COLUMN lang VARCHAR(25) NOT NULL DEFAULT 'default' AFTER lastseen" );
    }

    # Add test on existene of this key
    $dbh->do( "ALTER TABLE message_transports DROP FOREIGN KEY message_transports_ibfk_3 ");
    $dbh->do( "ALTER TABLE letter DROP PRIMARY KEY ");
    $dbh->do( "ALTER TABLE letter ADD PRIMARY KEY (`module`, `code`, `branchcode`, `message_transport_type`, `lang`) ");

    $dbh->do( "INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
        VALUES ('TranslateNotices',  '0',  NULL,  'Allow notices to be translated',  'YesNo') ");

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 17762 - Add columns letter.lang and borrowers.lang to allow translation of notices)\n";
}

$DBversion = '16.12.00.034';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` )
        VALUES ('OPACFineNoRenewalsBlockAutoRenew','0','','Block/Allow auto renewals if the patron owe more than OPACFineNoRenewals','YesNo')
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 15582 - Ability to block auto renewals if the OPACFineNoRenewals amount is reached)\n";
}

$DBversion = '16.12.00.035';
if( CheckVersion( $DBversion ) ) {
    if( !column_exists( 'issues', 'auto_renew_error' ) ) {
        $dbh->do(q{
           ALTER TABLE issues ADD COLUMN auto_renew_error VARCHAR(32) DEFAULT NULL AFTER auto_renew;
        });
    }

    if( !column_exists( 'old_issues', 'auto_renew_error' ) ) {
        $dbh->do(q{
            ALTER TABLE old_issues ADD COLUMN auto_renew_error VARCHAR(32) DEFAULT NULL AFTER auto_renew;
        });
    }

    $dbh->do(q{
        INSERT INTO letter (module, code, name, title, content, message_transport_type) VALUES ('circulation', 'AUTO_RENEWALS', 'notification on auto renewing', 'Auto renewals',
"Dear [% borrower.firstname %] [% borrower.surname %],
[% IF checkout.auto_renew_error %]
The following item [% biblio.title %] has not been correctly renewed
[% IF checkout.auto_renew_error == 'too_many' %]
You have reach the maximum of checkouts possible.
[% ELSIF checkout.auto_renew_error == 'on_reserve' %]
This item is on hold for another patron.
[% ELSIF checkout.auto_renew_error == 'restriction' %]
You are currently restricted.
[% ELSIF checkout.auto_renew_error == 'overdue' %]
You have overdues.
[% ELSIF checkout.auto_renew_error == 'auto_too_late' %]
It\'s too late to renew this checkout.
[% ELSIF checkout.auto_renew_error == 'auto_too_much_oweing' %]
You have too much unpaid fines.
[% END %]
[% ELSE %]
The following item [% biblio.title %] has correctly been renewed and is now due [% checkout.date_due %]
[% END %]", 'email');
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 15705 - Notify the user on auto renewing)\n";
}

$DBversion = '16.12.00.036';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type`)
        VALUES ('NumSavedReports', '20', NULL, 'By default, show this number of saved reports.', 'Integer');
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 17465 - Add a System Preference to control number of Saved Reports displayed)\n";
}

$DBversion = '16.12.00.037';
if( CheckVersion( $DBversion ) ) {
    $dbh->do( q|
        INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type`)
        VALUES ('FailedLoginAttempts','','','Number of login attempts before lockout the patron account','Integer');
    |);

    unless( column_exists( 'borrowers', 'login_attempts' ) ) {
        $dbh->do(q|
            ALTER TABLE borrowers ADD COLUMN login_attempts INT(4) DEFAULT 0 AFTER lastseen
        |);
        $dbh->do(q|
            ALTER TABLE deletedborrowers ADD COLUMN login_attempts INT(4) DEFAULT 0 AFTER lastseen
        |);
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18314 - Add FailedLoginAttempts and borrowers.login_attempts)\n";
}

$DBversion = '16.12.00.038';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('ExportRemoveFields','',NULL,'List of fields for non export in circulation.pl (separated by a space)','Free');
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18663 - Missing db update for ExportRemoveFields)\n";
}

$DBversion = '16.12.00.039';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('TalkingTechItivaPhoneNotification','0',NULL,'If ON, enables Talking Tech I-tiva phone notifications','YesNo');
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18600 - Missing db update for TalkingTechItivaPhoneNotification)\n";
}

$DBversion = '17.05.00.000';
if( CheckVersion( $DBversion ) ) {

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Koha 17.05)\n";
}

$DBversion = '17.06.00.000';
if( CheckVersion( $DBversion ) ) {
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (He pai ake te iti i te kore)\n";
}

$DBversion = '17.06.00.001';
if( CheckVersion( $DBversion ) ) {

    unless ( column_exists( 'export_format', 'used_for' ) ) {
        $dbh->do(q|ALTER TABLE export_format ADD used_for varchar(255) DEFAULT 'export_records' AFTER type|);

        $dbh->do(q|UPDATE export_format SET used_for = 'late_issues' WHERE type = 'sql'|);
        $dbh->do(q|UPDATE export_format SET used_for = 'export_records' WHERE type = 'marc'|);
    }
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 8612 - Add new column export_format.used_for)\n";
}

# DEVELOPER PROCESS, search for anything to execute in the db_update directory
# SEE bug 13068
# if there is anything in the atomicupdate, read and execute it.

my $update_dir = C4::Context->config('intranetdir') . '/installer/data/mysql/atomicupdate/';
opendir( my $dirh, $update_dir );
foreach my $file ( sort readdir $dirh ) {
    next if $file !~ /\.(sql|perl)$/;  #skip other files
    next if $file eq 'skeleton.perl'; # skip the skeleton file
    print "DEV atomic update: $file\n";
    if ( $file =~ /\.sql$/ ) {
        my $installer = C4::Installer->new();
        my $rv = $installer->load_sql( $update_dir . $file ) ? 0 : 1;
    } elsif ( $file =~ /\.perl$/ ) {
        my $code = read_file( $update_dir . $file );
        eval $code;
        say "Atomic update generated errors: $@" if $@;
    }
}

=head1 FUNCTIONS

=head2 TableExists($table)

=cut

sub TableExists {
    my $table = shift;
    eval {
                local $dbh->{PrintError} = 0;
                local $dbh->{RaiseError} = 1;
                $dbh->do(qq{SELECT * FROM $table WHERE 1 = 0 });
            };
    return 1 unless $@;
    return 0;
}

=head2 DropAllForeignKeys($table)

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


=head2 TransformToNum

Transform the Koha version from a 4 parts string
to a number, with just 1 .

=cut

sub TransformToNum {
    my $version = shift;
    # remove the 3 last . to have a Perl number
    $version =~ s/(.*\..*)\.(.*)\.(.*)/$1$2$3/;
    # three X's at the end indicate that you are testing patch with dbrev
    # change it into 999
    # prevents error on a < comparison between strings (should be: lt)
    $version =~ s/XXX$/999/;
    return $version;
}

=head2 SetVersion

set the DBversion in the systempreferences

=cut

sub SetVersion {
    return if $_[0]=~ /XXX$/;
      #you are testing a patch with a db revision; do not change version
    my $kohaversion = TransformToNum($_[0]);
    if (C4::Context->preference('Version')) {
      my $finish=$dbh->prepare("UPDATE systempreferences SET value=? WHERE variable='Version'");
      $finish->execute($kohaversion);
    } else {
      my $finish=$dbh->prepare("INSERT into systempreferences (variable,value,explanation) values ('Version',?,'The Koha database version. WARNING: Do not change this value manually, it is maintained by the webinstaller')");
      $finish->execute($kohaversion);
    }
    C4::Context::clear_syspref_cache(); # invalidate cached preferences
}

=head2 CheckVersion

Check whether a given update should be run when passed the proposed version
number. The update will always be run if the proposed version is greater
than the current database version and less than or equal to the version in
kohaversion.pl. The update is also run if the version contains XXX, though
this behavior will be changed following the adoption of non-linear updates
as implemented in bug 7167.

=cut

sub CheckVersion {
    my ($proposed_version) = @_;
    my $version_number = TransformToNum($proposed_version);

    # The following line should be deleted when bug 7167 is pushed
    return 1 if ( $proposed_version =~ m/XXX/ );

    if ( C4::Context->preference("Version") < $version_number
        && $version_number <= TransformToNum( $Koha::VERSION ) )
    {
        return 1;
    }
    else {
        return 0;
    }
}

exit;
