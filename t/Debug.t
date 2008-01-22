#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 3;

use vars qw($debug $cgi_debug);

BEGIN {
	diag "BEFORE use:     \$debug is " . (defined     $debug ?     $debug : 'not defined');
	diag "BEFORE use: \$cgi_debug is " . (defined $cgi_debug ? $cgi_debug : 'not defined');
	use_ok('C4::Debug');
}

diag " AFTER use:     \$debug is " . (defined     $debug ?     $debug : 'not defined');
diag " AFTER use: \$cgi_debug is " . (defined $cgi_debug ? $cgi_debug : 'not defined');
ok(defined     $debug, "    \$debug defined and imported.");
ok(defined $cgi_debug, "\$cgi_debug defined and imported.");

diag "Done.";
