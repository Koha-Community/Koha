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

my $logged_in_user = Koha::Patrons->find($loggedinuser);
my $op             = $cgi->param('op') // '';

if ( !C4::Context->config('encryption_key') ) {
    $template->param( missing_key => 1 );
} else {

    my $csrf_pars = {
        session_id => scalar $cgi->cookie('CGISESSID'),
        token      => scalar $cgi->param('csrf_token'),
    };

    if ( $op eq 'cud-disable-2FA' ) {
        my $auth = Koha::Auth::TwoFactorAuth->new( { patron => $logged_in_user } );
        $logged_in_user->secret(undef);
        $logged_in_user->auth_method('password')->store;
        if ( $logged_in_user->notice_email_address ) {
            $logged_in_user->queue_notice(
                {
                    letter_params => {
                        module      => 'members',
                        letter_code => '2FA_DISABLE',
                        branchcode  => $logged_in_user->branchcode,
                        lang        => $logged_in_user->lang,
                        tables      => {
                            branches  => $logged_in_user->branchcode,
                            borrowers => $logged_in_user->id
                        },
                    },
                    message_transports => ['email'],
                }
            );
        }
    }
}

$template->param(
    patron => $logged_in_user,
    op     => $op,
);

output_html_with_http_headers $cgi, $cookie, $template->output;
