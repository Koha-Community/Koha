package SIPtest;

use strict;
use warnings;

use Exporter;

our @ISA = qw(Exporter);

our @EXPORT_OK = qw(run_sip_tests no_tagged_fields
		    $datepat $textpat
		    $login_test $sc_status_test
		    %field_specs

		    $instid $currency $server $username $password
		    $user_barcode $user_pin $user_fullname $user_homeaddr
		    $user_email $user_phone $user_birthday $user_ptype
		    $user_inet
		    $item_barcode $item_title $item_owner
		    $item2_barcode $item2_title $item2_owner
		    $item_diacritic_barcode $item_diacritic_title
		    $item_diacritic_owner);
#use Data::Dumper;

# The number of tests is set in run_sip_tests() below, based
# on the size of the array of tests.
use Test::More;

use IO::Socket::INET;
use Sip qw(:all);
use Sip::Checksum qw(verify_cksum);
use Sip::Constants qw(:all);

# 
# Configuration parameters to run the test suite
#
our $instid = 'kohalibrary';
our $currency = 'USD';
#our $instid = 'UWOLS';
#our $currency = 'CAD';
our $server   = 'localhost:6001'; # Address of the SIP server

# SIP username and password to connect to the server.  See the
# SIP config.xml for the correct values.
our $username = 'koha';
our $password = 'koha';

# ILS Information

# Valid user barcode and corresponding user password/pin and full name
our $user_barcode = '900002';
our $user_pin     = 'password';
our $user_fullname= 'firstname surname';
our $user_homeaddr= '35 address';
our $user_email   = 'patron@liblime.com';
our $user_phone   = '555';
our $user_birthday= '';
our $user_ptype   = '';
our $user_inet    = '';

# Valid item barcode and corresponding title
our $item_barcode = '1565921879';
our $item_title   = 'Perl 5 desktop reference';
our $item_owner   = 'kohalibrary';

# Another valid item
our $item2_barcode = '0440242746';
our $item2_title   = 'The deep blue alibi';
our $item2_owner   = 'kohalibrary';

# An item with a diacritical in the title
our $item_diacritic_barcode = '660';
our $item_diacritic_title = 'Harry Potter y el cáliz de fuego';
our $item_diacritic_owner = 'kohalibrary';

# End configuration

# Pattern for a SIP datestamp, to be used by individual tests to
# match timestamp fields (duh).
our $datepat = '\d{8} {4}\d{6}';

# Pattern for a random text field (may be empty)
our $textpat = qr/^[^|]*$/;

our %field_specs = (
		    (FID_SCREEN_MSG) => { field    => FID_SCREEN_MSG,
					  pat      => $textpat,
					  required => 0, },
		    (FID_PRINT_LINE) => { field    => FID_PRINT_LINE,
					  pat      => $textpat,
					  required => 0, },
		    (FID_INST_ID)    => { field    => FID_INST_ID,
					  pat      => qr/^$instid$/o,
					  required => 1, },
		    (FID_HOLD_ITEMS_LMT)=> { field    => FID_HOLD_ITEMS_LMT,
					     pat      => qr/^\d{4}$/,
					     required => 0, },
		    (FID_OVERDUE_ITEMS_LMT)=> { field    => FID_OVERDUE_ITEMS_LMT,
						pat      => qr/^\d{4}$/,
						required => 0, },
		    (FID_CHARGED_ITEMS_LMT)=> { field    => FID_CHARGED_ITEMS_LMT,
						pat      => qr/^\d{4}$/,
						required => 0, },
		    (FID_VALID_PATRON) => { field    => FID_VALID_PATRON,
					    pat      => qr/^[NY]$/,
					    required => 0, },
		    (FID_VALID_PATRON_PWD)=> { field    => FID_VALID_PATRON_PWD,
					       pat      => qr/^[NY]$/,
					       required => 0, },
		    (FID_CURRENCY)   => { field    => FID_CURRENCY,
					  pat      => qr/^$currency$/io,
					  required => 0, },
		    );

# Login and SC Status are always the first two messages that
# the terminal sends to the server, so just create the test
# cases here and reference them in the individual test files.

our $login_test = { id => 'login',
		    msg => "9300CN$username|CO$password|CPThe floor|",
		    pat => qr/^941/,
		    fields => [], };

our $sc_status_test = { id => 'SC status',
			msg => '9910302.00',
			pat => qr/^98[YN]{6}\d{3}\d{3}$datepat(2\.00|1\.00)/,
			fields => [
				   $field_specs{(FID_SCREEN_MSG)},
				   $field_specs{(FID_PRINT_LINE)},
				   $field_specs{(FID_INST_ID)},
				   { field    => 'AM',
				     pat      => $textpat,
				     required => 0, },
				   { field    => 'BX',
				     pat      => qr/^[YN]{16}$/,
				     required => 1, },
				   { field    => 'AN',
				     pat      => $textpat,
				     required => 0, },
				   ],
			};

sub one_msg {
    my ($sock, $test, $seqno) = @_;
    my $resp;
    my %fields;

    # If reading or writing fails, then the server's dead,
    # so there's no point in continuing.
    if (!write_msg({seqno => $seqno}, $test->{msg}, $sock)) {
	BAIL_OUT("Write failure in $test->{id}");
    } elsif (!($resp = <$sock>)) {
	BAIL_OUT("Read failure in $test->{id}");
    }

    chomp($resp);

    if (!verify_cksum($resp)) {
	fail("checksum $test->{id}");
	return;
    }
    if ($resp !~ $test->{pat}) {
	fail("match leader $test->{id}");
	diag("Response '$resp' doesn't match pattern '$test->{pat}'");
	return;
    }

    # Split the tagged fields of the response into (name, value)
    # pairs and stuff them into the hash.
    $resp =~ $test->{pat};
    %fields = substr($resp, $+[0]) =~ /(..)([^|]*)\|/go;

#    print STDERR Dumper($test);
#    print STDERR Dumper(\%fields);
    if (!defined($test->{fields})) {
	diag("TODO: $test->{id} field tests not written yet");
    } else {
	# If there are no tagged fields, then 'fields' should be an
	# empty list which will automatically skip this loop
	foreach my $ftest (@{$test->{fields}}) {
	    my $field = $ftest->{field};

	    if ($ftest->{required} && !exists($fields{$field})) {
		fail("$test->{id} required field '$field' exists in '$resp'");
		return;
	    }

	    if (exists($fields{$field}) && ($fields{$field} !~ $ftest->{pat})) {

		fail("$test->{id} field test $field");
		diag("Field pattern '$ftest->{pat}' for '$field' doesn't match in '$resp'");
		return;
	    }
	}
    }
    pass("$test->{id}");
    return;
}

#
# _count_tests: Count the number of tests in a test array
sub _count_tests {
    return scalar @_;
}

sub run_sip_tests {
    my ($sock, $seqno);

    $Sip::error_detection = 1;
    $/ = "\r";

    $sock = new IO::Socket::INET(PeerAddr => $server,
				 Type     => SOCK_STREAM);

    BAIL_OUT('failed to create connection to server') unless $sock;

    $seqno = 1;

    plan tests => _count_tests(@_);

    foreach my $test (@_) {
	one_msg($sock, $test, $seqno++);
	$seqno %= 10;		# sequence number is one digit
    }
}

1;
