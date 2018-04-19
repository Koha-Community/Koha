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

# Deal with virtualshelves
my $DBversion = "3.00.00.001";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    # update virtualshelves table to
    #
    $dbh->do("ALTER TABLE `bookshelf` RENAME `virtualshelves`");
    $dbh->do("ALTER TABLE `shelfcontents` RENAME `virtualshelfcontents`");
    $dbh->do("ALTER TABLE `virtualshelfcontents` ADD `biblionumber` INT( 11 ) NOT NULL default '0' AFTER shelfnumber");
    $dbh->do("UPDATE `virtualshelfcontents` SET biblionumber=(SELECT biblionumber FROM items WHERE items.itemnumber=virtualshelfcontents.itemnumber)");
    # drop all foreign keys : otherwise, we can't drop itemnumber field.
    DropAllForeignKeys('virtualshelfcontents');
    $dbh->do("ALTER TABLE `virtualshelfcontents` ADD KEY biblionumber (biblionumber)");
    # create the new foreign keys (on biblionumber)
    $dbh->do("ALTER TABLE `virtualshelfcontents` ADD CONSTRAINT `virtualshelfcontents_ibfk_1` FOREIGN KEY (`shelfnumber`) REFERENCES `virtualshelves` (`shelfnumber`) ON DELETE CASCADE ON UPDATE CASCADE");
    # re-create the foreign key on virtualshelf
    $dbh->do("ALTER TABLE `virtualshelfcontents` ADD CONSTRAINT `shelfcontents_ibfk_2` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE");
    $dbh->do("ALTER TABLE `virtualshelfcontents` DROP `itemnumber`");
    print "Upgrade to $DBversion done (virtualshelves)\n";
    SetVersion ($DBversion);
}


$DBversion = "3.00.00.002";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("DROP TABLE sessions");
    $dbh->do("CREATE TABLE `sessions` (
  `id` varchar(32) NOT NULL,
  `a_session` text NOT NULL,
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
    print "Upgrade to $DBversion done (sessions uses CGI::session, new table structure for sessions)\n";
    SetVersion ($DBversion);
}


$DBversion = "3.00.00.003";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    if (C4::Context->preference("opaclanguages") eq "fr") {
        $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('ReservesNeedReturns','0','Si ce paramètre est mis à 1, une réservation posée sur un exemplaire présent sur le site devra être passée en retour pour être disponible. Sinon, elle sera automatiquement disponible, Koha considère que le bibliothécaire place la réservation en ayant le document en mains','','YesNo')");
    } else {
        $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('ReservesNeedReturns','0','If set, a reserve done on an item available in this branch need a check-in, otherwise, a reserve on a specific item, that is on the branch & available is considered as available','','YesNo')");
    }
    print "Upgrade to $DBversion done (adding ReservesNeedReturns systempref, in circulation)\n";
    SetVersion ($DBversion);
}


$DBversion = "3.00.00.004";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` VALUES ('DebugLevel','2','set the level of error info sent to the browser. 0=none, 1=some, 2=most','0|1|2','Choice')");
    print "Upgrade to $DBversion done (adding DebugLevel systempref, in 'Admin' tab)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.005";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("CREATE TABLE `tags` (
                    `entry` varchar(255) NOT NULL default '',
                    `weight` bigint(20) NOT NULL default 0,
                    PRIMARY KEY  (`entry`)
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
                ");
        $dbh->do("CREATE TABLE `nozebra` (
                `server` varchar(20)     NOT NULL,
                `indexname` varchar(40)  NOT NULL,
                `value` varchar(250)     NOT NULL,
                `biblionumbers` longtext NOT NULL,
                KEY `indexname` (`server`,`indexname`),
                KEY `value` (`server`,`value`))
                ENGINE=InnoDB DEFAULT CHARSET=utf8;
                ");
    print "Upgrade to $DBversion done (adding tags and nozebra tables )\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.006";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("UPDATE issues SET issuedate=timestamp WHERE issuedate='0000-00-00'");
    print "Upgrade to $DBversion done (filled issues.issuedate with timestamp)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.007";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('SessionStorage','mysql','Use mysql or a temporary file for storing session data','mysql|tmp','Choice')");
    print "Upgrade to $DBversion done (set SessionStorage variable)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.008";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE `biblio` ADD `datecreated` DATE NOT NULL AFTER `timestamp` ;");
    $dbh->do("UPDATE biblio SET datecreated=timestamp");
    print "Upgrade to $DBversion done (biblio creation date)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.009";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {

    # Create backups of call number columns
    # in case default migration needs to be customized
    #
    # UPGRADE NOTE: temp_upg_biblioitems_call_num should be dropped
    #               after call numbers have been transformed to the new structure
    #
    # Not bothering to do the same with deletedbiblioitems -- assume
    # default is good enough.
    $dbh->do("CREATE TABLE `temp_upg_biblioitems_call_num` AS
              SELECT `biblioitemnumber`, `biblionumber`,
                     `classification`, `dewey`, `subclass`,
                     `lcsort`, `ccode`
              FROM `biblioitems`");

    # biblioitems changes
    $dbh->do("ALTER TABLE `biblioitems` CHANGE COLUMN `volumeddesc` `volumedesc` TEXT,
                                    ADD `cn_source` VARCHAR(10) DEFAULT NULL AFTER `ccode`,
                                    ADD `cn_class` VARCHAR(30) DEFAULT NULL AFTER `cn_source`,
                                    ADD `cn_item` VARCHAR(10) DEFAULT NULL AFTER `cn_class`,
                                    ADD `cn_suffix` VARCHAR(10) DEFAULT NULL AFTER `cn_item`,
                                    ADD `cn_sort` VARCHAR(30) DEFAULT NULL AFTER `cn_suffix`,
                                    ADD `totalissues` INT(10) AFTER `cn_sort`");

    # default mapping of call number columns:
    #   cn_class = concatentation of classification + dewey,
    #              trimmed to fit -- assumes that most users do not
    #              populate both classification and dewey in a single record
    #   cn_item  = subclass
    #   cn_source = left null
    #   cn_sort = lcsort
    #
    # After upgrade, cn_sort will have to be set based on whatever
    # default call number scheme user sets as a preference.  Misc
    # script will be added at some point to do that.
    #
    $dbh->do("UPDATE `biblioitems`
              SET cn_class = SUBSTR(TRIM(CONCAT_WS(' ', `classification`, `dewey`)), 1, 30),
                    cn_item = subclass,
                    `cn_sort` = `lcsort`
            ");

    # Now drop the old call number columns
    $dbh->do("ALTER TABLE `biblioitems` DROP COLUMN `classification`,
                                        DROP COLUMN `dewey`,
                                        DROP COLUMN `subclass`,
                                        DROP COLUMN `lcsort`,
                                        DROP COLUMN `ccode`");

    # deletedbiblio changes
    $dbh->do("ALTER TABLE `deletedbiblio` ALTER COLUMN `frameworkcode` SET DEFAULT '',
                                        DROP COLUMN `marc`,
                                        ADD `datecreated` DATE NOT NULL AFTER `timestamp`");
    $dbh->do("UPDATE deletedbiblio SET datecreated = timestamp");

    # deletedbiblioitems changes
    $dbh->do("ALTER TABLE `deletedbiblioitems`
                        MODIFY `publicationyear` TEXT,
                        CHANGE `volumeddesc` `volumedesc` TEXT,
                        MODIFY `collectiontitle` MEDIUMTEXT DEFAULT NULL AFTER `volumedesc`,
                        MODIFY `collectionissn` TEXT DEFAULT NULL AFTER `collectiontitle`,
                        MODIFY `collectionvolume` MEDIUMTEXT DEFAULT NULL AFTER `collectionissn`,
                        MODIFY `editionstatement` TEXT DEFAULT NULL AFTER `collectionvolume`,
                        MODIFY `editionresponsibility` TEXT DEFAULT NULL AFTER `editionstatement`,
                        MODIFY `place` VARCHAR(255) DEFAULT NULL AFTER `size`,
                        MODIFY `marc` LONGBLOB,
                        ADD `cn_source` VARCHAR(10) DEFAULT NULL AFTER `url`,
                        ADD `cn_class` VARCHAR(30) DEFAULT NULL AFTER `cn_source`,
                        ADD `cn_item` VARCHAR(10) DEFAULT NULL AFTER `cn_class`,
                        ADD `cn_suffix` VARCHAR(10) DEFAULT NULL AFTER `cn_item`,
                        ADD `cn_sort` VARCHAR(30) DEFAULT NULL AFTER `cn_suffix`,
                        ADD `totalissues` INT(10) AFTER `cn_sort`,
                        ADD `marcxml` LONGTEXT NOT NULL AFTER `totalissues`,
                        ADD KEY `isbn` (`isbn`),
                        ADD KEY `publishercode` (`publishercode`)
                    ");

    $dbh->do("UPDATE `deletedbiblioitems`
                SET `cn_class` = SUBSTR(TRIM(CONCAT_WS(' ', `classification`, `dewey`)), 1, 30),
               `cn_item` = `subclass`,
                `cn_sort` = `lcsort`
            ");
    $dbh->do("ALTER TABLE `deletedbiblioitems`
                        DROP COLUMN `classification`,
                        DROP COLUMN `dewey`,
                        DROP COLUMN `subclass`,
                        DROP COLUMN `lcsort`,
                        DROP COLUMN `ccode`
            ");

    # deleteditems changes
    $dbh->do("ALTER TABLE `deleteditems`
                        MODIFY `barcode` VARCHAR(20) DEFAULT NULL,
                        MODIFY `price` DECIMAL(8,2) DEFAULT NULL,
                        MODIFY `replacementprice` DECIMAL(8,2) DEFAULT NULL,
                        DROP `bulk`,
                        MODIFY `itemcallnumber` VARCHAR(30) DEFAULT NULL AFTER `wthdrawn`,
                        MODIFY `holdingbranch` VARCHAR(10) DEFAULT NULL,
                        DROP `interim`,
                        MODIFY `timestamp` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP AFTER `paidfor`,
                        DROP `cutterextra`,
                        ADD `cn_source` VARCHAR(10) DEFAULT NULL AFTER `onloan`,
                        ADD `cn_sort` VARCHAR(30) DEFAULT NULL AFTER `cn_source`,
                        ADD `ccode` VARCHAR(10) DEFAULT NULL AFTER `cn_sort`,
                        ADD `materials` VARCHAR(10) DEFAULT NULL AFTER `ccode`,
                        ADD `uri` VARCHAR(255) DEFAULT NULL AFTER `materials`,
                        MODIFY `marc` LONGBLOB AFTER `uri`,
                        DROP KEY `barcode`,
                        DROP KEY `itembarcodeidx`,
                        DROP KEY `itembinoidx`,
                        DROP KEY `itembibnoidx`,
                        ADD UNIQUE KEY `delitembarcodeidx` (`barcode`),
                        ADD KEY `delitembinoidx` (`biblioitemnumber`),
                        ADD KEY `delitembibnoidx` (`biblionumber`),
                        ADD KEY `delhomebranch` (`homebranch`),
                        ADD KEY `delholdingbranch` (`holdingbranch`)");
    $dbh->do("UPDATE deleteditems SET `ccode` = `itype`");
    $dbh->do("ALTER TABLE deleteditems DROP `itype`");
    $dbh->do("UPDATE `deleteditems` SET `cn_sort` = `itemcallnumber`");

    # items changes
    $dbh->do("ALTER TABLE `items` ADD `cn_source` VARCHAR(10) DEFAULT NULL AFTER `onloan`,
                                ADD `cn_sort` VARCHAR(30) DEFAULT NULL AFTER `cn_source`,
                                ADD `ccode` VARCHAR(10) DEFAULT NULL AFTER `cn_sort`,
                                ADD `materials` VARCHAR(10) DEFAULT NULL AFTER `ccode`,
                                ADD `uri` VARCHAR(255) DEFAULT NULL AFTER `materials`
            ");
    $dbh->do("ALTER TABLE `items`
                        DROP KEY `itembarcodeidx`,
                        ADD UNIQUE KEY `itembarcodeidx` (`barcode`)");

    # map items.itype to items.ccode and
    # set cn_sort to itemcallnumber -- as with biblioitems.cn_sort,
    # will have to be subsequently updated per user's default
    # classification scheme
    $dbh->do("UPDATE `items` SET `cn_sort` = `itemcallnumber`,
                            `ccode` = `itype`");

    $dbh->do("ALTER TABLE `items` DROP `cutterextra`,
                                DROP `itype`");

    print "Upgrade to $DBversion done (major changes to biblio, biblioitems, items, and deleted* versions of same\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.010";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("CREATE INDEX `userid` ON borrowers (`userid`) ");
    print "Upgrade to $DBversion done (userid index added)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.011";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE `branchcategories` CHANGE `categorycode` `categorycode` varchar(10) ");
    $dbh->do("ALTER TABLE `branchcategories` CHANGE `categoryname` `categoryname` varchar(32) ");
    $dbh->do("ALTER TABLE `branchcategories` ADD COLUMN `categorytype` varchar(16) ");
    $dbh->do("UPDATE `branchcategories` SET `categorytype` = 'properties'");
    $dbh->do("ALTER TABLE `branchrelations` CHANGE `categorycode` `categorycode` varchar(10) ");
    print "Upgrade to $DBversion done (added branchcategory type)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.012";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("CREATE TABLE `class_sort_rules` (
                               `class_sort_rule` varchar(10) NOT NULL default '',
                               `description` mediumtext,
                               `sort_routine` varchar(30) NOT NULL default '',
                               PRIMARY KEY (`class_sort_rule`),
                               UNIQUE KEY `class_sort_rule_idx` (`class_sort_rule`)
                             ) ENGINE=InnoDB DEFAULT CHARSET=utf8");
    $dbh->do("CREATE TABLE `class_sources` (
                               `cn_source` varchar(10) NOT NULL default '',
                               `description` mediumtext,
                               `used` tinyint(4) NOT NULL default 0,
                               `class_sort_rule` varchar(10) NOT NULL default '',
                               PRIMARY KEY (`cn_source`),
                               UNIQUE KEY `cn_source_idx` (`cn_source`),
                               KEY `used_idx` (`used`),
                               CONSTRAINT `class_source_ibfk_1` FOREIGN KEY (`class_sort_rule`)
                                          REFERENCES `class_sort_rules` (`class_sort_rule`)
                             ) ENGINE=InnoDB DEFAULT CHARSET=utf8");
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type)
              VALUES('DefaultClassificationSource','ddc',
                     'Default classification scheme used by the collection. E.g., Dewey, LCC, etc.', NULL,'free')");
    $dbh->do("INSERT INTO `class_sort_rules` (`class_sort_rule`, `description`, `sort_routine`) VALUES
                               ('dewey', 'Default filing rules for DDC', 'Dewey'),
                               ('lcc', 'Default filing rules for LCC', 'LCC'),
                               ('generic', 'Generic call number filing rules', 'Generic')");
    $dbh->do("INSERT INTO `class_sources` (`cn_source`, `description`, `used`, `class_sort_rule`) VALUES
                            ('ddc', 'Dewey Decimal Classification', 1, 'dewey'),
                            ('lcc', 'Library of Congress Classification', 1, 'lcc'),
                            ('udc', 'Universal Decimal Classification', 0, 'generic'),
                            ('sudocs', 'SuDoc Classification (U.S. GPO)', 0, 'generic'),
                            ('z', 'Other/Generic Classification Scheme', 0, 'generic')");
    print "Upgrade to $DBversion done (classification sources added)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.013";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("CREATE TABLE `import_batches` (
              `import_batch_id` int(11) NOT NULL auto_increment,
              `template_id` int(11) default NULL,
              `branchcode` varchar(10) default NULL,
              `num_biblios` int(11) NOT NULL default 0,
              `num_items` int(11) NOT NULL default 0,
              `upload_timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP,
              `overlay_action` enum('replace', 'create_new', 'use_template') NOT NULL default 'create_new',
              `import_status` enum('staging', 'staged', 'importing', 'imported', 'reverting', 'reverted', 'cleaned') NOT NULL default 'staging',
              `batch_type` enum('batch', 'z3950') NOT NULL default 'batch',
              `file_name` varchar(100),
              `comments` mediumtext,
              PRIMARY KEY (`import_batch_id`),
              KEY `branchcode` (`branchcode`)
              ) ENGINE=InnoDB DEFAULT CHARSET=utf8");
    $dbh->do("CREATE TABLE `import_records` (
              `import_record_id` int(11) NOT NULL auto_increment,
              `import_batch_id` int(11) NOT NULL,
              `branchcode` varchar(10) default NULL,
              `record_sequence` int(11) NOT NULL default 0,
              `upload_timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP,
              `import_date` DATE default NULL,
              `marc` longblob NOT NULL,
              `marcxml` longtext NOT NULL,
              `marcxml_old` longtext NOT NULL,
              `record_type` enum('biblio', 'auth', 'holdings') NOT NULL default 'biblio',
              `overlay_status` enum('no_match', 'auto_match', 'manual_match', 'match_applied') NOT NULL default 'no_match',
              `status` enum('error', 'staged', 'imported', 'reverted', 'items_reverted') NOT NULL default 'staged',
              `import_error` mediumtext,
              `encoding` varchar(40) NOT NULL default '',
              `z3950random` varchar(40) default NULL,
              PRIMARY KEY (`import_record_id`),
              CONSTRAINT `import_records_ifbk_1` FOREIGN KEY (`import_batch_id`)
                          REFERENCES `import_batches` (`import_batch_id`) ON DELETE CASCADE ON UPDATE CASCADE,
              KEY `branchcode` (`branchcode`),
              KEY `batch_sequence` (`import_batch_id`, `record_sequence`)
              ) ENGINE=InnoDB DEFAULT CHARSET=utf8");
    $dbh->do("CREATE TABLE `import_record_matches` (
              `import_record_id` int(11) NOT NULL,
              `candidate_match_id` int(11) NOT NULL,
              `score` int(11) NOT NULL default 0,
              CONSTRAINT `import_record_matches_ibfk_1` FOREIGN KEY (`import_record_id`)
                          REFERENCES `import_records` (`import_record_id`) ON DELETE CASCADE ON UPDATE CASCADE,
              KEY `record_score` (`import_record_id`, `score`)
              ) ENGINE=InnoDB DEFAULT CHARSET=utf8");
    $dbh->do("CREATE TABLE `import_biblios` (
              `import_record_id` int(11) NOT NULL,
              `matched_biblionumber` int(11) default NULL,
              `control_number` varchar(25) default NULL,
              `original_source` varchar(25) default NULL,
              `title` varchar(128) default NULL,
              `author` varchar(80) default NULL,
              `isbn` varchar(14) default NULL,
              `issn` varchar(9) default NULL,
              `has_items` tinyint(1) NOT NULL default 0,
              CONSTRAINT `import_biblios_ibfk_1` FOREIGN KEY (`import_record_id`)
                          REFERENCES `import_records` (`import_record_id`) ON DELETE CASCADE ON UPDATE CASCADE,
              KEY `matched_biblionumber` (`matched_biblionumber`),
              KEY `title` (`title`),
              KEY `isbn` (`isbn`)
              ) ENGINE=InnoDB DEFAULT CHARSET=utf8");
    $dbh->do("CREATE TABLE `import_items` (
              `import_items_id` int(11) NOT NULL auto_increment,
              `import_record_id` int(11) NOT NULL,
              `itemnumber` int(11) default NULL,
              `branchcode` varchar(10) default NULL,
              `status` enum('error', 'staged', 'imported', 'reverted') NOT NULL default 'staged',
              `marcxml` longtext NOT NULL,
              `import_error` mediumtext,
              PRIMARY KEY (`import_items_id`),
              CONSTRAINT `import_items_ibfk_1` FOREIGN KEY (`import_record_id`)
                          REFERENCES `import_records` (`import_record_id`) ON DELETE CASCADE ON UPDATE CASCADE,
              KEY `itemnumber` (`itemnumber`),
              KEY `branchcode` (`branchcode`)
              ) ENGINE=InnoDB DEFAULT CHARSET=utf8");

    $dbh->do("INSERT INTO `import_batches`
                (`overlay_action`, `import_status`, `batch_type`, `file_name`)
              SELECT distinct 'create_new', 'staged', 'z3950', `file`
              FROM   `marc_breeding`");

    $dbh->do("INSERT INTO `import_records`
                (`import_batch_id`, `import_record_id`, `record_sequence`, `marc`, `record_type`, `status`,
                `encoding`, `z3950random`, `marcxml`, `marcxml_old`)
              SELECT `import_batch_id`, `id`, 1, `marc`, 'biblio', 'staged', `encoding`, `z3950random`, '', ''
              FROM `marc_breeding`
              JOIN `import_batches` ON (`file_name` = `file`)");

    $dbh->do("INSERT INTO `import_biblios`
                (`import_record_id`, `title`, `author`, `isbn`)
              SELECT `import_record_id`, `title`, `author`, `isbn`
              FROM   `marc_breeding`
              JOIN   `import_records` ON (`import_record_id` = `id`)");

    $dbh->do("UPDATE `import_batches`
              SET `num_biblios` = (
              SELECT COUNT(*)
              FROM `import_records`
              WHERE `import_batch_id` = `import_batches`.`import_batch_id`
              )");

    $dbh->do("DROP TABLE `marc_breeding`");

    print "Upgrade to $DBversion done (import_batches et al. added)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.014";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE subscription ADD lastbranch VARCHAR(4)");
    print "Upgrade to $DBversion done (userid index added)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.015";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("CREATE TABLE `saved_sql` (
           `id` int(11) NOT NULL auto_increment,
           `borrowernumber` int(11) default NULL,
           `date_created` datetime default NULL,
           `last_modified` datetime default NULL,
           `savedsql` text,
           `last_run` datetime default NULL,
           `report_name` varchar(255) default NULL,
           `type` varchar(255) default NULL,
           `notes` text,
           PRIMARY KEY  (`id`),
           KEY boridx (`borrowernumber`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
    $dbh->do("CREATE TABLE `saved_reports` (
           `id` int(11) NOT NULL auto_increment,
           `report_id` int(11) default NULL,
           `report` longtext,
           `date_run` datetime default NULL,
           PRIMARY KEY  (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
    print "Upgrade to $DBversion done (saved_sql and saved_reports added)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.016";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do(" CREATE TABLE reports_dictionary (
          id int(11) NOT NULL auto_increment,
          name varchar(255) default NULL,
          description text,
          date_created datetime default NULL,
          date_modified datetime default NULL,
          saved_sql text,
          area int(11) default NULL,
          PRIMARY KEY  (id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 ");
    print "Upgrade to $DBversion done (reports_dictionary) added)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.017";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE action_logs DROP PRIMARY KEY");
    $dbh->do("ALTER TABLE action_logs ADD KEY  timestamp (timestamp,user)");
    $dbh->do("ALTER TABLE action_logs ADD action_id INT(11) NOT NULL FIRST");
    $dbh->do("UPDATE action_logs SET action_id = if (\@a, \@a:=\@a+1, \@a:=1)");
    $dbh->do("ALTER TABLE action_logs MODIFY action_id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY");
    print "Upgrade to $DBversion done (added column to action_logs)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.018";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE `zebraqueue`
                    ADD `done` INT NOT NULL DEFAULT '0',
                    ADD `time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ;
            ");
    print "Upgrade to $DBversion done (adding timestamp and done columns to zebraque table to improve problem tracking) added)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.019";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE biblio MODIFY biblionumber INT(11) NOT NULL AUTO_INCREMENT");
    $dbh->do("ALTER TABLE biblioitems MODIFY biblioitemnumber INT(11) NOT NULL AUTO_INCREMENT");
    $dbh->do("ALTER TABLE items MODIFY itemnumber INT(11) NOT NULL AUTO_INCREMENT");
    print "Upgrade to $DBversion done (made bib/item PKs auto_increment)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.020";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE deleteditems
              DROP KEY `delitembarcodeidx`,
              ADD KEY `delitembarcodeidx` (`barcode`)");
    print "Upgrade to $DBversion done (dropped uniqueness of key on deleteditems.barcode)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.021";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE items CHANGE homebranch homebranch VARCHAR(10)");
    $dbh->do("ALTER TABLE deleteditems CHANGE homebranch homebranch VARCHAR(10)");
    $dbh->do("ALTER TABLE statistics CHANGE branch branch VARCHAR(10)");
    $dbh->do("ALTER TABLE subscription CHANGE lastbranch lastbranch VARCHAR(10)");
    print "Upgrade to $DBversion done (extended missed branchcode columns to 10 chars)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.022";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE items
                ADD `damaged` tinyint(1) default NULL AFTER notforloan");
    $dbh->do("ALTER TABLE deleteditems
                ADD `damaged` tinyint(1) default NULL AFTER notforloan");
    print "Upgrade to $DBversion done (adding damaged column to items table)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.023";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
     $dbh->do("INSERT INTO `systempreferences` (variable,value,options,explanation,type)
         VALUES ('yuipath','http://yui.yahooapis.com/2.3.1/build','Insert the path to YUI libraries','','free')");
    print "Upgrade to $DBversion done (adding new system preference for controlling YUI path)\n";
    SetVersion ($DBversion);
}
$DBversion = "3.00.00.024";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE biblioitems CHANGE  itemtype itemtype VARCHAR(10)");
    print "Upgrade to $DBversion done (changing itemtype to (10))\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.025";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE items ADD COLUMN itype VARCHAR(10)");
    $dbh->do("ALTER TABLE deleteditems ADD COLUMN itype VARCHAR(10) AFTER uri");
    if(C4::Context->preference('item-level_itypes')){
        $dbh->do('update items,biblioitems set items.itype=biblioitems.itemtype where items.biblionumber=biblioitems.biblionumber and itype is null');
    }
    print "Upgrade to $DBversion done (reintroduce items.itype - fill from itemtype)\n ";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.026";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,options,explanation,type)
       VALUES ('HomeOrHoldingBranch','homebranch','homebranch|holdingbranch','With independent branches turned on this decides whether to check the items holdingbranch or homebranch at circulatilon','choice')");
    print "Upgrade to $DBversion done (adding new system preference for choosing whether homebranch or holdingbranch is checked in circulation)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.027";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("CREATE TABLE `marc_matchers` (
                `matcher_id` int(11) NOT NULL auto_increment,
                `code` varchar(10) NOT NULL default '',
                `description` varchar(255) NOT NULL default '',
                `record_type` varchar(10) NOT NULL default 'biblio',
                `threshold` int(11) NOT NULL default 0,
                PRIMARY KEY (`matcher_id`),
                KEY `code` (`code`),
                KEY `record_type` (`record_type`)
              ) ENGINE=InnoDB DEFAULT CHARSET=utf8");
    $dbh->do("CREATE TABLE `matchpoints` (
                `matcher_id` int(11) NOT NULL,
                `matchpoint_id` int(11) NOT NULL auto_increment,
                `search_index` varchar(30) NOT NULL default '',
                `score` int(11) NOT NULL default 0,
                PRIMARY KEY (`matchpoint_id`),
                CONSTRAINT `matchpoints_ifbk_1` FOREIGN KEY (`matcher_id`)
                           REFERENCES `marc_matchers` (`matcher_id`) ON DELETE CASCADE ON UPDATE CASCADE
              ) ENGINE=InnoDB DEFAULT CHARSET=utf8");
    $dbh->do("CREATE TABLE `matchpoint_components` (
                `matchpoint_id` int(11) NOT NULL,
                `matchpoint_component_id` int(11) NOT NULL auto_increment,
                sequence int(11) NOT NULL default 0,
                tag varchar(3) NOT NULL default '',
                subfields varchar(40) NOT NULL default '',
                offset int(4) NOT NULL default 0,
                length int(4) NOT NULL default 0,
                PRIMARY KEY (`matchpoint_component_id`),
                KEY `by_sequence` (`matchpoint_id`, `sequence`),
                CONSTRAINT `matchpoint_components_ifbk_1` FOREIGN KEY (`matchpoint_id`)
                           REFERENCES `matchpoints` (`matchpoint_id`) ON DELETE CASCADE ON UPDATE CASCADE
              ) ENGINE=InnoDB DEFAULT CHARSET=utf8");
    $dbh->do("CREATE TABLE `matchpoint_component_norms` (
                `matchpoint_component_id` int(11) NOT NULL,
                `sequence`  int(11) NOT NULL default 0,
                `norm_routine` varchar(50) NOT NULL default '',
                KEY `matchpoint_component_norms` (`matchpoint_component_id`, `sequence`),
                CONSTRAINT `matchpoint_component_norms_ifbk_1` FOREIGN KEY (`matchpoint_component_id`)
                           REFERENCES `matchpoint_components` (`matchpoint_component_id`) ON DELETE CASCADE ON UPDATE CASCADE
              ) ENGINE=InnoDB DEFAULT CHARSET=utf8");
    $dbh->do("CREATE TABLE `matcher_matchpoints` (
                `matcher_id` int(11) NOT NULL,
                `matchpoint_id` int(11) NOT NULL,
                CONSTRAINT `matcher_matchpoints_ifbk_1` FOREIGN KEY (`matcher_id`)
                           REFERENCES `marc_matchers` (`matcher_id`) ON DELETE CASCADE ON UPDATE CASCADE,
                CONSTRAINT `matcher_matchpoints_ifbk_2` FOREIGN KEY (`matchpoint_id`)
                           REFERENCES `matchpoints` (`matchpoint_id`) ON DELETE CASCADE ON UPDATE CASCADE
              ) ENGINE=InnoDB DEFAULT CHARSET=utf8");
    $dbh->do("CREATE TABLE `matchchecks` (
                `matcher_id` int(11) NOT NULL,
                `matchcheck_id` int(11) NOT NULL auto_increment,
                `source_matchpoint_id` int(11) NOT NULL,
                `target_matchpoint_id` int(11) NOT NULL,
                PRIMARY KEY (`matchcheck_id`),
                CONSTRAINT `matcher_matchchecks_ifbk_1` FOREIGN KEY (`matcher_id`)
                           REFERENCES `marc_matchers` (`matcher_id`) ON DELETE CASCADE ON UPDATE CASCADE,
                CONSTRAINT `matcher_matchchecks_ifbk_2` FOREIGN KEY (`source_matchpoint_id`)
                           REFERENCES `matchpoints` (`matchpoint_id`) ON DELETE CASCADE ON UPDATE CASCADE,
                CONSTRAINT `matcher_matchchecks_ifbk_3` FOREIGN KEY (`target_matchpoint_id`)
                           REFERENCES `matchpoints` (`matchpoint_id`) ON DELETE CASCADE ON UPDATE CASCADE
              ) ENGINE=InnoDB DEFAULT CHARSET=utf8");
    print "Upgrade to $DBversion done (added C4::Matcher serialization tables)\n ";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.028";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,options,explanation,type)
       VALUES ('canreservefromotherbranches','1','','With Independent branches on, can a user from one library reserve an item from another library','YesNo')");
    print "Upgrade to $DBversion done (adding new system preference for changing reserve/holds behaviour with independent branches)\n";
    SetVersion ($DBversion);
}


$DBversion = "3.00.00.029";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE `import_batches` ADD `matcher_id` int(11) NULL AFTER `import_batch_id`");
    print "Upgrade to $DBversion done (adding matcher_id to import_batches)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.030";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("
CREATE TABLE services_throttle (
  service_type varchar(10) NOT NULL default '',
  service_count varchar(45) default NULL,
  PRIMARY KEY  (service_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
");
    $dbh->do("INSERT INTO `systempreferences` (variable,value,options,explanation,type)
       VALUES ('FRBRizeEditions',0,'','If ON, Koha will query one or more ISBN web services for associated ISBNs and display an Editions tab on the details pages','YesNo')");
 $dbh->do("INSERT INTO `systempreferences` (variable,value,options,explanation,type)
       VALUES ('XISBN',0,'','Use with FRBRizeEditions. If ON, Koha will use the OCLC xISBN web service in the Editions tab on the detail pages. See: http://www.worldcat.org/affiliate/webservices/xisbn/app.jsp','YesNo')");
 $dbh->do("INSERT INTO `systempreferences` (variable,value,options,explanation,type)
       VALUES ('OCLCAffiliateID','','','Use with FRBRizeEditions and XISBN. You can sign up for an AffiliateID here: http://www.worldcat.org/wcpa/do/AffiliateUserServices?method=initSelfRegister','free')");
 $dbh->do("INSERT INTO `systempreferences` (variable,value,options,explanation,type)
       VALUES ('XISBNDailyLimit',499,'','The xISBN Web service is free for non-commercial use when usage does not exceed 500 requests per day','free')");
 $dbh->do("INSERT INTO `systempreferences` (variable,value,options,explanation,type)
       VALUES ('PINESISBN',0,'','Use with FRBRizeEditions. If ON, Koha will use PINES OISBN web service in the Editions tab on the detail pages.','YesNo')");
 $dbh->do("INSERT INTO `systempreferences` (variable,value,options,explanation,type)
       VALUES ('ThingISBN',0,'','Use with FRBRizeEditions. If ON, Koha will use the ThingISBN web service in the Editions tab on the detail pages.','YesNo')");
    print "Upgrade to $DBversion done (adding services throttle table and sysprefs for xISBN)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.031";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {

$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('QueryStemming',1,'If ON, enables query stemming',NULL,'YesNo')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('QueryFuzzy',1,'If ON, enables fuzzy option for searches',NULL,'YesNo')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('QueryWeightFields',1,'If ON, enables field weighting',NULL,'YesNo')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('WebBasedSelfCheck',0,'If ON, enables the web-based self-check system',NULL,'YesNo')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('numSearchResults',20,'Specify the maximum number of results to display on a page of results',NULL,'free')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('OPACnumSearchResults',20,'Specify the maximum number of results to display on a page of results',NULL,'free')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('maxItemsInSearchResults',20,'Specify the maximum number of items to display for each result on a page of results',NULL,'free')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('defaultSortField',NULL,'Specify the default field used for sorting','relevance|popularity|call_number|pubdate|acqdate|title|author','Choice')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('defaultSortOrder',NULL,'Specify the default sort order','asc|dsc|az|za','Choice')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('OPACdefaultSortField',NULL,'Specify the default field used for sorting','relevance|popularity|call_number|pubdate|acqdate|title|author','Choice')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('OPACdefaultSortOrder',NULL,'Specify the default sort order','asc|dsc|za|az','Choice')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('staffClientBaseURL','','Specify the base URL of the staff client',NULL,'free')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('minPasswordLength',3,'Specify the minimum length of a patron/staff password',NULL,'free')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('noItemTypeImages',0,'If ON, disables item-type images',NULL,'YesNo')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('emailLibrarianWhenHoldIsPlaced',0,'If ON, emails the librarian whenever a hold is placed',NULL,'YesNo')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('holdCancelLength','','Specify how many days before a hold is canceled',NULL,'free')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('libraryAddress','','The address to use for printing receipts, overdues, etc. if different than physical address',NULL,'free')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('finesMode','test','Choose the fines mode, test or production','test|production','Choice')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('globalDueDate','','If set, allows a global static due date for all checkouts',NULL,'free')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('itemBarcodeInputFilter','','If set, allows specification of a item barcode input filter','cuecat','Choice')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('singleBranchMode',0,'Operate in Single-branch mode, hide branch selection in the OPAC',NULL,'YesNo')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('URLLinkText','','Text to display as the link anchor in the OPAC',NULL,'free')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('OPACSubscriptionDisplay','economical','Specify how to display subscription information in the OPAC','economical|off|full','Choice')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('OPACDisplayExtendedSubInfo',1,'If ON, extended subscription information is displayed in the OPAC',NULL,'YesNo')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('OPACViewOthersSuggestions',0,'If ON, allows all suggestions to be displayed in the OPAC',NULL,'YesNo')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('OPACURLOpenInNewWindow',0,'If ON, URLs in the OPAC open in a new window',NULL,'YesNo')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('OPACUserCSS',0,'Add CSS to be included in the OPAC',NULL,'free')");

    print "Upgrade to $DBversion done (adding additional system preference)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.032";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("UPDATE `marc_subfield_structure` SET `kohafield` = 'items.wthdrawn' WHERE `kohafield` = 'items.withdrawn'");
    print "Upgrade to $DBversion done (fixed MARC framework references to items.withdrawn)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.033";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `userflags` VALUES(17,'staffaccess','Modify login / permissions for staff users',0)");
    print "Upgrade to $DBversion done (Adding permissions flag for staff member access modification.  )\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.034";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE `virtualshelves` ADD COLUMN `sortfield` VARCHAR(16) ");
    print "Upgrade to $DBversion done (Adding sortfield for Virtual Shelves.  )\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.035";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("UPDATE marc_subfield_structure
              SET authorised_value = 'cn_source'
              WHERE kohafield IN ('items.cn_source', 'biblioitems.cn_source')
              AND (authorised_value is NULL OR authorised_value = '')");
    print "Upgrade to $DBversion done (MARC frameworks: make classification source a drop-down)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.036";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('OPACItemsResultsDisplay','statuses','statuses : show only the status of items in result list. itemdisplay : show full location of items (branch+location+callnumber) as in staff interface','statuses|itemdetails','Choice');");
    print "Upgrade to $DBversion done (OPACItemsResultsDisplay systempreference added)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.037";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE `borrowers` ADD COLUMN `altcontactfirstname` varchar(255)");
    $dbh->do("ALTER TABLE `borrowers` ADD COLUMN `altcontactsurname` varchar(255)");
    $dbh->do("ALTER TABLE `borrowers` ADD COLUMN `altcontactaddress1` varchar(255)");
    $dbh->do("ALTER TABLE `borrowers` ADD COLUMN `altcontactaddress2` varchar(255)");
    $dbh->do("ALTER TABLE `borrowers` ADD COLUMN `altcontactaddress3` varchar(255)");
    $dbh->do("ALTER TABLE `borrowers` ADD COLUMN `altcontactzipcode` varchar(50)");
    $dbh->do("ALTER TABLE `borrowers` ADD COLUMN `altcontactphone` varchar(50)");
    print "Upgrade to $DBversion done (Adding Alternative Contact Person information to borrowers table)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.038";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("UPDATE `systempreferences` set explanation='Choose the fines mode, off, test (emails admin report) or production (accrue overdue fines).  Requires fines cron script' , options='off|test|production' where variable='finesMode'");
    $dbh->do("DELETE FROM `systempreferences` WHERE variable='hideBiblioNumber'");
    print "Upgrade to $DBversion done ('alter finesMode systempreference, remove superfluous syspref.')\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.039";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('uppercasesurnames',0,'If ON, surnames are converted to upper case in patron entry form',NULL,'YesNo')");
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('CircControl','ItemHomeLibrary','Specify the agency that controls the circulation and fines policy','PickupLibrary|PatronLibrary|ItemHomeLibrary','Choice')");
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('finesCalendar','noFinesWhenClosed','Specify whether to use the Calendar in calculating duedates and fines','ignoreCalendar|noFinesWhenClosed','Choice')");
    # $dbh->do("DELETE FROM `systempreferences` WHERE variable='HomeOrHoldingBranch'"); # Bug #2752
    print "Upgrade to $DBversion done ('add circ sysprefs CircControl, finesCalendar, and uppercasesurnames, and delete HomeOrHoldingBranch.')\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.040";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
	$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('previousIssuesDefaultSortOrder','asc','Specify the sort order of Previous Issues on the circulation page','asc|desc','Choice')");
	$dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('todaysIssuesDefaultSortOrder','desc','Specify the sort order of Todays Issues on the circulation page','asc|desc','Choice')");
	print "Upgrade to $DBversion done ('add circ sysprefs todaysIssuesDefaultSortOrder and previousIssuesDefaultSortOrder.')\n";
    SetVersion ($DBversion);
}


$DBversion = "3.00.00.041";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    # Strictly speaking it is not necessary to explicitly change
    # NULL values to 0, because the ALTER TABLE statement will do that.
    # However, setting them first avoids a warning.
    $dbh->do("UPDATE items SET notforloan = 0 WHERE notforloan IS NULL");
    $dbh->do("UPDATE items SET damaged = 0 WHERE damaged IS NULL");
    $dbh->do("UPDATE items SET itemlost = 0 WHERE itemlost IS NULL");
    $dbh->do("UPDATE items SET wthdrawn = 0 WHERE wthdrawn IS NULL");
    $dbh->do("ALTER TABLE items
                MODIFY notforloan tinyint(1) NOT NULL default 0,
                MODIFY damaged    tinyint(1) NOT NULL default 0,
                MODIFY itemlost   tinyint(1) NOT NULL default 0,
                MODIFY wthdrawn   tinyint(1) NOT NULL default 0");
    $dbh->do("UPDATE deleteditems SET notforloan = 0 WHERE notforloan IS NULL");
    $dbh->do("UPDATE deleteditems SET damaged = 0 WHERE damaged IS NULL");
    $dbh->do("UPDATE deleteditems SET itemlost = 0 WHERE itemlost IS NULL");
    $dbh->do("UPDATE deleteditems SET wthdrawn = 0 WHERE wthdrawn IS NULL");
    $dbh->do("ALTER TABLE deleteditems
                MODIFY notforloan tinyint(1) NOT NULL default 0,
                MODIFY damaged    tinyint(1) NOT NULL default 0,
                MODIFY itemlost   tinyint(1) NOT NULL default 0,
                MODIFY wthdrawn   tinyint(1) NOT NULL default 0");
	print "Upgrade to $DBversion done (disallow NULL in several item status columns)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.04";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE aqbooksellers CHANGE name name mediumtext NOT NULL");
	print "Upgrade to $DBversion done (disallow NULL in aqbooksellers.name; part of fix for bug 1251)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.043";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE `currency` ADD `symbol` varchar(5) default NULL AFTER currency, ADD `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP AFTER symbol");
	print "Upgrade to $DBversion done (currency table: add symbol and timestamp columns)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.044";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE deletedborrowers
  ADD `altcontactfirstname` varchar(255) default NULL,
  ADD `altcontactsurname` varchar(255) default NULL,
  ADD `altcontactaddress1` varchar(255) default NULL,
  ADD `altcontactaddress2` varchar(255) default NULL,
  ADD `altcontactaddress3` varchar(255) default NULL,
  ADD `altcontactzipcode` varchar(50) default NULL,
  ADD `altcontactphone` varchar(50) default NULL
  ");
  $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES
('OPACBaseURL',NULL,'Specify the Base URL of the OPAC, e.g., opac.mylibrary.com, the http:// will be added automatically by Koha.',NULL,'Free'),
('language','en','Set the default language in the staff client.',NULL,'Languages'),
('QueryAutoTruncate',1,'If ON, query truncation is enabled by default',NULL,'YesNo'),
('QueryRemoveStopwords',0,'If ON, stopwords listed in the Administration area will be removed from queries',NULL,'YesNo')
  ");
        print "Upgrade to $DBversion done (syncing deletedborrowers table with borrowers table)\n";
    SetVersion ($DBversion);
}

#-- http://www.w3.org/International/articles/language-tags/

#-- RFC4646
$DBversion = "3.00.00.045";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("
CREATE TABLE language_subtag_registry (
        subtag varchar(25),
        type varchar(25), -- language-script-region-variant-extension-privateuse
        description varchar(25), -- only one of the possible descriptions for ease of reference, see language_descriptions for the complete list
        added date,
        KEY `subtag` (`subtag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8");

#-- TODO: add suppress_scripts
#-- this maps three letter codes defined in iso639.2 back to their
#-- two letter equivilents in rfc4646 (LOC maintains iso639+)
 $dbh->do("CREATE TABLE language_rfc4646_to_iso639 (
        rfc4646_subtag varchar(25),
        iso639_2_code varchar(25),
        KEY `rfc4646_subtag` (`rfc4646_subtag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8");

 $dbh->do("CREATE TABLE language_descriptions (
        subtag varchar(25),
        type varchar(25),
        lang varchar(25),
        description varchar(255),
        KEY `lang` (`lang`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8");

#-- bi-directional support, keyed by script subcode
 $dbh->do("CREATE TABLE language_script_bidi (
        rfc4646_subtag varchar(25), -- script subtag, Arab, Hebr, etc.
        bidi varchar(3), -- rtl ltr
        KEY `rfc4646_subtag` (`rfc4646_subtag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8");

#-- BIDI Stuff, Arabic and Hebrew
 $dbh->do("INSERT INTO language_script_bidi(rfc4646_subtag,bidi)
VALUES( 'Arab', 'rtl')");
 $dbh->do("INSERT INTO language_script_bidi(rfc4646_subtag,bidi)
VALUES( 'Hebr', 'rtl')");

#-- TODO: need to map language subtags to script subtags for detection
#-- of bidi when script is not specified (like ar, he)
 $dbh->do("CREATE TABLE language_script_mapping (
        language_subtag varchar(25),
        script_subtag varchar(25),
        KEY `language_subtag` (`language_subtag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8");

#-- Default mappings between script and language subcodes
 $dbh->do("INSERT INTO language_script_mapping(language_subtag,script_subtag)
VALUES( 'ar', 'Arab')");
 $dbh->do("INSERT INTO language_script_mapping(language_subtag,script_subtag)
VALUES( 'he', 'Hebr')");

        print "Upgrade to $DBversion done (adding language subtag registry and basic BiDi support NOTE: You should import the subtag registry SQL)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.046";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE `subscription` CHANGE `numberlength` `numberlength` int(11) default '0' ,
    		 CHANGE `weeklength` `weeklength` int(11) default '0'");
    $dbh->do("CREATE TABLE `serialitems` (`serialid` int(11) NOT NULL, `itemnumber` int(11) NOT NULL, UNIQUE KEY `serialididx` (`serialid`) ) ENGINE=InnoDB DEFAULT CHARSET=utf8");
    $dbh->do("INSERT INTO `serialitems` SELECT `serialid`,`itemnumber` from serial where NOT ISNULL(itemnumber) && itemnumber <> '' && itemnumber NOT LIKE '%,%'");
	print "Upgrade to $DBversion done (Add serialitems table to link serial issues to items. )\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.047";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('OpacRenewalAllowed',0,'If ON, users can renew their issues directly from their OPAC account',NULL,'YesNo');");
	print "Upgrade to $DBversion done ( Added OpacRenewalAllowed syspref )\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.048";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE `items` ADD `more_subfields_xml` longtext default NULL AFTER `itype`");
	print "Upgrade to $DBversion done (added items.more_subfields_xml)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.049";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
	$dbh->do("ALTER TABLE `z3950servers` ADD `encoding` text default NULL AFTER type ");
	print "Upgrade to $DBversion done ( Added encoding field to z3950servers table )\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.050";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('OpacHighlightedWords','0','If Set, query matched terms are highlighted in OPAC',NULL,'YesNo');");
	print "Upgrade to $DBversion done ( Added OpacHighlightedWords syspref )\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.051";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("UPDATE systempreferences SET explanation = 'Define the current theme for the OPAC interface.' WHERE variable = 'opacthemes';");
	print "Upgrade to $DBversion done ( Corrected opacthemes explanation. )\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.052";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE `deleteditems` ADD `more_subfields_xml` LONGTEXT DEFAULT NULL AFTER `itype`");
	print "Upgrade to $DBversion done ( Adding missing column to deleteditems table. )\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.053";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("CREATE TABLE `printers_profile` (
            `prof_id` int(4) NOT NULL auto_increment,
            `printername` varchar(40) NOT NULL,
            `tmpl_id` int(4) NOT NULL,
            `paper_bin` varchar(20) NOT NULL,
            `offset_horz` float default NULL,
            `offset_vert` float default NULL,
            `creep_horz` float default NULL,
            `creep_vert` float default NULL,
            `unit` char(20) NOT NULL default 'POINT',
            PRIMARY KEY  (`prof_id`),
            UNIQUE KEY `printername` (`printername`,`tmpl_id`,`paper_bin`),
            CONSTRAINT `printers_profile_pnfk_1` FOREIGN KEY (`tmpl_id`) REFERENCES `labels_templates` (`tmpl_id`) ON DELETE CASCADE ON UPDATE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8 ");
    $dbh->do("CREATE TABLE `labels_profile` (
            `tmpl_id` int(4) NOT NULL,
            `prof_id` int(4) NOT NULL,
            UNIQUE KEY `tmpl_id` (`tmpl_id`),
            UNIQUE KEY `prof_id` (`prof_id`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8 ");
    print "Upgrade to $DBversion done ( Printer Profile tables added )\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.054";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("UPDATE systempreferences SET options = 'incremental|annual|hbyymmincr|OFF', explanation = 'Used to autogenerate a barcode: incremental will be of the form 1, 2, 3; annual of the form 2007-0001, 2007-0002; hbyymmincr of the form HB08010001 where HB = Home Branch' WHERE variable = 'autoBarcode';");
	print "Upgrade to $DBversion done ( Added another barcode autogeneration sequence to barcode.pl. )\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.055";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE `zebraqueue` ADD KEY `zebraqueue_lookup` (`server`, `biblio_auth_number`, `operation`, `done`)");
	print "Upgrade to $DBversion done ( Added index on zebraqueue. )\n";
    SetVersion ($DBversion);
}
$DBversion = "3.00.00.056";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    if (C4::Context->preference("marcflavour") eq 'UNIMARC') {
        $dbh->do("INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value` , `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES ('995', 'v', 'Note sur le N° de périodique','Note sur le N° de périodique', 0, 0, 'items.enumchron', 10, '', '', '', 0, 0, '', '', '', NULL) ");
    } else {
        $dbh->do("INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value` , `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES ('952', 'h', 'Serial Enumeration / chronology','Serial Enumeration / chronology', 0, 0, 'items.enumchron', 10, '', '', '', 0, 0, '', '', '', NULL) ");
    }
    $dbh->do("ALTER TABLE `items` ADD `enumchron` VARCHAR(80) DEFAULT NULL;");
    print "Upgrade to $DBversion done ( Added item.enumchron column, and framework map to 952h )\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.057";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('OAI-PMH','0','if ON, OAI-PMH server is enabled',NULL,'YesNo');");
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('OAI-PMH:archiveID','KOHA-OAI-TEST','OAI-PMH archive identification',NULL,'Free');");
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('OAI-PMH:MaxCount','50','OAI-PMH maximum number of records by answer to ListRecords and ListIdentifiers queries',NULL,'Integer');");
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('OAI-PMH:Set','SET,Experimental set\r\nSET:SUBSET,Experimental subset','OAI-PMH exported set, the set name is followed by a comma and a short description, one set by line',NULL,'Free');");
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('OAI-PMH:Subset',\"itemtype='BOOK'\",'Restrict answer to matching raws of the biblioitems table (experimental)',NULL,'Free');");
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.058";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE `opac_news`
                CHANGE `lang` `lang` VARCHAR( 25 )
                CHARACTER SET utf8
                COLLATE utf8_general_ci
                NOT NULL default ''");
	print "Upgrade to $DBversion done ( lang field in opac_news made longer )\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.059";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {

    $dbh->do("CREATE TABLE IF NOT EXISTS `labels_templates` (
            `tmpl_id` int(4) NOT NULL auto_increment,
            `tmpl_code` char(100)  default '',
            `tmpl_desc` char(100) default '',
            `page_width` float default '0',
            `page_height` float default '0',
            `label_width` float default '0',
            `label_height` float default '0',
            `topmargin` float default '0',
            `leftmargin` float default '0',
            `cols` int(2) default '0',
            `rows` int(2) default '0',
            `colgap` float default '0',
            `rowgap` float default '0',
            `active` int(1) default NULL,
            `units` char(20)  default 'PX',
            `fontsize` int(4) NOT NULL default '3',
            PRIMARY KEY  (`tmpl_id`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
    $dbh->do("CREATE TABLE  IF NOT EXISTS `printers_profile` (
            `prof_id` int(4) NOT NULL auto_increment,
            `printername` varchar(40) NOT NULL,
            `tmpl_id` int(4) NOT NULL,
            `paper_bin` varchar(20) NOT NULL,
            `offset_horz` float default NULL,
            `offset_vert` float default NULL,
            `creep_horz` float default NULL,
            `creep_vert` float default NULL,
            `unit` char(20) NOT NULL default 'POINT',
            PRIMARY KEY  (`prof_id`),
            UNIQUE KEY `printername` (`printername`,`tmpl_id`,`paper_bin`),
            CONSTRAINT `printers_profile_pnfk_1` FOREIGN KEY (`tmpl_id`) REFERENCES `labels_templates` (`tmpl_id`) ON DELETE CASCADE ON UPDATE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8 ");
    print "Upgrade to $DBversion done ( Added labels_templates table if it did not exist. )\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.060";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("CREATE TABLE IF NOT EXISTS `patronimage` (
            `cardnumber` varchar(16) NOT NULL,
            `mimetype` varchar(15) NOT NULL,
            `imagefile` mediumblob NOT NULL,
            PRIMARY KEY  (`cardnumber`),
            CONSTRAINT `patronimage_fk1` FOREIGN KEY (`cardnumber`) REFERENCES `borrowers` (`cardnumber`) ON DELETE CASCADE ON UPDATE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
	print "Upgrade to $DBversion done ( Added patronimage table. )\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.061";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE labels_templates ADD COLUMN font char(10) NOT NULL DEFAULT 'TR';");
	print "Upgrade to $DBversion done ( Added font column to labels_templates )\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.062";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("CREATE TABLE `old_issues` (
                `borrowernumber` int(11) default NULL,
                `itemnumber` int(11) default NULL,
                `date_due` date default NULL,
                `branchcode` varchar(10) default NULL,
                `issuingbranch` varchar(18) default NULL,
                `returndate` date default NULL,
                `lastreneweddate` date default NULL,
                `return` varchar(4) default NULL,
                `renewals` tinyint(4) default NULL,
                `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
                `issuedate` date default NULL,
                KEY `old_issuesborridx` (`borrowernumber`),
                KEY `old_issuesitemidx` (`itemnumber`),
                KEY `old_bordate` (`borrowernumber`,`timestamp`),
                CONSTRAINT `old_issues_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`)
                    ON DELETE SET NULL ON UPDATE SET NULL,
                CONSTRAINT `old_issues_ibfk_2` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`)
                    ON DELETE SET NULL ON UPDATE SET NULL
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8");
    $dbh->do("CREATE TABLE `old_reserves` (
                `borrowernumber` int(11) default NULL,
                `reservedate` date default NULL,
                `biblionumber` int(11) default NULL,
                `constrainttype` varchar(1) default NULL,
                `branchcode` varchar(10) default NULL,
                `notificationdate` date default NULL,
                `reminderdate` date default NULL,
                `cancellationdate` date default NULL,
                `reservenotes` mediumtext,
                `priority` smallint(6) default NULL,
                `found` varchar(1) default NULL,
                `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
                `itemnumber` int(11) default NULL,
                `waitingdate` date default NULL,
                KEY `old_reserves_borrowernumber` (`borrowernumber`),
                KEY `old_reserves_biblionumber` (`biblionumber`),
                KEY `old_reserves_itemnumber` (`itemnumber`),
                KEY `old_reserves_branchcode` (`branchcode`),
                CONSTRAINT `old_reserves_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`)
                    ON DELETE SET NULL ON UPDATE SET NULL,
                CONSTRAINT `old_reserves_ibfk_2` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`)
                    ON DELETE SET NULL ON UPDATE SET NULL,
                CONSTRAINT `old_reserves_ibfk_3` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`)
                    ON DELETE SET NULL ON UPDATE SET NULL
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8");

    # move closed transactions to old_* tables
    $dbh->do("INSERT INTO old_issues SELECT * FROM issues WHERE returndate IS NOT NULL");
    $dbh->do("DELETE FROM issues WHERE returndate IS NOT NULL");
    $dbh->do("INSERT INTO old_reserves SELECT * FROM reserves WHERE cancellationdate IS NOT NULL OR found = 'F'");
    $dbh->do("DELETE FROM reserves WHERE cancellationdate IS NOT NULL OR found = 'F'");

	print "Upgrade to $DBversion done ( Added old_issues and old_reserves tables )\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.063";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE deleteditems
                CHANGE COLUMN booksellerid booksellerid MEDIUMTEXT DEFAULT NULL,
                ADD COLUMN enumchron VARCHAR(80) DEFAULT NULL AFTER more_subfields_xml,
                ADD COLUMN copynumber SMALLINT(6) DEFAULT NULL AFTER enumchron;");
    $dbh->do("ALTER TABLE items
                CHANGE COLUMN booksellerid booksellerid MEDIUMTEXT,
                ADD COLUMN copynumber SMALLINT(6) DEFAULT NULL AFTER enumchron;");
	print "Upgrade to $DBversion done ( Changed items.booksellerid and deleteditems.booksellerid to MEDIUMTEXT and added missing items.copynumber and deleteditems.copynumber to fix Bug 1927)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.064";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('AmazonLocale','US','Use to set the Locale of your Amazon.com Web Services','US|CA|DE|FR|JP|UK','Choice');");
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('AWSAccessKeyID','','See:  http://aws.amazon.com','','free');");
    $dbh->do("DELETE FROM `systempreferences` WHERE variable='AmazonDevKey';");
    $dbh->do("DELETE FROM `systempreferences` WHERE variable='XISBNAmazonSimilarItems';");
    $dbh->do("DELETE FROM `systempreferences` WHERE variable='OPACXISBNAmazonSimilarItems';");
    print "Upgrade to $DBversion done (IMPORTANT: Upgrading to Amazon.com Associates Web Service 4.0 ) \n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.065";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("CREATE TABLE `patroncards` (
                `cardid` int(11) NOT NULL auto_increment,
                `batch_id` varchar(10) NOT NULL default '1',
                `borrowernumber` int(11) NOT NULL,
                `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
                PRIMARY KEY  (`cardid`),
                KEY `patroncards_ibfk_1` (`borrowernumber`),
                CONSTRAINT `patroncards_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
    print "Upgrade to $DBversion done (Adding patroncards table for patroncards generation feature. ) \n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.066";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE `virtualshelfcontents` MODIFY `dateadded` timestamp NOT NULL
DEFAULT CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP;
");
    print "Upgrade to $DBversion done (fix for bug 1873: virtualshelfcontents dateadded column empty. ) \n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.067";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("UPDATE systempreferences SET explanation = 'Enable patron images for the Staff Client', type = 'YesNo' WHERE variable = 'patronimages'");
    print "Upgrade to $DBversion done (Updating patronimages syspref to reflect current kohastructure.sql. ) \n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.068";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("CREATE TABLE `permissions` (
                `module_bit` int(11) NOT NULL DEFAULT 0,
                `code` varchar(30) DEFAULT NULL,
                `description` varchar(255) DEFAULT NULL,
                PRIMARY KEY  (`module_bit`, `code`),
                CONSTRAINT `permissions_ibfk_1` FOREIGN KEY (`module_bit`) REFERENCES `userflags` (`bit`)
                    ON DELETE CASCADE ON UPDATE CASCADE
              ) ENGINE=InnoDB DEFAULT CHARSET=utf8");
    $dbh->do("CREATE TABLE `user_permissions` (
                `borrowernumber` int(11) NOT NULL DEFAULT 0,
                `module_bit` int(11) NOT NULL DEFAULT 0,
                `code` varchar(30) DEFAULT NULL,
                CONSTRAINT `user_permissions_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`)
                    ON DELETE CASCADE ON UPDATE CASCADE,
                CONSTRAINT `user_permissions_ibfk_2` FOREIGN KEY (`module_bit`, `code`)
                    REFERENCES `permissions` (`module_bit`, `code`)
                    ON DELETE CASCADE ON UPDATE CASCADE
              ) ENGINE=InnoDB DEFAULT CHARSET=utf8");

    $dbh->do("INSERT INTO permissions (module_bit, code, description) VALUES
    (13, 'edit_news', 'Write news for the OPAC and staff interfaces'),
    (13, 'label_creator', 'Create printable labels and barcodes from catalog and patron data'),
    (13, 'edit_calendar', 'Define days when the library is closed'),
    (13, 'moderate_comments', 'Moderate patron comments'),
    (13, 'edit_notices', 'Define notices'),
    (13, 'edit_notice_status_triggers', 'Set notice/status triggers for overdue items'),
    (13, 'view_system_logs', 'Browse the system logs'),
    (13, 'inventory', 'Perform inventory (stocktaking) of your catalogue'),
    (13, 'stage_marc_import', 'Stage MARC records into the reservoir'),
    (13, 'manage_staged_marc', 'Managed staged MARC records, including completing and reversing imports'),
    (13, 'export_catalog', 'Export bibliographic and holdings data'),
    (13, 'import_patrons', 'Import patron data'),
    (13, 'delete_anonymize_patrons', 'Delete old borrowers and anonymize circulation history (deletes borrower reading history)'),
    (13, 'batch_upload_patron_images', 'Upload patron images in batch or one at a time'),
    (13, 'schedule_tasks', 'Schedule tasks to run')");

    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('GranularPermissions','0','Use detailed staff user permissions',NULL,'YesNo')");

    print "Upgrade to $DBversion done (adding permissions and user_permissions tables and GranularPermissions syspref) \n";
    SetVersion ($DBversion);
}
$DBversion = "3.00.00.069";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE labels_conf CHANGE COLUMN class classification int(1) DEFAULT NULL;");
	print "Upgrade to $DBversion done ( Correcting columname in labels_conf )\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.070";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $sth = $dbh->prepare("SELECT value FROM systempreferences WHERE variable='yuipath'");
    $sth->execute;
    my ($value) = $sth->fetchrow;
    $value =~ s/2.3.1/2.5.1/;
    $dbh->do("UPDATE systempreferences SET value='$value' WHERE variable='yuipath';");
	print "Update yuipath syspref to 2.5.1 if necessary\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.071";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do(" ALTER TABLE `subscription` ADD `serialsadditems` TINYINT( 1 ) NOT NULL DEFAULT '0';");
    # fill the new field with the previous systempreference value, then drop the syspref
    my $sth = $dbh->prepare("SELECT value FROM systempreferences WHERE variable='serialsadditems'");
    $sth->execute;
    my ($serialsadditems) = $sth->fetchrow();
    $dbh->do("UPDATE subscription SET serialsadditems=$serialsadditems");
    $dbh->do("DELETE FROM systempreferences WHERE variable='serialsadditems'");
    print "Upgrade to $DBversion done ( moving serialsadditems from syspref to subscription )\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.072";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE labels_conf ADD COLUMN formatstring mediumtext DEFAULT NULL AFTER printingtype");
	print "Upgrade to $DBversion done ( Adding format string to labels generator. )\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.073";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
	$dbh->do("DROP TABLE IF EXISTS `tags_all`;");
	$dbh->do(q#
	CREATE TABLE `tags_all` (
	  `tag_id`         int(11) NOT NULL auto_increment,
	  `borrowernumber` int(11) NOT NULL,
	  `biblionumber`   int(11) NOT NULL,
	  `term`      varchar(255) NOT NULL,
	  `language`       int(4) default NULL,
	  `date_created` datetime  NOT NULL,
	  PRIMARY KEY  (`tag_id`),
	  KEY `tags_borrowers_fk_1` (`borrowernumber`),
	  KEY `tags_biblionumber_fk_1` (`biblionumber`),
	  CONSTRAINT `tags_borrowers_fk_1` FOREIGN KEY (`borrowernumber`)
		REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
	  CONSTRAINT `tags_biblionumber_fk_1` FOREIGN KEY (`biblionumber`)
		REFERENCES `biblio`     (`biblionumber`)  ON DELETE CASCADE ON UPDATE CASCADE
	) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	#);
	$dbh->do("DROP TABLE IF EXISTS `tags_approval`;");
	$dbh->do(q#
	CREATE TABLE `tags_approval` (
	  `term`   varchar(255) NOT NULL,
	  `approved`     int(1) NOT NULL default '0',
	  `date_approved` datetime       default NULL,
	  `approved_by` int(11)          default NULL,
	  `weight_total` int(9) NOT NULL default '1',
	  PRIMARY KEY  (`term`),
	  KEY `tags_approval_borrowers_fk_1` (`approved_by`),
	  CONSTRAINT `tags_approval_borrowers_fk_1` FOREIGN KEY (`approved_by`)
		REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
	) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	#);
	$dbh->do("DROP TABLE IF EXISTS `tags_index`;");
	$dbh->do(q#
	CREATE TABLE `tags_index` (
	  `term`    varchar(255) NOT NULL,
	  `biblionumber` int(11) NOT NULL,
	  `weight`        int(9) NOT NULL default '1',
	  PRIMARY KEY  (`term`,`biblionumber`),
	  KEY `tags_index_biblionumber_fk_1` (`biblionumber`),
	  CONSTRAINT `tags_index_term_fk_1` FOREIGN KEY (`term`)
		REFERENCES `tags_approval` (`term`)  ON DELETE CASCADE ON UPDATE CASCADE,
	  CONSTRAINT `tags_index_biblionumber_fk_1` FOREIGN KEY (`biblionumber`)
		REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE
	) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	#);
	$dbh->do(q#
	INSERT INTO `systempreferences` VALUES
		('BakerTaylorBookstoreURL','','','URL template for \"My Libary Bookstore\" links, to which the \"key\" value is appended, and \"https://\" is prepended.  It should include your hostname and \"Parent Number\".  Make this variable empty to turn MLB links off.  Example: ocls.mylibrarybookstore.com/MLB/actions/searchHandler.do?nextPage=bookDetails&parentNum=10923&key=',''),
		('BakerTaylorEnabled','0','','Enable or disable all Baker & Taylor features.','YesNo'),
		('BakerTaylorPassword','','','Baker & Taylor Password for Content Cafe (external content)','Textarea'),
		('BakerTaylorUsername','','','Baker & Taylor Username for Content Cafe (external content)','Textarea'),
		('TagsEnabled','1','','Enables or disables all tagging features.  This is the main switch for tags.','YesNo'),
		('TagsExternalDictionary',NULL,'','Path on server to local ispell executable, used to set $Lingua::Ispell::path  This dictionary is used as a \"whitelist\" of pre-allowed tags.',''),
		('TagsInputOnDetail','1','','Allow users to input tags from the detail page.',         'YesNo'),
		('TagsInputOnList',  '0','','Allow users to input tags from the search results list.', 'YesNo'),
		('TagsModeration',  NULL,'','Require tags from patrons to be approved before becoming visible.','YesNo'),
		('TagsShowOnDetail','10','','Number of tags to display on detail page.  0 is off.',        'Integer'),
		('TagsShowOnList',   '6','','Number of tags to display on search results list.  0 is off.','Integer')
	#);
	print "Upgrade to $DBversion done (Baker/Taylor,Tags: sysprefs and tables (tags_all, tags_index, tags_approval)) \n";
	SetVersion ($DBversion);
}

$DBversion = "3.00.00.074";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do( q(update itemtypes set imageurl = concat( 'npl/', imageurl )
                  where imageurl not like 'http%'
                    and imageurl is not NULL
                    and imageurl != '') );
    print "Upgrade to $DBversion done (updating imagetype.imageurls to reflect new icon locations.)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.075";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do( q(alter table authorised_values add imageurl varchar(200) default NULL) );
    print "Upgrade to $DBversion done (adding imageurl field to authorised_values table)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.076";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE import_batches
              ADD COLUMN nomatch_action enum('create_new', 'ignore') NOT NULL default 'create_new' AFTER overlay_action");
    $dbh->do("ALTER TABLE import_batches
              ADD COLUMN item_action enum('always_add', 'add_only_for_matches', 'add_only_for_new', 'ignore')
                  NOT NULL default 'always_add' AFTER nomatch_action");
    $dbh->do("ALTER TABLE import_batches
              MODIFY overlay_action  enum('replace', 'create_new', 'use_template', 'ignore')
                  NOT NULL default 'create_new'");
    $dbh->do("ALTER TABLE import_records
              MODIFY status  enum('error', 'staged', 'imported', 'reverted', 'items_reverted',
                                  'ignored') NOT NULL default 'staged'");
    $dbh->do("ALTER TABLE import_items
              MODIFY status enum('error', 'staged', 'imported', 'reverted', 'ignored') NOT NULL default 'staged'");

	print "Upgrade to $DBversion done (changes to import_batches and import_records)\n";
	SetVersion ($DBversion);
}

$DBversion = "3.00.00.077";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    # drop these tables only if they exist and none of them are empty
    # these tables are not defined in the packaged 2.2.9, but since it is believed
    # that at least one library may be using them in a post-2.2.9 but pre-3.0 Koha,
    # some care is taken.
    my ($print_error) = $dbh->{PrintError};
    $dbh->{PrintError} = 0;
    my ($raise_error) = $dbh->{RaiseError};
    $dbh->{RaiseError} = 1;

    my $count = 0;
    my $do_drop = 1;
    eval { $count = $dbh->do("SELECT 1 FROM categorytable"); };
    if ($count > 0) {
        $do_drop = 0;
    }
    eval { $count = $dbh->do("SELECT 1 FROM mediatypetable"); };
    if ($count > 0) {
        $do_drop = 0;
    }
    eval { $count = $dbh->do("SELECT 1 FROM subcategorytable"); };
    if ($count > 0) {
        $do_drop = 0;
    }

    if ($do_drop) {
        $dbh->do("DROP TABLE IF EXISTS `categorytable`");
        $dbh->do("DROP TABLE IF EXISTS `mediatypetable`");
        $dbh->do("DROP TABLE IF EXISTS `subcategorytable`");
    }

    $dbh->{PrintError} = $print_error;
    $dbh->{RaiseError} = $raise_error;
	print "Upgrade to $DBversion done (drop categorytable, subcategorytable, and mediatypetable)\n";
	SetVersion ($DBversion);
}

$DBversion = "3.00.00.078";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    my ($print_error) = $dbh->{PrintError};
    $dbh->{PrintError} = 0;

    unless ($dbh->do("SELECT 1 FROM browser")) {
        $dbh->{PrintError} = $print_error;
        $dbh->do("CREATE TABLE `browser` (
                    `level` int(11) NOT NULL,
                    `classification` varchar(20) NOT NULL,
                    `description` varchar(255) NOT NULL,
                    `number` bigint(20) NOT NULL,
                    `endnode` tinyint(4) NOT NULL
                  ) ENGINE=InnoDB DEFAULT CHARSET=utf8");
    }
    $dbh->{PrintError} = $print_error;
	print "Upgrade to $DBversion done (add browser table if not already present)\n";
	SetVersion ($DBversion);
}

$DBversion = "3.00.00.079";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
 my ($print_error) = $dbh->{PrintError};
    $dbh->{PrintError} = 0;

    $dbh->do("INSERT INTO `systempreferences` (variable, value,options,type, explanation)VALUES
        ('AddPatronLists','categorycode','categorycode|category_type','Choice','Allow user to choose what list to pick up from when adding patrons')");
    print "Upgrade to $DBversion done (add browser table if not already present)\n";
	SetVersion ($DBversion);
}

$DBversion = "3.00.00.080";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE subscription CHANGE monthlength monthlength int(11) default '0'");
    $dbh->do("ALTER TABLE deleteditems MODIFY marc LONGBLOB AFTER copynumber");
    $dbh->do("ALTER TABLE aqbooksellers CHANGE name name mediumtext NOT NULL");
	print "Upgrade to $DBversion done (catch up on DB schema changes since alpha and beta)\n";
	SetVersion ($DBversion);
}

$DBversion = "3.00.00.081";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("CREATE TABLE `borrower_attribute_types` (
                `code` varchar(10) NOT NULL,
                `description` varchar(255) NOT NULL,
                `repeatable` tinyint(1) NOT NULL default 0,
                `unique_id` tinyint(1) NOT NULL default 0,
                `opac_display` tinyint(1) NOT NULL default 0,
                `password_allowed` tinyint(1) NOT NULL default 0,
                `staff_searchable` tinyint(1) NOT NULL default 0,
                `authorised_value_category` varchar(10) default NULL,
                PRIMARY KEY  (`code`)
              ) ENGINE=InnoDB DEFAULT CHARSET=utf8");
    $dbh->do("CREATE TABLE `borrower_attributes` (
                `borrowernumber` int(11) NOT NULL,
                `code` varchar(10) NOT NULL,
                `attribute` varchar(30) default NULL,
                `password` varchar(30) default NULL,
                KEY `borrowernumber` (`borrowernumber`),
                KEY `code_attribute` (`code`, `attribute`),
                CONSTRAINT `borrower_attributes_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`)
                    ON DELETE CASCADE ON UPDATE CASCADE,
                CONSTRAINT `borrower_attributes_ibfk_2` FOREIGN KEY (`code`) REFERENCES `borrower_attribute_types` (`code`)
                    ON DELETE CASCADE ON UPDATE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8");
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('ExtendedPatronAttributes','0','Use extended patron IDs and attributes',NULL,'YesNo')");
    print "Upgrade to $DBversion done (added borrower_attributes and  borrower_attribute_types)\n";
 SetVersion ($DBversion);
}

$DBversion = "3.00.00.082";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do( q(alter table accountlines add column lastincrement decimal(28,6) default NULL) );
    print "Upgrade to $DBversion done (adding lastincrement column to accountlines table)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.083";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do( qq(UPDATE systempreferences SET value='local' where variable='yuipath' and value like "%/intranet-tmpl/prog/%"));
    print "Upgrade to $DBversion done (Changing yuipath behaviour in managing a local value)\n";
    SetVersion ($DBversion);
}
$DBversion = "3.00.00.084";
    if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('RenewSerialAddsSuggestion','0','if ON, adds a new suggestion at serial subscription renewal',NULL,'YesNo')");
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('GoogleJackets','0','if ON, displays jacket covers from Google Books API',NULL,'YesNo')");
    print "Upgrade to $DBversion done (add new sysprefs)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.085";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    if (C4::Context->preference("marcflavour") eq 'MARC21') {
        $dbh->do("UPDATE marc_subfield_structure SET tab = 0 WHERE tab =  9 AND tagfield = '037'");
        $dbh->do("UPDATE marc_subfield_structure SET tab = 1 WHERE tab =  6 AND tagfield in ('100', '110', '111', '130')");
        $dbh->do("UPDATE marc_subfield_structure SET tab = 2 WHERE tab =  6 AND tagfield in ('240', '243')");
        $dbh->do("UPDATE marc_subfield_structure SET tab = 4 WHERE tab =  6 AND tagfield in ('400', '410', '411', '440')");
        $dbh->do("UPDATE marc_subfield_structure SET tab = 5 WHERE tab =  9 AND tagfield = '584'");
        $dbh->do("UPDATE marc_subfield_structure SET tab = 7 WHERE tab = -6 AND tagfield = '760'");
    }
    print "Upgrade to $DBversion done (move editing tab of various MARC21 subfields)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.086";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
	$dbh->do(
	"CREATE TABLE `tmp_holdsqueue` (
  	`biblionumber` int(11) default NULL,
  	`itemnumber` int(11) default NULL,
  	`barcode` varchar(20) default NULL,
  	`surname` mediumtext NOT NULL,
  	`firstname` text,
  	`phone` text,
  	`borrowernumber` int(11) NOT NULL,
  	`cardnumber` varchar(16) default NULL,
  	`reservedate` date default NULL,
  	`title` mediumtext,
  	`itemcallnumber` varchar(30) default NULL,
  	`holdingbranch` varchar(10) default NULL,
  	`pickbranch` varchar(10) default NULL,
  	`notes` text
	) ENGINE=InnoDB DEFAULT CHARSET=utf8");

	$dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('RandomizeHoldsQueueWeight','0','if ON, the holds queue in circulation will be randomized, either based on all location codes, or by the location codes specified in StaticHoldsQueueWeight',NULL,'YesNo')");
	$dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('StaticHoldsQueueWeight','0','Specify a list of library location codes separated by commas -- the list of codes will be traversed and weighted with first values given higher weight for holds fulfillment -- alternatively, if RandomizeHoldsQueueWeight is set, the list will be randomly selective',NULL,'TextArea')");

	print "Upgrade to $DBversion done (Table structure for table `tmp_holdsqueue`)\n";
	SetVersion ($DBversion);
}

$DBversion = "3.00.00.087";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` VALUES ('AutoEmailOpacUser','0','','Sends notification emails containing new account details to patrons - when account is created.','YesNo')" );
    $dbh->do("INSERT INTO `systempreferences` VALUES ('AutoEmailPrimaryAddress','OFF','email|emailpro|B_email|cardnumber|OFF','Defines the default email address where Account Details emails are sent.','Choice')");
    print "Upgrade to $DBversion done (added 2 new 'AutoEmailOpacUser' sysprefs)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.088";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
	$dbh->do("INSERT INTO `systempreferences` (variable,value,options,explanation,type) VALUES ('OPACShelfBrowser','1','','Enable/disable Shelf Browser on item details page','YesNo')");
	$dbh->do("INSERT INTO `systempreferences` (variable,value,options,explanation,type) VALUES ('OPACItemHolds','1','Allow OPAC users to place hold on specific items. If OFF, users can only request next available copy.','','YesNo')");
	$dbh->do("INSERT INTO `systempreferences` (variable,value,options,explanation,type) VALUES ('XSLTDetailsDisplay','0','','Enable XSL stylesheet control over details page display on OPAC WARNING: MARC21 Only','YesNo')");
	$dbh->do("INSERT INTO `systempreferences` (variable,value,options,explanation,type) VALUES ('XSLTResultsDisplay','0','','Enable XSL stylesheet control over results page display on OPAC WARNING: MARC21 Only','YesNo')");
	print "Upgrade to $DBversion done (added 2 new 'AutoEmailOpacUser' sysprefs)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.089";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
	$dbh->do("INSERT INTO `systempreferences` (variable,value,options,explanation,type) VALUES('AdvancedSearchTypes','itemtypes','itemtypes|ccode','Select which set of fields comprise the Type limit in the advanced search','Choice')");
	print "Upgrade to $DBversion done (added new AdvancedSearchTypes syspref)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.090";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("
        CREATE TABLE `branch_borrower_circ_rules` (
          `branchcode` VARCHAR(10) NOT NULL,
          `categorycode` VARCHAR(10) NOT NULL,
          `maxissueqty` int(4) default NULL,
          PRIMARY KEY (`categorycode`, `branchcode`),
          CONSTRAINT `branch_borrower_circ_rules_ibfk_1` FOREIGN KEY (`categorycode`) REFERENCES `categories` (`categorycode`)
            ON DELETE CASCADE ON UPDATE CASCADE,
          CONSTRAINT `branch_borrower_circ_rules_ibfk_2` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`)
            ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8
    ");
    $dbh->do("
        CREATE TABLE `default_borrower_circ_rules` (
          `categorycode` VARCHAR(10) NOT NULL,
          `maxissueqty` int(4) default NULL,
          PRIMARY KEY (`categorycode`),
          CONSTRAINT `borrower_borrower_circ_rules_ibfk_1` FOREIGN KEY (`categorycode`) REFERENCES `categories` (`categorycode`)
            ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8
    ");
    $dbh->do("
        CREATE TABLE `default_branch_circ_rules` (
          `branchcode` VARCHAR(10) NOT NULL,
          `maxissueqty` int(4) default NULL,
          PRIMARY KEY (`branchcode`),
          CONSTRAINT `default_branch_circ_rules_ibfk_1` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`)
            ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8
    ");
    $dbh->do("
        CREATE TABLE `default_circ_rules` (
            `singleton` enum('singleton') NOT NULL default 'singleton',
            `maxissueqty` int(4) default NULL,
            PRIMARY KEY (`singleton`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8
    ");
    print "Upgrade to $DBversion done (added several circ rules tables)\n";
    SetVersion ($DBversion);
}


$DBversion = "3.00.00.091";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do(<<'END_SQL');
ALTER TABLE borrowers
ADD `smsalertnumber` varchar(50) default NULL
END_SQL

    $dbh->do(<<'END_SQL');
CREATE TABLE `message_attributes` (
  `message_attribute_id` int(11) NOT NULL auto_increment,
  `message_name` varchar(20) NOT NULL default '',
  `takes_days` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`message_attribute_id`),
  UNIQUE KEY `message_name` (`message_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
END_SQL

    $dbh->do(<<'END_SQL');
CREATE TABLE `message_transport_types` (
  `message_transport_type` varchar(20) NOT NULL,
  PRIMARY KEY  (`message_transport_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
END_SQL

    $dbh->do(<<'END_SQL');
CREATE TABLE `message_transports` (
  `message_attribute_id` int(11) NOT NULL,
  `message_transport_type` varchar(20) NOT NULL,
  `is_digest` tinyint(1) NOT NULL default '0',
  `letter_module` varchar(20) NOT NULL default '',
  `letter_code` varchar(20) NOT NULL default '',
  PRIMARY KEY  (`message_attribute_id`,`message_transport_type`,`is_digest`),
  KEY `message_transport_type` (`message_transport_type`),
  KEY `letter_module` (`letter_module`,`letter_code`),
  CONSTRAINT `message_transports_ibfk_1` FOREIGN KEY (`message_attribute_id`) REFERENCES `message_attributes` (`message_attribute_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `message_transports_ibfk_2` FOREIGN KEY (`message_transport_type`) REFERENCES `message_transport_types` (`message_transport_type`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `message_transports_ibfk_3` FOREIGN KEY (`letter_module`, `letter_code`) REFERENCES `letter` (`module`, `code`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8
END_SQL

    $dbh->do(<<'END_SQL');
CREATE TABLE `borrower_message_preferences` (
  `borrower_message_preference_id` int(11) NOT NULL auto_increment,
  `borrowernumber` int(11) NOT NULL default '0',
  `message_attribute_id` int(11) default '0',
  `days_in_advance` int(11) default '0',
  `wants_digets` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`borrower_message_preference_id`),
  KEY `borrowernumber` (`borrowernumber`),
  KEY `message_attribute_id` (`message_attribute_id`),
  CONSTRAINT `borrower_message_preferences_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `borrower_message_preferences_ibfk_2` FOREIGN KEY (`message_attribute_id`) REFERENCES `message_attributes` (`message_attribute_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8
END_SQL

    $dbh->do(<<'END_SQL');
CREATE TABLE `borrower_message_transport_preferences` (
  `borrower_message_preference_id` int(11) NOT NULL default '0',
  `message_transport_type` varchar(20) NOT NULL default '0',
  PRIMARY KEY  (`borrower_message_preference_id`,`message_transport_type`),
  KEY `message_transport_type` (`message_transport_type`),
  CONSTRAINT `borrower_message_transport_preferences_ibfk_1` FOREIGN KEY (`borrower_message_preference_id`) REFERENCES `borrower_message_preferences` (`borrower_message_preference_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `borrower_message_transport_preferences_ibfk_2` FOREIGN KEY (`message_transport_type`) REFERENCES `message_transport_types` (`message_transport_type`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8
END_SQL

    $dbh->do(<<'END_SQL');
CREATE TABLE `message_queue` (
  `message_id` int(11) NOT NULL auto_increment,
  `borrowernumber` int(11) NOT NULL,
  `subject` text,
  `content` text,
  `message_transport_type` varchar(20) NOT NULL,
  `status` enum('sent','pending','failed','deleted') NOT NULL default 'pending',
  `time_queued` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  KEY `message_id` (`message_id`),
  KEY `borrowernumber` (`borrowernumber`),
  KEY `message_transport_type` (`message_transport_type`),
  CONSTRAINT `messageq_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `messageq_ibfk_2` FOREIGN KEY (`message_transport_type`) REFERENCES `message_transport_types` (`message_transport_type`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8
END_SQL

    $dbh->do(<<'END_SQL');
INSERT INTO `systempreferences`
  (variable,value,explanation,options,type)
VALUES
('EnhancedMessagingPreferences',0,'If ON, allows patrons to select to receive additional messages about items due or nearly due.','','YesNo')
END_SQL

    $dbh->do( <<'END_SQL');
INSERT INTO `letter`
(module, code, name, title, content)
VALUES
('circulation','DUE','Item Due Reminder','Item Due Reminder','Dear <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nThe following item is now due:\r\n\r\n<<biblio.title>> by <<biblio.author>>'),
('circulation','DUEDGST','Item Due Reminder (Digest)','Item Due Reminder','You have <<count>> items due'),
('circulation','PREDUE','Advance Notice of Item Due','Advance Notice of Item Due','Dear <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nThe following item will be due soon:\r\n\r\n<<biblio.title>> by <<biblio.author>>'),
('circulation','PREDUEDGST','Advance Notice of Item Due (Digest)','Advance Notice of Item Due','You have <<count>> items due soon'),
('circulation','EVENT','Upcoming Library Event','Upcoming Library Event','Dear <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nThis is a reminder of an upcoming library event in which you have expressed interest.');
END_SQL

    my @sql_scripts = (
        'installer/data/mysql/en/mandatory/message_transport_types.sql',
        'installer/data/mysql/en/optional/sample_notices_message_attributes.sql',
        'installer/data/mysql/en/optional/sample_notices_message_transports.sql',
    );

    my $installer = C4::Installer->new();
    foreach my $script ( @sql_scripts ) {
        my $full_path = $installer->get_file_path_from_name($script);
        my $error = $installer->load_sql($full_path);
        warn $error if $error;
    }

    print "Upgrade to $DBversion done (Table structure for table `message_queue`, `message_transport_types`, `message_attributes`, `message_transports`, `borrower_message_preferences`, and `borrower_message_transport_preferences`.  Alter `borrowers` table,\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.092";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,options,explanation,type) VALUES('AllowOnShelfHolds', '0', '', 'Allow hold requests to be placed on items that are not on loan', 'YesNo')");
    $dbh->do("INSERT INTO `systempreferences` (variable,value,options,explanation,type) VALUES('AllowHoldsOnDamagedItems', '1', '', 'Allow hold requests to be placed on damaged items', 'YesNo')");
	print "Upgrade to $DBversion done (added new AllowOnShelfHolds syspref)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.093";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE `items` MODIFY COLUMN `copynumber` VARCHAR(32) DEFAULT NULL");
    $dbh->do("ALTER TABLE `deleteditems` MODIFY COLUMN `copynumber` VARCHAR(32) DEFAULT NULL");
	print "Upgrade to $DBversion done (Change data type of items.copynumber to allow free text)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.094";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE `marc_subfield_structure` MODIFY `tagsubfield` VARCHAR(1) NOT NULL DEFAULT '' COLLATE utf8_bin");
	print "Upgrade to $DBversion done (Change Collation of marc_subfield_structure to allow mixed case in subfield labels.)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.095";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    if (C4::Context->preference("marcflavour") eq 'MARC21') {
        $dbh->do("UPDATE marc_subfield_structure SET authtypecode = 'MEETI_NAME' WHERE authtypecode = 'Meeting Name'");
        $dbh->do("UPDATE marc_subfield_structure SET authtypecode = 'CORPO_NAME' WHERE authtypecode = 'CORP0_NAME'");
    }
	print "Upgrade to $DBversion done (fix invalid authority types in MARC21 frameworks [bug 2254])\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.096";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $sth = $dbh->prepare("SHOW COLUMNS FROM borrower_message_preferences LIKE 'wants_digets'");
    $sth->execute();
    if (my $row = $sth->fetchrow_hashref) {
        $dbh->do("ALTER TABLE borrower_message_preferences CHANGE wants_digets wants_digest tinyint(1) NOT NULL default 0");
    }
	print "Upgrade to $DBversion done (fix name borrower_message_preferences.wants_digest)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.00.00.097';
if ( C4::Context->preference('Version') < TransformToNum($DBversion) ) {

    $dbh->do('ALTER TABLE message_queue ADD to_address   mediumtext default NULL');
    $dbh->do('ALTER TABLE message_queue ADD from_address mediumtext default NULL');
    $dbh->do('ALTER TABLE message_queue ADD content_type text');
    $dbh->do('ALTER TABLE message_queue CHANGE borrowernumber borrowernumber int(11) default NULL');

    print "Upgrade to $DBversion done (updating 4 fields in message_queue table)\n";
    SetVersion($DBversion);
}

$DBversion = '3.00.00.098';
if ( C4::Context->preference('Version') < TransformToNum($DBversion) ) {

    $dbh->do(q(DELETE FROM message_transport_types WHERE message_transport_type = 'rss'));
    $dbh->do(q(DELETE FROM message_transports WHERE message_transport_type = 'rss'));

    print "Upgrade to $DBversion done (removing unused RSS message_transport_type)\n";
    SetVersion($DBversion);
}

$DBversion = '3.00.00.099';
if ( C4::Context->preference('Version') < TransformToNum($DBversion) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type) VALUES('OpacSuppression', '0', '', 'Turn ON the OPAC Suppression feature, requires further setup, ask your system administrator for details', 'YesNo')");
    print "Upgrade to $DBversion done (Adding OpacSuppression syspref)\n";
    SetVersion($DBversion);
}

$DBversion = '3.00.00.100';
if ( C4::Context->preference('Version') < TransformToNum($DBversion) ) {
	$dbh->do('ALTER TABLE virtualshelves ADD COLUMN lastmodified timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP');
    print "Upgrade to $DBversion done (Adding lastmodified column to virtualshelves)\n";
    SetVersion($DBversion);
}

$DBversion = '3.00.00.101';
if ( C4::Context->preference('Version') < TransformToNum($DBversion) ) {
	$dbh->do('ALTER TABLE `overduerules` CHANGE `categorycode` `categorycode` VARCHAR(10) NOT NULL');
	$dbh->do('ALTER TABLE `deletedborrowers` CHANGE `categorycode` `categorycode` VARCHAR(10) NOT NULL');
    print "Upgrade to $DBversion done (Updating columnd definitions for patron category codes in notice/statsu triggers and deletedborrowers tables.)\n";
    SetVersion($DBversion);
}

$DBversion = '3.00.00.102';
if ( C4::Context->preference('Version') < TransformToNum($DBversion) ) {
	$dbh->do('ALTER TABLE serialitems MODIFY `serialid` int(11) NOT NULL AFTER itemnumber' );
	$dbh->do('ALTER TABLE serialitems DROP KEY serialididx' );
	$dbh->do('ALTER TABLE serialitems ADD CONSTRAINT UNIQUE KEY serialitemsidx (itemnumber)' );
	# before setting constraint, delete any unvalid data
	$dbh->do('DELETE from serialitems WHERE serialid not in (SELECT serial.serialid FROM serial)');
	$dbh->do('ALTER TABLE serialitems ADD CONSTRAINT serialitems_sfk_1 FOREIGN KEY (serialid) REFERENCES serial (serialid) ON DELETE CASCADE ON UPDATE CASCADE' );
    print "Upgrade to $DBversion done (Updating serialitems table to allow for multiple items per serial fixing kohabug 2380)\n";
    SetVersion($DBversion);
}

$DBversion = "3.00.00.103";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("DELETE FROM systempreferences WHERE variable='serialsadditems'");
    print "Upgrade to $DBversion done ( Verifying the removal of serialsadditems from syspref fixing kohabug 2219)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.00.00.104";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("DELETE FROM systempreferences WHERE variable='noOPACHolds'");
    print "Upgrade to $DBversion done (remove superseded 'noOPACHolds' system preference per bug 2413)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.00.00.105';
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {

    # it is possible that this syspref is already defined since the feature was added some time ago.
    unless ( $dbh->do(q(SELECT variable FROM systempreferences WHERE variable = 'SMSSendDriver')) ) {
        $dbh->do(<<'END_SQL');
INSERT INTO `systempreferences`
  (variable,value,explanation,options,type)
VALUES
('SMSSendDriver','','Sets which SMS::Send driver is used to send SMS messages.','','free')
END_SQL
    }
    print "Upgrade to $DBversion done (added SMSSendDriver system preference)\n";
    SetVersion($DBversion);
}

$DBversion = "3.00.00.106";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("DELETE FROM systempreferences WHERE variable='noOPACHolds'");

# db revision 105 didn't apply correctly, so we're rolling this into 106
	$dbh->do("INSERT INTO `systempreferences`
   (variable,value,explanation,options,type)
	VALUES
	('SMSSendDriver','','Sets which SMS::Send driver is used to send SMS messages.','','free')");

    print "Upgrade to $DBversion done (remove default '0000-00-00' in subscriptionhistory.enddate field)\n";
    $dbh->do("ALTER TABLE `subscriptionhistory` CHANGE `enddate` `enddate` DATE NULL DEFAULT NULL ");
    $dbh->do("UPDATE subscriptionhistory SET enddate=NULL WHERE enddate='0000-00-00'");
    SetVersion ($DBversion);
}

$DBversion = '3.00.00.107';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do(<<'END_SQL');
UPDATE systempreferences
  SET explanation = CONCAT( explanation, '. WARNING: this feature is very resource consuming on collections with large numbers of items.' )
  WHERE variable = 'OPACShelfBrowser'
    AND explanation NOT LIKE '%WARNING%'
END_SQL
    $dbh->do(<<'END_SQL');
UPDATE systempreferences
  SET explanation = CONCAT( explanation, '. WARNING: this feature is very resource consuming.' )
  WHERE variable = 'CataloguingLog'
    AND explanation NOT LIKE '%WARNING%'
END_SQL
    $dbh->do(<<'END_SQL');
UPDATE systempreferences
  SET explanation = CONCAT( explanation, '. WARNING: using NoZebra on even modest sized collections is very slow.' )
  WHERE variable = 'NoZebra'
    AND explanation NOT LIKE '%WARNING%'
END_SQL
    print "Upgrade to $DBversion done (warning added to OPACShelfBrowser system preference)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.000';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    print "Upgrade to $DBversion done (start of 3.1)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.001';
if ( C4::Context->preference('Version') < TransformToNum($DBversion) ) {
    $dbh->do("
        CREATE TABLE hold_fill_targets (
            `borrowernumber` int(11) NOT NULL,
            `biblionumber` int(11) NOT NULL,
            `itemnumber` int(11) NOT NULL,
            `source_branchcode`  varchar(10) default NULL,
            `item_level_request` tinyint(4) NOT NULL default 0,
            PRIMARY KEY `itemnumber` (`itemnumber`),
            KEY `bib_branch` (`biblionumber`, `source_branchcode`),
            CONSTRAINT `hold_fill_targets_ibfk_1` FOREIGN KEY (`borrowernumber`)
                REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
            CONSTRAINT `hold_fill_targets_ibfk_2` FOREIGN KEY (`biblionumber`)
                REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE,
            CONSTRAINT `hold_fill_targets_ibfk_3` FOREIGN KEY (`itemnumber`)
                REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
            CONSTRAINT `hold_fill_targets_ibfk_4` FOREIGN KEY (`source_branchcode`)
                REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8
    ");
    $dbh->do("
        ALTER TABLE tmp_holdsqueue
            ADD item_level_request tinyint(4) NOT NULL default 0
    ");

    print "Upgrade to $DBversion done (add hold_fill_targets table and a column to tmp_holdsqueue)\n";
    SetVersion($DBversion);
}

$DBversion = '3.01.00.002';
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
    print "Upgrade to $DBversion done (bug 2582: set null issues.issuedate to lastreneweddate)\n";
    SetVersion($DBversion);
}

$DBversion = "3.01.00.003";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('AllowRenewalLimitOverride', '0', 'if ON, allows renewal limits to be overridden on the circulation screen',NULL,'YesNo')");
    print "Upgrade to $DBversion done (add new syspref)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.004';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('OPACDisplayRequestPriority','0','Show patrons the priority level on holds in the OPAC','','YesNo')");
    print "Upgrade to $DBversion done (added OPACDisplayRequestPriority system preference)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.005';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("
        INSERT INTO `letter` (module, code, name, title, content)
        VALUES('reserves', 'HOLD', 'Hold Available for Pickup', 'Hold Available for Pickup at <<branches.branchname>>', 'Dear <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nYou have a hold available for pickup as of <<reserves.waitingdate>>:\r\n\r\nTitle: <<biblio.title>>\r\nAuthor: <<biblio.author>>\r\nCopy: <<items.copynumber>>\r\nLocation: <<branches.branchname>>\r\n<<branches.branchaddress1>>\r\n<<branches.branchaddress2>>\r\n<<branches.branchaddress3>>')
    ");
    $dbh->do("INSERT INTO `message_attributes` (message_attribute_id, message_name, takes_days) values(4, 'Hold Filled', 0)");
    $dbh->do("INSERT INTO `message_transports` (message_attribute_id, message_transport_type, is_digest, letter_module, letter_code) values(4, 'sms', 0, 'reserves', 'HOLD')");
    $dbh->do("INSERT INTO `message_transports` (message_attribute_id, message_transport_type, is_digest, letter_module, letter_code) values(4, 'email', 0, 'reserves', 'HOLD')");
    print "Upgrade to $DBversion done (Add letter for holds notifications)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.006';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE `biblioitems` ADD KEY issn (issn)");
    print "Upgrade to $DBversion done (add index on biblioitems.issn)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.007";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("UPDATE `systempreferences` SET options='70|10' WHERE variable='intranetmainUserblock'");
    $dbh->do("UPDATE `systempreferences` SET options='70|10' WHERE variable='intranetuserjs'");
    $dbh->do("UPDATE `systempreferences` SET options='70|10' WHERE variable='opacheader'");
    $dbh->do("UPDATE `systempreferences` SET options='70|10' WHERE variable='OpacMainUserBlock'");
    $dbh->do("UPDATE `systempreferences` SET options='70|10' WHERE variable='OpacNav'");
    $dbh->do("UPDATE `systempreferences` SET options='70|10' WHERE variable='opacuserjs'");
    $dbh->do("UPDATE `systempreferences` SET options='30|10', type='Textarea' WHERE variable='OAI-PMH:Set'");
    $dbh->do("UPDATE `systempreferences` SET options='50' WHERE variable='intranetstylesheet'");
    $dbh->do("UPDATE `systempreferences` SET options='50' WHERE variable='intranetcolorstylesheet'");
    $dbh->do("UPDATE `systempreferences` SET options='10' WHERE variable='globalDueDate'");
    $dbh->do("UPDATE `systempreferences` SET type='Integer' WHERE variable='numSearchResults'");
    $dbh->do("UPDATE `systempreferences` SET type='Integer' WHERE variable='OPACnumSearchResults'");
    $dbh->do("UPDATE `systempreferences` SET type='Integer' WHERE variable='ReservesMaxPickupDelay'");
    $dbh->do("UPDATE `systempreferences` SET type='Integer' WHERE variable='TransfersMaxDaysWarning'");
    $dbh->do("UPDATE `systempreferences` SET type='Integer' WHERE variable='StaticHoldsQueueWeight'");
    $dbh->do("UPDATE `systempreferences` SET type='Integer' WHERE variable='holdCancelLength'");
    $dbh->do("UPDATE `systempreferences` SET type='Integer' WHERE variable='XISBNDailyLimit'");
    $dbh->do("UPDATE `systempreferences` SET type='Float' WHERE variable='gist'");
    $dbh->do("UPDATE `systempreferences` SET type='Free' WHERE variable='BakerTaylorUsername'");
    $dbh->do("UPDATE `systempreferences` SET type='Free' WHERE variable='BakerTaylorPassword'");
    $dbh->do("UPDATE `systempreferences` SET type='Textarea', options='70|10' WHERE variable='ISBD'");
    $dbh->do("UPDATE `systempreferences` SET type='Textarea', options='70|10', explanation='Enter a specific hash for NoZebra indexes. Enter : \\\'indexname\\\' => \\\'100a,245a,500*\\\',\\\'index2\\\' => \\\'...\\\'' WHERE variable='NoZebraIndexes'");
    print "Upgrade to $DBversion done (fix display of many sysprefs)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.008';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {

    $dbh->do("CREATE TABLE branch_transfer_limits (
                          limitId int(8) NOT NULL auto_increment,
                          toBranch varchar(4) NOT NULL,
                          fromBranch varchar(4) NOT NULL,
                          itemtype varchar(4) NOT NULL,
                          PRIMARY KEY  (limitId)
                          ) ENGINE=InnoDB DEFAULT CHARSET=utf8"
                        );

    $dbh->do("INSERT INTO `systempreferences` ( `variable` , `value` , `options` , `explanation` , `type` ) VALUES ( 'UseBranchTransferLimits', '0', '', 'If ON, Koha will will use the rules defined in branch_transfer_limits to decide if an item transfer should be allowed.', 'YesNo')");

    print "Upgrade to $DBversion done (added branch_transfer_limits table and UseBranchTransferLimits system preference)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.009";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE permissions MODIFY `code` varchar(64) DEFAULT NULL");
    $dbh->do("ALTER TABLE user_permissions MODIFY `code` varchar(64) DEFAULT NULL");
    $dbh->do("INSERT INTO permissions (module_bit, code, description) VALUES ( 1, 'circulate_remaining_permissions', 'Remaining circulation permissions')");
    $dbh->do("INSERT INTO permissions (module_bit, code, description) VALUES ( 1, 'override_renewals', 'Override blocked renewals')");
    print "Upgrade to $DBversion done (added subpermissions for circulate permission)\n";
}

$DBversion = '3.01.00.010';
if ( C4::Context->preference('Version') < TransformToNum($DBversion) ) {
    $dbh->do("ALTER TABLE `borrower_attributes` MODIFY COLUMN `attribute` VARCHAR(64) DEFAULT NULL");
    $dbh->do("ALTER TABLE `borrower_attributes` MODIFY COLUMN `password` VARCHAR(64) DEFAULT NULL");
    print "Upgrade to $DBversion done (bug 2687: increase length of borrower attribute fields)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.011';
if ( C4::Context->preference('Version') < TransformToNum($DBversion) ) {

    # Yes, the old value was ^M terminated.
    my $bad_value = "function prepareEmailPopup(){\r\n  if (!document.getElementById) return false;\r\n  if (!document.getElementById('reserveemail')) return false;\r\n  rsvlink = document.getElementById('reserveemail');\r\n  rsvlink.onclick = function() {\r\n      doReservePopup();\r\n      return false;\r\n	}\r\n}\r\n\r\nfunction doReservePopup(){\r\n}\r\n\r\nfunction prepareReserveList(){\r\n}\r\n\r\naddLoadEvent(prepareEmailPopup);\r\naddLoadEvent(prepareReserveList);";

    my $intranetuserjs = C4::Context->preference('intranetuserjs');
    if ($intranetuserjs  and  $intranetuserjs eq $bad_value) {
        my $sql = <<'END_SQL';
UPDATE systempreferences
SET value = ''
WHERE variable = 'intranetuserjs'
END_SQL
        $dbh->do($sql);
    }
    print "Upgrade to $DBversion done (removed bogus intranetuserjs syspref)\n";
    SetVersion($DBversion);
}

$DBversion = "3.01.00.012";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('AllowHoldPolicyOverride', '0', 'Allow staff to override hold policies when placing holds',NULL,'YesNo')");
    $dbh->do("
        CREATE TABLE `branch_item_rules` (
          `branchcode` varchar(10) NOT NULL,
          `itemtype` varchar(10) NOT NULL,
          `holdallowed` tinyint(1) default NULL,
          PRIMARY KEY  (`itemtype`,`branchcode`),
          KEY `branch_item_rules_ibfk_2` (`branchcode`),
          CONSTRAINT `branch_item_rules_ibfk_1` FOREIGN KEY (`itemtype`) REFERENCES `itemtypes` (`itemtype`) ON DELETE CASCADE ON UPDATE CASCADE,
          CONSTRAINT `branch_item_rules_ibfk_2` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8
    ");
    $dbh->do("
        CREATE TABLE `default_branch_item_rules` (
          `itemtype` varchar(10) NOT NULL,
          `holdallowed` tinyint(1) default NULL,
          PRIMARY KEY  (`itemtype`),
          CONSTRAINT `default_branch_item_rules_ibfk_1` FOREIGN KEY (`itemtype`) REFERENCES `itemtypes` (`itemtype`) ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8
    ");
    $dbh->do("
        ALTER TABLE default_branch_circ_rules
            ADD COLUMN holdallowed tinyint(1) NULL
    ");
    $dbh->do("
        ALTER TABLE default_circ_rules
            ADD COLUMN holdallowed tinyint(1) NULL
    ");
    print "Upgrade to $DBversion done (Add tables and system preferences for holds policies)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.013';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("
        CREATE TABLE item_circulation_alert_preferences (
            id           int(11) AUTO_INCREMENT,
            branchcode   varchar(10) NOT NULL,
            categorycode varchar(10) NOT NULL,
            item_type    varchar(10) NOT NULL,
            notification varchar(16) NOT NULL,
            PRIMARY KEY (id),
            KEY (branchcode, categorycode, item_type, notification)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    ");

    $dbh->do(q{ ALTER TABLE `message_queue` ADD metadata text DEFAULT NULL           AFTER content;  });
    $dbh->do(q{ ALTER TABLE `message_queue` ADD letter_code varchar(64) DEFAULT NULL AFTER metadata; });

    $dbh->do(q{
        INSERT INTO `letter` (`module`, `code`, `name`, `title`, `content`) VALUES
        ('circulation','CHECKIN','Item Check-in','Check-ins','The following items have been checked in:\r\n----\r\n<<biblio.title>>\r\n----\r\nThank you.');
    });
    $dbh->do(q{
        INSERT INTO `letter` (`module`, `code`, `name`, `title`, `content`) VALUES
        ('circulation','CHECKOUT','Item Checkout','Checkouts','The following items have been checked out:\r\n----\r\n<<biblio.title>>\r\n----\r\nThank you for visiting <<branches.branchname>>.');
    });

    $dbh->do(q{INSERT INTO message_attributes (message_attribute_id, message_name, takes_days) VALUES (5, 'Item Check-in', 0);});
    $dbh->do(q{INSERT INTO message_attributes (message_attribute_id, message_name, takes_days) VALUES (6, 'Item Checkout', 0);});

    $dbh->do(q{INSERT INTO message_transports (message_attribute_id, message_transport_type, is_digest, letter_module, letter_code) VALUES (5, 'email', 0, 'circulation', 'CHECKIN');});
    $dbh->do(q{INSERT INTO message_transports (message_attribute_id, message_transport_type, is_digest, letter_module, letter_code) VALUES (5, 'sms',   0, 'circulation', 'CHECKIN');});
    $dbh->do(q{INSERT INTO message_transports (message_attribute_id, message_transport_type, is_digest, letter_module, letter_code) VALUES (6, 'email', 0, 'circulation', 'CHECKOUT');});
    $dbh->do(q{INSERT INTO message_transports (message_attribute_id, message_transport_type, is_digest, letter_module, letter_code) VALUES (6, 'sms',   0, 'circulation', 'CHECKOUT');});

    print "Upgrade to $DBversion done (data for Email Checkout Slips project)\n";
	 SetVersion ($DBversion);
}

$DBversion = "3.01.00.014";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE `branch_transfer_limits` CHANGE `itemtype` `itemtype` VARCHAR( 4 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL");
    $dbh->do("ALTER TABLE `branch_transfer_limits` ADD `ccode` VARCHAR( 10 ) NULL ;");
    $dbh->do("INSERT INTO `systempreferences` ( `variable` , `value` , `options` , `explanation` , `type` )
    VALUES (
    'BranchTransferLimitsType', 'ccode', 'itemtype|ccode', 'When using branch transfer limits, choose whether to limit by itemtype or collection code.', 'Choice'
    );");

    print "Upgrade to $DBversion done ( Updated table for Branch Transfer Limits)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.015';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('SyndeticsClientCode', '0', 'Client Code for using Syndetics Solutions content','','free')");

    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('SyndeticsEnabled', '0', 'Turn on Syndetics Enhanced Content','','YesNo')");

    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('SyndeticsCoverImages', '0', 'Display Cover Images from Syndetics','','YesNo')");

    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('SyndeticsTOC', '0', 'Display Table of Content information from Syndetics','','YesNo')");

    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('SyndeticsSummary', '0', 'Display Summary Information from Syndetics','','YesNo')");

    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('SyndeticsEditions', '0', 'Display Editions from Syndetics','','YesNo')");

    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('SyndeticsExcerpt', '0', 'Display Excerpts and first chapters on OPAC from Syndetics','','YesNo')");

    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('SyndeticsReviews', '0', 'Display Reviews on OPAC from Syndetics','','YesNo')");

    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('SyndeticsAuthorNotes', '0', 'Display Notes about the Author on OPAC from Syndetics','','YesNo')");

    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('SyndeticsAwards', '0', 'Display Awards on OPAC from Syndetics','','YesNo')");

    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('SyndeticsSeries', '0', 'Display Series information on OPAC from Syndetics','','YesNo')");

    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('SyndeticsCoverImageSize', 'MC', 'Choose the size of the Syndetics Cover Image to display on the OPAC detail page, MC is Medium, LC is Large','MC|LC','Choice')");

    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('OPACAmazonCoverImages', '0', 'Display cover images on OPAC from Amazon Web Services','','YesNo')");

    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('AmazonCoverImages', '0', 'Display Cover Images in Staff Client from Amazon Web Services','','YesNo')");

    $dbh->do("UPDATE systempreferences SET variable='AmazonEnabled' WHERE variable = 'AmazonContent'");

    $dbh->do("UPDATE systempreferences SET variable='OPACAmazonEnabled' WHERE variable = 'OPACAmazonContent'");

    print "Upgrade to $DBversion done (added Syndetics Enhanced Content system preferences)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.016";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('Babeltheque',0,'Turn ON Babeltheque content  - See babeltheque.com to subscribe to this service','','YesNo')");
    print "Upgrade to $DBversion done (Added Babeltheque syspref)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.017";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE `subscription` ADD `staffdisplaycount` VARCHAR(10) NULL;");
    $dbh->do("ALTER TABLE `subscription` ADD `opacdisplaycount` VARCHAR(10) NULL;");
    $dbh->do("INSERT INTO `systempreferences` ( `variable` , `value` , `options` , `explanation` , `type` )
    VALUES (
    'StaffSerialIssueDisplayCount', '3', '', 'Number of serial issues to display per subscription in the Staff client', 'Integer'
    );");
	$dbh->do("INSERT INTO `systempreferences` ( `variable` , `value` , `options` , `explanation` , `type` )
    VALUES (
    'OPACSerialIssueDisplayCount', '3', '', 'Number of serial issues to display per subscription in the OPAC', 'Integer'
    );");

    print "Upgrade to $DBversion done ( Updated table for Serials Display)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.018";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE deletedborrowers ADD `smsalertnumber` varchar(50) default NULL");
    print "Upgrade to $DBversion done (added deletedborrowers.smsalertnumber, missed in 3.00.00.091)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.019";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
        $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('OPACShowCheckoutName','0','Displays in the OPAC the name of patron who has checked out the material. WARNING: Most sites should leave this off. It is intended for corporate or special sites which need to track who has the item.','','YesNo')");
    print "Upgrade to $DBversion done (adding OPACShowCheckoutName systempref)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.020";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type)VALUES('LibraryThingForLibrariesID','','See:http://librarything.com/forlibraries/','','free')");
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type)VALUES('LibraryThingForLibrariesEnabled','0','Enable or Disable Library Thing for Libraries Features','','YesNo')");
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type)VALUES('LibraryThingForLibrariesTabbedView','0','Put LibraryThingForLibraries Content in Tabs.','','YesNo')");
    print "Upgrade to $DBversion done (adding LibraryThing for Libraries sysprefs)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.021";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    my $enable_reviews = C4::Context->preference('OPACAmazonEnabled') ? '1' : '0';
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('OPACAmazonReviews', '$enable_reviews', 'Display Amazon readers reviews on OPAC','','YesNo')");
    print "Upgrade to $DBversion done (adding OPACAmazonReviews syspref)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.022';
if ( C4::Context->preference('Version') < TransformToNum($DBversion) ) {
    $dbh->do("ALTER TABLE `labels_conf` MODIFY COLUMN `formatstring` mediumtext DEFAULT NULL");
    print "Upgrade to $DBversion done (bug 2945: increase size of labels_conf.formatstring)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.023';
if ( C4::Context->preference('Version') < TransformToNum($DBversion) ) {
    $dbh->do("ALTER TABLE biblioitems        MODIFY COLUMN isbn VARCHAR(30) DEFAULT NULL");
    $dbh->do("ALTER TABLE deletedbiblioitems MODIFY COLUMN isbn VARCHAR(30) DEFAULT NULL");
    $dbh->do("ALTER TABLE import_biblios     MODIFY COLUMN isbn VARCHAR(30) DEFAULT NULL");
    $dbh->do("ALTER TABLE suggestions        MODIFY COLUMN isbn VARCHAR(30) DEFAULT NULL");
    print "Upgrade to $DBversion done (bug 2765: increase width of isbn column in several tables)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.024";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE labels MODIFY COLUMN batch_id int(10) NOT NULL default 1;");
    print "Upgrade to $DBversion done (change labels.batch_id from varchar to int)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.025';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` ( `variable` , `value` , `options` , `explanation` , `type` ) VALUES ( 'ceilingDueDate', '', '', 'If set, date due will not be past this date.  Enter date according to the dateformat System Preference', 'free')");

    print "Upgrade to $DBversion done (added ceilingDueDate system preference)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.026';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` ( `variable` , `value` , `options` , `explanation` , `type` ) VALUES ( 'numReturnedItemsToShow', '20', '', 'Number of returned items to show on the check-in page', 'Integer')");

    print "Upgrade to $DBversion done (added numReturnedItemsToShow system preference)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.027';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE zebraqueue CHANGE `biblio_auth_number` `biblio_auth_number` bigint(20) unsigned NOT NULL default 0");
    print "Upgrade to $DBversion done (Increased size of zebraqueue biblio_auth_number to address bug 3148.)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.028';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    my $enable_reviews = C4::Context->preference('AmazonEnabled') ? '1' : '0';
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('AmazonReviews', '$enable_reviews', 'Display Amazon reviews on staff interface','','YesNo')");
    print "Upgrade to $DBversion done (added AmazonReviews)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.029';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do(q( UPDATE language_rfc4646_to_iso639
                SET iso639_2_code = 'spa'
                WHERE rfc4646_subtag = 'es'
                AND   iso639_2_code = 'rus' )
            );
    print "Upgrade to $DBversion done (fixed bug 2599: using Spanish search limit retrieves Russian results)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.030";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` ( `variable` , `value` , `options` , `explanation` , `type` ) VALUES ( 'AllowNotForLoanOverride', '0', '', 'If ON, Koha will allow the librarian to loan a not for loan item.', 'YesNo')");
    print "Upgrade to $DBversion done (added AllowNotForLoanOverride system preference)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.031";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE branch_transfer_limits
              MODIFY toBranch   varchar(10) NOT NULL,
              MODIFY fromBranch varchar(10) NOT NULL,
              MODIFY itemtype   varchar(10) NULL");
    print "Upgrade to $DBversion done (fix column widths in branch_transfer_limits)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.032";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do(<<ENDOFRENEWAL);
INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('RenewalPeriodBase', 'now', 'Set whether the renewal date should be counted from the date_due or from the moment the Patron asks for renewal ','date_due|now','Choice');
ENDOFRENEWAL
    print "Upgrade to $DBversion done (Change the field)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.033";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do(q/
        ALTER TABLE borrower_message_preferences
        MODIFY borrowernumber int(11) default NULL,
        ADD    categorycode varchar(10) default NULL AFTER borrowernumber,
        ADD KEY `categorycode` (`categorycode`),
        ADD CONSTRAINT `borrower_message_preferences_ibfk_3`
                       FOREIGN KEY (`categorycode`) REFERENCES `categories` (`categorycode`)
                       ON DELETE CASCADE ON UPDATE CASCADE
    /);
    print "Upgrade to $DBversion done (DB changes to allow patron category defaults for messaging preferences)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.034";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE `subscription` ADD COLUMN `graceperiod` INT(11) NOT NULL default '0';");
    print "Upgrade to $DBversion done (Adding graceperiod column to subscription table)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.035';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do(q{ ALTER TABLE `subscription` ADD location varchar(80) NULL DEFAULT '' AFTER callnumber; });
   print "Upgrade to $DBversion done (Adding location to subscription table)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.036';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("UPDATE systempreferences SET explanation = 'Choose the default detail view in the staff interface; choose between normal, labeled_marc, marc or isbd'
              WHERE variable = 'IntranetBiblioDefaultView'
              AND   explanation = 'IntranetBiblioDefaultView'");
    $dbh->do("UPDATE systempreferences SET type = 'Choice', options = 'normal|marc|isbd|labeled_marc'
              WHERE variable = 'IntranetBiblioDefaultView'");
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type)VALUES('viewISBD','1','Allow display of ISBD view of bibiographic records','','YesNo')");
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type)VALUES('viewLabeledMARC','0','Allow display of labeled MARC view of bibiographic records','','YesNo')");
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type)VALUES('viewMARC','1','Allow display of MARC view of bibiographic records','','YesNo')");
    print "Upgrade to $DBversion done (new viewISBD, viewLabeledMARC, viewMARC sysprefs and tweak IntranetBiblioDefaultView)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.037';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do('ALTER TABLE authorised_values ADD KEY `lib` (`lib`)');
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type)VALUES('FilterBeforeOverdueReport','0','Do not run overdue report until filter selected','','YesNo')");
    SetVersion ($DBversion);
    print "Upgrade to $DBversion done (added FilterBeforeOverdueReport syspref and new index on authorised_values)\n";
}

$DBversion = "3.01.00.038";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    # update branches table
    #
    $dbh->do("ALTER TABLE branches ADD `branchzip` varchar(25) default NULL AFTER `branchaddress3`");
    $dbh->do("ALTER TABLE branches ADD `branchcity` mediumtext AFTER `branchzip`");
    $dbh->do("ALTER TABLE branches ADD `branchcountry` text AFTER `branchcity`");
    $dbh->do("ALTER TABLE branches ADD `branchurl` mediumtext AFTER `branchemail`");
    $dbh->do("ALTER TABLE branches ADD `branchnotes` mediumtext AFTER `branchprinter`");
    print "Upgrade to $DBversion done (add ZIP, city, country, URL, and notes column to branches)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.039';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type)VALUES('SpineLabelFormat', '<itemcallnumber><copynumber>', '30|10', 'This preference defines the format for the quick spine label printer. Just list the fields you would like to see in the order you would like to see them, surrounded by <>, for example <itemcallnumber>.', 'Textarea')");
    $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type)VALUES('SpineLabelAutoPrint', '0', '', 'If this setting is turned on, a print dialog will automatically pop up for the quick spine label printer.', 'YesNo')");
    SetVersion ($DBversion);
    print "Upgrade to $DBversion done (added SpineLabelFormat and SpineLabelAutoPrint sysprefs)\n";
}

$DBversion = '3.01.00.040';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type)VALUES('AllowHoldDateInFuture','0','If set a date field is displayed on the Hold screen of the Staff Interface, allowing the hold date to be set in the future.','','YesNo')");
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type)VALUES('OPACAllowHoldDateInFuture','0','If set, along with the AllowHoldDateInFuture system preference, OPAC users can set the date of a hold to be in the future.','','YesNo')");
    SetVersion ($DBversion);
    print "Upgrade to $DBversion done (AllowHoldDateInFuture and OPACAllowHoldDateInFuture sysprefs)\n";
}

$DBversion = '3.01.00.041';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('AWSPrivateKey','','See:  http://aws.amazon.com.  Note that this is required after 2009/08/15 in order to retrieve any enhanced content other than book covers from Amazon.','','free')");
    SetVersion ($DBversion);
    print "Upgrade to $DBversion done (added AWSPrivateKey syspref - note that if you use enhanced content from Amazon, this should be set right away.)\n";
}

$DBversion = '3.01.00.042';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('OPACFineNoRenewals','99999','Fine Limit above which user canmot renew books via OPAC','','Integer')");
    SetVersion ($DBversion);
    print "Upgrade to $DBversion done (added OPACFineNoRenewals syspref)\n";
}

$DBversion = '3.01.00.043';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do('ALTER TABLE items ADD COLUMN permanent_location VARCHAR(80) DEFAULT NULL AFTER location');
    $dbh->do('UPDATE items SET permanent_location = location');
    $dbh->do("INSERT INTO `systempreferences` ( `variable` , `value` , `options` , `explanation` , `type` ) VALUES ( 'NewItemsDefaultLocation', '', '', 'If set, all new items will have a location of the given Location Code ( Authorized Value type LOC )', '')");
    $dbh->do("INSERT INTO `systempreferences` ( `variable` , `value` , `options` , `explanation` , `type` ) VALUES ( 'InProcessingToShelvingCart', '0', '', 'If set, when any item with a location code of PROC is ''checked in'', it''s location code will be changed to CART.', 'YesNo')");
    $dbh->do("INSERT INTO `systempreferences` ( `variable` , `value` , `options` , `explanation` , `type` ) VALUES ( 'ReturnToShelvingCart', '0', '', 'If set, when any item is ''checked in'', it''s location code will be changed to CART.', 'YesNo')");
    SetVersion ($DBversion);
    print "Upgrade to $DBversion done (amended Item added NewItemsDefaultLocation, InProcessingToShelvingCart, ReturnToShelvingCart sysprefs)\n";
}

$DBversion = '3.01.00.044';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type)VALUES( 'DisplayClearScreenButton', '0', 'If set to yes, a clear screen button will appear on the circulation page.', 'If set to yes, a clear screen button will appear on the circulation page.', 'YesNo')");
    SetVersion ($DBversion);
    print "Upgrade to $DBversion done (added DisplayClearScreenButton system preference)\n";
}

$DBversion = '3.01.00.045';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type)VALUES('HidePatronName', '0', '', 'If this is switched on, patron''s cardnumber will be shown instead of their name on the holds and catalog screens', 'YesNo')");
    SetVersion ($DBversion);
    print "Upgrade to $DBversion done (added a preference to hide the patrons name in the staff catalog)\n";
}

$DBversion = "3.01.00.046";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    # update borrowers table
    #
    $dbh->do("ALTER TABLE borrowers ADD `country` text AFTER zipcode");
    $dbh->do("ALTER TABLE borrowers ADD `B_country` text AFTER B_zipcode");
    $dbh->do("ALTER TABLE deletedborrowers ADD `country` text AFTER zipcode");
    $dbh->do("ALTER TABLE deletedborrowers ADD `B_country` text AFTER B_zipcode");
    print "Upgrade to $DBversion done (add country and B_country to borrowers)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.047';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE items MODIFY itemcallnumber varchar(255);");
    $dbh->do("ALTER TABLE deleteditems MODIFY itemcallnumber varchar(255);");
    $dbh->do("ALTER TABLE tmp_holdsqueue MODIFY itemcallnumber varchar(255);");
    SetVersion ($DBversion);
    print " Upgrade to $DBversion done (bug 2761: change max length of itemcallnumber to 255 from 30)\n";
}

$DBversion = '3.01.00.048';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("UPDATE userflags SET flagdesc='View Catalog (Librarian Interface)' WHERE bit=2;");
    $dbh->do("UPDATE userflags SET flagdesc='Edit Catalog (Modify bibliographic/holdings data)' WHERE bit=9;");
    $dbh->do("UPDATE userflags SET flagdesc='Allow to edit authorities' WHERE bit=14;");
    $dbh->do("UPDATE userflags SET flagdesc='Allow to access to the reports module' WHERE bit=16;");
    $dbh->do("UPDATE userflags SET flagdesc='Allow to manage serials subscriptions' WHERE bit=15;");
    SetVersion ($DBversion);
    print " Upgrade to $DBversion done (bug 2611: fix spelling/capitalization in permission flag descriptions)\n";
}

$DBversion = '3.01.00.049';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("UPDATE permissions SET description = 'Perform inventory (stocktaking) of your catalog' WHERE code = 'inventory';");
     SetVersion ($DBversion);
    print "Upgrade to $DBversion done (bug 2611: changed catalogue to catalog per the standard)\n";
}

$DBversion = '3.01.00.050';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES ('OPACSearchForTitleIn','<li class=\"yuimenuitem\">\n<a target=\"_blank\" class=\"yuimenuitemlabel\" href=\"http://worldcat.org/search?q=TITLE\">Other Libraries (WorldCat)</a></li>\n<li class=\"yuimenuitem\">\n<a class=\"yuimenuitemlabel\" href=\"http://www.scholar.google.com/scholar?q=TITLE\" target=\"_blank\">Other Databases (Google Scholar)</a></li>\n<li class=\"yuimenuitem\">\n<a class=\"yuimenuitemlabel\" href=\"http://www.bookfinder.com/search/?author=AUTHOR&amp;title=TITLE&amp;st=xl&amp;ac=qr\" target=\"_blank\">Online Stores (Bookfinder.com)</a></li>','Enter the HTML that will appear in the ''Search for this title in'' box on the detail page in the OPAC.  Enter TITLE, AUTHOR, or ISBN in place of their respective variables in the URL.  Leave blank to disable ''More Searches'' menu.','70|10','Textarea');");
    SetVersion ($DBversion);
    print "Upgrade to $DBversion done (bug 1934: Add OPACSearchForTitleIn syspref)\n";
}

$DBversion = '3.01.00.051';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("UPDATE systempreferences SET explanation='Fine limit above which user cannot renew books via OPAC' WHERE variable='OPACFineNoRenewals';");
    $dbh->do("UPDATE systempreferences SET explanation='If set to ON, a clear screen button will appear on the circulation page.' WHERE variable='DisplayClearScreenButton';");
    SetVersion ($DBversion);
    print "Upgrade to $DBversion done (fixed typos in new sysprefs)\n";
}

$DBversion = '3.01.00.052';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do('ALTER TABLE deleteditems ADD COLUMN permanent_location VARCHAR(80) DEFAULT NULL AFTER location');
    SetVersion ($DBversion);
    print "Upgrade to $DBversion done (bug 3481: add permanent_location column to deleteditems)\n";
}

$DBversion = '3.01.00.053';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    my $upgrade_script = C4::Context->config("intranetdir") . "/installer/data/mysql/labels_upgrade.pl";
    system("perl $upgrade_script");
    print "Upgrade to $DBversion done (Migrated labels tables and data to new schema.) NOTE: All existing label batches have been assigned to the first branch in the list of branches. This is ONLY true of migrated label batches.\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.054';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE borrowers ADD `B_address2` text AFTER B_address");
    $dbh->do("ALTER TABLE borrowers ADD `altcontactcountry` text AFTER altcontactzipcode");
    $dbh->do("ALTER TABLE deletedborrowers ADD `B_address2` text AFTER B_address");
    $dbh->do("ALTER TABLE deletedborrowers ADD `altcontactcountry` text AFTER altcontactzipcode");
    SetVersion ($DBversion);
    print "Upgrade to $DBversion done (bug 1600, bug 3454: add altcontactcountry and B_address2 to borrowers and deletedborrowers)\n";
}

$DBversion = '3.01.00.055';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do(qq|UPDATE systempreferences set explanation='Enter the HTML that will appear in the ''Search for this title in'' box on the detail page in the OPAC.  Enter {TITLE}, {AUTHOR}, or {ISBN} in place of their respective variables in the URL. Leave blank to disable ''More Searches'' menu.', value='<li><a  href="http://worldcat.org/search?q={TITLE}" target="_blank">Other Libraries (WorldCat)</a></li>\n<li><a href="http://www.scholar.google.com/scholar?q={TITLE}" target="_blank">Other Databases (Google Scholar)</a></li>\n<li><a href="http://www.bookfinder.com/search/?author={AUTHOR}&amp;title={TITLE}&amp;st=xl&amp;ac=qr" target="_blank">Online Stores (Bookfinder.com)</a></li>' WHERE variable='OPACSearchForTitleIn'|);
    SetVersion ($DBversion);
    print "Upgrade to $DBversion done (changed OPACSearchForTitleIn per requests in bug 1934)\n";
}

$DBversion = '3.01.00.056';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES ('OPACPatronDetails','1','If OFF the patron details tab in the OPAC is disabled.','','YesNo');");
    SetVersion ($DBversion);
    print "Upgrade to $DBversion done (Bug 1172 : Add OPACPatronDetails syspref)\n";
}

$DBversion = '3.01.00.057';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES ('OPACFinesTab','1','If OFF the patron fines tab in the OPAC is disabled.','','YesNo');");
    SetVersion ($DBversion);
    print "Upgrade to $DBversion done (Bug 2576 : Add OPACFinesTab syspref)\n";
}

$DBversion = '3.01.00.058';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE `language_subtag_registry` ADD `id` INT( 11 ) NOT NULL AUTO_INCREMENT PRIMARY KEY;");
    $dbh->do("ALTER TABLE `language_rfc4646_to_iso639` ADD `id` INT( 11 ) NOT NULL AUTO_INCREMENT PRIMARY KEY;");
    $dbh->do("ALTER TABLE `language_descriptions` ADD `id` INT( 11 ) NOT NULL AUTO_INCREMENT PRIMARY KEY;");
    SetVersion ($DBversion);
    print "Upgrade to $DBversion done (Added primary keys to language tables)\n";
}

$DBversion = '3.01.00.059';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type)VALUES('DisplayOPACiconsXSLT', '1', '', 'If ON, displays the format, audience, type icons in XSLT MARC21 results and display pages.', 'YesNo')");
    SetVersion ($DBversion);
    print "Upgrade to $DBversion done (added DisplayOPACiconsXSLT sysprefs)\n";
}

$DBversion = '3.01.00.060';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('AllowAllMessageDeletion','0','Allow any Library to delete any message','','YesNo');");
    $dbh->do('DROP TABLE IF EXISTS messages');
    $dbh->do("CREATE TABLE messages ( `message_id` int(11) NOT NULL auto_increment,
        `borrowernumber` int(11) NOT NULL,
        `branchcode` varchar(4) default NULL,
        `message_type` varchar(1) NOT NULL,
        `message` text NOT NULL,
        `message_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (`message_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8");

	print "Upgrade to $DBversion done ( Added AllowAllMessageDeletion syspref and messages table )\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.061';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type)VALUES('ShowPatronImageInWebBasedSelfCheck', '0', 'If ON, displays patron image when a patron uses web-based self-checkout', '', 'YesNo')");
	print "Upgrade to $DBversion done ( Added ShowPatronImageInWebBasedSelfCheck system preference )\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.062";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO permissions (module_bit, code, description) VALUES ( 13, 'manage_csv_profiles', 'Manage CSV export profiles')");
    $dbh->do(q/
	CREATE TABLE `export_format` (
	  `export_format_id` int(11) NOT NULL auto_increment,
	  `profile` varchar(255) NOT NULL,
	  `description` mediumtext NOT NULL,
	  `marcfields` mediumtext NOT NULL,
	  PRIMARY KEY  (`export_format_id`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Used for CSV export';
    /);
    print "Upgrade to $DBversion done (added csv export profiles)\n";
}

$DBversion = "3.01.00.063";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("
        CREATE TABLE `fieldmapping` (
          `id` int(11) NOT NULL auto_increment,
          `field` varchar(255) NOT NULL,
          `frameworkcode` char(4) NOT NULL default '',
          `fieldcode` char(3) NOT NULL,
          `subfieldcode` char(1) NOT NULL,
          PRIMARY KEY  (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
             ");
    SetVersion ($DBversion);print "Upgrade to $DBversion done (Created table fieldmapping)\n";print "Upgrade to 3.01.00.064 done (Version number skipped: nothing done)\n";
}

$DBversion = '3.01.00.065';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do('ALTER TABLE issuingrules ADD COLUMN `renewalsallowed` smallint(6) NOT NULL default "0" AFTER `issuelength`;');
    $sth = $dbh->prepare("SELECT itemtype, renewalsallowed FROM itemtypes");
    $sth->execute();

    my $sthupd = $dbh->prepare("UPDATE issuingrules SET renewalsallowed = ? WHERE itemtype = ?");

    while(my $row = $sth->fetchrow_hashref){
        $sthupd->execute($row->{renewalsallowed}, $row->{itemtype});
    }

    $dbh->do('ALTER TABLE itemtypes DROP COLUMN `renewalsallowed`;');

    SetVersion ($DBversion);
    print "Upgrade to $DBversion done (Moving allowed renewals from itemtypes to issuingrule)\n";
}

$DBversion = '3.01.00.066';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do('ALTER TABLE issuingrules ADD COLUMN `reservesallowed` smallint(6) NOT NULL default "0" AFTER `renewalsallowed`;');

    my $maxreserves = C4::Context->preference('maxreserves');
    $sth = $dbh->prepare('UPDATE issuingrules SET reservesallowed = ?;');
    $sth->execute($maxreserves);

    $dbh->do('DELETE FROM systempreferences WHERE variable = "maxreserves";');

    $dbh->do("INSERT INTO systempreferences (variable,value, options, explanation, type) VALUES('ReservesControlBranch','PatronLibrary','ItemHomeLibrary|PatronLibrary','Branch checked for members reservations rights','Choice')");

    SetVersion ($DBversion);
    print "Upgrade to $DBversion done (Moving max allowed reserves from system preference to issuingrule)\n";
}

$DBversion = "3.01.00.067";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO permissions (module_bit, code, description) VALUES ( 13, 'batchmod', 'Perform batch modification of items')");
    $dbh->do("INSERT INTO permissions (module_bit, code, description) VALUES ( 13, 'batchdel', 'Perform batch deletion of items')");
    print "Upgrade to $DBversion done (added permissions for batch modification and deletion)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.068";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
	$dbh->do("ALTER TABLE issuingrules ADD COLUMN `finedays` int(11) default NULL AFTER `fine` ");
	print "Upgrade to $DBversion done (Adding finedays in issuingrules table)\n";
    SetVersion ($DBversion);
}


$DBversion = "3.01.00.069";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
	$dbh->do("INSERT INTO `systempreferences` (`variable`, `value`, `options`, `explanation`, `type`) VALUES ('EnableOpacSearchHistory', '1', '', 'Enable or disable opac search history', 'YesNo')");

	my $create = <<SEARCHHIST;
CREATE TABLE IF NOT EXISTS `search_history` (
  `userid` int(11) NOT NULL,
  `sessionid` varchar(32) NOT NULL,
  `query_desc` varchar(255) NOT NULL,
  `query_cgi` varchar(255) NOT NULL,
  `total` int(11) NOT NULL,
  `time` timestamp NOT NULL default CURRENT_TIMESTAMP,
  KEY `userid` (`userid`),
  KEY `sessionid` (`sessionid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Opac search history results';
SEARCHHIST
	$dbh->do($create);

	print "Upgrade to $DBversion done (added OPAC search history preference and table)\n";
}

$DBversion = "3.01.00.070";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
	$dbh->do("ALTER TABLE authorised_values ADD COLUMN `lib_opac` VARCHAR(80) default NULL AFTER `lib`");
	print "Upgrade to $DBversion done (Added a lib_opac field in authorised_values table)\n";
}

$DBversion = "3.01.00.071";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
	$dbh->do("ALTER TABLE `subscription` ADD `enddate` date default NULL");
	$dbh->do("ALTER TABLE subscriptionhistory CHANGE enddate histenddate DATE default NULL");
	print "Upgrade to $DBversion done ( Adding enddate to subscription)\n";
}

# Acquisitions update

$DBversion = "3.01.00.072";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('OpacPrivacy', '0', 'if ON, allows patrons to define their privacy rules (reading history)',NULL,'YesNo')");
    # create a new syspref for the 'Mr anonymous' patron
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('AnonymousPatron', '0', \"Set the identifier (borrowernumber) of the 'Mister anonymous' patron. Used for Suggestion and reading history privacy\",NULL,'')");
    # fill AnonymousPatron with AnonymousSuggestion value (copy)
    my $sth=$dbh->prepare("SELECT value FROM systempreferences WHERE variable='AnonSuggestions'");
    $sth->execute;
    my ($value) = $sth->fetchrow() || 0;
    $dbh->do("UPDATE systempreferences SET value='$value' WHERE variable='AnonymousPatron'");
    # set AnonymousSuggestion do YesNo
    # 1st, set the value (1/True if it had a borrowernumber)
    $dbh->do("UPDATE systempreferences SET value=1 WHERE variable='AnonSuggestions' AND value>0");
    # 2nd, change the type to Choice
    $dbh->do("UPDATE systempreferences SET type='YesNo' WHERE variable='AnonSuggestions'");
        # borrower reading record privacy : 0 : forever, 1 : laws, 2 : don't keep at all
    $dbh->do("ALTER TABLE `borrowers` ADD `privacy` INTEGER NOT NULL DEFAULT 1;");
    print "Upgrade to $DBversion done (add new syspref and column in borrowers)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.073';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do('SET FOREIGN_KEY_CHECKS=0 ');
    $dbh->do(<<'END_SQL');
CREATE TABLE IF NOT EXISTS `aqcontract` (
  `contractnumber` int(11) NOT NULL auto_increment,
  `contractstartdate` date default NULL,
  `contractenddate` date default NULL,
  `contractname` varchar(50) default NULL,
  `contractdescription` mediumtext,
  `booksellerid` int(11) not NULL,
    PRIMARY KEY  (`contractnumber`),
        CONSTRAINT `booksellerid_fk1` FOREIGN KEY (`booksellerid`)
        REFERENCES `aqbooksellers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;
END_SQL
    $dbh->do('SET FOREIGN_KEY_CHECKS=1 ');
    print "Upgrade to $DBversion done (adding aqcontract table)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.074';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE `aqbasket` ADD COLUMN `basketname` varchar(50) default NULL AFTER `basketno`");
    $dbh->do("ALTER TABLE `aqbasket` ADD COLUMN `note` mediumtext AFTER `basketname`");
    $dbh->do("ALTER TABLE `aqbasket` ADD COLUMN `booksellernote` mediumtext AFTER `note`");
    $dbh->do("ALTER TABLE `aqbasket` ADD COLUMN `contractnumber` int(11) AFTER `booksellernote`");
    $dbh->do("ALTER TABLE `aqbasket` ADD FOREIGN KEY (`contractnumber`) REFERENCES `aqcontract` (`contractnumber`)");
    print "Upgrade to $DBversion done (edit aqbasket table done)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.075';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE `aqorders` ADD COLUMN `uncertainprice` tinyint(1)");

    print "Upgrade to $DBversion done (adding uncertainprices)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.076';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do('SET FOREIGN_KEY_CHECKS=0 ');
    $dbh->do("CREATE TABLE IF NOT EXISTS `aqbasketgroups` (
                         `id` int(11) NOT NULL auto_increment,
                         `name` varchar(50) default NULL,
                         `closed` tinyint(1) default NULL,
                         `booksellerid` int(11) NOT NULL,
                         PRIMARY KEY (`id`),
                         KEY `booksellerid` (`booksellerid`),
                         CONSTRAINT `aqbasketgroups_ibfk_1` FOREIGN KEY (`booksellerid`) REFERENCES `aqbooksellers` (`id`) ON UPDATE CASCADE ON DELETE CASCADE
                         ) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
    $dbh->do("ALTER TABLE aqbasket ADD COLUMN `basketgroupid` int(11)");
    $dbh->do("ALTER TABLE aqbasket ADD FOREIGN KEY (`basketgroupid`) REFERENCES `aqbasketgroups` (`id`) ON UPDATE CASCADE ON DELETE SET NULL");
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES ('pdfformat','pdfformat::layout2pages','Controls what script is used for printing (basketgroups)','','free')");
    $dbh->do('SET FOREIGN_KEY_CHECKS=1 ');
    print "Upgrade to $DBversion done (adding basketgroups)\n";
    SetVersion ($DBversion);
}
$DBversion = '3.01.00.077';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {

    $dbh->do("SET FOREIGN_KEY_CHECKS=0 ");
    # create a mapping table holding the info we need to match orders to budgets
    $dbh->do('DROP TABLE IF EXISTS fundmapping');
    $dbh->do(
        q|CREATE TABLE fundmapping AS
        SELECT aqorderbreakdown.ordernumber, branchcode, bookfundid, budgetdate, entrydate
        FROM aqorderbreakdown JOIN aqorders ON aqorderbreakdown.ordernumber = aqorders.ordernumber|);
    # match the new type of the corresponding field
    $dbh->do('ALTER TABLE fundmapping modify column bookfundid varchar(30)');
    # System did not ensure budgetdate was valid historically
    $dbh->do(q|UPDATE fundmapping SET budgetdate = entrydate WHERE budgetdate = '0000-00-00' OR budgetdate IS NULL|);
    # We save the map in fundmapping in case you need later processing
    $dbh->do(q|ALTER TABLE fundmapping add column aqbudgetid integer|);
    # these can speed processing up
    $dbh->do(q|CREATE INDEX fundmaporder ON fundmapping (ordernumber)|);
    $dbh->do(q|CREATE INDEX fundmapid ON fundmapping (bookfundid)|);

    $dbh->do("DROP TABLE IF EXISTS `aqbudgetperiods` ");

    $dbh->do(qq|
                    CREATE TABLE `aqbudgetperiods` (
                    `budget_period_id` int(11) NOT NULL auto_increment,
                    `budget_period_startdate` date NOT NULL,
                    `budget_period_enddate` date NOT NULL,
                    `budget_period_active` tinyint(1) default '0',
                    `budget_period_description` mediumtext,
                    `budget_period_locked` tinyint(1) default NULL,
                    `sort1_authcat` varchar(10) default NULL,
                    `sort2_authcat` varchar(10) default NULL,
                    PRIMARY KEY  (`budget_period_id`)
                    ) ENGINE=InnoDB  DEFAULT CHARSET=utf8 |);

   $dbh->do(<<ADDPERIODS);
INSERT INTO aqbudgetperiods (budget_period_startdate,budget_period_enddate,budget_period_active,budget_period_description,budget_period_locked)
SELECT DISTINCT startdate, enddate, NOW() BETWEEN startdate and enddate, concat(startdate," ",enddate),NOT NOW() BETWEEN startdate AND enddate from aqbudget
ADDPERIODS
# SORRY , NO AQBUDGET/AQBOOKFUND -> AQBUDGETS IMPORT JUST YET,
# BUT A NEW CLEAN AQBUDGETS TABLE CREATE FOR NOW..
# DROP TABLE IF EXISTS `aqbudget`;
#CREATE TABLE `aqbudget` (
#  `bookfundid` varchar(10) NOT NULL default ',
#    `startdate` date NOT NULL default 0,
#	  `enddate` date default NULL,
#	    `budgetamount` decimal(13,2) default NULL,
#		  `aqbudgetid` tinyint(4) NOT NULL auto_increment,
#		    `branchcode` varchar(10) default NULL,
    DropAllForeignKeys('aqbudget');
  #$dbh->do("drop table aqbudget;");


    my $maxbudgetid = $dbh->selectcol_arrayref(<<IDsBUDGET);
SELECT MAX(aqbudgetid) from aqbudget
IDsBUDGET

$$maxbudgetid[0] = 0 if !$$maxbudgetid[0];

    $dbh->do(<<BUDGETAUTOINCREMENT);
ALTER TABLE aqbudget AUTO_INCREMENT=$$maxbudgetid[0]
BUDGETAUTOINCREMENT

    $dbh->do(<<BUDGETNAME);
ALTER TABLE aqbudget RENAME `aqbudgets`
BUDGETNAME

    $dbh->do(<<BUDGETS);
ALTER TABLE `aqbudgets`
   CHANGE  COLUMN aqbudgetid `budget_id` int(11) NOT NULL AUTO_INCREMENT,
   CHANGE  COLUMN branchcode `budget_branchcode` varchar(10) default NULL,
   CHANGE  COLUMN budgetamount `budget_amount` decimal(28,6) NOT NULL default '0.00',
   CHANGE  COLUMN bookfundid   `budget_code` varchar(30) default NULL,
   ADD     COLUMN `budget_parent_id` int(11) default NULL,
   ADD     COLUMN `budget_name` varchar(80) default NULL,
   ADD     COLUMN `budget_encumb` decimal(28,6) default '0.00',
   ADD     COLUMN `budget_expend` decimal(28,6) default '0.00',
   ADD     COLUMN `budget_notes` mediumtext,
   ADD     COLUMN `budget_description` mediumtext,
   ADD     COLUMN `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
   ADD     COLUMN `budget_amount_sublevel`  decimal(28,6) AFTER `budget_amount`,
   ADD     COLUMN `budget_period_id` int(11) default NULL,
   ADD     COLUMN `sort1_authcat` varchar(80) default NULL,
   ADD     COLUMN `sort2_authcat` varchar(80) default NULL,
   ADD     COLUMN `budget_owner_id` int(11) default NULL,
   ADD     COLUMN `budget_permission` int(1) default '0';
BUDGETS

    $dbh->do(<<BUDGETCONSTRAINTS);
ALTER TABLE `aqbudgets`
   ADD CONSTRAINT `aqbudgets_ifbk_1` FOREIGN KEY (`budget_period_id`) REFERENCES `aqbudgetperiods` (`budget_period_id`) ON DELETE CASCADE ON UPDATE CASCADE
BUDGETCONSTRAINTS
#    $dbh->do(<<BUDGETPKDROP);
#ALTER TABLE `aqbudgets`
#   DROP PRIMARY KEY
#BUDGETPKDROP
#    $dbh->do(<<BUDGETPKADD);
#ALTER TABLE `aqbudgets`
#   ADD PRIMARY KEY budget_id
#BUDGETPKADD


	my $query_period= $dbh->prepare(qq|SELECT budget_period_id from aqbudgetperiods where budget_period_startdate=? and budget_period_enddate=?|);
	my $query_bookfund= $dbh->prepare(qq|SELECT * from aqbookfund where bookfundid=?|);
	my $selectbudgets=$dbh->prepare(qq|SELECT * from aqbudgets|);
	my $updatebudgets=$dbh->prepare(qq|UPDATE aqbudgets SET budget_period_id= ? , budget_name=?, budget_branchcode=? where budget_id=?|);
	$selectbudgets->execute;
	while (my $databudget=$selectbudgets->fetchrow_hashref){
		$query_period->execute ($$databudget{startdate},$$databudget{enddate});
		my ($budgetperiodid)=$query_period->fetchrow;
		$query_bookfund->execute ($$databudget{budget_code});
		my $databf=$query_bookfund->fetchrow_hashref;
		my $branchcode=$$databudget{budget_branchcode}||$$databf{branchcode};
		$updatebudgets->execute($budgetperiodid,$$databf{bookfundname},$branchcode,$$databudget{budget_id});
	}
    $dbh->do(<<BUDGETDROPDATES);
ALTER TABLE `aqbudgets`
   DROP startdate,
   DROP enddate
BUDGETDROPDATES


    $dbh->do("DROP TABLE IF EXISTS `aqbudgets_planning` ");
    $dbh->do("CREATE TABLE  `aqbudgets_planning` (
                    `plan_id` int(11) NOT NULL auto_increment,
                    `budget_id` int(11) NOT NULL,
                    `budget_period_id` int(11) NOT NULL,
                    `estimated_amount` decimal(28,6) default NULL,
                    `authcat` varchar(30) NOT NULL,
                    `authvalue` varchar(30) NOT NULL,
					`display` tinyint(1) DEFAULT 1,
                        PRIMARY KEY  (`plan_id`),
                        CONSTRAINT `aqbudgets_planning_ifbk_1` FOREIGN KEY (`budget_id`) REFERENCES `aqbudgets` (`budget_id`) ON DELETE CASCADE ON UPDATE CASCADE
                        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;");

    $dbh->do("ALTER TABLE `aqorders`
                    ADD COLUMN `budget_id` tinyint(4) NOT NULL,
                    ADD COLUMN `budgetgroup_id` int(11) NOT NULL,
                    ADD COLUMN  `sort1_authcat` varchar(10) default NULL,
                    ADD COLUMN  `sort2_authcat` varchar(10) default NULL" );
                # We need to map the orders to the budgets
                # For Historic reasons this is more complex than it should be on occasions
                my $budg_arr = $dbh->selectall_arrayref(
                    q|SELECT aqbudgets.budget_id, aqbudgets.budget_code, aqbudgetperiods.budget_period_startdate,
                    aqbudgetperiods.budget_period_enddate
                    FROM aqbudgets JOIN aqbudgetperiods ON aqbudgets.budget_period_id = aqbudgetperiods.budget_period_id
                    ORDER BY budget_code, budget_period_startdate|, { Slice => {} });
                # We arbitarily order on start date, this means if you have overlapping periods the order will be
                # linked to the latest matching budget YMMV
                my $b_sth = $dbh->prepare(
                    'UPDATE fundmapping set aqbudgetid = ? where bookfundid =? AND budgetdate >= ? AND budgetdate <= ?');
                for my $b ( @{$budg_arr}) {
                    $b_sth->execute($b->{budget_id}, $b->{budget_code}, $b->{budget_period_startdate}, $b->{budget_period_enddate});
                }
                # move the budgetids to aqorders
                $dbh->do(q|UPDATE aqorders, fundmapping SET aqorders.budget_id = fundmapping.aqbudgetid
                    WHERE aqorders.ordernumber = fundmapping.ordernumber AND fundmapping.aqbudgetid IS NOT NULL|);
                # NB fundmapping is left as an accontants trail also if you have budgetids that werent set
                # you can decide what to do with them

     $dbh->do(
         q|UPDATE aqorders, aqbudgets SET aqorders.budgetgroup_id = aqbudgets.budget_period_id
         WHERE aqorders.budget_id = aqbudgets.budget_id|);
                # cannot do until aqorderbreakdown removed
#    $dbh->do("DROP TABLE aqbookfund ");
#    $dbh->do("ALTER TABLE aqorders  ADD FOREIGN KEY (`budget_id`) REFERENCES `aqbudgets` (`budget_id`) ON UPDATE CASCADE  " ); ????
    $dbh->do("SET FOREIGN_KEY_CHECKS=1 ");

    print "Upgrade to $DBversion done (Adding new aqbudgetperiods, aqbudgets and aqbudget_planning tables  )\n";
    SetVersion ($DBversion);
}



$DBversion = '3.01.00.078';
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("ALTER TABLE aqbudgetperiods ADD COLUMN budget_period_total decimal(28,6)");
    print "Upgrade to $DBversion done (adds 'budget_period_total' column to aqbudgetperiods table)\n";
    SetVersion($DBversion);
}


$DBversion = '3.01.00.079';
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("ALTER TABLE currency ADD COLUMN active  tinyint(1)");

    print "Upgrade to $DBversion done (adds 'active' column to currencies table)\n";
    SetVersion($DBversion);
}

$DBversion = '3.01.00.080';
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do(<<BUDG_PERM );
INSERT INTO permissions (module_bit, code, description) VALUES
            (11, 'vendors_manage', 'Manage vendors'),
            (11, 'contracts_manage', 'Manage contracts'),
            (11, 'period_manage', 'Manage periods'),
            (11, 'budget_manage', 'Manage budgets'),
            (11, 'budget_modify', "Modify budget (can't create lines but can modify existing ones)"),
            (11, 'planning_manage', 'Manage budget plannings'),
            (11, 'order_manage', 'Manage orders & basket'),
            (11, 'group_manage', 'Manage orders & basketgroups'),
            (11, 'order_receive', 'Manage orders & basket'),
            (11, 'budget_add_del', "Add and delete budgets (but can't modify budgets)");
BUDG_PERM

    print "Upgrade to $DBversion done (adds permissions for the acquisitions module)\n";
    SetVersion($DBversion);
}


$DBversion = '3.01.00.081';
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("ALTER TABLE aqbooksellers ADD COLUMN `gstrate` decimal(6,4) default NULL");
    if (my $gist=C4::Context->preference("gist")){
		my $sql=$dbh->prepare("UPDATE aqbooksellers set `gstrate`=? ");
    	$sql->execute($gist) ;
	}
    print "Upgrade to $DBversion done (added per-supplier gstrate setting)\n";
    SetVersion($DBversion);
}

$DBversion = "3.01.00.082";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    if (C4::Context->preference("opaclanguages") eq "fr") {
        $dbh->do(qq#INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('AcqCreateItem','ordering',"Définit quand l'exemplaire est créé : à la commande, à la livraison, au catalogage",'ordering|receiving|cataloguing','Choice')#);
    } else {
        $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('AcqCreateItem','ordering','Define when the item is created : when ordering, when receiving, or in cataloguing module','ordering|receiving|cataloguing','Choice')");
    }
    print "Upgrade to $DBversion done (adding ReservesNeedReturns systempref, in circulation)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.083";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do(qq|
 CREATE TABLE `aqorders_items` (
  `ordernumber` int(11) NOT NULL,
  `itemnumber` int(11) NOT NULL,
  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`itemnumber`),
  KEY `ordernumber` (`ordernumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8   |
    );

    $dbh->do(qq| DROP TABLE aqorderbreakdown |);
    $dbh->do('DROP TABLE aqbookfund');
    print "Upgrade to $DBversion done (New aqorders_items table for acqui)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.084";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do(  qq# INSERT INTO `systempreferences` VALUES ('CurrencyFormat','US','US|FR','Determines the display format of currencies. eg: ''36000'' is displayed as ''360 000,00''  in ''FR'' or 360,000.00''  in ''US''.','Choice')  #);

    print "Upgrade to $DBversion done (CurrencyFormat syspref added)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.085";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER table aqorders drop column title");
    $dbh->do("ALTER TABLE `aqorders` CHANGE `budget_id` `budget_id` INT( 11 ) NOT NULL");
    print "Upgrade to $DBversion done update budget_id size that should not be a tinyint\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.086";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do(<<SUGGESTIONS);
ALTER table suggestions
    ADD budgetid INT(11),
    ADD branchcode VARCHAR(10) default NULL,
    ADD acceptedby INT(11) default NULL,
    ADD accepteddate date default NULL,
    ADD suggesteddate date default NULL,
    ADD manageddate date default NULL,
    ADD rejectedby INT(11) default NULL,
    ADD rejecteddate date default NULL,
    ADD collectiontitle text default NULL,
    ADD itemtype VARCHAR(30) default NULL
    ;
SUGGESTIONS
    print "Upgrade to $DBversion done (Suggestions)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.087";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER table aqbudgets drop column budget_amount_sublevel;");
    print "Upgrade to $DBversion done (Drop column budget_amount_sublevel from aqbudgets)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.088";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do(  qq# INSERT INTO `systempreferences` VALUES ('intranetbookbag','1','','If ON, enables display of Cart feature in the intranet','YesNo')  #);

    print "Upgrade to $DBversion done (intranetbookbag syspref added)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.090";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
$dbh->do("
       INSERT INTO `permissions` (`module_bit`, `code`, `description`) VALUES
		(16, 'execute_reports', 'Execute SQL reports'),
		(16, 'create_reports', 'Create SQL Reports')
	");

    print "Upgrade to $DBversion done (granular permissions for guided reports added)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.091";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
$dbh->do("
	UPDATE `systempreferences` SET `options` = 'holdings|serialcollection|subscriptions'
	WHERE `systempreferences`.`variable` = 'opacSerialDefaultTab' LIMIT 1
	");

    print "Upgrade to $DBversion done (opac-detail default tag updated)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.092";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    if (C4::Context->preference("opaclanguages") =~ /fr/) {
	$dbh->do(qq{
INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES ('RoutingListAddReserves','1','Si activé, des reservations sont automatiquement créées pour chaque lecteur de la liste de circulation d''un numéro de périodique','','YesNo');
	});
	}else{
	$dbh->do(qq{
INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES ('RoutingListAddReserves','1','If ON the patrons on routing lists are automatically added to holds on the issue.','','YesNo');
	});
	}
    print "Upgrade to $DBversion done (Added RoutingListAddReserves syspref)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.093";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
	$dbh->do(qq{
	ALTER TABLE biblioitems ADD INDEX issn_idx (issn);
	});
    print "Upgrade to $DBversion done (added index to ISSN)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.094";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
	$dbh->do(qq{
	ALTER TABLE aqbasketgroups ADD deliveryplace VARCHAR(10) default NULL, ADD deliverycomment VARCHAR(255) default NULL;
	});

    print "Upgrade to $DBversion done (adding deliveryplace deliverycomment to basketgroups)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.095";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
	$dbh->do(qq{
	ALTER TABLE items ADD stocknumber VARCHAR(32) DEFAULT NULL COMMENT "stores the inventory number";
	});
	$dbh->do(qq{
	ALTER TABLE items ADD UNIQUE INDEX itemsstocknumberidx (stocknumber);
	});
	$dbh->do(qq{
	ALTER TABLE deleteditems ADD stocknumber VARCHAR(32) DEFAULT NULL COMMENT "stores the inventory number of deleted items";
	});
	$dbh->do(qq{
	ALTER TABLE deleteditems ADD UNIQUE INDEX deleteditemsstocknumberidx (stocknumber);
	});
	if (C4::Context->preference('marcflavour') eq 'UNIMARC'){
		$dbh->do(qq{
	INSERT IGNORE INTO marc_subfield_structure (frameworkcode,tagfield, tagsubfield, tab, repeatable, mandatory,kohafield)
	SELECT DISTINCT (frameworkcode),995,"j",10,0,0,"items.stocknumber" from biblio_framework ;
		});
		#Previously, copynumber was used as stocknumber
		$dbh->do(qq{
	UPDATE items set stocknumber=copynumber;
		});
		$dbh->do(qq{
	UPDATE items set copynumber=NULL;
		});
	}
    print "Upgrade to $DBversion done (stocknumber field added)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.096";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('OrderPdfTemplate','','Uploads a PDF template to use for printing baskets','NULL','Upload')");
    $dbh->do("UPDATE systempreferences SET variable='OrderPdfFormat' WHERE variable='pdfformat'");
    print "Upgrade to $DBversion done (PDF orders system preferences added and updated)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.097";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
	$dbh->do(qq{
	ALTER TABLE aqbasketgroups ADD billingplace VARCHAR(10) NOT NULL AFTER deliverycomment;
	});

    print "Upgrade to $DBversion done (Adding billingplace to aqbasketgroups)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.098";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
	$dbh->do(qq{
	ALTER TABLE auth_subfield_structure MODIFY frameworkcode VARCHAR(10) NULL;
	});

    print "Upgrade to $DBversion done (changing frameworkcode length in auth_subfield_structure)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.099";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
	$dbh->do(qq{
		INSERT INTO `permissions` (`module_bit`, `code`, `description`) VALUES
                (9, 'edit_catalogue', 'Edit catalogue'),
		(9, 'fast_cataloging', 'Fast cataloging')
	});

    print "Upgrade to $DBversion done (granular permissions for cataloging added)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.100";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
	$dbh->do("INSERT INTO `systempreferences` (`variable`, `value`, `options`, `explanation`, `type`) VALUES ('casAuthentication', '0', '', 'Enable or disable CAS authentication', 'YesNo'), ('casLogout', '1', '', 'Does a logout from Koha should also log out of CAS ?', 'YesNo'), ('casServerUrl', 'https://localhost:8443/cas', '', 'URL of the cas server', 'Free')");
	print "Upgrade to $DBversion done (added CAS authentication system preferences)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.101";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
	$dbh->do(
        "INSERT INTO systempreferences
           (variable, value, options, explanation, type)
         VALUES (
            'OverdueNoticeBcc', '', '',
            'Email address to Bcc outgoing notices sent by email',
            'free')
         ");
	print "Upgrade to $DBversion done (added OverdueNoticeBcc system preferences)\n";
    SetVersion ($DBversion);
}
$DBversion = "3.01.00.102";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do(
    "UPDATE permissions set description = 'Edit catalog (Modify bibliographic/holdings data)' where module_bit = 9 and code = 'edit_catalogue'"
    );
	print "Upgrade to $DBversion done (fixed spelling error in edit_catalogue permission)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.103";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
	$dbh->do("INSERT INTO permissions (module_bit, code, description) VALUES (13, 'moderate_tags', 'Moderate patron tags')");
	print "Upgrade to $DBversion done (adding patron permissions for tags tool)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.104";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {

    my ($maninv_count, $borrnotes_count);
    eval { $maninv_count = $dbh->do("SELECT 1 FROM authorised_values WHERE category='MANUAL_INV'"); };
    if ($maninv_count == 0) {
        $dbh->do("INSERT INTO authorised_values (category,authorised_value,lib) VALUES ('MANUAL_INV','Copier Fees','.25')");
    }
    eval { $borrnotes_count = $dbh->do("SELECT 1 FROM authorised_values WHERE category='BOR_NOTES'"); };
    if ($borrnotes_count == 0) {
        $dbh->do("INSERT INTO authorised_values (category,authorised_value,lib) VALUES ('BOR_NOTES','ADDR','Address Notes')");
    }

    $dbh->do("INSERT INTO authorised_values (category,authorised_value,lib) VALUES ('LOC','CART','Book Cart')");
    $dbh->do("INSERT INTO authorised_values (category,authorised_value,lib) VALUES ('LOC','PROC','Processing Center')");

	print "Upgrade to $DBversion done ( add defaults to authorized values for MANUAL_INV and BOR_NOTES and add new default LOC authorized values for shelf to cart processing )\n";
	SetVersion ($DBversion);
}


$DBversion = "3.01.00.105";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("
      CREATE TABLE `collections` (
        `colId` int(11) NOT NULL auto_increment,
        `colTitle` varchar(100) NOT NULL default '',
        `colDesc` text NOT NULL,
        `colBranchcode` varchar(4) default NULL COMMENT 'branchcode for branch where item should be held.',
        PRIMARY KEY  (`colId`)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    ");

    $dbh->do("
      CREATE TABLE `collections_tracking` (
        `ctId` int(11) NOT NULL auto_increment,
        `colId` int(11) NOT NULL default '0' COMMENT 'collections.colId',
        `itemnumber` int(11) NOT NULL default '0' COMMENT 'items.itemnumber',
        PRIMARY KEY  (`ctId`)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    ");
    $dbh->do("
        INSERT INTO permissions (module_bit, code, description)
        VALUES ( 13, 'rotating_collections', 'Manage Rotating collections')" );
	print "Upgrade to $DBversion done (added collection and collection_tracking tables for rotating collections functionality)\n";
    SetVersion ($DBversion);
}
$DBversion = "3.01.00.106";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
	$dbh->do("INSERT INTO `systempreferences` (variable,value,options,explanation,type) VALUES ( 'OpacAddMastheadLibraryPulldown', '0', '', 'Adds a pulldown menu to select the library to search on the opac masthead.', 'YesNo' )");
	print "Upgrade to $DBversion done (added OpacAddMastheadLibraryPulldown system preferences)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.107';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    my $upgrade_script = C4::Context->config("intranetdir") . "/installer/data/mysql/patroncards_upgrade.pl";
    system("perl $upgrade_script");
    print "Upgrade to $DBversion done (Migrated labels and patroncards tables and data to new schema.)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.108';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
	$dbh->do(qq{
    ALTER TABLE `export_format` ADD `csv_separator` VARCHAR( 2 ) NOT NULL AFTER `marcfields` ,
    ADD `field_separator` VARCHAR( 2 ) NOT NULL AFTER `csv_separator` ,
    ADD `subfield_separator` VARCHAR( 2 ) NOT NULL AFTER `field_separator`
    });
	print "Upgrade to $DBversion done (added separators for csv export)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.109";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
	$dbh->do(qq{
	ALTER TABLE `export_format` ADD `encoding` VARCHAR(255) NOT NULL AFTER `subfield_separator`
	});
	print "Upgrade to $DBversion done (added encoding for csv export)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.110';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do('ALTER TABLE `categories` ADD COLUMN `enrolmentperioddate` DATE NULL DEFAULT NULL AFTER `enrolmentperiod`');
    print "Upgrade to $DBversion done (Add enrolment period date support)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.111';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    print "Upgrade to $DBversion done (mark DBrev for 3.2-alpha release)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.112';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
	$dbh->do("INSERT INTO `systempreferences` (variable,value,options,explanation,type) VALUES ('SpineLabelShowPrintOnBibDetails', '0', '', 'If turned on, a \"Print Label\" link will appear for each item on the bib details page in the staff interface.', 'YesNo');");
	print "Upgrade to $DBversion done ( added Show Spine Label Printer on Bib Items Details preferences )\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.113';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    my $value = C4::Context->preference("XSLTResultsDisplay");
    $dbh->do(
        "INSERT INTO systempreferences (variable,value,type)
         VALUES('OPACXSLTResultsDisplay',?,'YesNo')", {}, $value ? 1 : 0);
    $value = C4::Context->preference("XSLTDetailsDisplay");
    $dbh->do(
        "INSERT INTO systempreferences (variable,value,type)
         VALUES('OPACXSLTDetailsDisplay',?,'YesNo')", {}, $value ? 1 : 0);
    print "Upgrade to $DBversion done (added two new syspref: OPACXSLTResultsDisplay and OPACXSLTDetailDisplay). You may have to go in Admin > System preference to tweak XSLT related syspref both in OPAC and Search tabs.\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.114';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type)VALUES('AutoSelfCheckAllowed', '0', 'For corporate and special libraries which want web-based self-check available from any PC without the need for a manual staff login. Most libraries will want to leave this turned off. If on, requires self-check ID and password to be entered in AutoSelfCheckID and AutoSelfCheckPass sysprefs.', '', 'YesNo')");
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('AutoSelfCheckID','','Staff ID with circulation rights to be used for automatic web-based self-check. Only applies if AutoSelfCheckAllowed syspref is turned on.','','free')");
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('AutoSelfCheckPass','','Password to be used for automatic web-based self-check. Only applies if AutoSelfCheckAllowed syspref is turned on.','','free')");
	print "Upgrade to $DBversion done ( Added AutoSelfCheckAllowed, AutoSelfCheckID, and AutoShelfCheckPass system preference )\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.115';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do('UPDATE aqorders SET quantityreceived = 0 WHERE quantityreceived IS NULL');
    $dbh->do('ALTER TABLE aqorders MODIFY COLUMN quantityreceived smallint(6) NOT NULL DEFAULT 0');
	print "Upgrade to $DBversion done ( Default aqorders.quantityreceived to 0 )\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.116';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
	if (C4::Context->preference('OrderPdfFormat') eq 'pdfformat::example'){
		$dbh->do("UPDATE `systempreferences` set value='pdfformat::layout2pages' WHERE variable='OrderPdfFormat'");
	}
	print "Upgrade to $DBversion done (corrected default OrderPdfFormat value if still set wrong )\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.117';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("UPDATE language_rfc4646_to_iso639 SET iso639_2_code = 'por' WHERE rfc4646_subtag='pt' ");
    print "Upgrade to $DBversion done (corrected ISO 639-2 language code for Portuguese)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.118';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    my ($count) = $dbh->selectrow_array("SELECT count(*) FROM information_schema.columns
                                         WHERE table_name = 'aqbudgets_planning'
                                         AND column_name = 'display'");
    if ($count < 1) {
        $dbh->do("ALTER TABLE aqbudgets_planning ADD COLUMN display tinyint(1) DEFAULT 1");
    }
    print "Upgrade to $DBversion done (bug 4203: add display column to aqbudgets_planning if missing)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.119';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    eval{require Locale::Currency::Format};
    if (!$@) {
        print "Upgrade to $DBversion done (Locale::Currency::Format installed.)\n";
        SetVersion ($DBversion);
    }
    else {
        print "Upgrade to $DBversion done.\n";
        print "NOTICE: The Locale::Currency::Format package is not installed on your system or not found in \@INC.\nThis dependency is required in order to include fine information in overdue notices.\nPlease ask your system administrator to install this package.\n";
        SetVersion ($DBversion);
    }
}

$DBversion = '3.01.00.120';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do(q{
INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('soundon','0','Enable circulation sounds during checkin and checkout in the staff interface.  Not supported by all web browsers yet.','','YesNo');
});
    print "Upgrade to $DBversion done (bug 1080: add soundon system preference for circulation sounds)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.121';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE `reserves` ADD `expirationdate` DATE DEFAULT NULL");
    $dbh->do("ALTER TABLE `reserves` ADD `lowestPriority` tinyint(1) NOT NULL");
    $dbh->do("ALTER TABLE `old_reserves` ADD `expirationdate` DATE DEFAULT NULL");
    $dbh->do("ALTER TABLE `old_reserves` ADD `lowestPriority` tinyint(1) NOT NULL");
    print "Upgrade to $DBversion done ( Added Additional Fields to Reserves tables )\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.122';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do(q{
      INSERT INTO systempreferences (variable,value,explanation,options,type)
      VALUES ('OAI-PMH:ConfFile', '', 'If empty, Koha OAI Server operates in normal mode, otherwise it operates in extended mode.','','File');
});
    print "Upgrade to $DBversion done. — Add a new system preference OAI-PMF:ConfFile\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.123";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `permissions` (`module_bit`, `code`, `description`) VALUES
        (6, 'place_holds', 'Place holds for patrons')");
    $dbh->do("INSERT INTO `permissions` (`module_bit`, `code`, `description`) VALUES
        (6, 'modify_holds_priority', 'Modify holds priority')");
    $dbh->do("UPDATE `userflags` SET `flagdesc` = 'Place and modify holds for patrons' WHERE `flag` = 'reserveforothers'");
    print "Upgrade to $DBversion done (Add granular permission for holds modification and update description of reserveforothers permission)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.124';
if (C4::Context->preference('Version') < TransformToNum($DBversion)){
    $dbh->do("
        INSERT INTO `letter` (module, code, name, title, content)         VALUES('reserves', 'HOLDPLACED', 'Hold Placed on Item', 'Hold Placed on Item','A hold has been placed on the following item : <<title>> (<<biblionumber>>) by the user <<firstname>> <<surname>> (<<cardnumber>>).');
    ");
    print "Upgrade to $DBversion done (bug 3242: add HOLDPLACED letter template, which is used when emailLibrarianWhenHoldIsPlaced is enabled)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.125';
if (C4::Context->preference('Version') < TransformToNum($DBversion)){
    $dbh->do("
        INSERT INTO `systempreferences` ( `variable` , `value` , `options` , `explanation` , `type` ) VALUES ( 'PrintNoticesMaxLines', '0', '', 'If greater than 0, sets the maximum number of lines an overdue notice will print. If the number of items is greater than this number, the notice will end with a warning asking the borrower to check their online account for a full list of overdue items.', 'Integer' );
    ");
    $dbh->do("
        INSERT INTO message_transport_types (message_transport_type) values ('print');
    ");
    print "Upgrade to $DBversion done (bug 3482: Printable hold and overdue notices)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.126";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
	$dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('ILS-DI','0','Enable ILS-DI services. See http://your.opac.name/cgi-bin/koha/ilsdi.pl for online documentation.','','YesNo')");
	$dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('ILS-DI:AuthorizedIPs','127.0.0.1','A comma separated list of IP addresses authorized to access the web services.','','free')");

    print "Upgrade to $DBversion done (Adding ILS-DI updates and ILS-DI:AuthorizedIPs)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.127';
if (C4::Context->preference('Version') < TransformToNum($DBversion)){
    $dbh->do("ALTER TABLE messages CHANGE branchcode branchcode varchar(10);");
    print "Upgrade to $DBversion done (bug 4190: messages in patron account did not work with branchcodes > 4)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.128';
if (C4::Context->preference('Version') < TransformToNum($DBversion)){
    $dbh->do('CREATE INDEX budget_id ON aqorders (budget_id );');
    print "Upgrade to $DBversion done (bug 4331: index orders by budget_id)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.129";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
	$dbh->do("UPDATE `permissions` SET `code` = 'items_batchdel' WHERE `permissions`.`module_bit` =13 AND `permissions`.`code` = 'batchdel' LIMIT 1 ;");
	$dbh->do("UPDATE `permissions` SET `code` = 'items_batchmod' WHERE `permissions`.`module_bit` =13 AND `permissions`.`code` = 'batchmod' LIMIT 1 ;");
	print "Upgrade to $DBversion done (Change permissions names for item batch modification / deletion)\n";

    SetVersion ($DBversion);
}

$DBversion = "3.01.00.130";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("UPDATE reserves SET expirationdate = NULL WHERE expirationdate = '0000-00-00'");
    print "Upgrade to $DBversion done (change reserves.expirationdate values of 0000-00-00 to NULL (bug 1532)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.131";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
	$dbh->do(q{
INSERT IGNORE INTO message_transport_types (message_transport_type) VALUES ('print'),('feed');
    });
    print "Upgrade to $DBversion done (adding print and feed message transport types)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.132";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
	$dbh->do(q{
    ALTER TABLE language_descriptions ADD INDEX subtag_type_lang (subtag, type, lang);
    });
    print "Upgrade to $DBversion done (Adding index to language_descriptions table)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.133';
if (C4::Context->preference('Version') < TransformToNum($DBversion)){
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES ('OverduesBlockCirc','noblock','When checking out an item should overdues block checkout, generate a confirmation dialogue, or allow checkout','noblock|confirmation|block','Choice')");
    print "Upgrade to $DBversion done (bug 4405: added OverduesBlockCirc syspref to control whether circulation is blocked if a borrower has overdues)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.134';
if (C4::Context->preference('Version') < TransformToNum($DBversion)){
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('DisplayMultiPlaceHold','1','Display the ability to place multiple holds or not','','YesNo')");
    print "Upgrade to $DBversion done (adding syspref DisplayMultiPlaceHold to control whether multiple holds can be placed from the search results page)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.135';
if (C4::Context->preference('Version') < TransformToNum($DBversion)){
    $dbh->do("
        INSERT INTO `letter` (module, code, name, title, content) VALUES
('reserves', 'HOLD_PRINT', 'Hold Available for Pickup (print notice)', 'Hold Available for Pickup (print notice)', '<<branches.branchname>>\r\n<<branches.branchaddress1>>\r\n<<branches.branchaddress2>>\r\n\r\n\r\nChange Service Requested\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n<<borrowers.firstname>> <<borrowers.surname>>\r\n<<borrowers.address>>\r\n<<borrowers.city>> <<borrowers.zipcode>>\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n<<borrowers.firstname>> <<borrowers.surname>> <<borrowers.cardnumber>>\r\n\r\nYou have a hold available for pickup as of <<reserves.waitingdate>>:\r\n\r\nTitle: <<biblio.title>>\r\nAuthor: <<biblio.author>>\r\nCopy: <<items.copynumber>>\r\n')
");
    print "Upgrade to $DBversion done (bug 4377: added HOLD_PRINT message template)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.136';
if (C4::Context->preference('Version') < TransformToNum($DBversion)){
    $dbh->do(qq{
INSERT INTO permissions (module_bit, code, description) VALUES
   ( 9, 'edit_items', 'Edit Items');});
    print "Upgrade to $DBversion done (Adding a new permission to edit items)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.137";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
        $dbh->do("
          INSERT INTO permissions (module_bit, code, description) VALUES
          (15, 'check_expiration', 'Check the expiration of a serial'),
          (15, 'claim_serials', 'Claim missing serials'),
          (15, 'create_subscription', 'Create a new subscription'),
          (15, 'delete_subscription', 'Delete an existing subscription'),
          (15, 'edit_subscription', 'Edit an existing subscription'),
          (15, 'receive_serials', 'Serials receiving'),
          (15, 'renew_subscription', 'Renew a subscription'),
          (15, 'routing', 'Routing');
                 ");
    print "Upgrade to $DBversion done (adding granular permissions for serials)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.138";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("DELETE FROM systempreferences WHERE variable = 'GranularPermissions'");
    print "Upgrade to $DBversion done (bug 4896: removing GranularPermissions syspref; use of granular permissions is now the default)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.139';
if (C4::Context->preference('Version') < TransformToNum($DBversion)){
    $dbh->do("ALTER TABLE message_attributes CHANGE message_name message_name varchar(40);");
    print "Upgrade to $DBversion done (bug 3682: change message_name from varchar(20) to varchar(40))\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.140';
if (C4::Context->preference('Version') < TransformToNum($DBversion)){
    $dbh->do("UPDATE systempreferences SET value = '0' WHERE variable = 'TagsModeration' AND value is NULL");
    print "Upgrade to $DBversion done (bug 4312 TagsModeration changed from NULL to 0)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.141';
if (C4::Context->preference('Version') < TransformToNum($DBversion)){
    $dbh->do(qq{DELETE FROM message_attributes WHERE message_attribute_id=3;});
    $dbh->do(qq{DELETE FROM letter WHERE code='EVENT' AND title='Upcoming Library Event';});
    print "Upgrade to $DBversion done Remove upcoming events messaging option (bug 2434)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.142';
if (C4::Context->preference('Version') < TransformToNum($DBversion)){
    $dbh->do(qq{DELETE FROM message_transports WHERE message_attribute_id=3;});
    print "Upgrade to $DBversion done (Remove upcoming events messaging option part 2 (bug 2434))\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.143';
if (C4::Context->preference('Version') < TransformToNum($DBversion)){
    $dbh->do(qq{CREATE INDEX auth_value_idx ON authorised_values (authorised_value)});
    $dbh->do(qq{CREATE INDEX auth_val_cat_idx ON borrower_attribute_types (authorised_value_category)});
    print "Upgrade to $DBversion done (Create index on authorised_values and borrower_attribute_types (bug 4139))\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.144';
if (C4::Context->preference('Version') < TransformToNum($DBversion)){
    $dbh->do(qq{UPDATE systempreferences SET value='normal' where value='default' and variable='IntranetBiblioDefaultView'});
    print "Upgrade to $DBversion done (Update the 'default' to 'normal' for the IntranetBiblioDefaultView syspref (bug 5007))\n";
    SetVersion ($DBversion);
}

$DBversion = "3.01.00.145";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE borrowers ADD KEY `guarantorid` (guarantorid);");
    print "Upgrade to $DBversion done (Add index on guarantorid)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.01.00.999';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    print "Upgrade to $DBversion done (3.2.0 release candidate)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.02.00.000";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    my $value = $dbh->selectrow_array("SELECT value FROM systempreferences WHERE variable = 'HomeOrHoldingBranch'");
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('HomeOrHoldingBranchReturn','$value','Used by Circulation to determine which branch of an item to check checking-in items','holdingbranch|homebranch','Choice');");
    print "Upgrade to $DBversion done (Add HomeOrHoldingBranchReturn system preference)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.02.00.001";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do(q{DELETE FROM systempreferences WHERE variable IN (
                'holdCancelLength',
                'PINESISBN',
                'sortbynonfiling',
                'TemplateEncoding',
                'OPACSubscriptionDisplay',
                'OPACDisplayExtendedSubInfo',
                'OAI-PMH:Set',
                'OAI-PMH:Subset',
                'libraryAddress',
                'kohaspsuggest',
                'OrderPdfTemplate',
                'marc',
                'acquisitions',
                'MIME')
               }
    );
    print "Upgrade to $DBversion done (bug 3756: remove disused system preferences)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.02.00.002";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do(q{DELETE FROM systempreferences WHERE variable = 'OpacPrivacy'});
    print "Upgrade to $DBversion done (bug 3881: remove unused OpacPrivacy system preference)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.02.00.003";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do(q{UPDATE systempreferences SET variable = 'ILS-DI:AuthorizedIPs' WHERE variable = 'ILS-DI:Authorized_IPs'});
    print "Upgrade to $DBversion done (correct ILS-DI:AuthorizedIPs)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.02.00.004";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    print "Upgrade to $DBversion done (3.2.0 general release)\n";
    SetVersion ($DBversion);
}
# This is the point where 3.2.x and master diverged, we can use $original_version to make sure we don't

# apply updates that have already been done

$DBversion = "3.03.00.001";
if (C4::Context->preference("Version") < TransformToNum($DBversion) && $original_version < TransformToNum("3.02.00.005")) {
    $dbh->do("DELETE FROM subscriptionroutinglist WHERE borrowernumber IS NULL;");
    $dbh->do("ALTER TABLE subscriptionroutinglist MODIFY COLUMN `borrowernumber` int(11) NOT NULL;");
    $dbh->do("DELETE FROM subscriptionroutinglist WHERE subscriptionid IS NULL;");
    $dbh->do("ALTER TABLE subscriptionroutinglist MODIFY COLUMN `subscriptionid` int(11) NOT NULL;");
    $dbh->do("CREATE TEMPORARY TABLE del_subscriptionroutinglist
              SELECT s1.routingid FROM subscriptionroutinglist s1
              WHERE EXISTS (SELECT * FROM subscriptionroutinglist s2
                            WHERE s2.borrowernumber = s1.borrowernumber
                            AND   s2.subscriptionid = s1.subscriptionid
                            AND   s2.routingid < s1.routingid);");
    $dbh->do("DELETE FROM subscriptionroutinglist
              WHERE routingid IN (SELECT routingid FROM del_subscriptionroutinglist);");
    $dbh->do("ALTER TABLE subscriptionroutinglist ADD UNIQUE (subscriptionid, borrowernumber);");
    $dbh->do("ALTER TABLE subscriptionroutinglist
                ADD CONSTRAINT `subscriptionroutinglist_ibfk_1` FOREIGN KEY (`borrowernumber`)
                REFERENCES `borrowers` (`borrowernumber`)
                ON DELETE CASCADE ON UPDATE CASCADE");
    $dbh->do("ALTER TABLE subscriptionroutinglist
                ADD CONSTRAINT `subscriptionroutinglist_ibfk_2` FOREIGN KEY (`subscriptionid`)
                REFERENCES `subscription` (`subscriptionid`)
                ON DELETE CASCADE ON UPDATE CASCADE");
    print "Upgrade to $DBversion done (Make subscriptionroutinglist more strict)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.03.00.002';
if (C4::Context->preference("Version") < TransformToNum($DBversion) && $original_version < TransformToNum("3.02.00.006")) {
    $dbh->do("UPDATE language_rfc4646_to_iso639 SET iso639_2_code='arm' WHERE rfc4646_subtag='hy';");
    $dbh->do("UPDATE language_rfc4646_to_iso639 SET iso639_2_code='eng' WHERE rfc4646_subtag='en';");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES( 'fi','fin');");
    $dbh->do("UPDATE language_rfc4646_to_iso639 SET iso639_2_code='fre' WHERE rfc4646_subtag='fr';");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES( 'lo','lao');");
    $dbh->do("UPDATE language_rfc4646_to_iso639 SET iso639_2_code='ita' WHERE rfc4646_subtag='it';");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES( 'sr','srp');");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES( 'tet','tet');");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES( 'ur','urd');");

    print "Upgrade to $DBversion done (Correct language mappings)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.03.00.003';
if (C4::Context->preference("Version") < TransformToNum($DBversion) && $original_version < TransformToNum("3.02.00.007")) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('UseTablesortForCirc','0','If on, use the JQuery tablesort function on the list of current borrower checkouts on the circulation page. Note that the use of this function may slow down circ for patrons with may checkouts.','','YesNo');");
    print "Upgrade to $DBversion done (Add UseTablesortForCirc syspref)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.03.00.004';
if (C4::Context->preference("Version") < TransformToNum($DBversion) && $original_version < TransformToNum("3.02.01.001")) {
    my $count = $dbh->selectrow_array('SELECT COUNT(*) FROM letter WHERE module = ? AND code = ?', {}, 'suggestions', 'ACCEPTED');
    $dbh->do(q/
INSERT INTO `letter`
(module, code, name, title, content)
VALUES
('suggestions','ACCEPTED','Suggestion accepted', 'Purchase suggestion accepted','Dear <<borrowers.firstname>> <<borrowers.surname>>,\n\nYou have suggested that the library acquire <<suggestions.title>> by <<suggestions.author>>.\n\nThe library has reviewed your suggestion today. The item will be ordered as soon as possible. You will be notified by mail when the order is completed, and again when the item arrives at the library.\n\nIf you have any questions, please email us at <<branches.branchemail>>.\n\nThank you,\n\n<<branches.branchname>>')
/) unless $count > 0;
    $count = $dbh->selectrow_array('SELECT COUNT(*) FROM letter WHERE module = ? AND code = ?', {}, 'suggestions', 'AVAILABLE');
    $dbh->do(q/
INSERT INTO `letter`
(module, code, name, title, content)
VALUES
('suggestions','AVAILABLE','Suggestion available', 'Suggested purchase available','Dear <<borrowers.firstname>> <<borrowers.surname>>,\n\nYou have suggested that the library acquire <<suggestions.title>> by <<suggestions.author>>.\n\nWe are pleased to inform you that the item you requested is now part of the collection.\n\nIf you have any questions, please email us at <<branches.branchemail>>.\n\nThank you,\n\n<<branches.branchname>>')
/) unless $count > 0;
    $count = $dbh->selectrow_array('SELECT COUNT(*) FROM letter WHERE module = ? AND code = ?', {}, 'suggestions', 'ORDERED');
    $dbh->do(q/
INSERT INTO `letter`
(module, code, name, title, content)
VALUES
('suggestions','ORDERED','Suggestion ordered', 'Suggested item ordered','Dear <<borrowers.firstname>> <<borrowers.surname>>,\n\nYou have suggested that the library acquire <<suggestions.title>> by <<suggestions.author>>.\n\nWe are pleased to inform you that the item you requested has now been ordered. It should arrive soon, at which time it will be processed for addition into the collection.\n\nYou will be notified again when the book is available.\n\nIf you have any questions, please email us at <<branches.branchemail>>\n\nThank you,\n\n<<branches.branchname>>')
/) unless $count > 0;
    $count = $dbh->selectrow_array('SELECT COUNT(*) FROM letter WHERE module = ? AND code = ?', {}, 'suggestions', 'REJECTED');
    $dbh->do(q/
INSERT INTO `letter`
(module, code, name, title, content)
VALUES
('suggestions','REJECTED','Suggestion rejected', 'Purchase suggestion declined','Dear <<borrowers.firstname>> <<borrowers.surname>>,\n\nYou have suggested that the library acquire <<suggestions.title>> by <<suggestions.author>>.\n\nThe library has reviewed your request today, and has decided not to accept the suggestion at this time.\n\nThe reason given is: <<suggestions.reason>>\n\nIf you have any questions, please email us at <<branches.branchemail>>.\n\nThank you,\n\n<<branches.branchname>>')
/) unless $count > 0;
    print "Upgrade to $DBversion done (bug 5127: add default templates for suggestion status change notifications)\n";
    SetVersion ($DBversion);
};

$DBversion = '3.03.00.005';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("update `systempreferences` set options='whitespace|T-prefix|cuecat|libsuite8' where variable='itemBarcodeInputFilter'");
    print "Upgrade to $DBversion done (Add itemBarcodeInputFilter choice libsuite8)\n";
}

$DBversion = '3.03.00.006';
if (C4::Context->preference("Version") < TransformToNum($DBversion) && $original_version < TransformToNum("3.02.01.002")) {
    $dbh->do("ALTER TABLE deletedborrowers ADD `privacy` int(11) AFTER smsalertnumber;");
    $dbh->do("ALTER TABLE deletedborrowers CHANGE `cardnumber` `cardnumber` varchar(16);");
    print "Upgrade to $DBversion done (Fix differences between borrowers and deletedborrowers)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.03.00.007';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER table suggestions ADD quantity SMALLINT(6) default NULL,
		ADD currency VARCHAR(3) default NULL,
		ADD price DECIMAL(28,6) default NULL,
		ADD total DECIMAL(28,6) default NULL;
		");
    print "Upgrade to $DBversion done (Added acq related columns to suggestions)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.03.00.008';
if (C4::Context->preference('Version') < TransformToNum($DBversion)){
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('OPACNoResultsFound','','Display this HTML when no results are found for a search in the OPAC','70|10','Textarea')");
    print "Upgrade to $DBversion done (adding syspref OPACNoResultsFound to control what displays when no results are found for a search in the OPAC.)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.03.00.009';
if (C4::Context->preference("Version") < TransformToNum($DBversion) && $original_version < TransformToNum("3.02.01.003")) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('IntranetUserCSS','','Add CSS to be included in the Intranet',NULL,'free')");
    print "Upgrade to $DBversion done (Add IntranetUserCSS syspref)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.03.00.010";
if (C4::Context->preference("Version") < TransformToNum($DBversion) && $original_version < TransformToNum("3.02.02.001")) {
    $dbh->do("UPDATE `marc_subfield_structure` SET liblibrarian = 'Distance from earth' WHERE liblibrarian = 'Distrance from earth' AND tagfield = '034' AND tagsubfield = 'r';");
    $dbh->do("UPDATE `marc_subfield_structure` SET libopac = 'Distance from earth' WHERE libopac = 'Distrance from earth' AND tagfield = '034' AND tagsubfield = 'r';");
    print "Upgrade to $DBversion done (Fix misspelled 034r subfield in MARC21 Frameworks)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.03.00.011";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("UPDATE aqbooksellers SET gstrate=NULL WHERE gstrate=0.0");
    print "Upgrade to $DBversion done (Bug 5186: allow GST rate to be set to 0)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.03.00.012";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
   $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('maxItemsInSearchResults',20,'Specify the maximum number of items to display for each result on a page of results',NULL,'free')");
   print "Upgrade to $DBversion done (Bug 2142: maxItemsInSearchResults syspref resurrected)\n";
   SetVersion ($DBversion);
}

$DBversion = "3.03.00.013";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('OpacPublic','1','If set to OFF and user is not logged in, all  OPAC pages require authentication, and OPAC searchbar is removed)','','YesNo')");
    print "Upgrade to $DBversion done (added 'OpacPublic' syspref)\n";
   SetVersion ($DBversion);
}

$DBversion = "3.03.00.014";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES ('ShelfBrowserUsesLocation','1','Use the item location when finding items for the shelf browser.','1','YesNo')");
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES ('ShelfBrowserUsesHomeBranch','1','Use the item home branch when finding items for the shelf browser.','1','YesNo')");
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES ('ShelfBrowserUsesCcode','0','Use the item collection code when finding items for the shelf browser.','1','YesNo')");
    print "Upgrade to $DBversion done (Add flexible shelf browser constraints)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.03.00.015";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    if ( C4::Context->preference("marcflavour") eq "MARC21" ) {
        my $sth = $dbh->prepare(
"INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`,
                             `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`)
                             VALUES ( ?, '9', '9 (RLIN)', '9 (RLIN)', 0, 0, '', 6, '', '', '', 0, -5, '', '', '', NULL)"
        );
        $sth->execute('648');
        $sth->execute('654');
        $sth->execute('655');
        $sth->execute('656');
        $sth->execute('657');
        $sth->execute('658');
        $sth->execute('662');
        $sth->finish;
        print
"Upgrade to $DBversion done (Bug 5619: Add subfield 9 to marc21 648,654,655,656,657,658,662)\n";
    }
    SetVersion($DBversion);
}

$DBversion = '3.03.00.016';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    # reimplement OpacPrivacy system preference
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('OpacPrivacy', '0', 'if ON, allows patrons to define their privacy rules (reading history)',NULL,'YesNo')");
    $dbh->do("ALTER TABLE `borrowers` ADD `privacy` INTEGER NOT NULL DEFAULT 1;");
    $dbh->do("ALTER TABLE `deletedborrowers` ADD `privacy` INTEGER NOT NULL DEFAULT 1;");
    print "Upgrade to $DBversion done (OpacPrivacy reimplementation)\n";
    SetVersion($DBversion);
};

$DBversion = '3.03.00.017';
if (C4::Context->preference("Version") < TransformToNum($DBversion) && $original_version < TransformToNum("3.02.03.001")) {
    $dbh->do("ALTER TABLE  `currency` CHANGE `rate` `rate` FLOAT( 15, 5 ) NULL DEFAULT NULL;");
    print "Upgrade to $DBversion done (Enable currency rates >= 100)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.03.00.018';
if (C4::Context->preference("Version") < TransformToNum($DBversion) && $original_version < TransformToNum("3.02.03.002")) {
    $dbh->do( q|update language_descriptions set description = 'Nederlands' where lang = 'nl' and subtag = 'nl'|);
    $dbh->do( q|update language_descriptions set description = 'Dansk' where lang = 'da' and subtag = 'da'|);
    print "Upgrade to $DBversion done (Correct language descriptions)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.03.00.019';
if (C4::Context->preference("Version") < TransformToNum($DBversion) && $original_version < TransformToNum("3.02.03.003")) {
    # Fix bokmål
    $dbh->do("UPDATE language_subtag_registry SET description = 'Norwegian bokm&#229;l' WHERE subtag = 'nb';");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES( 'nb','nob');");
    $dbh->do("UPDATE language_descriptions SET description = 'Norsk bokm&#229;l' WHERE subtag = 'nb' AND lang = 'nb';");
    $dbh->do("UPDATE language_descriptions SET description = 'Norwegian bokm&#229;l' WHERE subtag = 'nb' AND lang = 'en';");
    $dbh->do("UPDATE language_descriptions SET description = 'Norvégien bokm&#229;l' WHERE subtag = 'nb' AND lang = 'fr';");
    # Add nynorsk
    $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'nn', 'language', 'Norwegian nynorsk','2011-02-14' )");
    $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES( 'nn','nno')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES( 'nn', 'language', 'nb', 'Norsk nynorsk')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES( 'nn', 'language', 'nn', 'Norsk nynorsk')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES( 'nn', 'language', 'en', 'Norwegian nynorsk')");
    $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES( 'nn', 'language', 'fr', 'Norvégien nynorsk')");
    print "Upgrade to $DBversion done (Correct language descriptions for Norwegian)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.03.00.020';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES ('AllowFineOverride','0','If on, staff will be able to issue books to patrons with fines greater than noissuescharge.','0','YesNo')");
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES ('AllFinesNeedOverride','1','If on, staff will be asked to override every fine, even if it is below noissuescharge.','0','YesNo')");
    print "Upgrade to $DBversion done (Bug 5811: Add sysprefs controlling overriding fines)\n";
    SetVersion($DBversion);
};

$DBversion = '3.03.00.021';
if (C4::Context->preference("Version") < TransformToNum($DBversion) && $original_version < TransformToNum("3.02.05.001")) {
    $dbh->do("ALTER TABLE items MODIFY enumchron TEXT");
    $dbh->do("ALTER TABLE deleteditems MODIFY enumchron TEXT");
    print "Upgrade to $DBversion done (bug 5642: longer serial enumeration)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.03.00.022';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES ('AuthoritiesLog','0','If ON, log edit/create/delete actions on authorities.','','YesNo');");
    print "Upgrade to $DBversion done (Add AuthoritiesLog syspref)\n";
    SetVersion ($DBversion);
}

# due to a mismatch in kohastructure.sql some koha will have missing columns in aqbasketgroup
# this attempts to fix that
$DBversion = '3.03.00.023';
if (C4::Context->preference("Version") < TransformToNum($DBversion) && $original_version < TransformToNum("3.02.05.002")) {
    my $sth = $dbh->prepare("SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'aqbasketgroups' AND COLUMN_NAME = 'billingplace'");
    $sth->execute;
    $dbh->do("ALTER TABLE aqbasketgroups ADD billingplace VARCHAR(10)") if ! $sth->fetchrow_hashref;
    $sth = $dbh->prepare("SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'aqbasketgroups' AND COLUMN_NAME = 'deliveryplace'");
    $sth->execute;
    $dbh->do("ALTER TABLE aqbasketgroups ADD deliveryplace VARCHAR(10)") if ! $sth->fetchrow_hashref;
    $sth = $dbh->prepare("SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'aqbasketgroups' AND COLUMN_NAME = 'deliverycomment'");
    $sth->execute;
    $dbh->do("ALTER TABLE aqbasketgroups ADD deliverycomment VARCHAR(255)") if ! $sth->fetchrow_hashref;
    print "Upgrade to $DBversion done (Reconcile aqbasketgroups)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.03.00.024';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES ('TraceCompleteSubfields','0','Force subject tracings to only match complete subfields.','0','YesNo')");
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES ('UseAuthoritiesForTracings','1','Use authority record numbers for subject tracings instead of heading strings.','0','YesNo')");
    print "Upgrade to $DBversion done (Add syspref to force whole-subfield matching on subject tracings)\n";
    SetVersion($DBversion);
};

$DBversion = "3.03.00.025";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('OPACAllowUserToChooseBranch', 1, 'Allow the user to choose the branch they want to pickup their hold from','1','YesNo')");
    print "Upgrade to $DBversion done (Add syspref to control if user can choose pickup branch for holds)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.03.00.026';
if (C4::Context->preference("Version") < TransformToNum($DBversion) && $original_version < TransformToNum("3.02.05.003")) {
    $dbh->do("UPDATE `message_attributes` SET message_name='Item Due' WHERE message_attribute_id=1 AND message_name LIKE 'Item DUE'");
	print "Upgrade to $DBversion done ( fix capitalization in message type )\n";
    SetVersion ($DBversion);
}

$DBversion = '3.03.00.027';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('displayFacetCount', '0', NULL, NULL, 'YesNo')");
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('maxRecordsForFacets', '20', NULL, NULL, 'Integer')");
    print "Upgrade to $DBversion done (Preferences for facet count)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.03.00.028";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('FacetLabelTruncationLength', 20, 'Truncate facets length to','','free')");
    print "Upgrade to $DBversion done (Add FacetLabelTruncationLength syspref to control facets displayed length)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.03.00.029";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('AllowPurchaseSuggestionBranchChoice', 0, 'Allow user to choose branch when making a purchase suggestion','1','YesNo')");
    print "Upgrade to $DBversion done (Add syspref to control if user can choose branch when making purchase suggestion)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.03.00.030";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('OpacFavicon','','Enter a complete URL to an image to replace the default Koha favicon on the OPAC','','free')");
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('IntranetFavicon','','Enter a complete URL to an image to replace the default Koha favicon on the Staff client','','free')");
    print "Upgrade to $DBversion done (Add sysprefs to control custom favicons)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.03.00.031";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('FineNotifyAtCheckin',0,'If ON notify librarians of overdue fines on the items they are checking in.',NULL,'YesNo');");
    print "Upgrade to $DBversion done (Add syspref FineNotifyAtCheckin)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.03.00.032';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('TraceSubjectSubdivisions', 1, 'Create searches on all subdivisions for subject tracings.','1','YesNo')");
    print "Upgrade to $DBversion done ( include subdivisions when generating subject tracing searches )\n";
}


$DBversion = '3.03.00.033';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('StaffAuthorisedValueImages', '1', '', NULL, 'YesNo')");
    print "Upgrade to $DBversion done (System pref StaffAuthorisedValueImages)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.03.00.034';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE `categories` ADD `hidelostitems` tinyint(1) NOT NULL default '0' AFTER `reservefee`");
    print "Upgrade to $DBversion done (Add hidelostitems preference to borrower categories)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.03.00.035';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE `issuingrules` ADD hardduedate date default NULL AFTER issuelength");
    $dbh->do("ALTER TABLE `issuingrules` ADD hardduedatecompare tinyint NOT NULL default 0 AFTER hardduedate");
    my $duedate;
    if (C4::Context->preference("globalDueDate")) {
      $duedate = eval { output_pref( { dt => dt_from_string( C4::Context->preference("globalDueDate") ), dateonly => 1, dateformat => 'iso' } ); };
      $dbh->do("UPDATE `issuingrules` SET hardduedate = '$duedate', hardduedatecompare = 0");
    } elsif (C4::Context->preference("ceilingDueDate")) {
      $duedate = eval { output_pref( { dt => dt_from_string( C4::Context->preference("ceilingDueDate") ), dateonly => 1, dateformat => 'iso' } ); };
      $dbh->do("UPDATE `issuingrules` SET hardduedate = '$duedate', hardduedatecompare = -1");
    }
    $dbh->do("DELETE FROM `systempreferences` WHERE variable = 'globalDueDate' OR variable = 'ceilingDueDate'");
    print "Upgrade to $DBversion done (Move global and ceiling due dates to Circ Rules level)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.03.00.036';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('COinSinOPACResults', 1, 'If ON, use COinS in OPAC search results page.  NOTE: this can slow down search response time significantly','','YesNo')");
    print "Upgrade to $DBversion done ( Make COinS optional in OPAC search results )\n";
    SetVersion ($DBversion);
}

$DBversion = '3.03.00.037';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('OPACDisplay856uAsImage','OFF','Display the URI in the 856u field as an image, the corresponding OPACXSLT option must be on','OFF|Details|Results|Both','Choice')");
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('Display856uAsImage','OFF','Display the URI in the 856u field as an image, the corresponding Staff Client XSLT option must be on','OFF|Details|Results|Both','Choice')");
    print "Upgrade to $DBversion done (Add 'Display856uAsImage' and 'OPACDisplay856uAsImage' syspref)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.03.00.038';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES ('SelfCheckTimeout',120,'Define the number of seconds before the Web-based Self Checkout times out a patron','','Integer')");
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES ('AllowSelfCheckReturns',0,'If enabled, patrons may return items through the Web-based Self Checkout','','YesNo')");
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES ('SelfCheckHelpMessage','','Enter HTML to include under the basic Web-based Self Checkout instructions on the Help page','70|10','Textarea')");
    print "Upgrade to $DBversion done ( Add Self-checkout by Login system preferences )\n";
}

$DBversion = "3.03.00.039";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('ShowReviewer',1,'If ON, name of reviewer will be shown above comments in OPAC',NULL,'YesNo');");
    print "Upgrade to $DBversion done (Add syspref ShowReviewer)\n";
}

$DBversion = "3.03.00.040";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('UseControlNumber',0,'If ON, record control number (w subfields) and control number (001) are used for linking of bibliographic records.','','YesNo');");
    print "Upgrade to $DBversion done (Add syspref UseControlNumber)\n";
}

$DBversion = "3.03.00.041";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('AlternateHoldingsField','','The MARC field/subfield that contains alternate holdings information for bibs taht do not have items attached (e.g. 852abchi for libraries converting from MARC Magician).',NULL,'free')");
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('AlternateHoldingsSeparator','','The string to use to separate subfields in alternate holdings displays.',NULL,'free')");
    print "Upgrade to $DBversion done (Add sysprefs to control alternate holdings information display)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.03.00.042';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    stocknumber_checker();
    print "Upgrade to $DBversion done (5860 Index itemstocknumber)\n";
    SetVersion ($DBversion);
}

sub stocknumber_checker { #code reused later on
  my @row;
  #drop the obsolete itemSStocknumber idx if it exists
  @row = $dbh->selectrow_array("SHOW INDEXES FROM items WHERE key_name='itemsstocknumberidx'");
  $dbh->do("ALTER TABLE `items` DROP INDEX `itemsstocknumberidx`;") if @row;

  #check itemstocknumber idx; remove it if it is unique
  @row = $dbh->selectrow_array("SHOW INDEXES FROM items WHERE key_name='itemstocknumberidx' AND non_unique=0");
  $dbh->do("ALTER TABLE `items` DROP INDEX `itemstocknumberidx`;") if @row;

  #add itemstocknumber index non-unique IF it still not exists
  @row = $dbh->selectrow_array("SHOW INDEXES FROM items WHERE key_name='itemstocknumberidx'");
  $dbh->do("ALTER TABLE items ADD INDEX itemstocknumberidx (stocknumber);") unless @row;
}

$DBversion = "3.03.00.043";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {

    $dbh->do("INSERT INTO authorised_values (category,authorised_value,lib,lib_opac) VALUES ('YES_NO','0','No','No')");
    $dbh->do("INSERT INTO authorised_values (category,authorised_value,lib,lib_opac) VALUES ('YES_NO','1','Yes','Yes')");

	print "Upgrade to $DBversion done ( add generic boolean YES_NO authorised_values pair )\n";
	SetVersion ($DBversion);
}

$DBversion = '3.03.00.044';
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("ALTER TABLE `aqbasketgroups` ADD `freedeliveryplace` TEXT NULL AFTER `deliveryplace`;");
    print "Upgrade to $DBversion done (adding freedeliveryplace to basketgroups)\n";
}

$DBversion = '3.03.00.045';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    #Remove obsolete columns from aqbooksellers if needed
    my $a = $dbh->selectall_hashref('SHOW columns from aqbooksellers','Field');
    my $sqldrop="ALTER TABLE aqbooksellers DROP COLUMN ";
    foreach(qw/deliverydays followupdays followupscancel invoicedisc nocalc specialty/) {
      $dbh->do($sqldrop.$_) if exists $a->{$_};
    }
    #Remove obsolete column from aqbudgets if needed
    #The correct column is budget_notes
    $a = $dbh->selectall_hashref('SHOW columns from aqbudgets','Field');
    if(exists $a->{budget_description}) {
      $dbh->do("ALTER TABLE aqbudgets DROP COLUMN budget_description");
    }
    print "Upgrade to $DBversion done (Remove obsolete columns from aqbooksellers and aqbudgets if needed)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.03.00.046";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("ALTER TABLE overduerules ALTER delay1 SET DEFAULT NULL, ALTER delay2 SET DEFAULT NULL, ALTER delay3 SET DEFAULT NULL");
    print "Upgrade to $DBversion done (Setting NULL default value for delayn columns in table overduerules)\n";
    SetVersion($DBversion);
}

$DBversion = '3.03.00.047';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE borrowers ADD `state` mediumtext AFTER city;");
    $dbh->do("ALTER TABLE borrowers ADD `B_state` mediumtext AFTER B_city;");
    $dbh->do("ALTER TABLE borrowers ADD `altcontactstate` mediumtext AFTER altcontactaddress3;");
    $dbh->do("ALTER TABLE deletedborrowers ADD `state` mediumtext AFTER city;");
    $dbh->do("ALTER TABLE deletedborrowers ADD `B_state` mediumtext AFTER B_city;");
    $dbh->do("ALTER TABLE deletedborrowers ADD `altcontactstate` mediumtext AFTER altcontactaddress3;");
    print "Upgrade to $DBversion done (Add state field to patron's addresses)\n";
}

$DBversion = '3.03.00.048';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE branches ADD `branchstate` mediumtext AFTER `branchcity`;");
    print "Upgrade to $DBversion done (Add state to branch address)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.03.00.049';
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("ALTER TABLE `accountlines` ADD `note` text NULL default NULL");
    $dbh->do("ALTER TABLE `accountlines` ADD `manager_id` int( 11 ) NULL ");
    print "Upgrade to $DBversion done (adding note and manager_id fields in accountlines table)\n";
    SetVersion($DBversion);
}

$DBversion = "3.03.00.050";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("
	INSERT IGNORE INTO `systempreferences` (variable,value,explanation,options,type) VALUES('OpacHiddenItems','','This syspref allows to define custom rules for hiding specific items at opac. See docs/opac/OpacHiddenItems.txt for more informations.','','Textarea');
	");
    print "Upgrade to $DBversion done (Adding OpacHiddenItems syspref)\n";
    SetVersion($DBversion);
}

$DBversion = "3.03.00.051";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    print "Upgrade to $DBversion done (Remove spaces and dashes from message_attribute names)\n";
    $dbh->do("UPDATE message_attributes SET message_name = 'Item_Due' WHERE message_name='Item Due'");
    $dbh->do("UPDATE message_attributes SET message_name = 'Advance_Notice' WHERE message_name='Advance Notice'");
    $dbh->do("UPDATE message_attributes SET message_name = 'Hold_Filled' WHERE message_name='Hold Filled'");
    $dbh->do("UPDATE message_attributes SET message_name = 'Item_Check_in' WHERE message_name='Item Check-in'");
    $dbh->do("UPDATE message_attributes SET message_name = 'Item_Checkout' WHERE message_name='Item Checkout'");
    SetVersion ($DBversion);
}

$DBversion = "3.03.00.052";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('WaitingNotifyAtCheckin',0,'If ON, notify librarians of waiting holds for the patron whose items they are checking in.',NULL,'YesNo');");
    print "Upgrade to $DBversion done (Add syspref WaitingNotifyAtCheckin)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.04.00.000";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    print "Upgrade to $DBversion done Koha 3.4.0 release \n";
    SetVersion ($DBversion);
}

$DBversion = "3.05.00.001";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do(qq{
    INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('numSearchRSSResults',50,'Specify the maximum number of results to display on a RSS page of results',NULL,'Integer');
    });
    print "Upgrade to $DBversion done (Adds New System preference numSearchRSSResults)\n";
    SetVersion($DBversion);
}

$DBversion = '3.05.00.002';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    #follow up fix 5860: some installs already past 3.3.0.42
    stocknumber_checker();
    print "Upgrade to $DBversion done (Fix for stocknumber index)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.05.00.003";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do(qq{
    INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('OpacRenewalBranch','checkoutbranch','Choose how the branch for an OPAC renewal is recorded in statistics','itemhomebranch|patronhomebranch|checkoutbranch|null','Choice');
    });
    print "Upgrade to $DBversion done (Adds New System preference OpacRenewalBranch)\n";
    SetVersion($DBversion);
}

$DBversion = "3.05.00.004";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('ShowReviewerPhoto',1,'If ON, photo of reviewer will be shown beside comments in OPAC',NULL,'YesNo');");
    print "Upgrade to $DBversion done (Add syspref ShowReviewerPhoto)\n";
    SetVersion($DBversion);
}

$DBversion = "3.05.00.005";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES ('BasketConfirmations', '1', 'When closing or reopening a basket,', 'always ask for confirmation.|do not ask for confirmation.', 'Choice');");
    print "Upgrade to $DBversion done (Adds pref BasketConfirmations)\n";
    SetVersion($DBversion);
}

$DBversion = "3.05.00.006";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('MARCAuthorityControlField008', '|| aca||aabn           | a|a     d', NULL, NULL, 'Textarea')");
    print "Upgrade to $DBversion done (Add syspref MARCAuthorityControlField008)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.05.00.007";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('OpenLibraryCovers',0,'If ON Openlibrary book covers will be show',NULL,'YesNo');");
    print "Upgrade to $DBversion done (Add syspref OpenLibraryCovers)\n";
    SetVersion($DBversion);
}

$DBversion = "3.05.00.008";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE `cities` ADD `city_state` VARCHAR( 100 ) NULL DEFAULT NULL AFTER  `city_name`;");
    $dbh->do("ALTER TABLE `cities` ADD `city_country` VARCHAR( 100 ) NULL DEFAULT NULL AFTER  `city_zipcode`;");
    print "Add state and country to cities table corresponding to new columns in borrowers\n";
    SetVersion($DBversion);
}

$DBversion = "3.05.00.009";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO old_issues (borrowernumber, itemnumber, date_due, branchcode, issuingbranch, returndate, lastreneweddate, `return`, renewals, timestamp, issuedate)
              SELECT borrowernumber, itemnumber, date_due, branchcode, issuingbranch, returndate, lastreneweddate, `return`, renewals, timestamp, issuedate FROM issues WHERE borrowernumber IS NULL");
    $dbh->do("DELETE FROM issues WHERE borrowernumber IS NULL");

    $dbh->do("INSERT INTO old_issues (borrowernumber, itemnumber, date_due, branchcode, issuingbranch, returndate, lastreneweddate, `return`, renewals, timestamp, issuedate)
              SELECT borrowernumber, itemnumber, date_due, branchcode, issuingbranch, returndate, lastreneweddate, `return`, renewals, timestamp, issuedate FROM issues WHERE itemnumber IS NULL");
    $dbh->do("DELETE FROM issues WHERE itemnumber IS NULL");

    $dbh->do("INSERT INTO old_issues (borrowernumber, itemnumber, date_due, branchcode, issuingbranch, returndate, lastreneweddate, `return`, renewals, timestamp, issuedate)
              SELECT borrowernumber, itemnumber, date_due, branchcode, issuingbranch, returndate, lastreneweddate, `return`, renewals, timestamp, issuedate FROM issues WHERE NOT EXISTS (SELECT * FROM borrowers WHERE borrowernumber = issues.borrowernumber)");
    $dbh->do("DELETE FROM issues WHERE NOT EXISTS (SELECT * FROM borrowers WHERE borrowernumber = issues.borrowernumber)");

    $dbh->do("INSERT INTO old_issues (borrowernumber, itemnumber, date_due, branchcode, issuingbranch, returndate, lastreneweddate, `return`, renewals, timestamp, issuedate)
              SELECT borrowernumber, itemnumber, date_due, branchcode, issuingbranch, returndate, lastreneweddate, `return`, renewals, timestamp, issuedate FROM issues WHERE NOT EXISTS (SELECT * FROM items WHERE itemnumber = issues.itemnumber)");
    $dbh->do("DELETE FROM issues WHERE NOT EXISTS (SELECT * FROM items WHERE itemnumber = issues.itemnumber)");

    $dbh->do("ALTER TABLE issues DROP FOREIGN KEY `issues_ibfk_1`");
    $dbh->do("ALTER TABLE issues DROP FOREIGN KEY `issues_ibfk_2`");
    $dbh->do("ALTER TABLE issues ALTER COLUMN borrowernumber DROP DEFAULT");
    $dbh->do("ALTER TABLE issues ALTER COLUMN itemnumber DROP DEFAULT");
    $dbh->do("ALTER TABLE issues MODIFY COLUMN borrowernumber int(11) NOT NULL");
    $dbh->do("ALTER TABLE issues MODIFY COLUMN itemnumber int(11) NOT NULL");
    $dbh->do("ALTER TABLE issues DROP KEY `issuesitemidx`");
    $dbh->do("ALTER TABLE issues ADD PRIMARY KEY (`itemnumber`)");
    $dbh->do("ALTER TABLE issues ADD CONSTRAINT `issues_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE RESTRICT ON UPDATE CASCADE");
    $dbh->do("ALTER TABLE issues ADD CONSTRAINT `issues_ibfk_2` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE RESTRICT ON UPDATE CASCADE");

    print "Upgrade to $DBversion done (issues referential integrity)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.05.00.010";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("CREATE INDEX priorityfoundidx ON reserves (priority,found)");
    print "Create an index on reserves to speed up holds awaiting pickup report bug 5866\n";
    SetVersion($DBversion);
}


$DBversion = "3.05.00.011";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('OPACResultsSidebar','','Define HTML to be included on the search results page, underneath the facets sidebar','70|10','Textarea')");
    print "Upgrade to $DBversion done (add OPACResultsSidebar syspref (enh 6165))\n";
    SetVersion($DBversion);
}

$DBversion = "3.05.00.012";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('RecordLocalUseOnReturn',0,'If ON, statistically record returns of unissued items as local use, instead of return',NULL,'YesNo')");
    print "Upgrade to $DBversion done (add RecordLocalUseOnReturn syspref (enh 6403))\n";
    SetVersion($DBversion);
}

$DBversion = "3.05.00.013";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do(qq|INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES ('OpacKohaUrl','0',"Show 'Powered by Koha' text on OPAC footer.",NULL,NULL)|);
    print "Upgrade to $DBversion done (Add syspref 'OpacKohaUrl')\n";
    SetVersion($DBversion);
}

$DBversion = "3.05.00.014";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE `borrowers` MODIFY `userid` VARCHAR(75)");
    print "Modified userid column length into 75 in borrowers\n";
    SetVersion($DBversion);
}

$DBversion = "3.05.00.015";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('NovelistSelectEnabled',0,'Enable Novelist Select content.  Requires Novelist Profile and Password',NULL,'YesNo')");
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('NovelistSelectProfile',NULL,'Novelist Select user Password',NULL,'free')");
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('NovelistSelectPassword',NULL,'Enable Novelist user Profile',NULL,'free')");
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('NovelistSelectView','tab','Where to display Novelist Select content','tab|above|below|right','Choice')");
    print "Upgrade to $DBversion done (Add support for EBSCO's NoveList Select (enh 6902))\n";
    SetVersion($DBversion);
}

$DBversion = '3.05.00.016';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('EasyAnalyticalRecords','0','If on, display in the catalogue screens tools to easily setup analytical record relationships','','YesNo');");
    print "Upgrade to $DBversion done (Add EasyAnalyticalRecords syspref)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.05.00.017';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    if (C4::Context->preference("marcflavour") eq 'MARC21' ||
        C4::Context->preference("marcflavour") eq 'NORMARC'){
        $dbh->do("INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value` , `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES ('773', '0', 'Host Biblionumber', 'Host Biblionumber', 0, 0, NULL, 7, NULL, NULL, '', NULL, -6, '', '', '', NULL)");
        $dbh->do("INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value` , `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES ('773', '9', 'Host Itemnumber', 'Host Itemnumber', 0, 0, NULL, 7, NULL, NULL, '', NULL, -6, '', '', '', NULL)");
        print "Upgrade to $DBversion done (Add 773 subfield 9 and 0 to default framework)\n";
        SetVersion ($DBversion);
    } elsif (C4::Context->preference("marcflavour") eq 'UNIMARC'){
        $dbh->do("INSERT INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value` , `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES ('461', '9', 'Host Itemnumber', 'Host Itemnumber', 0, 0, NULL, 7, NULL, NULL, '', NULL, -6, '', '', '', NULL)");
        print "Upgrade to $DBversion done (Add 461 subfield 9 to default framework)\n";
        SetVersion ($DBversion);
    }
}

$DBversion = "3.05.00.018";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('OpacNavBottom','','Links after OpacNav links','70|10','Textarea')");
    print "Upgrade to $DBversion done (add OpacNavBottom syspref (enh 6825): if appropriate, you can split OpacNav into OpacNav and OpacNavBottom)\n";
    SetVersion($DBversion);
}

$DBversion = "3.05.00.019";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("UPDATE itemtypes SET imageurl = 'vokal/Book.png' WHERE imageurl = 'vokal/BOOK.png'");
    $dbh->do("UPDATE itemtypes SET imageurl = 'vokal/Book-32px.png' WHERE imageurl = 'vokal/BOOK-32px.png'");
    $dbh->do("UPDATE authorised_values SET imageurl = 'vokal/Book.png' WHERE imageurl = 'vokal/BOOK.png'");
    $dbh->do("UPDATE authorised_values SET imageurl = 'vokal/Book-32px.png' WHERE imageurl = 'vokal/BOOK-32px.png'");
    print "Upgrade to $DBversion done (remove duplicate VOKAL Book icons, bug 6862)\n";
    SetVersion($DBversion);
}

$DBversion = "3.05.00.020";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,options,explanation,type) VALUES ('AcqViewBaskets','user','user|branch|all','Define which baskets a user is allowed to view: his own only, any within his branch or all','Choice')");
    print "Upgrade to $DBversion done (Add syspref AcqViewBaskets)\n";
    SetVersion($DBversion);
}

$DBversion = "3.05.00.021";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE borrower_attribute_types ADD COLUMN display_checkout TINYINT(1) NOT NULL DEFAULT '0';");
    print "Upgrade to $DBversion done (Added a display_checkout field in borrower_attribute_types table)\n";
    SetVersion($DBversion);
}

$DBversion = "3.05.00.022";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("CREATE TABLE need_merge_authorities (id int NOT NULL auto_increment PRIMARY KEY, authid bigint NOT NULL, done tinyint DEFAULT 0) ENGINE=InnoDB DEFAULT CHARSET=utf8");
    print "Upgrade to $DBversion done (6094: Fixing ModAuthority problems, add a need_merge_authorities table)\n";
    SetVersion($DBversion);
}

$DBversion = "3.05.00.023";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('OpacShowRecentComments',0,'If ON a link to recent comments will appear in the OPAC masthead',NULL,'YesNo');");
    print "Upgrade to $DBversion done (Add syspref OpacShowRecentComments. When the preference is turned on a link to recent comments will appear in the OPAC masthead. )\n";
    SetVersion($DBversion);
}

$DBversion = "3.06.00.000";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    print "Upgrade to $DBversion done Koha 3.6.0 release \n";
    SetVersion ($DBversion);
}

$DBversion = "3.07.00.001";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    my $borrowers = $dbh->selectcol_arrayref( "SELECT borrowernumber from borrowers where debarred =1;", { Columns => [1] } );
    $dbh->do("ALTER TABLE borrowers MODIFY debarred DATE DEFAULT NULL;");
    $dbh->do( "UPDATE borrowers set debarred='9999-12-31' where borrowernumber IN (" . join( ",", @$borrowers ) . ");" ) if ($borrowers and scalar(@$borrowers)>0);
    $dbh->do("ALTER TABLE borrowers ADD COLUMN debarredcomment VARCHAR(255) DEFAULT NULL AFTER debarred;");
    $dbh->do("ALTER TABLE deletedborrowers MODIFY debarred DATE DEFAULT NULL;");
    $dbh->do("ALTER TABLE deletedborrowers ADD COLUMN debarredcomment VARCHAR(255) DEFAULT NULL AFTER debarred;");
    print "Upgrade done (Change borrowers.debarred into Date )\n";
    SetVersion($DBversion);
}

$DBversion = "3.07.00.002";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("UPDATE borrowers SET debarred=NULL WHERE debarred='0000-00-00';");
    print "Setting NULL to debarred where 0000-00-00 is stored (bug 7272)\n";
    SetVersion($DBversion);
}

$DBversion = "3.07.00.003";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do(" UPDATE `message_attributes` SET message_name='Item_Due' WHERE message_name='Item_DUE'");
    print "Updating message_name in message_attributes\n";
    SetVersion($DBversion);
}

$DBversion = "3.07.00.004";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE  `suggestions` ADD  `patronreason` TEXT NULL AFTER  `reason`");
    print "Upgrade to $DBversion done (Add column to suggestions table to store patrons' reasons for submitting a suggestion. )\n";
    SetVersion($DBversion);
}

$DBversion = "3.07.00.005";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES ('BorrowerUnwantedField','','Name the fields you don''t need to store for a patron''s account',NULL,'free')");
    print "Upgrade to $DBversion done (BorrowerUnwantedField syspref)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.07.00.006";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('CircAutoPrintQuickSlip', '1', 'Choose what should happen when an empty barcode field is submitted in circulation: Display a print quick slip window or Clear the screen.',NULL,'YesNo');");
    print "Upgrade to $DBversion done (Add syspref CircAutoPrintQuickSlip to control what should happen when an empty barcode field is submitted in circulation: Display a print quick slip window (default value, 3.6 behaviour) or clear the screen (previous 3.6 behaviour). )\n";
    SetVersion($DBversion);
}

$DBversion = "3.07.00.007";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE items MODIFY materials text;");
    print "Upgrade to $DBversion done alter items.material from varchar(10) to text \n";
    SetVersion($DBversion);
}

$DBversion = '3.07.00.008';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    if (C4::Context->preference("marcflavour") eq 'MARC21') {
        if (C4::Context->preference("opaclanguages") eq "de") {
            $dbh->do("INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES ('545', 'Fußnote zu biografischen oder historischen Daten', 'Fußnote zu biografischen oder historischen Daten', 1, 0, NULL, '');");
        } else {
            $dbh->do("INSERT INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES ('545', 'BIOGRAPHICAL OR HISTORICAL DATA', 'BIOGRAPHICAL OR HISTORICAL DATA', 1, 0, NULL, '');");
        }
    }
    print "Upgrade to $DBversion done (add MARC21 field 545 to framework)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.07.00.009";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("ALTER TABLE `aqorders` ADD COLUMN `claims_count` INT(11)  DEFAULT 0, ADD COLUMN `claimed_date` DATE  DEFAULT NULL AFTER `claims_count`");
    print "Upgrade to $DBversion done (Add claims_count and claimed_date fields in aqorders table)\n";
    SetVersion($DBversion);
}

$DBversion = "3.07.00.010";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do(
        q|CREATE TABLE `biblioimages` (
          `imagenumber` int(11) NOT NULL AUTO_INCREMENT,
          `biblionumber` int(11) NOT NULL,
          `mimetype` varchar(15) NOT NULL,
          `imagefile` mediumblob NOT NULL,
          `thumbnail` mediumblob NOT NULL,
          PRIMARY KEY (`imagenumber`),
          CONSTRAINT `bibliocoverimage_fk1` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8|
    );
    $dbh->do(
        q|INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES ('OPACLocalCoverImages','0','Display local cover images on OPAC search and details pages.','1','YesNo')|
        );
    $dbh->do(
        q|INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES ('LocalCoverImages','0','Display local cover images on intranet search and details pages.','1','YesNo')|
        );
    $dbh->do(
        q|INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES ('AllowMultipleCovers','0','Allow multiple cover images to be attached to each bibliographic record.','1','YesNo')|
    );
    $dbh->do(
        q|INSERT INTO permissions (module_bit, code, description) VALUES (13, 'upload_local_cover_images', 'Upload local cover images')|
    );
    print "Upgrade to $DBversion done (Added support for local cover images)\n";
    SetVersion($DBversion);
}

$DBversion = "3.07.00.011";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do(<<ENDOFRENEWAL);
    INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('BorrowerRenewalPeriodBase', 'now', 'Set whether the borrower renewal date should be counted from the dateexpiry or from the current date ','dateexpiry|now','Choice');
ENDOFRENEWAL
    print "Upgrade to $DBversion done (Added a system preference to allow renewal of Patron account either from todays date or from existing expiry date in the patrons account.)\n";
    SetVersion($DBversion);
}

$DBversion = "3.07.00.012";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('AllowItemsOnHoldCheckout',0,'Do not generate RESERVE_WAITING and RESERVED warning when checking out items reserved to someone else. This allows self checkouts for those items.','','YesNo')");
    print "Upgrade to $DBversion add 'AllowItemsOnHoldCheckout' syspref \n";
    SetVersion ($DBversion);
}

$DBversion = "3.07.00.013";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('OpacExportOptions','bibtex|dc|marcxml|marc8|utf8|marcstd|mods|ris','Define available export options on OPAC detail page.','','free');");
    print "Upgrade to $DBversion done (Bug 7345: Add system preference OpacExportOptions.)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.07.00.014";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    print "RELTERMS category available for English-, French-, and Spanish-language relator terms. They are not loaded during upgrade but can be easily inserted using the provided marc21_relatorterms.sql SQL script (MARC21 only, and currently available for en, es, and fr only).\n";
    SetVersion($DBversion);
}

$DBversion = "3.07.00.015";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    my $sth = $dbh->prepare(q|
        SELECT COUNT(*) FROM marc_subfield_structure where kohafield="biblioitems.editionstatement"
        |);
    $sth->execute;
    my $already_exists = $sth->fetchrow;
    if ( not $already_exists ) {
        my $field = C4::Context->preference("marcflavour") eq "UNIMARC" ? "205" : "250";
        my $subfield = "a";
        my $sth = $dbh->prepare( q|
            UPDATE marc_subfield_structure SET kohafield = "biblioitems.editionstatement"
            WHERE tagfield = ? AND tagsubfield = ?
        |);
        $sth->execute( $field, $subfield );
        print "Upgrade to $DBversion done (Added a mapping for biblioitems.editionstatement.)\n";
    } else {
        print "Upgrade to $DBversion done (Added a mapping for biblioitems.editionstatement (already exists, nothing to do).)\n";
    }
    SetVersion($DBversion);
}

$DBversion = "3.07.00.016";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("ALTER TABLE items ADD KEY `itemcallnumber` (itemcallnumber)");
    print "Upgrade to $DBversion done (Added index on items.itemcallnumber)\n";
    SetVersion($DBversion);
}

$DBversion = "3.07.00.017";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('TransferWhenCancelAllWaitingHolds','0','Transfer items when cancelling all waiting holds',NULL,'YesNo')");
    print "Upgrade to $DBversion done (Add sysprefs to control transfer when cancel all waiting holds)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.07.00.018";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("CREATE TABLE pending_offline_operations ( operationid int(11) NOT NULL AUTO_INCREMENT, userid varchar(30) NOT NULL, branchcode varchar(10) NOT NULL, timestamp timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP, action varchar(10) NOT NULL, barcode varchar(20) NOT NULL, cardnumber varchar(16) DEFAULT NULL, PRIMARY KEY (operationid) ) ENGINE=MyISAM DEFAULT CHARSET=utf8;");
    print "Upgrade to $DBversion done ( adding offline operations table )\n";
    SetVersion($DBversion);
}

$DBversion = "3.07.00.019";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do(" UPDATE `systempreferences` SET  `value` =  'none', `options` =  'none|full|first|surname|firstandinitial|username', `explanation` =  'Choose how a commenter''s identity is presented alongside comments in the OPAC', `type` =  'Choice' WHERE  `systempreferences`.`variable` =  'ShowReviewer' AND `systempreferences`.`variable` = 0");
    $dbh->do(" UPDATE `systempreferences` SET  `value` =  'full', `options` =  'none|full|first|surname|firstandinitial|username', `explanation` =  'Choose how a commenter''s identity is presented alongside comments in the OPAC', `type` =  'Choice' WHERE  `systempreferences`.`variable` =  'ShowReviewer' AND `systempreferences`.`variable` = 1");
    print "Upgrade to $DBversion done ( Adding additional options for the display of commenter's identity in the OPAC: Full name, first name, last name, first name and last name first initial, username, or no information)\n";
    SetVersion($DBversion);
}

$DBversion = "3.07.00.020";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('OPACpatronimages',0,'Enable patron images in the OPAC',NULL,'YesNo');");
    print "Upgrade to $DBversion done (Bug 3516: Add the option to show patron images in the OPAC.)\n";
    SetVersion($DBversion);
}

$DBversion = "3.07.00.021";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do(
    "INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('LinkerModule','Default','Chooses which linker module to use (see documentation).','Default|FirstMatchLastMatch','Choice');"
    );
    $dbh->do(
    "INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('LinkerOptions','','A pipe-separated list of options for the linker.','','free');"
    );
    $dbh->do(
    "INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('LinkerRelink',1,'If ON the authority linker will relink headings that have previously been linked every time it runs.',NULL,'YesNo');"
    );
    $dbh->do(
    "INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('LinkerKeepStale',0,'If ON the authority linker will keep existing authority links for headings where it is unable to find a match.',NULL,'YesNo');"
    );
    $dbh->do(
    "INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('AutoCreateAuthorities',0,'Automatically create authorities that do not exist when cataloging records.',NULL,'YesNo');"
    );
    $dbh->do(
    "INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('CatalogModuleRelink',0,'If OFF the linker will never replace the authids that are set in the cataloging module.',NULL,'YesNo');"
    );
    print "Upgrade to $DBversion done (Enhancement 7284, improved authority matching, see http://wiki.koha-community.org/wiki/Bug7284_authority_matching_improvement wiki page for configuration update needed)\n";
    SetVersion($DBversion);
}

$DBversion = "3.07.00.022";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("DELETE FROM reviews WHERE biblionumber NOT IN (SELECT biblionumber from biblio)");
    $dbh->do("UPDATE reviews SET borrowernumber = NULL WHERE borrowernumber NOT IN (SELECT borrowernumber FROM borrowers)");
    $dbh->do("ALTER TABLE reviews ADD CONSTRAINT reviews_ibfk_2 FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE");
    $dbh->do("ALTER TABLE reviews ADD CONSTRAINT reviews_ibfk_1 FOREIGN KEY (borrowernumber) REFERENCES borrowers (borrowernumber ) ON UPDATE CASCADE ON DELETE SET NULL");
    print "Upgrade to $DBversion done (Bug 7493 - Add constraint linking OPAC comment biblionumber to biblio, OPAC comment borrowernumber to borrowers.)\n";
    SetVersion($DBversion);
}

$DBversion = "3.07.00.023";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE `message_transports` DROP FOREIGN KEY `message_transports_ibfk_3`");
    $dbh->do("ALTER TABLE `letter` DROP PRIMARY KEY");
    $dbh->do("ALTER TABLE `letter` ADD `branchcode` varchar(10) default NULL AFTER `code`");
    $dbh->do("ALTER TABLE `letter` ADD PRIMARY KEY  (`module`,`code`, `branchcode`)");
    $dbh->do("ALTER TABLE `message_transports` ADD `branchcode` varchar(10) NOT NULL default ''");
    $dbh->do("ALTER TABLE `message_transports` ADD CONSTRAINT `message_transports_ibfk_3` FOREIGN KEY (`letter_module`, `letter_code`, `branchcode`) REFERENCES `letter` (`module`, `code`, `branchcode`) ON DELETE CASCADE ON UPDATE CASCADE");
    $dbh->do("ALTER TABLE `letter` ADD `is_html` tinyint(1) default 0 AFTER `name`");

    $dbh->do("INSERT INTO `letter` (module, code, name, title, content, is_html)
              VALUES ('circulation','ISSUESLIP','Issue Slip','Issue Slip', '<h3><<branches.branchname>></h3>
Checked out to <<borrowers.title>> <<borrowers.firstname>> <<borrowers.initials>> <<borrowers.surname>> <br />
(<<borrowers.cardnumber>>) <br />

<<today>><br />

<h4>Checked Out</h4>
<checkedout>
<p>
<<biblio.title>> <br />
Barcode: <<items.barcode>><br />
Date due: <<issues.date_due>><br />
</p>
</checkedout>

<h4>Overdues</h4>
<overdue>
<p>
<<biblio.title>> <br />
Barcode: <<items.barcode>><br />
Date due: <<issues.date_due>><br />
</p>
</overdue>

<hr>

<h4 style=\"text-align: center; font-style:italic;\">News</h4>
<news>
<div class=\"newsitem\">
<h5 style=\"margin-bottom: 1px; margin-top: 1px\"><b><<opac_news.title>></b></h5>
<p style=\"margin-bottom: 1px; margin-top: 1px\"><<opac_news.new>></p>
<p class=\"newsfooter\" style=\"font-size: 8pt; font-style:italic; margin-bottom: 1px; margin-top: 1px\">Posted on <<opac_news.timestamp>></p>
<hr />
</div>
</news>', 1)");
    $dbh->do("INSERT INTO `letter` (module, code, name, title, content, is_html)
              VALUES ('circulation','ISSUEQSLIP','Issue Quick Slip','Issue Quick Slip', '<h3><<branches.branchname>></h3>
Checked out to <<borrowers.title>> <<borrowers.firstname>> <<borrowers.initials>> <<borrowers.surname>> <br />
(<<borrowers.cardnumber>>) <br />

<<today>><br />

<h4>Checked Out Today</h4>
<checkedout>
<p>
<<biblio.title>> <br />
Barcode: <<items.barcode>><br />
Date due: <<issues.date_due>><br />
</p>
</checkedout>', 1)");
    $dbh->do("INSERT INTO `letter` (module, code, name, title, content, is_html)
              VALUES ('circulation','RESERVESLIP','Reserve Slip','Reserve Slip', '<h5>Date: <<today>></h5>

<h3> Transfer to/Hold in <<branches.branchname>></h3>

<h3><<borrowers.surname>>, <<borrowers.firstname>></h3>

<ul>
    <li><<borrowers.cardnumber>></li>
    <li><<borrowers.phone>></li>
    <li> <<borrowers.address>><br />
         <<borrowers.address2>><br />
         <<borrowers.city >>  <<borrowers.zipcode>>
    </li>
    <li><<borrowers.email>></li>
</ul>
<br />
<h3>ITEM ON HOLD</h3>
<h4><<biblio.title>></h4>
<h5><<biblio.author>></h5>
<ul>
   <li><<items.barcode>></li>
   <li><<items.itemcallnumber>></li>
   <li><<reserves.waitingdate>></li>
</ul>
<p>Notes:
<pre><<reserves.reservenotes>></pre>
</p>', 1)");
    $dbh->do("INSERT INTO `letter` (module, code, name, title, content, is_html)
              VALUES ('circulation','TRANSFERSLIP','Transfer Slip','Transfer Slip', '<h5>Date: <<today>></h5>
<h3>Transfer to <<branches.branchname>></h3>

<h3>ITEM</h3>
<h4><<biblio.title>></h4>
<h5><<biblio.author>></h5>
<ul>
   <li><<items.barcode>></li>
   <li><<items.itemcallnumber>></li>
</ul>', 1)");

    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('NoticeCSS','','Notices CSS url.',NULL,'free')");
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('SlipCSS','','Slips CSS url.',NULL,'free')");

    $dbh->do("UPDATE `letter` SET content = replace(content, '<<title>>', '<<biblio.title>>') WHERE code = 'HOLDPLACED'");

    print "Upgrade to $DBversion done (Add branchcode and is_html to letter table; Default ISSUESLIP, RESERVESLIP and TRANSFERSLIP letters; Add NoticeCSS and SlipCSS sysprefs)\n";
    SetVersion($DBversion);
}

$DBversion = "3.07.00.024";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type) VALUES ('ExpireReservesMaxPickUpDelayCharge', '0', NULL , 'If ExpireReservesMaxPickUpDelay is enabled, and this field has a non-zero value, than a borrower whose waiting hold has expired will be charged this amount.',  'free')");
    $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type) VALUES ('ExpireReservesMaxPickUpDelay', '0', '', 'Enabling this allows holds to expire automatically if they have not been picked by within the time period specified in ReservesMaxPickUpDelay', 'YesNo')");
    print "Upgrade to $DBversion done (Added system preference ExpireReservesMaxPickUpDelay, system preference ExpireReservesMaxPickUpDelayCharge, add reseves.charge_if_expired)\n";
}

$DBversion = "3.07.00.025";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    if (TableExists('bibliocoverimage')) {
        $dbh->do( q|DROP TABLE bibliocoverimage;| );
        $dbh->do(
            q|CREATE TABLE biblioimages (
              imagenumber int(11) NOT NULL AUTO_INCREMENT,
              biblionumber int(11) NOT NULL,
              mimetype varchar(15) NOT NULL,
              imagefile mediumblob NOT NULL,
              thumbnail mediumblob NOT NULL,
              PRIMARY KEY (imagenumber),
              CONSTRAINT bibliocoverimage_fk1 FOREIGN KEY (biblionumber) REFERENCES biblio (biblionumber) ON DELETE CASCADE ON UPDATE CASCADE
              ) ENGINE=InnoDB DEFAULT CHARSET=utf8;|
        );
    }
    print "Upgrade to $DBversion done (Correct table name for local cover images if needed. )\n";
    SetVersion($DBversion);
}

$DBversion = "3.07.00.026";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('CalendarFirstDayOfWeek','Sunday','Select the first day of week to use in the calendar.','Sunday|Monday','Choice');");
    print "Upgrade to $DBversion done (Add syspref CalendarFirstDayOfWeek used to select the first day of week to use in the calendar. )\n";
    SetVersion($DBversion);
}

$DBversion = "3.07.00.027";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do(q{INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('RoutingListNote','','Define a note to be shown on all routing lists','70|10','Textarea');});
    print "Upgrade to $DBversion done (Added system preference RoutingListNote for adding a general note to all routing lists.)\n";
    SetVersion($DBversion);
}

$DBversion = "3.07.00.028";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do(qq{
    INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES ('AllowPKIAuth','None','Use the field from a client-side SSL certificate to look a user in the Koha database','None|Common Name|emailAddress','Choice');
    });
    print "Upgrade to $DBversion done (Bug 6296 New System preference AllowPKIAuth)\n";
}

$DBversion = "3.07.00.029";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do(q{DROP TABLE IF EXISTS `oai_sets_descriptions`;});
    $dbh->do(q{DROP TABLE IF EXISTS `oai_sets_mappings`;});
    $dbh->do(q{DROP TABLE IF EXISTS `oai_sets_biblios`;});
    $dbh->do(q{DROP TABLE IF EXISTS `oai_sets`;});

    $dbh->do(q{
        CREATE TABLE `oai_sets` (
          `id` int(11) NOT NULL auto_increment,
          `spec` varchar(80) NOT NULL UNIQUE,
          `name` varchar(80) NOT NULL,
          PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    });

    $dbh->do(q{
        CREATE TABLE `oai_sets_descriptions` (
          `set_id` int(11) NOT NULL,
          `description` varchar(255) NOT NULL,
          CONSTRAINT `oai_sets_descriptions_ibfk_1` FOREIGN KEY (`set_id`) REFERENCES `oai_sets` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    });

    $dbh->do(q{
        CREATE TABLE `oai_sets_mappings` (
          `set_id` int(11) NOT NULL,
          `marcfield` char(3) NOT NULL,
          `marcsubfield` char(1) NOT NULL,
          `marcvalue` varchar(80) NOT NULL,
          CONSTRAINT `oai_sets_mappings_ibfk_1` FOREIGN KEY (`set_id`) REFERENCES `oai_sets` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    });

    $dbh->do(q{
        CREATE TABLE `oai_sets_biblios` (
          `biblionumber` int(11) NOT NULL,
          `set_id` int(11) NOT NULL,
          PRIMARY KEY (`biblionumber`, `set_id`),
          CONSTRAINT `oai_sets_biblios_ibfk_1` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE,
          CONSTRAINT `oai_sets_biblios_ibfk_2` FOREIGN KEY (`set_id`) REFERENCES `oai_sets` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    });

    $dbh->do(q{
        INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('OAI-PMH:AutoUpdateSets','0','Automatically update OAI sets when a bibliographic record is created or updated','','YesNo');
    });

    print "Upgrade to $DBversion done (Atomic update for OAI-PMH sets management)\n";
    SetVersion($DBversion);
}

$DBversion = "3.07.00.030";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("ALTER TABLE default_circ_rules ADD
            COLUMN `returnbranch` varchar(15) default NULL AFTER `holdallowed`");
    $dbh->do("ALTER TABLE branch_item_rules ADD
            COLUMN `returnbranch` varchar(15) default NULL AFTER `holdallowed`");
    $dbh->do("ALTER TABLE default_branch_circ_rules ADD
            COLUMN `returnbranch` varchar(15) default NULL AFTER `holdallowed`");
    $dbh->do("ALTER TABLE default_branch_item_rules ADD
            COLUMN `returnbranch` varchar(15) default NULL AFTER `holdallowed`");
    # set the default rule to the current value of HomeOrHoldingBranchReturn (default to 'homebranch' if need be)
    my $homeorholdingbranchreturn = C4::Context->preference('HomeOrHoldingBranchReturn') || 'homebranch';
    $dbh->do("UPDATE default_circ_rules SET returnbranch = '$homeorholdingbranchreturn'");
    print "Upgrade to $DBversion done (Atomic update for OAI-PMH sets management)\n";
    SetVersion($DBversion);
}

$DBversion = "3.07.00.031";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('UseICU', '1', 'Tell Koha if ICU indexing is in use for Zebra or not.','1','YesNo')");
    print "Upgrade to $DBversion done (Add syspref to tell Koha if ICU indexing is in use for Zebra or not.)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.07.00.032";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("ALTER TABLE virtualshelves MODIFY COLUMN owner int"); #should have been int already (fk to borrowers)
    $dbh->do("UPDATE virtualshelves vi LEFT JOIN borrowers bo ON bo.borrowernumber=vi.owner SET vi.owner=NULL where bo.borrowernumber IS NULL"); #before adding the constraint on borrowernumber, we need to get rid of deleted owners
    $dbh->do("DELETE FROM virtualshelves WHERE owner IS NULL and category=1"); #delete private lists without owner (cascades to shelfcontents)
    $dbh->do("ALTER TABLE virtualshelves ADD COLUMN allow_add tinyint(1) DEFAULT 0, ADD COLUMN allow_delete_own tinyint(1) DEFAULT 1, ADD COLUMN allow_delete_other tinyint(1) DEFAULT 0, ADD CONSTRAINT `virtualshelves_ibfk_1` FOREIGN KEY (`owner`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE SET NULL");
    $dbh->do("UPDATE virtualshelves SET allow_add=0, allow_delete_own=1, allow_delete_other=0 WHERE category=1");
    $dbh->do("UPDATE virtualshelves SET allow_add=0, allow_delete_own=1, allow_delete_other=0 WHERE category=2");
    $dbh->do("UPDATE virtualshelves SET allow_add=1, allow_delete_own=1, allow_delete_other=1 WHERE category=3");
    $dbh->do("UPDATE virtualshelves SET category=2 WHERE category=3");

    $dbh->do("ALTER TABLE virtualshelfcontents ADD COLUMN borrowernumber int, ADD CONSTRAINT `shelfcontents_ibfk_3` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE SET NULL");
    $dbh->do("UPDATE virtualshelfcontents co LEFT JOIN virtualshelves sh USING (shelfnumber) SET co.borrowernumber=sh.owner");

    $dbh->do("CREATE TABLE virtualshelfshares
    (id int AUTO_INCREMENT PRIMARY KEY, shelfnumber int NOT NULL,
    borrowernumber int, invitekey varchar(10), sharedate datetime,
    CONSTRAINT `virtualshelfshares_ibfk_1` FOREIGN KEY (`shelfnumber`) REFERENCES `virtualshelves` (`shelfnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
        CONSTRAINT `virtualshelfshares_ibfk_2` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE SET NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8");

    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('OpacAllowPublicListCreation',1,'If set, allows opac users to create public lists',NULL,'YesNo');");
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('OpacAllowSharingPrivateLists',0,'If set, allows opac users to share private lists with other patrons',NULL,'YesNo');");

    print "Upgrade to $DBversion done (BZ7310: Improving list permissions)\n";
    SetVersion($DBversion);
}

$DBversion = "3.07.00.033";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE branches ADD opac_info text;");
    print "Upgrade to $DBversion done add opac_info to branches \n";
    SetVersion($DBversion);
}

$DBversion = "3.07.00.034";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE borrower_attribute_types ADD COLUMN category_code VARCHAR(10) NULL DEFAULT NULL AFTER `display_checkout`");
    $dbh->do("ALTER TABLE borrower_attribute_types ADD COLUMN class VARCHAR(255)  NOT NULL DEFAULT '' AFTER `category_code`");
    $dbh->do("ALTER TABLE borrower_attribute_types ADD CONSTRAINT category_code_fk FOREIGN KEY (category_code) REFERENCES categories(categorycode)");
    print "Upgrade to $DBversion done (New fields category_code and class in borrower_attribute_types table)\n";
    SetVersion($DBversion);
}

$DBversion = "3.07.00.035";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("ALTER TABLE issues CHANGE date_due date_due datetime");
    $dbh->do("UPDATE issues SET date_due = CONCAT(SUBSTR(date_due,1,11),'23:59:00')");
    $dbh->do("ALTER TABLE issues CHANGE returndate returndate datetime");
    $dbh->do("ALTER TABLE issues CHANGE lastreneweddate lastreneweddate datetime");
    $dbh->do("ALTER TABLE issues CHANGE issuedate issuedate datetime");
    $dbh->do("ALTER TABLE old_issues CHANGE date_due date_due datetime");
    $dbh->do("ALTER TABLE old_issues CHANGE returndate returndate datetime");
    $dbh->do("ALTER TABLE old_issues CHANGE lastreneweddate lastreneweddate datetime");
    $dbh->do("ALTER TABLE old_issues CHANGE issuedate issuedate datetime");
    $dbh->do("UPDATE accountlines SET description = CONCAT(description,' 23:59') WHERE accounttype='F' OR accounttype='FU'"); #BUG-8253
    print "Upgrade to $DBversion done (Setting up issues and accountlines tables for hourly loans)\n";
    SetVersion($DBversion);
}

$DBversion = "3.07.00.036";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do(qq{
       ALTER TABLE z3950servers ADD timeout INT( 11 ) NOT NULL DEFAULT '0' AFTER syntax;
    });
    print "Upgrade to $DBversion done (New timeout field in z3950servers)\n";
}

$DBversion = "3.07.00.037";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("
       ALTER TABLE  `marc_subfield_structure` ADD  `maxlength` INT( 4 ) NOT NULL DEFAULT  '9999';
       ");
       $dbh->do("
       UPDATE `marc_subfield_structure` SET maxlength=24 WHERE tagfield='000';
       ");
       $dbh->do("
       UPDATE marc_subfield_structure SET maxlength = IF ((SELECT value FROM systempreferences WHERE variable = 'marcflavour')='MARC21','40','9999') WHERE tagfield='008';
       ");
       $dbh->do("
       UPDATE marc_subfield_structure SET maxlength = IF ((SELECT value FROM systempreferences WHERE variable = 'marcflavour')='NORMARC','40','9999') WHERE tagfield='008';
       ");
       $dbh->do("
       UPDATE marc_subfield_structure SET maxlength = IF ((SELECT value FROM systempreferences WHERE variable = 'marcflavour')='UNIMARC','36','9999') WHERE tagfield='100';
       ");
    print "Upgrade to $DBversion done (Add new field maxlength to marc_subfield_structure)\n";
    SetVersion($DBversion);
}

$DBversion = "3.07.00.038";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do(qq{
        INSERT INTO systempreferences(variable,value,explanation,options,type)
        VALUES('UniqueItemFields', 'barcode', 'Space-separated list of fields that should be unique (used in acquisition module for item creation). Fields must be valid SQL column names of items table', '', 'Free')
    });
    print "Upgrade to $DBversion done (Added system preference 'UniqueItemFields')\n";
    SetVersion($DBversion);
}

$DBversion = "3.07.00.039";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do( qq{INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES('Babeltheque_url_js','','Url for Babeltheque javascript (e.g. http://www.babeltheque.com/bw_XX.js','','Free')} );
    $dbh->do( qq{CREATE TABLE IF NOT EXISTS social_data
      ( isbn VARCHAR(30),
        num_critics INT,
        num_critics_pro INT,
        num_quotations INT,
        num_videos INT,
        score_avg DECIMAL(5,2),
        num_scores INT,
        PRIMARY KEY  (isbn)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8
    } );
    $dbh->do( qq{INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES ('Babeltheque_url_update', '', 'Url for Babeltheque update (E.G. http://www.babeltheque.com/.../file.csv.bz2)', '', 'Free')} );
    print "Upgrade to $DBversion done (added syspref and table for babeltheque (Babeltheque_url_js, babeltheque))\n";
    SetVersion($DBversion);
}

$DBversion = "3.07.00.040";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do( qq{INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES('SocialNetworks','0','Enable/Disable social networks links in opac detail','','YesNo')} );
    print "Upgrade to $DBversion done (added syspref SocialNetworks, to display facebook/ggl+ and other buttons)\n";
    SetVersion($DBversion);
}



$DBversion = "3.07.00.041";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type) VALUES('SubscriptionDuplicateDroppedInput','','','List of fields which must not be rewritten when a subscription is duplicated (Separated by pipe |)','Free')");
    print "Upgrade to $DBversion done (Add system preference SubscriptionDuplicateDroppedInput)\n";
    SetVersion($DBversion);
}

$DBversion = "3.07.00.042";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE reserves ADD suspend BOOLEAN NOT NULL DEFAULT 0");
    $dbh->do("ALTER TABLE old_reserves ADD suspend BOOLEAN NOT NULL DEFAULT 0");

    $dbh->do("ALTER TABLE reserves ADD suspend_until DATETIME NULL DEFAULT NULL");
    $dbh->do("ALTER TABLE old_reserves ADD suspend_until DATETIME NULL DEFAULT NULL");

    $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type) VALUES ('AutoResumeSuspendedHolds',  '1', NULL ,  'Allow suspended holds to be automatically resumed by a set date.',  'YesNo')");

    print "Upgrade to $DBversion done (Add suspend fields to reserves table, add syspref AutoResumeSuspendedHolds)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.07.00.043";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    my $countXSLTDetailsDisplay = 0;
    my $valueXSLTDetailsDisplay = "";
    my $valueXSLTResultsDisplay = "";
    my $valueOPACXSLTDetailsDisplay = "";
    my $valueOPACXSLTResultsDisplay = "";
    #the line below test if database comes from a BibLibre's branch
    $countXSLTDetailsDisplay = $dbh->do('SELECT 1 FROM systempreferences WHERE variable="IntranetXSLTDetailsDisplay"');
    if ($countXSLTDetailsDisplay > 0)
    {
        #the two lines below will only be used to update the databases from the BibLibre's branch. They will not affect the others
        $dbh->do(q|UPDATE systempreferences SET variable="XSLTDetailsDisplay" WHERE variable="IntranetXSLTDetailsDisplay"|);
        $dbh->do(q|UPDATE systempreferences SET variable="XSLTResultsDisplay" WHERE variable="IntranetXSLTResultsDisplay"|);
    }
    else
    {
        $valueXSLTDetailsDisplay = "default" if (C4::Context->preference("XSLTDetailsDisplay"));
        $valueXSLTResultsDisplay = "default" if (C4::Context->preference("XSLTResultsDisplay"));
        $valueOPACXSLTDetailsDisplay = "default" if (C4::Context->preference("OPACXSLTDetailsDisplay"));
        $valueOPACXSLTResultsDisplay = "default" if (C4::Context->preference("OPACXSLTResultsDisplay"));
        $dbh->do("UPDATE systempreferences SET type='Free', value=\"$valueXSLTDetailsDisplay\" WHERE variable='XSLTDetailsDisplay'");
        $dbh->do("UPDATE systempreferences SET type='Free', value=\"$valueXSLTResultsDisplay\" WHERE variable='XSLTResultsDisplay'");
        $dbh->do("UPDATE systempreferences SET type='Free', value=\"$valueOPACXSLTDetailsDisplay\" WHERE variable='OPACXSLTDetailsDisplay'");
        $dbh->do("UPDATE systempreferences SET type='Free', value=\"$valueOPACXSLTResultsDisplay\" WHERE variable='OPACXSLTResultsDisplay'");
    }
    print "Upgrade to $DBversion done (XSLT systempreference takes a path to file rather than YesNo)\n";
    SetVersion($DBversion);
}

$DBversion = "3.07.00.044";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("ALTER TABLE aqbooksellers ADD deliverytime INT DEFAULT NULL");
    print "Upgrade to $DBversion done (Add deliverytime field in aqbooksellers table)";
    SetVersion($DBversion);
}

$DBversion = "3.07.00.045";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE import_batches MODIFY COLUMN batch_type ENUM('batch','z3950','webservice') NOT NULL default 'batch'");
    print "Upgrade to $DBversion done (Add 'webservice' to batch_type enum)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.07.00.046";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("ALTER TABLE issuingrules ADD COLUMN lengthunit varchar(10) DEFAULT 'days' AFTER issuelength");
    print "Upgrade to $DBversion done (Setting up issues tables for hourly loans (lengthunit fix))\n";
    SetVersion($DBversion);
}

$DBversion = "3.07.00.047";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("CREATE INDEX items_location ON items(location)");
    $dbh->do("CREATE INDEX items_ccode ON items(ccode)");
    print "Upgrade to $DBversion done (items_location and items_ccode indexes added for ShelfBrowser)\n";
    SetVersion($DBversion);
}

$DBversion = "3.07.00.048";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do(
        q | CREATE TABLE ratings (
  borrowernumber int(11) NOT NULL,
  biblionumber int(11) NOT NULL,
  rating_value tinyint(1) NOT NULL,
  timestamp timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY  (borrowernumber,biblionumber),
  CONSTRAINT ratings_ibfk_1 FOREIGN KEY (borrowernumber) REFERENCES borrowers (borrowernumber) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT ratings_ibfk_2 FOREIGN KEY (biblionumber) REFERENCES biblio (biblionumber) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 |
    );

    $dbh->do(
q /INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('OpacStarRatings','disable',NULL,'disable|all|details','Choice') /
    );

    print
"Upgrade to $DBversion done (Add 'ratings' table and 'OpacStarRatings' syspref)\n";
    SetVersion($DBversion);
}

$DBversion = "3.07.00.049";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('OpacBrowseResults','1','Disable/enable browsing and paging search results from the OPAC detail page.',NULL,'YesNo')");
    print "Upgrade to $DBversion done (Add system preference OpacBrowseResults ))\n";
    SetVersion($DBversion);
}

$DBversion = "3.08.00.000";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    print "Upgrade to $DBversion done\n";
    SetVersion($DBversion);
}

$DBversion = "3.09.00.001";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("ALTER TABLE borrower_attribute_types MODIFY category_code VARCHAR( 1 ) NULL DEFAULT NULL");
    print "Upgrade to $DBversion done. (Bug 8002: Update patron attribute types table to allow NULL category_code)\n";
    SetVersion($DBversion);
}

$DBversion = "3.09.00.002";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("ALTER TABLE saved_sql
        ADD (
            cache_expiry INT NOT NULL DEFAULT 300,
            public BOOLEAN NOT NULL DEFAULT FALSE
        );
    ");
    print "Upgrade to $DBversion done (Added cache_expiry and public fields in
saved_reports table.)\n";
    SetVersion($DBversion);
}

$DBversion = "3.09.00.003";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('SvcMaxReportRows','10','Maximum number of rows to return via the report web service.',NULL,'Integer');");
    print "Upgrade to $DBversion done (Added SvcMaxReportRows syspref)\n";
    SetVersion($DBversion);
}

$DBversion = "3.09.00.004";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("INSERT IGNORE INTO permissions (module_bit, code, description) VALUES('13', 'edit_patrons', 'Perform batch modifivation of patrons')");
    print "Upgrade to $DBversion done (Adds permissions flag for access to the patron modifications tool)\n";
    SetVersion($DBversion);
}

$DBversion = "3.09.00.005";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    unless (TableExists('quotes')) {
        $dbh->do( qq{
            CREATE TABLE `quotes` (
              `id` int(11) NOT NULL AUTO_INCREMENT,
              `source` text DEFAULT NULL,
              `text` mediumtext NOT NULL,
              `timestamp` datetime NOT NULL,
              PRIMARY KEY (`id`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8
        });
    }
    $dbh->do( qq{
        INSERT IGNORE INTO permissions VALUES (13, "edit_quotes","Edit quotes for quote-of-the-day feature");
    });
    $dbh->do( qq{
        INSERT IGNORE INTO `systempreferences` (variable,value,explanation,options,type) VALUES('QuoteOfTheDay',0,'Enable or disable display of Quote of the Day on the OPAC home page',NULL,'YesNo');
    });
    print "Upgrade to $DBversion done (Adding Quote of the Day Option.)\n";
    SetVersion($DBversion);
}

$DBversion = "3.09.00.006";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("UPDATE systempreferences SET
                variable = 'OPACShowHoldQueueDetails',
                value = CASE value WHEN '1' THEN 'priority' ELSE 'none' END,
                options = 'none|priority|holds|holds_priority',
                explanation = 'Show holds details in OPAC',
                type = 'Choice'
              WHERE variable = 'OPACDisplayRequestPriority'");
    print "Upgrade to $DBversion done (Changed system preference OPACDisplayRequestPriority -> OPACShowHoldQueueDetails)\n";
    SetVersion($DBversion);
}

$DBversion = "3.09.00.007";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    unless(C4::Context->preference('ReservesControlBranch')){
        $dbh->do("INSERT INTO `systempreferences` (variable,value,options,explanation,type) VALUES ('ReservesControlBranch','PatronLibrary','ItemHomeLibrary|PatronLibrary','Branch checked for members reservations rights.','Choice')");
    }
    print "Upgrade to $DBversion done (Insert ReservesControlBranch systempreference into systempreferences table )\n";
    SetVersion($DBversion);
}

$DBversion = "3.09.00.008";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE sessions ADD PRIMARY KEY (id);");
    $dbh->do("ALTER TABLE sessions DROP INDEX `id`;");
    print "Upgrade to $DBversion done (redefine the field id as PRIMARY KEY of sessions)\n";
    SetVersion($DBversion);
}

$DBversion = "3.09.00.009";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE branches ADD PRIMARY KEY (branchcode);");
    $dbh->do("ALTER TABLE branches DROP INDEX branchcode;");
    print "Upgrade to $DBversion done (redefine the field branchcode as PRIMARY KEY of branches)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.09.00.010";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('IssueLostItem', 'alert', 'alert|confirm|nothing', 'Defines what should be done when an attempt is made to issue an item that has been marked as lost.', 'Choice')");
    print "Upgrade to $DBversion done (Add system preference issuelostitem ))\n";
    SetVersion($DBversion);
}

$DBversion = "3.09.00.011";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("ALTER TABLE `biblioitems` ADD `ean` VARCHAR( 13 ) NULL AFTER issn");
    $dbh->do("CREATE INDEX `ean` ON biblioitems (`ean`) ");
    $dbh->do("ALTER TABLE `deletedbiblioitems` ADD `ean` VARCHAR( 13 ) NULL AFTER issn");
    if (C4::Context->preference("marcflavour") eq 'UNIMARC') {
         $dbh->do("UPDATE marc_subfield_structure SET kohafield='biblioitems.ean' WHERE tagfield='073' and tagsubfield='a'");
    }
    print "Upgrade to $DBversion done (Adding ean in biblioitems and deletedbiblioitems)\n";
    print "If you have records with ean, please run misc/batchRebuildBiblioTables.pl to populate bibliotems.ean\n" if (C4::Context->preference("marcflavour") eq 'UNIMARC');
    SetVersion($DBversion);
}

$DBversion = "3.09.00.012";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('SuspendHoldsIntranet', '1', NULL , 'Allow holds to be suspended from the intranet.', 'YesNo')");
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('SuspendHoldsOpac', '1', NULL , 'Allow holds to be suspended from the OPAC.', 'YesNo')");
    print "Upgrade to $DBversion done (Add system preference OpacBrowseResults ))\n";
    SetVersion($DBversion);
}

$DBversion ="3.09.00.013";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('DefaultLanguageField008','','Fill in the default language for field 008 Range 35-37 (e.g. eng, nor, ger, see www.loc.gov/marc/languages/language_code.html)','','Free');");
    print "Upgrade to $DBversion done (Add system preference DefaultLanguageField008))\n";
    SetVersion($DBversion);
}

$DBversion ="3.09.00.014";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    # add phone message transport type
    $dbh->do("INSERT INTO message_transport_types (message_transport_type) VALUES ('phone')");

    # adds HOLD_PHONE and PREDUE_PHONE letters (as placeholders)
    $dbh->do("INSERT INTO letter (module, code, name, title, content) VALUES
              ('reserves', 'HOLD_PHONE', 'Item Available for Pick-up (phone notice)', 'Item Available for Pick-up (phone notice)', 'Your item is available for pickup'),
              ('circulation', 'PREDUE_PHONE', 'Advance Notice of Item Due (phone notice)', 'Advance Notice of Item Due (phone notice)', 'Your item is due soon'),
              ('circulation', 'OVERDUE_PHONE', 'Overdue Notice (phone notice)', 'Overdue Notice (phone notice)', 'Your item is overdue')
              ");

    # add phone notifications to patron message preferences options
    $dbh->do("INSERT INTO message_transports
             (message_attribute_id, message_transport_type, is_digest, letter_module, letter_code) VALUES
             (4, 'phone', 0, 'reserves', 'HOLD_PHONE'),
             (2, 'phone', 0, 'circulation', 'PREDUE_PHONE')
             ");

    # add TalkingTechItivaPhoneNotification syspref
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('TalkingTechItivaPhoneNotification',0,'If ON, enables Talking Tech I-tiva phone notifications',NULL,'YesNo');");

    print "Upgrade done (Support for Talking Tech i-tiva phone notification system)\n";
    SetVersion($DBversion);
}

$DBversion = "3.09.00.015";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do(qq{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES('StatisticsFields','location|itype|ccode','Define Fields (from the items table) used for statistics members','location|itype|ccode','free')
    });
    print "Upgrade to $DBversion done (Add System preference StatisticsFields)\n";
    SetVersion($DBversion);
}

$DBversion = "3.09.00.016";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('OPACShowBarcode','0','Show items barcode in holding tab','','YesNo')");
    print "Upgrade to $DBversion done (Add syspref OPACShowBarcode)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.09.00.017";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type) VALUES ('OpacNavRight', '', '70|10', 'Show the following HTML in the right hand column of the main page under the main login form', 'Textarea');");
    print "Upgrade to $DBversion done (Add customizable OpacNavRight region to the OPAC main page)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.09.00.018";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("DROP TABLE IF EXISTS aqbudgetborrowers");
    $dbh->do("
        CREATE TABLE aqbudgetborrowers (
          budget_id int(11) NOT NULL,
          borrowernumber int(11) NOT NULL,
          PRIMARY KEY (budget_id, borrowernumber),
          CONSTRAINT aqbudgetborrowers_ibfk_1 FOREIGN KEY (budget_id)
            REFERENCES aqbudgets (budget_id)
            ON DELETE CASCADE ON UPDATE CASCADE,
          CONSTRAINT aqbudgetborrowers_ibfk_2 FOREIGN KEY (borrowernumber)
            REFERENCES borrowers (borrowernumber)
            ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    ");
    $dbh->do("
        INSERT INTO permissions (module_bit, code, description)
        VALUES (11, 'budget_manage_all', 'Manage all budgets')
    ");
    print "Upgrade to $DBversion done (Add aqbudgetborrowers table)\n";
    SetVersion($DBversion);
}

$DBversion = "3.09.00.019";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type) VALUES ('OPACShowUnusedAuthorities','1','','Show authorities that are not being used in the OPAC.','YesNo')");
    print "Upgrade to $DBversion done (Add OPACShowUnusedAuthorities system preference)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.09.00.020";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,type) VALUES('EnableBorrowerFiles','0','If enabled, allows librarians to upload and attach arbitrary files to a borrower record.','YesNo')");
    $dbh->do("
CREATE TABLE IF NOT EXISTS borrower_files (
  file_id int(11) NOT NULL AUTO_INCREMENT,
  borrowernumber int(11) NOT NULL,
  file_name varchar(255) NOT NULL,
  file_type varchar(255) NOT NULL,
  file_description varchar(255) DEFAULT NULL,
  file_content longblob NOT NULL,
  date_uploaded timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (file_id),
  KEY borrowernumber (borrowernumber)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;
    ");
    $dbh->do("ALTER TABLE borrower_files ADD CONSTRAINT borrower_files_ibfk_1 FOREIGN KEY (borrowernumber) REFERENCES borrowers (borrowernumber) ON DELETE CASCADE ON UPDATE CASCADE");

    print "Upgrade to $DBversion done (Added borrow_files table, EnableBorrowerFiles syspref)\n";
    SetVersion($DBversion);
}

$DBversion = "3.09.00.021";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('UpdateTotalIssuesOnCirc','0','Whether to update the totalissues field in the biblio on each circ.',NULL,'YesNo');");
    print "Upgrade to $DBversion done (Add syspref UpdateTotalIssuesOnCirc)\n";
    SetVersion($DBversion);
}

$DBversion = "3.09.00.022";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE search_history MODIFY COLUMN query_cgi text NOT NULL");
    print "Upgrade to $DBversion done (Change search_history.query_cgi type to text. bug 5981)\n";
    SetVersion($DBversion);
}

$DBversion = "3.09.00.023";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES('SearchEngine','Zebra','Solr|Zebra','Search Engine','Choice')");
    print "Upgrade to $DBversion done (Add system preference SearchEngine )\n";
    SetVersion($DBversion);
}

$DBversion ="3.09.00.024";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('IntranetSlipPrinterJS','','Use this JavaScript for printing slips. Define at least function printThenClose(). For use e.g. with Firefox PlugIn jsPrintSetup, see http://jsprintsetup.mozdev.org/','','Free')");
    print "Upgrade to $DBversion done (Add system preference IntranetSlipPrinterJS))\n";
    SetVersion($DBversion);
}

$DBversion = "3.09.00.025";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do('START TRANSACTION');
    $dbh->do('CREATE TABLE tmp_reserves AS SELECT * FROM old_reserves LIMIT 0');
    $dbh->do('ALTER TABLE tmp_reserves ADD reserve_id INT( 11 ) NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST');
    $dbh->do("
        INSERT INTO tmp_reserves (
          borrowernumber, reservedate, biblionumber,
          constrainttype, branchcode, notificationdate,
          reminderdate, cancellationdate, reservenotes,
          priority, found, timestamp, itemnumber,
          waitingdate, expirationdate, lowestPriority,
          suspend, suspend_until
        ) SELECT
          borrowernumber, reservedate, biblionumber,
          constrainttype, branchcode, notificationdate,
          reminderdate, cancellationdate, reservenotes,
          priority, found, timestamp, itemnumber,
          waitingdate, expirationdate, lowestPriority,
          suspend, suspend_until
        FROM old_reserves ORDER BY reservedate
    ");
    $dbh->do('SET @ai = ( SELECT MAX( reserve_id ) FROM tmp_reserves )');
    $dbh->do('TRUNCATE old_reserves');
    $dbh->do('ALTER TABLE old_reserves ADD reserve_id INT( 11 ) NOT NULL PRIMARY KEY FIRST');
    $dbh->do('INSERT INTO old_reserves SELECT * FROM tmp_reserves WHERE reserve_id <= @ai');
    $dbh->do("
        INSERT INTO tmp_reserves (
          borrowernumber, reservedate, biblionumber,
          constrainttype, branchcode, notificationdate,
          reminderdate, cancellationdate, reservenotes,
          priority, found, timestamp, itemnumber,
          waitingdate, expirationdate, lowestPriority,
          suspend, suspend_until
        ) SELECT
          borrowernumber, reservedate, biblionumber,
          constrainttype, branchcode, notificationdate,
          reminderdate, cancellationdate, reservenotes,
          priority, found, timestamp, itemnumber,
          waitingdate, expirationdate, lowestPriority,
          suspend, suspend_until
        FROM reserves ORDER BY reservedate
    ");
    $dbh->do('TRUNCATE reserves');
    $dbh->do('ALTER TABLE reserves ADD reserve_id INT( 11 ) NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST');
    $dbh->do('INSERT INTO reserves SELECT * FROM tmp_reserves WHERE reserve_id > COALESCE(@ai, 0)');
    $dbh->do('DROP TABLE tmp_reserves');
    $dbh->do('COMMIT');

    my $sth = $dbh->prepare("
        SELECT COUNT( * ) AS count
        FROM information_schema.COLUMNS
        WHERE COLUMN_NAME =  'reserve_id'
        AND (
          TABLE_NAME LIKE  'reserves'
          OR
          TABLE_NAME LIKE  'old_reserves'
        )
    ");
    $sth->execute();
    my $row = $sth->fetchrow_hashref();
    die("Failed to add reserve_id to reserves tables, please refresh the page to try again.") unless ( $row->{'count'} );

    print "Upgrade to $DBversion done (add reserve_id to reserves & old_reserves tables)\n";
    SetVersion($DBversion);
}

$DBversion = "3.09.00.026";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("INSERT INTO permissions (module_bit, code, description) VALUES
        ( 3, 'parameters_remaining_permissions', 'Remaining system parameters permissions'),
        ( 3, 'manage_circ_rules', 'manage circulation rules')");
    $dbh->do("INSERT INTO user_permissions (borrowernumber, module_bit, code)
        SELECT borrowernumber, 3, 'parameters_remaining_permissions'
        FROM borrowers WHERE flags & (1 << 3)");
    # Give new subpermissions to all users that have 'parameters' permission flag (bit 3) set
    # see userflags table
    $dbh->do("INSERT INTO user_permissions (borrowernumber, module_bit, code)
        SELECT borrowernumber, 3, 'manage_circ_rules'
        FROM borrowers WHERE flags & (1 << 3)");
    print "Upgrade to $DBversion done (Added parameters subpermissions)\n";
    SetVersion($DBversion);
}

$DBversion = '3.09.00.027';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE issuingrules ADD overduefinescap decimal(28,6) DEFAULT NULL");
    my $maxfine = C4::Context->preference('MaxFine');
    if ($maxfine && $maxfine < 900) { # an arbitrary value that tells us it's not "some huge value"
      $dbh->do("UPDATE issuingrules SET overduefinescap=?",undef,$maxfine);
      $dbh->do("UPDATE systempreferences SET value = NULL WHERE variable = 'MaxFine'");
    }
    $dbh->do("UPDATE systempreferences SET explanation = 'Maximum fine a patron can have for all late returns at one moment. Single item caps are specified in the circulation rules matrix.' WHERE variable = 'MaxFine'");
    print "Upgrade to $DBversion done (Bug 7420 add overduefinescap to circulation matrix)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.09.00.028";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    unless ( C4::Context->preference('marcflavour') eq 'UNIMARC' ) {
        my %referencetypes = (  '00' => 'PERSO_NAME',
                                '10' => 'CORPO_NAME',
                                '11' => 'MEETI_NAME',
                                '30' => 'UNIF_TITLE',
                                '48' => 'CHRON_TERM',
                                '50' => 'TOPIC_TERM',
                                '51' => 'GEOGR_NAME',
                                '55' => 'GENRE/FORM'
                );
        my $query = q{SELECT DISTINCT authtypecode, tagfield
                    FROM auth_subfield_structure
                    WHERE (tagfield BETWEEN '400' AND '455' OR
                    tagfield BETWEEN '500' and '555') AND tagsubfield='a' AND
                    frameworkcode = '' AND ROW(authtypecode, tagfield) NOT IN
                    (SELECT authtypecode, tagfield FROM auth_subfield_structure
                    WHERE tagsubfield ='9' )};
        $sth = $dbh->prepare($query);
        $sth->execute;
        my $sth2 = $dbh->prepare(q{INSERT INTO auth_subfield_structure
                (authtypecode, tagfield, tagsubfield, liblibrarian, libopac,
                 repeatable, mandatory, tab, authorised_value, value_builder,
                 seealso, isurl, hidden, linkid, kohafield, frameworkcode)
                VALUES (?, ?, '9', '9 (RLIN)', '9 (RLIN)', 0, 0, ?, NULL, NULL,
                    NULL, 0, 1, '', '', '')});
        my $sth3 = $dbh->prepare(q{UPDATE auth_subfield_structure SET
                                    frameworkcode = ? WHERE authtypecode = ? AND
                                    tagfield = ? AND tagsubfield = 'a'});
        while (my $row = $sth->fetchrow_arrayref()) {
            my ($authtypecode, $field) = @$row;
            $sth2->execute($authtypecode, $field, substr($field, 0, 1));
            my $authtypemarker = substr $field, 1, 2;
            if ($authtypemarker && $referencetypes{$authtypemarker}) {
                $sth3->execute($referencetypes{$authtypemarker}, $authtypecode, $field);
            }
        }
    }

    print "Upgrade to $DBversion done (Add thesaurus links for MARC21/NORMARC)\n";
    SetVersion($DBversion);
}

$DBversion = "3.09.00.029"; # FIXME
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("UPDATE systempreferences SET options=concat(options,'|EAN13') WHERE variable='itemBarcodeInputFilter' AND options NOT LIKE '%EAN13%'");
    print "Upgrade to $DBversion done (Add itemBarcodeInputFilter choice EAN13)\n";

    $dbh->do("UPDATE systempreferences SET options = concat(options,'|EAN13'), explanation = concat(explanation,'; EAN13 - incremental') WHERE variable = 'autoBarcode' AND options NOT LIKE '%EAN13%'");
    print "Upgrade to $DBversion done ( Added EAN13 barcode autogeneration sequence )\n";
    SetVersion($DBversion);
}

$DBversion ="3.09.00.030";
if(C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    my $query = "SELECT value FROM systempreferences WHERE variable='opacstylesheet'";
    my $remote= $dbh->selectrow_arrayref($query);
    $dbh->do("DELETE from systempreferences WHERE variable='opacstylesheet'");
    if($remote && $remote->[0]) {
        $query="UPDATE systempreferences SET value=? WHERE variable='opaclayoutstylesheet'";
        $dbh->do($query,undef,$remote->[0]);
        print "NOTE: The URL of your remote opac css file has been moved to preference opaclayoutstylesheet.\n";
    }
    print "Upgrade to $DBversion done (BZ 8263: Make OPAC stylesheet preferences more consistent)\n";
    SetVersion($DBversion);
}

$DBversion = "3.09.00.031";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("DELETE FROM systempreferences WHERE variable='AmazonReviews'");
    $dbh->do("DELETE FROM systempreferences WHERE variable='AmazonSimilarItems'");
    $dbh->do("DELETE FROM systempreferences WHERE variable='AWSAccessKeyID'");
    $dbh->do("DELETE FROM systempreferences WHERE variable='AWSPrivateKey'");
    $dbh->do("DELETE FROM systempreferences WHERE variable='OPACAmazonReviews'");
    $dbh->do("DELETE FROM systempreferences WHERE variable='OPACAmazonSimilarItems'");
    $dbh->do("DELETE FROM systempreferences WHERE variable='AmazonEnabled'");
    $dbh->do("DELETE FROM systempreferences WHERE variable='OPACAmazonEnabled'");
    print "Upgrade to $DBversion done ('Remove preferences controlling broken Amazon features (Bug 8679')\n";
    SetVersion ($DBversion);
}

$DBversion = "3.09.00.032";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("UPDATE systempreferences SET value = 'call_number' WHERE variable = 'defaultSortField' AND value = 'callnumber'");
    $dbh->do("UPDATE systempreferences SET value = 'call_number' WHERE variable = 'OPACdefaultSortField' AND value = 'callnumber'");
    print "Upgrade to $DBversion done (Bug 8657 - Default sort by call number does not work. Correcting system preference value.)\n";
    SetVersion ($DBversion);
}


$DBversion = '3.09.00.033';
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
   $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('OpacSuppressionByIPRange','','Restrict the suppression to IP adresses outside of the IP range','','free');");
   print "Upgrade to $DBversion done (Add OpacSuppressionByIPRange syspref)\n";
   SetVersion ($DBversion);
}

$DBversion ="3.09.00.034";
if(C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("UPDATE auth_subfield_structure SET frameworkcode = 'PERSO_NAME' WHERE frameworkcode = 'PERSO_CODE'");
    $dbh->do("UPDATE auth_subfield_structure SET frameworkcode = 'CORPO_NAME' WHERE frameworkcode = 'ORGO_CODE'");
    print "Upgrade to $DBversion done (Bug 8207: correct typo in authority types)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.09.00.035";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("
    INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES('PrefillItem','0','When a new item is added, should it be prefilled with last created item values?','','YesNo');
    ");
    $dbh->do(
    "INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('SubfieldsToUseWhenPrefill','','Define a list of subfields to use when prefilling items (separated by space)','','Free');
    ");
    print "Upgrade to $DBversion done (Adding PrefillItem and SubfieldsToUseWhenPrefill sysprefs)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.09.00.036";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    # biblioitems changes
    $dbh->do("ALTER TABLE biblioitems ADD COLUMN agerestriction VARCHAR(255) DEFAULT NULL AFTER cn_sort");
    $dbh->do("ALTER TABLE deletedbiblioitems ADD COLUMN agerestriction VARCHAR(255) DEFAULT NULL AFTER cn_sort");
    # preferences changes
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('AgeRestrictionMarker','','Markers for age restriction indication, e.g. FSK|PEGI|Age|. See: http://wiki.koha-community.org/wiki/Age_restriction',NULL,'free')");
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('AgeRestrictionOverride',0,'Allow staff to check out an item with age restriction.',NULL,'YesNo')");

    print "Upgrade to $DBversion done (Add colum agerestriction to biblioitems and deletedbiblioitems, add system preferences AgeRestrictionMarker and AgeRestrictionOverride)\n";
   SetVersion ($DBversion);
}

$DBversion = "3.09.00.037";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('UseTransportCostMatrix',0,'Use Transport Cost Matrix when filling holds','','YesNo')");

 $dbh->do("CREATE TABLE `transport_cost` (
              `frombranch` varchar(10) NOT NULL,
              `tobranch` varchar(10) NOT NULL,
              `cost` decimal(6,2) NOT NULL,
              `disable_transfer` tinyint(1) NOT NULL DEFAULT 0,
              CHECK ( `frombranch` <> `tobranch` ), -- a dud check, mysql does not support that
              PRIMARY KEY (`frombranch`, `tobranch`),
              CONSTRAINT `transport_cost_ibfk_1` FOREIGN KEY (`frombranch`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE,
              CONSTRAINT `transport_cost_ibfk_2` FOREIGN KEY (`tobranch`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8");

    print "Upgrade to $DBversion done (creating `transport_cost` table; adding UseTransportCostMatrix systempref, in circulation)\n";
    SetVersion($DBversion);
}

$DBversion ="3.09.00.038";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("ALTER TABLE borrower_attributes CHANGE  attribute  attribute VARCHAR( 255 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL");
    print "Upgrade to $DBversion done (Increase the maximum size of a borrower attribute value)\n";
    SetVersion($DBversion);
}

$DBversion ="3.09.00.039";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,type) VALUES('DidYouMeanFromAuthorities','0','Suggest searches based on authority file.','YesNo');");
    print "Upgrade to $DBversion done (Add system preference DidYouMeanFromAuthorities)\n";
    SetVersion($DBversion);
}

$DBversion = "3.09.00.040";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type) VALUES ('IncludeSeeFromInSearches','0','','Include see-from references in searches.','YesNo');");
    print "Upgrade to $DBversion done (Add IncludeSeeFromInSearches system preference)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.09.00.041";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do(qq{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES('ExportRemoveFields','','List of fields for non export in circulation.pl (separated by a space)','','');
    });
    print "Upgrade to $DBversion done (Add system preference ExportRemoveFields)\n";
    SetVersion($DBversion);
}

$DBversion = "3.09.00.042";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do(qq{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES('ExportWithCsvProfile','','Set a profile name for CSV export','','');
    });
    print "Upgrade to $DBversion done (Adds New System preference ExportWithCsvProfile)\n";
    SetVersion($DBversion)
}

$DBversion = "3.09.00.043";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("
        ALTER TABLE aqorders
        ADD parent_ordernumber int(11) DEFAULT NULL
    ");
    $dbh->do("
        UPDATE aqorders
        SET parent_ordernumber = ordernumber;
    ");
    print "Upgrade to $DBversion done (Adding parent_ordernumber in aqorders)\n";
    SetVersion($DBversion);
}

$DBversion = '3.09.00.044';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE statistics ADD COLUMN ccode VARCHAR ( 10 ) NULL AFTER associatedborrower");
    $dbh->do("UPDATE statistics SET statistics.ccode = ( SELECT items.ccode FROM items WHERE statistics.itemnumber = items.itemnumber )");
    $dbh->do("UPDATE statistics SET statistics.ccode = (
              SELECT deleteditems.ccode FROM deleteditems
                  WHERE statistics.itemnumber = deleteditems.itemnumber
              ) WHERE statistics.ccode IS NULL");
    print "Upgrade done ( Added Collection Code to Statistics table. )\n";
    SetVersion ($DBversion);
}

$DBversion = "3.09.00.045";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("ALTER TABLE borrower_attribute_types MODIFY category_code VARCHAR( 10 ) NULL DEFAULT NULL");
    print "Upgrade to $DBversion done. (Bug 8002: Update patron attribute types table from varchar(1) to varchar(10) category_code)\nWarning to Koha System Administrators: If you use borrower attributes defined by borrower categories, you have to check your configuration. A bug may have removed your attribute links to borrower categories.\nPlease check, and fix it if necessary.";
    SetVersion($DBversion);
}

$DBversion = "3.09.00.046";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("ALTER TABLE `accountlines` ADD `accountlines_id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;");
    print "Upgrade to $DBversion done (adding accountlines_id field in accountlines table)\n";
    SetVersion($DBversion);
}

$DBversion = "3.09.00.047";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    # to preserve default behaviour as best as possible, set this new preference differently depending on whether IndependantBranches is set or not
    my $prefvalue = 'anywhere';
    if (C4::Context->preference("IndependantBranches")) { $prefvalue = 'homeorholdingbranch';}
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('AllowReturnToBranch', '$prefvalue', 'Where an item may be returned', 'anywhere|homebranch|holdingbranch|homeorholdingbranch', 'Choice');");

    print "Upgrade to $DBversion done: adding AllowReturnToBranch syspref (bug 6151)";
    SetVersion($DBversion);
}

$DBversion = "3.09.00.048";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE authorised_values MODIFY lib varchar(200)");
    $dbh->do("ALTER TABLE authorised_values MODIFY lib_opac varchar(200)");

    print "Upgrade to $DBversion done (Raise the length of Authorised Values descriptions)\n";
    SetVersion($DBversion);
}

$DBversion ="3.09.00.049";
if(C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('OPACMobileUserCSS','','Include the following CSS for the mobile view on all pages in the OPAC:',NULL,'free');");
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('OpacMainUserBlockMobile','','Show the following HTML in its own column on the main page of the OPAC (mobile version):',NULL,'free');");
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('OpacShowLibrariesPulldownMobile','1','Show the libraries pulldown on the mobile version of the OPAC.',NULL,'YesNo');");
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('OpacShowFiltersPulldownMobile','1','Show the search filters pulldown on the mobile version of the OPAC.',NULL,'YesNo');");
    print "Upgrade to $DBversion done (Add OPACMobileUserCSS, OpacMainUserBlockMobile, OpacShowLibrariesPulldownMobile and OpacShowFiltersPulldownMobile sysprefs)\n";
    SetVersion($DBversion);
}

$DBversion = "3.09.00.050";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE authorised_values MODIFY category varchar(16) NOT NULL DEFAULT '';");
    $dbh->do("INSERT INTO authorised_values (category, authorised_value, lib) VALUES
              ('REPORT_GROUP', 'CIRC', 'Circulation'),
              ('REPORT_GROUP', 'CAT', 'Catalog'),
              ('REPORT_GROUP', 'PAT', 'Patrons'),
              ('REPORT_GROUP', 'ACQ', 'Acquisitions'),
              ('REPORT_GROUP', 'ACC', 'Accounts');");

    $dbh->do("ALTER TABLE reports_dictionary ADD report_area varchar(6) DEFAULT NULL;");
    $dbh->do("UPDATE reports_dictionary SET report_area = CASE area
                  WHEN 1 THEN 'CIRC'
                  WHEN 2 THEN 'CAT'
                  WHEN 3 THEN 'PAT'
                  WHEN 4 THEN 'ACQ'
                  WHEN 5 THEN 'ACC'
                  END;");
    $dbh->do("ALTER TABLE reports_dictionary DROP area;");
    $dbh->do("ALTER TABLE reports_dictionary ADD KEY dictionary_area_idx (report_area);");

    $dbh->do("ALTER TABLE saved_sql ADD report_area varchar(6) DEFAULT NULL;");
    $dbh->do("ALTER TABLE saved_sql ADD report_group varchar(80) DEFAULT NULL;");
    $dbh->do("ALTER TABLE saved_sql ADD report_subgroup varchar(80) DEFAULT NULL;");
    $dbh->do("ALTER TABLE saved_sql ADD KEY sql_area_group_idx (report_group, report_subgroup);");

    print "Upgrade to $DBversion done saved_sql new fields report_group and report_area; authorised_values.category 16 char \n";
    SetVersion($DBversion);
}

$DBversion = "3.09.00.051";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("
        CREATE TABLE aqinvoices (
          invoiceid int(11) NOT NULL AUTO_INCREMENT,
          invoicenumber mediumtext NOT NULL,
          booksellerid int(11) NOT NULL,
          shipmentdate date default NULL,
          billingdate date default NULL,
          closedate date default NULL,
          shipmentcost decimal(28,6) default NULL,
          shipmentcost_budgetid int(11) default NULL,
          PRIMARY KEY (invoiceid),
          CONSTRAINT aqinvoices_fk_aqbooksellerid FOREIGN KEY (booksellerid) REFERENCES aqbooksellers (id) ON DELETE CASCADE ON UPDATE CASCADE,
          CONSTRAINT aqinvoices_fk_shipmentcost_budgetid FOREIGN KEY (shipmentcost_budgetid) REFERENCES aqbudgets (budget_id) ON DELETE SET NULL ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8
    ");

    # Fill this new table with existing invoices
    my $sth = $dbh->prepare("
        SELECT aqorders.booksellerinvoicenumber AS invoicenumber, aqbasket.booksellerid, aqorders.datereceived
        FROM aqorders
          LEFT JOIN aqbasket ON aqorders.basketno = aqbasket.basketno
        WHERE aqorders.booksellerinvoicenumber IS NOT NULL
          AND aqorders.booksellerinvoicenumber != ''
        GROUP BY aqorders.booksellerinvoicenumber
    ");
    $sth->execute;
    my $results = $sth->fetchall_arrayref({});
    $sth = $dbh->prepare("
        INSERT INTO aqinvoices (invoicenumber, booksellerid, shipmentdate) VALUES (?,?,?)
    ");
    foreach(@$results) {
        $sth->execute($_->{invoicenumber}, $_->{booksellerid}, $_->{datereceived});
    }

    # Add the column in aqorders, fill it with correct value
    # and then drop booksellerinvoicenumber column
    $dbh->do("
        ALTER TABLE aqorders
        ADD COLUMN invoiceid int(11) default NULL AFTER booksellerinvoicenumber,
        ADD CONSTRAINT aqorders_ibfk_3 FOREIGN KEY (invoiceid) REFERENCES aqinvoices (invoiceid) ON DELETE SET NULL ON UPDATE CASCADE
    ");

    $dbh->do("
        UPDATE aqorders, aqinvoices
        SET aqorders.invoiceid = aqinvoices.invoiceid
        WHERE aqorders.booksellerinvoicenumber = aqinvoices.invoicenumber
    ");

    $dbh->do("
        ALTER TABLE aqorders
        DROP COLUMN booksellerinvoicenumber
    ");

    print "Upgrade to $DBversion done (Add aqinvoices table) \n";
    SetVersion ($DBversion);
}

$DBversion = "3.09.00.052";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type) VALUES ('decreaseLoanHighHolds', NULL, '', 'Decreases the loan period for items with number of holds above the threshold specified in decreaseLoanHighHoldsValue', 'YesNo');");
    $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type) VALUES ('decreaseLoanHighHoldsValue', NULL, '', 'Specifies a threshold for the minimum number of holds needed to trigger a reduction in loan duration (used with decreaseLoanHighHolds)', 'Integer');");
    $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type) VALUES ('decreaseLoanHighHoldsDuration', NULL, '', 'Specifies a number of days that a loan is reduced to when used in conjunction with decreaseLoanHighHolds', 'Integer');");
    print "Upgrade to $DBversion done (Add systempreferences to decrease loan length on high demand items decreaseLoanHighHolds, decreaseLoanHighHoldsValue and decreaseLoanHighHoldsDuration) \n";
    SetVersion ($DBversion);
}

$DBversion = "3.09.00.053";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do(
    q|CREATE TABLE `import_auths` (
        import_record_id int(11) NOT NULL,
        matched_authid int(11) default NULL,
        control_number varchar(25) default NULL,
        authorized_heading varchar(128) default NULL,
        original_source varchar(25) default NULL,
        CONSTRAINT import_auths_ibfk_1 FOREIGN KEY (import_record_id)
        REFERENCES import_records (import_record_id) ON DELETE CASCADE ON UPDATE CASCADE,
        KEY matched_authid (matched_authid)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;|
    );
    $dbh->do("ALTER TABLE import_batches
                CHANGE COLUMN num_biblios num_records int(11) NOT NULL default 0,
                ADD COLUMN record_type enum('biblio', 'auth', 'holdings') NOT NULL default 'biblio'");
    $dbh->do("UPDATE import_batches SET record_type='auth' WHERE import_batch_id IN
                (SELECT import_batch_id FROM import_records WHERE record_type='auth')");

    print "Upgrade to $DBversion done (Added support for staging authorities)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.09.00.054";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("ALTER TABLE aqorders CHANGE COLUMN gst gstrate DECIMAL(6,4)  DEFAULT NULL");
    print "Upgrade to $DBversion done (Change column name in aqorders gst --> gstrate)\n";
    SetVersion($DBversion);
}

$DBversion = "3.09.00.055";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("ALTER TABLE aqorders ADD discount float(6,4) DEFAULT NULL AFTER gstrate");
    print "Upgrade to $DBversion done (Add discount field in aqorders table)\n";
    SetVersion($DBversion);
}

$DBversion ="3.09.00.056";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES('AuthDisplayHierarchy','0','Display authority hierarchies','','YesNo')");
    print "Upgrade to $DBversion done (Add system preference AuthDisplayHierarchy)\n";
    SetVersion($DBversion);
}

$DBversion = "3.09.00.057";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("ALTER TABLE aqbasket ADD deliveryplace VARCHAR(10) default NULL AFTER basketgroupid;");
    $dbh->do("ALTER TABLE aqbasket ADD billingplace VARCHAR(10) default NULL AFTER deliveryplace;");
    print "Upgrade to $DBversion done (Bug 5356: Added billingplace, deliveryplace to the aqbasket table)\n";
    SetVersion($DBversion);
}

$DBversion ="3.09.00.058";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,type) VALUES('OPACdidyoumean',NULL,'Did you mean? configuration for the OPAC. Do not change, as this is controlled by /cgi-bin/koha/admin/didyoumean.pl.','Free');");
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,type) VALUES('INTRAdidyoumean',NULL,'Did you mean? configuration for the Intranet. Do not change, as this is controlled by /cgi-bin/koha/admin/didyoumean.pl.','Free');");
    print "Upgrade to $DBversion done (Add Did You Mean? configuration)\n";
    SetVersion($DBversion);
}

$DBversion ="3.09.00.059";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("INSERT INTO systempreferences (variable, value, options, explanation, type) VALUES ('BlockReturnOfWithdrawnItems', '1', '0', 'If enabled, items that are marked as withdrawn cannot be returned.', 'YesNo');");
    print "Upgrade to $DBversion done (Add system preference BlockReturnOfWithdrawnItems)\n";
    SetVersion($DBversion);
}

$DBversion = "3.09.00.060";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('HoldsToPullStartDate','2','Set the default start date for the Holds to pull list to this many days ago',NULL,'Integer')");
    print "Upgrade to $DBversion done (Added HoldsToPullStartDate syspref)\n";
    SetVersion($DBversion);
}

$DBversion = "3.09.00.061";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("UPDATE systempreferences set value=0 WHERE variable='OPACItemsResultsDisplay' AND value='statuses'");
    $dbh->do("UPDATE systempreferences set value=1 WHERE variable='OPACItemsResultsDisplay' AND value='itemdetails'");
    $dbh->do("UPDATE systempreferences SET explanation='If No, show only the status of items in result list. If Yes, show full location of items (branchlocation+callnumber) as in staff interface',options=NULL,type='YesNo' WHERE variable='OPACItemsResultsDisplay'");
    print "Upgrade to $DBversion done (Fixes Bug 5409, Set the syspref value to 1 if it is itemdetails and 0 if it is statuses, leaving it alone if it is already 1 or 0 and change the type of the syspref to YesNo.)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.09.00.062";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
   $dbh->do("UPDATE systempreferences SET value=0 WHERE variable='NoZebra'");
   $dbh->do("UPDATE systempreferences SET value=0 WHERE variable='QueryRemoveStopwords'");
   print "Upgrade to $DBversion done (Disable obsolete NoZebra and QueryRemoveStopwords sysprefs)\n";
   SetVersion ($DBversion);
}

$DBversion = "3.09.00.063";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    my $gst_booksellers = $dbh->selectcol_arrayref("SELECT DISTINCT(gstrate) FROM aqbooksellers");
    my $gist_syspref = C4::Context->preference("gist");
    # remove the undef values and construct and array with the syspref and the supplier values
    my @gstrates = map { defined $_ ? $_ : () } @$gst_booksellers;
    push @gstrates, split ('\|', $gist_syspref);
    # we want to compare integer (or float)
    $_ = $_ + 0 for @gstrates;
    use List::MoreUtils qw/uniq/;
    # remove duplicate values
    @gstrates = uniq sort @gstrates;
    my $new_syspref_value = join '|', @gstrates;
    # update the syspref with the new values
    my $sth = $dbh->prepare("UPDATE systempreferences set value=? WHERE variable='gist'");
    $sth->execute( $new_syspref_value );

    print "Upgrade to $DBversion done (Bug 8832, Set the syspref gist with the existing values)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.09.00.064";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
   $dbh->do('ALTER TABLE items ADD coded_location_qualifier varchar(10) default NULL AFTER itemcallnumber');
   print "Upgrade to $DBversion done (Bug 6428: Added coded_location_qualifier to the items table)\n";
   SetVersion ($DBversion);
}

$DBversion = "3.09.00.065";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
   $dbh->do('ALTER TABLE deleteditems ADD coded_location_qualifier varchar(10) default NULL AFTER itemcallnumber');
   print "Upgrade to $DBversion done (Bug 6428: Added coded_location_qualifier to the deleteditems table)\n";
   SetVersion ($DBversion);
}

$DBversion = "3.09.00.066";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
   $dbh->do("DELETE FROM systempreferences WHERE variable='DidYouMeanFromAuthorities'");
   print "Upgrade to $DBversion done (Bug 9107: remove DidYouMeanFromAuthorities syspref)\n";
   SetVersion ($DBversion);
}

$DBversion = "3.09.00.067";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
   $dbh->do("ALTER TABLE statistics CHANGE COLUMN ccode ccode varchar(10) NULL");
   print "Upgrade to $DBversion done (Bug 9064: statistics.ccode potentially wrongly defined)\n";
   SetVersion ($DBversion);
}

$DBversion = "3.10.00.00";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
   print "Upgrade to $DBversion done (release tag)\n";
   SetVersion ($DBversion);
}

$DBversion = "3.11.00.001";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('alphabet','A B C D E F G H I J K L M N O P Q R S T U V W X Y Z','Alphabet that can be expanded into browse links, e.g. on Home > Patrons',NULL,'free')");
    print "Upgrade to $DBversion done (Bug 2832 - Add alphabet syspref)\n";
}

$DBversion = "3.11.00.002";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do(q{
        DELETE from aqorders_items where ordernumber NOT IN (SELECT ordernumber FROM aqorders);
    });
    $dbh->do(q{
        ALTER TABLE aqorders_items
        ADD CONSTRAINT aqorders_items_ibfk_1 FOREIGN KEY (ordernumber) REFERENCES aqorders (ordernumber)
        ON DELETE CASCADE ON UPDATE CASCADE;
    });
    print "Upgrade to $DBversion done (Bug 9030: Add constraint on aqorders_items.ordernumber)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.11.00.003";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('RefundLostItemFeeOnReturn', '1', 'If enabled, the lost item fee charged to a borrower will be refunded when the lost item is returned.', NULL, 'YesNo')");
    print "Upgrade to $DBversion done (Bug 7189: Add system preference RefundLostItemFeeOnReturn)\n";
    SetVersion($DBversion);
}

$DBversion = "3.11.00.004";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do(qq{
        ALTER TABLE subscription ADD COLUMN closed INT(1) NOT NULL DEFAULT 0 AFTER enddate;
    });

    print "Upgrade to $DBversion done (Bug 8782: Add field subscription.closed)\n";
    SetVersion($DBversion);
}

$DBversion = "3.11.00.005";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do(qq{CREATE TABLE borrower_attribute_types_branches(bat_code VARCHAR(10), b_branchcode VARCHAR(10),FOREIGN KEY (bat_code) REFERENCES borrower_attribute_types(code) ON DELETE CASCADE,FOREIGN KEY (b_branchcode) REFERENCES branches(branchcode) ON DELETE CASCADE ) ENGINE=INNODB DEFAULT CHARSET=utf8;});

    $dbh->do(qq{CREATE TABLE categories_branches(categorycode VARCHAR(10), branchcode VARCHAR(10), FOREIGN KEY (categorycode) REFERENCES categories(categorycode) ON DELETE CASCADE, FOREIGN KEY (branchcode) REFERENCES branches(branchcode) ON DELETE CASCADE ) ENGINE=INNODB DEFAULT CHARSET=utf8;});

    $dbh->do(qq{CREATE TABLE authorised_values_branches(av_id INTEGER, branchcode VARCHAR(10), FOREIGN KEY (av_id) REFERENCES authorised_values(id) ON DELETE CASCADE, FOREIGN KEY  (branchcode) REFERENCES branches(branchcode) ON DELETE CASCADE ) ENGINE=INNODB DEFAULT CHARSET=utf8;});

    print "Upgrade to $DBversion done (Bug 7919: Display of values depending on the connexion library)\n";
    SetVersion($DBversion);
}

$DBversion = "3.11.00.006";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do(q{
        UPDATE virtualshelves SET sortfield="copyrightdate" where sortfield="year";
    });
    print "Upgrade to $DBversion done (Bug 9167: Update the virtualshelves.sortfield column with 'copyrightdate' if needed)\n";
    SetVersion($DBversion);
}

$DBversion = "3.11.00.007";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'ar', 'language', 'de', 'Arabisch')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'hy', 'language', 'de', 'Armenisch')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'bg', 'language', 'de', 'Bulgarisch')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'zh', 'language', 'de', 'Chinesisch')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'cs', 'language', 'de', 'Tschechisch')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'da', 'language', 'de', 'Dänisch')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'nl', 'language', 'de', 'Niederländisch')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'en', 'language', 'de', 'Englisch')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'fi', 'language', 'de', 'Finnisch')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'fr', 'language', 'de', 'Französisch')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'lo', 'language', 'fr', 'Laotien')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'lo', 'language', 'de', 'Laotisch')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'el', 'language', 'de', 'Griechisch (Nach 1453)')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'he', 'language', 'de', 'Hebräisch')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'hi', 'language', 'de', 'Hindi')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'hu', 'language', 'de', 'Ungarisch')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'id', 'language', 'de', 'Indonesisch')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'it', 'language', 'de', 'Italienisch')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'ja', 'language', 'de', 'Japanisch')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'ko', 'language', 'de', 'Koreanisch')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'la', 'language', 'de', 'Latein')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'gl', 'language', 'fr', 'Galicien')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'gl', 'language', 'de', 'Galizisch')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'nb', 'language', 'de', 'Norwegisch bokm&#229;l')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'nn', 'language', 'de', 'Norwegisch nynorsk')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'fa', 'language', 'de', 'Persisch')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'pl', 'language', 'de', 'Polnisch')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'pt', 'language', 'de', 'Portugiesisch')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'ro', 'language', 'de', 'Rumänisch')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'ru', 'language', 'de', 'Russisch')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'sr', 'language', 'fr', 'Serbe')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'sr', 'language', 'de', 'Serbisch')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'es', 'language', 'de', 'Spanisch')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'sv', 'language', 'de', 'Schwedisch')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'tet', 'language', 'fr', 'Tétoum')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'tet', 'language', 'de', 'Tetum')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'th', 'language', 'de', 'Thailändisch')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'tr', 'language', 'de', 'Türkisch')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'uk', 'language', 'de', 'Ukrainisch')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'ur', 'language', 'fr', 'Ourdou')");
    $dbh->do("INSERT INTO language_descriptions (subtag, type, lang, description) VALUES( 'ur', 'language', 'de', 'Urdu')");
    print "Upgrade to $DBversion done (Bug 9056: add German and a couple of French translations to language_descriptions)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.11.00.008";
if (CheckVersion($DBversion)) {
    $dbh->do("
        CREATE TABLE IF NOT EXISTS `borrower_modifications` (
          `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
          `verification_token` varchar(255) NOT NULL DEFAULT '',
          `borrowernumber` int(11) NOT NULL DEFAULT '0',
          `cardnumber` varchar(16) DEFAULT NULL,
          `surname` mediumtext,
          `firstname` text,
          `title` mediumtext,
          `othernames` mediumtext,
          `initials` text,
          `streetnumber` varchar(10) DEFAULT NULL,
          `streettype` varchar(50) DEFAULT NULL,
          `address` mediumtext,
          `address2` text,
          `city` mediumtext,
          `state` text,
          `zipcode` varchar(25) DEFAULT NULL,
          `country` text,
          `email` mediumtext,
          `phone` text,
          `mobile` varchar(50) DEFAULT NULL,
          `fax` mediumtext,
          `emailpro` text,
          `phonepro` text,
          `B_streetnumber` varchar(10) DEFAULT NULL,
          `B_streettype` varchar(50) DEFAULT NULL,
          `B_address` varchar(100) DEFAULT NULL,
          `B_address2` text,
          `B_city` mediumtext,
          `B_state` text,
          `B_zipcode` varchar(25) DEFAULT NULL,
          `B_country` text,
          `B_email` text,
          `B_phone` mediumtext,
          `dateofbirth` date DEFAULT NULL,
          `branchcode` varchar(10) DEFAULT NULL,
          `categorycode` varchar(10) DEFAULT NULL,
          `dateenrolled` date DEFAULT NULL,
          `dateexpiry` date DEFAULT NULL,
          `gonenoaddress` tinyint(1) DEFAULT NULL,
          `lost` tinyint(1) DEFAULT NULL,
          `debarred` date DEFAULT NULL,
          `debarredcomment` varchar(255) DEFAULT NULL,
          `contactname` mediumtext,
          `contactfirstname` text,
          `contacttitle` text,
          `guarantorid` int(11) DEFAULT NULL,
          `borrowernotes` mediumtext,
          `relationship` varchar(100) DEFAULT NULL,
          `ethnicity` varchar(50) DEFAULT NULL,
          `ethnotes` varchar(255) DEFAULT NULL,
          `sex` varchar(1) DEFAULT NULL,
          `password` varchar(30) DEFAULT NULL,
          `flags` int(11) DEFAULT NULL,
          `userid` varchar(75) DEFAULT NULL,
          `opacnote` mediumtext,
          `contactnote` varchar(255) DEFAULT NULL,
          `sort1` varchar(80) DEFAULT NULL,
          `sort2` varchar(80) DEFAULT NULL,
          `altcontactfirstname` varchar(255) DEFAULT NULL,
          `altcontactsurname` varchar(255) DEFAULT NULL,
          `altcontactaddress1` varchar(255) DEFAULT NULL,
          `altcontactaddress2` varchar(255) DEFAULT NULL,
          `altcontactaddress3` varchar(255) DEFAULT NULL,
          `altcontactstate` text,
          `altcontactzipcode` varchar(50) DEFAULT NULL,
          `altcontactcountry` text,
          `altcontactphone` varchar(50) DEFAULT NULL,
          `smsalertnumber` varchar(50) DEFAULT NULL,
          `privacy` int(11) DEFAULT NULL,
          PRIMARY KEY (`verification_token`,`borrowernumber`),
          KEY `verification_token` (`verification_token`),
          KEY `borrowernumber` (`borrowernumber`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
");

    $dbh->do("
        INSERT INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type`) VALUES
        ('PatronSelfRegistration', '0', NULL, 'If enabled, patrons will be able to register themselves via the OPAC.', 'YesNo'),
        ('PatronSelfRegistrationVerifyByEmail', '0', NULL, 'If enabled, any patron attempting to register themselves via the OPAC will be required to verify themselves via email to activate his or her account.', 'YesNo'),
        ('PatronSelfRegistrationDefaultCategory', '', '', 'A patron registered via the OPAC will receive a borrower category code set in this system preference.', 'free'),
        ('PatronSelfRegistrationExpireTemporaryAccountsDelay', '0', NULL, 'If PatronSelfRegistrationDefaultCategory is enabled, this system preference controls how long a patron can have a temporary status before the account is deleted automatically. It is an integer value representing a number of days to wait before deleting a temporary patron account. Setting it to 0 disables the deleting of temporary accounts.', 'Integer'),
        ('PatronSelfRegistrationBorrowerMandatoryField',  'surname|firstname', NULL ,  'Choose the mandatory fields for a patron''s account, when registering via the OPAC.',  'free'),
        ('PatronSelfRegistrationBorrowerUnwantedField',  '', NULL ,  'Name the fields you don''t want to display when registering a new patron via the OPAC.',  'free');
    ");

    $dbh->do("
    INSERT INTO  letter ( `module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content` )
    VALUES ( 'members', 'OPAC_REG_VERIFY', '', 'Opac Self-Registration Verification Email', '1', 'Verify Your Account', 'Hello!

    Your library account has been created. Please verify your email address by clicking this link to complete the signup process:

    http://<<OPACBaseURL>>/cgi-bin/koha/opac-registration-verify.pl?token=<<borrower_modifications.verification_token>>

    If you did not initiate this request, you may safely ignore this one-time message. The request will expire shortly.'
    )");

    print "Upgrade to $DBversion done (Bug 7067: Add Patron Self Registration)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.11.00.009";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES
        ('SeparateHoldings', '0', 'Separate current branch holdings from other holdings', NULL, 'YesNo'),
        ('SeparateHoldingsBranch', 'homebranch', 'Branch used to separate holdings', 'homebranch|holdingbranch', 'Choice'),
        ('OpacSeparateHoldings', '0', 'Separate current branch holdings from other holdings (OPAC)', NULL, 'YesNo'),
        ('OpacSeparateHoldingsBranch', 'homebranch', 'Branch used to separate holdings (OPAC)', 'homebranch|holdingbranch', 'Choice')
    ");

    print "Upgrade to $DBversion done (Bug 7674: Add systempreferences SeparateHoldings, SeparateHoldingsBranch, OpacSeparateHoldings and OpacSeparateHoldingsBranch) \n";
    SetVersion ($DBversion);
}

$DBversion = "3.11.00.010";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type) VALUES('RenewalSendNotice', '0', '', NULL, 'YesNo')");
    $dbh->do(q{
        INSERT INTO `letter` (`module`, `code`, `name`, `title`, `content`) VALUES
        ('circulation','RENEWAL','Item Renewals','Item Renewals','The following items have been renewed:\r\n----\r\n<<biblio.title>>\r\n----\r\nThank you for visiting <<branches.branchname>>.');
    });
    print "Upgrade to $DBversion done (Bug 9151 - Renewal notice according to patron alert preferences)\n";
    SetVersion($DBversion);
}

$DBversion = "3.11.00.011";
if ( CheckVersion($DBversion) ) {
   $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('HTML5MediaEnabled','not','Show a HTML5 media player in a tab on opac-detail.pl for media files catalogued in field 856.','not|opac|staff|both','Choice');");
   $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('HTML5MediaExtensions','webm|ogg|ogv|oga|vtt','Media file extensions','','free');");
   print "Upgrade to $DBversion done (Bug 8377: Add HTML5MediaEnabled and HTML5MediaExtensions sysprefs)\n";
   SetVersion ($DBversion);
}

$DBversion = "3.11.00.012";
if ( CheckVersion($DBversion) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('AllowHoldsOnPatronsPossessions', '1', 'Allow holds on records that patron have items of it',NULL,'YesNo')");
    print "Upgrade to $DBversion done (Bug 9206: Only allow place holds in records that the patron don't have in his possession)\n";
    SetVersion($DBversion);
}

$DBversion = "3.11.00.013";
if ( CheckVersion($DBversion) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('NotesBlacklist','','List of notes fields that should not appear in the title notes/description separator of details',NULL,'free')");
    print "Upgrade to $DBversion done (Bug 9162 - Add a system preference to set which notes fields appears on title notes/description separator)\n";
    SetVersion($DBversion);
}

$DBversion = "3.11.00.014";
if ( CheckVersion($DBversion) ) {
   $dbh->do("INSERT INTO systempreferences ( variable, value, explanation, type ) VALUES ( 'SCOUserCSS', '', 'Add CSS to be included in the SCO module in an embedded <style> tag.', 'free' )");
   $dbh->do("INSERT INTO systempreferences ( variable, value, explanation, type ) VALUES ( 'SCOUserJS', '', 'Define custom javascript for inclusion in the SCO module', 'free' )");
   print "Upgrade to $DBversion done (Bug 9009: Add SCOUserCSS and SCOUserJS sysprefs)\n";
}

$DBversion = "3.11.00.015";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('RentalsInNoissuesCharge', '1', 'Rental charges block checkouts (added to noissuescharge).',NULL,'YesNo');");
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('ManInvInNoissuesCharge', '1', 'MANUAL_INV charges block checkouts (added to noissuescharge).',NULL,'YesNo');");
    print "Upgrade to $DBversion done (Add sysprefs RentalsInNoissuesCharge and ManInvInNoissuesCharge.)\n";
    SetVersion($DBversion);
}

$DBversion = "3.11.00.016";
if ( CheckVersion($DBversion) ) {
   $dbh->do(q{
        UPDATE userflags SET flagdesc="<b>Required for staff login.</b> Staff access, allows viewing of catalogue in staff client." where flagdesc="Modify login / permissions for staff users";
        });
   $dbh->do(q{
        UPDATE userflags SET flagdesc="Edit Authorities" where flagdesc="Allow to edit authorities";
        });
   $dbh->do(q{
        UPDATE userflags SET flagdesc="Allow access to the reports module" where flagdesc="Allow to access to the reports module";
        });
   $dbh->do(q{
        UPDATE userflags SET flagdesc="Set library management parameters (deprecated)" where flagdesc="Set library management parameters";
        });
   $dbh->do(q{
        UPDATE userflags SET flagdesc="Manage serial subscriptions" where flagdesc="Allow to manage serials subscriptions";
        });
   $dbh->do(q{
        UPDATE userflags SET flagdesc="Manage patrons fines and fees" where flagdesc="Update borrower charges";
        });
   $dbh->do(q{
        UPDATE userflags SET flagdesc="Check out and check in items" where flagdesc="Circulate books";
        });
   $dbh->do(q{
        UPDATE userflags SET flagdesc="Manage Koha system settings (Administration panel)" where flagdesc="Set Koha system parameters";
        });
   $dbh->do(q{
        UPDATE userflags SET flagdesc="Add or modify patrons" where flagdesc="Add or modify borrowers";
        });
   $dbh->do(q{
        UPDATE userflags SET flagdesc="Use all tools (expand for granular tools permissions)" where flagdesc="Use tools (export, import, barcodes)";
        });
   $dbh->do(q{
        UPDATE userflags SET flagdesc="Allow staff members to modify permissions for other staff members" where flagdesc="Set user permissions";
        });
   $dbh->do(q{
        UPDATE permissions SET description="Perform batch modification of patrons" where description="Perform batch modifivation of patrons";
        });

   print "Upgrade to $DBversion done (Bug 9382 (updated with bug 9745) - refresh permission descriptions to make more sense)\n";
   SetVersion ($DBversion);
}

$DBversion ="3.11.00.017";
if ( CheckVersion($DBversion) ) {
    $dbh->do("INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES('IDreamBooksReviews','0','Display book review snippets from IDreamBooks.com','','YesNo');");
    $dbh->do("INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES('IDreamBooksReadometer','0','Display Readometer from IDreamBooks.com','','YesNo');");
    $dbh->do("INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES('IDreamBooksResults','0','Display IDreamBooks.com rating in search results','','YesNo');");
    print "Upgrade to $DBversion done (Add IDreamBooks enhanced content)\n";
    SetVersion($DBversion);
}

$DBversion = "3.11.00.018";
if ( CheckVersion($DBversion) ) {
   $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type) VALUES ('OPACNumbersPreferPhrase','0', NULL, 'Control the use of phr operator in callnumber and standard number OPAC searches', 'YesNo')");
   $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type) VALUES ('IntranetNumbersPreferPhrase','0', NULL, 'Control the use of phr operator in callnumber and standard number staff client searches', 'YesNo')");
   print "Upgrade to $DBversion done (Bug 9395: Problem with callnumber and standard number search in OPAC and Staff Client)\n";
   SetVersion ($DBversion);
}

$DBversion = "3.11.00.019";
if ( CheckVersion($DBversion) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('UNIMARCAuthorityField100', 'afrey50      ba0', NULL, NULL, 'Textarea')");
    print "Upgrade to $DBversion done (Bug 9145 - Add syspref UNIMARCAuthorityField100)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.11.00.020";
if ( CheckVersion($DBversion) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('UNIMARCField100Language', 'fre','UNIMARC field 100 default language',NULL,'short')");
    print "Upgrade to $DBversion done (Bug 8347 - Koha forces UNIMARC 100 field code language to 'fre')\n";
    SetVersion($DBversion);
}

$DBversion ="3.11.00.021";
if ( CheckVersion($DBversion) ) {
    $dbh->do("INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES('OPACPopupAuthorsSearch','0','Display the list of authors when clicking on one author.','','YesNo');");
    print "Upgrade to $DBversion done (Bug 5888 - Subject search pop-up for the OPAC)\n";
    SetVersion($DBversion);
}

$DBversion = "3.11.00.022";
if ( CheckVersion($DBversion) ) {
    $dbh->do(
"INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES('Persona',0,'Use Mozilla Persona for login','','YesNo')"
    );
    print "Upgrade to $DBversion done (Bug 9587 - Allow login via Persona)\n";
    SetVersion($DBversion);
}

$DBversion = "3.11.00.023";
if ( CheckVersion($DBversion) ) {
    $dbh->do("UPDATE z3950servers SET host = 'lx2.loc.gov', port = 210, db = 'LCDB', syntax = 'USMARC', encoding = 'utf8' WHERE name = 'LIBRARY OF CONGRESS'");
    print "Upgrade to $DBversion done (Bug 9520 - Update default LOC Z39.50 target)\n";
    SetVersion($DBversion);
}

$DBversion = "3.11.00.024";
if ( CheckVersion($DBversion) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('OpacItemLocation','callnum','Show the shelving location of items in the opac','callnum|ccode|location','Choice');");
    print "Upgrade to $DBversion done (Bug 5079: Add OpacItemLocation syspref)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.11.00.025";
if ( CheckVersion($DBversion) ) {
    $dbh->do(
        "CREATE TABLE linktracker (
  id int(11) NOT NULL AUTO_INCREMENT,
  biblionumber int(11) DEFAULT NULL,
  itemnumber int(11) DEFAULT NULL,
  borrowernumber int(11) DEFAULT NULL,
  url text,
  timeclicked datetime DEFAULT NULL,
  PRIMARY KEY (id),
  KEY bibidx (biblionumber),
  KEY itemidx (itemnumber),
  KEY borridx (borrowernumber),
  KEY dateidx (timeclicked)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;"
    );
    $dbh->do( "
  INSERT INTO systempreferences (variable,value,explanation,options,type)
  VALUES('TrackClicks','0','Track links clicked',NULL,'Integer')" );
    print
"Upgrade to $DBversion done (Adds feature Bug 8917, the ability to track links clicked)\n";
    SetVersion($DBversion);
}

$DBversion = "3.11.00.026";
if ( CheckVersion($DBversion) ) {
    $dbh->do(qq{
        ALTER TABLE import_records ADD INDEX batch_id_record_type ( import_batch_id, record_type );
    });
    print "Upgrade to $DBversion done (Bug 9207: Add new index batch_id_record_type to import_records)\n";
    SetVersion($DBversion);
}

$DBversion = "3.11.00.027";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT INTO permissions ( module_bit, code, description )
        VALUES  ( '1', 'overdues_report', 'Execute overdue items report' )
    });
    # add new permission for users with all report permissions and circulation remaining permission
    $dbh->do(q{
        INSERT INTO user_permissions (borrowernumber, module_bit, code)
        SELECT user_permissions.borrowernumber, 1, 'overdues_report'
        FROM user_permissions
        LEFT JOIN borrowers USING(borrowernumber)
        WHERE borrowers.flags & (1 << 16)
        AND user_permissions.code = 'circulate_remaining_permissions'
    });
    print "Upgrade to $DBversion done ( Add circ permission overdues_report )\n";
    SetVersion($DBversion);
}

$DBversion = "3.11.00.028";
if ( CheckVersion($DBversion) ) {
    $dbh->do("INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('PatronSelfRegistrationAdditionalInstructions', '', NULL , 'A free text field to display additional instructions to newly self registered patrons.', 'free'    );");
    print "Upgrade to $DBversion done (Bug 9756 - Patron self registration missing the system preference PatronSelfRegistrationAdditionalInstructions)\n";
    SetVersion($DBversion);
}

$DBversion = "3.11.00.029";
if (CheckVersion($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('UseQueryParser', '0', 'If enabled, try to use QueryParser for queries.', NULL, 'YesNo')");
    print "Upgrade to $DBversion done (Bug 9239: Make it possible for Koha to use QueryParser)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.11.00.030";
if ( CheckVersion($DBversion) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('FinesIncludeGracePeriod','1','If enabled, fines calculations will include the grace period.',NULL,'YesNo');");
    print "Upgrade to $DBversion done (Add system preference FinesIncludeGracePeriod)\n";
    SetVersion($DBversion);
}

$DBversion = "3.11.00.100";
if ( CheckVersion($DBversion) ) {
    print "Upgrade to $DBversion done (3.12-alpha release)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.11.00.101";
if ( CheckVersion($DBversion) ) {
   $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('UNIMARCAuthorsFacetsSeparator',', ', 'UNIMARC authors facets separator', NULL, 'short')");
   print "Upgrade to $DBversion done (Bug 9341: Problem with UNIMARC authors facets)\n";
   SetVersion ($DBversion);
}

$DBversion = "3.11.00.102";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        DELETE FROM systempreferences WHERE variable='NoZebra'
    });
    $dbh->do(q{
        DELETE FROM systempreferences WHERE variable='QueryRemoveStopwords'
    });
    print "Upgrade to $DBversion done (Remove deprecated NoZebra and QueryRemoveStopwords sysprefs)\n";
    SetVersion($DBversion);
}

$DBversion = "3.11.00.103";
if ( CheckVersion($DBversion) ) {
    $dbh->do("DELETE FROM systempreferences WHERE variable = 'insecure';");
    print "Upgrade to $DBversion done (Bug 9827 - Remove 'insecure' system preference)\n";
    SetVersion($DBversion);
}

$DBversion = "3.11.00.104";
if ( CheckVersion($DBversion) ) {
    print "Upgrade to $DBversion done (3.12-alpha2 release)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.11.00.105";
if ( CheckVersion($DBversion) ) {
    if ( C4::Context->preference("marcflavour") eq 'MARC21' ) {
        $sth = $dbh->prepare(
"SELECT frameworkcode FROM marc_tag_structure WHERE tagfield = '029'"
        );
        $sth->execute;
        my $frameworkcodes = $sth->fetchall_hashref('frameworkcode');

        for my $frameworkcode ( keys %$frameworkcodes ) {
            $dbh->do( "
    INSERT IGNORE INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian,
    libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode,
    value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
    ('029', 'a', 'OCLC library identifier', 'OCLC library identifier', 0, 0, '', 0, '', '', '', 0, -6, '$frameworkcode', '', '', NULL),
    ('029', 'b', 'System control number', 'System control number', 0, 0, '', 0, '', '', '', 0, -6, '$frameworkcode', '', '', NULL),
    ('029', 'c', 'OAI set name', 'OAI set name', 0, 0, '', 0, '', '', '', 0, -6, '$frameworkcode', '', '', NULL),
    ('029', 't', 'Content type identifier', 'Content type identifier', 0, 0, '', 0, '', '', '', 0, -6, '$frameworkcode', '', '', NULL)
   " );
        }

        for my $tag ( '863', '864', '865' ) {
            $sth = $dbh->prepare(
"SELECT frameworkcode FROM marc_tag_structure WHERE tagfield = '$tag'"
            );
            $sth->execute;
            my $frameworkcodes = $sth->fetchall_hashref('frameworkcode');

            for my $frameworkcode ( keys %$frameworkcodes ) {
                $dbh->do( "
     INSERT IGNORE INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian,
     libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode,
     value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
     ('$tag', '6', 'Linkage', 'Linkage', 0, 0, '', 8, '', '', '', NULL, 5, '$frameworkcode', '', '', NULL),
     ('$tag', '8', 'Field link and sequence number', 'Field link and sequence number', 0, 0, '', 8, '', '', '', NULL, 5, '$frameworkcode', '', '', NULL),
     ('$tag', 'a', 'First level of enumeration', 'First level of enumeration', 0, 0, '', 8, '', '', '', 0, 5, '$frameworkcode', '', '', NULL),
     ('$tag', 'b', 'Second level of enumeration', 'Second level of enumeration', 0, 0, '', 8, '', '', '', 0, 5, '$frameworkcode', '', '', NULL),
     ('$tag', 'c', 'Third level of enumeration', 'Third level of enumeration', 0, 0, '', 8, '', '', '', 0, 5, '$frameworkcode', '', '', NULL),
     ('$tag', 'd', 'Fourth level of enumeration', 'Fourth level of enumeration', 0, 0, '', 8, '', '', '', 0, 5, '$frameworkcode', '', '', NULL),
     ('$tag', 'e', 'Fifth level of enumeration', 'Fifth level of enumeration', 0, 0, '', 8, '', '', '', 0, 5, '$frameworkcode', '', '', NULL),
     ('$tag', 'f', 'Sixth level of enumeration', 'Sixth level of enumeration', 0, 0, '', 8, '', '', '', 0, 5, '$frameworkcode', '', '', NULL),
     ('$tag', 'g', 'Alternative numbering scheme, first level of enumeration', 'Alternative numbering scheme, first level of enumeration', 0, 0, '', 8, '', '', '', 0, 5, '$frameworkcode', '', '', NULL),
     ('$tag', 'h', 'Alternative numbering scheme, second level of enumeration', 'Alternative numbering scheme, second level of enumeration', 0, 0, '', 8, '', '', '', 0, 5, '$frameworkcode', '', '', NULL),
     ('$tag', 'i', 'First level of chronology', 'First level of chronology', 0, 0, '', 8, '', '', '', 0, 5, '$frameworkcode', '', '', NULL),
     ('$tag', 'j', 'Second level of chronology', 'Second level of chronology', 0, 0, '', 8, '', '', '', 0, 5, '$frameworkcode', '', '', NULL),
     ('$tag', 'k', 'Third level of chronology', 'Third level of chronology', 0, 0, '', 8, '', '', '', 0, 5, '$frameworkcode', '', '', NULL),
     ('$tag', 'l', 'Fourth level of chronology', 'Fourth level of chronology', 0, 0, '', 8, '', '', '', 0, 5, '$frameworkcode', '', '', NULL),
     ('$tag', 'm', 'Alternative numbering scheme, chronology', 'Alternative numbering scheme, chronology', 0, 0, '', 8, '', '', '', 0, 5, '$frameworkcode', '', '', NULL),
     ('$tag', 'n', 'Converted Gregorian year', 'Converted Gregorian year', 0, 0, '', 8, '', '', '', 0, 5, '$frameworkcode', '', '', NULL),
     ('$tag', 'o', 'Type of unit', 'Type of unit', 1, 0, '', 8, '', '', '', 0, 5, '$frameworkcode', '', '', NULL),
     ('$tag', 'p', 'Piece designation', 'Piece designation', 0, 0, '', 8, '', '', '', 0, 5, '$frameworkcode', '', '', NULL),
     ('$tag', 'q', 'Piece physical condition', 'Piece physical condition', 0, 0, '', 8, '', '', '', 0, 5, '$frameworkcode', '', '', NULL),
     ('$tag', 's', 'Copyright article-fee code', 'Copyright article-fee code', 1, 0, '', 8, '', '', '', 0, 5, '$frameworkcode', '', '', NULL),
     ('$tag', 't', 'Copy number', 'Copy number', 0, 0, '', 8, '', '', '', 0, 5, '$frameworkcode', '', '', NULL),
     ('$tag', 'v', 'Issuing date', 'Issuing date', 1, 0, '', 8, '', '', '', 0, 5, '$frameworkcode', '', '', NULL),
     ('$tag', 'w', 'Break indicator', 'Break indicator', 0, 0, '', 8, '', '', '', 0, 5, '$frameworkcode', '', '', NULL),
     ('$tag', 'x', 'Nonpublic note', 'Nonpublic note', 1, 0, '', 8, '', '', '', 0, 5, '$frameworkcode', '', '', NULL),
     ('$tag', 'z', 'Public note', 'Public note', 1, 0, '', 8, '', '', '', 0, 5, '$frameworkcode', '', '', NULL)
    " );
            }
        }
    }
    print "Upgrade to $DBversion done (Bug 9353: Missing subfields on MARC21 frameworks)\n";
    SetVersion($DBversion);
}


$DBversion = "3.11.00.106";
if ( CheckVersion($DBversion) ) {
    $dbh->do("INSERT INTO userflags (bit, flag, flagdesc, defaulton) VALUES ('19', 'plugins', 'Koha plugins', '0')");
    $dbh->do("INSERT INTO permissions (module_bit, code, description) VALUES
              ('19', 'manage', 'Manage plugins ( install / uninstall )'),
              ('19', 'tool', 'Use tool plugins'),
              ('19', 'report', 'Use report plugins'),
              ('19', 'configure', 'Configure plugins')
            ");
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('UseKohaPlugins','0','Enable or disable the ability to use Koha Plugins.','','YesNo')");

    $dbh->do("
        CREATE TABLE IF NOT EXISTS plugin_data (
            plugin_class varchar(255) NOT NULL,
            plugin_key varchar(255) NOT NULL,
            plugin_value text,
            PRIMARY KEY (plugin_class,plugin_key)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    ");

    print "Upgrade to $DBversion done (Bug 7804: Added plugin system.)\n";
    SetVersion($DBversion);
}

$DBversion = "3.11.00.107";
if ( CheckVersion($DBversion) ) {
   $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type) VALUES ('TimeFormat','24hr','12hr|24hr','Defines the global time format for visual output.','Choice')");
   print "Upgrade to $DBversion done (Bug 9014: Add syspref TimeFormat)\n";
   SetVersion ($DBversion);
}

$DBversion = "3.11.00.108";
if ( CheckVersion($DBversion) ) {
    $dbh->do("ALTER TABLE action_logs CHANGE timestamp timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;");
    $dbh->do("UPDATE action_logs SET info=(SELECT itemnumber FROM items WHERE biblionumber= action_logs.info LIMIT 1) WHERE module='CIRCULATION' AND action in ('ISSUE','RETURN');");
    $dbh->do("ALTER TABLE action_logs CHANGE timestamp timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;");
    print "Upgrade to $DBversion done (Bug 7241: Fix on circulation logs)\n";
    print "WARNING about bug 7241: to partially correct the broken logs, the log history is filled with the first found item for each biblio.\n";
    SetVersion($DBversion);
}

$DBversion = "3.11.00.109";
if ( CheckVersion($DBversion) ) {
   $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type) VALUES('DisplayIconsXSLT', '1', '', 'If ON, displays the format, audience, and material type icons in XSLT MARC21 results and detail pages.', 'YesNo');");
   print "Upgrade to $DBversion done (Bug 9403: Add DisplayIconsXSLT)\n";
   SetVersion ($DBversion);
}

$DBversion = "3.11.00.110";
if ( CheckVersion($DBversion) ) {
    $dbh->do("ALTER TABLE pending_offline_operations CHANGE barcode barcode VARCHAR( 20 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL");
    $dbh->do("ALTER TABLE pending_offline_operations ADD amount DECIMAL( 28, 6 ) NULL DEFAULT NULL");
    print "Upgrade to $DBversion done (Bug 8220 - Allow koc uploads to go to process queue)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.11.00.111";
if ( CheckVersion($DBversion) ) {
    my $sth = $dbh->prepare("
        SELECT module, code, branchcode, content
        FROM letter
        WHERE content LIKE '%<fine>%'
    ");
    $sth->execute;
    my $sth_update = $dbh->prepare("UPDATE letter SET content = ? WHERE module = ? AND code = ? AND branchcode = ?");
    while(my $row = $sth->fetchrow_hashref){
        $row->{content} =~ s/<fine>\w+<\/fine>/<<items.fine>>/;
        $sth_update->execute($row->{content}, $row->{module}, $row->{code}, $row->{branchcode});
    }
    print "Upgrade to $DBversion done (use new <<items.fine>> syntax in notices)\n";
    SetVersion($DBversion);
}

$DBversion = "3.11.00.112";
if ( CheckVersion($DBversion) ) {
    $dbh->do(qq{
        ALTER TABLE issuingrules ADD COLUMN renewalperiod int(4) DEFAULT NULL AFTER renewalsallowed
    });
    $dbh->do(qq{
        UPDATE issuingrules SET renewalperiod = issuelength
    });
    print "Upgrade to $DBversion done (Bug 8365: Add colum issuingrules.renewalperiod)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.11.00.113";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        ALTER TABLE branchcategories ADD show_in_pulldown BOOLEAN NOT NULL DEFAULT '0',
        ADD INDEX ( show_in_pulldown )
    });
    print "Upgrade to $DBversion done (Bug 9257 - Add groups to normal search pulldown)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.11.00.115";
if ( CheckVersion($DBversion) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type) VALUES ('HighlightOwnItemsOnOPAC','0','','If on, and a patron is logged into the OPAC, items from his or her home library will be emphasized and shown first in search results and item details.','YesNo')");
    $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type) VALUES ('HighlightOwnItemsOnOPACWhich','PatronBranch','PatronBranch|OpacURLBranch','Decides which branch''s items to emphasize. If PatronBranch, emphasize the logged in user''s library''s items. If OpacURLBranch, highlight the items of the Apache var BRANCHCODE defined in Koha''s Apache configuration file.','Choice')");
    print "Upgrade to $DBversion done (Bug 7740: Add syspref HighlightOwnItemsOnOPAC)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.11.00.116";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{ALTER TABLE aqorders DROP COLUMN serialid;});
    $dbh->do(q{ALTER TABLE aqorders DROP COLUMN subscription;});
    $dbh->do(q{ALTER TABLE aqorders ADD COLUMN subscriptionid INT(11) DEFAULT NULL;});
    $dbh->do(q{ALTER TABLE aqorders ADD CONSTRAINT aqorders_subscriptionid FOREIGN KEY (subscriptionid) REFERENCES subscription (subscriptionid) ON DELETE CASCADE ON UPDATE CASCADE;});
    $dbh->do(q{ALTER TABLE subscription ADD COLUMN reneweddate DATE DEFAULT NULL;});
    print "Upgrade to $DBversion done (Bug 5343: table aqorders: DROP serialid and subscription fields and ADD subscriptionid, table subscription: ADD reneweddate)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.11.00.200";
if ( CheckVersion($DBversion) ) {
    print "Upgrade to $DBversion done (3.12-beta1 release)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.11.00.201";
if ( CheckVersion($DBversion) ) {
    $dbh->do("UPDATE z3950servers SET encoding = 'ISO_8859-1' WHERE name = 'BIBSYS' AND host LIKE 'z3950.bibsys.no'");
    $dbh->do("UPDATE z3950servers SET encoding = 'ISO_8859-1' WHERE name = 'NORBOK' AND host LIKE 'z3950.nb.no'");
    $dbh->do("UPDATE z3950servers SET encoding = 'ISO_8859-1' WHERE name = 'SAMBOK' AND host LIKE 'z3950.nb.no'");
    $dbh->do("UPDATE z3950servers SET encoding = 'ISO_8859-1' WHERE name = 'DEICHMAN' AND host like 'z3950.deich.folkebibl.no'");
    print "Upgrade to $DBversion done (Bug 9498 - Update encoding for Norwegian sample Z39.50 servers)\n";
    SetVersion($DBversion);
}

$DBversion = "3.11.00.202";
if ( CheckVersion($DBversion) ) {
   $dbh->do("INSERT INTO language_subtag_registry( subtag, type, description, added) VALUES ( 'ca', 'language', 'Catalan','2013-01-12' )");
   $dbh->do("INSERT INTO language_rfc4646_to_iso639(rfc4646_subtag,iso639_2_code) VALUES( 'ca','cat')");
   $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES( 'ca', 'language', 'es', 'Catalán')");
   $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES( 'ca', 'language', 'en', 'Catalan')");
   $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES( 'ca', 'language', 'fr', 'Catalan')");
   $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES( 'ca', 'language', 'ca', 'Català')");
   $dbh->do("INSERT INTO language_descriptions(subtag, type, lang, description) VALUES( 'ca', 'language', 'de', 'Katalanisch')");
   print "Upgrade to $DBversion done (Bug 9381: Add Catalan laguage)\n";
   SetVersion ($DBversion);
}

$DBversion = "3.11.00.203";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{ALTER TABLE suggestions CHANGE COLUMN title title VARCHAR(255) DEFAULT NULL;});
    print "Upgrade to $DBversion done (Bug 2046 - increasing title column length for suggestions)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.11.00.300";
if ( CheckVersion($DBversion) ) {
    print "Upgrade to $DBversion done (3.12-beta3 release)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.11.00.301";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    #issues
    $dbh->do(q{
        ALTER TABLE `issues`
            ADD KEY `itemnumber_idx` (`itemnumber`),
            ADD KEY `branchcode_idx` (`branchcode`),
            ADD KEY `issuingbranch_idx` (`issuingbranch`)
    });
    $dbh->do(q{
        ALTER TABLE `old_issues`
            ADD KEY `branchcode_idx` (`branchcode`),
            ADD KEY `issuingbranch_idx` (`issuingbranch`)
    });
    #items
    $dbh->do(q{
        ALTER TABLE `items` ADD KEY `itype_idx` (`itype`)
    });
    $dbh->do(q{
        ALTER TABLE `deleteditems` ADD KEY `itype_idx` (`itype`)
    });
    # biblioitems
    $dbh->do(q{
        ALTER TABLE `biblioitems` ADD KEY `itemtype_idx` (`itemtype`)
    });
    $dbh->do(q{
        ALTER TABLE `deletedbiblioitems` ADD KEY `itemtype_idx` (`itemtype`)
    });
    # statistics
    $dbh->do(q{
        ALTER TABLE `statistics`
            ADD KEY `branch_idx` (`branch`),
            ADD KEY `proccode_idx` (`proccode`),
            ADD KEY `type_idx` (`type`),
            ADD KEY `usercode_idx` (`usercode`),
            ADD KEY `itemnumber_idx` (`itemnumber`),
            ADD KEY `itemtype_idx` (`itemtype`),
            ADD KEY `borrowernumber_idx` (`borrowernumber`),
            ADD KEY `associatedborrower_idx` (`associatedborrower`),
            ADD KEY `ccode_idx` (`ccode`)
    });

    print "Upgrade to $DBversion done (Bug 9681: Add some database indexes)\n";
    SetVersion($DBversion);
}

$DBversion = "3.12.00.000";
if ( CheckVersion($DBversion) ) {
    print "Upgrade to $DBversion done (3.12.0 release)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.13.00.000';
if ( CheckVersion($DBversion) ) {
    print "Upgrade to $DBversion done (start the journey to Koha Pi)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.13.00.001";
if ( CheckVersion($DBversion) ) {
    $dbh->do("INSERT INTO `systempreferences` (`variable`, `value`, `options`, `explanation`, `type`) VALUES ('UseCourseReserves', '0', NULL, 'Enable the course reserves feature.', 'YesNo')");
    $dbh->do("INSERT INTO userflags (bit,flag,flagdesc,defaulton) VALUES ('18','coursereserves','Course Reserves','0')");
    $dbh->do("
CREATE TABLE `courses` (
  `course_id` int(11) NOT NULL AUTO_INCREMENT,
  `department` varchar(20) DEFAULT NULL,
  `course_number` varchar(255) DEFAULT NULL,
  `section` varchar(255) DEFAULT NULL,
  `course_name` varchar(255) DEFAULT NULL,
  `term` varchar(20) DEFAULT NULL,
  `staff_note` mediumtext,
  `public_note` mediumtext,
  `students_count` varchar(20) DEFAULT NULL,
  `enabled` enum('yes','no') NOT NULL DEFAULT 'yes',
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
   PRIMARY KEY (`course_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;
    ");

    $dbh->do("
CREATE TABLE `course_instructors` (
  `course_id` int(11) NOT NULL,
  `borrowernumber` int(11) NOT NULL,
  PRIMARY KEY (`course_id`,`borrowernumber`),
  KEY `borrowernumber` (`borrowernumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    ");

    $dbh->do("
ALTER TABLE `course_instructors`
  ADD CONSTRAINT `course_instructors_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`),
  ADD CONSTRAINT `course_instructors_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE;
    ");

    $dbh->do("
CREATE TABLE `course_items` (
  `ci_id` int(11) NOT NULL AUTO_INCREMENT,
  `itemnumber` int(11) NOT NULL,
  `itype` varchar(10) DEFAULT NULL,
  `ccode` varchar(10) DEFAULT NULL,
  `holdingbranch` varchar(10) DEFAULT NULL,
  `location` varchar(80) DEFAULT NULL,
  `enabled` enum('yes','no') NOT NULL DEFAULT 'no',
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
   PRIMARY KEY (`ci_id`),
   UNIQUE KEY `itemnumber` (`itemnumber`),
   KEY `holdingbranch` (`holdingbranch`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;
    ");

    $dbh->do("
ALTER TABLE `course_items`
  ADD CONSTRAINT `course_items_ibfk_2` FOREIGN KEY (`holdingbranch`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `course_items_ibfk_1` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE;
");

    $dbh->do("
CREATE TABLE `course_reserves` (
  `cr_id` int(11) NOT NULL AUTO_INCREMENT,
  `course_id` int(11) NOT NULL,
  `ci_id` int(11) NOT NULL,
  `staff_note` mediumtext,
  `public_note` mediumtext,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
   PRIMARY KEY (`cr_id`),
   UNIQUE KEY `pseudo_key` (`course_id`,`ci_id`),
   KEY `course_id` (`course_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;
");

    $dbh->do("
ALTER TABLE `course_reserves`
  ADD CONSTRAINT `course_reserves_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`);
    ");

    $dbh->do("
INSERT INTO permissions (module_bit, code, description) VALUES
  (18, 'manage_courses', 'Add, edit and delete courses'),
  (18, 'add_reserves', 'Add course reserves'),
  (18, 'delete_reserves', 'Remove course reserves')
;
    ");


    print "Upgrade to $DBversion done (Add Course Reserves ( system preference UseCourseReserves ))\n";
    SetVersion($DBversion);
}

$DBversion = "3.13.00.002";
if ( CheckVersion($DBversion) ) {
   $dbh->do("UPDATE systempreferences SET variable = 'IndependentBranches' WHERE variable = 'IndependantBranches'");
   print "Upgrade to $DBversion done (Bug 10080 - Change system pref IndependantBranches to IndependentBranches)\n";
   SetVersion ($DBversion);
}

$DBversion = '3.13.00.003';
if ( CheckVersion($DBversion) ) {
    $dbh->do("ALTER TABLE serial DROP itemnumber");
    print "Upgrade to $DBversion done (Bug 7718 - Remove itemnumber column from serials table)\n";
    SetVersion($DBversion);
}

$DBversion = "3.13.00.004";
if(CheckVersion($DBversion)) {
    $dbh->do(
"INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES('OpacShowHoldNotes',0,'Show hold notes on OPAC','','YesNo')"
    );
    print "Upgrade to $DBversion done (Bug 9722: Allow users to add notes when placing a hold in OPAC)\n";
    SetVersion($DBversion);
}

$DBversion = "3.13.00.005";
if(CheckVersion($DBversion)) {
    my $intra= C4::Context->preference("intranetstylesheet");
    #if this pref is not blank or starting with http, https or / [root], then
    #add an additional / to the front
    if($intra && $intra !~ /^(\/|https?)/) {
        $dbh->do("UPDATE systempreferences SET value=? WHERE variable=?",
            undef,('/'.$intra,"intranetstylesheet"));
        print "WARNING: Your system preference intranetstylesheet has been prefixed with a slash to make it an absolute path.\n";
    }
    print "Upgrade to $DBversion done (Bug 10052: Make intranetstylesheet and intranetcolorstylesheet behave exactly like their opac counterparts)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.13.00.006";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
        VALUES ('CalculateFinesOnReturn','1','Switch to control if overdue fines are calculated on return or not', '', 'YesNo')
    });
    print "Upgrade to $DBversion done (Bug 10120: Fines on item return controlled by a systempreference)\n";
    SetVersion($DBversion);
}

$DBversion = "3.13.00.007";
if ( CheckVersion($DBversion) ) {
    $dbh->do("UPDATE systempreferences SET variable='OpacHoldNotes' WHERE variable='OpacShowHoldNotes'");
    print "Upgrade to $DBversion done (Bug 10343: Rename OpacShowHoldNotes to OpacHoldNotes)\n";
    SetVersion($DBversion);
}

$DBversion = "3.13.00.008";
if ( CheckVersion($DBversion) ) {
    $dbh->do("
CREATE TABLE IF NOT EXISTS borrower_files (
  file_id int(11) NOT NULL AUTO_INCREMENT,
  borrowernumber int(11) NOT NULL,
  file_name varchar(255) NOT NULL,
  file_type varchar(255) NOT NULL,
  file_description varchar(255) DEFAULT NULL,
  file_content longblob NOT NULL,
  date_uploaded timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (file_id),
  KEY borrowernumber (borrowernumber),
  CONSTRAINT borrower_files_ibfk_1 FOREIGN KEY (borrowernumber) REFERENCES borrowers (borrowernumber) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;
    ");
    print "Upgrade to $DBversion done (Bug 10443: make sure borrower_files table exists)\n";
    SetVersion($DBversion);
}

$DBversion = "3.13.00.009";
if ( CheckVersion($DBversion) ) {
    $dbh->do("ALTER TABLE aqorders DROP COLUMN biblioitemnumber");
    print "Upgrade to $DBversion done (Bug 9987 - Drop column aqorders.biblioitemnumber)\n";
    SetVersion($DBversion);
}

$DBversion = "3.13.00.010";
if ( CheckVersion($DBversion) ) {
    $dbh->do(
        q{
INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('AcqWarnOnDuplicateInvoice','0','Warn librarians when they try to create a duplicate invoice', '', 'YesNo');
}
    );
    print
"Upgrade to $DBversion done (Bug 10366 - Add system preference to enabling warning librarian when invoice is duplicated)\n";
    SetVersion($DBversion);
}

$DBversion = "3.13.00.011";
if ( CheckVersion($DBversion) ) {
    $dbh->do("UPDATE language_rfc4646_to_iso639 SET iso639_2_code='ita' WHERE rfc4646_subtag='it'");
    print "Upgrade to $DBversion done (Bug 9519: Wrong language code for Italian in the advanced search language limitations)\n";
    SetVersion($DBversion);
}

$DBversion = "3.13.00.012";
if ( CheckVersion($DBversion) ) {
    $dbh->do("ALTER TABLE issuingrules MODIFY COLUMN overduefinescap decimal(28,6) DEFAULT NULL;");
    print "Upgrade to $DBversion done (Bug 10490: Correct datatype for overduefinescap in issuingrules)\n";
    SetVersion($DBversion);
}

$DBversion ="3.13.00.013";
if ( CheckVersion($DBversion) ) {
    $dbh->do("INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES ('AllowTooManyOverride', '1', 'If on, allow staff to override and check out items when the patron has reached the maximum number of allowed checkouts', '', 'YesNo');");
    print "Upgrade to $DBversion done (Bug 9576: add AllowTooManyOverride syspref to enable or disable issue limit confirmation)\n";
    SetVersion($DBversion);
}

$DBversion = "3.13.00.014";
if ( CheckVersion($DBversion) ) {
    $dbh->do("ALTER TABLE courses MODIFY COLUMN department varchar(80) DEFAULT NULL;");
    $dbh->do("ALTER TABLE courses MODIFY COLUMN term       varchar(80) DEFAULT NULL;");
    print "Upgrade to $DBversion done (Bug 10604: correct width of courses.department and courses.term)\n";
    SetVersion($DBversion);
}

$DBversion = "3.13.00.015";
if ( CheckVersion($DBversion) ) {
    $dbh->do(
"INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('itemBarcodeFallbackSearch','','If set, enables the automatic use of a keyword catalog search if the phrase entered as a barcode on the checkout page does not turn up any results during an item barcode search',NULL,'YesNo')"
    );
    print "Upgrade to $DBversion done (Bug 7494: Add itemBarcodeFallbackSearch syspref)\n";
    SetVersion($DBversion);
}

$DBversion = "3.13.00.016";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        ALTER TABLE items CHANGE wthdrawn withdrawn TINYINT( 1 ) NOT NULL DEFAULT  '0'
    });

    $dbh->do(q{
        ALTER TABLE deleteditems CHANGE wthdrawn withdrawn TINYINT( 1 ) NOT NULL DEFAULT  '0'
    });

    $dbh->do(q{
        UPDATE saved_sql SET savedsql = REPLACE(savedsql, 'wthdrawn', 'withdrawn')
    });

    $dbh->do(q{
        UPDATE marc_subfield_structure SET kohafield = 'items.withdrawn' WHERE kohafield = 'items.wthdrawn'
    });

    print "Upgrade to $DBversion done (Bug 10550 - Fix database typo wthdrawn)\n";
    SetVersion($DBversion);
}

$DBversion = "3.13.00.017";
if ( CheckVersion($DBversion) ) {
    $dbh->do(
"INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES('OverDriveClientKey','','Client key for OverDrive integration','30','Free')"
    );
    $dbh->do(
"INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES('OverDriveClientSecret','','Client key for OverDrive integration','30','YesNo')"
    );
    $dbh->do(
"INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES('OverDriveLibraryID','','Library ID for OverDrive integration','','Integer')"
    );
    print "Upgrade to $DBversion done (Bug 10320 - Show results from library's OverDrive collection in OPAC search)\n";
    SetVersion($DBversion);
}

$DBversion = "3.13.00.018";
if ( CheckVersion($DBversion) ) {
    $dbh->do(qq{DROP TABLE IF EXISTS aqorders_transfers;});
    $dbh->do(qq{
        CREATE TABLE aqorders_transfers (
          ordernumber_from int(11) NULL,
          ordernumber_to int(11) NULL,
          timestamp timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
          UNIQUE KEY ordernumber_from (ordernumber_from),
          UNIQUE KEY ordernumber_to (ordernumber_to),
          CONSTRAINT aqorders_transfers_ordernumber_from FOREIGN KEY (ordernumber_from) REFERENCES aqorders (ordernumber) ON DELETE SET NULL ON UPDATE CASCADE,
          CONSTRAINT aqorders_transfers_ordernumber_to FOREIGN KEY (ordernumber_to) REFERENCES aqorders (ordernumber) ON DELETE SET NULL ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    });
    print "Upgrade to $DBversion done (Bug 5349: Add aqorders_transfers table)\n";
    SetVersion($DBversion);
}

$DBversion = "3.13.00.019";
if ( CheckVersion($DBversion) ) {
    $dbh->do("ALTER TABLE itemtypes ADD COLUMN checkinmsg VARCHAR(255) AFTER summary;");
    $dbh->do("ALTER TABLE itemtypes ADD COLUMN checkinmsgtype CHAR(16) DEFAULT 'message' NOT NULL AFTER checkinmsg;");
    print "Upgrade to $DBversion done (Bug 10513 - Light up a warning/message when returning a chosen item type)\n";
    SetVersion($DBversion);
}

$DBversion = "3.13.00.020";
if ( CheckVersion($DBversion) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type) VALUES('WhenLostForgiveFine','0',NULL,'If ON, Forgives the fines on an item when it is lost.','YesNo')");
    $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type) VALUES('WhenLostChargeReplacementFee','1',NULL,'If ON, Charge the replacement price when a patron loses an item.','YesNo')");
    print "Upgrade to $DBversion done (Bug 7639: system preferences to forgive fines on lost items)\n";
    SetVersion($DBversion);
}

$DBversion ="3.13.00.021";
if ( CheckVersion($DBversion) ) {
    $dbh->do("INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES('ConfirmFutureHolds','0','Number of days for confirming future holds','','Integer');");
    print "Upgrade to $DBversion done (Bug 9761: Add ConfirmFutureHolds pref)\n";
    SetVersion($DBversion);
}

$DBversion = "3.13.00.022";
if ( CheckVersion($DBversion) ) {
    $dbh->do("DELETE from auth_tag_structure WHERE tagfield IN ('68a','68b')");
    $dbh->do("DELETE from auth_subfield_structure WHERE tagfield IN ('68a','68b')");
    print "Upgrade to $DBversion done (Bug 10687 - Delete erroneous tags 68a and 68b on default MARC21 auth framework)\n";
    SetVersion($DBversion);
}

$DBversion = "3.13.00.023";
if ( CheckVersion($DBversion) ) {
    $dbh->do("ALTER TABLE borrowers CHANGE password password VARCHAR(60);");
    print "Upgrade to $DBversion done (Bug 9611 upgrading password storage system)\n";
    SetVersion($DBversion);
}

$DBversion = "3.13.00.024";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{ALTER TABLE z3950servers ADD COLUMN recordtype VARCHAR(45) NOT NULL DEFAULT 'biblio' AFTER description;});
    print "Upgrade to $DBversion done (Bug 10096 - Add a Z39.50 interface for authority searching)\n";
}

$DBversion = "3.13.00.025";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
   $dbh->do("ALTER TABLE oai_sets_mappings ADD COLUMN operator varchar(8) NOT NULL default 'equal' AFTER marcsubfield;");
   print "Upgrade to $DBversion done (Bug 9295: OAI notequal: add operator column to OAI mappings table)\n";
   SetVersion ($DBversion);
}

$DBversion = "3.13.00.026";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        ALTER TABLE auth_subfield_structure ADD COLUMN defaultvalue TEXT DEFAULT NULL AFTER frameworkcode
    |);
    print "Upgrade to $DBversion done (Bug 10602: Add the column auth_subfield_structure.defaultvalue)\n";
    SetVersion($DBversion);
}

$DBversion = "3.13.00.027";
if ( CheckVersion($DBversion) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type) VALUES ('AllowOfflineCirculation','0','','If on, enables HTML5 offline circulation functionality.','YesNo')");
    print "Upgrade to $DBversion done (Bug 10240: Add syspref AllowOfflineCirculation)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.13.00.028";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        ALTER TABLE export_format ADD type VARCHAR(255) DEFAULT 'marc' AFTER encoding
    });
    $dbh->do(q{
        ALTER TABLE export_format CHANGE marcfields content mediumtext NOT NULL
    });
    print "Upgrade to $DBversion done (Bug 10853: Add new field export_format.type and rename export_format.marcfields with export_format.content)\n";
    SetVersion($DBversion);
}

$DBversion = "3.13.00.029";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO export_format( profile, description, content, csv_separator, type )
        VALUES ( "issues to claim", "Default CSV export for serial issue claims",
                "SUPPLIER=aqbooksellers.name|TITLE=subscription.title|ISSUE NUMBER=serial.serialseq|LATE SINCE=serial.planneddate",
                ",", "sql" )
    });
    print "Upgrade to $DBversion done (Bug 10854: Add the default CSV profile for claiming issues)\n";
    SetVersion($DBversion);
}

$DBversion = "3.13.00.030";
if ( CheckVersion($DBversion) ) {
    $dbh->do(qq{
        DELETE FROM patronimage WHERE NOT EXISTS (SELECT * FROM borrowers WHERE borrowers.cardnumber = patronimage.cardnumber)
    });

    $dbh->do(qq{
        ALTER TABLE patronimage ADD borrowernumber INT( 11 ) NULL FIRST
    });

    $dbh->{AutoCommit} = 0;
    $dbh->{RaiseError} = 1;

    eval {
        $dbh->do(qq{
            UPDATE patronimage LEFT JOIN borrowers USING ( cardnumber ) SET patronimage.borrowernumber = borrowers.borrowernumber
        });
        $dbh->commit();
    };

    if ($@) {
        print "Upgrade to $DBversion done (Bug 10636 - patronimage should have borrowernumber as PK, not cardnumber) failed! Transaction aborted because $@\n";
        eval { $dbh->rollback };
    }
    else {
        $dbh->do(qq{
            ALTER TABLE patronimage DROP FOREIGN KEY patronimage_fk1
        });
        $dbh->do(qq{
            ALTER TABLE patronimage DROP PRIMARY KEY, ADD PRIMARY KEY( borrowernumber )
        });
        $dbh->do(qq{
            ALTER TABLE patronimage DROP cardnumber
        });
        $dbh->do(qq{
            ALTER TABLE patronimage ADD FOREIGN KEY ( borrowernumber ) REFERENCES borrowers ( borrowernumber ) ON DELETE CASCADE ON UPDATE CASCADE
        });

        print "Upgrade to $DBversion done (Bug 10636 - patronimage should have borrowernumber as PK, not cardnumber)\n";
        SetVersion($DBversion);
    }

    $dbh->{AutoCommit} = 1;
    $dbh->{RaiseError} = 0;
}

$DBversion = "3.13.00.031";
if ( CheckVersion($DBversion) ) {

    $dbh->do(q{
        CREATE TABLE IF NOT EXISTS `patron_lists` (
          patron_list_id int(11) NOT NULL AUTO_INCREMENT,
          name varchar(255) CHARACTER SET utf8 NOT NULL,
          owner int(11) NOT NULL,
          PRIMARY KEY (patron_list_id),
          KEY owner (owner)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    });

    $dbh->do(q{
        ALTER TABLE `patron_lists`
          ADD CONSTRAINT patron_lists_ibfk_1 FOREIGN KEY (`owner`) REFERENCES borrowers (borrowernumber) ON DELETE CASCADE ON UPDATE CASCADE;
    });

    $dbh->do(q{
        CREATE TABLE patron_list_patrons (
          patron_list_patron_id int(11) NOT NULL AUTO_INCREMENT,
          patron_list_id int(11) NOT NULL,
          borrowernumber int(11) NOT NULL,
          PRIMARY KEY (patron_list_patron_id),
          KEY patron_list_id (patron_list_id),
          KEY borrowernumber (borrowernumber)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    });

    $dbh->do(q{
        ALTER TABLE `patron_list_patrons`
          ADD CONSTRAINT patron_list_patrons_ibfk_1 FOREIGN KEY (patron_list_id) REFERENCES patron_lists (patron_list_id) ON DELETE CASCADE ON UPDATE CASCADE,
          ADD CONSTRAINT patron_list_patrons_ibfk_2 FOREIGN KEY (borrowernumber) REFERENCES borrowers (borrowernumber) ON DELETE CASCADE ON UPDATE CASCADE;
    });

    $dbh->do(q{
        INSERT INTO permissions (module_bit, code, description) VALUES
        (13, 'manage_patron_lists', 'Add, edit and delete patron lists and their contents')
    });

    print "Upgrade to $DBversion done (Bug 10565 - Add a 'Patron List' feature for storing and manipulating collections of patrons)\n";
    SetVersion($DBversion);
}

$DBversion = "3.13.00.032";
if ( CheckVersion($DBversion) ) {
    $dbh->do("ALTER TABLE aqorders ADD COLUMN orderstatus varchar(16) DEFAULT 'new' AFTER parent_ordernumber");
    $dbh->do("UPDATE aqorders SET orderstatus='ordered' WHERE basketno IN (SELECT basketno FROM aqbasket WHERE closedate IS NOT NULL)");
    $dbh->do(q{
        UPDATE aqorders SET orderstatus='partial'
        WHERE quantity > quantityreceived
        AND quantityreceived > 0
        AND ordernumber IN (
            SELECT parent_ordernumber
            FROM (
                SELECT DISTINCT(parent_ordernumber)
                FROM aqorders
                WHERE ordernumber != parent_ordernumber
            ) AS aq
        )
        AND basketno IN (SELECT basketno FROM aqbasket WHERE closedate IS NOT NULL)
    });
    $dbh->do("UPDATE aqorders SET orderstatus='complete' WHERE quantity=quantityreceived");
    $dbh->do("UPDATE aqorders SET orderstatus='cancelled' WHERE datecancellationprinted IS NOT NULL");
    print "Upgrade to $DBversion done (Bug 5336: Add the new column aqorders.orderstatus)\n";
    SetVersion($DBversion);
}

$DBversion = "3.13.00.033";
if ( CheckVersion($DBversion) ) {
    $dbh->do(qq|
        DROP TABLE IF EXISTS subscription_frequencies
    |);
    $dbh->do(qq|
        CREATE TABLE subscription_frequencies (
            id INTEGER NOT NULL AUTO_INCREMENT,
            description TEXT NOT NULL,
            displayorder INT DEFAULT NULL,
            unit ENUM('day','week','month','year') DEFAULT NULL,
            unitsperissue INTEGER NOT NULL DEFAULT '1',
            issuesperunit INTEGER NOT NULL DEFAULT '1',
            PRIMARY KEY (id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8
    |);

    $dbh->do(qq|
        DROP TABLE IF EXISTS subscription_numberpatterns
    |);
    $dbh->do(qq|
        CREATE TABLE subscription_numberpatterns (
            id INTEGER NOT NULL AUTO_INCREMENT,
            label VARCHAR(255) NOT NULL,
            displayorder INTEGER DEFAULT NULL,
            description TEXT NOT NULL,
            numberingmethod VARCHAR(255) NOT NULL,
            label1 VARCHAR(255) DEFAULT NULL,
            add1 INTEGER DEFAULT NULL,
            every1 INTEGER DEFAULT NULL,
            whenmorethan1 INTEGER DEFAULT NULL,
            setto1 INTEGER DEFAULT NULL,
            numbering1 VARCHAR(255) DEFAULT NULL,
            label2 VARCHAR(255) DEFAULT NULL,
            add2 INTEGER DEFAULT NULL,
            every2 INTEGER DEFAULT NULL,
            whenmorethan2 INTEGER DEFAULT NULL,
            setto2 INTEGER DEFAULT NULL,
            numbering2 VARCHAR(255) DEFAULT NULL,
            label3 VARCHAR(255) DEFAULT NULL,
            add3 INTEGER DEFAULT NULL,
            every3 INTEGER DEFAULT NULL,
            whenmorethan3 INTEGER DEFAULT NULL,
            setto3 INTEGER DEFAULT NULL,
            numbering3 VARCHAR(255) DEFAULT NULL,
            PRIMARY KEY (id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8
    |);

    $dbh->do(qq|
        INSERT INTO subscription_frequencies (description, unit, unitsperissue, issuesperunit, displayorder)
        VALUES
            ('2/day', 'day', 1, 2, 1),
            ('1/day', 'day', 1, 1, 2),
            ('3/week', 'week', 1, 3, 3),
            ('1/week', 'week', 1, 1, 4),
            ('1/2 weeks', 'week', 2, 1, 5),
            ('1/3 weeks', 'week', 3, 1, 6),
            ('1/month', 'month', 1, 1, 7),
            ('1/2 months', 'month', 2, 1, 8),
            ('1/3 months', 'month', 3, 1, 9),
            ('2/year', 'month', 6, 1, 10),
            ('1/year', 'year', 1, 1, 11),
            ('1/2 year', 'year', 2, 1, 12),
            ('Irregular', NULL, 1, 1, 13)
    |);

    # Used to link existing subscription to newly created frequencies
    my $frequencies_mapping = {     # keys are old frequency numbers, values are the new ones
        1 => 2,     # daily (n/week)
        2 => 4,     # 1/week
        3 => 5,     # 1/2 weeks
        4 => 6,     # 1/3 weeks
        5 => 7,     # 1/month
        6 => 8,     # 1/2 months (6/year)
        7 => 9,     # 1/3 months (1/quarter)
        8 => 9,    # 1/quarter (seasonal)
        9 => 10,    # 2/year
        10 => 11,   # 1/year
        11 => 12,   # 1/2 years
        12 => 1,    # 2/day
        16 => 13,   # Without periodicity
        32 => 13,   # Irregular
        48 => 13    # Unknown
    };

    $dbh->do(qq|
        INSERT INTO subscription_numberpatterns
            (label, displayorder, description, numberingmethod,
            label1, add1, every1, whenmorethan1, setto1, numbering1,
            label2, add2, every2, whenmorethan2, setto2, numbering2,
            label3, add3, every3, whenmorethan3, setto3, numbering3)
        VALUES
            ('Number', 1, 'Simple Numbering method', 'No.{X}',
            'Number', 1, 1, 99999, 1, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL),

            ('Volume, Number, Issue', 2, 'Volume Number Issue 1', 'Vol.{X}, Number {Y}, Issue {Z}',
            'Volume', 1, 48, 99999, 1, NULL,
            'Number', 1, 4, 12, 1, NULL,
            'Issue', 1, 1, 4, 1, NULL),

            ('Volume, Number', 3, 'Volume Number 1', 'Vol {X}, No {Y}',
            'Volume', 1, 12, 99999, 1, NULL,
            'Number', 1, 1, 12, 1, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL),

            ('Seasonal', 4, 'Season Year', '{X} {Y}',
            'Season', 1, 1, 3, 0, 'season',
            'Year', 1, 4, 99999, 1, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL)
    |);

    $dbh->do(qq|
        ALTER TABLE subscription
        MODIFY COLUMN numberpattern INTEGER DEFAULT NULL,
        MODIFY COLUMN periodicity INTEGER DEFAULT NULL
    |);

    # Update existing subscriptions

    my $query = qq|
        SELECT subscriptionid, periodicity, numberingmethod,
            add1, every1, whenmorethan1, setto1,
            add2, every2, whenmorethan2, setto2,
            add3, every3, whenmorethan3, setto3
        FROM subscription
        ORDER BY subscriptionid
    |;
    my $sth = $dbh->prepare($query);
    $sth->execute;
    my $insert_numberpatterns_sth = $dbh->prepare(qq|
        INSERT INTO subscription_numberpatterns
             (label, displayorder, description, numberingmethod,
            label1, add1, every1, whenmorethan1, setto1, numbering1,
            label2, add2, every2, whenmorethan2, setto2, numbering2,
            label3, add3, every3, whenmorethan3, setto3, numbering3)
        VALUES
            (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    |);
    my $check_numberpatterns_sth = $dbh->prepare(qq|
        SELECT * FROM subscription_numberpatterns
        WHERE (add1 = ? OR (add1 IS NULL AND ? IS NULL)) AND (add2 = ? OR (add2 IS NULL AND ? IS NULL))
        AND (add3 = ? OR (add3 IS NULL AND ? IS NULL)) AND (every1 = ? OR (every1 IS NULL AND ? IS NULL))
        AND (every2 = ? OR (every2 IS NULL AND ? IS NULL)) AND (every3 = ? OR (every3 IS NULL AND ? IS NULL))
        AND (whenmorethan1 = ? OR (whenmorethan1 IS NULL AND ? IS NULL)) AND (whenmorethan2 = ? OR (whenmorethan2 IS NULL AND ? IS NULL))
        AND (whenmorethan3 = ? OR (whenmorethan3 IS NULL AND ? IS NULL)) AND (setto1 = ? OR (setto1 IS NULL AND ? IS NULL))
        AND (setto2 = ? OR (setto2 IS NULL AND ? IS NULL)) AND (setto3 = ? OR (setto3 IS NULL AND ? IS NULL))
        AND (numberingmethod = ? OR (numberingmethod IS NULL AND ? IS NULL))
        LIMIT 1
    |);
    my $update_subscription_sth = $dbh->prepare(qq|
        UPDATE subscription
        SET numberpattern = ?,
            periodicity = ?
        WHERE subscriptionid = ?
    |);

    my $i = 1;
    while(my $sub = $sth->fetchrow_hashref) {
        $check_numberpatterns_sth->execute(
            $sub->{add1}, $sub->{add1}, $sub->{add2}, $sub->{add2}, $sub->{add3}, $sub->{add3},
            $sub->{every1}, $sub->{every1}, $sub->{every2}, $sub->{every2}, $sub->{every3}, $sub->{every3},
            $sub->{whenmorethan1}, $sub->{whenmorethan1}, $sub->{whenmorethan2}, $sub->{whenmorethan2},
            $sub->{whenmorethan3}, $sub->{whenmorethan3}, $sub->{setto1}, $sub->{setto1}, $sub->{setto2},
            $sub->{setto2}, $sub->{setto3}, $sub->{setto3}, $sub->{numberingmethod}, $sub->{numberingmethod}
        );
        my $p = $check_numberpatterns_sth->fetchrow_hashref;
        if (defined $p) {
            # Pattern already exists, link to it
            $update_subscription_sth->execute($p->{id},
                $frequencies_mapping->{$sub->{periodicity}},
                $sub->{subscriptionid});
        } else {
            # Create a new numbering pattern for this subscription
            my $ok = $insert_numberpatterns_sth->execute(
                "Backup pattern $i", 4+$i, "Automatically created pattern by updatedatabase", $sub->{numberingmethod},
                "X", $sub->{add1}, $sub->{every1}, $sub->{whenmorethan1}, $sub->{setto1}, undef,
                "Y", $sub->{add2}, $sub->{every2}, $sub->{whenmorethan2}, $sub->{setto2}, undef,
                "Z", $sub->{add3}, $sub->{every3}, $sub->{whenmorethan3}, $sub->{setto3}, undef
            );
            if($ok) {
                my $id = $dbh->last_insert_id(undef, undef, 'subscription_numberpatterns', undef);
                # Link to subscription_numberpatterns and subscription_frequencies
                $update_subscription_sth->execute($id,
                    $frequencies_mapping->{$sub->{periodicity}},
                    $sub->{subscriptionid});
            }
            $i++;
        }
    }

    # Remove now useless columns
    $dbh->do(qq|
        ALTER TABLE subscription
        DROP COLUMN numberingmethod,
        DROP COLUMN add1,
        DROP COLUMN every1,
        DROP COLUMN whenmorethan1,
        DROP COLUMN setto1,
        DROP COLUMN add2,
        DROP COLUMN every2,
        DROP COLUMN whenmorethan2,
        DROP COLUMN setto2,
        DROP COLUMN add3,
        DROP COLUMN every3,
        DROP COLUMN whenmorethan3,
        DROP COLUMN setto3,
        DROP COLUMN dow,
        DROP COLUMN issuesatonce,
        DROP COLUMN hemisphere,
        ADD COLUMN countissuesperunit INTEGER NOT NULL DEFAULT 1 AFTER periodicity,
        ADD COLUMN skip_serialseq BOOLEAN NOT NULL DEFAULT 0 AFTER irregularity,
        ADD COLUMN locale VARCHAR(80) DEFAULT NULL AFTER numberpattern,
        ADD CONSTRAINT subscription_ibfk_1 FOREIGN KEY (periodicity) REFERENCES subscription_frequencies (id) ON DELETE SET NULL ON UPDATE CASCADE,
        ADD CONSTRAINT subscription_ibfk_2 FOREIGN KEY (numberpattern) REFERENCES subscription_numberpatterns (id) ON DELETE SET NULL ON UPDATE CASCADE
    |);

    # Set firstacquidate if not already set (firstacquidate is now mandatory)
    my $get_first_planneddate_sth = $dbh->prepare(qq|
        SELECT planneddate
        FROM serial
        WHERE subscriptionid = ?
        ORDER BY serialid
        LIMIT 1
    |);
    my $update_firstacquidate_sth = $dbh->prepare(qq|
        UPDATE subscription
        SET firstacquidate = ?
        WHERE subscriptionid = ?
    |);
    my $get_subscriptions_sth = $dbh->prepare(qq|
        SELECT subscriptionid, startdate
        FROM subscription
        WHERE firstacquidate IS NULL
          OR firstacquidate = '0000-00-00'
    |);
    $get_subscriptions_sth->execute;
    while ( my ($subscriptionid, $startdate) = $get_subscriptions_sth->fetchrow ) {
        # Try to get the planned date of the first serial
        $get_first_planneddate_sth->execute($subscriptionid);
        my ($first_planneddate) = $get_first_planneddate_sth->fetchrow;
        if ($first_planneddate and $first_planneddate =~ /^\d{4}-\d{2}-\d{2}$/) {
            $update_firstacquidate_sth->execute($first_planneddate, $subscriptionid);
        } else {
            # Defaults to subscription start date
            $update_firstacquidate_sth->execute($startdate, $subscriptionid);
        }
    }

    print "Upgrade to $DBversion done (Bug 7688: add subscription_frequencies and subscription_numberpatterns tables)\n";
    SetVersion($DBversion);
}

$DBversion = "3.13.00.034";
if ( CheckVersion($DBversion) ) {
    $dbh->do("
        ALTER TABLE `import_batches`
        CHANGE `item_action` `item_action`
          ENUM( 'always_add', 'add_only_for_matches', 'add_only_for_new', 'ignore', 'replace' )
          NOT NULL DEFAULT 'always_add'
    ");
    print "Upgrade to $DBversion done (Bug 7131 - way to overlay items in in marc import)\n";
    SetVersion($DBversion);
}

$DBversion ="3.13.00.035";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
CREATE TABLE borrower_debarments (
  borrower_debarment_id int(11) NOT NULL AUTO_INCREMENT,
  borrowernumber int(11) NOT NULL,
  expiration date DEFAULT NULL,
  `type` enum('SUSPENSION','OVERDUES','MANUAL') NOT NULL DEFAULT 'MANUAL',
  `comment` text,
  manager_id int(11) DEFAULT NULL,
  created timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  updated timestamp NULL DEFAULT NULL,
  PRIMARY KEY (borrower_debarment_id),
  KEY borrowernumber (borrowernumber) ,
  CONSTRAINT `borrower_debarments_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;
    });

    # debarments with end date
    $dbh->do(q{
INSERT INTO borrower_debarments ( borrowernumber, expiration, comment ) SELECT borrowernumber, debarred, debarredcomment FROM borrowers WHERE debarred IS NOT NULL AND debarred <> '9999-12-31'
    });
    # debarments with no end date
    $dbh->do(q{
INSERT INTO borrower_debarments ( borrowernumber, comment ) SELECT borrowernumber, debarredcomment FROM borrowers WHERE debarred = '9999-12-31'
    });

    $dbh->do(q{
INSERT IGNORE INTO systempreferences (variable,value,explanation,type) VALUES
('AutoRemoveOverduesRestrictions','0','Defines whether an OVERDUES debarment should be lifted automatically if all overdue items are returned by the patron.','YesNo')
    });

    print "Upgrade to $DBversion done (Bug 2720 - Overdues which debar automatically should undebar automatically when returned)\n";
    SetVersion($DBversion);
}

$DBversion = "3.13.00.036";
if ( CheckVersion($DBversion) ) {
    $dbh->do(qq{
        INSERT INTO systempreferences (variable, value, explanation, options, type)
        VALUES ('StaffDetailItemSelection', '1', 'Enable item selection in record detail page', NULL, 'YesNo')
    });
    print "Upgrade to $DBversion done (Add system preference StaffDetailItemSelection)\n";
    SetVersion($DBversion);
}

$DBversion = "3.13.00.037";
if ( CheckVersion($DBversion) ) {
    #add phone if it is not there already (explains the ignore option)
    $dbh->do("
INSERT IGNORE INTO message_transport_types (message_transport_type) values ('phone');
    ");
    print "Upgrade to $DBversion done (Bug 10572: Add phone to message_transport_types table for new installs)\n";
    SetVersion($DBversion);
}

$DBversion = "3.13.00.038";
if ( CheckVersion($DBversion) ) {
    $dbh->do("INSERT INTO permissions (module_bit, code, description) VALUES(15, 'superserials', 'Manage subscriptions from any branch (only applies when IndependentBranches is used)')");
    print "Upgrade to $DBversion done (Bug 8435: Add superserials permission)\n";
    SetVersion($DBversion);
}

$DBversion = "3.13.00.039";
if ( CheckVersion($DBversion) ) {
    $dbh->do("
        ALTER TABLE aqbasket ADD branch varchar(10) default NULL
    ");
    $dbh->do("
        ALTER TABLE aqbasket
        ADD CONSTRAINT aqbasket_ibfk_4 FOREIGN KEY (branch)
            REFERENCES branches (branchcode)
            ON UPDATE CASCADE ON DELETE SET NULL
    ");
    $dbh->do("
        DROP TABLE IF EXISTS aqbasketusers
    ");
    $dbh->do("
        CREATE TABLE aqbasketusers (
            basketno int(11) NOT NULL,
            borrowernumber int(11) NOT NULL,
            PRIMARY KEY (basketno,borrowernumber),
            CONSTRAINT aqbasketusers_ibfk_1 FOREIGN KEY (basketno) REFERENCES aqbasket (basketno) ON DELETE CASCADE ON UPDATE CASCADE,
            CONSTRAINT aqbasketusers_ibfk_2 FOREIGN KEY (borrowernumber) REFERENCES borrowers (borrowernumber) ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    ");
    $dbh->do("
        INSERT INTO permissions (module_bit, code, description)
        VALUES (11, 'order_manage_all', 'Manage all orders and baskets, regardless of restrictions on them')
    ");

    print "Upgrade to $DBversion done (Add branch and users list to baskets. "
        . "New permission order_manage_all)\n";
    SetVersion($DBversion);
}

$DBversion = "3.13.00.040";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("CREATE TABLE IF NOT EXISTS marc_modification_templates (
              template_id int(11) NOT NULL auto_increment,
              name text NOT NULL,
              PRIMARY KEY  (template_id)
              ) ENGINE=InnoDB  DEFAULT CHARSET=utf8;"
    );

    $dbh->do("
      CREATE TABLE IF NOT EXISTS marc_modification_template_actions (
      mmta_id int(11) NOT NULL auto_increment,
      template_id int(11) NOT NULL,
      ordering int(3) NOT NULL,
      action enum('delete_field','update_field','move_field','copy_field') NOT NULL,
      field_number smallint(6) NOT NULL default '0',
      from_field varchar(3) NOT NULL,
      from_subfield varchar(1) NULL,
      field_value varchar(100) default NULL,
      to_field varchar(3) default NULL,
      to_subfield varchar(1) default NULL,
      to_regex_search text,
      to_regex_replace text,
      to_regex_modifiers varchar(8) default '',
      conditional enum('if','unless') default NULL,
      conditional_field varchar(3) default NULL,
      conditional_subfield varchar(1) default NULL,
      conditional_comparison enum('exists','not_exists','equals','not_equals') default NULL,
      conditional_value text,
      conditional_regex tinyint(1) NOT NULL default '0',
      description text,
      PRIMARY KEY  (mmta_id),
      CONSTRAINT `mmta_ibfk_1` FOREIGN KEY (`template_id`) REFERENCES `marc_modification_templates` (`template_id`) ON DELETE CASCADE ON UPDATE CASCADE
      ) ENGINE=InnoDB  DEFAULT CHARSET=utf8;
    ");

    $dbh->do("INSERT INTO permissions (module_bit, code, description) VALUES ('13', 'marc_modification_templates', 'Manage marc modification templates')");

    print "Upgrade to $DBversion done ( Bug 8015: Added tables for MARC Modification Framework )\n";
    SetVersion($DBversion);
}

$DBversion = "3.13.00.041";
if(CheckVersion($DBversion)) {
    $dbh->do(q{
        INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('AcqItemSetSubfieldsWhenReceived','','Set subfields for item when items are created when receiving (e.g. o=5|a="foo bar")','','Free');
    });
    print "Upgrade to $DBversion done (Bug 10986: Added AcqItemSetSubfieldsWhenReceived syspref)\n";
    SetVersion($DBversion);
}

$DBversion = "3.13.00.042";
if(CheckVersion($DBversion)) {
    print "Upgrade to $DBversion done (Koha 3.14 beta)\n";
    SetVersion($DBversion);
}

$DBversion = "3.13.00.043";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES('SearchEngine','Zebra','Solr|Zebra','Search Engine','Choice')");
    print "Upgrade to $DBversion done (Bug 11196: Add system preference SearchEngine if missing )\n";
    SetVersion($DBversion);
}

$DBversion = "3.14.00.000";
if ( CheckVersion($DBversion) ) {
    print "Upgrade to $DBversion done (3.14.0 release)\n";
    SetVersion ($DBversion);
}

$DBversion = '3.15.00.000';
if ( CheckVersion($DBversion) ) {
    print "Upgrade to $DBversion done (the road goes ever on)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.15.00.001";
if ( CheckVersion($DBversion) ) {
    $dbh->do("UPDATE systempreferences SET value='clear' where variable = 'CircAutoPrintQuickSlip' and value = '0'");
    $dbh->do("UPDATE systempreferences SET value='qslip' where variable = 'CircAutoPrintQuickSlip' and value = '1'");
    $dbh->do("UPDATE systempreferences SET explanation = 'Choose what should happen when an empty barcode field is submitted in circulation: Display a print quick slip window, Display a print slip window or Clear the screen.', type = 'Choice' where variable = 'CircAutoPrintQuickSlip'");
    print "Upgrade to $DBversion done (Bug 11040: Add option to print full slip when checking out a null barcode)\n";
    SetVersion($DBversion);
}

$DBversion = "3.15.00.002";
if(CheckVersion($DBversion)) {
    $dbh->do("ALTER TABLE deleteditems MODIFY materials text;");
    print "Upgrade to $DBversion done (Bug 11275: alter deleteditems.materials from varchar(10) to text)\n";
    SetVersion($DBversion);
}

$DBversion = "3.15.00.003";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        UPDATE accountlines
        SET description = ''
        WHERE description IN (
            ' New Card',
            ' Fine',
            ' Sundry',
            'Writeoff',
            ' Account Management fee',
            'Payment,thanks', 'Payment,thanks - ',
            ' Lost Item'
        )
    });
    print "Upgrade to $DBversion done (Bug 2546: Update fine descriptions)\n";
    SetVersion($DBversion);
}

$DBversion = "3.15.00.004";
if ( CheckVersion($DBversion) ) {
    if ( C4::Context->preference("marcflavour") eq 'MARC21' ) {
        $dbh->do(qq{
            INSERT IGNORE INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory,
            kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link,
            defaultvalue) VALUES
            ('015', 'q', 'Qualifying information', 'Qualifying information', 1, 0, '', 0, '', '', '', 0, 0, '', '', '', NULL),
            ('020', 'q', 'Qualifying information', 'Qualifying information', 1, 0, '', 0, '', '', '', 0, 0, '', '', '', NULL),
            ('024', 'q', 'Qualifying information', 'Qualifying information', 1, 0, '', 0, '', '', '', 0, 0, '', '', '', NULL),
            ('027', 'q', 'Qualifying information', 'Qualifying information', 1, 0, '', 0, '', '', '', 0, 0, '', '', '', NULL),
            ('800', '7', 'Control subfield', 'Control subfield', 0, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
            ('810', '7', 'Control subfield', 'Control subfield', 0, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
            ('811', '7', 'Control subfield', 'Control subfield', 0, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL),
            ('830', '7', 'Control subfield', 'Control subfield', 0, 0, '', 8, '', '', '', NULL, -6, '', '', '', NULL);
        });
        $dbh->do(qq{
            INSERT IGNORE INTO auth_subfield_structure (authtypecode, tagfield, tagsubfield, liblibrarian, libopac, repeatable,
            mandatory, tab, authorised_value, value_builder, seealso, isurl, hidden, linkid, kohafield, frameworkcode) VALUES
            ('', '020', 'q', 'Qualifying information', 'Qualifying information', 1, 0, 0, NULL, NULL, NULL, 0, 0, '', '', ''),
            ('', '024', 'q', 'Qualifying information', 'Qualifying information', 1, 0, 0, NULL, NULL, NULL, 0, 0, '', '', '');
        });
    }
    print "Upgrade to $DBversion done (Bug 10970 - Update MARC21 frameworks to Update Nr. 17 - DB update)\n";
    SetVersion($DBversion);
}

$DBversion = "3.15.00.005";
if ( CheckVersion($DBversion) ) {
   $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type) VALUES('AcquisitionDetails', '1', '', 'Hide/Show acquisition details on the biblio detail page.', 'YesNo');");
   print "Upgrade to $DBversion done (Bug 8230: Add AcquisitionDetails system preference)\n";
   SetVersion ($DBversion);
}

$DBversion = "3.15.00.006";
if(CheckVersion($DBversion)) {
    $dbh->do(q{
        ALTER TABLE `borrowers`
        ADD KEY `surname_idx` (`surname`(255)),
        ADD KEY `firstname_idx` (`firstname`(255)),
        ADD KEY `othernames_idx` (`othernames`(255))
    });
    print "Upgrade to $DBversion done (Bug 11249 - Add DB indexes on borrower names)\n";
    SetVersion($DBversion);
}

$DBversion = "3.15.00.007";
if ( CheckVersion($DBversion) ) {
   $dbh->do("ALTER TABLE items ADD itemlost_on DATETIME NULL AFTER itemlost");
   $dbh->do("ALTER TABLE items ADD withdrawn_on DATETIME NULL AFTER withdrawn");
   $dbh->do("ALTER TABLE deleteditems ADD itemlost_on DATETIME NULL AFTER itemlost");
   $dbh->do("ALTER TABLE deleteditems ADD withdrawn_on DATETIME NULL AFTER withdrawn");
   print "Upgrade to $DBversion done (Bug 9673 - Track when items are marked as lost or withdrawn)\n";
   SetVersion ($DBversion);
}

$DBversion = "3.15.00.008";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        ALTER TABLE collections_tracking CHANGE ctId collections_tracking_id integer(11) NOT NULL auto_increment;
    });
    print "Upgrade to $DBversion done (Bug 11384) - change name of collections_tracker.ctId column)\n";
   SetVersion ($DBversion);
}

$DBversion = "3.15.00.009";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        ALTER TABLE suggestions MODIFY suggesteddate DATE NOT NULL
    });
    print "Upgrade to $DBversion done (Bug 11391) - drop default value on suggestions.suggesteddate column)\n";
   SetVersion ($DBversion);
}

$DBversion = "3.15.00.010";
if(CheckVersion($DBversion)) {
    $dbh->do("ALTER TABLE deleteditems DROP COLUMN marc");
    print "Upgrade to $DBversion done (Bug 6331: remove obsolete column in deleteditems.marc)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.15.00.011";
if(CheckVersion($DBversion)) {
    $dbh->do("UPDATE marc_subfield_structure SET maxlength=9999 WHERE maxlength IS NULL OR maxlength=0;");
    print "Upgrade to $DBversion done (Bug 8018: set 9999 as default max length for subfields)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.15.00.012";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT INTO permissions (module_bit, code, description) VALUES ( 1, 'force_checkout', 'Force checkout if a limitation exists')
    });
    $dbh->do(q{
        INSERT INTO permissions (module_bit, code, description) VALUES ( 1, 'manage_restrictions', 'Manage restrictions for accounts')
    });
    $dbh->do(q{
        INSERT INTO user_permissions (borrowernumber, module_bit, code)
            SELECT user_permissions.borrowernumber, 1, 'force_checkout'
            FROM user_permissions
            LEFT JOIN borrowers USING(borrowernumber)
            WHERE borrowers.flags & (1 << 1)
    });
    $dbh->do(q{
        INSERT INTO user_permissions (borrowernumber, module_bit, code)
            SELECT user_permissions.borrowernumber, 1, 'manage_restrictions'
            FROM user_permissions
            LEFT JOIN borrowers USING(borrowernumber)
            WHERE borrowers.flags & (1 << 1)
    });

    print "Upgrade to $DBversion done (Bug 10863 - Add permissions force_checkout and manage_restrictions)\n";
    SetVersion($DBversion);
}

$DBversion = "3.15.00.013";
if(CheckVersion($DBversion)) {
    $dbh->do(q{
        UPDATE systempreferences
        SET explanation = 'Upon receiving items, update their subfields if they were created when placing an order (e.g. o=5|a="foo bar")'
        WHERE variable = "AcqItemSetSubfieldsWhenReceived"
    });

    $dbh->do(q{
        UPDATE systempreferences
        SET value = ''
        WHERE variable = "AcqItemSetSubfieldsWhenReceived"
            AND value = "0"
    });
    print "Upgrade to $DBversion done (Bug 11237: Update explanation and default value for AcqItemSetSubfieldsWhenReceived syspref)\n";
    SetVersion($DBversion);
}

$DBversion = "3.15.00.014";
if (CheckVersion($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,options,explanation,type) VALUES('SelfCheckReceiptPrompt', '1', 'NULL', 'If ON, print receipt dialog pops up when self checkout is finished.', 'YesNo');");
    print "Upgrade to $DBversion done (Bug 11415: add system preference for automatic self checkout receipt printing)\n";
    SetVersion($DBversion);
}

$DBversion = "3.15.00.015";
if (CheckVersion($DBversion)) {
    $dbh->do("INSERT INTO systempreferences ( variable, value, options, explanation, type ) VALUES
        ('OpacSuggestionManagedBy',1,'','Show the name of the staff member who managed a suggestion in OPAC','YesNo');");
    print "Upgrade to $DBversion done (Bug 10907: Add OpacSuggestionManagedBy system preference)\n";
    SetVersion($DBversion);
}

$DBversion = "3.15.00.016";
if (CheckVersion($DBversion)) {
    $dbh->do("ALTER TABLE biblioitems CHANGE url url TEXT NULL DEFAULT NULL");
    $dbh->do("ALTER TABLE deletedbiblioitems CHANGE url url TEXT NULL DEFAULT NULL");
    print "Upgrade to $DBversion done (Bug 11268 - Biblioitems URL field is too small for some URLs)\n";
    SetVersion($DBversion);
}

$DBversion = "3.15.00.017";
if(CheckVersion($DBversion)) {
    $dbh->do(q{
        UPDATE systempreferences
        SET explanation = 'Define the contents of UNIMARC authority control field 100 position 08-35'
        WHERE variable = "UNIMARCAuthorityField100"
    });
    $dbh->do(q{
        UPDATE systempreferences
        SET explanation = 'Define the contents of MARC21 authority control field 008 position 06-39'
        WHERE variable = "MARCAuthorityControlField008"
    });
    $dbh->do(q{
        UPDATE systempreferences
        SET explanation = 'Define MARC Organization Code for MARC21 records - http://www.loc.gov/marc/organizations/orgshome.html'
        WHERE variable = "MARCOrgCode"
    });
    print "Upgrade to $DBversion done (Bug 11611 - fix possible confusion between UNIMARC and MARC21 in some sysprefs)\n";
    SetVersion($DBversion);
}

$DBversion = "3.15.00.018";
if ( CheckVersion($DBversion) ) {
    $dbh->{AutoCommit} = 0;
    $dbh->{RaiseError} = 1;

    eval {
        $dbh->selectcol_arrayref(q|SELECT COUNT(*) FROM roadtype|);
    };
    unless ( $@ ) {
        my $av_added = $dbh->do(q|
            INSERT INTO authorised_values(category, authorised_value, lib, lib_opac)
                SELECT 'ROADTYPE', roadtypeid, road_type, road_type
                FROM roadtype;
        |);

        my $rt_deleted = $dbh->do(q|
            DELETE FROM roadtype
        |);

        if ( $av_added == $rt_deleted or $rt_deleted eq "0E0" ) {
            $dbh->do(q|
                DROP TABLE roadtype;
            |);
            $dbh->commit;
            print "Upgrade to $DBversion done (Bug 7372: Move road types from the roadtype table to the ROADTYPE authorised values)\n";
            SetVersion($DBversion);
        } else {
            print "Upgrade to $DBversion failed (Bug 7372: Move road types from the roadtype table to the ROADTYPE authorised values.\nTransaction aborted because $@\n)";
            $dbh->rollback;
        }
    }
    $dbh->{AutoCommit} = 1;
    $dbh->{RaiseError} = 0;
}

$DBversion = "3.15.00.019";
if ( CheckVersion($DBversion) ) {
    $dbh->do("INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES('OpacMaxItemsToDisplay','50','','Max items to display at the OPAC on a biblio detail','Integer')");
    print "Upgrade to $DBversion done (Bug 11256: Add system preference OpacMaxItemsToDisplay)\n";
    SetVersion($DBversion);
}

$DBversion = "3.15.00.020";
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES('MaxItemsForBatch','1000',NULL,'Max number of items record to process in a batch (modification or deletion)','Integer')
    |);
    print "Upgrade to $DBversion done (Bug 11343: Add system preference MaxItemsForBatch )\n";
    SetVersion($DBversion);
}

$DBversion = "3.15.00.021";
if(CheckVersion($DBversion)) {
    $dbh->do(q{
        ALTER TABLE `action_logs`
            DROP KEY timestamp,
            ADD KEY `timestamp_idx` (`timestamp`),
            ADD KEY `user_idx` (`user`),
            ADD KEY `module_idx` (`module`(255)),
            ADD KEY `action_idx` (`action`(255)),
            ADD KEY `object_idx` (`object`),
            ADD KEY `info_idx` (`info`(255))
    });
    print "Upgrade to $DBversion done (Bug 3445: Add indexes to action_logs table)\n";
    SetVersion($DBversion);
}

$DBversion = "3.15.00.022";
if (CheckVersion($DBversion)) {
    $dbh->do(q|
        DELETE FROM systempreferences WHERE variable= "memberofinstitution"
    |);
    print "Upgrade to $DBversion done (Bug 11751: Remove memberofinstitytion system preference)\n";
    SetVersion($DBversion);
}

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
          date_created timestamp NULL DEFAULT NULL,
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
        VALUES ('circulation', 'CHECKOUT_NOTE', '', 'Checkout note on item set by patron', '0', 'Checkout note', '<<borrowers.firstname>> <<borrowers.surname>> has added a note to the item <<biblio.title>> - <<biblio.author>> (<<biblio.biblionumber>>).','email');
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

        my $expirationdate = dt_from_string($hold->waitingdate);
        if ( C4::Context->preference("ExcludeHolidaysFromMaxPickUpDelay") ) {
            my $calendar = Koha::Calendar->new( branchcode => $hold->branchcode );
            $expirationdate = $calendar->days_forward( $expirationdate, $max_pickup_delay );
        } else {
            $expirationdate->add( days => $max_pickup_delay );
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

$DBversion = '17.06.00.002';
if ( CheckVersion($DBversion) ) {

    unless ( column_exists('virtualshelves', 'allow_change_from_owner' ) ) {
        $dbh->do(q|
            ALTER TABLE virtualshelves
            ADD COLUMN allow_change_from_owner tinyint(1) default 1,
            ADD COLUMN allow_change_from_others tinyint(1) default 0
        |);

        # Conversion:
        # Since we had no readonly lists, change_from_owner is set to true.
        # When adding or delete_other was granted, change_from_others is true.
        # Note: In my opinion the best choice; there is no exact match.
        $dbh->do(q|
            UPDATE virtualshelves
            SET allow_change_from_owner = 1,
                allow_change_from_others = CASE WHEN allow_add=1 OR allow_delete_other=1 THEN 1 ELSE 0 END
        |);

        # Remove the old columns
        $dbh->do(q|
            ALTER TABLE virtualshelves
            DROP COLUMN allow_add,
            DROP COLUMN allow_delete_own,
            DROP COLUMN allow_delete_other
        |);
    }

    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 18228 - Alter table virtualshelves to simplify permissions)\n";
}

$DBversion = '17.06.00.003';
if ( CheckVersion($DBversion) ) {

    # Fetch all auth types
    my $authtypes = $dbh->selectcol_arrayref(q|SELECT authtypecode FROM auth_types|);

    if ( grep { $_ eq 'Default' } @$authtypes ) {

        # If this exists as an authtypecode, we don't do anything
    }
    else {
        # Replace the incorrect Default by empty string
        $dbh->do(q|
            UPDATE auth_header SET authtypecode='' WHERE authtypecode='Default'
        |);
    }

    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 18801 - Update incorrect Default auth type codes)\n";
}

$DBversion = '17.06.00.004';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('GoogleOpenIDConnectAutoRegister',   '0',NULL,' Google OpenID Connect logins to auto-register patrons.','YesNo'),
        ('GoogleOpenIDConnectDefaultCategory','','','This category code will be used to create Google OpenID Connect patrons.','Textarea'),
        ('GoogleOpenIDConnectDefaultBranch',  '','','This branch code will be used to create Google OpenID Connect patrons.','Textarea');
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 16892: Add automatic patron registration via OAuth2 login)\n";
}

$DBversion = '17.06.00.005';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type`) VALUES  ('StaffLangSelectorMode','footer','top|both|footer','Select the location to display the language selector in staff client','Choice')
        });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18718 - Language selector in staff header menu similar to OPAC )\n";
}

$DBversion = '17.06.00.006';
if( CheckVersion( $DBversion ) ) {
    print q{WARNING: Bug 18811 fixed an inconsistency in the visibility settings for authority frameworks. It is recommended that you run script misc/maintenance/auth_show_hidden_data.pl to check if you have data in hidden fields and adjust your frameworks accordingly to prevent data loss when editing such records.};
    print "\n";

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18811 - Visibility settings inconsistent between framework and authority editor)\n";
}

$DBversion = '17.06.00.007';
if( CheckVersion( $DBversion ) ) {
    if( !column_exists( 'branches', 'marcorgcode' ) ) {
        $dbh->do( "ALTER TABLE branches ADD COLUMN marcorgcode VARCHAR(16) default NULL AFTER geolocation" );
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 10132 - MARCOrgCode on branch level (branches.marcorgcode))\n";
}

$DBversion = '17.06.00.008';
if( CheckVersion( $DBversion ) ) {
    unless ( column_exists( 'borrowers', 'date_renewed' ) ) {
        $dbh->do(q{
            ALTER TABLE borrowers ADD COLUMN date_renewed DATE NULL DEFAULT NULL AFTER dateexpiry;
        });
    }

    unless ( column_exists( 'deletedborrowers', 'date_renewed' ) ) {
        $dbh->do(q{
            ALTER TABLE deletedborrowers ADD COLUMN date_renewed DATE NULL DEFAULT NULL AFTER dateexpiry;
        });
    }

    unless ( column_exists( 'borrower_modifications', 'date_renewed' ) ) {
        $dbh->do(q{
            ALTER TABLE borrower_modifications ADD COLUMN date_renewed DATE NULL DEFAULT NULL AFTER dateexpiry;
        });
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 6758 - Capture membership renewal date for reporting purposes (borrowers.date_renewed))\n";
}

$DBversion = '17.06.00.009';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        ALTER TABLE borrowers MODIFY COLUMN login_attempts int(4) AFTER lang;
    });
    $dbh->do(q{
        ALTER TABLE deletedborrowers MODIFY COLUMN login_attempts int(4) AFTER lang;
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 19344 -  Reorder lang and login_attempts in the [deleted]borrowers tables)\n";
}

$DBversion = '17.06.00.010';
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` )
        VALUES (
            'DefaultCountryField008','','',
            'Fill in the default country code for field 008 Range 15-17 of MARC21 - Place of publication, production, or execution. See <a href=\"http://www.loc.gov/marc/countries/countries_code.html\">MARC Code List for Countries</a>','Free')
    });
    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 13912 - System preference for default place of publication (country code) for field 008, range 15-17)\n";
}

$DBversion = '17.06.00.011';
if ( CheckVersion($DBversion) ) {
    # Drop index that might exist because of bug 5337
    if( index_exists('biblioitems', 'ean')) {
        $dbh->do(q{ ALTER TABLE biblioitems DROP INDEX ean });
    }
    if( index_exists('deletedbiblioitems', 'ean')) {
        $dbh->do(q{ ALTER TABLE deletedbiblioitems DROP INDEX ean });
    }

    # Change data type of column
    $dbh->do(q{ ALTER TABLE biblioitems MODIFY COLUMN ean MEDIUMTEXT default NULL });
    $dbh->do(q{ ALTER TABLE deletedbiblioitems MODIFY COLUMN ean MEDIUMTEXT default NULL });

    # Add indexes
    $dbh->do(q{ ALTER TABLE biblioitems ADD INDEX ean ( ean(255) )});
    $dbh->do(q{ ALTER TABLE deletedbiblioitems ADD INDEX ean ( ean(255 ) )});

    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 13766 - Make ean mediumtext and add ean indexes)\n";
}

$DBversion = '17.06.00.012';
if( CheckVersion( $DBversion ) ) {
    my $where = q|host='clio-db.cc.columbia.edu' AND port=7090|;
    my $sql = "SELECT COUNT(*) FROM z3950servers WHERE $where";
    my ( $cnt ) = $dbh->selectrow_array( $sql );
    if( $cnt ) {
        $dbh->do( "DELETE FROM z3950servers WHERE $where" );
        print "Removed $cnt Z39.50 target(s) for Columbia University\n";
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 19043 - Z39.50 target for Columbia University is no longer publicly available.)\n";
}

$DBversion = '17.06.00.013';
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "UPDATE systempreferences SET value = CONCAT('http://', value) WHERE variable = 'staffClientBaseURL' AND value <> '' AND value NOT LIKE 'http%'" );

    my ( $staffClientBaseURL_used_in_notices ) = $dbh->selectrow_array(q|
        SELECT COUNT(*) FROM letter where content like "%staffClientBaseURL%"
    |);
    if ( $staffClientBaseURL_used_in_notices ) {
        warn "\tYou may need to update one or more notice templates if they contain 'staffClientBaseURL'\n";
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 16401 - fix potentialy bad set staffClientBaseURL preference)\n";
}

$DBversion = '17.06.00.014';
if( CheckVersion( $DBversion ) ) {
    unless( column_exists('aqbasket','create_items') ){
        $dbh->do(q{
            ALTER TABLE aqbasket
                ADD COLUMN create_items ENUM('ordering', 'receiving', 'cataloguing') default NULL AFTER is_standing
        });
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 15685 - Allow creation of items (AcqCreateItem) to be customizable per-basket)\n";
}

$DBversion = '17.06.00.015';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type`) VALUES
        ('SelfCheckoutByLogin','0',NULL,'Have patrons login into the web-based self checkout system with their username/password or their cardnumber','YesNo')
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 19186 - Insert system preference SelfCheckoutByLogin if missing)\n";
}

$DBversion = '17.06.00.016';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type`)
        VALUES ('RequireStrongPassword','0','','Require a strong login password for staff and patrons','YesNo');
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18298 - Allow enforcing password complexity (system preference RequireStrongPassword))\n";
}

$DBversion = '17.06.00.017';
if( CheckVersion( $DBversion ) ) {
    unless (TableExists('account_offsets')) {
        $dbh->do(q{
            DROP TABLE IF EXISTS `accountoffsets`;
        });

        $dbh->do(q{
            CREATE TABLE IF NOT EXISTS `account_offset_types` (
              `type` varchar(16) NOT NULL, -- The type of offset this is
              PRIMARY KEY (`type`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
        });

        $dbh->do(q{
            CREATE TABLE IF NOT EXISTS `account_offsets` (
              `id` int(11) NOT NULL auto_increment, -- unique identifier for each offset
              `credit_id` int(11) NULL DEFAULT NULL, -- The id of the accountline the increased the patron's balance
              `debit_id` int(11) NULL DEFAULT NULL, -- The id of the accountline that decreased the patron's balance
              `type` varchar(16) NOT NULL, -- The type of offset this is
              `amount` decimal(26,6) NOT NULL, -- The amount of the change
              `created_on` timestamp NOT NULL default CURRENT_TIMESTAMP,
              PRIMARY KEY (`id`),
              CONSTRAINT `account_offsets_ibfk_p` FOREIGN KEY (`credit_id`) REFERENCES `accountlines` (`accountlines_id`) ON DELETE CASCADE ON UPDATE CASCADE,
              CONSTRAINT `account_offsets_ibfk_f` FOREIGN KEY (`debit_id`) REFERENCES `accountlines` (`accountlines_id`) ON DELETE CASCADE ON UPDATE CASCADE,
              CONSTRAINT `account_offsets_ibfk_t` FOREIGN KEY (`type`) REFERENCES `account_offset_types` (`type`) ON DELETE CASCADE ON UPDATE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
        });

        $dbh->do(q{
            INSERT IGNORE INTO account_offset_types ( type ) VALUES
            ('Writeoff'),
            ('Payment'),
            ('Lost Item'),
            ('Processing Fee'),
            ('Manual Debit'),
            ('Reverse Payment'),
            ('Forgiven'),
            ('Dropbox'),
            ('Rental Fee'),
            ('Fine Update'),
            ('Fine');
        });
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 14826 - Resurrect account offsets table (Add new tables account_offsets and account_offset_types))\n";
}

$DBversion = '17.06.00.018';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,type) VALUES ('useDefaultReplacementCost',0,'default replacement cost defined in item type','YesNo');
    });
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,type) VALUES ('ProcessingFeeNote','','Set the text to be recorded in the column note, table accountlines when the processing fee (defined in item type) is applied','textarea');
    });
    $dbh->do(q{
        ALTER TABLE `itemtypes` MODIFY COLUMN `rentalcharge` DECIMAL(28,6) NULL DEFAULT NULL;
    });
    unless ( column_exists( 'itemtypes', 'defaultreplacecost' ) ) {
        $dbh->do(q{
            ALTER TABLE `itemtypes` ADD `defaultreplacecost` DECIMAL(28,6) NULL DEFAULT NULL AFTER `rentalcharge`;
        });
    }
    unless ( column_exists( 'itemtypes', 'processfee' ) ) {
        $dbh->do(q{
            ALTER TABLE `itemtypes` ADD `processfee` DECIMAL(28,6) NULL DEFAULT NULL AFTER `defaultreplacecost`;
        });

    }
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 12768 - Insert system preferences useDefaultReplacementCost and ProcessingFeeNote + Add new columns defaultreplacecost and processfee to the itemtypes table)\n";
}

$DBversion = '17.06.00.019';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO account_offset_types ( type ) VALUES ( 'Processing Fee' );
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 12768 - Add 'Processing Fee' to the account_offset_types table if missing)\n";
}

$DBversion = '17.06.00.020';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        UPDATE systempreferences
        SET
            variable='OpacLocationOnDetail',
            options='holding|home|both|column',
            explanation='In the OPAC detail, display the shelving location on its own column or under a library columns.'
        WHERE
            variable='OpacLocationBranchToDisplayShelving'
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 19028: Add 'shelving location' to holdings table in detail page (Rename syspref OpacLocationBranchToDisplayShelving with OpacLocationOnDetail))\n";
}

$DBversion = '17.06.00.021';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type` ) VALUES ('SCOMainUserBlock','','70|10','Add a block of HTML that will display on the self checkout screen','Textarea')
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 17381 - Add system preference SCOMainUserBlock)\n";
}

$DBversion = '17.06.00.022';
if( CheckVersion( $DBversion ) ) {
    my $hide_barcode = C4::Context->preference('OPACShowBarcode') ? 0 : 1;
    $dbh->do(q{
        DELETE FROM systempreferences
        WHERE
            variable='OPACShowBarcode'
    });

    # Configure column visibility if it isn't
    $dbh->do(q{
        INSERT IGNORE INTO columns_settings
            (module,page,tablename,columnname,cannot_be_toggled,is_hidden)
        VALUES
            ('opac','biblio-detail','holdingst','item_barcode',0,?)
    }, undef, $hide_barcode);

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 19038: Remove OPACShowBarcode syspref)\n";
}

$DBversion = '17.06.00.023';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('MarkLostItemsAsReturned','1','','Mark items as returned when flagged as lost','YesNo');
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 12363 - Add system preference MarkLostItemsAsReturned)\n";
}

$DBversion = '17.06.00.024';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (`variable`,`value`,`options`,`explanation`,`type`) VALUES
        ('OPACUserSummary', 1, NULL, "Show the summary of a logged in user's checkouts, overdues, holds and fines on the mainpage", 'YesNo');
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 2093 - Add system preference OPACUserSummary)\n";
}

$DBversion = '17.06.00.025';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        ALTER TABLE borrowers MODIFY cardnumber varchar(32);
    });
    $dbh->do(q{
        ALTER TABLE borrower_modifications MODIFY cardnumber varchar(32);
    });
    $dbh->do(q{
        ALTER TABLE deletedborrowers MODIFY cardnumber varchar(32);
    });
    $dbh->do(q{
        ALTER TABLE pending_offline_operations MODIFY cardnumber varchar(32);
    });
    $dbh->do(q{
        ALTER TABLE tmp_holdsqueue MODIFY cardnumber varchar(32);
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 13178 - Increase cardnumber fields to VARCHAR(32))\n";
}

$DBversion = '17.06.00.026';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('BlockReturnOfLostItems','0','0','If enabled, items that are marked as lost cannot be returned.','YesNo');
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 10748 - Add system preference BlockReturnOfLostItems)\n";
}

$DBversion = '17.06.00.027';
if( CheckVersion( $DBversion ) ) {
    if ( !column_exists( 'statistics', 'location' ) ) {
        $dbh->do('ALTER TABLE statistics ADD COLUMN location VARCHAR(80) default NULL AFTER itemtype');
    }

    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 18882 - Add location code to statistics table for checkouts and renewals)\n";
}

$DBversion = '17.06.00.028';
if( CheckVersion( $DBversion ) ) {
    if ( !TableExists( 'illrequests' ) ) {
        $dbh->do(q{
            CREATE TABLE illrequests (
               illrequest_id serial PRIMARY KEY,           -- ILL request number
               borrowernumber integer DEFAULT NULL,        -- Patron associated with request
               biblio_id integer DEFAULT NULL,             -- Potential bib linked to request
               branchcode varchar(50) NOT NULL,            -- The branch associated with the request
               status varchar(50) DEFAULT NULL,            -- Current Koha status of request
               placed date DEFAULT NULL,                   -- Date the request was placed
               replied date DEFAULT NULL,                  -- Last API response
               updated timestamp DEFAULT CURRENT_TIMESTAMP -- Last modification to request
                 ON UPDATE CURRENT_TIMESTAMP,
               completed date DEFAULT NULL,                -- Date the request was completed
               medium varchar(30) DEFAULT NULL,            -- The Koha request type
               accessurl varchar(500) DEFAULT NULL,        -- Potential URL for accessing item
               cost varchar(20) DEFAULT NULL,              -- Cost of request
               notesopac text DEFAULT NULL,                -- Patron notes attached to request
               notesstaff text DEFAULT NULL,               -- Staff notes attached to request
               orderid varchar(50) DEFAULT NULL,           -- Backend id attached to request
               backend varchar(20) DEFAULT NULL,           -- The backend used to create request
               CONSTRAINT `illrequests_bnfk`
                 FOREIGN KEY (`borrowernumber`)
                 REFERENCES `borrowers` (`borrowernumber`)
                 ON UPDATE CASCADE ON DELETE CASCADE,
               CONSTRAINT `illrequests_bcfk_2`
                 FOREIGN KEY (`branchcode`)
                 REFERENCES `branches` (`branchcode`)
                 ON UPDATE CASCADE ON DELETE CASCADE
           ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
        });
    }

    if ( !TableExists( 'illrequestattributes' ) ) {
        $dbh->do(q{
            CREATE TABLE illrequestattributes (
                illrequest_id bigint(20) unsigned NOT NULL, -- ILL request number
                type varchar(200) NOT NULL,                 -- API ILL property name
                value text NOT NULL,                        -- API ILL property value
                PRIMARY KEY  (`illrequest_id`,`type`),
                CONSTRAINT `illrequestattributes_ifk`
                  FOREIGN KEY (illrequest_id)
                  REFERENCES `illrequests` (`illrequest_id`)
                  ON UPDATE CASCADE ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
        });
    }

    # System preferences
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES
            ('ILLModule','0','If ON, enables the interlibrary loans module.','','YesNo');
    });

    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES
            ('ILLModuleCopyrightClearance','','70|10','Enter text to enable the copyright clearance stage of request creation. Text will be displayed','Textarea');
    });
    # userflags
    $dbh->do(q{
        INSERT IGNORE INTO userflags (bit,flag,flagdesc,defaulton) VALUES
            (22,'ill','The Interlibrary Loans Module',0);
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 7317 - Add an Interlibrary Loan Module to Circulation and OPAC)\n";
}

$DBversion = '17.11.00.000';
if( CheckVersion( $DBversion ) ) {
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Koha 17.11)\n";
}

$DBversion = '17.12.00.000';
if( CheckVersion( $DBversion ) ) {
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Tē tōia, tē haumatia)\n";
}

$DBversion = '17.12.00.001';
if( CheckVersion( $DBversion ) ) {
    foreach my $table (qw(biblio_metadata deletedbiblio_metadata)) {
        if (!column_exists($table, 'timestamp')) {
            $dbh->do(qq{
                ALTER TABLE `$table`
                ADD COLUMN `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER `metadata`,
                ADD KEY `timestamp` (`timestamp`)
            });
            $dbh->do(qq{
                UPDATE $table metadata
                    LEFT JOIN biblioitems ON (biblioitems.biblionumber = metadata.biblionumber)
                    LEFT JOIN biblio ON (biblio.biblionumber = metadata.biblionumber)
                SET metadata.timestamp = GREATEST(biblioitems.timestamp, biblio.timestamp);
            });
        }
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 19724 - Add [deleted]biblio_metadata.timestamp)\n";
}

$DBversion = '17.12.00.002';
if( CheckVersion( $DBversion ) ) {

    my $msss = $dbh->selectall_arrayref(q|
        SELECT kohafield, tagfield, tagsubfield, frameworkcode
        FROM marc_subfield_structure
        WHERE   frameworkcode != ''
    |, { Slice => {} });


    my $sth = $dbh->prepare(q|
        SELECT kohafield
        FROM marc_subfield_structure
        WHERE frameworkcode = ''
        AND tagfield = ?
        AND tagsubfield = ?
    |);

    my @exceptions;
    for my $mss ( @$msss ) {
        $sth->execute($mss->{tagfield}, $mss->{tagsubfield} );
        my ( $default_kohafield ) = $sth->fetchrow_array();
        if( $mss->{kohafield} ) {
            push @exceptions, { frameworkcode => $mss->{frameworkcode}, tagfield => $mss->{tagfield}, tagsubfield => $mss->{tagsubfield}, kohafield => $mss->{kohafield} } if not $default_kohafield or $default_kohafield ne $mss->{kohafield};
        } else {
            push @exceptions, { frameworkcode => $mss->{frameworkcode}, tagfield => $mss->{tagfield}, tagsubfield => $mss->{tagsubfield}, kohafield => q{} } if $default_kohafield;
        }
    }

    if (@exceptions) {
        print "WARNING: The Default framework is now considered as authoritative for Koha to MARC mappings. We have found that your additional frameworks contained "
          . scalar(@exceptions)
          . " mapping(s) that deviate from the standard mappings. Please look at the following list and consider if you need to add them again in Default (possibly as a second mapping).\n";
        for my $exception (@exceptions) {
            print "Field "
              . $exception->{tagfield} . '$'
              . $exception->{tagsubfield}
              . " in framework "
              . $exception->{frameworkcode} . ': ';
            if ( $exception->{kohafield} ) {
                print "Mapping to "
                  . $exception->{kohafield}
                  . " has been adjusted.\n";
            }
            else {
                print "Mapping has been reset.\n";
            }
        }

        # Sync kohafield

        # Clear the destination frameworks first
        $dbh->do(q|
            UPDATE marc_subfield_structure
            SET kohafield = NULL
            WHERE   frameworkcode > ''
                AND     Kohafield > ''
        |);

        # Now copy from Default
        my $msss = $dbh->selectall_arrayref(q|
            SELECT kohafield, tagfield, tagsubfield
            FROM marc_subfield_structure
            WHERE   frameworkcode = ''
                AND     kohafield > ''
        |, { Slice => {} });
        my $sth = $dbh->prepare(q|
            UPDATE marc_subfield_structure
            SET kohafield = ?
            WHERE frameworkcode > ''
            AND tagfield = ?
            AND tagsubfield = ?
        |);
        for my $mss (@$msss) {
            $sth->execute( $mss->{kohafield}, $mss->{tagfield},
                $mss->{tagsubfield} );
        }

        # Clear the cache
        my @frameworkcodes = $dbh->selectall_arrayref(q|
            SELECT frameworkcode FROM biblio_framework WHERE frameworkcode > ''
        |);
        for my $frameworkcode (@frameworkcodes) {
            Koha::Caches->get_instance->clear_from_cache("MarcSubfieldStructure-$frameworkcode");
        }
        Koha::Caches->get_instance->clear_from_cache("default_value_for_mod_marc-");
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 19096 - Make Default authoritative for Koha to MARC mappings)\n";
}

$DBversion = '17.12.00.003';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q|DROP TABLE IF EXISTS notifys|);

    if( column_exists( 'accountlines', 'notify_id' ) ) {
        $dbh->do(q|ALTER TABLE accountlines DROP COLUMN notify_id|);
        $dbh->do(q|ALTER TABLE accountlines DROP COLUMN notify_level|);
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 10021 - Drop notifys-related table and columns)\n";
}

$DBversion = '17.12.00.004';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` )
        VALUES
            ('RESTdefaultPageSize','20','','Set the default number of results returned by the REST API endpoints','Integer')
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 19278 - Add a configurable default page size for REST endpoints)\n";
}

$DBversion = '17.12.00.005';
if( CheckVersion( $DBversion ) ) {
    # For installations having the note already
    $dbh->do(q{
        UPDATE letter
        SET code    = 'CHECKOUT_NOTE',
            name    = 'Checkout note on item set by patron',
            title   = 'Checkout note',
            content = REPLACE(content, "<<biblio.item>>", "<<biblio.title>>")
        WHERE code = 'PATRON_NOTE'
    });
    # For installations coming from 17.11
    $dbh->do(q{
        INSERT IGNORE INTO `letter` (`module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content`, `message_transport_type`)
        VALUES ('circulation', 'CHECKOUT_NOTE', '', 'Checkout note on item set by patron', '0', 'Checkout note', '<<borrowers.firstname>> <<borrowers.surname>> has added a note to the item <<biblio.title>> - <<biblio.author>> (<<biblio.biblionumber>>).','email')
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18915 - Correct CHECKOUT_NOTE notice template)\n";
}

$DBversion = '17.12.00.006';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        UPDATE systempreferences SET value=replace(value, "http://www.scholar", "https://scholar") WHERE variable='OPACSearchForTitleIn';
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 17682 - Update URL for Google Scholar in OPACSearchForTitleIn)\n";
}

$DBversion = '17.12.00.007';
if( CheckVersion( $DBversion ) ) {

    unless ( TableExists( 'library_groups' ) ) {
        $dbh->do(q{
            CREATE TABLE library_groups (
                id INT(11) NOT NULL auto_increment,    -- unique id for each group
                parent_id INT(11) NULL DEFAULT NULL,   -- if this is a child group, the id of the parent group
                branchcode VARCHAR(10) NULL DEFAULT NULL, -- The branchcode of a branch belonging to the parent group
                title VARCHAR(100) NULL DEFAULT NULL,     -- Short description of the goup
                description TEXT NULL DEFAULT NULL,    -- Longer explanation of the group, if necessary
                created_on TIMESTAMP NULL,             -- Date and time of creation
                updated_on TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Date and time of last
                PRIMARY KEY id ( id ),
                FOREIGN KEY (parent_id) REFERENCES library_groups(id) ON UPDATE CASCADE ON DELETE CASCADE,
                FOREIGN KEY (branchcode) REFERENCES branches(branchcode) ON UPDATE CASCADE ON DELETE CASCADE,
                UNIQUE KEY title ( title )
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
        });
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 15707 - Add new table library_groups)\n";
}

$DBversion = '17.12.00.008';
if ( CheckVersion($DBversion) ) {

    if ( TableExists( 'branchcategories' ) and TableExists('branchrelations' )) {
        $dbh->do(q{
            INSERT INTO library_groups ( title, description, created_on ) VALUES ( '__SEARCH_GROUPS__', 'Library search groups', NOW() )
        });
        my $search_groups_root_id = $dbh->last_insert_id(undef, undef, 'library_groups', undef);

        my $sth = $dbh->prepare("SELECT * FROM branchcategories");

        my $sth2 = $dbh->prepare("INSERT INTO library_groups ( parent_id, title, description, created_on ) VALUES ( ?, ?, ?, NOW() )");

        my $sth3 = $dbh->prepare("SELECT * FROM branchrelations WHERE categorycode = ?");

        my $sth4 = $dbh->prepare("INSERT INTO library_groups ( parent_id, branchcode, created_on ) VALUES ( ?, ?, NOW() )");

        $sth->execute();
        while ( my $lc = $sth->fetchrow_hashref ) {
            my $description = $lc->{categorycode};
            $description .= " - " . $lc->{codedescription} if $lc->{codedescription};

            $sth2->execute($search_groups_root_id, $lc->{categoryname}, $description);

            my $subgroup_id = $dbh->last_insert_id(undef, undef, 'library_groups', undef);

            $sth3->execute( $lc->{categorycode} );

            while ( my $l = $sth3->fetchrow_hashref ) {
                $sth4->execute( $subgroup_id, $l->{branchcode} );
            }
        }

        $dbh->do("DROP TABLE branchrelations");
        $dbh->do("DROP TABLE branchcategories");
    }

    print "Upgrade to $DBversion done (Bug 16735 - Migrate library search groups into the new hierarchical groups)\n";
    SetVersion($DBversion);
}

$DBversion = '17.12.00.009';
if ( CheckVersion($DBversion) ) {
    $dbh->do(q|
        INSERT IGNORE INTO permissions (module_bit, code, description) VALUES
        (4, 'edit_borrowers', 'Add, modify and view patron information'),
        (4, 'view_borrower_infos_from_any_libraries', 'View patron infos from any libraries');
    |);

    # We are lucky here, there is nothing else to do: flags 4-borrowers did not contain sub permissions

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18403 - Add the view_borrower_infos_from_any_libraries permission )\n";
}

$DBversion = '17.12.00.010';
if( CheckVersion( $DBversion ) ) {

    if( !column_exists( 'library_groups', 'ft_hide_patron_info' ) ) {
        $dbh->do( "ALTER TABLE library_groups ADD COLUMN ft_hide_patron_info tinyint(1) NOT NULL DEFAULT 0 AFTER description" );
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 20133 - Add library_groups.ft_hide_patron_info)\n";
}

$DBversion = '17.12.00.011';
if( CheckVersion( $DBversion ) ) {

    if( !column_exists( 'library_groups', 'ft_search_groups_opac' ) ) {
        $dbh->do( "ALTER TABLE library_groups ADD COLUMN ft_search_groups_opac tinyint(1) NOT NULL DEFAULT 0 AFTER ft_hide_patron_info" );
        $dbh->do( "ALTER TABLE library_groups ADD COLUMN ft_search_groups_staff tinyint(1) NOT NULL DEFAULT 0 AFTER ft_search_groups_opac" );
        $dbh->do( "UPDATE library_groups SET ft_search_groups_staff = 1 AND ft_search_groups_opac = 1 WHERE title = '__SEARCH_GROUPS__'" );
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 20157 - Use group 'features' to decide which groups to use for group searching functionality)\n";
}

$DBversion = '17.12.00.012';
if( CheckVersion( $DBversion ) ) {

    $dbh->do( q|
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
        VALUES ('AutoSwitchPatron', '0', '', 'Auto switch to patron', 'YesNo');
    |);

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 15752 - Add system preference AutoSwitchPatron)\n";
}

$DBversion = '17.12.00.013';
if( CheckVersion( $DBversion ) ) {

    $dbh->do(q|
        ALTER TABLE club_enrollments MODIFY date_created timestamp NULL DEFAULT NULL;
    |);

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 20175 - Set DEFAULT NULL value for club_enrollments.date_created)\n";
}

$DBversion = '17.12.00.014';
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "UPDATE marc_subfield_structure SET kohafield=NULL where kohafield='additionalauthors.author'" );
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 19790 - Remove additionalauthors.author from installer files)\n";
}

$DBversion = '17.12.00.015';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q|
        ALTER TABLE borrowers
        MODIFY surname MEDIUMTEXT,
        MODIFY address MEDIUMTEXT,
        MODIFY city MEDIUMTEXT
    |);
    $dbh->do(q|
        ALTER TABLE deletedborrowers
        MODIFY surname MEDIUMTEXT,
        MODIFY address MEDIUMTEXT,
        MODIFY city MEDIUMTEXT
    |);

    $dbh->do(q|
        ALTER TABLE export_format
        MODIFY csv_separator VARCHAR(2) NOT NULL DEFAULT ',',
        MODIFY field_separator VARCHAR(2),
        MODIFY subfield_separator VARCHAR(2)
    |);
    $dbh->do(q|
        ALTER TABLE export_format MODIFY encoding VARCHAR(255) NOT NULL DEFAULT 'utf8'
    |);

    $dbh->do(q|
        ALTER TABLE reserves MODIFY lowestPriority tinyint(1) NOT NULL DEFAULT 0
    |);
    $dbh->do(q|
        ALTER TABLE old_reserves MODIFY lowestPriority tinyint(1) NOT NULL DEFAULT 0
    |);

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 20144 - Adapt DB structure to work with new SQL modes)\n";
}

$DBversion = '17.12.00.016';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q|SET foreign_key_checks = 0|);
    my $sth = $dbh->table_info( '','','','TABLE' );

    while ( my ( $cat, $schema, $name, $type, $remarks ) = $sth->fetchrow_array ) {
        my $table_sth = $dbh->prepare(qq|SHOW CREATE TABLE $name|);
        $table_sth->execute;
        my @table = $table_sth->fetchrow_array;
        unless ( $table[1] =~ /COLLATE=utf8mb4_unicode_ci/ ) {
            # Some users might have done the upgrade to utf8mb4 on their own
            # to support supplemental chars (japanese, chinese, etc)
            if ( $name eq 'additional_fields' ) {
                $dbh->do(qq|
                    ALTER TABLE $name
                        DROP KEY `fields_uniq`,
                        ADD UNIQUE KEY `fields_uniq` (`tablename` (191), `name` (191))
                |);
                $dbh->do(qq|ALTER TABLE $name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci|);
            }
            elsif ( $name eq 'authorised_values' ) {
                $dbh->do(qq|
                    ALTER TABLE $name
                        DROP KEY `lib`,
                        ADD KEY `lib` (`lib` (191))
                |);
                $dbh->do(qq|ALTER TABLE $name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci|);
            }
            elsif ( $name eq 'borrower_modifications' ) {
                $dbh->do(qq|
                    ALTER TABLE $name
                        DROP PRIMARY KEY,
                        DROP KEY `verification_token`,
                        ADD PRIMARY KEY (`verification_token` (191),`borrowernumber`),
                        ADD KEY `verification_token` (`verification_token` (191))
                |);
                $dbh->do(qq|ALTER TABLE $name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci|);
            }
            elsif ( $name eq 'columns_settings' ) {
                $dbh->do(qq|
                    ALTER TABLE $name
                        DROP PRIMARY KEY,
                        ADD PRIMARY KEY (`module` (191), `page` (191), `tablename` (191), `columnname` (191))
                |);
                $dbh->do(qq|ALTER TABLE $name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci|);
            }
            elsif ( $name eq 'illrequestattributes' ) {
                $dbh->do(qq|
                    ALTER TABLE $name
                        DROP PRIMARY KEY,
                        ADD PRIMARY KEY  (`illrequest_id`, `type` (191))
                |);
                $dbh->do(qq|ALTER TABLE $name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci|);
            }
            elsif ( $name eq 'items_search_fields' ) {
                $dbh->do(qq|
                    ALTER TABLE $name
                        DROP PRIMARY KEY,
                        ADD PRIMARY KEY (`name` (191))
                |);
                $dbh->do(qq|ALTER TABLE $name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci|);
            }
            elsif ( $name eq 'marc_subfield_structure' ) {
                # In this case we convert each column explicitly
                # to preserve 'tagsubield' collation (utf8mb4_bin)
                $dbh->do(qq|
                    ALTER TABLE $name
                        MODIFY COLUMN tagfield
                            VARCHAR(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
                        MODIFY COLUMN tagsubfield
                            VARCHAR(1) COLLATE utf8mb4_bin NOT NULL DEFAULT '',
                        MODIFY COLUMN liblibrarian
                            VARCHAR(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
                        MODIFY COLUMN libopac
                            VARCHAR(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
                        MODIFY COLUMN kohafield
                            VARCHAR(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
                        MODIFY COLUMN authorised_value
                            VARCHAR(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
                        MODIFY COLUMN authtypecode
                            VARCHAR(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
                        MODIFY COLUMN value_builder
                            VARCHAR(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
                        MODIFY COLUMN frameworkcode
                            VARCHAR(4) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
                        MODIFY COLUMN seealso
                            VARCHAR(1100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
                        MODIFY COLUMN link
                            VARCHAR(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
                        MODIFY COLUMN defaultvalue
                            MEDIUMTEXT COLLATE utf8mb4_unicode_ci default NULL
                |);
                $dbh->do(qq|ALTER TABLE $name CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci|);
            }
            elsif ( $name eq 'plugin_data' ) {
                $dbh->do(qq|
                    ALTER TABLE $name
                        DROP PRIMARY KEY,
                        ADD PRIMARY KEY (`plugin_class` (191), `plugin_key` (191))
                |);
                $dbh->do(qq|ALTER TABLE $name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci|);
            }
            elsif ( $name eq 'search_field' ) {
                $dbh->do(qq|
                    ALTER TABLE $name
                        DROP KEY `name`,
                        ADD UNIQUE KEY `name` (`name` (191))
                |);
                $dbh->do(qq|ALTER TABLE $name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci|);
            }
            elsif ( $name eq 'search_marc_map' ) {
                $dbh->do(qq|
                    ALTER TABLE $name
                        DROP KEY `index_name`,
                        ADD UNIQUE KEY `index_name` (`index_name`, `marc_field` (191), `marc_type`)
                |);
                $dbh->do(qq|ALTER TABLE $name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci|);
            }
            elsif ( $name eq 'sms_providers' ) {
                $dbh->do(qq|
                    ALTER TABLE $name
                        DROP KEY `name`,
                        ADD UNIQUE KEY `name` (`name` (191))
                |);
                $dbh->do(qq|ALTER TABLE $name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci|);
            }
            elsif ( $name eq 'tags' ) {
                $dbh->do(qq|
                    ALTER TABLE $name
                        DROP PRIMARY KEY,
                        ADD PRIMARY KEY (`entry` (191))
                |);
                $dbh->do(qq|ALTER TABLE $name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci|);
            }
            elsif ( $name eq 'tags_approval' ) {
                $dbh->do(qq|
                    ALTER TABLE $name
                        MODIFY COLUMN `term` VARCHAR(191) NOT NULL
                |);
                $dbh->do(qq|ALTER TABLE $name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci|);
            }
            elsif ( $name eq 'tags_index' ) {
                $dbh->do(qq|
                    ALTER TABLE $name
                        MODIFY COLUMN `term` VARCHAR(191) NOT NULL
                |);
                $dbh->do(qq|ALTER TABLE $name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci|);
            }
            else {
                $dbh->do(qq|ALTER TABLE $name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci|);
            }
        }
    }
    $dbh->do(q|SET foreign_key_checks = 1|);

    print "Upgrade to $DBversion done (Bug 18336 - Convert DB tables to utf8mb4 🎁)\n";
    SetVersion($DBversion);
}


$DBversion = '17.12.00.017';
if( CheckVersion( $DBversion ) ) {

    if( !column_exists( 'items', 'damaged_on' ) ) {
        $dbh->do( "ALTER TABLE items ADD COLUMN damaged_on DATETIME NULL AFTER damaged");
    }
    if( !column_exists( 'deleteditems', 'damaged_on' ) ) {
        $dbh->do( "ALTER TABLE deleteditems ADD COLUMN damaged_on DATETIME NULL AFTER damaged");
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 17672 - Add damaged_on to items and deleteditems tables)\n";
}

$DBversion = '17.12.00.018';
if( CheckVersion( $DBversion ) ) {

    $dbh->do( q|
        INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type`) VALUES  ('BrowseResultSelection','0',NULL,'Enable/Disable browsing search results fromt the bibliographic record detail page in staff client','YesNo')
    |);

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 19290 - Add system preference BrowseResultSelection)\n";
}

$DBversion = '17.12.00.019';
if( CheckVersion( $DBversion ) ) {

    $dbh->do(q|UPDATE auth_subfield_structure SET hidden=1 WHERE hidden<>0|);

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 20074 - Auth_subfield_structure changes hidden attribute)\n";
}

$DBversion = '17.12.00.020';
if( CheckVersion( $DBversion ) ) {

    $dbh->do(q|
        INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
        VALUES ('vi', 'language', 'de', 'Vietnamesisch')
    |);

    $dbh->do(q|
        UPDATE language_descriptions SET description = 'Tiếng Việt'
        WHERE subtag = 'vi' and type = 'language' and lang = 'vi'
    |);

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 20082 - Update descriptions of Vietnamese language)\n";
}

$DBversion = '17.12.00.021';
if( CheckVersion( $DBversion ) ) {

    $dbh->do(q|
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('PurgeSuggestionsOlderThan', '', NULL, 'Default value for cronjob purge_suggestions.pl', 'Integer');
    |);

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 13287 - Add system preference PurgeSuggestionsOlderThan)\n";
}

$DBversion = '17.12.00.022';
if( CheckVersion( $DBversion ) ) {

    if( !column_exists( 'currency', 'p_sep_by_space' ) ) {
        $dbh->do(q|
            ALTER TABLE currency ADD COLUMN p_sep_by_space tinyint(1) default 0 after archived
        |);
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 4078 - Add column currency.p_sep_by_space)\n";
}

$DBversion = '17.12.00.023';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        DELETE FROM systempreferences
        WHERE variable='checkdigit'
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 20264 - Remove system preference 'checkdigit')\n";
}

$DBversion = '17.12.00.024';
if( CheckVersion( $DBversion ) ) {

    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
        VALUES ('SelfCheckInMainUserBlock', '', '70|10', 'Add a block of HTML that will display on the self check-in screen.', 'Textarea');
    });

    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
        VALUES ('SelfCheckInModule', 0, NULL, 'Enable the standalone self-checkin module.', 'YesNo');
    });

    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
        VALUES ('SelfCheckInModuleUserID', NULL, NULL, 'Patron ID (borrowernumber) to be allowed on the self-checkin module.', 'Integer');
    });

    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
        VALUES ('SelfCheckInTimeout', 120, NULL, 'Define the number of seconds before the self check-in module times out.', 'Integer');
    });

    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
        VALUES ('SelfCheckInUserCSS', '', NULL, 'Add CSS to be included in the self check-in module in an embedded <style> tag.', 'free');
    });

    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
        VALUES ('SelfCheckInUserJS', '', NULL, 'Define custom javascript for inclusion in the self check-in module.', 'free');
    });

    # Add new userflag for self check
    $dbh->do(q{
        INSERT IGNORE INTO userflags (bit,flag,flagdesc,defaulton) VALUES
            (23,'self_check','Self check modules',0);
    });

    # Add self check-in module subpermission
    $dbh->do(q{
        INSERT IGNORE INTO permissions (module_bit,code,description)
        VALUES (23, 'self_checkin_module', 'Log into the self check-in module');
    });

    # Add self check-in module subpermission
    $dbh->do(q{
        INSERT IGNORE INTO permissions (module_bit,code,description)
        VALUES (23, 'self_checkout_module', 'Perform self checkout at the OPAC. It should be used for the patron matching the AutoSelfCheckID');
    });

    # Update patrons with self_checkout permission
    # IMPORTANT: Needs to happen before removing the old subpermission
    $dbh->do(q{
        UPDATE user_permissions
        SET module_bit = 23,
                  code = 'self_checkout_module'
        WHERE module_bit = 1 AND code = 'self_checkout';
    });

    # Remove old self_checkout permission
    $dbh->do(q{
        DELETE IGNORE FROM permissions
        WHERE  code='self_checkout';
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 15492 - Add a standalone self-checkin module)\n";
}

$DBversion = '17.12.00.025';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q|
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
        VALUES ('StaffLoginInstructions','','HTML to go into the login box for the staff client',NULL,'Free')
    |);
    $dbh->do(q|
        UPDATE systempreferences
        SET variable = 'OpacLoginInstructions'
        WHERE variable = 'NoLoginInstructions'
    |);

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 20291 - Add StaffLoginInstructions system preference and rename NoLoginInstructions with OpacLoginInstructions)\n";
}

$DBversion = '17.12.00.026';
if( CheckVersion( $DBversion ) ) {
    if( !column_exists( 'issuingrules', 'suspension_chargeperiod' ) ) {
        $dbh->do(q|
            ALTER TABLE issuingrules ADD COLUMN suspension_chargeperiod int(11) DEFAULT '1' AFTER maxsuspensiondays;
        |);
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 19804 - Add issuingrules.suspension_chargeperiod)\n";
}

$DBversion = '17.12.00.027';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q|
        INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type`)
        VALUES ('UseACQFrameworkForBiblioRecords','0','','Use the ACQ framework for the catalog details','YesNo')
    |);

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 19289 - Add system preference UseACQFrameworkForBiblioRecords)\n";
}

$DBversion = '17.12.00.028';
if( CheckVersion( $DBversion ) ) {
    if( !column_exists( 'marc_tag_structure', 'ind1_defaultvalue' ) ) {
        $dbh->do(q|
            ALTER TABLE marc_tag_structure
            ADD COLUMN ind2_defaultvalue VARCHAR(1) NOT NULL DEFAULT '' AFTER authorised_value,
            ADD COLUMN ind1_defaultvalue VARCHAR(1) NOT NULL DEFAULT '' AFTER authorised_value;
        |);
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 9701 - Add default indicators (marc_tag_structure.indX_defaultvalue))\n";
}

$DBversion = '17.12.00.029';
if( CheckVersion( $DBversion ) ) {
    my $pref =
q|# PERSO_NAME  100 600 696 700 796 800 896
marc21, 100, ind1:auth1
marc21, 600, ind1:auth1, ind2:thesaurus
marc21, 696, ind1:auth1
marc21, 700, ind1:auth1
marc21, 796, ind1:auth1
marc21, 800, ind1:auth1
marc21, 896, ind1:auth1
# CORPO_NAME  110 610 697 710 797 810 897
marc21, 110, ind1:auth1
marc21, 610, ind1:auth1, ind2:thesaurus
marc21, 697, ind1:auth1
marc21, 710, ind1:auth1
marc21, 797, ind1:auth1
marc21, 810, ind1:auth1
marc21, 897, ind1:auth1
# MEETI_NAME    111 611 698 711 798 811 898
marc21, 111, ind1:auth1
marc21, 611, ind1:auth1, ind2:thesaurus
marc21, 698, ind1:auth1
marc21, 711, ind1:auth1
marc21, 798, ind1:auth1
marc21, 811, ind1:auth1
marc21, 898, ind1:auth1
# UNIF_TITLE        130 440 630 699 730 799 830 899 / 240
marc21, 130, ind1:auth2
marc21, 240, , ind2:auth2
marc21, 440, , ind2:auth2
marc21, 630, ind1:auth2, ind2:thesaurus
marc21, 699, ind1:auth2
marc21, 730, ind1:auth2
marc21, 799, ind1:auth2
marc21, 830, , ind2:auth2
marc21, 899, ind1:auth2
# CHRON_TERM    648
marc21, 648, , ind2:thesaurus
# TOPIC_TERM      650 654 656 657 658 690
marc21, 650, , ind2:thesaurus
# GEOGR_NAME   651 662 691 / 751
marc21, 651, , ind2:thesaurus
# GENRE/FORM    655
marc21, 655, , ind2:thesaurus

# UNIMARC: Always copy the indicators from the authority
unimarc, *, ind1:auth1, ind2:auth2|;

    $dbh->do( q|
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
        VALUES ( 'AuthorityControlledIndicators', ?, 'Authority controlled indicators per biblio field', NULL, 'Free' );
    |, undef, $pref );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 14769 - Authorities merge: Set correct indicators in biblio field (new system preference AuthorityControlledIndicators))\n";
}

$DBversion = '17.12.00.030';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q|
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
        VALUES ('NovelistSelectStaffProfile',NULL,'Novelist staff client user Profile',NULL,'free')
    |);

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 19882 - Add system preference NovelistSelectStaffProfile)\n";
}

$DBversion = '17.12.00.031';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q|
        INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type`)
        VALUES ('MarcFieldDocURL', NULL, NULL, 'URL used for MARC field documentation. Following substitutions are available: {MARC} = marc flavour, eg. \"MARC21\" or \"UNIMARC\". {FIELD} = field number, eg. \"000\" or \"048\". {LANG} = user language, eg. \"en\" or \"fi-FI\"', 'free')
    |);

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 11674 - Add system preference MarcFieldDocURL)\n";
}

$DBversion = '17.12.00.032';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q|
        UPDATE letter SET code = "SERIAL_ALERT" WHERE code = "RLIST";
    |);
    $dbh->do(q|
        UPDATE letter SET name = "New serial issue" WHERE name = "Routing List";
    |);
    $dbh->do(q|
        UPDATE subscription SET letter = "SERIAL_ALERT" WHERE letter = "RLIST";
    |);

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 19794 - Rename RLIST notice to SERIAL_ALERT)\n";
}

$DBversion = '17.12.00.033';
if( CheckVersion( $DBversion ) ) {
    if ( !column_exists( 'accountlines', 'payment_type' ) ) {
        $dbh->do(q{
            ALTER TABLE accountlines ADD payment_type varchar(80) default NULL AFTER accounttype
        });
    }

    $dbh->do(q{
        INSERT IGNORE INTO authorised_value_categories( category_name ) VALUES ('PAYMENT_TYPE')
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18786 - Add ability to create custom payment types)\n";
}

$DBversion = '17.12.00.034';
if( CheckVersion( $DBversion ) ) {

    $dbh->do( q{
        INSERT IGNORE INTO account_offset_types ( type ) VALUES ('Void Payment')
    } );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18790 - Add ability to void payment)\n";
}

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
