package Koha::Acquisition::Bookseller;

use Modern::Perl;

use Koha::Database;
use base qw( Koha::Object );

use Koha::DateUtils qw( dt_from_string output_pref );

use Koha::Acquisition::Bookseller::Contacts;
use Koha::Subscriptions;

sub baskets {
    my ( $self ) = @_;
    return $self->{_result}->aqbaskets;
}

sub contacts {
    my ($self) = @_;
    return Koha::Acquisition::Bookseller::Contacts->search( { booksellerid => $self->id } );
}

sub subscriptions {
    my ($self) = @_;

    return Koha::Subscriptions->search( { aqbooksellerid => $self->id } );
}

sub _type {
    return 'Aqbookseller';
}

1;
