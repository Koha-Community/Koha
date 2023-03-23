#!/usr/bin/perl

# Copyright 2023 Aleisha Amohia <aleisha@catalyst.net.nz>
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
use CGI qw ( -utf8 );
use C4::Context;
use C4::Output qw( output_html_with_http_headers );
use C4::Auth qw( get_template_and_user );
use Koha::DateUtils qw( dt_from_string );
use Koha::Patrons;

my $query = CGI->new;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-user.tt",
        query           => $query,
        type            => "opac",
    }
);

my $patron_id = $query->param('patron_id');
my $patron = Koha::Patrons->find( $patron_id );
my $message_id = $query->param('message_id');
my $message = $patron->messages->find( $message_id );

unless ( $message ) {
    # exit early
    print $query->redirect("/cgi-bin/koha/opac-user.pl");
    exit;
}

$message->update({ patron_read_date => dt_from_string });

print $query->redirect("/cgi-bin/koha/opac-user.pl");

output_html_with_http_headers $query, $cookie, $template->output, undef, { force_no_caching => 1 };
