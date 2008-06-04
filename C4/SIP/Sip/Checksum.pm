package Sip::Checksum;

use Exporter;
use strict;
use warnings;

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(checksum verify_cksum);
our $debug = 0;

sub checksum {
    my $pkt = shift;
    return (-unpack('%16U*', $pkt) & 0xFFFF);
}

sub verify_cksum {
    my $pkt = shift;
    my $cksum;
    my $shortsum;

	if ($pkt =~ /AZ(....)$/) {
		$debug and warn "verify_cksum: sum ($1) detected";
	} else {
		warn "verify_cksum: no sum detected";
		return 0; # No checksum at end
	}
    # return 0 if (substr($pkt, -6, 2) ne "AZ");

    # Convert the checksum back to hex and calculate the sum of the
    # pack without the checksum.
    $cksum = hex($1);
    $shortsum = unpack("%16U*", substr($pkt, 0, -4));

    # The checksum is valid if the hex sum, plus the checksum of the 
    # base packet short when truncated to 16 bits.
    return (($cksum + $shortsum) & 0xFFFF) == 0;
}

{
    no warnings qw(once);
    eval join('',<main::DATA>) || die $@ unless caller();
	# FIXME: what the heck is this?
}

1;
__END__

#
# Some simple test data
#
sub test {
    my $testpkt = shift;
    my $cksum = checksum($testpkt);
    my $fullpkt = sprintf("%s%4X", $testpkt, $cksum);

    print $fullpkt, "\n";
}

while (<>) {
    chomp;
    test($_);
}

1;
