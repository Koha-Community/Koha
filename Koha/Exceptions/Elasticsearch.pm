package Koha::Exceptions::Elasticsearch;

use Modern::Perl;

use Exception::Class (

    'Koha::Exceptions::Elasticsearch' => {
        description => 'Something went wrong!',
    },
    'Koha::Exceptions::Elasticsearch::MARCFieldExprParseError' => {
        isa => 'Koha::Exceptions::Elasticsearch',
        description => 'Parse error while processing MARC field expression in mapping',
    }

);

1;
