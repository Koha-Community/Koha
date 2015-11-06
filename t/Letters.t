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

use Test::MockModule;
use Test::More;

use Module::Load::Conditional qw/check_install/;

BEGIN {
    if ( check_install( module => 'Test::DBIx::Class' ) ) {
        plan tests => 6;
    } else {
        plan skip_all => "Need Test::DBIx::Class"
    }
}

use Test::DBIx::Class {
    schema_class => 'Koha::Schema',
    connect_info => ['dbi:SQLite:dbname=:memory:','',''],
    connect_opts => { name_sep => '.', quote_char => '`', },
    fixture_class => '::Populate',
}, 'Letter' ;
use t::lib::Mocks;

fixtures_ok [
    Letter => [
        [ 'module', 'code', 'branchcode', 'name', 'is_html', 'title', 'content' ],
        [ 'blah',   'ISBN', 'NBSI',       'book', 1,         'green', 'blahblah' ],
        [ 'bleh',   'ISSN', 'NSSI',       'page', 0,         'blue',  'blehbleh' ]
    ],
], 'add fixtures';

my $db = Test::MockModule->new('Koha::Database');
$db->mock( _new_schema => sub { return Schema(); } );

use_ok('C4::Letters');

t::lib::Mocks::mock_preference('dateformat', 'metric');

my $letters = C4::Letters::GetLetters();

my ( $ISBN_letter ) = grep {$_->{code} eq 'ISBN'} @$letters;
is( $ISBN_letter->{name}, 'book', 'letter name for "ISBN" letter is book' );
is( scalar( @$letters ), 2, 'GetLetters returns the 2 inserted letters' );

# Regression test for bug 10843
# $dt->add takes a scalar, not undef
my $letter;
t::lib::Mocks::mock_preference('ReservesMaxPickUpDelay', undef);
$letter = C4::Letters::_parseletter( undef, 'reserves', {waitingdate => "2013-01-01"} );
is( ref($letter), 'HASH');
t::lib::Mocks::mock_preference('ReservesMaxPickUpDelay', 1);
$letter = C4::Letters::_parseletter( undef, 'reserves', {waitingdate => "2013-01-01"} );
is( ref($letter), 'HASH');

1;
