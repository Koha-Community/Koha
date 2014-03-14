#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 5;
use CGI qw ( -utf8 );

BEGIN {
    use_ok('C4::Output');
}

my $query = CGI->new();
my $cookie;
my $output = 'foobarbaz';

{
    local *STDOUT;
    my $stdout;
    open STDOUT, '>', \$stdout;
    output_html_with_http_headers $query, $cookie, $output, undef, { force_no_caching => 1 };
    like($stdout, qr/Cache-control: no-cache, no-store, max-age=0/, 'force_no_caching sets Cache-control as desired');
    like($stdout, qr/Expires: /, 'force_no_caching sets an Expires header');
    $stdout = '';
    close STDOUT;
    open STDOUT, '>', \$stdout;
    output_html_with_http_headers $query, $cookie, $output, undef, undef;
    like($stdout, qr/Cache-control: no-cache[^,]/, 'not using force_no_caching sets Cache-control as desired');
    unlike($stdout, qr/Expires: /, 'force_no_caching does not set an Expires header');
}
