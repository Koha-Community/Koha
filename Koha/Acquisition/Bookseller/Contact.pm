package Koha::Acquisition::Bookseller::Contact;

use Modern::Perl;

use base qw( Koha::Object );

sub _type {
    return 'Aqcontact';
}

1;
