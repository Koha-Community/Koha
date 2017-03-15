#!/usr/bin/perl

# Copyright KohaSuomi 2016
#
# This file is part of Koha.
#

use C4::Context;

use Koha::BiblioDataElements;

my $dbh = C4::Context->dbh();

$dbh->do(q{ALTER TABLE biblio_data_elements ADD COLUMN encoding_level varchar(1);});
$dbh->do(q{ALTER TABLE biblio_data_elements ADD KEY `encoding_level` (`encoding_level`);});
Koha::BiblioDataElements::markForReindex();
print "Upgrade done (KD-257-3 - Add 'Encoding level' to the Biblio data elements -table)\n";
