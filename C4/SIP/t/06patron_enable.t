#!/usr/bin/perl
# patron_enable: test  Patron Enable Response

use strict;
use warnings;
use Clone qw(clone);

use Sip::Constants qw(:all);

use SIPtest qw(:basic :user1);

my $patron_enable_test_template = {
    id => 'Patron Enable: valid patron',
    msg => "2520060102    084238AOUWOLS|AA$user_barcode|",
    pat => qr/^26 {4}[ Y]{10}000$datepat/,
    fields => [
	       $SIPtest::field_specs{(FID_INST_ID)},
	       $SIPtest::field_specs{(FID_SCREEN_MSG)},
	       $SIPtest::field_specs{(FID_PRINT_LINE)},
	       { field    => FID_PATRON_ID,
		 pat      => qr/^$user_barcode$/,
		 required => 1, },
	       { field    => FID_PERSONAL_NAME,
		 pat      => qr/^$user_fullname$/,
		 required => 1, },
	       { field    => FID_VALID_PATRON,
		 pat      => qr/^Y$/,
		 # Not required by the spec, but by the test
		 required => 1, },
	       ], };

# We need to disable the valid patron before we can 
# ensure that he was properly enabled.
my $patron_disable_test_template = {
    id => 'Patron Enable: block patron (prep to test enabling)',
    msg => "01N20060102    084238AO$instid|ALBlocked patron for SIP test.|AA$user_barcode|",
    # response to block patron is a patron status message
    pat => qr/^24Y{4}[ Y]{10}000$datepat/,
    fields => [
	       $SIPtest::field_specs{(FID_INST_ID)},
	       { field    => FID_PATRON_ID,
		 pat      => qr/^$user_barcode$/,
		 required => 1, },
	       { field    => FID_PERSONAL_NAME,
		 pat      => qr/^$user_fullname$/,
		 required => 1, },
	       { field    => FID_VALID_PATRON,
		 pat      => qr/^Y$/,
		 # Not required by the spec, but by the test
		 required => 1, },
	       ], };

my @tests = (
	     $SIPtest::login_test,
	     $SIPtest::sc_status_test,
	     $patron_disable_test_template,
	     clone($patron_enable_test_template),
	     );

my $test;

# Valid patron, valid password
$test = clone($patron_enable_test_template);
$test->{id} = "Patron Enable: valid patron, valid password";
$test->{msg} .= FID_PATRON_PWD . "$user_pin|";
$test->{pat} = qr/^26 {4}[ Y]{10}000$datepat/;
delete $test->{fields};
$test->{fields} = [
		   $SIPtest::field_specs{(FID_INST_ID)},
		   $SIPtest::field_specs{(FID_SCREEN_MSG)},
		   $SIPtest::field_specs{(FID_PRINT_LINE)},
		   { field    => FID_PATRON_ID,
		     pat      => qr/^$user_barcode$/,
		     required => 1, },
		   { field    => FID_PERSONAL_NAME,
		     pat      => qr/^$user_fullname$/,
		     required => 1, },
		   { field    => FID_VALID_PATRON,
		     pat      => qr/^Y$/,
		     # Not required by the spec, but by the test
		     required => 1, },
		   { field    => FID_VALID_PATRON_PWD,
		     pat      => qr/^Y$/,
		     required => 1, },
		   ];

push @tests, $patron_disable_test_template, $test;

# Valid patron, invalid password
$test = clone($patron_enable_test_template);
$test->{id} = "Patron Enable: valid patron, invalid password";
$test->{msg} .= FID_PATRON_PWD . 'bad password|';
$test->{pat} = qr/^26[ Y]{14}000$datepat/;
delete $test->{fields};
$test->{fields} = [
		   $SIPtest::field_specs{(FID_INST_ID)},
		   $SIPtest::field_specs{(FID_SCREEN_MSG)},
		   $SIPtest::field_specs{(FID_PRINT_LINE)},
		   { field    => FID_PATRON_ID,
		     pat      => qr/^$user_barcode$/,
		     required => 1, },
		   { field    => FID_PERSONAL_NAME,
		     pat      => qr/^$user_fullname$/,
		     required => 1, },
		   { field    => FID_VALID_PATRON,
		     pat      => qr/^Y$/,
		     # Not required by the spec, but by the test
		     required => 1, },
		   { field    => FID_VALID_PATRON_PWD,
		     pat      => qr/^N$/,
		     required => 1, },
		   ];

push @tests, $patron_disable_test_template, $test;
# After this test, the patron is left disabled, so re-enable
push @tests, $patron_enable_test_template;

# Invalid patron
$test = clone($patron_enable_test_template);
$test->{id} =~ s/valid/invalid/;
$test->{msg} =~ s/AA$user_barcode\|/AAbad_barcode|/;
$test->{pat} =  qr/^26Y{4}[ Y]{10}000$datepat/;
delete $test->{fields};
$test->{fields} = [
		   $SIPtest::field_specs{(FID_INST_ID)},
		   $SIPtest::field_specs{(FID_SCREEN_MSG)},
		   $SIPtest::field_specs{(FID_PRINT_LINE)},
		   { field    => FID_PATRON_ID,
		     pat      => qr/^bad_barcode$/,
		     required => 1, },
		   { field    => FID_PERSONAL_NAME,
		     pat      => qr/^$/,
		     required => 1, },
		   { field    => FID_VALID_PATRON,
		     pat      => qr/^N$/,
		     # Not required by the spec, but by the test
		     required => 1, },
		   ];

push @tests, $test;

SIPtest::run_sip_tests(@tests);

1;
