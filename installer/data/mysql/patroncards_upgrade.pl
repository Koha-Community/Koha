#!/usr/bin/perl
#
# Copyright 2009 Foundations Bible College.
#
# This file is part of Koha.
#
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

#use strict;
#use warnings; FIXME - Bug 2505

use C4::Context;

my $sth = C4::Context->dbh;

# NOTE: As long as we die on error *before* the DROP TABLE instructions are executed, the script may simply be rerun after addressing whatever errors occur; If we get past the data conversion without error, the DROPs and ALTERs could be executed manually if need be.

# Turn off key checks for duration of script...
$sth->do("
    SET UNIQUE_CHECKS = 0;
") or die "DB ERROR: " . $sth->errstr . "\n";

$sth->do("
    SET FOREIGN_KEY_CHECKS = 0;
") or die "DB ERROR: " . $sth->errstr . "\n";

# Create new tables with temporary names...
$sth->do("
    DROP TABLE IF EXISTS creator_batches_tmp;");
$sth->do("
    CREATE TABLE `creator_batches_tmp` (
      `label_id` int(11) NOT NULL AUTO_INCREMENT,
      `batch_id` int(10) NOT NULL DEFAULT '1',
      `item_number` int(11) DEFAULT NULL,
      `borrower_number` int(11) DEFAULT NULL,
      `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      `branch_code` varchar(10) NOT NULL DEFAULT 'NB',
      `creator` char(15) NOT NULL DEFAULT 'Labels',
      PRIMARY KEY (`label_id`),
      KEY `branch_fk_constraint` (`branch_code`),
      KEY `item_fk_constraint` (`item_number`),
      KEY `borrower_fk_constraint` (`borrower_number`),
      FOREIGN KEY (`borrower_number`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
      FOREIGN KEY (`branch_code`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE,
      FOREIGN KEY (`item_number`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
") or die "DB ERROR: " . $sth->errstr . "\n";

$sth->do("
    DROP TABLE IF EXISTS creator_layouts_tmp;");
$sth->do("
    CREATE TABLE `creator_layouts_tmp` (
      `layout_id` int(4) NOT NULL AUTO_INCREMENT,
      `barcode_type` char(100) NOT NULL DEFAULT 'CODE39',
      `start_label` int(2) NOT NULL DEFAULT '1',
      `printing_type` char(32) NOT NULL DEFAULT 'BAR',
      `layout_name` char(20) NOT NULL DEFAULT 'DEFAULT',
      `guidebox` int(1) DEFAULT '0',
      `font` char(10) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL DEFAULT 'TR',
      `font_size` int(4) NOT NULL DEFAULT '10',
      `units` char(20) NOT NULL DEFAULT 'POINT',
      `callnum_split` int(1) DEFAULT '0',
      `text_justify` char(1) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL DEFAULT 'L',
      `format_string` varchar(210) NOT NULL DEFAULT 'barcode',
      `layout_xml` text NOT NULL,
      `creator` char(15) NOT NULL DEFAULT 'Labels',
      PRIMARY KEY (`layout_id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
") or die "DB ERROR: " . $sth->errstr . "\n";

$sth->do("
    DROP TABLE IF EXISTS creator_templates_tmp;");
$sth->do("
    CREATE TABLE `creator_templates_tmp` (
      `template_id` int(4) NOT NULL AUTO_INCREMENT,
      `profile_id` int(4) DEFAULT NULL,
      `template_code` char(100) NOT NULL DEFAULT 'DEFAULT TEMPLATE',
      `template_desc` char(100) NOT NULL DEFAULT 'Default description',
      `page_width` float NOT NULL DEFAULT '0',
      `page_height` float NOT NULL DEFAULT '0',
      `label_width` float NOT NULL DEFAULT '0',
      `label_height` float NOT NULL DEFAULT '0',
      `top_text_margin` float NOT NULL DEFAULT '0',
      `left_text_margin` float NOT NULL DEFAULT '0',
      `top_margin` float NOT NULL DEFAULT '0',
      `left_margin` float NOT NULL DEFAULT '0',
      `cols` int(2) NOT NULL DEFAULT '0',
      `rows` int(2) NOT NULL DEFAULT '0',
      `col_gap` float NOT NULL DEFAULT '0',
      `row_gap` float NOT NULL DEFAULT '0',
      `units` char(20) NOT NULL DEFAULT 'POINT',
      `creator` char(15) NOT NULL DEFAULT 'Labels',
      PRIMARY KEY (`template_id`),
      KEY `template_profile_fk_constraint` (`profile_id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
") or die "DB ERROR: " . $sth->errstr . "\n";

$sth->do("
    DROP TABLE IF EXISTS `creator_images`;");
$sth->do("
CREATE TABLE `creator_images` (
      `image_id` int(4) NOT NULL AUTO_INCREMENT,
      `imagefile` mediumblob,
      `image_name` char(20) NOT NULL DEFAULT 'DEFAULT',
      PRIMARY KEY (`image_id`),
      UNIQUE KEY `image_name_index` (`image_name`)
    ) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8;
") or die "DB ERROR: " . $sth->errstr . "\n";

$sth->do("
    ALTER TABLE printers_profile ADD COLUMN `creator` char(15) NOT NULL DEFAULT 'Labels';
") or die "DB ERROR: " . $sth->errstr . "\n";

$sth->do("
    ALTER TABLE printers_profile DROP KEY printername;
") or die "DB ERROR: " . $sth->errstr . "\n";

$sth->do("
    ALTER TABLE printers_profile ADD UNIQUE KEY `printername` (`printer_name`,`template_id`,`paper_bin`,`creator`);
") or die "DB ERROR: " . $sth->errstr . "\n";

# Migrate data from existing tables to new tables...

$sth->do("INSERT INTO `creator_batches_tmp` (label_id, batch_id, item_number, timestamp, branch_code) SELECT label_id, batch_id, item_number, timestamp, branch_code FROM labels_batches;") or die "DB ERROR: " . $sth->errstr . "\n";

$sth->do("INSERT INTO `creator_layouts_tmp` (layout_id, barcode_type, printing_type, layout_name, guidebox, callnum_split, text_justify, format_string) SELECT layout_id, barcode_type, printing_type, layout_name, guidebox, callnum_split, text_justify, format_string FROM labels_layouts;") or die "DB ERROR: " . $sth->errstr . "\n";

$sth->do("INSERT INTO `creator_templates_tmp` (template_id, template_code, template_desc, page_width, page_height, label_width, label_height, top_margin, left_margin, cols, rows, col_gap, row_gap, units) SELECT template_id, template_code, template_desc, page_width, page_height, label_width, label_height, top_margin, left_margin, cols, rows, col_gap, row_gap, units FROM labels_templates;") or die "DB ERROR: " . $sth->errstr . "\n";

# Drop old tables....

$sth->do("DROP TABLE IF EXISTS labels_batches;") or die "DB ERROR: " . $sth->errstr . "\n";
$sth->do("DROP TABLE IF EXISTS labels_layouts;") or die "DB ERROR: " . $sth->errstr . "\n";
$sth->do("DROP TABLE IF EXISTS labels_templates;") or die "DB ERROR: " . $sth->errstr . "\n";

# Rename temporary tables to permenant names...

$sth->do("ALTER TABLE creator_batches_tmp RENAME TO creator_batches;") or die "DB ERROR: " . $sth->errstr . "\n";
$sth->do("ALTER TABLE creator_layouts_tmp RENAME TO creator_layouts;") or die "DB ERROR: " . $sth->errstr . "\n";
$sth->do("ALTER TABLE creator_templates_tmp RENAME TO creator_templates;") or die "DB ERROR: " . $sth->errstr . "\n";

# Re-enable key checks...
$sth->do("
    SET UNIQUE_CHECKS = 1;
") or die "DB ERROR: " . $sth->errstr . "\n";

$sth->do("
    SET  FOREIGN_KEY_CHECKS = 1;
") or die "DB ERROR: " . $sth->errstr . "\n";
