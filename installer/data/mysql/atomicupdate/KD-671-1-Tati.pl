#!/usr/bin/perl

# Copyright KohaSuomi
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

use DateTime;

use C4::Context;
use C4::BatchOverlay::RuleManager;
use Koha::AtomicUpdater;

my $dbh = C4::Context->dbh();
my $atomicUpdater = Koha::AtomicUpdater->new();

unless($atomicUpdater->find('KD671-1')) {
    print "KD-671-1 - Deploying TäTi - Batch Overlay 'candidateCriteria'-feature\n";

    my $now = DateTime->now(time_zone => C4::Context->tz);
    my $oneYearAgo = $now->clone()->subtract(years => 1);
    my $twoYearsAgo = $now->clone()->subtract(years => 2);

    C4::BatchOverlay::RuleManager::alterAllRules({
        default => {
            candidateCriteria => {
                lowlyCatalogued => 'always',
                monthsPast => 'Date-of-acquisition 2',
                publicationDates => [$now->year, $oneYearAgo->year, $twoYearsAgo->year],
            }
        }
    });

    print "Upgrade done (KD-671-1 - TäTi - Batch Overlay 'candidateCriteria'-feature)\n";
}
