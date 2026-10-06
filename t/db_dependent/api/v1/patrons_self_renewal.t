#!/usr/bin/env perl

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
use Test::More tests => 3;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new();

my $t = Test::Mojo->new('Koha::REST::V1');

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'start()' => sub {
    plan tests => 9;

    $schema->storage->txn_begin;

    my $category = $builder->build_object(
        {
            class => 'Koha::Patron::Categories',
            value => {
                self_renewal_enabled         => 0, self_renewal_availability_start => 10, self_renewal_if_expired => 10,
                self_renewal_fines_block     => 10, noissuescharge                 => 10,
                self_renewal_failure_message => 'This is a failure message'
            }
        }
    );

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { categorycode => $category->categorycode, dateexpiry => dt_from_string(), debarred => undef }
        }
    );

    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    my $borrowernumber = $patron->borrowernumber;

    $t->get_ok("//$userid:$password@/api/v1/public/patrons/$borrowernumber/self_renewal")
        ->status_is( 403, 'REST3.2.2' )
        ->json_is( { error => "You are not eligible for self-renewal" } );

    $category->self_renewal_enabled(1)->store();

    t::lib::Mocks::mock_preference( 'OPACPatronDetails', 1 );

    $t->get_ok("//$userid:$password@/api/v1/public/patrons/$borrowernumber/self_renewal")
        ->status_is( 200, 'REST3.2.2' )
        ->json_is(
        {
            self_renewal_settings => {
                self_renewal_failure_message      => $category->self_renewal_failure_message,
                self_renewal_information_messages => [ $category->self_renewal_information_message ],
                opac_patron_details               => 1
            }
        }
        );

    my $new_category = $builder->build_object(
        {
            class => 'Koha::Patron::Categories',
            value => {
                self_renewal_enabled         => 1, self_renewal_availability_start => 10, self_renewal_if_expired => 10,
                self_renewal_fines_block     => 10, noissuescharge                 => 10,
                self_renewal_failure_message => 'This is a failure message'
            }
        }
    );
    $t->get_ok("//$userid:$password@/api/v1/public/patrons/$borrowernumber/self_renewal")
        ->status_is( 200, 'REST3.2.2' )
        ->json_is(
        {
            self_renewal_settings => {
                self_renewal_failure_message      => $category->self_renewal_failure_message,
                self_renewal_information_messages => [ $category->self_renewal_information_message ],
                opac_patron_details               => 1
            }
        }
        );

    $schema->storage->txn_rollback;
};

subtest 'submit()' => sub {
    plan tests => 11;

    $schema->storage->txn_begin;

    my $category = $builder->build_object(
        {
            class => 'Koha::Patron::Categories',
            value => {
                self_renewal_enabled         => 0, self_renewal_availability_start => 10, self_renewal_if_expired => 10,
                self_renewal_fines_block     => 10, noissuescharge                 => 10,
                self_renewal_failure_message => 'This is a failure message',
                enforce_expiry_notice        => 0
            }
        }
    );
    my $branch = $builder->build_object( { class => 'Koha::Libraries' } );

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                branchcode => $branch->branchcode, categorycode => $category->categorycode,
                dateexpiry => dt_from_string(),    debarred     => undef, lang => 'default'
            }
        }
    );

    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    my $borrowernumber = $patron->borrowernumber;

    $t->post_ok( "//$userid:$password@/api/v1/public/patrons/$borrowernumber/self_renewal" => json => {} )
        ->status_is( 403, 'REST3.2.2' )
        ->json_is( { error => "You are not eligible for self-renewal" } );

    t::lib::Mocks::mock_preference( 'OPACPatronDetails',                1 );
    t::lib::Mocks::mock_preference( 'AutoApprovePatronProfileSettings', 0 );
    $category->self_renewal_enabled(1)->store();

    my $date;
    if ( C4::Context->preference('BorrowerRenewalPeriodBase') eq 'combination' ) {
        $date =
            ( dt_from_string gt dt_from_string( $patron->dateexpiry ) )
            ? dt_from_string
            : dt_from_string( $patron->dateexpiry );
    } else {
        $date =
            C4::Context->preference('BorrowerRenewalPeriodBase') eq 'dateexpiry'
            ? dt_from_string( $patron->dateexpiry )
            : dt_from_string;
    }
    my $expiry_date = $patron->category->get_expiry_date($date);

    my $renewal_notice = $builder->build_object(
        {
            class => 'Koha::Notice::Templates',
            value => {
                module                 => 'members',
                code                   => 'MEMBERSHIP_RENEWED',
                branchcode             => $branch->branchcode,
                message_transport_type => 'print',
                lang                   => 'default'
            }
        }
    );

    my $counter = Koha::Notice::Messages->search( { borrowernumber => $patron->borrowernumber } )->count;
    $t->post_ok( "//$userid:$password@/api/v1/public/patrons/$borrowernumber/self_renewal" => json => {} )
        ->status_is( 201, 'REST3.2.2' )
        ->json_is( { expiry_date => $expiry_date->truncate( to => 'day' ), confirmation_sent => 1 } );
    is(
        Koha::Notice::Messages->search( { borrowernumber => $patron->borrowernumber } )->count, $counter + 1,
        "Notice queued"
    );

    # Test that modifications are created correctly
    t::lib::Mocks::mock_preference( 'OPACPatronDetails', 1 );
    my $modification_data = { patron => { firstname => 'Newname' } };
    $patron->dateexpiry( dt_from_string() )->store();

    $t->post_ok(
        "//$userid:$password@/api/v1/public/patrons/$borrowernumber/self_renewal" => json => $modification_data )
        ->status_is( 201, 'REST3.2.2' )
        ->json_is( { expiry_date => $expiry_date->truncate( to => 'day' ), confirmation_sent => 1 } );

    my @modifications = Koha::Patron::Modifications->search( { borrowernumber => $patron->borrowernumber } )->as_list;
    is( scalar(@modifications), 1, "New modification has replaced any existing mods" );

    $schema->storage->txn_rollback;
};
