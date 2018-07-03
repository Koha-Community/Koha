#!/usr/bin/perl

# Copyright Koha-Suomi Oy 2018
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

use CGI qw ( -utf8 );
use C4::Auth;
use C4::Output;
use C4::Templates qw/gettemplate/;
use JSON;
use Koha::Auth::Token;
use Koha::Patron::Attribute;

use Koha;

my $input = new CGI;

my $token   = $input->param("token");

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "mydata.tt",
        query           => $input,
        type            => "opac",
        authnotrequired => 0,
        debug           => 1,
    }
);

my $tokenizer = new Koha::Auth::Token;
my $resultSet = Koha::Database->new()->schema()->resultset(Koha::Patron::Attribute->_type());

my $tokenParams = {};
$tokenParams->{borrowernumber} = $borrowernumber;
$tokenParams->{code} = 'LTOKEN';

my $dbtoken = $tokenizer->getToken($resultSet, $tokenParams);
my $bornumber = $dbtoken->borrowernumber->borrowernumber if $dbtoken;
if ( defined $dbtoken && $token eq $dbtoken->attribute && $bornumber eq $borrowernumber) {

    my $logUrl = C4::Context->preference('LogInterfaceURL');
    my $personalUrl = C4::Context->preference('PersonalInterfaceURL');
    $template->param(borrowernumber => $borrowernumber, logurl => $logUrl, personalurl => $personalUrl);
    $tokenizer->delete($resultSet, $tokenParams);
	output_html_with_http_headers $input, $cookie, $template->output;
} else {
	print $input->redirect("/cgi-bin/koha/opac-main.pl");
}

1;