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

use Test::More tests => 2;

use Test::MockModule;
use Test::MockObject;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::ILL::Request::Workflow::HistoryCheck;
use Koha::Database;

my $schema = Koha::Database->new->schema;

my $issn = '321321321';

subtest 'show_history_check' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    my $builder = t::lib::TestBuilder->new;

    use_ok('Koha::ILL::Request::Workflow::HistoryCheck');

    my $metadata = {
        title  => 'This is a title',
        author => 'This is an author',
        issn   => $issn
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
        'eyJhdXRob3IiOiJUaGlzIGlzIGFuIGF1dGhvciIsImlzc24iOiIzMjEzMjEzMjEiLCJ0aXRsZSI6%0AIlRoaXMgaXMgYSB0aXRsZSJ9%0A',
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

    my $ill_request = $builder->build_sample_ill_request();
    is(
        $history_check->show_history_check($ill_request),
        0, 'Request with ISSN ' . $issn . ' does not exist even though syspref is on. Not showing history check screen'
    );

    $builder->build(
        {
            source => 'Illrequestattribute',
            value  => { illrequest_id => $ill_request->illrequest_id, type => 'issn', value => $issn }
        }
    );

    is(
        $history_check->show_history_check($ill_request),
        1, 'Request with ISSN ' . $issn . ' exists and syspref is on. Able to show history check screen'
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

    plan tests => 4;

    $schema->storage->txn_begin;

    my $builder = t::lib::TestBuilder->new;

    my $metadata = {
        title  => 'This is a title',
        author => 'This is an author',
        issn   => $issn
    };

    my $authenticated_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
        }
    );

    my $other_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
        }
    );

    t::lib::Mocks::mock_userenv( { patron => $authenticated_patron } );

    # Create an old request
    my $existing_ill_request =
        $builder->build_sample_ill_request( { borrowernumber => $other_patron->borrowernumber } );
    $builder->build(
        {
            source => 'Illrequestattribute',
            value  => { illrequest_id => $existing_ill_request->illrequest_id, type => 'issn', value => $issn }
        }
    );

    # Create a new request with new issn
    my $new_ill_request =
        $builder->build_sample_ill_request( { borrowernumber => $authenticated_patron->borrowernumber } );
    my $original_staff_notes = $new_ill_request->notesstaff;
    $metadata->{issn} = 'nonexistentissn';
    $builder->build(
        {
            source => 'Illrequestattribute',
            value  => { illrequest_id => $new_ill_request->illrequest_id, type => 'issn', value => $metadata->{issn} }
        }
    );
    my $opac_history_check = Koha::ILL::Request::Workflow::HistoryCheck->new( $metadata, 'opac' );
    $opac_history_check->after_request_created( $metadata, $new_ill_request );

    is(
        $new_ill_request->notesstaff,
        $original_staff_notes,
        'History check didn\'t find any matching requests. Staff notes have not been updated.'
    );

    # Create a third request with preexisting issn by other patron
    my $third_ill_request =
        $builder->build_sample_ill_request( { borrowernumber => $authenticated_patron->borrowernumber } );
    $metadata->{issn} = $issn;
    $builder->build(
        {
            source => 'Illrequestattribute',
            value  => { illrequest_id => $third_ill_request->illrequest_id, type => 'issn', value => $issn }
        }
    );
    $opac_history_check->after_request_created( $metadata, $third_ill_request );

    like(
        $third_ill_request->notesstaff, qr/Request has been submitted by other patrons in the past/,
        'Contains staffnotes related submissions by other patrons'
    );

    # Create a fourth request with preexisting issn by self patron and others
    my $fourth_ill_request =
        $builder->build_sample_ill_request( { borrowernumber => $authenticated_patron->borrowernumber } );
    $metadata->{issn} = $issn;
    $builder->build(
        {
            source => 'Illrequestattribute',
            value  => { illrequest_id => $fourth_ill_request->illrequest_id, type => 'issn', value => $issn }
        }
    );
    $opac_history_check->after_request_created( $metadata, $fourth_ill_request );

    like(
        $fourth_ill_request->notesstaff, qr/Request has been submitted by other patrons in the past/,
        'Contains staffnotes related submissions by other patrons'
    );

    like(
        $fourth_ill_request->notesstaff, qr/Request has been submitted by this patron in the past/,
        'Contains staffnotes related submissions by self patron'
    );

};

1;
