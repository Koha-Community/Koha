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
use Try::Tiny;

use C4::Auth qw( get_template_and_user );
use C4::Context;
use C4::Output  qw( output_html_with_http_headers );
use C4::Letters qw( GetPreparedLetter EnqueueLetter SendQueuedMessages );
use C4::Members;
use C4::Members::Messaging qw( SetMessagingPreferencesFromDefaults );
use C4::Form::MessagingPreferences;
use Koha::AuthUtils;
use Koha::Patrons;
use Koha::Patron::Consent;
use Koha::Patron::Modifications;
use Koha::Patron::Categories;

my $cgi = CGI->new;
my $dbh = C4::Context->dbh;

unless ( C4::Context->preference('PatronSelfRegistration') ) {
    print $cgi->redirect("/cgi-bin/koha/opac-main.pl");
    exit;
}

my $token = $cgi->param('token');
my $op    = $cgi->param('op');
my $confirmed;
if ( $op && $op eq 'cud-confirmed' ) {
    $confirmed = 1;
}
my $m = Koha::Patron::Modifications->find( { verification_token => $token } );

my ( $template, $borrowernumber, $cookie );
my ( $error_type, $error_info );

my $rego_found;
if (
    $m    # The token exists and the email is unique if requested
    and not(C4::Context->preference('PatronSelfRegistrationEmailMustBeUnique')
        and Koha::Patrons->search( { email => $m->email } )->count )
    )
{
    $rego_found = 1;
}

if ( $rego_found
    and !$confirmed )
{
    ( $template, $borrowernumber, $cookie ) = get_template_and_user(
        {
            template_name   => "opac-registration-confirmation.tt",
            type            => "opac",
            query           => $cgi,
            authnotrequired => C4::Context->preference("OpacPublic") ? 1 : 0,
        }
    );
    $template->param( "token" => $token );
} elsif ( $rego_found
    and $confirmed )
{
    my $patron_attrs = $m->unblessed;
    $patron_attrs->{password} ||=
        Koha::AuthUtils::generate_password( Koha::Patron::Categories->find( $patron_attrs->{categorycode} ) );
    my $consent_dt = delete $patron_attrs->{gdpr_proc_consent};
    $patron_attrs->{categorycode} ||= C4::Context->preference('PatronSelfRegistrationDefaultCategory');
    delete $patron_attrs->{timestamp};
    delete $patron_attrs->{verification_token};
    delete $patron_attrs->{changed_fields};
    delete $patron_attrs->{extended_attributes};

    my $patron;
    try {
        $patron = Koha::Patron->new($patron_attrs)->store;
        Koha::Patron::Consent->new(
            { borrowernumber => $patron->borrowernumber, type => 'GDPR_PROCESSING', given_on => $consent_dt } )->store
            if $patron && $consent_dt;
        C4::Members::Messaging::SetMessagingPreferencesFromDefaults(
            { borrowernumber => $patron->borrowernumber, categorycode => $patron->categorycode } );
    } catch {
        $error_type = ref($_);
        $error_info = "$_";
    };

    if ($patron) {
        if ( $m->extended_attributes ) {
            $m->borrowernumber( $patron->borrowernumber );
            $m->changed_fields( ['extended_attributes'] );
            $m->approve();
        } else {
            $m->delete();
        }
        ( $template, $borrowernumber, $cookie ) = get_template_and_user(
            {
                template_name   => "opac-registration-confirmation.tt",
                type            => "opac",
                query           => $cgi,
                authnotrequired => C4::Context->preference("OpacPublic") ? 1 : 0,
            }
        );
        $template->param( "confirmed" => 1 );

        $template->param( password_cleartext => $patron->plain_text_password );
        $template->param( borrower           => $patron );

        # If 'AutoEmailNewUser' syspref is on, email user their account details from the 'notice' that matches the user's branchcode.
        if ( C4::Context->preference("AutoEmailNewUser") ) {

            # Look up correct email address taking EmailFieldPrimary into account
            my $emailaddr = $patron->notice_email_address;

            # if we manage to find a valid email address, send notice
            if ($emailaddr) {
                eval {
                    my $letter = GetPreparedLetter(
                        module      => 'members',
                        letter_code => 'WELCOME',
                        branchcode  => $patron->branchcode,,
                        lang        => $patron->lang || 'default',
                        tables      => {
                            'branches'  => $patron->branchcode,
                            'borrowers' => $patron->borrowernumber,
                        },
                        want_librarian => 1,
                    ) or return;

                    my $message_id = EnqueueLetter(
                        {
                            letter                 => $letter,
                            borrowernumber         => $patron->id,
                            to_address             => $emailaddr,
                            message_transport_type => 'email'
                        }
                    );
                    SendQueuedMessages( { message_id => $message_id } ) if $message_id;
                };
            }
        }

        # Notify library of new patron registration
        my $notify_library = C4::Context->preference("EmailPatronRegistrations");
        if ($notify_library) {
            $patron->notify_library_of_registration($notify_library);
        }

        my ( $theme, $news_lang, $availablethemes ) = C4::Templates::themelanguage(
            C4::Context->config('opachtdocs'), 'opac-registration-confirmation.tt',
            'opac',                            $cgi
        );
        $template->param( news_lang => $news_lang );
    }
}

if ( !$template ) {    # Missing token, patron exception, etc.
    ( $template, $borrowernumber, $cookie ) = get_template_and_user(
        {
            template_name   => "opac-registration-invalid.tt",
            type            => "opac",
            query           => $cgi,
            authnotrequired => C4::Context->preference("OpacPublic") ? 1 : 0,
        }
    );
    $template->param( error_type => $error_type, error_info => $error_info );
}

output_html_with_http_headers $cgi, $cookie, $template->output;
