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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 3;

use Koha::Database;
use Koha::Suggestions;

use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'suggester() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $patron     = $builder->build_object( { class => 'Koha::Patrons' } );
    my $suggestion = $builder->build_object( { class => 'Koha::Suggestions', value => { suggestedby => undef } } );

    is( $suggestion->suggester, undef, 'Returns undef if no suggester' );

    # Set a borrowernumber
    $suggestion->suggestedby( $patron->borrowernumber )->store->discard_changes;
    my $suggester = $suggestion->suggester;
    is( ref($suggester), 'Koha::Patron', 'Type is correct for suggester' );
    is_deeply( $patron->unblessed, $suggester->unblessed, 'It returns the right patron' );

    $schema->storage->txn_rollback;
};

subtest 'strings_map() tests' => sub {
    plan tests => 2;

    $schema->txn_begin;

    my $av_value1 = Koha::AuthorisedValue->new(
        {
            category         => "SUGGEST_FORMAT",
            authorised_value => 'RECORD',
            lib              => "Test format"
        }
    )->store;
    my $av_value2 = Koha::AuthorisedValue->new(
        {
            category         => "SUGGEST_STATUS",
            authorised_value => 'WANTED',
            lib              => "Test status"
        }
    )->store;
    my $suggestion = $builder->build_object(
        { class => 'Koha::Suggestions', value => { suggestedby => undef, STATUS => 'WANTED', itemtype => 'RECORD' } } );

    my $strings_map = $suggestion->strings_map( { public => 0 } );
    is_deeply(
        $strings_map,
        {
            STATUS       => { str => 'Test status',             type => 'av', category => 'SUGGEST_STATUS' },
            itemtype     => { str => 'Test format',             type => 'av', category => 'SUGGEST_FORMAT' },
            patronreason => { str => $suggestion->patronreason, type => 'av', category => 'OPAC_SUG' },
        },
        'Strings map is correct'
    );

    my $av_value3 = Koha::AuthorisedValue->new(
        {
            category         => "OPAC_SUG",
            authorised_value => 'OPAC',
            lib              => "An OPAC reason"
        }
    )->store;

    $suggestion->patronreason('OPAC');
    $strings_map = $suggestion->strings_map( { public => 0 } );
    is_deeply(
        $strings_map,
        {
            STATUS       => { str => 'Test status',    type => 'av', category => 'SUGGEST_STATUS' },
            itemtype     => { str => 'Test format',    type => 'av', category => 'SUGGEST_FORMAT' },
            patronreason => { str => 'An OPAC reason', type => 'av', category => 'OPAC_SUG' },
        },
        'Strings map is correct'
    );

    $schema->txn_rollback;

};
