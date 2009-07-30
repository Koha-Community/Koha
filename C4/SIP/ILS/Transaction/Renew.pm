#
# Status of a Renew Transaction
#

package ILS::Transaction::Renew;

use warnings;
use strict;

use ILS;
use ILS::Transaction;

use C4::Circulation;
use C4::Members;

our @ISA = qw(ILS::Transaction);

my %fields = (
	renewal_ok => 0,
);

sub new {
	my $class = shift;
	my $self = $class->SUPER::new();
	my $element;

	foreach $element (keys %fields) {
		$self->{_permitted}->{$element} = $fields{$element};
	}

	@{$self}{keys %fields} = values %fields;	# overkill?
	return bless $self, $class;
}

sub do_renew_for ($$) {
	my $self = shift;
	my $borrower = shift;
	my ($renewokay,$renewerror) = CanBookBeRenewed($borrower->{borrowernumber},$self->{item}->{itemnumber});
	if ($renewokay){
		my $datedue = AddIssue( $borrower, $self->{item}->id, undef, 0 );
		$self->{due} = $datedue;
		$self->renewal_ok(1);
	} else {
		$self->screen_msg(($self->screen_msg || '') . " " . $renewerror);
		$self->renewal_ok(0);
	}
    $! and warn "do_renew_for error: $!";
	$self->ok(1) unless $!;
	return $self;
}

sub do_renew {
	my $self = shift;
	my $borrower = GetMember( $self->{patron}->id, 'cardnumber');
	return $self->do_renew_for($borrower);
}	

1;
