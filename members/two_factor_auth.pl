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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use CGI qw(-utf8);

use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_and_exit output_html_with_http_headers );

use Koha::Patrons;
use Koha::Auth::TwoFactorAuth;

my $cgi = CGI->new;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => 'members/two_factor_auth.tt',
        query         => $cgi,
        type          => 'intranet',
        flagsrequired => { catalogue => 1 },
    }
);

my $TwoFactorAuthentication = C4::Context->preference('TwoFactorAuthentication');
if ( $TwoFactorAuthentication ne 'enabled' && $TwoFactorAuthentication ne 'enforced' ) {
    print $cgi->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

my $op        = $cgi->param('op')             // '';
my $patron_id = $cgi->param('borrowernumber') // '';

my $another_user = $patron_id ne $loggedinuser;

my $logged_in_user = Koha::Patrons->find($loggedinuser);

if ( $another_user && !$logged_in_user->is_superlibrarian() ) {
    print $cgi->redirect("/cgi-bin/koha/errors/403.pl");
    exit;
}

my $patron =
    $another_user
    ? Koha::Patrons->find($patron_id)
    : $logged_in_user;

if ( !$patron ) {
    print $cgi->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

if ( !C4::Context->config('encryption_key') ) {
    $template->param( missing_key => 1 );
} else {

    if ( $op eq 'cud-disable-2FA' ) {

        $patron->reset_2fa();

        if ( $patron->notice_email_address ) {
            $patron->queue_notice(
                {
                    letter_params => {
                        module      => 'members',
                        letter_code => '2FA_DISABLE',
                        branchcode  => $patron->branchcode,
                        lang        => $patron->lang,
                        tables      => {
                            branches  => $patron->branchcode,
                            borrowers => $patron->id
                        },
                    },
                    message_transports => ['email'],
                }
            );
        }
    }
}

$template->param(
    another_user => $another_user,
    op           => $op,
    patron       => $patron,
);

output_html_with_http_headers $cgi, $cookie, $template->output;
