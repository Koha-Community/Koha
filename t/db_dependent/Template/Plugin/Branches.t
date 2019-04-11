#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 18;

use C4::Context;
use C4::Biblio qw(AddBiblio);
use C4::Items qw(AddItem);
use Koha::Database;

use t::lib::TestBuilder;
use t::lib::Mocks;

BEGIN {
    use_ok('Koha::Template::Plugin::Branches');
}

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;
my $library = $builder->build({
    source => 'Branch',
    value => {
        branchcode => 'MYLIBRARY',
    }
});
my $another_library = $builder->build({
    source => 'Branch',
    value => {
        branchcode => 'ANOTHERLIB',
    }
});

my $plugin = Koha::Template::Plugin::Branches->new();
ok($plugin, "initialized Branches plugin");

my $name = $plugin->GetName($library->{branchcode});
is($name, $library->{branchname}, 'retrieved expected name for library');

$name = $plugin->GetName('__ANY__');
is($name, '', 'received empty string as name of the "__ANY__" placeholder library code');

$name = $plugin->GetName(undef);
is($name, '', 'received empty string as name of NULL/undefined library code');

$library = $plugin->GetLoggedInBranchcode();
is($library, '', 'no active library if there is no active user session');

t::lib::Mocks::mock_userenv({ branchcode => 'MYLIBRARY' });
$library = $plugin->GetLoggedInBranchcode();
is($library, 'MYLIBRARY', 'GetLoggedInBranchcode() returns active library');

t::lib::Mocks::mock_preference( 'IndependentBranches', 0 );
my $libraries = $plugin->all();
ok( scalar(@$libraries) > 1, 'If IndependentBranches is not set, all libraries should be returned' );
is( grep ( { $_->{branchcode} eq 'MYLIBRARY'  and $_->{selected} == 1 } @$libraries ),       1, 'Without selected parameter, my library should be preselected' );
is( grep ( { $_->{branchcode} eq 'ANOTHERLIB' and not exists $_->{selected} } @$libraries ), 1, 'Without selected parameter, other library should not be preselected' );
$libraries = $plugin->all( { selected => 'ANOTHERLIB' } );
is( grep ( { $_->{branchcode} eq 'MYLIBRARY'  and not exists $_->{selected} } @$libraries ), 1, 'With selected parameter, my library should not be preselected' );
is( grep ( { $_->{branchcode} eq 'ANOTHERLIB' and $_->{selected} == 1 } @$libraries ),       1, 'With selected parameter, other library should be preselected' );
$libraries = $plugin->all( { selected => '' } );
is( grep ( { exists $_->{selected} } @$libraries ), 0, 'With selected parameter set to an empty string, no library should be preselected' );

my $total = @{$plugin->all};
my $pickupable = @{$plugin->all( { search_params => { pickup_location => 1 } }) };
my $yet_another_library = $builder->build({
    source => 'Branch',
    value => {
        branchcode => 'CANTPICKUP',
        pickup_location => 0,
    }
});
is(@{$plugin->all( { search_params => { pickup_location => 1 } }) }, $pickupable,
   'Adding a new library with pickups'
   .' disabled does not increase the amount returned by ->pickup_locations');
is(@{$plugin->all}, $total+1, 'However, adding a new library increases'
   .' the total amount gotten with ->all');

t::lib::Mocks::mock_preference( 'IndependentBranches', 1 );
$libraries = $plugin->all();
is( scalar(@$libraries), 1, 'If IndependentBranches is set, only 1 library should be returned' );
$libraries = $plugin->all( { unfiltered => 1 } );
ok( scalar(@$libraries) > 1, 'If IndependentBranches is set, all libraries should be returned if the unfiltered flag is set' );

subtest 'UseBranchTransferLimits = OFF' => sub {
    plan tests => 5;

    my $from = Koha::Library->new({
        branchcode => 'zzzfrom',
        branchname => 'zzzfrom',
        branchnotes => 'zzzfrom',
    })->store;
    my $to = Koha::Library->new({
        branchcode => 'zzzto',
        branchname => 'zzzto',
        branchnotes => 'zzzto',
    })->store;

    my ($bibnum, $title, $bibitemnum) = create_helper_biblio('DUMMY');
    # Create item instance for testing.
    my ($item_bibnum1, $item_bibitemnum1, $itemnumber1)
    = AddItem({ homebranch => $from->branchcode,
                holdingbranch => $from->branchcode } , $bibnum);
    my ($item_bibnum2, $item_bibitemnum2, $itemnumber2)
    = AddItem({ homebranch => $from->branchcode,
                holdingbranch => $from->branchcode } , $bibnum);
    my ($item_bibnum3, $item_bibitemnum3, $itemnumber3)
    = AddItem({ homebranch => $from->branchcode,
                holdingbranch => $from->branchcode } , $bibnum);
    my $biblio = Koha::Biblios->find($bibnum);

    t::lib::Mocks::mock_preference('UseBranchTransferLimits', 0);
    t::lib::Mocks::mock_preference('BranchTransferLimitsType', 'itemtype');
    t::lib::Mocks::mock_preference('item-level_itypes', 1);
    Koha::Item::Transfer::Limits->delete;
    Koha::Item::Transfer::Limit->new({
        fromBranch => $from->branchcode,
        toBranch => $to->branchcode,
        itemtype => $biblio->itemtype,
    })->store;
    my $total_pickup = Koha::Libraries->search({
        pickup_location => 1
    })->count;

    # Test TT plugin
    my $pickup = Koha::Template::Plugin::Branches::pickup_locations({ biblio => $bibnum });
    is(C4::Context->preference('UseBranchTransferLimits'), 0, 'Given system '
       .'preference UseBranchTransferLimits is switched OFF,');
    is(@{$pickup}, $total_pickup, 'Then the total number of pickup locations '
       .'equal number of libraries with pickup_location => 1');

    t::lib::Mocks::mock_preference('BranchTransferLimitsType', 'itemtype');
    t::lib::Mocks::mock_preference('item-level_itypes', 1);
    $pickup = Koha::Template::Plugin::Branches::pickup_locations({ biblio => $bibnum });
    is(@{$pickup}, $total_pickup, '...when '
       .'BranchTransferLimitsType = itemtype and item-level_itypes = 1');
    t::lib::Mocks::mock_preference('item-level_itypes', 0);
    $pickup = Koha::Template::Plugin::Branches::pickup_locations({ biblio => $bibnum });
    is(@{$pickup}, $total_pickup, '...as well as when '
       .'BranchTransferLimitsType = itemtype and item-level_itypes = 0');
    t::lib::Mocks::mock_preference('BranchTransferLimitsType', 'ccode');
    $pickup = Koha::Template::Plugin::Branches::pickup_locations({ biblio => $bibnum });
    is(@{$pickup}, $total_pickup, '...as well as when '
       .'BranchTransferLimitsType = ccode');

    t::lib::Mocks::mock_preference('item-level_itypes', 1);
};

sub create_helper_biblio {
    my $itemtype = shift;
    my ($bibnum, $title, $bibitemnum);
    my $bib = MARC::Record->new();
    $title = 'Silence in the library';
    $bib->append_fields(
        MARC::Field->new('100', ' ', ' ', a => 'Moffat, Steven'),
        MARC::Field->new('245', ' ', ' ', a => $title),
        MARC::Field->new('942', ' ', ' ', c => $itemtype),
    );
    return ($bibnum, $title, $bibitemnum) = AddBiblio($bib, '');
}
