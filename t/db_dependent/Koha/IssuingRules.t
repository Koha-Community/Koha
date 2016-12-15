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

use Koha::IssuingRules;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder      = t::lib::TestBuilder->new;

subtest 'get_effective_issuing_rule' => sub {
    plan tests => 1;

    my $patron       = $builder->build({ source => 'Borrower' });
    my $item     = $builder->build({ source => 'Item' });

    my $categorycode = $patron->{'categorycode'};
    my $itemtype     = $item->{'itype'};
    my $branchcode   = $item->{'homebranch'};

    subtest 'Get effective issuing rule in correct order' => sub {
        plan tests => 18;

        my $rule;
        Koha::IssuingRules->delete;
        ok(!Koha::IssuingRules->search->count, 'There are no issuing rules.');
        $rule = Koha::IssuingRules->get_effective_issuing_rule({
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
        });
        is($rule, undef, 'When I attempt to get effective issuing rule, then undef'
                        .' is returned.');

        ok(Koha::IssuingRule->new({
            branchcode => '*',
            categorycode => '*',
            itemtype => '*',
        })->store, 'Given I added an issuing rule branchcode => *, categorycode => *, itemtype => *,');
        $rule = Koha::IssuingRules->get_effective_issuing_rule({
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
        });
        ok(_row_match($rule, '*', '*', '*'), 'When I attempt to get effective issuing rule,'
           .' then the above one is returned.');

        ok(Koha::IssuingRule->new({
            branchcode => '*',
            categorycode => '*',
            itemtype => $itemtype,
        })->store, "Given I added an issuing rule branchcode => *, categorycode => *, itemtype => $itemtype,");
        $rule = Koha::IssuingRules->get_effective_issuing_rule({
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
        });
        ok(_row_match($rule, '*', '*', $itemtype), 'When I attempt to get effective issuing rule,'
           .' then the above one is returned.');

        ok(Koha::IssuingRule->new({
            branchcode => '*',
            categorycode => $categorycode,
            itemtype => '*',
        })->store, "Given I added an issuing rule branchcode => *, categorycode => $categorycode, itemtype => *,");
        $rule = Koha::IssuingRules->get_effective_issuing_rule({
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
        });
        ok(_row_match($rule, '*', $categorycode, '*'), 'When I attempt to get effective issuing rule,'
           .' then the above one is returned.');

        ok(Koha::IssuingRule->new({
            branchcode => '*',
            categorycode => $categorycode,
            itemtype => $itemtype,
        })->store, "Given I added an issuing rule branchcode => *, categorycode => $categorycode, itemtype => $itemtype,");
        $rule = Koha::IssuingRules->get_effective_issuing_rule({
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
        });
        ok(_row_match($rule, '*', $categorycode, $itemtype), 'When I attempt to get effective issuing rule,'
           .' then the above one is returned.');

        ok(Koha::IssuingRule->new({
            branchcode => $branchcode,
            categorycode => '*',
            itemtype => '*',
        })->store, "Given I added an issuing rule branchcode => $branchcode, categorycode => '*', itemtype => '*',");
        $rule = Koha::IssuingRules->get_effective_issuing_rule({
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
        });
        ok(_row_match($rule, $branchcode, '*', '*'), 'When I attempt to get effective issuing rule,'
           .' then the above one is returned.');

        ok(Koha::IssuingRule->new({
            branchcode => $branchcode,
            categorycode => '*',
            itemtype => $itemtype,
        })->store, "Given I added an issuing rule branchcode => $branchcode, categorycode => '*', itemtype => $itemtype,");
        $rule = Koha::IssuingRules->get_effective_issuing_rule({
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
        });
        ok(_row_match($rule, $branchcode, '*', $itemtype), 'When I attempt to get effective issuing rule,'
           .' then the above one is returned.');

        ok(Koha::IssuingRule->new({
            branchcode => $branchcode,
            categorycode => $categorycode,
            itemtype => '*',
        })->store, "Given I added an issuing rule branchcode => $branchcode, categorycode => $categorycode, itemtype => '*',");
        $rule = Koha::IssuingRules->get_effective_issuing_rule({
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
        });
        ok(_row_match($rule, $branchcode, $categorycode, '*'), 'When I attempt to get effective issuing rule,'
           .' then the above one is returned.');

        ok(Koha::IssuingRule->new({
            branchcode => $branchcode,
            categorycode => $categorycode,
            itemtype => $itemtype,
        })->store, "Given I added an issuing rule branchcode => $branchcode, categorycode => $categorycode, itemtype => $itemtype,");
        $rule = Koha::IssuingRules->get_effective_issuing_rule({
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
        });
        ok(_row_match($rule, $branchcode, $categorycode, $itemtype), 'When I attempt to get effective issuing rule,'
           .' then the above one is returned.');
    };
};

sub _row_match {
    my ($rule, $branchcode, $categorycode, $itemtype) = @_;

    return $rule->branchcode eq $branchcode && $rule->categorycode eq $categorycode
            && $rule->itemtype eq $itemtype;
}

$schema->storage->txn_rollback;

1;
