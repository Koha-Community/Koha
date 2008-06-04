#!/usr/bin/perl
# patron_enable: test  Patron Enable Response

use strict;
use warnings;
use Clone qw(clone);

use Sip::Constants qw(:all);

use SIPtest qw(:basic :user1 :user2 :item1 :item2);

my $hold_test_template = {
    id => "Place Hold: valid item ($item_barcode), valid patron ($user_barcode)",	 #BS could be another branch
    msg => "15+20060415    110158BW20060815    110158|BS$instid|BY2|AO$instid|AA$user_barcode|AB$item_barcode|",
    pat => qr/^161Y$datepat/,
    fields => [
	       $SIPtest::field_specs{(FID_INST_ID)},
	       $SIPtest::field_specs{(FID_SCREEN_MSG)},
	       $SIPtest::field_specs{(FID_PRINT_LINE)},
	       { field    => FID_PATRON_ID,
		 pat      => qr/^$user_barcode$/,
		 required => 1, },
	       { field    => FID_EXPIRATION,
		 pat      => $datepat,
		 required => 0, },
	       { field    => FID_QUEUE_POS,
		 pat      => qr/^1$/,
		 required => 0, },
	       { field    => FID_PICKUP_LOCN,
		 pat      => qr/^$item_owner$/,
		 required => 0, },
	       { field    => FID_TITLE_ID,
		 pat      => qr/^$item_title$/,
		 required => 0, },
	       { field    => FID_ITEM_ID,
		 pat      => qr/^$item_barcode$/,
		 required => 0, },
	       ],};

my $tmp_msg = "6300020060329    201700          AO$instid|AA$user_barcode|";
my $hold_count_test_template0 = {
    id => "Confirm patron ($user_barcode) has 0 holds",
    msg => $tmp_msg,
    pat => qr/^64 [ Y]{13}\d{3}${datepat}0000(\d{4}){5}/,
    fields => [],
};
my $hold_count_test_template1 = {
    id => "Confirm patron ($user_barcode) has 1 hold",
    msg => $tmp_msg,
    pat => qr/^64 [ Y]{13}\d{3}${datepat}((0001(\d{4}){4}0000)|(0000(\d{4}){4}0001))/,
		# The tricky part at the end here is because we don't know whether
		# the hold will count as "waiting" or unavailable.
		# But it will be one or the other!
    fields => [],
};

my @tests = (
	     $SIPtest::login_test,								# 1
	     $SIPtest::sc_status_test,							# 2
	     $hold_test_template, $hold_count_test_template1,	# 3,4
	     );

my $test;

# Hold Queue: second hold placed on item
$test = clone($hold_test_template);
$test->{id} = "Place 2nd hold on item ($item_barcode) for user ($user2_barcode)";
$test->{msg} =~ s/AA$user_barcode\|/AA$user2_barcode|/;
$test->{pat} = qr/^161N$datepat/;
foreach my $i (0 .. (scalar @{$test->{fields}})-1) {
	my $field =  $test->{fields}[$i];
	if ($field->{field} eq FID_PATRON_ID) {
		$field->{pat} = qr/^$user2_barcode$/;
	} elsif ($field->{field} eq FID_QUEUE_POS) {
		$field->{pat} = qr/^2$/;
	}
}

push @tests, $test;											# 5

# Cancel hold: valid hold
$test = clone($hold_test_template);
$test->{id} = "Cancel Hold: valid hold for user ($user_barcode)";
$test->{msg} =~ s/\+/-/;
$test->{pat} = qr/^161[NY]$datepat/;
delete $test->{fields};
$test->{fields} = [
		   $SIPtest::field_specs{(FID_INST_ID)},
		   $SIPtest::field_specs{(FID_SCREEN_MSG)},
		   $SIPtest::field_specs{(FID_PRINT_LINE)},
		   { field    => FID_PATRON_ID,
		     pat      => qr/^$user_barcode$/,
		     required => 1, },
		   ];

push @tests, $test, $hold_count_test_template0;				# 6,7

# Cancel Hold: no hold on item
# $test is already set up to cancel a hold, just change
# the field tests
$test = clone($test);
$test->{id} = 'Cancel Hold: no hold on specified item';
$test->{pat} = qr/^160N$datepat/;

push @tests, $test, $hold_count_test_template0;				# 8,9

# Cleanup: cancel 2nd user's hold too.
$test = clone($hold_test_template);
$test->{id} = "Cancel hold: cleanup hold for 2nd patron ($user2_barcode)";
$test->{msg} =~ s/\+/-/;
$test->{msg} =~ s/$user_barcode/$user2_barcode/;
$test->{pat} = qr/^161[NY]$datepat/;
delete $test->{fields};
$test->{fields} = [
		   $SIPtest::field_specs{(FID_INST_ID)},
		   $SIPtest::field_specs{(FID_SCREEN_MSG)},
		   $SIPtest::field_specs{(FID_PRINT_LINE)},
		   { field    => FID_PATRON_ID,
		     pat      => qr/^$user2_barcode$/,
		     required => 1, },
		   ];

push @tests, $test;											# 11

# Place hold: valid patron, item, invalid patron pwd
$test = clone($hold_test_template);
$test->{id} = 'Place hold: invalid patron password';
$test->{msg} .= FID_PATRON_PWD . 'bad password|';
$test->{pat} = qr/^160N$datepat/;
delete $test->{fields};
$test->{fields} = [
		   $SIPtest::field_specs{(FID_INST_ID)},
		   $SIPtest::field_specs{(FID_SCREEN_MSG)},
		   $SIPtest::field_specs{(FID_PRINT_LINE)},
		   { field    => FID_PATRON_ID,
		     pat      => qr/^$user_barcode$/,
		     required => 1, },
		   ];

push @tests, $test, $hold_count_test_template0;				# 12,13

# Place hold: invalid patron
$test = clone($hold_test_template);
$test->{id} = 'Place hold: invalid patron';
$test->{msg} =~ s/AA$user_barcode\|/AAbad_barcode|/;
$test->{pat} = qr/^160N$datepat/;
delete $test->{fields};
$test->{fields} = [
		   $SIPtest::field_specs{(FID_INST_ID)},
		   $SIPtest::field_specs{(FID_SCREEN_MSG)},
		   $SIPtest::field_specs{(FID_PRINT_LINE)},
		   { field    => FID_PATRON_ID,
		     pat      => qr/^bad_barcode$/,
		     required => 1, },
		   ];

# There's no patron to check the number of holds against
push @tests, $test;											# 14

# Place hold: invalid item
$test = clone($hold_test_template);
$test->{id} = 'Place hold: invalid item';
$test->{msg} =~ s/AB$item_barcode\|/ABnosuchitem|/;
$test->{pat} = qr/^160N$datepat/;
delete $test->{fields};
$test->{fields} = [
		   $SIPtest::field_specs{(FID_INST_ID)},
		   $SIPtest::field_specs{(FID_SCREEN_MSG)},
		   $SIPtest::field_specs{(FID_PRINT_LINE)},
		   { field    => FID_PATRON_ID,
		     pat      => qr/^$user_barcode$/,
		     required => 1, },
		   { field    => FID_ITEM_ID,
		     pat      => qr/^nosuchitem$/,
		     required => 0, },
		   ];

push @tests, $test, $hold_count_test_template0;				# 15

# Still need tests for:
#     - valid patron not permitted to place holds
#     - valid item, not allowed to hold item
#     - multiple holds on item: correct queue position management
#     - setting and verifying hold expiry dates (requires ILS support)

SIPtest::run_sip_tests(@tests);

1;
