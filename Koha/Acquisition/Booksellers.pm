package Koha::Acquisition::Booksellers;

use Modern::Perl;

use Carp;

use Koha::Database;

use base qw( Koha::Objects );

use Koha::Acquisition::Bookseller;

sub search {
    my ( $self, $params, $attributes ) = @_;


    while ( my ( $field, $value ) = each %$params ) {
        if ( $field eq 'name' ) {
            # Use "like" if search on name
            $params->{name} = { -like => "%$value%" };
        }
    }

    $attributes->{order_by} ||= { -asc => 'name' };

    return $self->SUPER::search( $params, $attributes );
}

sub _type {
    return 'Aqbookseller';
}

sub object_class {
    return 'Koha::Acquisition::Bookseller';
}

1;
