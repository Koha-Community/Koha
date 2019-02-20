#!/usr/bin/perl
# This script lets the users change the passwords by themselves.
#
# (c) 2005 Universidad ORT Uruguay.
#
# This file is part of the extensions and enhacments made to koha by Universidad ORT Uruguay
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

use C4::Auth;    # checkauth, getborrowernumber.
use C4::Context;
use C4::Circulation;
use C4::Members;
use C4::Output;
use Koha::Patrons;

use Try::Tiny;

my $query = new CGI;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-passwd.tt",
        query           => $query,
        type            => "opac",
        authnotrequired => 0,
        debug           => 1,
    }
);

my $patron = Koha::Patrons->find( $borrowernumber );
if ( $patron->category->effective_change_password ) {
    if (   $query->param('Oldkey')
        && $query->param('Newkey')
        && $query->param('Confirm') )
    {
        my $error;
        my $new_password = $query->param('Newkey');
        my $confirm_password = $query->param('Confirm');
        if ( C4::Auth::checkpw_hash( scalar $query->param('Oldkey'), $patron->password ) ) {

            if ( $new_password ne $confirm_password ) {
                $template->param( 'Ask_data'       => '1' );
                $template->param( 'Error_messages' => '1' );
                $template->param( 'passwords_mismatch'   => '1' );
            } else {
                try {
                    $patron->set_password({ password => $new_password });
                    $template->param( 'password_updated' => '1' );
                    $template->param( 'borrowernumber'   => $borrowernumber );
                }
                catch {
                    $error = 'password_too_short'
                        if $_->isa('Koha::Exceptions::Password::TooShort');
                    $error = 'password_too_weak'
                        if $_->isa('Koha::Exceptions::Password::TooWeak');
                    $error = 'password_has_whitespaces'
                        if $_->isa('Koha::Exceptions::Password::WhitespaceCharacters');
                };
            }
        }
        else {
            $error = 'WrongPass';
        }
        if ($error) {
            $template->param(
                Ask_data       => 1,
                Error_messages => 1,
                $error         => 1,
            );

        }
    }
    else {

        # Called Empty, Ask for data.
        $template->param( 'Ask_data' => '1' );
        if (!$query->param('Oldkey') && ($query->param('Newkey') || $query->param('Confirm'))){
            # Old password is empty but one of the others isn't
            $template->param( 'Error_messages' => '1' );
            $template->param( 'WrongPass'      => '1' );
        }
        elsif ($query->param('Oldkey') && (!$query->param('Newkey') || !$query->param('Confirm'))){
            # Oldpassword is entered but one of the other fields is empty
            $template->param( 'Error_messages' => '1' );
            $template->param( 'PassMismatch'   => '1' );
        }
    }
}
$template->param(
    firstname  => $patron->firstname,
    surname    => $patron->surname,
    passwdview => 1,
);


output_html_with_http_headers $query, $cookie, $template->output, undef, { force_no_caching => 1 };
