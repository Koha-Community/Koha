#
# Transaction: Superclass of all the transactional status objects
#

package C4::SIP::ILS::Transaction;

use Carp;
use strict;
use warnings;
use C4::Context;
use C4::Circulation qw( GetItemIssue );
use Koha::DateUtils;

my %fields = (
	ok            => 0,
	patron        => undef,
	item          => undef,
	desensitize   => 0,
	alert         => '',
	transaction_id=> undef,
	sip_fee_type  => '01', # Other/Unknown
	fee_amount    => undef,
	sip_currency  => 'USD', # FIXME: why hardcoded?
	screen_msg    => '',
	print_line    => '',
    fee_ack       => 'N',
);

our $AUTOLOAD;

sub new {
	my $class = shift;
	my $self = {
		_permitted => \%fields,
		%fields,
	};
	return bless $self, $class;
}

sub duedatefromissue {
    my ($self, $iss, $itemnum) = @_;
    my $due_dt;
    if (defined $iss ) {
        $due_dt = dt_from_string( $iss->date_due() );
    } # renew from AddIssue ??
    else {
        # need to reread the issue to get due date
        $iss = GetItemIssue($itemnum);
        if ($iss && $iss->{date_due} ) {
            $due_dt = dt_from_string( $iss->{date_due} );
        }
    }
    return $due_dt;
}



sub DESTROY {
    # be cool
}

sub AUTOLOAD {
    my $self = shift;
    my $class = ref($self) or croak "$self is not an object";
    my $name = $AUTOLOAD;

    $name =~ s/.*://;

    unless (exists $self->{_permitted}->{$name}) {
		croak "Can't access '$name' field of class '$class'";
    }

	if (@_) {
		return $self->{$name} = shift;
	} else {
		return $self->{$name};
	}
}

1;
__END__

