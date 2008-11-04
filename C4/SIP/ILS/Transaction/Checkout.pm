#
# An object to handle checkout status
#

package ILS::Transaction::Checkout;

use warnings;
use strict;

use POSIX qw(strftime);
use Sys::Syslog qw(syslog);
use Data::Dumper;
use CGI;

use ILS;
use ILS::Transaction;

use C4::Context;
use C4::Circulation;
use C4::Members;
use C4::Reserves qw(ModReserveFill);
use C4::Debug;

use vars qw($VERSION @ISA $debug);

BEGIN {
	$VERSION = 1.03;
	@ISA = qw(ILS::Transaction);
}

# Most fields are handled by the Transaction superclass
my %fields = (
	      security_inhibit => 0,
	      due              => undef,
	      renew_ok         => 0,
	);

sub new {
    my $class = shift;;
    my $self = $class->SUPER::new();
    my $element;
    foreach $element (keys %fields) {
		$self->{_permitted}->{$element} = $fields{$element};
    }
    @{$self}{keys %fields} = values %fields;
#    $self->{'due'} = time() + (60*60*24*14); # two weeks hence
	$debug and warn "new ILS::Transaction::Checkout : " . Dumper $self;
    return bless $self, $class;
}

sub do_checkout {
	my $self = shift;
	syslog('LOG_DEBUG', "ILS::Transaction::Checkout performing checkout...");
	my $pending        = $self->{item}->pending_queue;
	my $shelf          = $self->{item}->hold_shelf;
	my $barcode        = $self->{item}->id;
	my $patron_barcode = $self->{patron}->id;
	$debug and warn "do_checkout: patron (" . $patron_barcode . ")";
	my $borrower = $self->{patron}->getmemberdetails_object();
	$debug and warn "do_checkout borrower: . " . Dumper $borrower;
	my ($issuingimpossible,$needsconfirmation) = CanBookBeIssued( $borrower, $barcode );
	my $noerror=1;
    if (scalar keys %$issuingimpossible) {
        foreach (keys %$issuingimpossible) {
            # do something here so we pass these errors
            $self->screen_msg($_ . ': ' . $issuingimpossible->{$_});
            $noerror = 0;
        }
    } else {
        foreach my $confirmation (keys %$needsconfirmation) {
            if ($confirmation eq 'RENEW_ISSUE'){
                $self->screen_msg("Item already checked out to you: renewing item.");
            } elsif ($confirmation eq 'RESERVED' or $confirmation eq 'RESERVE_WAITING') {
                my $x = $self->{item}->available($patron_barcode);
                if ($x) {
                    $self->screen_msg("Item was reserved for you.");
                } else {
                    $self->screen_msg("Item is reserved for another patron upon return.");
                    # $noerror = 0;
                }
            } elsif ($confirmation eq 'ISSUED_TO_ANOTHER') {
                $self->screen_msg("Item already checked out to another patron.  Please return item for check-in.");
                $noerror = 0;
            } elsif ($confirmation eq 'DEBT') {     # don't do anything, it's the minor debt, and alarms fire elsewhere
            } else {
                $self->screen_msg($needsconfirmation->{$confirmation});
                $noerror = 0;
            }
        }
    }
    my $itemnumber = $self->{item}->{itemnumber};
    foreach (@$shelf) {
        $debug and warn "shelf has ($_->{itemnumber} for $_->{borrowernumber}). this is ($itemnumber, $self->{patron}->{borrowernumber})";
        ($_->{itemnumber} eq $itemnumber) or next;    # skip it if not this item
        ($_->{borrowernumber} == $self->{patron}->{borrowernumber}) and last;
            # if item was waiting for this patron, we're done.  AddIssue takes care of the "W" hold.
        $debug and warn "Item is on hold shelf for another patron.";
        $self->screen_msg("Item is on hold shelf for another patron.");
        $noerror = 0;
    }
	unless ($noerror) {
		$debug and warn "cannot issue: " . Dumper($issuingimpossible) . "\n" . Dumper($needsconfirmation);
		$self->ok(0);
		return $self;
	}
    # Fill any reserves the patron had on the item.  
    # TODO: this logic should be pulled internal to AddIssue for all Koha. 
    $debug and warn "pending_queue: " . (@$pending) ? Dumper($pending) : '[]';
    foreach (grep {$_->{borrowernumber} eq $self->{patron}->{borrowernumber}} @$pending) {
        $debug and warn "Filling reserve (borrowernumber,biblionumber,reservedate): "
            . sprintf("(%s,%s,%s)\n",$_->{borrowernumber},$_->{biblionumber},$_->{reservedate});
        ModReserveFill($_);
        # TODO: adjust representation in $self->item
    }
	# can issue
	$debug and warn "do_checkout: calling AddIssue(\$borrower,$barcode, undef, 0)\n"
		# . "w/ \$borrower: " . Dumper($borrower)
		. "w/ C4::Context->userenv: " . Dumper(C4::Context->userenv);
	my $c4due  = AddIssue($borrower, $barcode, undef, 0);
	my $due  = $c4due->output('iso') || undef;
	$debug and warn "Item due: $due";
	$self->{'due'} = $due;
	$self->{item}->due_date($due);
	$self->ok(1);
	return $self;
}

1;
__END__
