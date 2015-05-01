#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 7;

use vars qw($debug $cgi_debug);

BEGIN {
    $ENV{'KOHA_CGI_DEBUG'}='2';
    $ENV{'KOHA_DEBUG'}='5';
    is($debug,    undef,"    \$debug is undefined as expected.");
    is($cgi_debug,undef,"\$cgi_debug is undefined as expected.");
    use_ok('C4::Debug');
}

ok(defined     $debug, "    \$debug defined and imported.");
ok(defined $cgi_debug, "\$cgi_debug defined and imported.");
is($cgi_debug,2,"cgi_debug gets the ENV{'KOHA_CGI_DEBUG'}");
is($debug,5,"debug gets the ENV{'KOHA_DEBUG'}");
