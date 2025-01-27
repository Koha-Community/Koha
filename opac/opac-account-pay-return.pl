#!/usr/bin/perl

# Copyright ByWater Solutions 2017
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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use CGI;

use C4::Auth qw( checkauth );
use Koha::Plugins::Handler;

my $cgi = CGI->new;

my ( $userid, $cookie, $sessionID, $flags ) = checkauth( $cgi, 0, {}, 'opac' );

# Check for payment method in both POST and GET vars
my $payment_method = $cgi->param('payment_method') || $cgi->url_param('payment_method');

my $can_handle_payment = Koha::Plugins::Handler->run(
    {
        class  => $payment_method,
        method => 'opac_online_payment',
        cgi    => $cgi,
    }
);

if ($can_handle_payment) {
    Koha::Plugins::Handler->run(
        {
            class  => $payment_method,
            method => 'opac_online_payment_end',
            cgi    => $cgi,
        }
    );
} else {
    print $cgi->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}
