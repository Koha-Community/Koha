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

use Test::More; #See plan tests => \d+ below
use LWP::UserAgent;

my $intranet = $ENV{KOHA_INTRANET_URL};

eval{
    use C4::Context;
};
if ($@) {
    plan skip_all => "Tests skip. You must have a working Context\n";
}
elsif (not defined $intranet) {
    plan skip_all => "Tests skip. You must set env. variable KOHA_INTRANET_URL to do tests\n";
}
else {
    plan tests => 1;
}

$intranet =~ s#/$##;

my $api_base_url = "$intranet/api/v1";
subtest 'non-existent routes' => sub {
    plan tests => 1;
    my $response = LWP::UserAgent->new->get($api_base_url . "/does_not_exist");
    is( $response->code, 404, "REST API should return 404 on non-existent routes" );
};
