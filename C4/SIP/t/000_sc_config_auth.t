#!/usr/bin/perl
# 
# check if SIP terminal can Auth based on the xml config
#

use strict;
use warnings;

use Test::More tests => 15;

BEGIN {
	use_ok('Sip::Constants', qw(:all));
	use_ok('SIPtest', qw(:basic :user1 :auth));
	use_ok('C4::Auth', qw(&check_api_auth));
	use_ok('C4::Context');
	use_ok('CGI');
	use_ok('Data::Dumper');
}

my ($status, $cookie, $sessionID, $uenv);
my $query = CGI->new();
ok($username, sprintf "\$username exported by SIPtest (%s)", ($username||''));
ok($password, sprintf "\$password exported by SIPtest (%s)", ($password||''));

ok($ENV{REMOTE_USER} = $username,          "set ENV{REMOTE_USER}");	# from SIPtest
ok($query->param(userid   => $username),   "set \$query->param('userid')");
ok($query->param(password => $password),   "set \$query->param('password')");

$status = api_auth();
$uenv = C4::Context->userenv;
ok($status,    sprintf "api_auth returned status (%s)",    ($status   ||''));
ok($uenv, "After  api_auth, Got C4::Context->userenv :" . ($uenv ? Dumper($uenv) : ''));

($status, $cookie, $sessionID) = check_api_auth($query, {circulate=>1}, "intranet");

ok($status,    sprintf "checkauth returned status (%s)",    ($status   ||''));
# ok($cookie,    sprintf "checkauth returned cookie (%s)",    ($cookie   ||''));
# ok($sessionID, sprintf "checkauth returned sessionID (%s)", ($sessionID||''));

diag "note: checkauth " . ($cookie    ? "returned cookie    ($cookie)\n"    : "did NOT return cookie\n"   ); 
diag "note: checkauth " . ($sessionID ? "returned sessionID ($sessionID)\n" : "did NOT return sessionID\n"); 

$uenv = C4::Context->userenv;
ok($uenv, "After checkauth, Got C4::Context->userenv :" . ($uenv ? Dumper($uenv) : ''));

diag "Done.";
