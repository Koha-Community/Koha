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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 2;

use t::lib::TestBuilder;

use Koha::Database;
use Koha::Tags::Approvals;

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'search() tests' => sub {

    plan tests => 1;

    $schema->storage->txn_begin;

    my $current_count = Koha::Tags::Approvals->search->count;

    my $approval_1 = $builder->build_object( { class => 'Koha::Tags::Approvals' } );
    my $approval_2 = $builder->build_object( { class => 'Koha::Tags::Approvals' } );

    is( Koha::Tags::Approvals->search->count, $current_count + 2, 'Approvals count consistent' );

    $schema->storage->txn_rollback;

};
