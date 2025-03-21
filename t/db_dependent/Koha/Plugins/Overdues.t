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

use Test::NoWarnings;
use Test::More tests => 6;

use C4::Overdues qw(CalcFine);

use File::Basename;

use t::lib::Mocks;
use t::lib::TestBuilder;

BEGIN {
    # Mock pluginsdir before loading Plugins module
    my $path = dirname(__FILE__) . '/../../../lib/plugins';
    t::lib::Mocks::mock_config( 'pluginsdir', $path );

    use_ok('C4::Overdues');
    use_ok('Koha::Plugins');
    use_ok('Koha::Plugins::Handler');
    use_ok('Koha::Plugin::Test');
}

t::lib::Mocks::mock_config( 'enable_plugins', 1 );

my $builder = t::lib::TestBuilder->new;

my $branch = $builder->build(
    {
        source => 'Branch',
    }
);

my $category = $builder->build(
    {
        source => 'Category',
    }
);

my $item = $builder->build_sample_item;

subtest 'overwrite_calc_fine hook tests' => sub {
    plan tests => 6;

    my $schema = Koha::Database->new->schema;
    $schema->storage->txn_begin;

    my $plugins = Koha::Plugins->new;
    $plugins->InstallPlugins;
    Koha::Plugin::Test->new->enable;

    Koha::CirculationRules->set_rules(
        {
            branchcode   => undef,
            categorycode => undef,
            itemtype     => undef,
            rules        => {
                fine                          => '2.00',
                lengthunit                    => 'days',
                finedays                      => 0,
                firstremind                   => 0,
                chargeperiod                  => 1,
                overduefinescap               => '0',
                cap_fine_to_replacement_price => 0,
            }
        },
    );

    my $due_date = DateTime->new(
        year  => 2000,
        month => 1,
        day   => 1,
    );
    my $end_date = DateTime->new(
        year  => 2000,
        month => 1,
        day   => 30,
    );

    my ( $amount, $units, $chargable_units ) = CalcFine( $item->{itemnumber}, undef, undef, $due_date, $end_date );

    is( $amount,          87, 'Amount is calculated correctly with custom function' );
    is( $units,           29, 'Units are calculated correctly with custom function' );
    is( $chargable_units, 27, 'Chargable units are calculated correctly with custom function' );

    ( $amount, $units, $chargable_units ) =
        CalcFine( $item->{itemnumber}, $category->{categorycode}, $branch->{branchcode}, $due_date, $end_date );

    is( $amount,          58, 'Amount is calculated correctly with original function' );
    is( $units,           29, 'Units are calculated correctly with original function' );
    is( $chargable_units, 29, 'Chargable units are calculated correctly with original function' );

    Koha::Plugins->RemovePlugins;
    $schema->storage->txn_rollback;
};
