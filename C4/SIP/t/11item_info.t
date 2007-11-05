#!/usr/bin/perl
# renew_all: test Renew All Response

use strict;
use warnings;
use Clone qw(clone);

use Sip::Constants qw(:all);

use SIPtest qw($datepat $textpat $instid $currency $user_barcode
	       $item_barcode $item_title $item_owner);

my $item_info_test_template = {
    id => 'Item Information: check information for available item',
    msg => "1720060110    215612AO$instid|AB$item_barcode|",
    pat => qr/^180[13]0201$datepat/, # status of 'other' or 'available'
    fields => [
	       $SIPtest::field_specs{(FID_SCREEN_MSG)},
	       $SIPtest::field_specs{(FID_PRINT_LINE)},
	       { field    => FID_ITEM_ID,
		 pat      => qr/^$item_barcode$/,
		 required => 1, },
	       { field    => FID_TITLE_ID,
		 pat      => qr/^$item_title\s*$/,
		 required => 1, },
	       { field    => FID_MEDIA_TYPE,
		 pat      => qr/^\d{3}$/,
		 required => 0, },
	       { field    => FID_OWNER,
		 pat      => qr/^$item_owner$/,
		 required => 0, },
	       ], };

my @tests = (
	     $SIPtest::login_test,
	     $SIPtest::sc_status_test,
	     clone($item_info_test_template),
	     );

SIPtest::run_sip_tests(@tests);

1;
