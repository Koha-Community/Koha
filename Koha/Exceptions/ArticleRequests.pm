package Koha::Exceptions::ArticleRequests;

use Modern::Perl;

use Exception::Class (

    'Koha::Exceptions::ArticleRequests' => {
        description => 'Something went wrong!',
    },
    'Koha::Exceptions::ArticleRequests::FailedCancel' => {
        isa => 'Koha::Exceptions::ArticleRequests',
        description => 'Failed to cancel article request'
    }

);

1;