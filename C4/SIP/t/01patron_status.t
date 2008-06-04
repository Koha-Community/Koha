#!/usr/bin/perl
# 
# patron_status: check status of valid patron and invalid patron

use strict;
use warnings;

use Sip::Constants qw(:all);
use SIPtest qw($datepat $instid $currency :user1);

my @tests = (
	     $SIPtest::login_test,
	     $SIPtest::sc_status_test,
	     { id => 'valid Patron Status',
	       msg => "2300120060101    084237AO$instid|AA$user_barcode|AD$user_pin|AC|",
	       pat => qr/^24 [ Y]{13}\d{3}$datepat/,
	       fields => [
			  $SIPtest::field_specs{(FID_INST_ID)},
			  $SIPtest::field_specs{(FID_SCREEN_MSG)},
			  $SIPtest::field_specs{(FID_PRINT_LINE)},
			  { field    => FID_PERSONAL_NAME,
			    pat      => qr/^$user_fullname$/o,
			    required => 1, },
			  { field    => FID_PATRON_ID,
			    pat      => qr/^$user_barcode/o,
			    required => 1, },
			  { field    => FID_VALID_PATRON,
			    pat      => qr/^Y$/,
			    required => 0, },
			  { field    => FID_VALID_PATRON_PWD,
			    pat      => qr/^Y$/,
			    required => 0, },
			  { field    => FID_CURRENCY,
			    pat      => qr/^$currency$/io,
			    required => 0, },
			  { field    => FID_FEE_AMT,
			    pat      => qr/^[0-9.]+$/,
			    required => 0, },
			  ], },
	     { id => 'invalid password Patron Status',
	       msg => "2300120060101    084237AO$instid|AA$user_barcode|AC|ADbadw|",
	       pat => qr/^24[ Y]{14}\d{3}$datepat/,
	       fields => [
			  { field    => FID_PERSONAL_NAME,
			    pat      => qr/^$user_fullname$/o,
			    required => 1, },
			  { field    => FID_PATRON_ID,
			    pat      => qr/^$user_barcode$/o,
			    required => 1, },
			  { field    => FID_INST_ID,
			    pat      => qr/^$instid$/o,
			    required => 1, },
			  { field    => FID_VALID_PATRON_PWD,
			    pat      => qr/^N$/,
			    required => 1, },
			  { field    => FID_VALID_PATRON,
			    pat      => qr/^Y$/,
			    required => 1, },
			  ], },
	     { id => 'invalid Patron Status',
	       msg => "2300120060101    084237AO$instid|AAwshakespeare|AC|",
	       pat => qr/^24Y[ Y]{13}\d{3}$datepat/,
	       fields => [
			  { field    => FID_PERSONAL_NAME,
			    pat      => qr/^$/,
			    required => 1, },
			  { field    => FID_PATRON_ID,
			    pat      => qr/^wshakespeare$/,
			    required => 1, },
			  { field    => FID_INST_ID,
			    pat      => qr/^$instid$/o,
			    required => 1, },
			  ], },
	     );

SIPtest::run_sip_tests(@tests);

1;
