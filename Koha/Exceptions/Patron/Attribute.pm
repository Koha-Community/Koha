package Koha::Exceptions::Patron::Attribute;

use Modern::Perl;

use Exception::Class (

    'Koha::Exceptions::Patron::Attribute' => {
        description => 'Something went wrong'
    },
    'Koha::Exceptions::Patron::Attribute::NonRepeatable' => {
        isa => 'Koha::Exceptions::Patron::Attribute',
        description => "repeatable not set for attribute type and tried to add a new attribute for the same code"
    },
    'Koha::Exceptions::Patron::Attribute::UniqueIDConstraint' => {
        isa => 'Koha::Exceptions::Patron::Attribute',
        description => "unique_id set for attribute type and tried to add a new with the same code and value"
    }
);

1;
