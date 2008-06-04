#!/usr/bin/perl
# Item Information test

use strict;
use warnings;
use Clone qw(clone);

use Sip::Constants qw(:all);
use SIPtest qw(:basic :user1 :item1);

my $item_info_test_template = {
	id  => "Item Information: check info for available item ($item_barcode)",
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
	],
};

my @tests = (
	$SIPtest::login_test,
	$SIPtest::sc_status_test,
	$item_info_test_template,
);

SIPtest::run_sip_tests(@tests);

1;
