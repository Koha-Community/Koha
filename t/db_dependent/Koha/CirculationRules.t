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

use Benchmark;
use Test::More tests => 7;
use Test::Deep qw( cmp_methods );
use Test::Exception;

use Koha::CirculationRules;
use Koha::Database;

use t::lib::Mocks;
use t::lib::TestBuilder;
use Koha::Cache::Memory::Lite;

my $schema = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'get_effective_issuing_rule' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $categorycode = $builder->build({ source => 'Category' })->{'categorycode'};
    my $itemtype     = $builder->build({ source => 'Itemtype' })->{'itemtype'};
    my $branchcode   = $builder->build({ source => 'Branch' })->{'branchcode'};

    subtest 'Call with undefined values' => sub {
        plan tests => 5;

        my $rule;
        Koha::CirculationRules->delete;

        is(Koha::CirculationRules->search->count, 0, 'There are no issuing rules.');
        # undef, undef, undef => 1
        $rule = Koha::CirculationRules->get_effective_rule({
            branchcode   => undef,
            categorycode => undef,
            itemtype     => undef,
            rule_name    => 'fine',
            rule_value   => 1,
        });
        is($rule, undef, 'When I attempt to get effective issuing rule by'
           .' providing undefined values, then undef is returned.');

       # undef, undef, undef => 2
        ok(
            Koha::CirculationRule->new(
                {
                    branchcode   => undef,
                    categorycode => undef,
                    itemtype     => undef,
                    rule_name    => 'fine',
                    rule_value   => 2,
                }
              )->store,
            'Given I added an issuing rule branchcode => undef,'
           .' categorycode => undef, itemtype => undef,');
        $rule = Koha::CirculationRules->get_effective_rule({
            branchcode   => undef,
            categorycode => undef,
            itemtype     => undef,
            rule_name    => 'fine',
        });
        _is_row_match(
            $rule,
            {
                branchcode   => undef,
                categorycode => undef,
                itemtype     => undef,
                rule_name    => 'fine',
                rule_value   => 2,
            },
            'When I attempt to get effective'
           .' issuing rule by providing undefined values, then the above one is'
           .' returned.'
        );
    };

    subtest 'Performance' => sub {
        plan tests => 4;

        my $worst_case = timethis(500,
                    sub { Koha::CirculationRules->get_effective_rule({
                            branchcode   => 'nonexistent',
                            categorycode => 'nonexistent',
                            itemtype     => 'nonexistent',
                            rule_name    => 'nonexistent',
                        });
                    }
                );
        my $mid_case = timethis(500,
                    sub { Koha::CirculationRules->get_effective_rule({
                            branchcode   => $branchcode,
                            categorycode => 'nonexistent',
                            itemtype     => 'nonexistent',
                            rule_name    => 'nonexistent',
                        });
                    }
                );
        my $sec_best_case = timethis(500,
                    sub { Koha::CirculationRules->get_effective_rule({
                            branchcode   => $branchcode,
                            categorycode => $categorycode,
                            itemtype     => 'nonexistent',
                            rule_name    => 'nonexistent',
                        });
                    }
                );
        my $best_case = timethis(500,
                    sub { Koha::CirculationRules->get_effective_rule({
                            branchcode   => $branchcode,
                            categorycode => $categorycode,
                            itemtype     => $itemtype,
                            rule_name    => 'nonexistent',
                        });
                    }
                );
        ok($worst_case, 'In worst case, get_effective_issuing_rule finds matching'
           .' rule '.sprintf('%.2f', $worst_case->iters/$worst_case->cpu_a)
           .' times per second.');
        ok($mid_case, 'In mid case, get_effective_issuing_rule finds matching'
           .' rule '.sprintf('%.2f', $mid_case->iters/$mid_case->cpu_a)
           .' times per second.');
        ok($sec_best_case, 'In second best case, get_effective_issuing_rule finds matching'
           .' rule '.sprintf('%.2f', $sec_best_case->iters/$sec_best_case->cpu_a)
           .' times per second.');
        ok($best_case, 'In best case, get_effective_issuing_rule finds matching'
           .' rule '.sprintf('%.2f', $best_case->iters/$best_case->cpu_a)
           .' times per second.');
    };

    $schema->storage->txn_rollback;

};

subtest 'set_rule' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    my $branchcode   = $builder->build({ source => 'Branch' })->{'branchcode'};
    my $categorycode = $builder->build({ source => 'Category' })->{'categorycode'};
    my $itemtype     = $builder->build({ source => 'Itemtype' })->{'itemtype'};

    subtest 'Correct call' => sub {
        plan tests => 5;

        Koha::CirculationRules->delete;

        lives_ok( sub {
            Koha::CirculationRules->set_rule( {
                branchcode => $branchcode,
                rule_name => 'lostreturn',
                rule_value => '',
            } );
        }, 'setting lostreturn with branch' );

        lives_ok( sub {
            Koha::CirculationRules->set_rule( {
                branchcode => $branchcode,
                rule_name => 'processingreturn',
                rule_value => '',
            } );
        }, 'setting processingreturn with branch' );

        lives_ok( sub {
            Koha::CirculationRules->set_rule( {
                branchcode => $branchcode,
                categorycode => $categorycode,
                rule_name => 'patron_maxissueqty',
                rule_value => '',
            } );
        }, 'setting patron_maxissueqty with branch/category succeeds' );

        lives_ok( sub {
            Koha::CirculationRules->set_rule( {
                branchcode => $branchcode,
                itemtype => $itemtype,
                rule_name => 'holdallowed',
                rule_value => '',
            } );
        }, 'setting holdallowed with branch/itemtype succeeds' );

        lives_ok( sub {
            Koha::CirculationRules->set_rule( {
                branchcode => $branchcode,
                categorycode => $categorycode,
                itemtype => $itemtype,
                rule_name => 'article_requests',
                rule_value => '',
            } );
        }, 'setting fine with branch/category/itemtype succeeds' );
    };

    subtest 'Call with missing params' => sub {
        plan tests => 5;

        Koha::CirculationRules->delete;

        throws_ok( sub {
            Koha::CirculationRules->set_rule( {
                rule_name => 'lostreturn',
                rule_value => '',
            } );
        }, qr/branchcode/, 'setting lostreturn without branch fails' );

        throws_ok( sub {
            Koha::CirculationRules->set_rule( {
                rule_name => 'processingreturn',
                rule_value => '',
            } );
        }, qr/branchcode/, 'setting processingreturn without branch fails' );

        throws_ok( sub {
            Koha::CirculationRules->set_rule( {
                branchcode => $branchcode,
                rule_name => 'patron_maxissueqty',
                rule_value => '',
            } );
        }, qr/categorycode/, 'setting patron_maxissueqty without categorycode fails' );

        throws_ok( sub {
            Koha::CirculationRules->set_rule( {
                branchcode => $branchcode,
                rule_name => 'holdallowed',
                rule_value => '',
            } );
        }, qr/itemtype/, 'setting holdallowed without itemtype fails' );

        throws_ok( sub {
            Koha::CirculationRules->set_rule( {
                branchcode => $branchcode,
                categorycode => $categorycode,
                rule_name => 'fine',
                rule_value => '',
            } );
        }, qr/itemtype/, 'setting fine without itemtype fails' );
    };

    subtest 'Call with extra params' => sub {
        plan tests => 4;

        Koha::CirculationRules->delete;

        throws_ok( sub {
            Koha::CirculationRules->set_rule( {
                branchcode => $branchcode,
                categorycode => $categorycode,
                rule_name => 'lostreturn',
                rule_value => '',
            } );
        }, qr/categorycode/, 'setting lostreturn with categorycode fails' );

        throws_ok( sub {
            Koha::CirculationRules->set_rule( {
                branchcode => $branchcode,
                categorycode => $categorycode,
                rule_name => 'processingreturn',
                rule_value => '',
            } );
        }, qr/categorycode/, 'setting processingreturn with categorycode fails' );

        throws_ok( sub {
            Koha::CirculationRules->set_rule( {
                branchcode => $branchcode,
                categorycode => $categorycode,
                itemtype => $itemtype,
                rule_name => 'patron_maxissueqty',
                rule_value => '',
            } );
        }, qr/itemtype/, 'setting patron_maxissueqty with itemtype fails' );

        throws_ok( sub {
            Koha::CirculationRules->set_rule( {
                branchcode => $branchcode,
                rule_name => 'holdallowed',
                categorycode => $categorycode,
                itemtype => $itemtype,
                rule_value => '',
            } );
        }, qr/categorycode/, 'setting holdallowed with categorycode fails' );
    };

    subtest 'Call with badly formatted params' => sub {
        plan tests => 4;

        Koha::CirculationRules->delete;

        foreach my $monetary_rule ( ( 'article_request_fee', 'fine', 'overduefinescap', 'recall_overdue_fine' ) ) {
            throws_ok(
                sub {
                    Koha::CirculationRules->set_rule(
                        {
                            categorycode => '*',
                            branchcode   => '*',
                            ( $monetary_rule ne 'article_request_fee' ? ( itemtype => '*' ) : () ),
                            rule_name  => $monetary_rule,
                            rule_value => '10,00',
                        }
                    );
                },
                qr/decimal/,
                "setting $monetary_rule fails when passed value is not decimal"
            );
        }
    };

    $schema->storage->txn_rollback;
};

subtest 'clone' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $branchcode   = $builder->build({ source => 'Branch' })->{'branchcode'};
    my $categorycode = $builder->build({ source => 'Category' })->{'categorycode'};
    my $itemtype     = $builder->build({ source => 'Itemtype' })->{'itemtype'};

    subtest 'Clone multiple rules' => sub {
        plan tests => 4;

        Koha::CirculationRules->delete;

        Koha::CirculationRule->new({
            branchcode   => undef,
            categorycode => $categorycode,
            itemtype     => $itemtype,
            rule_name    => 'fine',
            rule_value   => 5,
        })->store;

        Koha::CirculationRule->new({
            branchcode   => undef,
            categorycode => $categorycode,
            itemtype     => $itemtype,
            rule_name    => 'lengthunit',
            rule_value   => 'days',
        })->store;

        Koha::CirculationRules->search({ branchcode => undef })->clone($branchcode);

        my $rule_fine = Koha::CirculationRules->get_effective_rule({
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
            rule_name    => 'fine',
        });
        my $rule_lengthunit = Koha::CirculationRules->get_effective_rule({
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
            rule_name    => 'lengthunit',
        });

        _is_row_match(
            $rule_fine,
            {
                branchcode   => $branchcode,
                categorycode => $categorycode,
                itemtype     => $itemtype,
                rule_name    => 'fine',
                rule_value   => 5,
            },
            'When I attempt to get cloned fine rule,'
           .' then the above one is returned.'
        );
        _is_row_match(
            $rule_lengthunit,
            {
                branchcode   => $branchcode,
                categorycode => $categorycode,
                itemtype     => $itemtype,
                rule_name    => 'lengthunit',
                rule_value   => 'days',
            },
            'When I attempt to get cloned lengthunit rule,'
           .' then the above one is returned.'
        );

    };

    subtest 'Clone one rule' => sub {
        plan tests => 2;

        Koha::CirculationRules->delete;

        Koha::CirculationRule->new({
            branchcode   => undef,
            categorycode => $categorycode,
            itemtype     => $itemtype,
            rule_name    => 'fine',
            rule_value   => 5,
        })->store;

        my $rule = Koha::CirculationRules->search({ branchcode => undef })->next;
        $rule->clone($branchcode);

        my $cloned_rule = Koha::CirculationRules->get_effective_rule({
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
            rule_name    => 'fine',
        });

        _is_row_match(
            $cloned_rule,
            {
                branchcode   => $branchcode,
                categorycode => $categorycode,
                itemtype     => $itemtype,
                rule_name    => 'fine',
                rule_value   => '5',
            },
            'When I attempt to get cloned fine rule,'
           .' then the above one is returned.'
        );

    };

    $schema->storage->txn_rollback;
};

subtest 'set_rule + get_effective_rule' => sub {
    plan tests => 9;

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

    subtest 'test rules that cannot be blank' => sub {
        plan tests => 3;
        foreach my $no_blank_rule ( ('holdallowed','hold_fulfillment_policy','returnbranch') ){
            Koha::CirculationRules->set_rule(
                {
                    branchcode   => $branchcode,
                    itemtype     => '*',
                    rule_name    => $no_blank_rule,
                    rule_value   => '',
                }
            );

            $rule = Koha::CirculationRules->get_effective_rule(
                {
                    branchcode   => $branchcode,
                    categorycode => undef,
                    itemtype     => undef,
                    rule_name    => $no_blank_rule,
                }
            );
            is( $rule, undef, 'Rules that cannot be blank are not set when passed blank string' );
        }
    };


    subtest 'test rule matching with different combinations of rule scopes' => sub {
        my ( $tests, $order ) = _prepare_tests_for_rule_scope_combinations(
            {
                branchcode   => $branchcode,
                categorycode => $categorycode,
                itemtype     => $itemtype,
            },
            'maxissueqty'
        );

        plan tests => 2**scalar @$order;

        foreach my $test (@$tests) {
            my $rule_params = {%$test};
            $rule_params->{rule_name} = $rule_name;
            my $rule_value = $rule_params->{rule_value} = int( rand(10) );

            Koha::CirculationRules->set_rule($rule_params);

            my $rule = Koha::CirculationRules->get_effective_rule(
                {
                    branchcode   => $branchcode,
                    categorycode => $categorycode,
                    itemtype     => $itemtype,
                    rule_name    => $rule_name,
                }
            );

            my $scope_output = '';
            foreach my $key ( values @$order ) {
                $scope_output .= " $key" if $test->{$key} ne '*';
            }

            is( $rule->rule_value, $rule_value,
                'Explicitly scoped'
                  . ( $scope_output ? $scope_output : ' nothing' ) );
        }
    };

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

    my $default_proc_rule_charge = $builder->build(
        {
            source => 'CirculationRule',
            value  => {
                branchcode   => undef,
                categorycode => undef,
                itemtype     => undef,
                rule_name    => 'processingreturn',
                rule_value   => 'charge'
            }
        }
    );
    my $default_lost_rule_charge = $builder->build(
        {
            source => 'CirculationRule',
            value  => {
                branchcode   => undef,
                categorycode => undef,
                itemtype     => undef,
                rule_name    => 'lostreturn',
                rule_value   => 'charge'
            }
        }
    );
    my $branchcode = $builder->build( { source => 'Branch' } )->{branchcode};
    my $specific_lost_rule_false = $builder->build(
        {
            source => 'CirculationRule',
            value  => {
                branchcode   => $branchcode,
                categorycode => undef,
                itemtype     => undef,
                rule_name    => 'lostreturn',
                rule_value   => 0
            }
        }
    );
    my $specific_proc_rule_false = $builder->build(
        {
            source => 'CirculationRule',
            value  => {
                branchcode   => $branchcode,
                categorycode => undef,
                itemtype     => undef,
                rule_name    => 'processingreturn',
                rule_value   => 0
            }
        }
    );
    my $branchcode2 = $builder->build( { source => 'Branch' } )->{branchcode};
    my $specific_lost_rule_refund = $builder->build(
        {
            source => 'CirculationRule',
            value  => {
                branchcode   => $branchcode2,
                categorycode => undef,
                itemtype     => undef,
                rule_name    => 'lostreturn',
                rule_value   => 'refund'
            }
        }
    );
    my $specific_proc_rule_refund = $builder->build(
        {
            source => 'CirculationRule',
            value  => {
                branchcode   => $branchcode2,
                categorycode => undef,
                itemtype     => undef,
                rule_name    => 'processingreturn',
                rule_value   => 'refund'
            }
        }
    );
    my $branchcode3 = $builder->build( { source => 'Branch' } )->{branchcode};
    my $specific_lost_rule_restore = $builder->build(
        {
            source => 'CirculationRule',
            value  => {
                branchcode   => $branchcode3,
                categorycode => undef,
                itemtype     => undef,
                rule_name    => 'lostreturn',
                rule_value   => 'restore'
            }
        }
    );
    my $specific_proc_rule_restore = $builder->build(
        {
            source => 'CirculationRule',
            value  => {
                branchcode   => $branchcode3,
                categorycode => undef,
                itemtype     => undef,
                rule_name    => 'processingreturn',
                rule_value   => 'restore'
            }
        }
    );

    # Make sure we have an unused branchcode
    my $branch_without_rule = $builder->build( { source => 'Branch' } )->{branchcode};

    my $item = $builder->build_sample_item(
        {
            homebranch    => $specific_lost_rule_restore->{branchcode},
            holdingbranch => $specific_lost_rule_false->{branchcode}
        }
    );
    my $params = {
        return_branch => $specific_lost_rule_refund->{ branchcode },
        item          => $item
    };

    # Specific rules
    t::lib::Mocks::mock_preference( 'RefundLostOnReturnControl', 'CheckinLibrary' );
    is_deeply( Koha::CirculationRules->get_lostreturn_policy( $params ),
        { lostreturn => 'refund', processingreturn => 'refund' },'Specific rule for checkin branch is applied (refund)');

    t::lib::Mocks::mock_preference( 'RefundLostOnReturnControl', 'ItemHomeBranch' );
    is_deeply( Koha::CirculationRules->get_lostreturn_policy( $params ),
         { lostreturn => 'restore', processingreturn => 'restore' },'Specific rule for home branch is applied (restore)');

    t::lib::Mocks::mock_preference( 'RefundLostOnReturnControl', 'ItemHoldingBranch' );
    is_deeply( Koha::CirculationRules->get_lostreturn_policy( $params ),
         { lostreturn => 0, processingreturn => 0 },'Specific rule for holding branch is applied (false)');

    # Default rule check
    t::lib::Mocks::mock_preference( 'RefundLostOnReturnControl', 'CheckinLibrary' );
    $params->{return_branch} = $branch_without_rule;
    is_deeply( Koha::CirculationRules->get_lostreturn_policy( $params ),
         { lostreturn => 'charge', processingreturn => 'charge' },'No rule for branch, global rule applied (charge)');

    # Change the default value just to try
    Koha::CirculationRules->search({ branchcode => undef, rule_name => 'lostreturn' })->next->rule_value(0)->store;
    Koha::CirculationRules->search({ branchcode => undef, rule_name => 'processingreturn' })->next->rule_value(0)->store;
    my $memory_cache = Koha::Cache::Memory::Lite->get_instance;
    $memory_cache->flush();
    is_deeply( Koha::CirculationRules->get_lostreturn_policy( $params ),
         { lostreturn => 0, processingreturn => 0 },'No rule for branch, global rule applied (false)');

    # No default rule defined check
    Koha::CirculationRules
        ->search(
            {
                branchcode   => undef,
                categorycode => undef,
                itemtype     => undef,
                rule_name    => 'lostreturn'
            }
          )
        ->next
        ->delete;
    # No default rule defined check
    Koha::CirculationRules
        ->search(
            {
                branchcode   => undef,
                categorycode => undef,
                itemtype     => undef,
                rule_name    => 'processingreturn'
            }
          )
        ->next
        ->delete;
    is_deeply( Koha::CirculationRules->get_lostreturn_policy( $params ),
         { lostreturn => 'refund', processingreturn => 'refund' },'No rule for branch, no default rule, fallback default (refund)');

    # Fallback to ItemHoldBranch if CheckinLibrary is undefined
    $params->{return_branch} = undef;
    is_deeply( Koha::CirculationRules->get_lostreturn_policy( $params ),
         { lostreturn => 'restore', processingreturn => 'restore' },'return_branch undefined, fallback to ItemHomeBranch rule (restore)');

    $schema->storage->txn_rollback;
};

sub _is_row_match {
    my ( $rule, $expected, $message ) = @_;

    ok( $rule, $message ) ?
        cmp_methods( $rule, [ %$expected ], $message ) :
        fail( $message );
}

sub _prepare_tests_for_rule_scope_combinations {
    my ( $scope, $rule_name ) = @_;

    # Here we create a combinations of 1s and 0s the following way
    #
    # 000...
    # 001...
    # 010...
    # 011...
    # 100...
    # 101...
    # 110...
    # 111...
    #
    # (the number of columns equals to the amount of rule scopes)
    # The ... symbolizes possible future scopes.
    #
    # - 0 equals to circulation rule scope with any value (aka. *)
    # - 1 equals to circulation rule scope exact value, e.g.
    #     "CPL" (for branchcode).
    #
    # The order is the same as the weight of scopes when sorting circulation
    # rules. So the first column of numbers is the scope with most weight.
    # This is defined by C<$order> which will be assigned next.
    #
    # We must maintain the order in order to keep the test valid. This should be
    # equal to Koha/CirculationRules.pm "order_by" of C<get_effective_rule> sub.
    # Let's explicitly define the order and fail test if we are missing a scope:
    my $order = [ 'branchcode', 'categorycode', 'itemtype' ];
    is( join(", ", sort keys %$scope),
       join(", ", sort @$order), 'Missing a scope!' ) if keys %$scope ne scalar @$order;

    my @tests = ();
    foreach my $value ( glob( "{0,1}" x keys %$scope || 1 ) ) {
        my $test = { %$scope };
        for ( my $i=0; $i < keys %$scope; $i++ ) {
            $test->{$order->[$i]} = '*' unless substr( $value, $i, 1 );
        }
        push @tests, $test;
    }

    return \@tests, $order;
}
