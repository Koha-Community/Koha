# 
# RenewAll: class to manage status of "Renew All" transaction

package ILS::Transaction::RenewAll;

use strict;
use warnings;

our @ISA = qw(ILS::Transaction);

my %fields = (
	      renewed => [],
	      unrenewed => [],
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

1;
