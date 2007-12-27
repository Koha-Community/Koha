#!/usr/bin/perl


# Database Updater
# This script checks for required updates to the database.

# Part of the Koha Library Software www.koha.org
# Licensed under the GPL.

# Bugs/ToDo:
# - Would also be a good idea to offer to do a backup at this time...

# NOTE:  If you do something more than once in here, make it table driven.

# NOTE: Please keep the version in C4/Context.pm up-to-date!

use strict;

# CPAN modules
use DBI;
use Getopt::Long;
# Koha modules
use C4::Context;

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
    $dbh->do("ALTER TABLE `virtualshelfcontents` ADD `biblionumber` INT( 11 ) NOT NULL");
    $dbh->do("UPDATE `virtualshelfcontents` SET biblionumber=(SELECT biblionumber FROM items WHERE items.itemnumber=virtualshelfcontents.itemnumber)");
    # drop all foreign keys : otherwise, we can't drop itemnumber field.
    DropAllForeignKeys('virtualshelfcontents');
    # create the new foreign keys (on biblionumber)
    $dbh->do("ALTER TABLE `virtualshelfcontents` ADD FOREIGN KEY biblionumber_fk (biblionumber) REFERENCES biblio (biblionumber) ON UPDATE CASCADE ON DELETE CASCADE");
    # re-create the foreign key on virtualshelf
    $dbh->do("ALTER TABLE `virtualshelfcontents` ADD FOREIGN KEY shelfnumber_fk (shelfnumber) REFERENCES virtualshelves (shelfnumber) ON UPDATE CASCADE ON DELETE CASCADE");
    # now we can drop the itemnumber column
    $dbh->do("ALTER TABLE `virtualshelfcontents` DROP `itemnumber`");
    print "Upgrade to $DBversion done (virtualshelves)\n";
    SetVersion ($DBversion);
}


$DBversion = "3.00.00.002";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    $dbh->do("DROP TABLE sessions");
    $dbh->do("CREATE TABLE `sessions` (
  `id` char(32) NOT NULL,
  `a_session` text NOT NULL,
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
    print "Upgrade to $DBversion done (sessions uses CGI::session, new table structure for sessions)\n";
    SetVersion ($DBversion);
}


$DBversion = "3.00.00.003";
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    if (C4::Context->preference("opaclanguage") eq "fr") {
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
                        MODIFY `marc` BLOB,
                        ADD `cn_source` VARCHAR(10) DEFAULT NULL AFTER `url`,
                        ADD `cn_class` VARCHAR(30) DEFAULT NULL AFTER `cn_source`,
                        ADD `cn_item` VARCHAR(10) DEFAULT NULL AFTER `cn_class`,
                        ADD `cn_suffix` VARCHAR(10) DEFAULT NULL AFTER `cn_item`,
                        ADD `cn_sort` VARCHAR(30) DEFAULT NULL AFTER `cn_suffix`,
                        ADD `totalissues` INT(10) AFTER `cn_sort`,
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
	$dbh->do("ALTER TABLE `branchcategories` CHANGE `categorycode` `categorycode` char(10) ");
	$dbh->do("ALTER TABLE `branchcategories` CHANGE `categoryname` `categoryname` varchar(32) ");
	$dbh->do("ALTER TABLE `branchcategories` ADD COLUMN `categorytype` varchar(16) ");
	$dbh->do("UPDATE `branchcategories` SET `categorytype` = 'properties'");
	$dbh->do("ALTER TABLE `branchrelations` CHANGE `categorycode` `categorycode` char(10) ");
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
                ADD `damaged` tinyint(1) default NULL");
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
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('noOPACHolds',0,'If ON, disables holds globally',NULL,'YesNo')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('emailLibrarianWhenHoldIsPlaced',0,'If ON, emails the librarian whenever a hold is placed',NULL,'YesNo')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('holdCancelLength','','Specify how many days before a hold is canceled',NULL,'free')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('libraryAddress','','The address to use for printing receipts, overdues, etc. if different than physical address',NULL,'free')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('finesMode','test','Choose the fines mode, test or production','test|production','Choice')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('globalDueDate','','If set, allows a global static due date for all checkouts',NULL,'free')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('itemBarcodeInputFilter','','If set, allows specification of a item barcode input filter','cuecat','Choice')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('singleBranchMode',0,'Operate in Single-branch mode, hide branch selection in the OPAC',NULL,'YesNo')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('URLLinkText','','Text to display as the link anchor in the OPAC',NULL,'free')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('noOPACUserLogin',0,'If ON, disables the OPAC User Login',NULL,'YesNo')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('OPACSubscriptionDisplay','economical','Specify how to display subscription information in the OPAC','economical|off|full','Choice')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('OPACDisplayExtendedSubInfo',1,'If ON, extended subscription information is displayed in the OPAC',NULL,'YesNo')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('OPACViewOthersSuggestions',0,'If ON, allows all suggestions to be displayed in the OPAC',NULL,'YesNo')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('OPACURLOpenInNewWindow',0,'If ON, URLs in the OPAC open in a new window',NULL,'YesNo')");
$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('hideBiblioNumber',0,'If ON, hides the biblionumber in the detail page on the OPAC',NULL,'YesNo')");
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
      my $finish=$dbh->prepare("INSERT into systempreferences (variable,value,explanation) values ('Version',?,'The Koha database version. Don t change this value manually, it s holded by the webinstaller')");
      $finish->execute($kohaversion);
    }
}
exit;

# Revision 1.172  2007/07/19 10:21:22  hdl
