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
use C4::Members::AttributeTypes;
use Koha::Database;
use t::lib::TestBuilder;

use Test::More tests => 48;

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
C4::Context->_new_userenv('DUMMY SESSION');
C4::Context->set_userenv(123, 'userid', 'usercnum', 'First name', 'Surname', $library->{branchcode}, 'My Library', 0);
my $borrowernumber = $patron->{borrowernumber};

my $attribute_type1 = C4::Members::AttributeTypes->new('my code1', 'my description1');
$attribute_type1->unique_id(1);
$attribute_type1->store();

my $attribute_type2 = C4::Members::AttributeTypes->new('my code2', 'my description2');
$attribute_type2->opac_display(1);
$attribute_type2->staff_searchable(1);
$attribute_type2->store();

my $new_library = $builder->build( { source => 'Branch' } );
my $attribute_type_limited = C4::Members::AttributeTypes->new('my code3', 'my description3');
$attribute_type_limited->branches([ $new_library->{branchcode} ]);
$attribute_type_limited->store;

my $borrower_attributes = C4::Members::Attributes::GetBorrowerAttributes();
is( @$borrower_attributes, 0, 'GetBorrowerAttributes without the borrower number returns an empty array' );
$borrower_attributes = C4::Members::Attributes::GetBorrowerAttributes($borrowernumber);
is( @$borrower_attributes, 0, 'GetBorrowerAttributes returns the correct number of borrower attributes' );

my $attributes = [
    {
        value => 'my attribute1',
        code => $attribute_type1->code(),
    },
    {
        value => 'my attribute2',
        code => $attribute_type2->code(),
    },
    {
        value => 'my attribute limited',
        code => $attribute_type_limited->code(),
    }
];

my $set_borrower_attributes = C4::Members::Attributes::SetBorrowerAttributes();
$borrower_attributes = C4::Members::Attributes::GetBorrowerAttributes();
is( @$borrower_attributes, 0, 'SetBorrowerAttributes without arguments does not add borrower attributes' );

$set_borrower_attributes = C4::Members::Attributes::SetBorrowerAttributes($borrowernumber);
$borrower_attributes = C4::Members::Attributes::GetBorrowerAttributes();
is( @$borrower_attributes, 0, 'SetBorrowerAttributes without the attributes does not add borrower attributes' );

$set_borrower_attributes = C4::Members::Attributes::SetBorrowerAttributes($borrowernumber, $attributes);
is( $set_borrower_attributes, 1, 'SetBorrowerAttributes returns the success code' );
$borrower_attributes = C4::Members::Attributes::GetBorrowerAttributes();
is( @$borrower_attributes, 0, 'GetBorrowerAttributes without the borrower number returns an empty array' );
$borrower_attributes = C4::Members::Attributes::GetBorrowerAttributes($borrowernumber);
is( @$borrower_attributes, 3, 'GetBorrowerAttributes returns the correct number of borrower attributes' );
is( $borrower_attributes->[0]->{code}, $attributes->[0]->{code}, 'SetBorrowerAttributes stores the correct code correctly' );
is( $borrower_attributes->[0]->{description}, $attribute_type1->description(), 'SetBorrowerAttributes stores the field description correctly' );
is( $borrower_attributes->[0]->{value}, $attributes->[0]->{value}, 'SetBorrowerAttributes stores the field value correctly' );
is( $borrower_attributes->[1]->{code}, $attributes->[1]->{code}, 'SetBorrowerAttributes stores the field code correctly' );
is( $borrower_attributes->[1]->{description}, $attribute_type2->description(), 'SetBorrowerAttributes stores the field description correctly' );
is( $borrower_attributes->[1]->{value}, $attributes->[1]->{value}, 'SetBorrowerAttributes stores the field value correctly' );
$borrower_attributes = C4::Members::Attributes::GetBorrowerAttributes($borrowernumber);
is( @$borrower_attributes, 3, 'GetBorrowerAttributes returns the correct number of borrower attributes' );

$attributes = [
    {
        value => 'my attribute1',
        code => $attribute_type1->code(),
    },
    {
        value => 'my attribute2',
        code => $attribute_type2->code(),
    }
];
C4::Members::Attributes::SetBorrowerAttributes($borrowernumber, $attributes);
$borrower_attributes = C4::Members::Attributes::GetBorrowerAttributes($borrowernumber);
is( @$borrower_attributes, 3, 'SetBorrowerAttributes should not have removed the attributes limited to another branch' );

# TODO This is not implemented yet
#$borrower_attributes = C4::Members::Attributes::GetBorrowerAttributes($borrowernumber, undef, 'branch_limited');
#is( @$borrower_attributes, 2, 'GetBorrowerAttributes returns the correct number of borrower attributes filtered on library' );

my $attribute_value = C4::Members::Attributes::GetBorrowerAttributeValue();
is( $attribute_value, undef, 'GetBorrowerAttributeValue without arguments returns undef' );
$attribute_value = C4::Members::Attributes::GetBorrowerAttributeValue($borrowernumber);
is( $attribute_value, undef, 'GetBorrowerAttributeValue without the attribute code returns undef' );
$attribute_value = C4::Members::Attributes::GetBorrowerAttributeValue(undef, $attributes->[0]->{code});
is( $attribute_value, undef, 'GetBorrowerAttributeValue with a undef borrower number returns undef' );
$attribute_value = C4::Members::Attributes::GetBorrowerAttributeValue($borrowernumber, 'my invalid code');
is( $attribute_value, undef, 'GetBorrowerAttributeValue with an invalid code retuns undef' );

$attribute_value = C4::Members::Attributes::GetBorrowerAttributeValue($borrowernumber, $attributes->[0]->{code});
is( $attribute_value, $attributes->[0]->{value}, 'GetBorrowerAttributeValue returns the correct attribute value' );
$attribute_value = C4::Members::Attributes::GetBorrowerAttributeValue($borrowernumber, $attributes->[1]->{code});
is( $attribute_value, $attributes->[1]->{value}, 'GetBorrowerAttributeValue returns the correct attribute value' );


my $attribute = {
    attribute => 'my attribute3',
    code => $attribute_type1->code(),
};
C4::Members::Attributes::UpdateBorrowerAttribute($borrowernumber, $attribute);
$borrower_attributes = C4::Members::Attributes::GetBorrowerAttributes($borrowernumber);
is( @$borrower_attributes, 3, 'UpdateBorrowerAttribute does not change the number of borrower attributes' );
is( $borrower_attributes->[0]->{code}, $attribute->{code}, 'UpdateBorrowerAttribute updates the field code correctly' );
is( $borrower_attributes->[0]->{description}, $attribute_type1->description(), 'UpdateBorrowerAttribute updates the field description correctly' );
is( $borrower_attributes->[0]->{value}, $attribute->{attribute}, 'UpdateBorrowerAttribute updates the field value correctly' );


my $check_uniqueness = C4::Members::Attributes::CheckUniqueness();
is( $check_uniqueness, 0, 'CheckUniqueness without arguments returns false' );
$check_uniqueness = C4::Members::Attributes::CheckUniqueness($attribute->{code});
is( $check_uniqueness, 1, 'CheckUniqueness with a valid argument code returns true' );
$check_uniqueness = C4::Members::Attributes::CheckUniqueness(undef, $attribute->{attribute});
is( $check_uniqueness, 0, 'CheckUniqueness without the argument code returns false' );
$check_uniqueness = C4::Members::Attributes::CheckUniqueness('my invalid code');
is( $check_uniqueness, 0, 'CheckUniqueness with an invalid argument code returns false' );
$attribute_value = C4::Members::Attributes::GetBorrowerAttributeValue($borrowernumber, $attributes->[1]->{code});
$check_uniqueness = C4::Members::Attributes::CheckUniqueness('my invalid code', $attribute->{attribute});
is( $check_uniqueness, 0, 'CheckUniqueness with an invalid argument code returns fale' );
$check_uniqueness = C4::Members::Attributes::CheckUniqueness($attribute->{code}, 'new value');
is( $check_uniqueness, 1, 'CheckUniqueness with a new value returns true' );
$check_uniqueness = C4::Members::Attributes::CheckUniqueness('my invalid code', 'new value');
is( $check_uniqueness, 0, 'CheckUniqueness with an invalid argument code and a new value returns false' );
$check_uniqueness = C4::Members::Attributes::CheckUniqueness($attributes->[1]->{code}, $attributes->[1]->{value});
is( $check_uniqueness, 1, 'CheckUniqueness with an attribute unique_id=0 returns true' );
$check_uniqueness = C4::Members::Attributes::CheckUniqueness($attribute->{code}, $attribute->{attribute});
is( $check_uniqueness, '', 'CheckUniqueness returns false' );


my $borrower_numbers = C4::Members::Attributes::SearchIdMatchingAttribute('attribute1');
is( @$borrower_numbers, 0, 'SearchIdMatchingAttribute searchs only in attributes with staff_searchable=1' );
for my $attr( split(' ', $attributes->[1]->{value}) ) {
    $borrower_numbers = C4::Members::Attributes::SearchIdMatchingAttribute($attr);
    is( $borrower_numbers->[0], $borrowernumber, 'SearchIdMatchingAttribute returns the borrower numbers matching' );
}


C4::Members::Attributes::DeleteBorrowerAttribute();
$borrower_attributes = C4::Members::Attributes::GetBorrowerAttributes($borrowernumber);
is( @$borrower_attributes, 3, 'DeleteBorrowerAttribute without arguments deletes nothing' );
C4::Members::Attributes::DeleteBorrowerAttribute($borrowernumber);
$borrower_attributes = C4::Members::Attributes::GetBorrowerAttributes($borrowernumber);
is( @$borrower_attributes, 3, 'DeleteBorrowerAttribute without the attribute deletes nothing' );
C4::Members::Attributes::DeleteBorrowerAttribute(undef, $attribute);
$borrower_attributes = C4::Members::Attributes::GetBorrowerAttributes($borrowernumber);
is( @$borrower_attributes, 3, 'DeleteBorrowerAttribute with a undef borrower number deletes nothing' );

C4::Members::Attributes::DeleteBorrowerAttribute($borrowernumber, $attribute);
$borrower_attributes = C4::Members::Attributes::GetBorrowerAttributes($borrowernumber);
is( @$borrower_attributes, 2, 'DeleteBorrowerAttribute deletes a borrower attribute' );
is( $borrower_attributes->[0]->{code}, $attributes->[1]->{code}, 'DeleteBorrowerAttribute deletes the correct entry');
is( $borrower_attributes->[0]->{description}, $attribute_type2->description(), 'DeleteBorrowerAttribute deletes the correct entry');
is( $borrower_attributes->[0]->{value}, $attributes->[1]->{value}, 'DeleteBorrowerAttribute deletes the correct entry');

C4::Members::Attributes::DeleteBorrowerAttribute($borrowernumber, $attributes->[1]);
$borrower_attributes = C4::Members::Attributes::GetBorrowerAttributes($borrowernumber);
is( @$borrower_attributes, 1, 'DeleteBorrowerAttribute deletes a borrower attribute' );

# Regression tests for bug 16504
C4::Context->set_userenv(123, 'userid', 'usercnum', 'First name', 'Surname', $new_library->{branchcode}, 'My Library', 0);
my $another_patron = $builder->build(
    {   source => 'Borrower',
        value  => {
            firstname    => 'my another firstname',
            surname      => 'my another surname',
            branchcode => $new_library->{branchcode},
        }
    }
);
$attributes = [
    {
        value => 'my attribute1',
        code => $attribute_type1->code(),
    },
    {
        value => 'my attribute2',
        code => $attribute_type2->code(),
    },
    {
        value => 'my attribute limited',
        code => $attribute_type_limited->code(),
    }
];
C4::Members::Attributes::SetBorrowerAttributes($another_patron->{borrowernumber}, $attributes);
$borrower_attributes = C4::Members::Attributes::GetBorrowerAttributes($another_patron->{borrowernumber});
is( @$borrower_attributes, 3, 'SetBorrowerAttributes should have added the 3 attributes for another patron');
$borrower_attributes = C4::Members::Attributes::GetBorrowerAttributes($borrowernumber);
is( @$borrower_attributes, 1, 'SetBorrowerAttributes should not have removed the attributes of other patrons' );
