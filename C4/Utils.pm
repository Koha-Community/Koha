package C4::Utils;

# Useful code I didn't feel like duplicating all over the place.
#

use strict;
use warnings;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $debug);

BEGIN {
	require Exporter;
	$VERSION = 1.00;        # set the version for version checking
	$debug = $ENV{DEBUG} || 0;
	@ISA    = qw(Exporter);
	@EXPORT_OK = qw(&maxwidth &hashdump);
	%EXPORT_TAGS = ( all => [qw(&maxwidth &hashdump)], );
}


sub maxwidth (@) {
	(@_) or return 0;
	return (sort {$a <=> $b} map {length} @_)[-1];
}

sub hashdump ($$) {
	my $pre = shift;
	my $val  = shift;
	if (ref($val) =~ /HASH/) {
		print "$pre = HASH w/ " . scalar(keys %$val) . " keys.\n";
		my $w2 = maxwidth(keys %$val);
		foreach (sort keys %$val) {
			&hashdump($pre . '->{' . sprintf('%' . $w2 .'s', $_) . '}', $val->{$_});
		}
		print "\n";
	} elsif (ref($val) =~ /ARRAY/) {
		print "$pre = ARRAY w/ " . scalar(@$val) . " members.\n";
		my $w2 = maxwidth(@$val);
		foreach (@$val) {
			&hashdump($pre . '->{' . sprintf('%' . $w2 .'s', $_) . '}', $_);
		}
		print "\n";
	} else {
		print "$pre = $val\n";
	}
}

1;
__END__
