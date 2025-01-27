#!/usr/bin/perl

# Copyright ByWater Solutions 2015
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

use utf8;

use Modern::Perl;

use CGI;

use C4::Auth qw( get_template_and_user );
use C4::Output;
use C4::Context;
use Koha::Acquisition::Currencies;
use Koha::Database;
use Koha::Plugins::Handler;

my $cgi            = CGI->new;
my $op             = $cgi->param('op');
my $payment_method = $cgi->param('payment_method');
my @accountlines   = $cgi->multi_param('accountline');

my $use_plugin = Koha::Plugins::Handler->run(
    {
        class  => $payment_method,
        method => 'opac_online_payment',
        cgi    => $cgi,
    }
);

unless ($use_plugin) {
    print $cgi->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

unless ( $op eq 'cud-pay' ) {
    print $cgi->redirect("/cgi-bin/koha/errors/400.pl");
    exit;
}

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => "opac-account-pay-error.tt",
        query         => $cgi,
        type          => "opac",
    }
);

Koha::Plugins::Handler->run(
    {
        class  => $payment_method,
        method => 'opac_online_payment_begin',
        cgi    => $cgi,
    }
);
