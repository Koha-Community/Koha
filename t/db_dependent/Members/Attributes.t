#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2014  Biblibre SARL
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

use C4::Context;
use C4::Members;
use Koha::Database;
use t::lib::TestBuilder;
use t::lib::Mocks;

use Test::Exception;
use Test::More tests => 33;

use_ok('C4::Members::Attributes');

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;
my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;

$dbh->do(q|DELETE FROM issues|);
$dbh->do(q|DELETE FROM borrowers|);
$dbh->do(q|DELETE FROM borrower_attributes|);
$dbh->do(q|DELETE FROM borrower_attribute_types|);
my $library = $builder->build({
    source => 'Branch',
});

my $patron = $builder->build(
    {   source => 'Borrower',
        value  => {
            firstname    => 'my firstname',
            surname      => 'my surname',
            branchcode => $library->{branchcode},
        }
    }
);
t::lib::Mocks::mock_userenv({ branchcode => $library->{branchcode} });
my $borrowernumber = $patron->{borrowernumber};

my $attribute_type1 = Koha::Patron::Attribute::Type->new(
    {
        code        => 'my code1',
        description => 'my description1',
        unique_id   => 1
    }
)->store;
my $attribute_type2 = Koha::Patron::Attribute::Type->new(
    {
        code             => 'my code2',
        description      => 'my description2',
        opac_display     => 1,
        staff_searchable => 1
    }
)->store;

my $new_library = $builder->build( { source => 'Branch' } );
my $attribute_type_limited = Koha::Patron::Attribute::Type->new(
    { code => 'my code3', description => 'my description3' } )->store;
$attribute_type_limited->library_limits( [ $new_library->{branchcode} ] );

$patron = Koha::Patrons->find($borrowernumber);
my $borrower_attributes = $patron->extended_attributes;
is( $borrower_attributes->count, 0, 'extended_attributes returns the correct number of borrower attributes' );

my $attributes = [
    {
        attribute => 'my attribute1',
        code => $attribute_type1->code(),
    },
    {
        attribute => 'my attribute2',
        code => $attribute_type2->code(),
    },
    {
        attribute => 'my attribute limited',
        code => $attribute_type_limited->code(),
    }
];

$patron->extended_attributes->filter_by_branch_limitations->delete;
my $set_borrower_attributes = $patron->extended_attributes($attributes);
is( ref($set_borrower_attributes), 'Koha::Patron::Attributes', '');
is( $set_borrower_attributes->count, 3, '');
$borrower_attributes = $patron->extended_attributes;
is( $borrower_attributes->count, 3, 'extended_attributes returns the correct number of borrower attributes' );
my $attr_0 = $borrower_attributes->next;
is( $attr_0->code, $attributes->[0]->{code}, 'setter for extended_attributes sestores the correct code correctly' );
is( $attr_0->type->description, $attribute_type1->description(), 'setter for extended_attributes stores the field description correctly' );
is( $attr_0->attribute, $attributes->[0]->{attribute}, 'setter for extended_attributes stores the field value correctly' );
my $attr_1 = $borrower_attributes->next;
is( $attr_1->code, $attributes->[1]->{code}, 'setter for extended_attributes stores the field code correctly' );
is( $attr_1->type->description, $attribute_type2->description(), 'setter for extended_attributes stores the field description correctly' );
is( $attr_1->attribute, $attributes->[1]->{attribute}, 'setter for extended_attributes stores the field value correctly' );

$attributes = [
    {
        attribute => 'my attribute1',
        code => $attribute_type1->code(),
    },
    {
        attribute => 'my attribute2',
        code => $attribute_type2->code(),
    }
];
$patron->extended_attributes->filter_by_branch_limitations->delete;
$patron->extended_attributes($attributes);
$borrower_attributes = $patron->extended_attributes;
is( $borrower_attributes->count, 3, 'setter for extended_attributes should not have removed the attributes limited to another branch' );

# TODO This is not implemented yet
#$borrower_attributes = C4::Members::Attributes::GetBorrowerAttributes($borrowernumber, undef, 'branch_limited');
#is( @$borrower_attributes, 2, 'GetBorrowerAttributes returns the correct number of borrower attributes filtered on library' );

$patron = Koha::Patrons->find($borrowernumber);
my $extended_attributes = $patron->extended_attributes;
my $attribute_value = $extended_attributes->search({ code => 'my invalid code' });
is( $attribute_value->count, 0, 'non existent attribute should return empty result set');
$attribute_value = $patron->get_extended_attribute('my invalid code');
is( $attribute_value, undef, 'non existent attribute should undef');

$attribute_value = $patron->get_extended_attribute($attributes->[0]->{code});
is( $attribute_value->attribute, $attributes->[0]->{attribute}, 'get_extended_attribute returns the correct attribute value' );
$attribute_value = $patron->get_extended_attribute($attributes->[1]->{code});
is( $attribute_value->attribute, $attributes->[1]->{attribute}, 'get_extended_attribute returns the correct attribute value' );


my $attribute = {
    attribute => 'my attribute3',
    code => $attribute_type1->code(),
};
$patron->extended_attributes->search({'me.code' => $attribute->{code}})->filter_by_branch_limitations->delete;
$patron->add_extended_attribute($attribute);
$borrower_attributes = $patron->extended_attributes;
is( $borrower_attributes->count, 3, 'delete then add a new attribute does not change the number of borrower attributes' );
$attr_0 = $borrower_attributes->next;
is( $attr_0->code, $attribute->{code}, 'delete then add a new attribute updates the field code correctly' );
is( $attr_0->type->description, $attribute_type1->description(), 'delete then add a new attribute updates the field description correctly' );
is( $attr_0->attribute, $attribute->{attribute}, 'delete then add a new attribute updates the field value correctly' );


lives_ok { # Editing, new value, same patron
    Koha::Patron::Attribute->new(
        {
            code           => $attribute->{code},
            attribute      => 'new value',
            borrowernumber => $patron->borrowernumber
        }
    )->check_unique_id;
} 'no exception raised';
lives_ok { # Editing, same value, same patron
    Koha::Patron::Attribute->new(
        {
            code           => $attributes->[1]->{code},
            attribute      => $attributes->[1]->{attribute},
            borrowernumber => $patron->borrowernumber
        }
    )->check_unique_id;
} 'no exception raised';
throws_ok { # Creating a new one, but already exists!
    Koha::Patron::Attribute->new(
        { code => $attribute->{code}, attribute => $attribute->{attribute} } )
      ->check_unique_id;
} 'Koha::Exceptions::Patron::Attribute::UniqueIDConstraint';


my $borrower_numbers = C4::Members::Attributes::SearchIdMatchingAttribute('attribute1');
is( @$borrower_numbers, 0, 'SearchIdMatchingAttribute searchs only in attributes with staff_searchable=1' );
for my $attr( split(' ', $attributes->[1]->{attribute}) ) {
    $borrower_numbers = C4::Members::Attributes::SearchIdMatchingAttribute($attr);
    is( $borrower_numbers->[0], $borrowernumber, 'SearchIdMatchingAttribute returns the borrower numbers matching' );
}


$patron->get_extended_attribute($attribute->{code})->delete;
$borrower_attributes = $patron->extended_attributes;
is( $borrower_attributes->count, 2, 'delete attribute by code' );
$attr_0 = $borrower_attributes->next;
is( $attr_0->code, $attributes->[1]->{code}, 'delete attribute by code');
is( $attr_0->type->description, $attribute_type2->description(), 'delete attribute by code');
is( $attr_0->attribute, $attributes->[1]->{attribute}, 'delete attribute by code');

$patron->get_extended_attribute($attributes->[1]->{code})->delete;
$borrower_attributes = $patron->extended_attributes;
is( $borrower_attributes->count, 1, 'delete attribute by code' );

# Regression tests for bug 16504
t::lib::Mocks::mock_userenv({ branchcode => $new_library->{branchcode} });
my $another_patron = $builder->build_object(
    {   class  => 'Koha::Patrons',
        value  => {
            firstname    => 'my another firstname',
            surname      => 'my another surname',
            branchcode => $new_library->{branchcode},
        }
    }
);
$attributes = [
    {
        attribute => 'my attribute1',
        code => $attribute_type1->code(),
    },
    {
        attribute => 'my attribute2',
        code => $attribute_type2->code(),
    },
    {
        attribute => 'my attribute limited',
        code => $attribute_type_limited->code(),
    }
];

$another_patron->extended_attributes->filter_by_branch_limitations->delete;
$another_patron->extended_attributes($attributes);
$borrower_attributes = $another_patron->extended_attributes;
is( $borrower_attributes->count, 3, 'setter for extended_attributes should have added the 3 attributes for another patron');
$borrower_attributes = $patron->extended_attributes;
is( $borrower_attributes->count, 1, 'setter for extended_attributes should not have removed the attributes of other patrons' );
