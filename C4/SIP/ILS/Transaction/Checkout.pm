#
# An object to handle checkout status
#

package ILS::Transaction::Checkout;

use warnings;
use strict;

use POSIX qw(strftime);
use Sys::Syslog qw(syslog);

use ILS;
use ILS::Transaction;

use C4::Circulation;
use C4::Members;

our @ISA = qw(ILS::Transaction);

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
#	use Data::Dumper;
#    warn Dumper $self;    
    return bless $self, $class;
}

sub do_checkout {
	my $self = shift;
	syslog('LOG_DEBUG', "ILS::Transaction::Checkout performing checkout...");
	my $barcode = $self->{item}->id;
	my $patron_barcode = $self->{patron}->id;
	warn $patron_barcode;
	my $borrower = GetMember( $patron_barcode, 'cardnumber' );
#	use Data::Dumper;
#	warn Dumper $borrower;
	my ($issuingimpossible,$needsconfirmation) = CanBookBeIssued ( $borrower, $barcode );
	my $noerror=1;
	foreach my $impossible ( keys %$issuingimpossible ) {
		# do something here so we pass these errors
		$self->screen_msg($issuingimpossible->{$impossible});
		$noerror = 0;                                                                                                                                  
	}
	foreach my $confirmation ( keys %$needsconfirmation ) {
		if ($confirmation eq 'RENEW_ISSUE'){
			my ($renewokay,$renewerror)= CanBookBeRenewed($borrower->{borrowernumber},$self->{item}->{itemnumber});
			if (! $renewokay){
				$noerror = 0;
				warn "cant renew $borrower->{borrowernumber} $self->{item}->{itemnumber} $renewerror";
			}
		}
		else {
			$self->screen_msg($needsconfirmation->{$confirmation});
			$noerror = 0;
		}
	}            
    
	
	if ($noerror){
		warn "can issue";
		# we can issue
		my $datedue = AddIssue( $borrower, $barcode, undef, 0 ); 		
		$self->{'due'} = $datedue;
		$self->ok(1);
	}
	else {		
		warn "cant issue";
		use Data::Dumper;
		warn Dumper $issuingimpossible;
		warn Dumper $needsconfirmation;
		$self->ok(0);
	}
	return $self;
	
}

1;
