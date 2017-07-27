package Koha::Acquisition::Basket;

use Modern::Perl;

use Koha::Database;

use base qw( Koha::Object );

sub bookseller {
    my ($self) = @_;
    my $bookseller_rs = $self->_result->booksellerid;
    return Koha::Acquisition::Bookseller->_new_from_dbic( $bookseller_rs );
}

sub _type {
    return 'Aqbasket';
}

1;
