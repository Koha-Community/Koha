package SIPtest;

use strict;
use warnings;

use Exporter;
use vars qw(@ISA $VERSION @EXPORT @EXPORT_OK %EXPORT_TAGS);

use Data::Dumper;

BEGIN {
	@ISA = qw(Exporter);
	%EXPORT_TAGS = (
		auth  => [qw(&api_auth)],
		basic => [qw($datepat $textpat $login_test $sc_status_test
						$instid $currency $server $username $password)],
		user1 => [qw($user_barcode  $user_pin  $user_fullname  $user_homeaddr  $user_email
						$user_phone  $user_birthday  $user_ptype  $user_inet)],
		item1 => [qw($item_barcode  $item_title  $item_owner )],
		diacritic => [qw($item_diacritic_barcode $item_diacritic_title $item_diacritic_owner)],
	);
	# duplicate user1 and item1 as user2 and item2
	# w/ tags like $user2_pin instead of $user_pin
	foreach my $tag (qw(user item)) {
		my @tags = @{$EXPORT_TAGS{$tag.'1'}};	# fresh array avoids side affect in map
		push @{$EXPORT_TAGS{$tag.'2'}}, map {s/($tag)\_/${1}2_/;$_} @tags;
	}
	# From perldoc Exporter
	# Add all the other ":class" tags to the ":all" class, deleting duplicates
	my %seen;
	push @{$EXPORT_TAGS{all}},
		grep {!$seen{$_}++} @{$EXPORT_TAGS{$_}} foreach keys %EXPORT_TAGS;
	Exporter::export_ok_tags('all');	# Anything in a tag is in OK_EXPORT
	# print Dumper(\%EXPORT_TAGS);		# Uncomment if you want to see the results of these tricks.
}

# The number of tests is set in run_sip_tests() below, based
# on the size of the array of tests.
use Test::More;
use CGI;

use IO::Socket::INET;
use Sip qw(:all);
use Sip::Checksum qw(verify_cksum);
use Sip::Constants qw(:all);

use C4::Auth qw(&check_api_auth);
use C4::Context;

# 
# Configuration parameters to run the test suite
#
our $instid   = 'CPL';	# 'UWOLS';
our $currency = 'USD';	# 'CAD';
our $server   = 'localhost:6001'; 	# Address of the SIP server

# SIP username and password to connect to the server.  See the
# SIP config.xml for the correct values.
our $username = 'term1';
our $password = 'term1';

# ILS Information

# NOTE: make sure to escape the data for use in RegExp.
# Valid user barcode and corresponding user password/pin and full name
our $user_barcode = '23529001000463';
our $user_pin     = 'fn5zS';
our $user_fullname= 'Edna Acosta';
our $user_homeaddr= '7896 Library Rd\.';
our $user_email   = 'patron\@liblime\.com';
our $user_phone   = '\(212\) 555-1212';
our $user_birthday= '1980-04-24';
our $user_ptype   = 'PT';
our $user_inet    = 'Y';

# Another valid user
our $user2_barcode = '23529000240482';
our $user2_pin     = 'jw937';
our $user2_fullname= 'Jamie White';
our $user2_homeaddr= '937 Library Rd\.';
our $user2_email   = 'patron\@liblime\.com';
our $user2_phone   = '\(212\) 555-1212';
our $user2_birthday= '1950-04-22';
our $user2_ptype   = 'T';
our $user2_inet    = 'Y';

# Valid item barcode and corresponding title
our $item_barcode = '502326000005';
our $item_title   = 'How I became a pirate /';
our $item_owner   = 'CPL';

# Another valid item
our $item2_barcode = '502326000011';
our $item2_title   = 'The biggest, smallest, fastest, tallest things you\'ve ever heard of /';
our $item2_owner   = 'CPL';

# An item with a diacritical in the title
our $item_diacritic_barcode = '502326001030';
our $item_diacritic_titlea  = 'Hari Poṭer u-geviʻa ha-esh /';
our $item_diacritic_owner   = 'CPL';

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
	$resp =~ tr/\cM//d;
	$resp =~ s/\015?\012$//;
	chomp($resp);

	if (!verify_cksum($resp)) {
		fail("$test->{id} checksum($resp)");
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

    # print STDERR 	"one_msg ( test ) : " . Dumper($test) . "\n" .
    # 				"one_msg (fields) : " . Dumper(\%fields);
	if (!defined($test->{fields})) {
		diag("TODO: $test->{id} field tests not written yet");
	} else {
	# If there are no tagged fields, then 'fields' should be an
	# empty list which will automatically skip this loop
	foreach my $ftest (@{$test->{fields}}) {
	    my $field = $ftest->{field};

	    if ($ftest->{required} && !exists($fields{$field})) {
		fail("$test->{id}: required field '$field' not found in '$resp'");
		return;
	    }

	    if (exists($fields{$field}) && ($fields{$field} !~ $ftest->{pat})) {
		fail("$test->{id} field test $field");
		diag("Field '$field' pattern '$ftest->{pat}' fails to match value '$fields{$field}' in message '$resp'");
		return;
	    }
	}
    }
    pass("$test->{id}");
    return;
}

sub api_auth() {
	# AUTH
	$ENV{REMOTE_USER} = $username;
	my $query = CGI->new();
	$query->param(userid   => $username);
	$query->param(password => $password);
	my ($status, $cookie, $sessionID) = check_api_auth($query, {circulate=>1}, "intranet");
	print STDERR "check_api_auth returns " . ($status || 'undef') . "\n";
	# print STDERR "api_auth userenv = " . &dump_userenv;
	return $status;
}

sub dump_userenv {
	my $userenv = C4::Context->userenv;
	return "# userenv: EMPTY\n" unless ($userenv);
	my $userbranch = $userenv->{branch};
	return "# userenv: " . Dumper($userenv)
		. ($userbranch ? "BRANCH FOUND: $userbranch\n" : "NO BRANCH FOUND\n");
}

sub run_sip_tests {
    my ($sock, $seqno);

    $Sip::error_detection = 1;
    $/ = "\015\012";	# must use correct record separator

    $sock = new IO::Socket::INET(PeerAddr => $server,
				 Type     => SOCK_STREAM);

    BAIL_OUT('failed to create connection to server') unless $sock;

    $seqno = 1;
	# print STDERR "Number of tests : ",  scalar (@_), "\n";
    plan tests => scalar(@_);
    foreach my $test (@_) {
		# print STDERR "Test $seqno:" . Dumper($test);
		one_msg($sock, $test, $seqno++);
		$seqno %= 10;		# sequence number is one digit
    }
}

1;
