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

use Test::More tests => 1;

use Koha::Database;
use Koha::Suggestions;

use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'suggester() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $patron     = $builder->build_object( { class => 'Koha::Patrons' } );
    my $suggestion = $builder->build_object(
        { class => 'Koha::Suggestions', value => { suggestedby => undef } } );

    is( $suggestion->suggester, undef, 'Returns undef if no suggester' );
    # Set a borrowernumber
    $suggestion->suggestedby($patron->borrowernumber)->store->discard_changes;
    my $suggester = $suggestion->suggester;
    is( ref($suggester), 'Koha::Patron', 'Type is correct for suggester' );
    is_deeply( $patron->unblessed, $suggester->unblessed, 'It returns the right patron' );

    $schema->storage->txn_rollback;
};
