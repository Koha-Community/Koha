package Koha::Acquisition::Bookseller::Contacts;

use Modern::Perl;

use base qw( Koha::Objects );

use Koha::Acquisition::Bookseller::Contact;

sub _type {
    return 'Aqcontact';
}

sub object_class {
    return 'Koha::Acquisition::Bookseller::Contact';
}

1;
