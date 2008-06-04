#!/usr/bin/perl
# block_patron: test Block Patron Response

use strict;
use warnings;
use Clone qw(clone);

use Sip::Constants qw(:all);

use SIPtest qw(:basic :user1);

my $block_patron_test_template = {
    id => 'Block Patron: valid patron, card not retained',
    msg => "01N20060102    084238AO$instid|ALThis card is blocked.|AA$user_barcode|AC$password|",
    # response to block patron is a patron status message
    pat => qr/^24Y[ Y]{13}000$datepat/,
    fields => [
	       $SIPtest::field_specs{(FID_INST_ID)},
	       $SIPtest::field_specs{(FID_SCREEN_MSG)},
	       $SIPtest::field_specs{(FID_PRINT_LINE)},
	       { field    => FID_PATRON_ID,
		 pat      => qr/^$user_barcode$/o,
		 required => 1, },
	       { field    => FID_PERSONAL_NAME,
		 pat      => qr/^$user_fullname$/o,
		 required => 1, },
	       { field    => FID_VALID_PATRON,
		 pat      => qr/^Y$/,
		 # Not required by the spec, but by the test
		 required => 1, },
	       $SIPtest::field_specs{(FID_CURRENCY)},
	       { field    => FID_FEE_AMT,
		 pat      => $textpat,
		 required => 0, },
	       ], };

my @tests = (
	     $SIPtest::login_test,
	     $SIPtest::sc_status_test,
	     clone($block_patron_test_template),
	     );

SIPtest::run_sip_tests(@tests);

1;
