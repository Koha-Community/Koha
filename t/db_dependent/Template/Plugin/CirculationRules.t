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
use Test::More tests => 3;
use Test::MockModule;

use Koha::CirculationRules;

use t::lib::TestBuilder;
use t::lib::Mocks;

BEGIN {
    use_ok('Koha::Template::Plugin::CirculationRules');
}

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'Basic function tests' => sub {

    plan tests => 10;

    $schema->storage->txn_begin;

    my $library_1 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_2 = $builder->build_object( { class => 'Koha::Libraries' } );

    my $plugin = Koha::Template::Plugin::CirculationRules->new();
    ok( $plugin, "initialized CirculationRules plugin" );

    my $rule_value = $plugin->Get( $library_1->branchcode, '*', '*', 'maxholds' );
    is( $rule_value, undef, 'Max holds not set, Get returns undef' );

    $rule_value = $plugin->Search( $library_1->branchcode, '*', '*', 'maxholds' );
    is( $rule_value, undef, 'Max holds not set, Search returns undef' );

    my $rule = $plugin->Search( $library_1->branchcode, '*', '*', 'maxholds', { want_rule => 1 } );
    is( $rule, undef, 'Max holds not set, Search with want_rule returns undef' );

    Koha::CirculationRules->set_rule(
        {
            branchcode   => '*',
            categorycode => '*',
            rule_name    => 'max_holds',
            rule_value   => 5,
        }
    );

    Koha::CirculationRules->set_rule(
        {
            branchcode   => $library_1->branchcode,
            categorycode => '*',
            rule_name    => 'max_holds',
            rule_value   => "",
        }
    );

    $rule_value = $plugin->Get( $library_1->branchcode, '*', '*', 'max_holds' );
    is( $rule_value, "", 'Max holds set to blank string (unlimited), Get returns blank string for branch' );

    $rule = $plugin->Search( $library_1->branchcode, '*', '*', 'max_holds', { want_rule => 1 } );
    is(
        ref $rule, "Koha::CirculationRule",
        'Max holds set to blank string, Search with want_rule returns a circulation rules object'
    );
    is( $rule->rule_value, "", 'Max holds set to blank string (unlimited), returned rule has correct value' );

    $rule_value = $plugin->Get( $library_2->branchcode, '*', '*', 'max_holds' );
    is( $rule_value, 5, 'Max holds default set to 5, Get returns 5 for branch with no rule set' );

    $rule_value = $plugin->Search( '*', '*', '*', 'max_holds' );
    is( $rule_value, 5, 'Search for all libraries max holds rule, Search returns 5' );

    $rule_value = $plugin->Search( $library_1->branchcode, '*', '*', 'max_holds' );
    is( $rule_value, "", 'Max holds set to blank string (unlimited), Get returns blank string for branch' );

    $schema->storage->txn_rollback;
};
