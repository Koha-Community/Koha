#!/usr/bin/perl
# 
# sc_status: test basic connection, login, and response
# to the SC Status message, which has to be sent before
# anything else

use strict;
use warnings;

use SIPtest qw($datepat $username $password $login_test $sc_status_test);

my $invalid_uname = { id => 'Invalid username',
		      msg => "9300CNinvalid$username|CO$password|CPThe floor|",
		      pat => qr/^940/,
		      fields => [], };

my $invalid_pwd = { id => 'Invalid password',
		      msg => "9300CN$username|COinvalid$password|CPThe floor|",
		      pat => qr/^940/,
		      fields => [], };

my @tests = ( $invalid_uname, $invalid_pwd, $login_test, $sc_status_test );

SIPtest::run_sip_tests(@tests);

1;
