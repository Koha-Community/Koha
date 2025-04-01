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

use Test::More tests => 8;
use Test::Warn;

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
    use_ok('Koha::Plugin::1_CalcFineEmpty');
    use_ok('Koha::Plugin::2_CalcFineNotEmpty');
    use_ok('Koha::Plugin::3_CalcFineBadValue');
    use_ok('Koha::Plugin::Test');
}

t::lib::Mocks::mock_config( 'enable_plugins', 1 );

my $builder = t::lib::TestBuilder->new;
my $schema  = Koha::Database->new->schema;

subtest 'overwrite_calc_fine hook tests' => sub {

    plan tests => 13;

    $schema->storage->txn_begin;

    my $library  = $builder->build_object( { class => 'Koha::Libraries', } );
    my $category = $builder->build_object( { class => 'Koha::Patron::Categories', } );
    my $item     = $builder->build_sample_item;
    my $patron   = $builder->build_object( { class => 'Koha::Patrons', } );

    Koha::Plugins->new->InstallPlugins();
    my $test_plugin = Koha::Plugin::Test->new->disable();

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

    my ( $amount, $units, $chargable_units ) =
        CalcFine( $item->unblessed, $category->categorycode, $library->branchcode, $due_date, $end_date );

    is( $amount,          58, 'Amount is calculated correctly with original function' );
    is( $units,           29, 'Units are calculated correctly with original function' );
    is( $chargable_units, 29, 'Chargable units are calculated correctly with original function' );

    # initialize undef value plugin
    my $empty_value_plugin = Koha::Plugin::1_CalcFineEmpty->new->enable();
    ( $amount, $units, $chargable_units ) =
        CalcFine( $item->unblessed, $category->categorycode, $library->branchcode, $due_date, $end_date );

    is( $amount,          58, 'Amount is calculated correctly with original function, undef plugin skipped' );
    is( $units,           29, 'Units are calculated correctly with original function, undef plugin skipped' );
    is( $chargable_units, 29, 'Chargable units are calculated correctly with original function, undef plugin skipped' );

    # initialize valid value plugin
    my $not_empty_value_plugin = Koha::Plugin::2_CalcFineNotEmpty->new->enable();

    ( $amount, $units, $chargable_units ) = CalcFine( $item->unblessed, undef, undef, $due_date, $end_date );

    is( $amount,          1, 'Amount is calculated correctly with custom function' );
    is( $units,           2, 'Units are calculated correctly with custom function' );
    is( $chargable_units, 3, 'Chargable units are calculated correctly with custom function' );

    # initialize bad value plugin
    my $bad_value_plugin = Koha::Plugin::3_CalcFineBadValue->new->enable();
    $not_empty_value_plugin->disable();

    ( $amount, $units, $chargable_units ) = CalcFine( $item->unblessed, undef, undef, $due_date, $end_date );

    is( $amount, 'a', 'Amount is calculated correctly with custom function, bad value returned anyway' );
    is( $units,  'b', 'Units are calculated correctly with custom function, bad value returned anyway' );
    is(
        $chargable_units, undef,
        'Chargable units are calculated correctly with custom function, bad value returned anyway'
    );

    Koha::Plugin::Test->new->enable();

    $empty_value_plugin->disable();
    $bad_value_plugin->disable();

    my $borrowernumber = $patron->borrowernumber;
    my $overdue        = $item->unblessed;
    $overdue->{borrowernumber} = $borrowernumber;

    my $itemnumber   = $item->itemnumber;
    my $branchcode   = $library->branchcode;
    my $categorycode = $category->categorycode;

    warnings_like { CalcFine( $overdue, $category->categorycode, $library->branchcode, $due_date, $end_date ); }
    [
        qr/itemnumber:$itemnumber/,
        qr/borrowernumber:$borrowernumber/,
        qr/branchcode:$branchcode/,
        qr/categorycode:$categorycode/,
        qr/due_date_type:DateTime/,
        qr/end_date_type:DateTime/
    ],
        'Parameters are correct';

    Koha::Plugins->RemovePlugins();

    $schema->storage->txn_rollback;
};
