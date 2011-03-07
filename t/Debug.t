#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 5;

use vars qw($debug $cgi_debug);

BEGIN {
$ENV{'KOHA_CGI_DEBUG'}='2';
$ENV{'KOHA_DEBUG'}='5';
	diag "BEFORE use:     \$debug is " . (defined     $debug ?     $debug : 'not defined');
	diag "BEFORE use: \$cgi_debug is " . (defined $cgi_debug ? $cgi_debug : 'not defined');
	use_ok('C4::Debug');
}

diag " AFTER use:     \$debug is " . (defined     $debug ?     $debug : 'not defined');
diag " AFTER use: \$cgi_debug is " . (defined $cgi_debug ? $cgi_debug : 'not defined');
ok(defined     $debug, "    \$debug defined and imported.");
ok(defined $cgi_debug, "\$cgi_debug defined and imported.");
is($cgi_debug,2,"cgi_debug gets the ENV{'KOHA_CGI_DEBUG'}");
is($debug,5,"debug gets the ENV{'KOHA_DEBUG'}");

diag "Done.";
