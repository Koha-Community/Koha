package Koha::Exceptions::Category;

use Modern::Perl;

use Exception::Class (

    'Koha::Exceptions::Category' => {
        description => 'Something went wrong!',
    },
    'Koha::Exceptions::Category::CategorycodeNotFound' => {
        isa => 'Koha::Exceptions::Category',
        description => "Category does not exist",
        fields => ["categorycode"],
    },
);

1;
