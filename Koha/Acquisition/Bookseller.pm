package Koha::Acquisition::Bookseller;

use Modern::Perl;

use Koha::Database;
use Koha::DateUtils qw( dt_from_string output_pref );

use Carp qw( croak );

use base qw( Class::Accessor );

use C4::Bookseller::Contact;

sub fetch {
    my ( $class, $params ) = @_;
    my $id = $params->{id};
    return unless $id;
    my $schema = Koha::Database->new->schema;

    my $bookseller =
      $schema->resultset('Aqbookseller')->find( { id => $id },
        { result_class => 'DBIx::Class::ResultClass::HashRefInflator' } );

    return unless $bookseller;

    my $self = $class->new( $bookseller );
    $self->contacts; # TODO: This should be generated on demand.
    return $self;
}

sub search {
    my ( $class, $params ) = @_;

    my $schema = Koha::Database->new->schema;

    my $search_params;
    while ( my ( $field, $value ) = each %$params ) {
        if ( $field eq 'name' ) {
            # Use "like" if search on name
            $search_params->{name} = { -like => "%$value%" };
        } else {
            $search_params->{$field} = $value;
        }
    }
    my $rs = $schema->resultset('Aqbookseller')->search(
        $search_params,
        { order_by => 'name' }
    );

    my @booksellers;
    while ( my $b = $rs->next ) {
        my $t = Koha::Acquisition::Bookseller->fetch({ id => $b->id });
        push @booksellers, $t;
    }
    return @booksellers;
}

sub basket_count {
    my ( $self ) = @_;
    my $schema = Koha::Database->new->schema;

    return $schema->resultset('Aqbasket')->count( { booksellerid => $self->{id} });
}

sub subscription_count {
    my ( $self ) = @_;

    my $schema = Koha::Database->new->schema;

    return $schema->resultset('Subscription')->count( { aqbooksellerid => $self->{id} });
}

sub contacts {
    my ( $self ) = @_;

    return $self->{contacts} if $self->{contacts};
    $self->{contacts} = C4::Bookseller::Contact->get_from_bookseller($self->{id});
    return $self->{contacts};
}

sub insert {
    my ($self) = @_;

    # if these parameters are missing, we can't continue
    for my $key (qw( id )) {
        croak "Cannot insert bookseller: Mandatory parameter $key is missing"
          unless $self->{$key};
    }

    $self->{quantityreceived} ||= 0;
    $self->{entrydate} ||=
      output_pref( { dt => dt_from_string, dateformat => 'iso' } );

    my $schema  = Koha::Database->new->schema;
    my @columns = $schema->source('Aqorder')->columns;
    my $rs = $schema->resultset('Aqorder')->create(
        {
            map {
                exists $self->{$_} ? ( $_ => $self->{$_} ) : ()
            } @columns
        }
    );
    $self->{ordernumber} = $rs->id;

    unless ( $self->{parent_ordernumber} ) {
        $rs->update( { parent_ordernumber => $self->{ordernumber} } );
    }

    return $self;
}

# TODO Move code from ModBookseller
sub update {
    die "not implemented yet";
}

# TODO Move code from DelBookseller
sub delete {
    die "not implemented yet";
}

1;
