package Koha::Exceptions::ArticleRequest;

use Modern::Perl;

use Exception::Class (

    'Koha::Exceptions::ArticleRequest' => {
        description => 'Something went wrong!',
    },
    'Koha::Exceptions::ArticleRequest::NotAllowed' => {
        isa => 'Koha::Exceptions::ArticleRequest',
        description => "Article request is not allowed.",
    },
    'Koha::Exceptions::ArticleRequest::BibLevelRequestNotAllowed' => {
        isa => 'Koha::Exceptions::ArticleRequest',
        description => "Bib level article request is not allowed.",
    },
    'Koha::Exceptions::ArticleRequest::ItemLevelRequestNotAllowed' => {
        isa => 'Koha::Exceptions::ArticleRequest',
        description => "Item level article request is not allowed.",
    }
);

1;
