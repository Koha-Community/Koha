#!/usr/bin/perl
# This script lets the users change the passwords by themselves.
#
# (c) 2005 Universidad ORT Uruguay.
#
# This file is part of the extensions and enhacments made to koha by Universidad ORT Uruguay
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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
require Exporter;
use CGI;

use C4::Auth;    # checkauth, getborrowernumber.
use C4::Context;
use Digest::MD5 qw(md5_base64);
use C4::Circulation;
use C4::Members;
use C4::Output;

my $query = new CGI;
my $dbh   = C4::Context->dbh;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-passwd.tmpl",
        query           => $query,
        type            => "opac",
        authnotrequired => 0,
        flagsrequired   => { borrow => 1 },
        debug           => 1,
    }
);

# get borrower information ....
my ( $borr ) = GetMemberDetails( $borrowernumber );
my $sth =  $dbh->prepare("UPDATE borrowers SET password = ? WHERE borrowernumber=?");
my $minpasslen = C4::Context->preference("minPasswordLength");
if (   $query->param('Oldkey')
    && $query->param('Newkey')
    && $query->param('Confirm') )
{
    if ( goodkey( $dbh, $borrowernumber, $query->param('Oldkey') ) ) {
        if ( $query->param('Newkey') eq $query->param('Confirm')
            && length( $query->param('Confirm') ) >= $minpasslen )
        {    # Record password
            my $clave = md5_base64( $query->param('Newkey') );
            $sth->execute( $clave, $borrowernumber );
            $template->param( 'password_updated' => '1' );
            $template->param( 'borrowernumber'   => $borrowernumber );
        }
        elsif ( $query->param('Newkey') ne $query->param('Confirm') ) {
            $template->param( 'Ask_data'       => '1' );
            $template->param( 'Error_messages' => '1' );
            $template->param( 'PassMismatch'   => '1' );
        }
        elsif ( length( $query->param('Confirm') ) < $minpasslen ) {
            $template->param( 'Ask_data'       => '1' );
            $template->param( 'Error_messages' => '1' );
            $template->param( 'ShortPass'      => '1' );
        }
        else {
            $template->param( 'Error_messages' => '1' );
        }
    }
    else {
        $template->param( 'Ask_data'       => '1' );
        $template->param( 'Error_messages' => '1' );
        $template->param( 'WrongPass'      => '1' );
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

$template->param(firstname => $borr->{'firstname'},
							surname => $borr->{'surname'},
							minpasslen => $minpasslen,
							passwdview => 1,
);

output_html_with_http_headers $query, $cookie, $template->output;

sub goodkey {
    my ( $dbh, $borrowernumber, $key ) = @_;

    my $sth =
      $dbh->prepare("SELECT password FROM borrowers WHERE borrowernumber=?");
    $sth->execute($borrowernumber);
    if ( $sth->rows ) {
        my ($md5password) = $sth->fetchrow;
        if ( md5_base64($key) eq $md5password ) { return 1; }
        else { return 0; }
    }
    else { return 0; }
}
