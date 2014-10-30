#!/usr/bin/perl
# renew_all: test Renew All Response

use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin";
use Clone qw(clone);

use C4::SIP::Sip::Constants qw(:all);

use SIPtest qw(:basic :user1 :item1 :item2);

my $enable_template = {
    id => 'Renew All: prep: enable patron permissions',
    msg => "2520060102    084238AO$instid|AA$user_barcode|",
    pat => qr/^26 {4}[ Y]{10}000$datepat/,
    fields => [],
};

# reset_checkin_templates will be used to reset the status of the items if needed
# If "make test" is used (all tests at once), after the tests 08 and 09, the item stays checked out and this raises an error here
# so we begin with a Checkin, awaiting for the minimal answer : ^10 (Checkin response)
# Both results (101 and 100, for OK and NON OK) must be accepted, because if we run this test alone, the item won't necessarily be checked out
# and the checkin attempt will then result in a "100" code, which is not a problem (we are just preparing the renewal tests)
my @reset_checkin_templates = (
    {
        id => "Renew All: prep: check in $item_barcode (used in previous tests)",
        msg => "09N20060102    08423620060113    084235AP$item_owner|AO$instid|AB$item_barcode|AC$password|",
        pat    => qr/^10/,
        fields => [],
    },
    {
        id => "Renew All: prep: check in $item2_barcode (used in previous tests)",
        msg => "09N20060102    08423620060113    084235AP$item2_owner|AO$instid|AB$item2_barcode|AC$password|",
        pat    => qr/^10/,
        fields => [],
    }
);

# Checkout as a preparation for renewal
my @checkout_templates = (
	{    id => "Renew All: prep: check out $item_barcode to $user_barcode",
		msg => "11YN20060329    203000                  AO$instid|AA$user_barcode|AB$item_barcode|AC$password|",
		pat => qr/^121NNY$datepat/,
		fields => [],},
	{    id => "Renew All: prep: check out $item2_barcode to $user_barcode",
		msg => "11YN20060329    203000                  AO$instid|AA$user_barcode|AB$item2_barcode|AC$password|",
		pat => qr/^121NNY$datepat/,
		fields => [],}
);

my $renew_all_test_template = {
	 id => "Renew All: patron ($user_barcode) with 1 item ($item_barcode) checked out, no patron password",
	msg => "6520060102    084236AO$instid|AA$user_barcode|",
	pat => qr/^66100010000$datepat/,
	fields => [
       $SIPtest::field_specs{(FID_INST_ID)},
       $SIPtest::field_specs{(FID_SCREEN_MSG)},
       $SIPtest::field_specs{(FID_PRINT_LINE)},
       { field   => FID_RENEWED_ITEMS,
	 	pat      => qr/^$item_barcode$/,
	 	required => 1, },
	]
};

# check the book in, when done testing
my @checkin_templates = (
    {
        id => "Renew All: prep: check in $item_barcode",
        msg => "09N20060102    08423620060113    084235AP$item_owner|AO$instid|AB$item_barcode|AC$password|",
        pat    => qr/^101YNN$datepat/,
        fields => [],
    },
    {
        id => "Renew All: prep: check in $item2_barcode",
        msg => "09N20060102    08423620060113    084235AP$item2_owner|AO$instid|AB$item2_barcode|AC$password|",
        pat    => qr/^101YNN$datepat/,
        fields => [],
    }
);



my @tests = (
	     $SIPtest::login_test,
	     $SIPtest::sc_status_test,
	     );

my $test;

# WIP?
$test = clone($renew_all_test_template);
$test->{id} = 'Renew All: Valid patron, two items checked out';
$test->{pat} = qr/^66100020000$datepat/;
foreach my $i (0 .. (scalar @{$test->{fields}})-1) {
	my $field =  $test->{fields}[$i];
	if ($field->{field} eq FID_RENEWED_ITEMS) {
		$field->{pat} = qr/^$item_barcode\|$item2_barcode$/;
	}
}

#push @tests, @checkout_templates[0..1], $renew_all_test_template, @checkin_templates[0..1];

$test = clone($renew_all_test_template);
$test->{id} = 'Renew All: valid patron, invalid patron password';
$test->{msg} .= (FID_PATRON_PWD) . 'bad_pwd|';
$test->{pat} = qr/^66000000000$datepat/;
delete $test->{fields};
$test->{fields} = [
	       $SIPtest::field_specs{(FID_INST_ID)},
	       $SIPtest::field_specs{(FID_SCREEN_MSG)},
	       $SIPtest::field_specs{(FID_PRINT_LINE)},
		  ];

push @tests, $reset_checkin_templates[0], $checkout_templates[0], $test, $checkin_templates[0];

$test = clone($renew_all_test_template);
$test->{id} = 'Renew All: invalid patron';
$test->{msg} =~ s/AA$user_barcode/AAbad_barcode/;
$test->{pat} = qr/^66000000000$datepat/;
delete $test->{fields};
$test->{fields} = [
	       $SIPtest::field_specs{(FID_INST_ID)},
	       $SIPtest::field_specs{(FID_SCREEN_MSG)},
	       $SIPtest::field_specs{(FID_PRINT_LINE)},
		  ];
push @tests, $test;

SIPtest::run_sip_tests(@tests);

1;
