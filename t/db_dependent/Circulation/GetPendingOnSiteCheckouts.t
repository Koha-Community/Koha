#!/usr/bin/perl

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

use Modern::Perl;

use Test::More tests => 2;
use Test::MockModule;
use t::lib::TestBuilder;

use C4::Circulation;
use C4::Biblio;
use C4::Items;
use C4::Members;

use Koha::Libraries;
use Koha::Patrons;
use Koha::Patron::Categories;

use MARC::Record;

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;
my $dbh = C4::Context->dbh;

$dbh->do(q|DELETE FROM issues|);

my $branchcode = $builder->build({ source => 'Branch' })->{ branchcode };
my $itemtype   = $builder->build({ source => 'Itemtype' })->{ itemtype };

my %item_infos = (
    homebranch    => $branchcode,
    holdingbranch => $branchcode,
    itype         => $itemtype
);

my ($biblionumber1) = AddBiblio(MARC::Record->new, '');
my $itemnumber1 = AddItem({ barcode => '0101', %item_infos }, $biblionumber1);
my $itemnumber2 = AddItem({ barcode => '0102', %item_infos }, $biblionumber1);

my ($biblionumber2) = AddBiblio(MARC::Record->new, '');
my $itemnumber3 = AddItem({ barcode => '0203', %item_infos }, $biblionumber2);

my $categorycode = $builder->build({ source => 'Category' })->{ categorycode };
my $borrowernumber = $builder->build(
    {   source => 'Borrower',
        value  => { categorycode => $categorycode, branchcode => $branchcode }
    }
)->{borrowernumber};

my $borrower = Koha::Patrons->find( $borrowernumber )->unblessed;

# Need to mock userenv for AddIssue
my $module = new Test::MockModule('C4::Context');
$module->mock('userenv', sub { { branch => $branchcode } });
AddIssue($borrower, '0101');
AddIssue($borrower, '0203');

# Begin tests...
my $onsite_checkouts = GetPendingOnSiteCheckouts;
is( scalar @$onsite_checkouts, 0, "No pending on-site checkouts" );

my $itemnumber4 = AddItem({ barcode => '0104', %item_infos }, $biblionumber1);
AddIssue( $borrower, '0104', undef, undef, undef, undef, { onsite_checkout => 1 } );
$onsite_checkouts = GetPendingOnSiteCheckouts;
is( scalar @$onsite_checkouts, 1, "There is 1 pending on-site checkout" );

$schema->storage->txn_rollback;

