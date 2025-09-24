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

use Test::More tests => 3;
use Test::NoWarnings;

use Test::MockModule;
use Test::MockObject;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::ILL::Request::Workflow::HistoryCheck;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $isbn = '321321321';

subtest 'show_history_check' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    use_ok('Koha::ILL::Request::Workflow::HistoryCheck');

    my $fake_cardnumber = '123456789';
    my $ill_patron      = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { cardnumber => $fake_cardnumber }
        }
    );

    my $metadata = {
        title      => 'This is a title',
        author     => 'This is an author',
        isbn       => $isbn,
        cardnumber => $fake_cardnumber,
    };

    # Because hashes can reorder themselves, we need to make sure ours is in a
    # predictable order
    my $sorted = {};
    foreach my $key ( keys %{$metadata} ) {
        $sorted->{$key} = $metadata->{$key};
    }

    my $history_check = Koha::ILL::Request::Workflow::HistoryCheck->new( $sorted, 'staff' );

    isa_ok( $history_check, 'Koha::ILL::Request::Workflow::HistoryCheck' );

    is(
        $history_check->prep_metadata($sorted),
        'eyJhdXRob3IiOiJUaGlzIGlzIGFuIGF1dGhvciIsImNhcmRudW1iZXIiOiIxMjM0NTY3ODkiLCJp%0Ac2JuIjoiMzIxMzIxMzIxIiwidGl0bGUiOiJUaGlzIGlzIGEgdGl0bGUifQ%3D%3D%0A',
        'prep_metadata works'
    );

    # Mock capabilities and load_backend
    my $backend = Test::MockObject->new;
    $backend->set_always( 'capabilities', sub { return can_create_request => 1 } );
    my $illreqmodule = Test::MockModule->new('Koha::ILL::Request');
    $illreqmodule->mock(
        'load_backend',
        sub { my $self = shift; $self->{_my_backend} = $backend; return $self }
    );

    # Mock ILLHistoryCheck enabled
    t::lib::Mocks::mock_preference( 'ILLHistoryCheck', 1 );

    my $ill_request = $builder->build_sample_ill_request( { borrowernumber => $ill_patron->borrowernumber } );
    is(
        $history_check->show_history_check($ill_request),
        0, 'Request with ISBN ' . $isbn . ' does not exist even though syspref is on. Not showing history check screen'
    );

    $builder->build(
        {
            source => 'Illrequestattribute',
            value  => { illrequest_id => $ill_request->illrequest_id, type => 'isbn', value => $isbn }
        }
    );

    is(
        $history_check->show_history_check($ill_request),
        1, 'Request with ISBN ' . $isbn . ' exists, syspref is on and is same patron. Able to show history check screen'
    );

    my $metadata_with_no_cardnumber = {
        title  => 'This is a title',
        author => 'This is an author',
        isbn   => $isbn,
    };

    my $ill_request_with_no_borrowernumber = $builder->build_sample_ill_request( { borrowernumber => undef } );

    my $new_opac_history_check =
        Koha::ILL::Request::Workflow::HistoryCheck->new( $metadata_with_no_cardnumber, 'opac' );

    is(
        $new_opac_history_check->show_history_check($ill_request_with_no_borrowernumber),
        0, 'Don\'t show history check for unauthenticated requests'
    );

    # Mock ILLHistoryCheck disabled
    t::lib::Mocks::mock_preference( 'ILLHistoryCheck', 0 );

    is(
        $history_check->show_history_check($ill_request),
        0, 'not able to show history check screen'
    );

    $schema->storage->txn_rollback;

};

subtest 'after_request_created' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $fake_cardnumber = '123456789';
    my $metadata        = {
        title  => 'This is a title',
        author => 'This is an author',
        isbn   => $isbn,
    };

    my $authenticated_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
        }
    );

    t::lib::Mocks::mock_userenv( { patron => $authenticated_patron } );

    # Create a new request with new isbn
    my $new_ill_request =
        $builder->build_sample_ill_request( { borrowernumber => $authenticated_patron->borrowernumber } );
    my $original_staff_notes = $new_ill_request->notesstaff;
    $metadata->{isbn} = 'nonexistentisbn';
    $builder->build(
        {
            source => 'Illrequestattribute',
            value  => { illrequest_id => $new_ill_request->illrequest_id, type => 'isbn', value => $metadata->{isbn} }
        }
    );
    my $opac_history_check = Koha::ILL::Request::Workflow::HistoryCheck->new( $metadata, 'opac' );
    $opac_history_check->after_request_created( $metadata, $new_ill_request );

    is(
        $new_ill_request->extended_attributes->find( { 'type' => 'historycheck_requests' } ),
        undef,
        'History check didn\'t find any matching requests. historycheck_requests illrequestattribute has not been updated.'
    );

    # Create a second request with preexisting isbn by self patron
    my $second_ill_request =
        $builder->build_sample_ill_request( { borrowernumber => $authenticated_patron->borrowernumber } );
    my $third_ill_request =
        $builder->build_sample_ill_request( { borrowernumber => $authenticated_patron->borrowernumber } );
    $metadata->{isbn} = $isbn;
    $builder->build(
        {
            source => 'Illrequestattribute',
            value  => { illrequest_id => $second_ill_request->illrequest_id, type => 'isbn', value => $isbn }
        }
    );
    $builder->build(
        {
            source => 'Illrequestattribute',
            value  => { illrequest_id => $third_ill_request->illrequest_id, type => 'isbn', value => $isbn }
        }
    );
    $opac_history_check->after_request_created( $metadata, $third_ill_request );

    is(
        $third_ill_request->extended_attributes->find( { 'type' => 'historycheck_requests' } )->value,
        $second_ill_request->illrequest_id,
        'Contains staffnotes related submissions by self patron'
    );

    $schema->storage->txn_rollback;
};

1;
