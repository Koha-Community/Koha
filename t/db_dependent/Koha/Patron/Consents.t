#!/usr/bin/perl

# Copyright 2018 Rijksmuseum
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

use t::lib::TestBuilder;

use Koha::Database;
use Koha::DateUtils qw/dt_from_string/;
use Koha::Patron::Consents;

our $builder = t::lib::TestBuilder->new;
our $schema = Koha::Database->new->schema;

subtest 'Basic tests for Koha::Patron::Consent' => sub {
    plan tests => 2;
    $schema->storage->txn_begin;

    my $patron1 = $builder->build_object({ class => 'Koha::Patrons' });
    my $consent1 = Koha::Patron::Consent->new({
        borrowernumber => $patron1->borrowernumber,
        type => 'GDPR_PROCESSING',
        given_on => dt_from_string,
    })->store;
    is( Koha::Patron::Consents->search({ borrowernumber => $patron1->borrowernumber })->count, 1, 'One consent for new borrower' );
    $consent1->delete;
    is( Koha::Patron::Consents->search({ borrowernumber => $patron1->borrowernumber })->count, 0, 'No consents left for new borrower' );

    $schema->storage->txn_rollback;
};
