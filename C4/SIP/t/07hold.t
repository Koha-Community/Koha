#!/usr/bin/perl
# patron_enable: test  Patron Enable Response

use strict;
use warnings;
use Clone qw(clone);

use Sip::Constants qw(:all);

use SIPtest qw($datepat $textpat);

my $hold_test_template = {
    id => 'Place Hold: valid item, valid patron',
    msg => '15+20060415    110158BW20060815    110158|BSTaylor|BY2|AOUWOLS|AAdjfiander|AB1565921879|',
    pat => qr/^161N$datepat/,
    fields => [
	       $SIPtest::field_specs{(FID_INST_ID)},
	       $SIPtest::field_specs{(FID_SCREEN_MSG)},
	       $SIPtest::field_specs{(FID_PRINT_LINE)},
	       { field    => FID_PATRON_ID,
		 pat      => qr/^djfiander$/,
		 required => 1, },
	       { field    => FID_EXPIRATION,
		 pat      => $datepat,
		 required => 0, },
	       { field    => FID_QUEUE_POS,
		 pat      => qr/^1$/,
		 required => 1, },
	       { field    => FID_PICKUP_LOCN,
		 pat      => qr/^Taylor$/,
		 required => 1, },
	       { field    => FID_TITLE_ID,
		 pat      => qr/^Perl 5 desktop reference$/,
		 required => 1, },
	       { field    => FID_ITEM_ID,
		 pat      => qr/^1565921879$/,
		 required => 1, },
	       ],};

my $hold_count_test_template0 = {
    id => 'Confirm patron has 0 holds',
    msg => '6300020060329    201700          AOUWOLS|AAdjfiander|',
    pat => qr/^64 [ Y]{13}\d{3}${datepat}0000(\d{4}){5}/,
    fields => [],
};

my $hold_count_test_template1 = {
    id => 'Confirm patron has 1 hold',
    msg => '6300020060329    201700          AOUWOLS|AAdjfiander|',
    pat => qr/^64 [ Y]{13}\d{3}${datepat}0001(\d{4}){5}/,
    fields => [],
};


my @tests = (
	     $SIPtest::login_test,
	     $SIPtest::sc_status_test,
	     $hold_test_template, $hold_count_test_template1,
	     );

my $test;

# Hold Queue: second hold placed on item
$test = clone($hold_test_template);
$test->{id} = 'Place hold: second hold on item';
$test->{msg} =~ s/djfiander/miker/;
$test->{pat} = qr/^161N$datepat/;
foreach my $i (0 .. (scalar @{$test->{fields}})-1) {
    my $field =  $test->{fields}[$i];

    if ($field->{field} eq FID_PATRON_ID) {
	$field->{pat} = qr/^miker$/;
    } elsif ($field->{field} eq FID_QUEUE_POS) {
	$field->{pat} = qr/^2$/;
    }
}

push @tests, $test;

# Cancel hold: valid hold
$test = clone($hold_test_template);
$test->{id} = 'Cancel hold: valid hold';
$test->{msg} =~ s/\+/-/;
$test->{pat} = qr/^161[NY]$datepat/;
delete $test->{fields};
$test->{fields} = [
		   $SIPtest::field_specs{(FID_INST_ID)},
		   $SIPtest::field_specs{(FID_SCREEN_MSG)},
		   $SIPtest::field_specs{(FID_PRINT_LINE)},
		   { field    => FID_PATRON_ID,
		     pat      => qr/^djfiander$/,
		     required => 1, },
		   ];

push @tests, $test, $hold_count_test_template0;

# Cancel Hold: no hold on item
# $test is already set up to cancel a hold, just change
# the field tests
$test = clone($test);
$test->{id} = 'Cancel Hold: no hold on specified item';
$test->{pat} = qr/^160N$datepat/;

push @tests, $test, $hold_count_test_template0;

# Cleanup: cancel miker's hold too.
$test = clone($hold_test_template);
$test->{id} = "Cancel hold: cleanup second patron's hold";
$test->{msg} =~ s/\+/-/;
$test->{msg} =~ s/djfiander/miker/;
$test->{pat} = qr/^161[NY]$datepat/;
delete $test->{fields};
$test->{fields} = [
		   $SIPtest::field_specs{(FID_INST_ID)},
		   $SIPtest::field_specs{(FID_SCREEN_MSG)},
		   $SIPtest::field_specs{(FID_PRINT_LINE)},
		   { field    => FID_PATRON_ID,
		     pat      => qr/^miker$/,
		     required => 1, },
		   ];

push @tests, $test;

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
		     pat      => qr/^djfiander$/,
		     required => 1, },
		   ];

push @tests, $test, $hold_count_test_template0;

# Place hold: invalid patron
$test = clone($hold_test_template);
$test->{id} = 'Place hold: invalid patron';
$test->{msg} =~ s/AAdjfiander\|/AAberick|/;
$test->{pat} = qr/^160N$datepat/;
delete $test->{fields};
$test->{fields} = [
		   $SIPtest::field_specs{(FID_INST_ID)},
		   $SIPtest::field_specs{(FID_SCREEN_MSG)},
		   $SIPtest::field_specs{(FID_PRINT_LINE)},
		   { field    => FID_PATRON_ID,
		     pat      => qr/^berick$/,
		     required => 1, },
		   ];

# There's no patron to check the number of holds against
push @tests, $test;

# Place hold: invalid item
$test = clone($hold_test_template);
$test->{id} = 'Place hold: invalid item';
$test->{msg} =~ s/AB1565921879\|/ABnosuchitem|/;
$test->{pat} = qr/^160N$datepat/;
delete $test->{fields};
$test->{fields} = [
		   $SIPtest::field_specs{(FID_INST_ID)},
		   $SIPtest::field_specs{(FID_SCREEN_MSG)},
		   $SIPtest::field_specs{(FID_PRINT_LINE)},
		   { field    => FID_PATRON_ID,
		     pat      => qr/^djfiander$/,
		     required => 1, },
		   { field    => FID_ITEM_ID,
		     pat      => qr/^nosuchitem$/,
		     required => 0, },
		   ];

push @tests, $test, $hold_count_test_template0;

# Still need tests for:
#     - valid patron not permitted to place holds
#     - valid item, not allowed to hold item
#     - multiple holds on item: correct queue position management
#     - setting and verifying hold expiry dates (requires ILS support)

SIPtest::run_sip_tests(@tests);

1;
