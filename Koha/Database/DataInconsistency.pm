package Koha::Database::DataInconsistency;

use Modern::Perl;
use Koha::I18N qw( __x );

sub item_library {
    my ( $self, $items ) = @_;

    $items = $items->search( { -or => { homebranch => undef, holdingbranch => undef } } );
    my @errors;
    while ( my $item = $items->next ) {
        if ( not $item->homebranch and not $item->holdingbranch ) {
            push @errors,
                __x(
                "Item with itemnumber={itemnumber} does not have homebranch and holdingbranch defined",
                itemnumber => $item->itemnumber
                );
        } elsif ( not $item->homebranch ) {
            push @errors,
                __x(
                "Item with itemnumber={itemnumber} does not have homebranch defined",
                itemnumber => $item->itemnumber
                );
        } else {
            push @errors,
                __x(
                "Item with itemnumber={itemnumber} does not have holdingbranch defined",
                itemnumber => $item->itemnumber
                );
        }
    }
    return @errors;
}

sub for_biblio {
    my ( $self, $biblio ) = @_;
    my @errors;
    push @errors, $self->item_library( $biblio->items );
    return @errors;
}

1;
