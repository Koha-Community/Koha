#!/usr/bin/perl

# Copyright Koha development team 2007
#
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

use Test::MockModule;
use Test::More tests => 3;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Koha::Database;

use_ok('C4::Letters', qw( GetLetters ));

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;
our $builder = t::lib::TestBuilder->new;

subtest 'GetLetters' => sub {
    plan tests => 2;
    t::lib::Mocks::mock_preference( 'dateformat', 'metric' );

    my $data_1 = {
        module  => 'blah',     code => 'ISBN', branchcode => 'NBSI', name => 'book', is_html => 1, title => 'green',
        content => 'blahblah', lang => 'french'
    };
    my $data_2 = {
        module  => 'blah',   code => 'ISSN', branchcode => 'NSSI', name => 'page', is_html => 0, title => 'blue',
        content => 'bleble', lang => 'american'
    };
    $builder->build_object( { class => 'Koha::Notice::Templates', value => $data_1 } );
    $builder->build_object( { class => 'Koha::Notice::Templates', value => $data_2 } );

    my $letters = GetLetters( { module => 'blah' } );
    is( scalar(@$letters), 2, 'GetLetters returns the 2 inserted letters' );

    my ($ISBN_letter) = grep { $_->{code} eq 'ISBN' } @$letters;
    is( $ISBN_letter->{name}, 'book', 'letter name for "ISBN" letter is book' );
};

subtest '_parseletter' => sub {
    plan tests => 2;

    # Regression test for bug 10843
    # $dt->add takes a scalar, not undef
    my $letter;
    t::lib::Mocks::mock_preference( 'ReservesMaxPickUpDelay', undef );
    $letter = C4::Letters::_parseletter( undef, 'reserves', { waitingdate => "2013-01-01" } );
    is( ref($letter), 'HASH' );
    t::lib::Mocks::mock_preference( 'ReservesMaxPickUpDelay', 1 );
    $letter = C4::Letters::_parseletter( undef, 'reserves', { waitingdate => "2013-01-01" } );
    is( ref($letter), 'HASH' );
};

$schema->storage->txn_begin;
