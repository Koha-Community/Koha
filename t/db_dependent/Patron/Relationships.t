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

use Test::NoWarnings;
use Test::More tests => 55;

use C4::Context;
use Koha::Database;

use t::lib::TestBuilder;

BEGIN {
    use_ok('Koha::Objects');
    use_ok('Koha::Patrons');
    use_ok('Koha::Patron::Relationship');
    use_ok('Koha::Patron::Relationships');
}

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new();

$schema->storage->txn_begin;

# Father
my $kyle = $builder->build_object(
    {
        class => 'Koha::Patrons',
        value => {
            firstname => 'Kyle',
            surname   => 'Hall',
        }
    }
);

# Mother
my $chelsea = $builder->build_object(
    {
        class => 'Koha::Patrons',
        value => {
            firstname => 'Chelsea',
            surname   => 'Hall',
        }
    }
);

# Children
my $daria = $builder->build_object(
    {
        class => 'Koha::Patrons',
        value => {
            firstname => 'Daria',
            surname   => 'Hall',
        }
    }
);

my $kylie = $builder->build_object(
    {
        class => 'Koha::Patrons',
        value => {
            firstname => 'Kylie',
            surname   => 'Hall',
        }
    }
);

Koha::Patron::Relationship->new( { guarantor_id => $kyle->id, guarantee_id => $daria->id, relationship => 'father' } )
    ->store();
Koha::Patron::Relationship->new( { guarantor_id => $kyle->id, guarantee_id => $kylie->id, relationship => 'father' } )
    ->store();
Koha::Patron::Relationship->new(
    { guarantor_id => $chelsea->id, guarantee_id => $daria->id, relationship => 'mother' } )->store();
Koha::Patron::Relationship->new(
    { guarantor_id => $chelsea->id, guarantee_id => $kylie->id, relationship => 'mother' } )->store();

my @gr;

@gr = $kyle->guarantee_relationships()->as_list;
is( @gr,                      2,              'Found 2 guarantee relationships for father' );
is( $gr[0]->guarantor_id,     $kyle->id,      'Guarantor matches for first relationship' );
is( $gr[0]->guarantee_id,     $daria->id,     'Guarantee matches for first relationship' );
is( $gr[0]->relationship,     'father',       'Relationship is father' );
is( ref( $gr[0]->guarantee ), 'Koha::Patron', 'Method guarantee returns a Koha::Patron' );
is( $gr[0]->guarantee->id,    $daria->id,     'Koha::Patron returned is the correct guarantee' );
is( ref( $gr[0]->guarantor ), 'Koha::Patron', 'Method guarantor returns a Koha::Patron' );
is( $gr[0]->guarantor->id,    $kyle->id,      'Koha::Patron returned is the correct guarantor' );

is( $gr[1]->guarantor_id,     $kyle->id,      'Guarantor matches for first relationship' );
is( $gr[1]->guarantee_id,     $kylie->id,     'Guarantee matches for first relationship' );
is( $gr[1]->relationship,     'father',       'Relationship is father' );
is( ref( $gr[1]->guarantee ), 'Koha::Patron', 'Method guarantee returns a Koha::Patron' );
is( $gr[1]->guarantee->id,    $kylie->id,     'Koha::Patron returned is the correct guarantee' );
is( ref( $gr[1]->guarantor ), 'Koha::Patron', 'Method guarantor returns a Koha::Patron' );
is( $gr[1]->guarantor->id,    $kyle->id,      'Koha::Patron returned is the correct guarantor' );

@gr = $chelsea->guarantee_relationships()->as_list;
is( @gr,                      2,              'Found 2 guarantee relationships for mother' );
is( $gr[0]->guarantor_id,     $chelsea->id,   'Guarantor matches for first relationship' );
is( $gr[0]->guarantee_id,     $daria->id,     'Guarantee matches for first relationship' );
is( $gr[0]->relationship,     'mother',       'Relationship is mother' );
is( ref( $gr[0]->guarantee ), 'Koha::Patron', 'Method guarantee returns a Koha::Patron' );
is( $gr[0]->guarantee->id,    $daria->id,     'Koha::Patron returned is the correct guarantee' );
is( ref( $gr[0]->guarantor ), 'Koha::Patron', 'Method guarantor returns a Koha::Patron' );
is( $gr[0]->guarantor->id,    $chelsea->id,   'Koha::Patron returned is the correct guarantor' );

is( $gr[1]->guarantor_id,     $chelsea->id,   'Guarantor matches for first relationship' );
is( $gr[1]->guarantee_id,     $kylie->id,     'Guarantee matches for first relationship' );
is( $gr[1]->relationship,     'mother',       'Relationship is mother' );
is( ref( $gr[1]->guarantee ), 'Koha::Patron', 'Method guarantee returns a Koha::Patron' );
is( $gr[1]->guarantee->id,    $kylie->id,     'Koha::Patron returned is the correct guarantee' );
is( ref( $gr[1]->guarantor ), 'Koha::Patron', 'Method guarantor returns a Koha::Patron' );
is( $gr[1]->guarantor->id,    $chelsea->id,   'Koha::Patron returned is the correct guarantor' );

@gr = $daria->guarantor_relationships()->as_list;
is( @gr,                      2,              'Found 4 guarantor relationships for child' );
is( $gr[0]->guarantor_id,     $kyle->id,      'Guarantor matches for first relationship' );
is( $gr[0]->guarantee_id,     $daria->id,     'Guarantee matches for first relationship' );
is( $gr[0]->relationship,     'father',       'Relationship is father' );
is( ref( $gr[0]->guarantee ), 'Koha::Patron', 'Method guarantee returns a Koha::Patron' );
is( $gr[0]->guarantee->id,    $daria->id,     'Koha::Patron returned is the correct guarantee' );
is( ref( $gr[0]->guarantor ), 'Koha::Patron', 'Method guarantor returns a Koha::Patron' );
is( $gr[0]->guarantor->id,    $kyle->id,      'Koha::Patron returned is the correct guarantor' );

is( $gr[1]->guarantor_id,     $chelsea->id,   'Guarantor matches for first relationship' );
is( $gr[1]->guarantee_id,     $daria->id,     'Guarantee matches for first relationship' );
is( $gr[1]->relationship,     'mother',       'Relationship is mother' );
is( ref( $gr[1]->guarantee ), 'Koha::Patron', 'Method guarantee returns a Koha::Patron' );
is( $gr[1]->guarantee->id,    $daria->id,     'Koha::Patron returned is the correct guarantee' );
is( ref( $gr[1]->guarantor ), 'Koha::Patron', 'Method guarantor returns a Koha::Patron' );
is( $gr[1]->guarantor->id,    $chelsea->id,   'Koha::Patron returned is the correct guarantor' );

my $siblings = $daria->siblings;
my $sibling  = $siblings->next();
is( ref($siblings),      'Koha::Patrons', 'Calling siblings in scalar context results in a Koha::Patrons object' );
is( ref($sibling),       'Koha::Patron',  'Method next returns a Koha::Patron' );
is( $sibling->firstname, 'Kylie',         'Sibling from scalar first name matches correctly' );
is( $sibling->surname,   'Hall',          'Sibling from scalar surname matches correctly' );
is( $sibling->id,        $kylie->id,      'Sibling from scalar patron id matches correctly' );

$schema->storage->txn_rollback;
