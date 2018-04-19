package Koha::Exceptions::Object;

use Modern::Perl;

use Koha::Exceptions::Exception;

use Exception::Class (
    'Koha::Exceptions::Object' => {
        isa         => 'Koha::Exceptions::Exception',
    },
    'Koha::Exceptions::Object::DuplicateID' => {
        isa         => 'Koha::Exceptions::Object',
        description => "Duplicate ID passed",
        fields      =>  ['duplicate_id']
    },
    'Koha::Exceptions::Object::FKConstraint' => {
        isa         => 'Koha::Exceptions::Object',
        description => "Foreign key constraint broken",
        fields      =>  ['broken_fk', 'value'],
    },
    'Koha::Exceptions::Object::MethodNotFound' => {
        isa => 'Koha::Exceptions::Object',
        description => "Invalid method",
    },
    'Koha::Exceptions::Object::PropertyNotFound' => {
        isa => 'Koha::Exceptions::Object',
        description => "Invalid property",
    },
    'Koha::Exceptions::Object::MethodNotCoveredByTests' => {
        isa => 'Koha::Exceptions::Object',
        description => "Method not covered by tests",
    },
);

1;
