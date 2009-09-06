#!/usr/bin/perl
#
# Copyright 2009 Foundations Bible College.
#
# This file is part of Koha.
#
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
    DROP TABLE IF EXISTS labels_batches_tmp;");
$sth->do("
    CREATE TABLE `labels_batches_tmp` (
      `label_id` int(11) NOT NULL auto_increment,
      `batch_id` int(10) NOT NULL default '1',
      `item_number` int(11) NOT NULL default '0',
      `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
      `branch_code` varchar(10) NOT NULL default 'NB',
      PRIMARY KEY USING BTREE (`label_id`),
      KEY `branch_fk_constraint` (`branch_code`),
      KEY `item_fk_constraint` (`item_number`),
      FOREIGN KEY (`branch_code`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE,
      FOREIGN KEY (`item_number`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
") or die "DB ERROR: " . $sth->errstr . "\n";

$sth->do("
    DROP TABLE IF EXISTS labels_layouts_tmp;");
$sth->do("
    CREATE TABLE `labels_layouts_tmp` (
      `layout_id` int(4) NOT NULL auto_increment,
      `barcode_type` char(100) NOT NULL default 'CODE39',
      `printing_type` char(32) NOT NULL default 'BAR',
      `layout_name` char(20) NOT NULL default 'DEFAULT',
      `guidebox` int(1) default '0',
      `font` char(10) character set utf8 collate utf8_unicode_ci NOT NULL default 'TR',
      `font_size` int(4) NOT NULL default '10',
      `callnum_split` int(1) default '0',
      `text_justify` char(1) character set utf8 collate utf8_unicode_ci NOT NULL default 'L',
      `format_string` varchar(210) NOT NULL default 'barcode',
      PRIMARY KEY  USING BTREE (`layout_id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
") or die "DB ERROR: " . $sth->errstr . "\n";

$sth->do("
    DROP TABLE IF EXISTS labels_templates_tmp;");
$sth->do("
    CREATE TABLE `labels_templates_tmp` (
      `template_id` int(4) NOT NULL auto_increment,
      `profile_id` int(4) default NULL,
      `template_code` char(100) NOT NULL default 'DEFAULT TEMPLATE',
      `template_desc` char(100) NOT NULL default 'Default description',
      `page_width` float NOT NULL default '0',
      `page_height` float NOT NULL default '0',
      `label_width` float NOT NULL default '0',
      `label_height` float NOT NULL default '0',
      `top_text_margin` float NOT NULL default '0',
      `left_text_margin` float NOT NULL default '0',
      `top_margin` float NOT NULL default '0',
      `left_margin` float NOT NULL default '0',
      `cols` int(2) NOT NULL default '0',
      `rows` int(2) NOT NULL default '0',
      `col_gap` float NOT NULL default '0',
      `row_gap` float NOT NULL default '0',
      `units` char(20) NOT NULL default 'POINT',
      PRIMARY KEY  (`template_id`),
      KEY `template_profile_fk_constraint` (`profile_id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
") or die "DB ERROR: " . $sth->errstr . "\n";

$sth->do("
    DROP TABLE IF EXISTS printers_profile_tmp;");
$sth->do("
    CREATE TABLE `printers_profile_tmp` (
      `profile_id` int(4) NOT NULL auto_increment,
      `printer_name` varchar(40) NOT NULL default 'Default Printer',
      `template_id` int(4) NOT NULL default '0',
      `paper_bin` varchar(20) NOT NULL default 'Bypass',
      `offset_horz` float NOT NULL default '0',
      `offset_vert` float NOT NULL default '0',
      `creep_horz` float NOT NULL default '0',
      `creep_vert` float NOT NULL default '0',
      `units` char(20) NOT NULL default 'POINT',
      PRIMARY KEY  (`profile_id`),
      UNIQUE KEY `printername` (`printer_name`,`template_id`,`paper_bin`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
") or die "DB ERROR: " . $sth->errstr . "\n";

# Migrate data from existing tables to new tables...

$sth->do("INSERT INTO `labels_batches_tmp` (label_id, batch_id, item_number) SELECT labelid, batch_id, itemnumber FROM labels;") or die "DB ERROR: " . $sth->errstr . "\n";
# Since the new label creator keys batches on branch code we must add a branch code during the conversion; the simplest solution appears to be to grab the top branch code from the branches table...
$sth->do("UPDATE `labels_batches_tmp` SET branch_code=(SELECT branchcode FROM branches LIMIT 0,1);") or die "DB ERROR: " . $sth->errstr . "\n";


$sth->do("INSERT INTO `labels_layouts_tmp` (layout_id, barcode_type, printing_type, layout_name, guidebox, callnum_split, text_justify, format_string) SELECT lc.id, lc.barcodetype, lc.printingtype, lc.layoutname, lc.guidebox, lc.callnum_split, lc.text_justify, lc.formatstring FROM labels_conf AS lc;") or die "DB ERROR: " . $sth->errstr . "\n";

$sth->do("INSERT INTO `labels_templates_tmp` (template_id, template_code, template_desc, page_width, page_height, label_width, label_height, top_margin, left_margin, cols, rows, col_gap, row_gap, units) SELECT lt.tmpl_id, lt.tmpl_code, lt.tmpl_desc, lt.page_width, lt.page_height, lt.label_width, lt.label_height, lt.topmargin, lt.leftmargin, lt.cols, lt.rows, lt.colgap, lt.rowgap, lt.units FROM labels_templates AS lt;") or die "DB ERROR: " . $sth->errstr . "\n";

$sth->do("INSERT INTO `printers_profile_tmp` (profile_id, printer_name, template_id, paper_bin, offset_horz, offset_vert, creep_horz, creep_vert, units) SELECT prof_id, printername, tmpl_id, paper_bin, offset_horz, offset_vert, creep_horz, creep_vert, unit FROM printers_profile;") or die "DB ERROR: " . $sth->errstr . "\n";


my $sth1 = C4::Context->dbh->prepare("SELECT layout_id, format_string FROM labels_layouts_tmp;");
#$sth1->{'TraceLevel'} = 3;
$sth1->execute or die "DB ERROR: " . $sth1->errstr . "\n";
while (my $layout = $sth1->fetchrow_hashref()) {
    if (!$layout->{'format_string'}) {
        my $sth2 = C4::Context->dbh->prepare("SELECT id, title, subtitle, itemtype, barcode, dewey, classification, subclass, itemcallnumber, author, issn, isbn, ccode FROM labels_conf WHERE id = " . $layout->{'layout_id'});
        $sth2->execute or die "DB ERROR: " . $sth2->errstr . "\n";
        my $record = $sth2->fetchrow_hashref();
        my @label_fields = ();
        RECORD:
        foreach (keys(%$record)) {
            next RECORD if $record->{$_} eq '' or $_ eq 'id';
            $label_fields[$record->{$_}] = $_;
        }
        shift @label_fields;
        my $format_string = join (",", @label_fields);
#        my $format_string = s/^,//i;
        $sth->do("UPDATE `labels_layouts_tmp` SET format_string=\'$format_string\' WHERE layout_id = " . $record->{'id'}) or die "DB ERROR: " . $sth->errstr . "\n";
    }
}

my $sth3 = C4::Context->dbh->prepare("SELECT template_id FROM labels_templates_tmp;");
$sth3->execute or die "DB ERROR: " . $sth3->errstr . "\n";
RECORD:
while (my $template = $sth3->fetchrow_hashref()) {
        my $sth4 = C4::Context->dbh->prepare("SELECT profile_id FROM printers_profile_tmp WHERE template_id = " . $template->{'template_id'});
        $sth4->execute or die "DB ERROR: " . $sth4->errstr . "\n";
        my $profile_id = $sth4->fetchrow_hashref();
        next RECORD if $profile_id->{'profile_id'} eq '';
        $sth->do("UPDATE `labels_templates_tmp` SET profile_id=\'" . $profile_id->{'profile_id'} . "\' WHERE template_id = " . $template->{'template_id'}) or die "DB ERROR: " . $sth->errstr . "\n";
}

# Drop old tables....

$sth->do("DROP TABLE IF EXISTS labels;") or die "DB ERROR: " . $sth->errstr . "\n";
$sth->do("DROP TABLE IF EXISTS labels_conf;") or die "DB ERROR: " . $sth->errstr . "\n";
$sth->do("DROP TABLE IF EXISTS labels_profile;") or die "DB ERROR: " . $sth->errstr . "\n";
$sth->do("DROP TABLE IF EXISTS labels_templates;") or die "DB ERROR: " . $sth->errstr . "\n";
$sth->do("DROP TABLE IF EXISTS printers_profile;") or die "DB ERROR: " . $sth->errstr . "\n";

# Rename temporary tables to permenant names...

$sth->do("ALTER TABLE labels_batches_tmp RENAME TO labels_batches;") or die "DB ERROR: " . $sth->errstr . "\n";
$sth->do("ALTER TABLE labels_layouts_tmp RENAME TO labels_layouts;") or die "DB ERROR: " . $sth->errstr . "\n";
$sth->do("ALTER TABLE labels_templates_tmp RENAME TO labels_templates;") or die "DB ERROR: " . $sth->errstr . "\n";
$sth->do("ALTER TABLE printers_profile_tmp RENAME TO printers_profile;") or die "DB ERROR: " . $sth->errstr . "\n";


# Re-enable key checks...
$sth->do("
    SET UNIQUE_CHECKS = 1;
") or die "DB ERROR: " . $sth->errstr . "\n";

$sth->do("
    SET  FOREIGN_KEY_CHECKS = 1;
") or die "DB ERROR: " . $sth->errstr . "\n";
