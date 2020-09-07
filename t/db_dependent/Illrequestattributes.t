#!/usr/bin/perl

# This file is part of Koha.
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

use File::Basename qw/basename/;
use Koha::Database;
use Koha::Patrons;
use t::lib::TestBuilder;

use Test::More tests => 3;

my $schema = Koha::Database->new->schema;
use_ok('Koha::Illrequestattribute');
use_ok('Koha::Illrequestattributes');

subtest 'Basic object tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    Koha::Illrequestattributes->search->delete;

    my $builder = t::lib::TestBuilder->new;

    my $illrqattr = $builder->build({ source => 'Illrequestattribute' });

    my $illrqattr_obj = Koha::Illrequestattributes->find(
        $illrqattr->{illrequest_id},
        $illrqattr->{type}
    );
    isa_ok($illrqattr_obj, 'Koha::Illrequestattribute',
        "Correctly create and load an illrequestattribute object.");
    is($illrqattr_obj->illrequest_id, $illrqattr->{illrequest_id},
       "Illrequest_id getter works.");
    is($illrqattr_obj->type, $illrqattr->{type},
       "Type getter works.");
    is($illrqattr_obj->value, $illrqattr->{value},
       "Value getter works.");

    $illrqattr_obj->delete;

    is(Koha::Illrequestattributes->search->count, 0,
        "No attributes found after delete.");

    $schema->storage->txn_rollback;
};

1;
