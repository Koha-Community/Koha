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

use Test::More tests => 1;
use Test::Exception;

subtest 'Koha::Exceptions::Object::FKConstraint tests' => sub {

    plan tests => 5;

    use_ok('Koha::Exceptions::Object');

    throws_ok
        { Koha::Exceptions::Object::FKConstraint->throw( broken_fk => 'nasty', value => 'fk' ); }
        'Koha::Exceptions::Object::FKConstraint',
        'Exception is thrown :-D';

    # stringify the exception
    is( "$@", 'Invalid parameter passed, nasty=fk does not exist', 'Exception stringified correctly' );

    throws_ok
        { Koha::Exceptions::Object::FKConstraint->throw( "Manual message exception" ) }
        'Koha::Exceptions::Object::FKConstraint',
        'Exception is thrown :-D';
    is( "$@", 'Manual message exception', 'Exception not stringified if manually passed' );
};

