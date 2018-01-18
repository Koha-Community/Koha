#!/usr/bin/perl

# Copyright 2014 PTFS Europe Ltd.
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use CGI;
use Koha::Database;
use C4::Koha;
use C4::Auth;
use C4::Output;

my $q = CGI->new;
my ( $template, $loggedinuser, $cookie, $userflags ) = get_template_and_user(
    {
        template_name   => 'acqui/edifactmsgs.tt',
        query           => $q,
        type            => 'intranet',
        authnotrequired => 0,
        flagsrequired   => { acquisition => 'manage_edi' },
        debug           => 1,
    }
);

my $schema = Koha::Database->new()->schema();
my $cmd    = $q->param('op');
if ( $cmd && $cmd eq 'delete' ) {
    my $id  = $q->param('message_id');
    my $msg = $schema->resultset('EdifactMessage')->find($id);
    $msg->deleted(1);
    $msg->update;
}

my @msgs = $schema->resultset('EdifactMessage')->search(
    {
        deleted => 0,
    },
    {
        join     => 'vendor',
        order_by => { -desc => 'transfer_date' },
    }

)->all;

$template->param( messages => \@msgs );

output_html_with_http_headers( $q, $cookie, $template->output );
