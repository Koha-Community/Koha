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
use warnings;

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
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('emailPurchaseSuggestions',0,'If ON, patron suggestions are emailed rather than managed in Acquisitions',NULL,'YesNo')");

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

$DBversion = "3.00.00.042";
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
    $dbh->do("ALTER TABLE labels_conf ADD COLUMN formatstring VARCHAR(64) DEFAULT NULL AFTER printingtype");
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
    SetVersion ($DBversion);
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
    if ( $intranetuserjs eq $bad_value ) {
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

