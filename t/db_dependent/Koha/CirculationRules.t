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

use Test::More tests => 4;
use Test::Exception;

use Koha::CirculationRules;
use Koha::Database;

use t::lib::Mocks;
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

subtest 'get_effective_daysmode' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    my $item_1 = $builder->build_sample_item();
    my $item_2 = $builder->build_sample_item();

    my $circ_rules =
      Koha::CirculationRules->search( { rule_name => 'daysmode' } )->delete;

    # Default value 'Datedue' at pref level
    t::lib::Mocks::mock_preference( 'useDaysMode', 'Datedue' );

    is(
        Koha::CirculationRules->get_effective_daysmode(
            {
                categorycode => undef,
                itemtype     => $item_1->effective_itemtype,
                branchcode   => undef
            }
        ),
        'Datedue',
        'daysmode default to pref value if the rule does not exist'
    );

    Koha::CirculationRules->set_rule(
        {
            branchcode   => '*',
            categorycode => '*',
            itemtype     => '*',
            rule_name    => 'daysmode',
            rule_value   => 'Calendar',
        }
    );
    Koha::CirculationRules->set_rule(
        {
            branchcode   => '*',
            categorycode => '*',
            itemtype     => $item_1->effective_itemtype,
            rule_name    => 'daysmode',
            rule_value   => 'Days',
        }
    );

    is(
        Koha::CirculationRules->get_effective_daysmode(
            {
                categorycode => undef,
                itemtype     => $item_1->effective_itemtype,
                branchcode   => undef
            }
        ),
        'Days',
        "daysmode for item_1 is the specific rule"
    );
    is(
        Koha::CirculationRules->get_effective_daysmode(
            {
                categorycode => undef,
                itemtype     => $item_2->effective_itemtype,
                branchcode   => undef
            }
        ),
        'Calendar',
        "daysmode for item_2 is the one defined for the default circ rule"
    );

    Koha::CirculationRules->set_rule(
        {
            branchcode   => '*',
            categorycode => '*',
            itemtype     => $item_2->effective_itemtype,
            rule_name    => 'daysmode',
            rule_value   => '',
        }
    );

    is(
        Koha::CirculationRules->get_effective_daysmode(
            {
                categorycode => undef,
                itemtype     => $item_2->effective_itemtype,
                branchcode   => undef
            }
        ),
        'Datedue',
        'daysmode default to pref value if the rule exists but set to""'
    );

    $schema->storage->txn_rollback;
};

subtest 'get_lostreturn_policy() tests' => sub {
    plan tests => 7;

    $schema->storage->txn_begin;

    $schema->resultset('CirculationRule')->search()->delete;

    my $default_rule = $builder->build(
        {
            source => 'CirculationRule',
            value  => {
                branchcode   => undef,
                categorycode => undef,
                itemtype     => undef,
                rule_name    => 'refund',
                rule_value   => 1
            }
        }
    );
    my $branchcode = $builder->build( { source => 'Branch' } )->{branchcode};
    my $specific_rule_false = $builder->build(
        {
            source => 'CirculationRule',
            value  => {
                branchcode   => $branchcode,
                categorycode => undef,
                itemtype     => undef,
                rule_name    => 'refund',
                rule_value   => 0
            }
        }
    );
    my $branchcode2 = $builder->build( { source => 'Branch' } )->{branchcode};
    my $specific_rule_true = $builder->build(
        {
            source => 'CirculationRule',
            value  => {
                branchcode   => $branchcode2,
                categorycode => undef,
                itemtype     => undef,
                rule_name    => 'refund',
                rule_value   => 1
            }
        }
    );
    # Make sure we have an unused branchcode
    my $branchcode3 = $builder->build( { source => 'Branch' } )->{branchcode};
    my $specific_rule_dummy = $builder->build(
        {
            source => 'CirculationRule',
            value  => {
                branchcode   => $branchcode3,
                categorycode => undef,
                itemtype     => undef,
                rule_name    => 'refund',
            }
        }
    );
    my $branch_without_rule = $specific_rule_dummy->{ branchcode };
    Koha::CirculationRules
        ->search(
            {
                branchcode   => $branch_without_rule,
                categorycode => undef,
                itemtype     => undef,
                rule_name    => 'refund'
            }
          )
        ->next
        ->delete;

    my $item = $builder->build_sample_item(
        {
            homebranch    => $specific_rule_false->{branchcode},
            holdingbranch => $specific_rule_true->{branchcode}
        }
    );
    my $params = {
        return_branch => $specific_rule_true->{ branchcode },
        item          => $item
    };

    # Specific rules
    t::lib::Mocks::mock_preference( 'RefundLostOnReturnControl', 'CheckinLibrary' );
    is( Koha::CirculationRules->get_lostreturn_policy( $params ),
          1,'Specific rule for checkin branch is applied (true)');

    t::lib::Mocks::mock_preference( 'RefundLostOnReturnControl', 'ItemHomeBranch' );
    is( Koha::CirculationRules->get_lostreturn_policy( $params ),
         0,'Specific rule for home branch is applied (false)');

    t::lib::Mocks::mock_preference( 'RefundLostOnReturnControl', 'ItemHoldingBranch' );
    is( Koha::CirculationRules->get_lostreturn_policy( $params ),
         1,'Specific rule for holding branch is applied (true)');

    # Default rule check
    t::lib::Mocks::mock_preference( 'RefundLostOnReturnControl', 'CheckinLibrary' );
    $params->{return_branch} = $branch_without_rule;
    is( Koha::CirculationRules->get_lostreturn_policy( $params ),
         1,'No rule for branch, global rule applied (true)');

    # Change the default value just to try
    Koha::CirculationRules->search({ branchcode => undef, rule_name => 'refund' })->next->rule_value(0)->store;
    is( Koha::CirculationRules->get_lostreturn_policy( $params ),
         0,'No rule for branch, global rule applied (false)');

    # No default rule defined check
    Koha::CirculationRules
        ->search(
            {
                branchcode   => undef,
                categorycode => undef,
                itemtype     => undef,
                rule_name    => 'refund'
            }
          )
        ->next
        ->delete;
    is( Koha::CirculationRules->get_lostreturn_policy( $params ),
         1,'No rule for branch, no default rule, fallback default (true)');

    # Fallback to ItemHoldBranch if CheckinLibrary is undefined
    $params->{return_branch} = undef;
    is( Koha::CirculationRules->get_lostreturn_policy( $params ),
         0,'return_branch undefined, fallback to ItemHomeBranch rule (false)');

    $schema->storage->txn_rollback;
};
