#
# status of a Hold transaction

package C4::SIP::ILS::Transaction::Hold;

use Modern::Perl;

use C4::SIP::ILS::Transaction;

use C4::Reserves qw( CalculatePriority AddReserve ModReserve CanItemBeReserved );
use Koha::Holds;
use Koha::Patrons;
use Koha::Items;

use parent qw(C4::SIP::ILS::Transaction);

my %fields = (
    expiration_date => 0,
    pickup_location => undef,
    constraint_type => undef,
);

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new();
    foreach my $element ( keys %fields ) {
        $self->{_permitted}->{$element} = $fields{$element};
    }
    @{$self}{ keys %fields } = values %fields;
    return bless $self, $class;
}

sub queue_position {
    my $self = shift;
    return $self->item->hold_queue_position( $self->patron->id );
}

sub do_hold {
    my $self   = shift;
    my $patron = Koha::Patrons->find( $self->{patron}->borrowernumber );
    unless ($patron) {
        $self->screen_msg('do_hold called with undefined patron');
        $self->ok(0);
        return $self;
    }
    my $item = Koha::Items->find( { barcode => $self->{item}->id } );
    unless ($item) {
        $self->screen_msg( 'No biblio record matches barcode "' . $self->{item}->id . '".' );
        $self->ok(0);
        return $self;
    }
    my $branch = ( $self->pickup_location || $self->{patron}->{branchcode} );
    unless ($branch) {
        $self->screen_msg('No branch specified (or found w/ patron).');
        $self->ok(0);
        return $self;
    }
    unless ( $item->can_be_transferred( { to => Koha::Libraries->find($branch) } ) ) {
        $self->screen_msg('Item cannot be transferred.');
        $self->ok(0);
        return $self;
    }

    my $canReserve = CanItemBeReserved( $patron, $item, $branch );
    if ( $canReserve->{status} eq 'OK' ) {
        my $priority = C4::Reserves::CalculatePriority( $item->biblionumber );
        AddReserve(
            {
                priority       => $priority,
                branchcode     => $branch,
                borrowernumber => $patron->borrowernumber,
                biblionumber   => $item->biblionumber
            }
        );

        $self->ok(1);
    } else {
        $self->ok(0);
    }

    return $self;
}

sub drop_hold {
    my $self   = shift;
    my $patron = Koha::Patrons->find( $self->{patron}->borrowernumber );
    unless ($patron) {
        $self->screen_msg('drop_hold called with undefined patron');
        $self->ok(0);
        return $self;
    }

    my $item  = Koha::Items->find( { barcode => $self->{item}->id } );
    my $holds = $item->holds->search( { borrowernumber => $patron->borrowernumber } );

    return $self unless $holds->count;
    my $hold = $holds->next;

    if ( C4::Context->preference('HoldCancellationRequestSIP') ) {
        $hold->add_cancellation_request;
    } else {
        $hold->cancel;
    }

    $self->ok(1);
    return $self;
}

sub change_hold {
    my $self   = shift;
    my $patron = Koha::Patrons->find( $self->{patron}->borrowernumber );
    unless ($patron) {
        $self->screen_msg('change_hold called with undefined patron');
        $self->ok(0);
        return $self;
    }
    my $item = Koha::Items->find( { barcode => $self->{item}->id } );
    unless ($item) {
        $self->screen_msg( 'No biblio record matches barcode "' . $self->{item}->id . '".' );
        $self->ok(0);
        return $self;
    }
    my $branch = ( $self->pickup_location || $self->{patron}->branchcode );
    unless ($branch) {
        $self->screen_msg('No branch specified (or found w/ patron).');
        $self->ok(0);
        return $self;
    }
    ModReserve(
        { biblionumber => $item->biblionumber, borrowernumber => $patron->borrowernumber, branchcode => $branch } );

    $self->ok(1);
    return $self;
}

1;
__END__
