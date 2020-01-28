#!/usr/bin/perl

# Copyright 2016 Koha-Suomi Oy
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
use Test::Deep qw( cmp_methods );
use Test::Exception;

use Benchmark;

use Koha::CirculationRules;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder      = t::lib::TestBuilder->new;

subtest 'get_effective_issuing_rule' => sub {
    plan tests => 3;

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

    subtest 'Get effective issuing rule in correct order' => sub {
        plan tests => 26;

        my $rule;
        Koha::CirculationRules->delete;
        is(Koha::CirculationRules->search->count, 0, 'There are no issuing rules.');
        $rule = Koha::CirculationRules->get_effective_rule({
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
            rule_name    => 'fine',
        });
        is($rule, undef, 'When I attempt to get effective issuing rule, then undef'
                        .' is returned.');

        # undef, undef, undef => 5
        ok(Koha::CirculationRule->new({
            branchcode => undef,
            categorycode => undef,
            itemtype => undef,
            rule_name => 'fine',
            rule_value   => 5,
        })->store, 'Given I added an issuing rule branchcode => undef, categorycode => undef, itemtype => undef,');
        $rule = Koha::CirculationRules->get_effective_rule({
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
            rule_name    => 'fine',
        });
        _is_row_match(
            $rule,
            {
                branchcode   => undef,
                categorycode => undef,
                itemtype     => undef,
                rule_name    => 'fine',
                rule_value   => 5,
            },
            'When I attempt to get effective issuing rule,'
           .' then the above one is returned.'
        );

        # undef, undef, undef     => 5
        # undef, undef, $itemtype => 7
        ok(
            Koha::CirculationRule->new(
                {
                    branchcode   => undef,
                    categorycode => undef,
                    itemtype     => $itemtype,
                    rule_name    => 'fine',
                    rule_value   => 7,
                }
              )->store,
            "Given I added an issuing rule branchcode => undef, categorycode => undef, itemtype => $itemtype,"
        );
        $rule = Koha::CirculationRules->get_effective_rule({
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
            rule_name    => 'fine',
        });
        _is_row_match(
            $rule,
            {
                branchcode   => undef,
                categorycode => undef,
                itemtype     => $itemtype,
                rule_name    => 'fine',
                rule_value   => 7,
            },
            'When I attempt to get effective issuing rule,'
           .' then the above one is returned.'
        );

        # undef, undef,         undef     => 5
        # undef, undef,         $itemtype => 7
        # undef, $categorycode, undef     => 9
        ok(
            Koha::CirculationRule->new(
                {
                    branchcode   => undef,
                    categorycode => $categorycode,
                    itemtype     => undef,
                    rule_name    => 'fine',
                    rule_value   => 9,
                }
              )->store,
            "Given I added an issuing rule branchcode => undef, categorycode => $categorycode, itemtype => undef,"
        );
        $rule = Koha::CirculationRules->get_effective_rule({
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
            rule_name    => 'fine',
        });
        _is_row_match(
            $rule,
            {
                branchcode   => undef,
                categorycode => $categorycode,
                itemtype     => undef,
                rule_name    => 'fine',
                rule_value   => 9,
            },
            'When I attempt to get effective issuing rule,'
           .' then the above one is returned.'
        );

        # undef, undef,         undef     => 5
        # undef, undef,         $itemtype => 7
        # undef, $categorycode, undef     => 9
        # undef, $categorycode, $itemtype => 11
        ok(
            Koha::CirculationRule->new(
                {
                    branchcode   => undef,
                    categorycode => $categorycode,
                    itemtype     => $itemtype,
                    rule_name    => 'fine',
                    rule_value   => 11,
                }
              )->store,
            "Given I added an issuing rule branchcode => undef, categorycode => $categorycode, itemtype => $itemtype,"
        );
        $rule = Koha::CirculationRules->get_effective_rule({
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
            rule_name    => 'fine',
        });
        _is_row_match(
            $rule,
            {
                branchcode   => undef,
                categorycode => $categorycode,
                itemtype     => $itemtype,
                rule_name    => 'fine',
                rule_value   => 11,
            },
            'When I attempt to get effective issuing rule,'
           .' then the above one is returned.'
        );

        # undef,       undef,         undef     => 5
        # undef,       undef,         $itemtype => 7
        # undef,       $categorycode, undef     => 9
        # undef,       $categorycode, $itemtype => 11
        # $branchcode, undef,         undef     => 13
        ok(
            Koha::CirculationRule->new(
                {
                    branchcode   => $branchcode,
                    categorycode => undef,
                    itemtype     => undef,
                    rule_name    => 'fine',
                    rule_value   => 13,
                }
              )->store,
            "Given I added an issuing rule branchcode => $branchcode, categorycode => undef, itemtype => undef,"
        );
        $rule = Koha::CirculationRules->get_effective_rule({
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
            rule_name    => 'fine',
        });
        _is_row_match(
            $rule,
            {
                branchcode   => $branchcode,
                categorycode => undef,
                itemtype     => undef,
                rule_name    => 'fine',
                rule_value   => 13,
            },
            'When I attempt to get effective issuing rule,'
           .' then the above one is returned.'
        );

        # undef,       undef,         undef     => 5
        # undef,       undef,         $itemtype => 7
        # undef,       $categorycode, undef     => 9
        # undef,       $categorycode, $itemtype => 11
        # $branchcode, undef,         undef     => 13
        # $branchcode, undef,         $itemtype => 15
        ok(
            Koha::CirculationRule->new(
                {
                    branchcode   => $branchcode,
                    categorycode => undef,
                    itemtype     => $itemtype,
                    rule_name    => 'fine',
                    rule_value   => 15,
                }
              )->store,
            "Given I added an issuing rule branchcode => $branchcode, categorycode => undef, itemtype => $itemtype,"
        );
        $rule = Koha::CirculationRules->get_effective_rule({
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
            rule_name    => 'fine',
        });
        _is_row_match(
            $rule,
            {
                branchcode   => $branchcode,
                categorycode => undef,
                itemtype     => $itemtype,
                rule_name    => 'fine',
                rule_value   => 15,
            },
            'When I attempt to get effective issuing rule,'
           .' then the above one is returned.'
        );

        # undef,       undef,         undef     => 5
        # undef,       undef,         $itemtype => 7
        # undef,       $categorycode, undef     => 9
        # undef,       $categorycode, $itemtype => 11
        # $branchcode, undef,         undef     => 13
        # $branchcode, undef,         $itemtype => 15
        # $branchcode, $categorycode, undef     => 17
        ok(
            Koha::CirculationRule->new(
                {
                    branchcode   => $branchcode,
                    categorycode => $categorycode,
                    itemtype     => undef,
                    rule_name    => 'fine',
                    rule_value   => 17,
                }
              )->store,
            "Given I added an issuing rule branchcode => $branchcode, categorycode => $categorycode, itemtype => undef,"
        );
        $rule = Koha::CirculationRules->get_effective_rule({
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
            rule_name    => 'fine',
        });
        _is_row_match(
            $rule,
            {
                branchcode   => $branchcode,
                categorycode => $categorycode,
                itemtype     => undef,
                rule_name    => 'fine',
                rule_value   => 17,
            },
            'When I attempt to get effective issuing rule,'
           .' then the above one is returned.'
        );

        # undef,       undef,         undef     => 5
        # undef,       undef,         $itemtype => 7
        # undef,       $categorycode, undef     => 9
        # undef,       $categorycode, $itemtype => 11
        # $branchcode, undef,         undef     => 13
        # $branchcode, undef,         $itemtype => 15
        # $branchcode, $categorycode, undef     => 17
        # $branchcode, $categorycode, $itemtype => 19
        ok(
            Koha::CirculationRule->new(
                {
                    branchcode   => $branchcode,
                    categorycode => $categorycode,
                    itemtype     => $itemtype,
                    rule_name    => 'fine',
                    rule_value   => 19,
                }
              )->store,
            "Given I added an issuing rule branchcode => $branchcode, categorycode => $categorycode, itemtype => $itemtype,"
        );
        $rule = Koha::CirculationRules->get_effective_rule({
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
            rule_name    => 'fine',
        });
        _is_row_match(
            $rule,
            {
                branchcode   => $branchcode,
                categorycode => $categorycode,
                itemtype     => $itemtype,
                rule_name    => 'fine',
                rule_value   => 19,
            },
            'When I attempt to get effective issuing rule,'
           .' then the above one is returned.'
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
};

subtest 'set_rule' => sub {
    plan tests => 3;

    my $branchcode   = $builder->build({ source => 'Branch' })->{'branchcode'};
    my $categorycode = $builder->build({ source => 'Category' })->{'categorycode'};
    my $itemtype     = $builder->build({ source => 'Itemtype' })->{'itemtype'};

    subtest 'Correct call' => sub {
        plan tests => 4;

        Koha::CirculationRules->delete;

        lives_ok( sub {
            Koha::CirculationRules->set_rule( {
                branchcode => $branchcode,
                rule_name => 'refund',
                rule_value => '',
            } );
        }, 'setting refund with branch' );

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
                rule_name => 'fine',
                rule_value => '',
            } );
        }, 'setting fine with branch/category/itemtype succeeds' );
    };

    subtest 'Call with missing params' => sub {
        plan tests => 4;

        Koha::CirculationRules->delete;

        throws_ok( sub {
            Koha::CirculationRules->set_rule( {
                rule_name => 'refund',
                rule_value => '',
            } );
        }, qr/branchcode/, 'setting refund without branch fails' );

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
        plan tests => 3;

        Koha::CirculationRules->delete;

        throws_ok( sub {
            Koha::CirculationRules->set_rule( {
                branchcode => $branchcode,
                categorycode => $categorycode,
                rule_name => 'refund',
                rule_value => '',
            } );
        }, qr/categorycode/, 'setting refund with categorycode fails' );

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
};

subtest 'clone' => sub {
    plan tests => 2;

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
};

sub _is_row_match {
    my ( $rule, $expected, $message ) = @_;

    ok( $rule, $message ) ?
        cmp_methods( $rule, [ %$expected ], $message ) :
        fail( $message );
}

$schema->storage->txn_rollback;

