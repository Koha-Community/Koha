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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use CGI qw ( -utf8 );

use C4::Auth qw( get_template_and_user );
use C4::Output;
use Koha::Patron::Messages;

my $input = CGI->new;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "circ/circulation.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { borrowers => 'edit_borrowers' },
    }
);

my $op             = $input->param('op');
my $borrowernumber = $input->param('borrowernumber');
my $message_id     = $input->param('message_id');

my $message = Koha::Patron::Messages->find($message_id);
if (   $message
    && !C4::Context->preference('AllowAllMessageDeletion')
    && C4::Context->userenv->{'branch'} ne $message->branchcode )
{
    print $input->redirect("/cgi-bin/koha/errors/403.pl");
    exit;
}

$message->delete if $message && $op eq 'cud-delete';

if ( $input->param('from') && $input->param('from') eq "moremember" ) {
    print $input->redirect("/cgi-bin/koha/members/moremember.pl?borrowernumber=$borrowernumber");
} else {
    print $input->redirect("/cgi-bin/koha/circ/circulation.pl?borrowernumber=$borrowernumber");
}
