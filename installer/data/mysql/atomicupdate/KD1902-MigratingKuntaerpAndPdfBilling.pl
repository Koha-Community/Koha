#!/usr/bin/perl

# Copyright Koha-Suomi 2017
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
use Koha::AtomicUpdater;

my $dbh = C4::Context->dbh();
my $atomicUpdater = Koha::AtomicUpdater->new();

unless($atomicUpdater->find('1902')) {

    $dbh->do("INSERT INTO systempreferences (variable, value, options, explanation, type) VALUES ('RemoveFineOnReturn', '', '', 'Choose which fines will be removed on item return', 'Choice');");
    if ($dbh->errstr)
	{
	  die "Could not update first insert: Remove 1902 from atomicupdate table and fix query (KD1092: Migrate KuntaErp and PDF-billing to a new Koha version)\n";

	}
    $dbh->do("INSERT INTO branchcategories (categorycode, categoryname, codedescription, categorytype) VALUES ('PDFBILL', 'PDF-laskutus', 'Luo PDF-laskuja tulostettaviksi', 'properties');");

    if ($dbh->errstr)
	{
	  die "Could not update second insert: Remove 1902 from atomicupdate table and fix query (KD1092: Migrate KuntaErp and PDF-billing to a new Koha version)\n";
	}

	$dbh->do("INSERT INTO branchcategories (categorycode, categoryname, codedescription, categorytype) VALUES ('SAPERP', 'Sap-laskutus', 'Lähettää laskuja KuntaErpiin SAPilla', 'properties');");

    if ($dbh->errstr)
	{
	  die "Could not update second insert: Remove 1902 from atomicupdate table and fix query (KD1092: Migrate KuntaErp and PDF-billing to a new Koha version)\n";
	}

	$dbh->do("CREATE TABLE `overduebills` (
		`bill_id` int(11) NOT NULL AUTO_INCREMENT,
		`issue_id` int(11) NOT NULL,
		`timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
		`billingdate` datetime DEFAULT NULL,
		PRIMARY KEY (`bill_id`),
		KEY `issue_id` (`issue_id`)
		) DEFAULT CHARSET=utf8;
		");

    if ($dbh->errstr)
	{
	  die "Could not create overduebills table: Remove 1902 from atomicupdate table and fix query (KD1092: Migrate KuntaErp and PDF-billing to a new Koha version)\n";
	}


    print "Upgrade done (KD1092: Migrate KuntaErp and PDF-billing to a new Koha version)\n";
}