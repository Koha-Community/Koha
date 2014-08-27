package Koha::Acquisition::Order;

use Modern::Perl;

use Koha::Database;
use Koha::DateUtils qw( dt_from_string output_pref );

use Carp qw( croak );

use base qw( Class::Accessor );

# TODO fetch order from itemnumber (GetOrderFromItemnnumber)
# TODO Move code from GetOrder
sub fetch {
    my ( $class, $params ) = @_;
    my $ordernumber = $params->{ordernumber};
    return unless $ordernumber;
    my $schema = Koha::Database->new->schema;

    my $rs =
      $schema->resultset('Aqorder')->search( { ordernumber => $ordernumber },
        { result_class => 'DBIx::Class::ResultClass::HashRefInflator' } );

    return $class->new( $rs->first );
}

sub insert {
    my ($self) = @_;

    # if these parameters are missing, we can't continue
    for my $key (qw( basketno quantity biblionumber budget_id )) {
        croak "Cannot insert order: Mandatory parameter $key is missing"
          unless $self->{$key};
    }

    $self->{quantityreceived} ||= 0;
    $self->{entrydate} ||=
      output_pref( { dt => dt_from_string, dateformat => 'iso' } );

    my $schema  = Koha::Database->new->schema;
    my @columns = $schema->source('Aqorder')->columns;

    $self->{ordernumber} ||= undef;

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

sub add_item {
    my ( $self, $itemnumber )  = @_;
    my $schema = Koha::Database->new->schema;
    my $rs = $schema->resultset('AqordersItem');
    $rs->create({ ordernumber => $self->{ordernumber}, itemnumber => $itemnumber });
}

# TODO Move code from ModItemOrder
sub update_item {
    die "not implemented yet";
}

sub del_item {
    die "not implemented yet";
}

# TODO Move code from ModOrder
sub update {
    die "not implemented yet";
}

# TODO Move code from DelOrder
sub delete {
    die "not implemented yet";
}

# TODO Move code from TransferOrder
sub transfer {
    die "not implemented yet";
}

1;
