#!/usr/bin/perl

# Copyright 2020 Koha Development team
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

use Test::More tests => 3;
use Test::Exception;

use Koha::CirculationRules;
use Koha::Database;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'set_rule + get_effective_rule' => sub {
    plan tests => 14;

    $schema->storage->txn_begin;

    my $categorycode = $builder->build_object( { class => 'Koha::Patron::Categories' } )->categorycode;
    my $itemtype     = $builder->build_object( { class => 'Koha::ItemTypes' } )->itemtype;
    my $branchcode   = $builder->build_object( { class => 'Koha::Libraries' } )->branchcode;
    my $branchcode_2 = $builder->build_object( { class => 'Koha::Libraries' } )->branchcode;
    my $rule_name    = 'maxissueqty';
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

    $rule = Koha::CirculationRules->get_effective_rule(
        {
            branchcode   => $branchcode_2,
            categorycode => '*',
            itemtype     => '*',
            rule_name    => $rule_name,
        }
    );
    is( $rule->rule_value, 1,
        'Default rule is returned if there is no rule for this branchcode' );

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

    my $our_branch_rules = Koha::CirculationRules->search({branchcode => $branchcode});
    is( $our_branch_rules->count, 4, "We added 8 rules");
    $our_branch_rules->delete;
    is( $our_branch_rules->count, 0, "We deleted 8 rules");

    $schema->storage->txn_rollback;
};

subtest 'get_onshelfholds_policy() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $item = $builder->build_sample_item();

    my $circ_rules = Koha::CirculationRules->new;
    # Cleanup
    $circ_rules->search({ rule_name => 'onshelfholds' })->delete;

    $circ_rules->set_rule(
        {
            branchcode   => '*',
            categorycode => '*',
            itemtype     => '*',
            rule_name    => 'onshelfholds',
            rule_value   => 1,
        }
    );

    is( $circ_rules->get_onshelfholds_policy({ item => $item }), 1, 'If rule_value is set on a matching rule, return it' );
    # Delete the rule (i.e. get_effective_rule returns undef)
    $circ_rules->delete;
    is( $circ_rules->get_onshelfholds_policy({ item => $item }), 0, 'If no matching rule, fallback to 0' );

    $schema->storage->txn_rollback;
};

subtest 'get_useDaysMode_effective_value' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    my $item_1 = $builder->build_sample_item();
    my $item_2 = $builder->build_sample_item();

    my $circ_rules =
      Koha::CirculationRules->search( { rule_name => 'useDaysMode' } )->delete;

    # Default value 'Datedue' at pref level
    t::lib::Mocks::mock_preference( 'useDaysMode', 'Datedue' );

    is(
        Koha::CirculationRules->get_useDaysMode_effective_value(
            {
                categorycode => undef,
                itemtype     => $item_1->effective_itemtype,
                branchcode   => undef
            }
        ),
        'Datedue',
        'useDaysMode default to pref value if the rule does not exist'
    );

    Koha::CirculationRules->set_rule(
        {
            branchcode   => '*',
            categorycode => '*',
            itemtype     => '*',
            rule_name    => 'useDaysMode',
            rule_value   => 'Calendar',
        }
    );
    Koha::CirculationRules->set_rule(
        {
            branchcode   => '*',
            categorycode => '*',
            itemtype     => $item_1->effective_itemtype,
            rule_name    => 'useDaysMode',
            rule_value   => 'Days',
        }
    );

    is(
        Koha::CirculationRules->get_useDaysMode_effective_value(
            {
                categorycode => undef,
                itemtype     => $item_1->effective_itemtype,
                branchcode   => undef
            }
        ),
        'Days',
        "useDaysMode for item_1 is the specific rule"
    );
    is(
        Koha::CirculationRules->get_useDaysMode_effective_value(
            {
                categorycode => undef,
                itemtype     => $item_2->effective_itemtype,
                branchcode   => undef
            }
        ),
        'Calendar',
        "useDaysMode for item_2 is the one defined for the default circ rule"
    );

    Koha::CirculationRules->set_rule(
        {
            branchcode   => '*',
            categorycode => '*',
            itemtype     => $item_2->effective_itemtype,
            rule_name    => 'useDaysMode',
            rule_value   => '',
        }
    );

    is(
        Koha::CirculationRules->get_useDaysMode_effective_value(
            {
                categorycode => undef,
                itemtype     => $item_2->effective_itemtype,
                branchcode   => undef
            }
        ),
        'Datedue',
        'useDaysMode default to pref value if the rule exists but set to""'
    );

    $schema->storage->txn_rollback;
};
