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

use Test::More tests => 59;

use C4::Context;

use t::lib::TestBuilder;

BEGIN {
    use_ok('Koha::Objects');
    use_ok('Koha::Patrons');
    use_ok('Koha::Patron::Relationship');
    use_ok('Koha::Patron::Relationships');
}

# Start transaction
my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

my $builder = t::lib::TestBuilder->new();

# Father
my $kyle = Koha::Patrons->find(
    $builder->build(
        {
            source => 'Borrower',
            value  => {
                firstname => 'Kyle',
                surname   => 'Hall',
            }
        }
    )->{borrowernumber}
);

# Mother
my $chelsea = Koha::Patrons->find(
    $builder->build(
        {
            source => 'Borrower',
            value  => {
                firstname => 'Chelsea',
                surname   => 'Hall',
            }
        }
    )->{borrowernumber}
);

# Children
my $daria = Koha::Patrons->find(
    $builder->build(
        {
            source => 'Borrower',
            value  => {
                firstname => 'Daria',
                surname   => 'Hall',
            }
        }
    )->{borrowernumber}
);

my $kylie = Koha::Patrons->find(
    $builder->build(
        {
            source => 'Borrower',
            value  => {
                firstname => 'Kylie',
                surname   => 'Hall',
            }
        }
    )->{borrowernumber}
);

Koha::Patron::Relationship->new({ guarantor_id => $kyle->id, guarantee_id => $daria->id, relationship => 'father' })->store();
Koha::Patron::Relationship->new({ guarantor_id => $kyle->id, guarantee_id => $kylie->id, relationship => 'father' })->store();
Koha::Patron::Relationship->new({ guarantor_id => $chelsea->id, guarantee_id => $daria->id, relationship => 'mother' })->store();
Koha::Patron::Relationship->new({ guarantor_id => $chelsea->id, guarantee_id => $kylie->id, relationship => 'mother' })->store();

my @gr;

@gr = $kyle->guarantee_relationships();
is( @gr, 2, 'Found 2 guarantee relationships for father' );
is( $gr[0]->guarantor_id, $kyle->id, 'Guarantor matches for first relationship' );
is( $gr[0]->guarantee_id, $daria->id, 'Guarantee matches for first relationship' );
is( $gr[0]->relationship, 'father', 'Relationship is father' );
is( ref($gr[0]->guarantee), 'Koha::Patron', 'Method guarantee returns a Koha::Patron' );
is( $gr[0]->guarantee->id, $daria->id, 'Koha::Patron returned is the correct guarantee' );
is( ref($gr[0]->guarantor), 'Koha::Patron', 'Method guarantor returns a Koha::Patron' );
is( $gr[0]->guarantor->id, $kyle->id, 'Koha::Patron returned is the correct guarantor' );

is( $gr[1]->guarantor_id, $kyle->id, 'Guarantor matches for first relationship' );
is( $gr[1]->guarantee_id, $kylie->id, 'Guarantee matches for first relationship' );
is( $gr[1]->relationship, 'father', 'Relationship is father' );
is( ref($gr[1]->guarantee), 'Koha::Patron', 'Method guarantee returns a Koha::Patron' );
is( $gr[1]->guarantee->id, $kylie->id, 'Koha::Patron returned is the correct guarantee' );
is( ref($gr[1]->guarantor), 'Koha::Patron', 'Method guarantor returns a Koha::Patron' );
is( $gr[1]->guarantor->id, $kyle->id, 'Koha::Patron returned is the correct guarantor' );

@gr = $chelsea->guarantee_relationships();
is( @gr, 2, 'Found 2 guarantee relationships for mother' );
is( $gr[0]->guarantor_id, $chelsea->id, 'Guarantor matches for first relationship' );
is( $gr[0]->guarantee_id, $daria->id, 'Guarantee matches for first relationship' );
is( $gr[0]->relationship, 'mother', 'Relationship is mother' );
is( ref($gr[0]->guarantee), 'Koha::Patron', 'Method guarantee returns a Koha::Patron' );
is( $gr[0]->guarantee->id, $daria->id, 'Koha::Patron returned is the correct guarantee' );
is( ref($gr[0]->guarantor), 'Koha::Patron', 'Method guarantor returns a Koha::Patron' );
is( $gr[0]->guarantor->id, $chelsea->id, 'Koha::Patron returned is the correct guarantor' );

is( $gr[1]->guarantor_id, $chelsea->id, 'Guarantor matches for first relationship' );
is( $gr[1]->guarantee_id, $kylie->id, 'Guarantee matches for first relationship' );
is( $gr[1]->relationship, 'mother', 'Relationship is mother' );
is( ref($gr[1]->guarantee), 'Koha::Patron', 'Method guarantee returns a Koha::Patron' );
is( $gr[1]->guarantee->id, $kylie->id, 'Koha::Patron returned is the correct guarantee' );
is( ref($gr[1]->guarantor), 'Koha::Patron', 'Method guarantor returns a Koha::Patron' );
is( $gr[1]->guarantor->id, $chelsea->id, 'Koha::Patron returned is the correct guarantor' );

@gr = $daria->guarantor_relationships();
is( @gr, 2, 'Found 4 guarantor relationships for child' );
is( $gr[0]->guarantor_id, $kyle->id, 'Guarantor matches for first relationship' );
is( $gr[0]->guarantee_id, $daria->id, 'Guarantee matches for first relationship' );
is( $gr[0]->relationship, 'father', 'Relationship is father' );
is( ref($gr[0]->guarantee), 'Koha::Patron', 'Method guarantee returns a Koha::Patron' );
is( $gr[0]->guarantee->id, $daria->id, 'Koha::Patron returned is the correct guarantee' );
is( ref($gr[0]->guarantor), 'Koha::Patron', 'Method guarantor returns a Koha::Patron' );
is( $gr[0]->guarantor->id, $kyle->id, 'Koha::Patron returned is the correct guarantor' );

is( $gr[1]->guarantor_id, $chelsea->id, 'Guarantor matches for first relationship' );
is( $gr[1]->guarantee_id, $daria->id, 'Guarantee matches for first relationship' );
is( $gr[1]->relationship, 'mother', 'Relationship is mother' );
is( ref($gr[1]->guarantee), 'Koha::Patron', 'Method guarantee returns a Koha::Patron' );
is( $gr[1]->guarantee->id, $daria->id, 'Koha::Patron returned is the correct guarantee' );
is( ref($gr[1]->guarantor), 'Koha::Patron', 'Method guarantor returns a Koha::Patron' );
is( $gr[1]->guarantor->id, $chelsea->id, 'Koha::Patron returned is the correct guarantor' );

my @siblings = $daria->siblings;
is( @siblings, 1, 'Method siblings called in list context returns list' );
is( ref($siblings[0]), 'Koha::Patron', 'List contains a Koha::Patron' );
is( $siblings[0]->firstname, 'Kylie', 'Sibling from list first name matches correctly' );
is( $siblings[0]->surname, 'Hall', 'Sibling from list surname matches correctly' );
is( $siblings[0]->id, $kylie->id, 'Sibling from list patron id matches correctly' );

my $siblings = $daria->siblings;
my $sibling = $siblings->next();
is( ref($siblings), 'Koha::Patrons', 'Calling siblings in scalar context results in a Koha::Patrons object' );
is( ref($sibling), 'Koha::Patron', 'Method next returns a Koha::Patron' );
is( $sibling->firstname, 'Kylie', 'Sibling from scalar first name matches correctly' );
is( $sibling->surname, 'Hall', 'Sibling from scalar surname matches correctly' );
is( $sibling->id, $kylie->id, 'Sibling from scalar patron id matches correctly' );

1;
