#
# An object to handle checkout status
#

package C4::SIP::ILS::Transaction::Checkout;

use warnings;
use strict;

use POSIX qw(strftime);
use C4::SIP::Sip qw( siplog );
use Data::Dumper;
use CGI qw ( -utf8 );

use C4::SIP::ILS::Transaction;

use C4::Context;
use C4::Circulation qw( AddIssue GetIssuingCharges CanBookBeIssued ProcessOfflineIssue );
use C4::Members;
use Koha::DateUtils qw( dt_from_string );

use parent qw(C4::SIP::ILS::Transaction);

# Most fields are handled by the Transaction superclass
my %fields = (
          security_inhibit => 0,
          due              => undef,
          renew_ok         => 0,
    );

sub new {
    my $class = shift;;
    my $self = $class->SUPER::new();
    foreach my $element (keys %fields) {
        $self->{_permitted}->{$element} = $fields{$element};
    }
    @{$self}{keys %fields} = values %fields;
    return bless $self, $class;
}

sub do_checkout {
	my $self = shift;
    my $account = shift;
    my $no_block_due_date = shift;
	siplog('LOG_DEBUG', "ILS::Transaction::Checkout performing checkout...");
    my $shelf          = $self->{item}->hold_attached;
	my $barcode        = $self->{item}->id;
    my $patron         = Koha::Patrons->find($self->{patron}->{borrowernumber});
    my $overridden_duedate; # usually passed as undef to AddIssue
    my $prevcheckout_block_checkout  = $account->{prevcheckout_block_checkout};
    my ($issuingimpossible, $needsconfirmation, $messages) = _can_we_issue($patron, $barcode, 0);

    if ( $no_block_due_date ) {
        my $year = substr($no_block_due_date,0,4);
        my $month = substr($no_block_due_date,4,2);
        my $day = substr($no_block_due_date,6,2);
        my $hour = substr($no_block_due_date,12,2);
        my $minute = substr($no_block_due_date,14,2);
        my $second = substr($no_block_due_date,16,2);

        my $iso = "$year-$month-$day $hour:$minute:$second";
        $no_block_due_date = dt_from_string( $iso, "iso" );
    }

    my $noerror=1;  # If set to zero we block the issue
    if (keys %{$issuingimpossible}) {
        foreach (keys %{$issuingimpossible}) {
            # do something here so we pass these errors
            $self->screen_msg("Issue failed : $_");
            $noerror = 0;
            last;
        }
    } else {
        foreach my $confirmation (keys %{$needsconfirmation}) {
            if ($confirmation eq 'RENEW_ISSUE'){
                $self->screen_msg("Item already checked out to you: renewing item.");
            } elsif ($confirmation eq 'RESERVED' and !C4::Context->preference("AllowItemsOnHoldCheckoutSIP")) {
                $self->screen_msg("Item is reserved for another patron upon return.");
                $noerror = 0;
            } elsif ($confirmation eq 'RESERVED' and C4::Context->preference("AllowItemsOnHoldCheckoutSIP")) {
                next;
            } elsif ($confirmation eq 'RESERVE_WAITING'
                      or $confirmation eq 'TRANSFERRED'
                      or $confirmation eq 'PROCESSING') {
               $self->screen_msg("Item is on hold for another patron.");
               $noerror = 0;
            } elsif ($confirmation eq 'ISSUED_TO_ANOTHER') {
                $self->screen_msg("Item already checked out to another patron.  Please return item for check-in.");
                $noerror = 0;
                last;
            } elsif ($confirmation eq 'DEBT') {
                $self->screen_msg('Outstanding Fines block issue');
                $noerror = 0;
                last;
            } elsif ($confirmation eq 'HIGHHOLDS') {
                $overridden_duedate = $needsconfirmation->{$confirmation}->{returndate};
                $self->screen_msg('Loan period reduced for high-demand item');
            } elsif ($confirmation eq 'RENTALCHARGE') {
                if ($self->{fee_ack} ne 'Y') {
                    $noerror = 0;
                    last;
                }
            } elsif ($confirmation eq 'PREVISSUE') {
                $self->screen_msg("This item was previously checked out by you");
                $noerror = 0 if ($prevcheckout_block_checkout);
                last;
            } elsif ( $confirmation eq 'ADDITIONAL_MATERIALS' ) {
                $self->screen_msg('Item must be checked out at a circulation desk');
                $noerror = 0;
                last;
            } elsif ( $confirmation eq 'RECALLED' ) {
                $self->screen_msg('Item has been recalled for another patron');
                $noerror = 0;
                last;
            } else {
                # We've been returned a case other than those above
                $self->screen_msg("Item cannot be issued: $confirmation");
                $noerror = 0;
                siplog('LOG_DEBUG', "Blocking checkout Reason:$confirmation");
                last;
            }
        }
    }
    my $itemnumber = $self->{item}->{itemnumber};
    my ($fee, undef) = GetIssuingCharges($itemnumber, $patron->borrowernumber);
    if ( $fee > 0 ) {
        $self->{sip_fee_type} = '06';
        $self->{fee_amount} = sprintf '%.2f', $fee;
        if ($self->{fee_ack} eq 'N' ) {
            $noerror = 0;
        }
    }

    if ( $noerror == 0 && !$no_block_due_date ) {
		$self->ok(0);
		return $self;
	}

    if ( $no_block_due_date ) {
        $overridden_duedate = $no_block_due_date;
        ProcessOfflineIssue({
            cardnumber => $patron->cardnumber,
            barcode    => $barcode,
            timestamp  => $no_block_due_date,
        });
    } else {
        # can issue
        my $recall_id;
        foreach ( keys %{$messages} ) {
            if ( $_ eq "RECALLED" ) {
                $recall_id = $messages->{RECALLED};
            }
        }
        my $issue = AddIssue( $patron, $barcode, $overridden_duedate, 0, undef, undef, { recall_id => $recall_id } );
        $self->{due} = $self->duedatefromissue( $issue, $itemnumber );
    }

    $self->ok(1);
    return $self;
}

sub _can_we_issue {
    my ( $patron, $barcode, $pref ) = @_;

    my ( $issuingimpossible, $needsconfirmation, $alerts, $messages ) =
      CanBookBeIssued( $patron, $barcode, undef, 0, $pref );
    for my $href ( $issuingimpossible, $needsconfirmation ) {

        # some data is returned using lc keys we only
        foreach my $key ( keys %{$href} ) {
            if ( $key =~ m/[^A-Z_]/ ) {
                delete $href->{$key};
            }
        }
    }
    return ( $issuingimpossible, $needsconfirmation, $messages );
}

1;
__END__
