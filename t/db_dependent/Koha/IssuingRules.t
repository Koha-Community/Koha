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

use Test::More tests => 1;

use Benchmark;

use Koha::IssuingRules;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder      = t::lib::TestBuilder->new;

my ($categorycode, $itemtype, $branchcode, $ccode, $permanent_location,
    $sub_location, $genre, $circulation_level, $reserve_level);

subtest 'get_effective_issuing_rule' => sub {
    plan tests => 3;

    my $patron       = $builder->build({ source => 'Borrower' });
    my $item     = $builder->build({ source => 'Item' });

    $categorycode = $patron->{'categorycode'};
    $itemtype     = $item->{'itype'};
    $branchcode   = $item->{'homebranch'};
    $ccode        = $item->{'ccode'};
    $permanent_location = $item->{'permanent_location'};
    $sub_location = $item->{'sub_location'};
    $genre        = $item->{'genre'};
    $circulation_level = $item->{'circulation_level'};
    $reserve_level = $item->{'reserve_level'};

    subtest 'Call with undefined values' => sub {
        plan tests => 4;

        my $rule;
        Koha::IssuingRules->delete;

        is(Koha::IssuingRules->search->count, 0, 'There are no issuing rules.');
        $rule = Koha::IssuingRules->get_effective_issuing_rule({
            branchcode   => undef,
            categorycode => undef,
            itemtype     => undef,
            ccode        => undef,
            permanent_location => undef,
            sub_location => undef,
            genre        => undef,
            circulation_level => undef,
            reserve_level => undef,
        });
        is($rule, undef, 'When I attempt to get effective issuing rule by'
           .' providing undefined values, then undef is returned.');
        my $new_rule = {
            branchcode => '*',
            categorycode => '*',
            itemtype => '*',
            ccode => '*',
            permanent_location => '*',
            sub_location => '*',
            genre => '*',
            circulation_level => '*',
            reserve_level => '*',
        };
        ok(Koha::IssuingRule->new($new_rule)->store, 'Given I added an issuing '
           .' rule branchcode => *, categorycode => *, itemtype => *,');
        $rule = Koha::IssuingRules->get_effective_issuing_rule({
            branchcode   => undef,
            categorycode => undef,
            itemtype     => undef,
            ccode        => undef,
            permanent_location => undef,
            sub_location => undef,
            genre => undef,
            circulation_level => undef,
            reserve_level => undef,
        });
        ok(_row_match($rule, $new_rule), 'When I attempt to get effective'
           .' issuing rule by providing undefined values, then the above one is'
           .' returned.');
    };

    subtest 'Get effective issuing rule in correct order' => sub {
        plan tests => 1026;

        my $rule;
        Koha::IssuingRules->delete;
        is(Koha::IssuingRules->search->count, 0, 'There are no issuing rules.');
        $rule = Koha::IssuingRules->get_effective_issuing_rule({
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
            ccode        => $ccode,
            permanent_location => $permanent_location,
            sub_location => $sub_location,
            genre        => $genre,
            circulation_level => $circulation_level,
            reserve_level => $reserve_level,
        });
        is($rule, undef, 'When I attempt to get effective issuing rule, then undef'
                        .' is returned.');

        test_effective_issuing_rules({
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
            ccode        => $ccode,
            permanent_location => $permanent_location,
            sub_location => $sub_location,
            genre        => $genre,
            circulation_level => $circulation_level,
            reserve_level => $reserve_level,
        });
    };

    subtest 'Performance' => sub {
        plan tests => 4;

        my $worst_case = timethis(500,
                    sub { Koha::IssuingRules->get_effective_issuing_rule({
                            branchcode   => 'nonexistent',
                            categorycode => 'nonexistent',
                            itemtype     => 'nonexistent',
                        });
                    }
                );
        my $mid_case = timethis(500,
                    sub { Koha::IssuingRules->get_effective_issuing_rule({
                            branchcode   => $branchcode,
                            categorycode => 'nonexistent',
                            itemtype     => 'nonexistent',
                        });
                    }
                );
        my $sec_best_case = timethis(500,
                    sub { Koha::IssuingRules->get_effective_issuing_rule({
                            branchcode   => $branchcode,
                            categorycode => $categorycode,
                            itemtype     => 'nonexistent',
                        });
                    }
                );
        my $best_case = timethis(500,
                    sub { Koha::IssuingRules->get_effective_issuing_rule({
                            branchcode   => $branchcode,
                            categorycode => $categorycode,
                            itemtype     => $itemtype,
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

sub test_effective_issuing_rules {
    my ($params) = @_;

    my $default = '*';

    my $tmp_params = { %$params };
    my @combinations = glob "{0,1}{0,1}{0,1}{0,1}{0,1}{0,1}{0,1}{0,1}{0,1}";
    foreach my $combination (@combinations) {
        my @vals = split //, $combination;
        $tmp_params->{branchcode} = $vals[0] ? $params->{branchcode} : '*';
        $tmp_params->{circulation_level} = $vals[1] ? $params->{circulation_level} : '*';
        $tmp_params->{reserve_level} = $vals[2] ? $params->{reserve_level} : '*';
        $tmp_params->{categorycode} = $vals[3] ? $params->{categorycode} : '*';
        $tmp_params->{itemtype} = $vals[4] ? $params->{itemtype} : '*';
        $tmp_params->{ccode} = $vals[5] ? $params->{ccode} : '*';
        $tmp_params->{permanent_location} = $vals[6] ? $params->{permanent_location} : '*';
        $tmp_params->{sub_location} = $vals[7] ? $params->{sub_location} : '*';
        $tmp_params->{genre} = $vals[8] ? $params->{genre} : '*';

        _test_rule($tmp_params);
    }
}

sub _row_match {
    my ($result_rule, $rule) = @_;

    return 0 unless keys %$result_rule;
    return     $result_rule->branchcode eq $rule->{branchcode}
            && $result_rule->categorycode eq $rule->{categorycode}
            && $result_rule->itemtype eq $rule->{itemtype}
            && $result_rule->ccode eq $rule->{ccode}
            && $result_rule->permanent_location eq $rule->{permanent_location}
            && $result_rule->sub_location eq $rule->{sub_location}
            && $result_rule->genre eq $rule->{genre}
            && $result_rule->circulation_level eq $rule->{circulation_level}
            && $result_rule->reserve_level eq $rule->{reserve_level};
}

sub _test_rule {
    my ($rule) = @_;
    my $result_rule;
    my $rule_str = 'Added an issuing rule';
    foreach my $param (keys %$rule) {
        my $val = $rule->{$param};
        $rule_str .= " $param => " . (
            defined $val
                ? length($val)>5 ? substr($val, 0, 3).'...' : $val
                : 'undef'
            ) . ',';
    }
    ok(Koha::IssuingRule->new($rule)->store, $rule_str);
        $result_rule = Koha::IssuingRules->get_effective_issuing_rule({
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
            ccode        => $ccode,
            permanent_location => $permanent_location,
            sub_location => $sub_location,
            genre        => $genre,
            circulation_level => $circulation_level,
            reserve_level => $reserve_level,
        });
    ok(_row_match($result_rule, $rule), 'When I attempt to get effective '
       .'issuing rule, then the above one is returned.');
}

$schema->storage->txn_rollback;

