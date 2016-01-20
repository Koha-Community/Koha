#!/usr/bin/perl

# Copyright 2009 PTFS Inc.
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

use C4::Auth;
use C4::Output;
use Koha::Patron::Message;

my $input = new CGI;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "circ/circulation.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { borrowers => 1 },
        debug           => 1,
    }
);

my $borrowernumber   = $input->param('borrowernumber');
my $branchcode       = $input->param('branchcode');
my $message_type     = $input->param('message_type');
my $borrower_message = $input->param('borrower_message');

Koha::Patron::Message->new(
    {
        borrowernumber => $borrowernumber,
        branchcode     => $branchcode,
        message_type   => $message_type,
        message        => $borrower_message,
    }
);

print $input->redirect(
    "/cgi-bin/koha/circ/circulation.pl?borrowernumber=$borrowernumber");
