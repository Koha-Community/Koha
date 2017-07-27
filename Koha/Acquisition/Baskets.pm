package Koha::Acquisition::Baskets;

use Modern::Perl;

use Koha::Database;
use Koha::Acquisition::Basket;

use base qw( Koha::Objects );

sub _type {
    return 'Aqbasket';
}

sub object_class {
    return 'Koha::Acquisition::Basket';
}

1;
