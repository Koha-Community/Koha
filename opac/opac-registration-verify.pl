#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use CGI;

use C4::Auth;
use C4::Output;
use C4::Members;
use Koha::Borrower::Modifications;

my $cgi = new CGI;
my $dbh = C4::Context->dbh;

unless ( C4::Context->preference('PatronSelfRegistration') ) {
    print $cgi->redirect("/cgi-bin/koha/opac-main.pl");
    exit;
}

my $token = $cgi->param('token');
my $m = Koha::Borrower::Modifications->new( verification_token => $token );

my ( $template, $borrowernumber, $cookie );
if ( $m->Verify() ) {
    ( $template, $borrowernumber, $cookie ) = get_template_and_user(
        {
            template_name   => "opac-registration-confirmation.tmpl",
            type            => "opac",
            query           => $cgi,
            authnotrequired => 1,
        }
    );

    $template->param(
        OpacPasswordChange => C4::Context->preference('OpacPasswordChange') );

    my $borrower = $m->GetModifications();

    my $password;
    ( $borrowernumber, $password ) = AddMember_Opac(%$borrower);

    if ($borrowernumber) {
        Koha::Borrower::Modifications->DelModifications({ verification_token => $token });

        $template->param( password_cleartext => $password );
        $template->param(
            borrower => GetMember( borrowernumber => $borrowernumber ) );
        $template->param(
            PatronSelfRegistrationAdditionalInstructions =>
              C4::Context->preference(
                'PatronSelfRegistrationAdditionalInstructions')
        );
    }

}
else {
    ( $template, $borrowernumber, $cookie ) = get_template_and_user(
        {
            template_name   => "opac-registration-invalid.tmpl",
            type            => "opac",
            query           => $cgi,
            authnotrequired => 1,
        }
    );
}

output_html_with_http_headers $cgi, $cookie, $template->output;
