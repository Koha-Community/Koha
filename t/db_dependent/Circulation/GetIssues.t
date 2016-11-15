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

use Test::More tests => 10;
use Test::MockModule;
use t::lib::TestBuilder;

use C4::Biblio;
use C4::Circulation;
use C4::Items;
use C4::Members;

use Koha::Library;
use Koha::Libraries;
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

my $borrower = GetMember(borrowernumber => $borrowernumber);

# Need to mock userenv for AddIssue
my $module = new Test::MockModule('C4::Context');
$module->mock('userenv', sub { { branch => $branchcode } });
AddIssue($borrower, '0101');
AddIssue($borrower, '0203');

# Begin tests...
my $issues;
$issues = C4::Circulation::GetIssues({biblionumber => $biblionumber1});
is(scalar @$issues, 1, "Biblio $biblionumber1 has 1 item issued");
is($issues->[0]->{itemnumber}, $itemnumber1, "First item of biblio $biblionumber1 is issued");

$issues = C4::Circulation::GetIssues({biblionumber => $biblionumber2});
is(scalar @$issues, 1, "Biblio $biblionumber2 has 1 item issued");
is($issues->[0]->{itemnumber}, $itemnumber3, "First item of biblio $biblionumber2 is issued");

$issues = C4::Circulation::GetIssues({borrowernumber => $borrowernumber});
is(scalar @$issues, 2, "Borrower $borrowernumber checked out 2 items");

$issues = C4::Circulation::GetIssues({borrowernumber => $borrowernumber, biblionumber => $biblionumber1});
is(scalar @$issues, 1, "One of those is an item from biblio $biblionumber1");

$issues = C4::Circulation::GetIssues({borrowernumber => $borrowernumber, biblionumber => $biblionumber2});
is(scalar @$issues, 1, "The other is an item from biblio $biblionumber2");

$issues = C4::Circulation::GetIssues({itemnumber => $itemnumber2});
is(scalar @$issues, 0, "No one has issued the second item of biblio $biblionumber2");

my $onsite_checkouts = GetPendingOnSiteCheckouts;
is( scalar @$onsite_checkouts, 0, "No pending on-site checkouts" );

my $itemnumber4 = AddItem({ barcode => '0104', %item_infos }, $biblionumber1);
AddIssue( $borrower, '0104', undef, undef, undef, undef, { onsite_checkout => 1 } );
$onsite_checkouts = GetPendingOnSiteCheckouts;
is( scalar @$onsite_checkouts, 1, "There is 1 pending on-site checkout" );

$schema->storage->txn_rollback;

1;
