#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2014 - Koha Team
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

use t::lib::TestBuilder;
use Test::More tests => 3;

use Koha::Database;

BEGIN {
    use_ok('C4::Category');
}

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new();

my $nonexistent_categorycode = 'NONEXISTEN';
$builder->build({
    source => 'Category',
    value  => {
        categorycode          => $nonexistent_categorycode,
        description           => 'Desc',
        enrolmentperiod       => 12,
        enrolementperioddate  => '2014-01-02',
        upperagelimit         => 99,
        dateofbirthrequired   => 1,
        enrolmentfee          => 1.5,
        reservefee            => 2.5,
        hidelostitems         => 0,
        overduenoticerequired => 0,
        category_type         => 'A',
    },
});

my @categories = C4::Category->all;
ok( @categories, 'all returns categories' );

my $match = grep {$_->{categorycode} eq $nonexistent_categorycode } @categories;
is( $match, 1, 'all returns the inserted category');

$schema->storage->txn_rollback;

1;
