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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 2;

use Koha::Database;
use Koha::ClassSplitRules;
use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;

subtest 'store + regexs' => sub {
    plan tests => 2;
    $schema->storage->txn_begin;

    my @regexs = ( 's/\s/\n/g', 's/(\s?=)/\n=/g', 's/^(J|K)\n/$1 /' );
    my $rule   = Koha::ClassSplitRule->new(
        {
            class_split_rule => 'split_rule',
            description      => 'a_split_test_1',
            split_routine    => 'regex',
        }
    )->store;

    $rule = Koha::ClassSplitRules->find("split_rule");
    is_deeply( $rule->regexs, [], '->regexs return an empty array when no regex is defined' );

    $rule->regexs( \@regexs )->store;

    $rule = Koha::ClassSplitRules->find("split_rule");
    is_deeply( $rule->regexs, \@regexs, '->new and ->regexs correctly serialized/deserialized the regexs' );

    $schema->storage->txn_rollback;
};
