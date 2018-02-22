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

use Test::More tests => 14;
use Test::MockModule;
use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Context;
use C4::Circulation;
use C4::Biblio;
use C4::Items;

use Koha::Database;
use Koha::Patrons;

my $schema  = Koha::Database->new()->schema();
my $dbh     = $schema->storage->dbh;
my $builder = t::lib::TestBuilder->new();

# Start transaction
$dbh->{RaiseError} = 1;
$schema->storage->txn_begin();

my $itemtype = $builder->build({ source => 'Itemtype' })->{ itemtype };
my $category = $builder->build({ source => 'Category' })->{ categorycode };
my $branch_1 = $builder->build({ source => 'Branch' });
my $branch_2 = $builder->build({ source => 'Branch' });

my $c4_context = Test::MockModule->new('C4::Context');
$c4_context->mock('userenv', sub {
    { branch => $branch_1->{ branchcode } }
});
t::lib::Mocks::mock_preference('item-level_itypes', '0');

my $biblionumber = create_biblio('Test 1', $itemtype);
AddItem({
    barcode => 'GTI_BARCODE_001',
    homebranch => $branch_1->{ branchcode },
    ccode => 'GTI_CCODE',
}, $biblionumber);

$biblionumber = create_biblio('Test 2', $itemtype);
AddItem({
    barcode => 'GTI_BARCODE_002',
    homebranch => $branch_2->{ branchcode },
}, $biblionumber);

my $borrowernumber = Koha::Patron->new({
    userid => 'gti.test',
    categorycode => $category,
    branchcode => $branch_1->{ branchcode }
})->store->borrowernumber;
my $borrower = Koha::Patrons->find( $borrowernumber )->unblessed;

AddIssue($borrower, 'GTI_BARCODE_001');
AddIssue($borrower, 'GTI_BARCODE_002');

#
# Start of tests
#

my @issues = GetTopIssues({count => 10, itemtype => $itemtype});
is(scalar @issues, 2);
is($issues[0]->{title}, 'Test 1');
is($issues[1]->{title}, 'Test 2');

@issues = GetTopIssues({count => 1, itemtype => $itemtype});
is(scalar @issues, 1);
is($issues[0]->{title}, 'Test 1');

@issues = GetTopIssues({count => 10, branch => $branch_2->{ branchcode }});
is(scalar @issues, 1);
is($issues[0]->{title}, 'Test 2');

@issues = GetTopIssues({count => 10, ccode => 'GTI_CCODE'});
is(scalar @issues, 1);
is($issues[0]->{title}, 'Test 1');

@issues = GetTopIssues({count => 10, itemtype => $itemtype, newness => 1});
is(scalar @issues, 2);
is($issues[0]->{title}, 'Test 1');
is($issues[1]->{title}, 'Test 2');

$dbh->do(q{
    UPDATE biblio
    SET datecreated = DATE_SUB(datecreated, INTERVAL 2 DAY)
    WHERE biblionumber = ?
}, undef, $biblionumber);

@issues = GetTopIssues({count => 10, itemtype => $itemtype, newness => 1});
is(scalar @issues, 1);
is($issues[0]->{title}, 'Test 1');

#
# End of tests
#

$schema->storage->txn_rollback();

sub create_biblio {
    my ($title, $itemtype) = @_;

    my ($title_tag, $title_subfield) = GetMarcFromKohaField('biblio.title', '');
    my ($it_tag, $it_subfield) = GetMarcFromKohaField('biblioitems.itemtype', '');

    my $record = MARC::Record->new();
    $record->append_fields(
        MARC::Field->new($title_tag, ' ', ' ', $title_subfield => $title),
        MARC::Field->new($it_tag, ' ', ' ', $it_subfield => $itemtype),
    );

    my ($biblionumber) = AddBiblio($record, '');

    return $biblionumber;
}
