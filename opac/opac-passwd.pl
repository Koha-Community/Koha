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
use Digest::MD5 qw(md5_base64);
use C4::Circulation;
use C4::Members;
use C4::Output;
use Koha::AuthUtils qw(hash_password);
use Koha::Patrons;

my $query = new CGI;
my $dbh   = C4::Context->dbh;

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
if ( C4::Context->preference("OpacPasswordChange") ) {
    my $sth =  $dbh->prepare("UPDATE borrowers SET password = ? WHERE borrowernumber=?");
    if (   $query->param('Oldkey')
        && $query->param('Newkey')
        && $query->param('Confirm') )
    {
        my $error;
        my $new_password = $query->param('Newkey');
        my $confirm_password = $query->param('Confirm');
        if ( goodkey( $dbh, $borrowernumber, $query->param('Oldkey') ) ) {

            if ( $new_password ne $confirm_password ) {
                $template->param( 'Ask_data'       => '1' );
                $template->param( 'Error_messages' => '1' );
                $template->param( 'passwords_mismatch'   => '1' );
            } else {
                my ( $is_valid, $error ) = Koha::AuthUtils::is_password_valid( $new_password );
                unless ( $is_valid ) {
                    $error = 'password_too_short' if $error eq 'too_short';
                    $error = 'password_too_weak' if $error eq 'too_weak';
                    $error = 'password_has_whitespaces' if $error eq 'has_whitespaces';
                } else {
                    # Password is valid and match
                    my $clave = hash_password( $new_password );
                    $sth->execute( $clave, $borrowernumber );
                    $template->param( 'password_updated' => '1' );
                    $template->param( 'borrowernumber'   => $borrowernumber );
                }
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
            # Old password is empty but one of the others isnt
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

sub goodkey {
    my ( $dbh, $borrowernumber, $key ) = @_;

    my $sth =
      $dbh->prepare("SELECT password FROM borrowers WHERE borrowernumber=?");
    $sth->execute($borrowernumber);
    if ( $sth->rows ) {
        my $hash;
        my ($stored_hash) = $sth->fetchrow;
        if ( substr($stored_hash,0,2) eq '$2') {
            $hash = hash_password($key, $stored_hash);
        } else {
            $hash = md5_base64($key);
        }
        if ( $hash eq $stored_hash ) { return 1; }
        else { return 0; }
    }
    else { return 0; }
}
