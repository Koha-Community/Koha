#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 6;
use Test::Warn;
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

subtest 'parametrized_url' => sub {
    plan tests => 2;

    my $url = 'https://somesite.com/search?q={TITLE}&author={AUTHOR}{SUFFIX}';
    my $subs = { TITLE => '_title_', AUTHOR => undef, ISBN => '123456789' };
    my $res;
    warning_is { $res = C4::Output::parametrized_url( $url, $subs ) }
        q{}, 'No warning expected on undefined author';
    is( $res, 'https://somesite.com/search?q=_title_&author=',
        'Title replaced, author empty and SUFFIX removed' );
};
