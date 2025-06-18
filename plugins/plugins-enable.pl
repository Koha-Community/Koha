#!/usr/bin/perl
#
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use CGI qw ( -utf8 );

use C4::Context;
use C4::Auth qw( check_cookie_auth );
use Koha::Plugins::Handler;

die("Koha plugins are disabled!") unless C4::Context->config("enable_plugins");

my $input = CGI->new;

my ($auth_status) = check_cookie_auth( $input->cookie('CGISESSID'), { plugins => 'manage' } );
if ( $auth_status ne 'ok' ) {
    print CGI::header( '-status' => '401' );
    exit 0;
}

my $class  = $input->param('class');
my $method = $input->param('method');

Koha::Plugins::Handler->run(
    {
        class  => $class,
        method => $method
    }
);

print $input->redirect("/cgi-bin/koha/plugins/plugins-home.pl");
