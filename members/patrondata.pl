#!/usr/bin/perl

# Copyright 2018 Koha-Suomi Oy
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

use C4::Auth qw(check_cookie_auth);
use CGI qw ( -utf8 );
use C4::Context;
use C4::Koha;
use C4::Output;
use C4::Log;
use C4::Debug;
use Koha::Auth::Token;
use Koha::Patron::Attribute;

my $input = new CGI;

my ( $auth_status, $sessionID ) =
  check_cookie_auth( $input->cookie('CGISESSID'),
    { privacy => 'patron_data' } );

if ( $auth_status ne "ok" ) {
    exit 0;
}

my $email = $input->param("email");
my $bornumber = $input->param("borrowernumber");

if ($email) {
    my $tokenizer = new Koha::Auth::Token;
    my $resultSet = Koha::Database->new()->schema()->resultset(Koha::Patron::Attribute->_type());

    my $tokenParams = {};
    $tokenParams->{borrowernumber} = $bornumber;
    $tokenParams->{code} = 'LTOKEN';

    $tokenizer->setToken($resultSet, 'attribute', $tokenParams);

    my $token = $tokenizer->getToken($resultSet, $tokenParams);

    # create link
    my $opacbase = C4::Context->preference('OPACBaseURL') || '';
    my $tokenLink = $opacbase
      . "/cgi-bin/koha/mydata.pl?token=".$token->attribute;

    my $patron = Koha::Patrons->find( $bornumber );

    # prepare the email
    my $letter = C4::Letters::GetPreparedLetter(
        module      => 'members',
        letter_code => 'PATRON_DATA',
        branchcode  => $patron->branchcode,
        lang        => $patron->lang,
        tables => {
            'borrowers'   => $bornumber,
        },
        substitute => { mydataurl => $tokenLink, user => $patron->userid },
    );

    # define to/from emails
    my $kohaEmail = C4::Context->preference('KohaAdminEmailAddress');    # from

    C4::Letters::EnqueueLetter(
        {
            letter                 => $letter,
            borrowernumber         => $bornumber,
            to_address             => $email,
            from_address           => $kohaEmail,
            message_transport_type => 'email',
        }
    );
    C4::Log::logaction("MEMBERS", "SENT", $bornumber, "Sent patron data to ".$email) if C4::Context->preference("BorrowersLog");
}

print $input->redirect("/cgi-bin/koha/members/moremember.pl?borrowernumber=".$bornumber);