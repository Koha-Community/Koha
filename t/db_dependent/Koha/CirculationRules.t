#!/usr/bin/perl

# Copyright 2018 Koha Development team
#
# This file is part of Koha
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

use Test::More tests => 1;
use Test::Exception;

use Koha::CirculationRules;
use Koha::Database;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

subtest 'set_rule + get_effective_rule' => sub {
    plan tests => 11;

    my $categorycode = $builder->build_object( { class => 'Koha::Patron::Categories' } )->categorycode;
    my $itemtype     = $builder->build_object( { class => 'Koha::ItemTypes' } )->itemtype;
    my $branchcode   = $builder->build_object( { class => 'Koha::Libraries' } )->branchcode;
    my $rule_name    = 'my_rule';
    my $default_rule_value = 1;

    my $rule;
    Koha::CirculationRules->delete;

    throws_ok { Koha::CirculationRules->get_effective_rule }
    'Koha::Exceptions::MissingParameter',
    "Exception should be raised if get_effective_rule is called without rule_name parameter";

    $rule = Koha::CirculationRules->get_effective_rule(
        {
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
            rule_name    => $rule_name,
        }
    );
    is( $rule, undef, 'Undef should be returned if no rule exist' );

    Koha::CirculationRules->set_rule(
        {
            branchcode   => '*',
            categorycode => '*',
            itemtype     => '*',
            rule_name    => $rule_name,
            rule_value   => $default_rule_value,
        }
    );

    $rule = Koha::CirculationRules->get_effective_rule(
        {
            branchcode   => undef,
            categorycode => undef,
            itemtype     => undef,
            rule_name    => $rule_name,
        }
    );
    is( $rule->rule_value, $default_rule_value, 'undef means default' );
    $rule = Koha::CirculationRules->get_effective_rule(
        {
            branchcode   => '*',
            categorycode => '*',
            itemtype     => '*',
            rule_name    => $rule_name,
        }
    );

    is( $rule->rule_value, $default_rule_value, '* means default' );

    Koha::CirculationRules->set_rule(
        {
            branchcode   => '*',
            categorycode => '*',
            itemtype     => $itemtype,
            rule_name    => $rule_name,
            rule_value   => 2,
        }
    );

    $rule = Koha::CirculationRules->get_effective_rule(
        {
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
            rule_name    => $rule_name,
        }
    );
    is( $rule->rule_value, 2,
        'More specific rule is returned when itemtype is given' );

    Koha::CirculationRules->set_rule(
        {
            branchcode   => '*',
            categorycode => $categorycode,
            itemtype     => '*',
            rule_name    => $rule_name,
            rule_value   => 3,
        }
    );

    $rule = Koha::CirculationRules->get_effective_rule(
        {

            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
            rule_name    => $rule_name,
        }
    );
    is( $rule->rule_value, 3,
        'More specific rule is returned when categorycode exists' );

    Koha::CirculationRules->set_rule(
        {
            branchcode   => '*',
            categorycode => $categorycode,
            itemtype     => $itemtype,
            rule_name    => $rule_name,
            rule_value   => 4,
        }
    );
    $rule = Koha::CirculationRules->get_effective_rule(
        {
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
            rule_name    => $rule_name,
        }
    );
    is( $rule->rule_value, 4,
        'More specific rule is returned when categorycode and itemtype exist' );

    Koha::CirculationRules->set_rule(
        {
            branchcode   => $branchcode,
            categorycode => '*',
            itemtype     => '*',
            rule_name    => $rule_name,
            rule_value   => 5,
        }
    );
    $rule = Koha::CirculationRules->get_effective_rule(
        {
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
            rule_name    => $rule_name,
        }
    );
    is( $rule->rule_value, 5,
        'More specific rule is returned when branchcode exists' );

    Koha::CirculationRules->set_rule(
        {
            branchcode   => $branchcode,
            categorycode => '*',
            itemtype     => $itemtype,
            rule_name    => $rule_name,
            rule_value   => 6,
        }
    );
    $rule = Koha::CirculationRules->get_effective_rule(
        {
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
            rule_name    => $rule_name,
        }
    );
    is( $rule->rule_value, 6,
        'More specific rule is returned when branchcode and itemtype exists' );

    Koha::CirculationRules->set_rule(
        {
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => '*',
            rule_name    => $rule_name,
            rule_value   => 7,
        }
    );
    $rule = Koha::CirculationRules->get_effective_rule(
        {
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
            rule_name    => $rule_name,
        }
    );
    is( $rule->rule_value, 7,
        'More specific rule is returned when branchcode and categorycode exist'
    );

    Koha::CirculationRules->set_rule(
        {
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
            rule_name    => $rule_name,
            rule_value   => 8,
        }
    );
    $rule = Koha::CirculationRules->get_effective_rule(
        {
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
            rule_name    => $rule_name,
        }
    );
    is( $rule->rule_value, 8,
        'More specific rule is returned when branchcode, categorycode and itemtype exist'
    );
};

$schema->storage->txn_rollback;
