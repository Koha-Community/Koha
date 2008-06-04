#
# An object to handle checkin status
#

package ILS::Transaction::Checkin;

use warnings;
use strict;

use POSIX qw(strftime);

use ILS;
use ILS::Transaction;

use C4::Circulation;

our @ISA = qw(ILS::Transaction);

my %fields = (
	magnetic => 0,
	sort_bin => undef,
);

sub new {
	my $class = shift;;
	my $self = $class->SUPER::new();
	my $element;

	foreach $element (keys %fields) {
		$self->{_permitted}->{$element} = $fields{$element};
	}

	@{$self}{keys %fields} = values %fields;
	return bless $self, $class;
}

sub do_checkin {
	my $self = shift;
	my $barcode = $self->{item}->{id};
	my $branch='ALB'; # gotta set this
			# FIXME: hardcoded branch not good.
	my $return = AddReturn($barcode,$branch);
	$self->ok($return);
	return 1;
}

sub resensitize {
	my $self = shift;
	unless ($self->{item}) {
		warn "no item found in object to resensitize";
		return undef;
	}
	return !$self->{item}->magnetic;
}

1;
