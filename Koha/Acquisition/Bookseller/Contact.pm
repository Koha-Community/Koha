package Koha::Acquisition::Bookseller::Contact;

use Modern::Perl;

use base qw( Koha::Object );

use Carp qw( croak );

sub _type {
    return 'Aqcontact';
}

1;
