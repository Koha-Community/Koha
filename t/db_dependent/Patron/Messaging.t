#!/usr/bin/perl
#
# This file is part of Koha.
#
# Copyright (C) 2018  Andreas Jonsson <andreas.jonsson@kreablo.se>
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
use t::lib::Mocks;
use File::Spec;
use File::Basename;

use Koha::DateUtils qw( dt_from_string );

my $schema = Koha::Database->new->schema;
my $dbh    = C4::Context->dbh;

my $library;
my $borrower;

subtest 'Default behaviour tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    # Set only to avoid exception.
    t::lib::Mocks::mock_preference( 'dateformat', 'metric' );

    my $builder = t::lib::TestBuilder->new;

    $library = $builder->build(
        {
            source => 'Branch',
        }
    );

    $borrower = $builder->build(
        {
            source => 'Borrower',
            value  => {
                branchcode => $library->{branchcode},
            }
        }
    );

    $dbh->do(<<DELETESQL);
DELETE FROM letter
 WHERE module='circulation'
   AND code = 'PREDUEDGST'
   AND message_transport_type='email'
   AND branchcode=''
DELETESQL

    $dbh->do(<<DELETESQL);
DELETE FROM message_attributes WHERE message_name = 'Advance_Notice'
DELETESQL

    my $message_attribute = $builder->build(
        {
            source => 'MessageAttribute',
            value  => { message_name => 'Advance_Notice' }
        }
    );

    my $letter = $builder->build(
        {
            source => 'Letter',
            value  => {
                module                 => 'circulation',
                code                   => 'PREDUEDGST',
                branchcode             => '',
                message_transport_type => 'email',
                lang                   => 'default',
                is_html                => 0,
                content                => '<<count>> <<branches.branchname>>'
            }
        }
    );
    my $borrower_message_preference = $builder->build(
        {
            source => 'BorrowerMessagePreference',
            value  => {
                borrowernumber       => $borrower->{borrowernumber},
                wants_digest         => 1,
                days_in_advance      => 1,
                message_attribute_id => $message_attribute->{message_attribute_id}
            }
        }
    );

    my $borrower_message_transport_preference = $builder->build(
        {
            source => 'BorrowerMessageTransportPreference',
            value  => {
                borrower_message_preference_id => $borrower_message_preference->{borrower_message_preference_id},
                message_transport_type         => 'email'
            }
        }
    );

    my $borrower_message_transport_preference_1 = $builder->build(
        {
            source => 'BorrowerMessageTransportPreference',
            value  => {
                borrower_message_preference_id => $borrower_message_preference->{borrower_message_preference_id},
                message_transport_type         => 'phone'
            }
        }
    );

    my $patron = Koha::Patrons->find( $borrower->{borrowernumber} );

    is(
        $patron->has_messaging_preference( { message_name => 'Advance_Notice', message_transport_type => 'email' } ),
        1, "Patron has Advance_Notice email preference"
    );
    is(
        $patron->has_messaging_preference( { message_name => 'Advance_Notice', message_transport_type => 'phone' } ),
        1, "Patron has Advance_Notice phone preference"
    );
    is(
        $patron->has_messaging_preference( { message_name => 'Advance_Notice', message_transport_type => 'sms' } ), 0,
        "Patron has no Advance_Notice sms preference"
    );
};
