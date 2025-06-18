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

use CGI qw ( -utf8 );

use C4::Auth qw( get_template_and_user checkpw checkpw_hash );
use C4::Context;
use C4::Output qw( output_html_with_http_headers );
use Koha::Patrons;

use Try::Tiny qw( catch try );

my $query = CGI->new;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-reset-password.tt",
        query           => $query,
        type            => "opac",
        authnotrequired => 1,
    }
);

my $op = $query->param('op');

if ( $op eq 'cud-update' ) {
    my $userid          = $query->param('userid');
    my $currentpassword = $query->param('currentpassword');
    my $newpassword     = $query->param('newpassword');
    my $confirmpassword = $query->param('confirmpassword');

    my $patron = Koha::Patrons->find_by_identifier($userid);

    if ( $patron && $patron->password_expiration_date ) {
        if ( $patron->account_locked ) {
            $template->param( error => 'account_locked' );
        } elsif ( $currentpassword && $newpassword && $confirmpassword ) {
            my $error;
            if ( C4::Auth::checkpw_hash( $currentpassword, $patron->password ) ) {

                if ( $newpassword ne $confirmpassword ) {
                    $template->param( 'error' => 'passwords_mismatch' );
                } elsif ( $currentpassword eq $newpassword ) {
                    $template->param( 'error' => 'no_change' );
                } else {
                    try {
                        $patron->set_password( { password => $newpassword } );
                        $template->param( 'password_updated' => '1' );
                        $template->param( 'staff_access'     => 1 )
                            if $patron->has_permission( { catalogue => 1 } );
                    } catch {
                        $error = 'password_too_short'
                            if $_->isa('Koha::Exceptions::Password::TooShort');
                        $error = 'password_too_weak'
                            if $_->isa('Koha::Exceptions::Password::TooWeak');
                        $error = 'password_has_whitespaces'
                            if $_->isa('Koha::Exceptions::Password::WhitespaceCharacters');
                        $template->param( 'error' => $error );
                    };
                }
            } else {
                $template->param( 'error' => 'invalid_credentials' );
                $patron->update( { login_attempts => $patron->login_attempts + 1 } )
                    if !$patron->account_locked;
            }
        } else {
            $template->param( 'incomplete_form' => '1' );
        }
    } elsif ( !$patron ) {
        template->param( 'error' => 'invalid_credentials' );
    } elsif ( !$patron->password_expiration_date ) {
        $template->param( 'error' => 'no_expire' );
    } else {
        $template->param( 'error' => 'unknown' );
    }
}

output_html_with_http_headers $query, $cookie, $template->output, undef,
    { force_no_caching => 1 };
