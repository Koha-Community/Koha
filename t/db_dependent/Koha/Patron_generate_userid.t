#!/usr/bin/perl

# Copyright 2022 Rijksmuseum, Koha development team
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
use utf8;
#use Data::Dumper;
use Test::More tests => 2;
use Test::Warn;
use Test::MockModule;
use Test::MockObject;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Koha::Database;
use Koha::Patrons;
use Koha::Plugins;

our $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
our $builder = t::lib::TestBuilder->new;
our $expected_plugins = [];

sub mockedGetPlugins {
    my @plugins;
    foreach my $p ( @$expected_plugins ) {
        my $object = Test::MockObject->new;
        my $method;
        if( $p eq 'email' ) {
            $method = sub { return $_[1]->{patron}->email; };
        } elsif( $p eq 'firstname' ) {
            $method = sub { return $_[1]->{patron}->firstname. ($_[1]->{patron}->id // 0); };
        } elsif( $p eq 'baduserid' ) {
            $method = sub { return ''; }; # bad return
        } elsif( $p eq 'die' ) {
            $method = sub { die; };
        } elsif( $p eq 'undef' ) {
            $method = sub { return; };
        } else { # borrowernumber
            $method = sub { return $_[1]->{patron}->id // 0; };
        }
        $object->mock('patron_generate_userid', $method);
        $object->mock('get_metadata', sub { return { name => $p }}); # called when warning from ->call
        push @plugins, $object;
    }
    return @plugins;
}

subtest 'generate_userid (legacy, without plugins)' => sub {
    plan tests => 7;

    t::lib::Mocks::mock_config('enable_plugins', 0);

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron_category = $builder->build_object(
        {
            class => 'Koha::Patron::Categories',
            value => { category_type => 'P', enrolmentfee => 0 }
        }
    );
    my %data = (
        cardnumber   => "123456789",
        firstname    => "Tômàsító",
        surname      => "Ñoné",
        categorycode => $patron_category->categorycode,
        branchcode   => $library->branchcode,
    );

    my $expected_userid_patron_1 = 'tomasito.none';
    my $new_patron = Koha::Patron->new({ firstname => $data{firstname}, surname => $data{surname} } );
    $new_patron->generate_userid;
    my $userid = $new_patron->userid;
    is( $userid, $expected_userid_patron_1, 'generate_userid should generate the userid we expect' );
    my $borrowernumber = Koha::Patron->new(\%data)->store->borrowernumber;
    my $patron_1 = Koha::Patrons->find($borrowernumber);
    is ( $patron_1->userid, $expected_userid_patron_1, 'The userid generated should be the one we expect' );

    $new_patron->generate_userid;
    $userid = $new_patron->userid;
    is( $userid, $expected_userid_patron_1 . '1', 'generate_userid should generate the userid we expect' );
    $data{cardnumber} = '987654321';
    my $new_borrowernumber = Koha::Patron->new(\%data)->store->borrowernumber;
    my $patron_2 = Koha::Patrons->find($new_borrowernumber);
    isnt( $patron_2->userid, 'tomasito',
        "Patron with duplicate userid has new userid generated" );
    is( $patron_2->userid, $expected_userid_patron_1 . '1', # TODO we could make that configurable
        "Patron with duplicate userid has new userid generated (1 is appended" );

    $new_patron->generate_userid;
    $userid = $new_patron->userid;
    is( $userid, $expected_userid_patron_1 . '2', 'generate_userid should generate the userid we expect' );

    $patron_1 = Koha::Patrons->find($borrowernumber);
    $patron_1->userid(undef);
    $patron_1->generate_userid;
    $userid = $patron_1->userid;
    is( $userid, $expected_userid_patron_1, 'generate_userid should generate the userid we expect' );

    # Cleanup
    $patron_1->delete;
    $patron_2->delete;
};

subtest 'Plugins for generate_userid' => sub {
    plan tests => 6;
    t::lib::Mocks::mock_config('enable_plugins', 1);

    my $auth = Test::MockModule->new( 'Koha::Plugins' );
    $auth->mock( 'GetPlugins', \&mockedGetPlugins );
    $auth->mock( 'get_enabled_plugins', \&mockedGetPlugins );

    # Check the email plugin
    $expected_plugins = [ 'email' ];
    my $patron1 = $builder->build_object({ class => 'Koha::Patrons', value => { email => 'test@domain.com' } });
    $patron1->generate_userid;
    is( $patron1->userid, 'test@domain.com', 'generated userid from email plugin' );

    # Expect second response from firstname, because empty string from baduserid is not valid
    $expected_plugins = [ 'baduserid', 'firstname', 'email' ];
    $patron1->generate_userid;
    my $reg = $patron1->firstname. '\d+';
    like( $patron1->userid, qr/$reg/, 'ignored baduserid, generated userid from firstname plugin' );

    # Expect third response from fallback for wrong_method, catch warning from die plugin
    $expected_plugins = [ 'die', 'baduserid', 'wrong_method', 'firstname', 'email' ];
    warning_like { $patron1->generate_userid; } qr/Plugin error \(die\): Died/, 'Caught warn for die plugin';
    like( $patron1->userid, qr/^\d+$/, 'generated borrowernumber userid from plugin when given wrong_method' );
    $patron1->delete;

    # Testing with an object not in storage; unknown should return id 0, the plugin undef returns undef :)
    $expected_plugins = [ 'unknown', 'undef' ];
    $patron1= Koha::Patron->new({ firstname => 'A', surname => 'B', email => 'test2@domain.com', userid => 'user999' });
    $patron1->generate_userid;
    is( $patron1->userid, undef, 'No valid plugin responses' );

    # Finally pass no plugins, so we would expect legacy response
    $expected_plugins = [];
    $patron1->generate_userid;
    is( $patron1->userid, 'a.b', 'No plugins: legacy response' );
};

$schema->storage->txn_rollback;
