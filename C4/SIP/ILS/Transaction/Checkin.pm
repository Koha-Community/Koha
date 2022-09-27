
# An object to handle checkin status
#

package C4::SIP::ILS::Transaction::Checkin;

use warnings;
use strict;

# use POSIX qw(strftime);

use C4::SIP::ILS::Transaction;

use C4::Circulation qw( AddReturn LostItem );
use C4::Items qw( ModItemTransfer );
use C4::Reserves qw( ModReserve ModReserveAffect CheckReserves );
use Koha::DateUtils qw( dt_from_string );
use Koha::Items;

use parent qw(C4::SIP::ILS::Transaction);

my %fields = (
    magnetic => 0,
    sort_bin => undef,
    collection_code  => undef,
    # 3M extensions:
    call_number      => undef,
    destination_loc  => undef,
    alert_type       => undef,  # 00,01,02,03,04 or 99
    hold_patron_id   => undef,
    hold_patron_name => "",
    hold             => undef,
);

sub new {
    my $class = shift;
    my $self = $class->SUPER::new();                # start with an ILS::Transaction object

    foreach (keys %fields) {
        $self->{_permitted}->{$_} = $fields{$_};    # overlaying _permitted
    }

    @{$self}{keys %fields} = values %fields;        # copying defaults into object
    return bless $self, $class;
}

sub do_checkin {
    my $self = shift;
    my $branch = shift;
    my $return_date = shift;
    my $account = shift;

    my $checked_in_ok       = $account->{checked_in_ok};
    my $cv_triggers_alert   = $account->{cv_triggers_alert};
    my $holds_block_checkin = $account->{holds_block_checkin};
    my $holds_get_captured  = $account->{holds_get_captured} // 1;

    if (!$branch) {
        $branch = 'SIP2';
    }
    my $barcode = $self->{item}->id;

    if ( $return_date ) {
        $return_date =   substr( $return_date, 0, 4 )
                       . '-'
                       . substr( $return_date, 4, 2 )
                       . '-'
                       . substr( $return_date, 6, 2 )
                       . q{ }
                       . substr( $return_date, 12, 2 )
                       . ':'
                       . substr( $return_date, 14, 2 )
                       . ':'
                       . substr( $return_date, 16, 2 );
        $return_date = dt_from_string($return_date);
    }

    my ( $return, $messages, $issue, $borrower );

    my $item = Koha::Items->find( { barcode => $barcode } );

    my $human_required = 0;
    if (   C4::Context->preference("CircConfirmItemParts")
        && defined($item)
        && $item->materials )
    {
        $human_required                   = 1;
        $messages->{additional_materials} = 1;
    }

    my $reserved;
    my $lookahead = C4::Context->preference('ConfirmFutureHolds'); #number of days to look for future holds
    my ($resfound) = $item->withdrawn ? q{} : CheckReserves( $item, $lookahead );
    if ( $resfound eq "Reserved") {
        $reserved = 1;
    }

    my $checkin_blocked_by_holds = $holds_block_checkin && $reserved;

    ( $return, $messages, $issue, $borrower ) =
      AddReturn( $barcode, $branch, undef, $return_date )
      unless $human_required || $checkin_blocked_by_holds;

    if ( $checked_in_ok ) {
        delete $messages->{ItemLocationUpdated};
        delete $messages->{NotIssued};
        delete $messages->{LocalUse};
        $return = 1 unless keys %$messages;
    }

    # biblionumber, biblioitemnumber, itemnumber
    # borrowernumber, reservedate, branchcode
    # cancellationdate, found, reservenotes, priority, timestamp
    if ($messages->{additional_materials}) {
        $self->alert_type('99');
    }
    if( $messages->{DataCorrupted} ) {
        $self->alert_type('98');
    }
    if ($messages->{BadBarcode}) {
        $self->alert_type('99');
    }
    if ($messages->{withdrawn}) {
        $self->alert_type('99');
    }
    if ($messages->{WasLost}) {
        $self->alert_type('99') if C4::Context->preference("BlockReturnOfLostItems");
    }
    if ($messages->{Wrongbranch}) {
        $self->{item}->destination_loc($messages->{Wrongbranch}->{Rightbranch});
        $self->alert_type('04');            # send to other branch
    }
    if ($messages->{WrongTransfer}) {
        $self->{item}->destination_loc($messages->{WrongTransfer});
        $self->alert_type('04');            # send to other branch
    }
    if ($messages->{NeedsTransfer}) {
        $self->{item}->destination_loc($messages->{NeedsTransfer});
        $self->alert_type('04');            # send to other branch
    }
    if ($messages->{WasTransfered}) { # set into transit so tell unit
        $self->{item}->destination_loc($item->homebranch);
        $self->alert_type('04');            # send to other branch
    }
    if ($messages->{ResFound} || $checkin_blocked_by_holds ) {
        if ($checkin_blocked_by_holds) {
            $self->alert_type('99');
            $return = 0;
        } elsif ($branch eq $messages->{ResFound}->{branchcode}) {
            $self->hold($messages->{ResFound});
            $self->alert_type('01');
            ModReserveAffect(
                $messages->{ResFound}->{itemnumber},
                $messages->{ResFound}->{borrowernumber},
                0, $messages->{ResFound}->{reserve_id}
            ) if $holds_get_captured;

        } else {
            $self->hold($messages->{ResFound});
            $self->alert_type('02');
            if ($holds_get_captured) {
                ModReserveAffect( $item->itemnumber,
                    $messages->{ResFound}->{borrowernumber},
                    1, $messages->{ResFound}->{reserve_id} );
                ModItemTransfer( $item->itemnumber, $branch,
                    $messages->{ResFound}->{branchcode}, 'Reserve', );
            }
        }
        $self->{item}->hold_patron_id( $messages->{ResFound}->{borrowernumber} );
        $self->{item}->destination_loc( $messages->{ResFound}->{branchcode} );
    }
    # ignoring messages: NotIssued, WasTransfered

    if ($cv_triggers_alert) {
        $self->alert( defined $self->alert_type ); # Overwrites existing alert value, should set to 0 if there is no alert type
    }
    else {
        $self->alert( !$return || defined $self->alert_type );
    }

    # Set sort bin based on info in the item associated with the issue, and the
    # mapping from SIP2SortBinMapping
    $self->sort_bin( _get_sort_bin( $item, $branch, $account ) );

    $self->ok($return);

    return { messages => $messages };
}

sub resensitize {
	my $self = shift;
	unless ($self->{item}) {
		warn "resensitize(): no item found in object to resensitize";
		return;
	}
	return !$self->{item}->magnetic_media;
}

sub patron_id {
	my $self = shift;
	unless ($self->{patron}) {
		warn "patron_id(): no patron found in object";
		return;
	}
	return $self->{patron}->id;
}

=head1 _get_sort_bin

Takes a Koha::Item object and the return branch branchcode as arguments.

Uses the contents of the SIP2SortBinMapping syspref to determine the sort_bin
value that should be returned for an item checked in via SIP2.

The mapping should be:

 <branchcode>:<item field>:<comparator>:<item field value>:<sort bin number>

For example:

 CPL:itype:eq:BOOK:1
 CPL:location:eq:OFFICE:2
 CPL:classmark:<:339.6:3

This will give:

=over 4

=item * sort_bin = "1" for items at the CPL branch with an itemtype of BOOK

=item * sort_bin = "2" for items at the CPL branch with a location of OFFICE

=item * sort_bin = "3" for items at the CPL branch with a classmark less than 339.6

=back

Returns the ID of the appropriate sort_bin, if there is one, or undef.

=cut

sub _get_sort_bin {

    # We should get an item represented as a hashref here
    my ( $item, $branch, $account ) = @_;
    return unless $item;

    my @lines;
    # Mapping in SIP config takes precedence over syspref
    if ( my $mapping = $account->{sort_bin_mapping} ) {
        @lines = map { $_->{mapping} } @$mapping;
    }
    else {
        # Get the mapping and split on newlines
        my $raw_map = C4::Context->preference('SIP2SortBinMapping');
        return unless $raw_map;
        @lines = split /\r\n/, $raw_map;
    }

    # Iterate over the mapping. The first hit wins.
    my $rule = 0;
    foreach my $line (@lines) {

        # Split the line into fields
        my ( $branchcode, $item_property, $comparator, $value, $sort_bin ) =
          split /:/, $line;
        if ( $value =~ s/^\$// ) {
            $value = $item->$value;
        }
        # Check the fields against values in the item
        if ( $branch eq $branchcode ) {
            my $property = $item->$item_property;
            if ( ( $comparator eq 'eq' || $comparator eq '=' ) && ( $property eq $value ) ) {
                return $sort_bin;
            }
            if ( ( $comparator eq 'ne' || $comparator eq '!=' ) && ( $property ne $value ) ) {
                return $sort_bin;
            }
            if ( ( $comparator eq '<' ) && ( $property < $value ) ) {
                return $sort_bin;
            }
            if ( ( $comparator eq '>' ) && ( $property > $value ) ) {
                return $sort_bin;
            }
            if ( ( $comparator eq '<=' ) && ( $property <= $value ) ) {
                return $sort_bin;
            }
            if ( ( $comparator eq '>=' ) && ( $property >= $value ) ) {
                return $sort_bin;
            }
        }
    }

    # Return undef if no hits were found
    return;
}

1;
