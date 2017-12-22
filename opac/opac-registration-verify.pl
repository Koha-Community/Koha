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

use CGI qw ( -utf8 );

use C4::Auth;
use C4::Output;
use C4::Members;
use C4::Form::MessagingPreferences;
use Koha::Patrons;
use Koha::Patron::Modifications;

my $cgi = new CGI;
my $dbh = C4::Context->dbh;

unless ( C4::Context->preference('PatronSelfRegistration') ) {
    print $cgi->redirect("/cgi-bin/koha/opac-main.pl");
    exit;
}

my $token = $cgi->param('token');
my $m = Koha::Patron::Modifications->find( { verification_token => $token } );

my ( $template, $borrowernumber, $cookie );

if (
    $m # The token exists and the email is unique if requested
    and not(
            C4::Context->preference('PatronSelfRegistrationEmailMustBeUnique')
        and Koha::Patrons->search( { email => $m->email } )->count
    )
  )
{
    ( $template, $borrowernumber, $cookie ) = get_template_and_user(
        {
            template_name   => "opac-registration-confirmation.tt",
            type            => "opac",
            query           => $cgi,
            authnotrequired => 1,
        }
    );

    $template->param(
        OpacPasswordChange => C4::Context->preference('OpacPasswordChange') );

    my $borrower = $m->unblessed();

    my $password;
    ( $borrowernumber, $password ) = AddMember_Opac(%$borrower);

    if ($borrowernumber) {
        $m->delete();
        C4::Form::MessagingPreferences::handle_form_action($cgi, { borrowernumber => $borrowernumber }, $template, 1, C4::Context->preference('PatronSelfRegistrationDefaultCategory') ) if C4::Context->preference('EnhancedMessagingPreferences');

        $template->param( password_cleartext => $password );
        my $patron = Koha::Patrons->find( $borrowernumber );
        $template->param( borrower => $patron->unblessed );
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
            template_name   => "opac-registration-invalid.tt",
            type            => "opac",
            query           => $cgi,
            authnotrequired => 1,
        }
    );
}

output_html_with_http_headers $cgi, $cookie, $template->output;
