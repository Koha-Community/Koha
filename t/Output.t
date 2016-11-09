#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 7;
use Test::Warn;
use CGI qw ( -utf8 );

use t::lib::Mocks;

BEGIN {
    use_ok('C4::Output', qw( output_html_with_http_headers parametrized_url  ));
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

subtest 'output_with_http_headers() tests' => sub {

    plan tests => 4;

    local *STDOUT;
    my $stdout;

    my $query = CGI->new();
    my $cookie;
    my $output = 'foobarbaz';

    open STDOUT, '>', \$stdout;
    t::lib::Mocks::mock_preference('AccessControlAllowOrigin','');
    output_html_with_http_headers $query, $cookie, $output, undef;
    unlike($stdout, qr/Access-control-allow-origin/, 'No header set if no value on syspref');
    close STDOUT;

    open STDOUT, '>', \$stdout;
    t::lib::Mocks::mock_preference('AccessControlAllowOrigin',undef);
    output_html_with_http_headers $query, $cookie, $output, undef;
    unlike($stdout, qr/Access-control-allow-origin/, 'No header set if no value on syspref');
    close STDOUT;

    open STDOUT, '>', \$stdout;
    t::lib::Mocks::mock_preference('AccessControlAllowOrigin','*');
    output_html_with_http_headers $query, $cookie, $output, undef;
    like($stdout, qr/Access-control-allow-origin: \*/, 'Header set to *');
    close STDOUT;

    open STDOUT, '>', \$stdout;
    t::lib::Mocks::mock_preference('AccessControlAllowOrigin','https://koha-community.org');
    output_html_with_http_headers $query, $cookie, $output, undef;
    like($stdout, qr/Access-control-allow-origin: https:\/\/koha-community\.org/, 'Header set to https://koha-community.org');
    close STDOUT;
};
