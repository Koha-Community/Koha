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

use Test::NoWarnings;
use Test::More tests => 3;
use Test::MockModule;

use t::lib::TestBuilder;

use Koha::Database;
use Koha::DateUtils qw(dt_from_string);

use_ok('Koha::Acquisition::Invoice');

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'to_api() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    my $invoice_class = Test::MockModule->new('Koha::Acquisition::Invoice');
    $invoice_class->mock(
        'algo',
        sub { return 'algo' }
    );

    my $invoice = $builder->build_object(
        {
            class => 'Koha::Acquisition::Invoices',
            value => { closedate => undef }
        }
    );

    my $closed = $invoice->to_api->{closed};
    ok( defined $closed, 'closed is defined' );
    ok( !$closed,        'closedate is undef, closed evaluates to false' );

    $invoice->closedate(dt_from_string)->store->discard_changes;
    $closed = $invoice->to_api->{closed};
    ok( defined $closed, 'closed is defined' );
    ok( $closed,         'closedate is defined, closed evaluates to true' );

    my $invoice_json = $invoice->to_api( { embed => { algo => {} } } );
    ok( exists $invoice_json->{algo} );
    is_deeply( $invoice_json->{algo}, 'algo' );

    $schema->storage->txn_rollback;
};
