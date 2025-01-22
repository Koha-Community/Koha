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

use Test::NoWarnings;
use Test::More tests => 2;
use Test::Exception;

use Koha::Plugins::Tab;

subtest 'new() tests' => sub {
    plan tests => 7;

    throws_ok { Koha::Plugins::Tab->new( { title => 'A title' } ); }
    'Koha::Exceptions::MissingParameter',
        'Exception is thrown on missing content';

    like(
        "$@",
        qr/Mandatory parameter 'content' missing/,
        'Exception message is correct'
    );

    throws_ok { Koha::Plugins::Tab->new( { content => 'Some content' } ); }
    'Koha::Exceptions::MissingParameter',
        'Exception is thrown on missing title';

    like(
        "$@",
        qr/Mandatory parameter 'title' missing/,
        'Exception message is correct'
    );

    my $tab = Koha::Plugins::Tab->new(
        {
            title   => 'A title',
            content => 'Some content'
        }
    );

    is( $tab->title,   'A title',      'title accessor is correct' );
    is( $tab->content, 'Some content', 'content accessor is correct' );

    my $id = 'calculated-id';
    $tab->id($id);

    is( $tab->id, $id, 'The id can be calculated and set on runtime' );
};
