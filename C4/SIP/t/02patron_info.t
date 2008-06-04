#!/usr/bin/perl
# patron_info: test Patron Information Response

use strict;
use warnings;
use Clone qw(clone);

use Sip::Constants qw(:all);

use SIPtest qw(:basic :user1);

# This is a template test case for the Patron Information
# message handling.  Because of the large number of fields,
# this template forms the basis for all of the different
# situations: valid patron no details, valid patron with each
# individual detail requested, invalid patron, invalid patron
# password, etc.
our $patron_info_test_template = {
    id => 'valid Patron Info no details',
    msg => "6300020060329    201700          AO$instid|AA$user_barcode|",
    pat => qr/^64 [ Y]{13}\d{3}$datepat(\d{4}){6}/,
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
	       $SIPtest::field_specs{(FID_HOLD_ITEMS_LMT)},
	       $SIPtest::field_specs{(FID_OVERDUE_ITEMS_LMT)},
	       $SIPtest::field_specs{(FID_CHARGED_ITEMS_LMT)},
	       { field    => FID_VALID_PATRON,
		 pat      => qr/^Y$/,
		 # Not required by the spec, but by the test
		 required => 1, },
	       $SIPtest::field_specs{(FID_CURRENCY)},
	       { field    => FID_FEE_AMT,
		 pat      => $textpat,
		 required => 0, },
	       { field    => FID_FEE_LMT,
		 pat      => $textpat,
		 required => 0, },
	       { field    => FID_HOME_ADDR,
		 pat      => qr/^$user_homeaddr$/o,
		 required => 1, }, # required by this test case
	       { field    => FID_EMAIL,
		 pat      => qr/^$user_email$/o,
		 required => 1, },
	       { field    => FID_HOME_PHONE,
		 pat      => qr/^$user_phone$/o,
		 required => 1, },
	       { field    => FID_PATRON_BIRTHDATE,
		 pat      => qr/^$user_birthday$/o,
		 required => 1, },
	       { field    => FID_PATRON_CLASS,
		 pat      => qr/^$user_ptype$/o,
		 required => 1, },
	       { field    => FID_INET_PROFILE,
		 pat      => qr/^$user_inet$/,
		 required => 1, },
	      ], };

our @tests = (
	     $SIPtest::login_test,
	     $SIPtest::sc_status_test,
	     clone($patron_info_test_template),
	);


# Create the test cases for the various summary detail fields
sub create_patron_summary_tests {
    my $test;
    my @patron_info_summary_tests = (
				     { field    => FID_HOLD_ITEMS,
				       pat      => $textpat,
				       required => 0, },
				     { field    => FID_OVERDUE_ITEMS,
				       pat      => $textpat,
				       required => 0, },
				     { field    => FID_CHARGED_ITEMS,
				       pat      => $textpat,
				       required => 0, },
# The test user has no items of these types, so the tests seem to fail
#				     { field    => FID_FINE_ITEMS,
#				       pat      => $textpat,
#				       required => 1, },
#				     { field    => FID_RECALL_ITEMS,
#				       pat      => $textpat,
#				       required => 0, },
#				     { field    => FID_UNAVAILABLE_HOLD_ITEMS,
#				       pat      => $textpat,
#				       required => 0, },
				     );

    foreach my $i (0 .. scalar @patron_info_summary_tests-1) {
	# The tests for each of the summary fields are exactly the
	# same as the basic one, except for the fact that there's
	# an extra field to test

	# Copy the hash, adjust it, add it to the end of the list
	$test = clone($patron_info_test_template);

	substr($test->{msg}, 23+$i, 1) = 'Y';
	$test->{id} = "valid Patron Info details: "
	    . $patron_info_summary_tests[$i]->{field};
	push @{$test->{fields}}, $patron_info_summary_tests[$i];
	push @tests, $test;
	}
}

sub create_invalid_patron_tests {
    my $test;

    $test = clone($patron_info_test_template);
    $test->{id} = "invalid Patron Info id";
    $test->{msg} =~ s/AA$user_barcode\|/AAberick|/o;
    $test->{pat} = qr/^64Y[ Y]{13}\d{3}$datepat(\d{4}){6}/;
    delete $test->{fields};
    $test->{fields} = [
		       $SIPtest::field_specs{(FID_INST_ID)},
		       $SIPtest::field_specs{(FID_SCREEN_MSG)},
		       $SIPtest::field_specs{(FID_PRINT_LINE)},
		       { field    => FID_PATRON_ID,
			 pat      => qr/^berick$/,
			 required => 1, },
		       { field    => FID_PERSONAL_NAME,
			 pat      => qr/^$/,
			 required => 1, },
		       { field    => FID_VALID_PATRON,
			 pat      => qr/^N$/,
			 required => 1, },
		       ];
    push @tests, $test;

    # Valid patron, invalid patron password
    $test = clone($patron_info_test_template);
    $test->{id} = "valid Patron Info, invalid password";
    $test->{msg} .= (FID_PATRON_PWD) . 'badpwd|';
    $test->{pat} = qr/^64[ Y]{14}\d{3}$datepat(\d{4}){6}/;
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
			 required => 1, },
		       { field    => FID_VALID_PATRON_PWD,
			 pat      => qr/^N$/,
			 required => 1, },
		       ];
    push @tests, $test;
}

create_patron_summary_tests;
create_invalid_patron_tests;
SIPtest::run_sip_tests(@tests);
1;
