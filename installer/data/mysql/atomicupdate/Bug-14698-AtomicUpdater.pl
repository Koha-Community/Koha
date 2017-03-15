#!/usr/bin/perl

# Copyright Open Source Freedom Fighters
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use C4::Context;

my $dbh = C4::Context->dbh();

$dbh->do("
CREATE TABLE `atomicupdates` (
  `atomicupdate_id` int(11) unsigned NOT NULL auto_increment,
  `issue_id` varchar(20) NOT NULL,
  `filename` varchar(30) NOT NULL,
  `modification_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY  (`atomicupdate_id`),
  UNIQUE KEY `origincode` (`issue_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
");
$dbh->do("INSERT INTO atomicupdates (issue_id, filename) VALUES ('Bug14698', 'Bug14698-AtomicUpdater.pl')");

print "Upgrade to Bug 14698 - AtomicUpdater - Keeps track of which updates have been applied to a database done\n";
