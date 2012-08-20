#!/usr/bin/perl

# Database Updater
# This script checks for required updates to the database.

# Parts copyright Catalyst IT 2011

# Part of the Koha Library Software www.koha-community.org
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA
#

# Bugs/ToDo:
# - Would also be a good idea to offer to do a backup at this time...

# NOTE:  If you do something more than once in here, make it table driven.

# NOTE: Please keep the version in kohaversion.pl up-to-date!

use strict;
use warnings;

# CPAN modules
use DBI;
use Getopt::Long;
# Koha modules
use C4::Context;
use C4::Installer;
use C4::Dates;

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
      $duedate = C4::Dates::format_date_in_iso(C4::Context->preference("globalDueDate"));
      $dbh->do("UPDATE `issuingrules` SET hardduedate = '$duedate', hardduedatecompare = 0");
    } elsif (C4::Context->preference("ceilingDueDate")) {
      $duedate = C4::Dates::format_date_in_iso(C4::Context->preference("ceilingDueDate"));
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

$DBversion = "3.06.01.000";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    print "Upgrade to $DBversion done (Incrementing version for 3.6.1 release. See release notes for details.) \n";
    SetVersion ($DBversion);
}

$DBversion = "3.06.02.000";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    print "Upgrade to $DBversion done (Incrementing version for 3.6.2 release. See release notes for details.) \n";
    SetVersion ($DBversion);
}

$DBversion = "3.06.02.001";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE  `suggestions` ADD  `patronreason` TEXT NULL AFTER  `reason`");
    print "Upgrade to $DBversion done (Add column to suggestions table to store patrons' reasons for submitting a suggestion. )\n";
    SetVersion($DBversion);
}

$DBversion = "3.06.02.002";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("ALTER TABLE items MODIFY materials text;");
    print "Upgrade to $DBversion done alter items.material from varchar(10) to text \n";
    SetVersion($DBversion);
}

$DBversion = '3.06.02.003';
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

$DBversion = "3.06.03.000";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    print "Upgrade to $DBversion done (Incrementing version for 3.6.3 release. See release notes for details.) \n";
    SetVersion ($DBversion);
}

$DBversion = "3.06.03.001";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('AllowItemsOnHoldCheckout',0,'Do not generate RESERVE_WAITING and RESERVED warning when checking out items reserved to someone else. This allows self checkouts for those items.','','YesNo')");
    print "Upgrade to $DBversion add 'AllowItemsOnHoldCheckout' syspref \n";
    SetVersion ($DBversion);
}
$DBversion = "3.06.04.000";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    print "Upgrade to $DBversion done (Incrementing version for 3.6.4 release. See release notes for details.) \n";
    SetVersion ($DBversion);
}

$DBversion = "3.06.04.001";
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

$DBversion = "3.06.04.002";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("DELETE FROM reviews WHERE biblionumber NOT IN (SELECT biblionumber from biblio)");
    $dbh->do("UPDATE reviews SET borrowernumber = NULL WHERE borrowernumber NOT IN (SELECT borrowernumber FROM borrowers)");
    $dbh->do("ALTER TABLE reviews ADD CONSTRAINT reviews_ibfk_2 FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE");
    $dbh->do("ALTER TABLE reviews ADD CONSTRAINT reviews_ibfk_1 FOREIGN KEY (borrowernumber) REFERENCES borrowers (borrowernumber ) ON UPDATE CASCADE ON DELETE SET NULL");
    print "Upgrade to $DBversion done (Bug 7493 - Add constraint linking OPAC comment biblionumber to biblio, OPAC comment borrowernumber to borrowers.)\n";
    SetVersion($DBversion);
}

$DBversion = "3.06.04.003";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('UseICU', '1', 'Tell Koha if ICU indexing is in use for Zebra or not.','1','YesNo')");
    print "Upgrade to $DBversion done (Add syspref to tell Koha if ICU indexing is in use for Zebra or not.)\n";
    SetVersion ($DBversion);
}

$DBversion = "3.06.04.004";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('OpacBrowseResults','1','Disable/enable browsing and paging search results from the OPAC detail page.',NULL,'YesNo')");
    print "Upgrade to $DBversion done (Add system preference OpacBrowseResults ))\n";
    SetVersion($DBversion);
}

$DBversion = "3.06.04.005";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("UPDATE borrowers SET debarred=NULL WHERE debarred='0000-00-00';");
    print "Setting NULL to debarred where 0000-00-00 is stored (bug 7272)";
    SetVersion($DBversion);
}


$DBversion = "3.06.04.006";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("CREATE INDEX items_location ON items(location)");
    $dbh->do("CREATE INDEX items_ccode ON items(ccode)");
    print "Upgrade to $DBversion done (items_location and items_ccode indexes added for ShelfBrowser)";
    SetVersion($DBversion);
}

$DBversion = "3.06.05.000";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    print "Upgrade to $DBversion done (Incrementing version for 3.6.5 release. See release notes for details.) \n";
    SetVersion ($DBversion);
}

$DBversion = "3.06.05.001";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    unless(C4::Context->preference('ReservesControlBranch')){
        $dbh->do("INSERT INTO `systempreferences` (variable,value,options,explanation,type) VALUES ('ReservesControlBranch','PatronLibrary','ItemHomeLibrary|PatronLibrary','Branch checked for members reservations rights.','Choice')");
}
    print "Upgrade to $DBversion done (Insert ReservesControlBranch systempreference into systempreferences table )\n";
    SetVersion($DBversion);
}

$DBversion = "3.06.06.001";
if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do("CREATE INDEX items_location ON items(location)");
    $dbh->do("CREATE INDEX items_ccode ON items(ccode)");
    print "Upgrade to $DBversion done (items_location and items_ccode indexes added for ShelfBrowser)";
    SetVersion($DBversion);
}

$DBversion = "3.06.07.001";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("UPDATE systempreferences SET value = 'call_number' WHERE variable = 'defaultSortField' AND value = 'callnumber'");
    $dbh->do("UPDATE systempreferences SET value = 'call_number' WHERE variable = 'OPACdefaultSortField' AND value = 'callnumber'");
    print "Upgrade to $DBversion done (Bug 8657 - Default sort by call number does not work. Correcting system preference value.)\n";
    SetVersion ($DBversion);
}

=head1 FUNCTIONS

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
}
exit;

