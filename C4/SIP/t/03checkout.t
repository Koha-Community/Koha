#!/usr/bin/perl
# checkout: test Checkout Response

use strict;
use warnings;
use Clone qw(clone);

use CGI;

use Sip::Constants qw(:all);
use SIPtest qw(
		:basic
		$user_barcode
		:diacritic
        :item1
	);

my $patron_enable_template = {
    id => 'Renew All: prep: enable patron permissions',
    msg => "2520060102    084238AO$instid|AA$user_barcode|",
    pat => qr/^26 {4}[ Y]{10}000$datepat/o,
    fields => [],
};

my $patron_disable_template = {
    id => 'Checkout: block patron (prep to test checkout denied)',
    msg => "01N20060102    084238AO$instid|ALFees overrun|AA$user_barcode|",
    # response to block patron is a patron status message
    pat => qr/^24Y{4}[ Y]{10}000$datepat/o,
    fields => [],
};

my $checkin_template = {
	id => 'Checkout: cleanup: check in item',
	msg => "09N20050102    08423620060113    084235AP$item_owner|AO$instid|AB$item_barcode|ACterminal password|",
	pat => qr/^101YNN$datepat/o,
	fields => [],
};

my $checkout_test_template = {
    id => 'Checkout: valid item, valid patron',
    msg => "11YN20060329    203000                  AO$instid|AA$user_barcode|AB$item_barcode|AC|",
    pat => qr/^121NNY$datepat/,
    fields => [
	       $SIPtest::field_specs{(FID_INST_ID)},
	       $SIPtest::field_specs{(FID_SCREEN_MSG)},
	       $SIPtest::field_specs{(FID_PRINT_LINE)},
	       { field    => FID_PATRON_ID,
		 pat      => qr/^$user_barcode$/o,
		 required => 1, },
	       { field    => FID_ITEM_ID,
		 pat      => qr/^$item_barcode$/o,
		 required => 1, },
	       { field    => FID_TITLE_ID,
		 pat      => qr/^$item_title\s*$/o,
		 required => 1, },
	       { field    => FID_DUE_DATE,
		 pat      => $textpat,
		 required => 1, },
	       { field    => FID_FEE_TYPE,
		 pat      => qr/^\d{2}$/,
		 required => 0, },
	       { field    => FID_SECURITY_INHIBIT,
		 pat      => qr/^[YN]$/,
		 required => 0, },
	       { field    => FID_CURRENCY,
		 pat      => qr/^$currency$/o,
		 required => 0, },
	       { field    => FID_FEE_AMT,
		 pat      => qr/^[.0-9]+$/,
		 required => 0, },
	       { field    => FID_MEDIA_TYPE,
		 pat      => qr/^\d{3}$/,
		 required => 0, },
	       { field    => FID_ITEM_PROPS,
		 pat      => $textpat,
		 required => 0, },
	       { field    => FID_TRANSACTION_ID,
		 pat      => $textpat,
		 required => 0, },
	       ], };

my @tests = (
	     $SIPtest::login_test,
	     $SIPtest::sc_status_test,
	     clone($checkout_test_template),
	     # Don't check the item in, because we're about to test renew
	     );

my $test;

## Renewal OK
## Test this by checking out exactly the same book a second time.
## The only difference should be that the "Renewal OK" flag should now
## be 'Y'.
#$test = clone($checkout_test_template);
#$test->{id} = 'Checkout: patron renewal';
#$test->{pat} = qr/^121YNY$datepat/;

#push @tests, $test;

# NOW check it in

push @tests, $checkin_template;

# Valid Patron, item with diacritical in the title
#$test = clone($checkout_test_template);
#
#$test->{id} = 'Checkout: valid patron, diacritical character in title';
#$test->{msg} =~ s/AB$item_barcode/AB$item_diacritic_barcode/;

#foreach my $i (0 .. (scalar @{$test->{fields}})-1) {
#    my $field =  $test->{fields}[$i];

#    if ($field->{field} eq FID_ITEM_ID) {
#	$field->{pat} = qr/^$item_diacritic_barcode$/;
#    } elsif ($field->{field} eq FID_TITLE_ID) {
#	$field->{pat} = qr/^$item_diacritic_title\s*$/;
#    } elsif ($field->{field} eq FID_OWNER) {
#	$field->{pat} = qr/^$item_diacritic_owner$/;
#    }
#}

#push @tests, $test;

#$test = clone($checkin_template);
#$test->{msg} =~ s/AB$item_barcode/AB$item_diacritic_barcode/;
#push @tests, $test;

# Valid Patron, Invalid Item_id
$test = clone($checkout_test_template);

$test->{id} = 'Checkout: valid patron, invalid item';
$test->{msg} =~ s/AB$item_barcode/ABno-barcode/o;
$test->{pat} = qr/^120NUN$datepat/;
delete $test->{fields};
$test->{fields} = [
		   $SIPtest::field_specs{(FID_INST_ID)},
		   $SIPtest::field_specs{(FID_SCREEN_MSG)},
		   $SIPtest::field_specs{(FID_PRINT_LINE)},
		   { field    => FID_PATRON_ID,
		     pat      => qr/^$user_barcode$/o,
		     required => 1, },
		   { field    => FID_ITEM_ID,
		     pat      => qr/^no-barcode$/,
		     required => 1, },
		   { field    => FID_TITLE_ID,
		     pat      => qr/^$/,
		     required => 1, },
		   { field    => FID_DUE_DATE,
		     pat      => qr/^$/,
		     required => 1, },
		   { field    => FID_VALID_PATRON,
		     pat      => qr/^Y$/,
		     required => 1, },
		   ];

push @tests, $test;

# Invalid patron, valid item
$test = clone($checkout_test_template);
$test->{id} = 'Checkout: invalid patron, valid item';
$test->{msg} =~ s/AA$user_barcode/AAberick/;
$test->{pat} = qr/^120NUN$datepat/;
delete $test->{fields};
$test->{fields} = [
		   $SIPtest::field_specs{(FID_INST_ID)},
		   $SIPtest::field_specs{(FID_SCREEN_MSG)},
		   $SIPtest::field_specs{(FID_PRINT_LINE)},
		   { field    => FID_PATRON_ID,
		     pat      => qr/^berick$/,
		     required => 1, },
		   { field    => FID_ITEM_ID,
		     pat      => qr/^$item_barcode$/o,
		     required => 1, },
		   { field    => FID_TITLE_ID,
		     pat      => qr/^$item_title\s*$/o,
		     required => 1, },
		   { field    => FID_DUE_DATE,
		     pat      => qr/^$/,
		     required => 1, },
		   { field    => FID_VALID_PATRON,
		     pat      => qr/^N$/,
		     required => 1, },
		   ];

push @tests, $test;

# Needed: tests for blocked patrons, patrons with excessive
# fines/fees, magnetic media, charging fees to borrow items.

## Blocked patron
#$test = clone($checkout_test_template);
#$test->{id} = 'Checkout: Blocked patron';
#$test->{pat} = qr/^120NUN$datepat/;
#delete $test->{fields};
#$test->{fields} = [
#		   $SIPtest::field_specs{(FID_INST_ID)},
#		   $SIPtest::field_specs{(FID_SCREEN_MSG)},
#		   $SIPtest::field_specs{(FID_PRINT_LINE)},
#		   { field    => FID_PATRON_ID,
#		     pat      => qr/^$user_barcode$/,
#		     required => 1, },
#		   { field    => FID_VALID_PATRON,
#		     pat      => qr/^Y$/,
#		     required => 1, },
#		  ];
#
#push @tests, $patron_disable_template, $test, $patron_enable_template;
#
SIPtest::run_sip_tests(@tests);

1;
