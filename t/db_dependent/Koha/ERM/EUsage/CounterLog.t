#!/usr/bin/perl

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
use Koha::ERM::EUsage::CounterLog;

use t::lib::Mocks;
use t::lib::TestBuilder;
use Test::MockModule;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'patron' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $library = $builder->build( { source => 'Branch' } );
    my $patron  = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library->{branchcode} }
        }
    );

    my $counterlog = Koha::ERM::EUsage::CounterLog->new(
        {
            borrowernumber => $patron->borrowernumber,
        }
    )->store;

    my $p = $counterlog->patron;
    is(
        ref($p), 'Koha::Patron',
        'Koha::ERM::EUsage::CounterLog->patron should return a Koha::Patron'
    );
    is(
        $p->borrowernumber, $patron->borrowernumber,
        'Koha::ERM::EUsage::CounterLog->patron should return the correct patron'
    );

    $schema->storage->txn_rollback;

};
