#!/usr/bin/perl

# Copyright 2014 PTFS Europe Ltd.
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

use CGI;

use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use Koha::Database;
use Koha::EDI qw( process_invoice );

my $q = CGI->new;
my ( $template, $loggedinuser, $cookie, $userflags ) = get_template_and_user(
    {
        template_name => 'acqui/edifactmsgs.tt',
        query         => $q,
        type          => 'intranet',
        flagsrequired => { acquisition => 'edi_manage' },
    }
);

my $schema = Koha::Database->new()->schema();
my $cmd    = $q->param('op');
if ( $cmd && $cmd eq 'cud-delete' ) {
    my $id  = $q->param('message_id');
    my $msg = $schema->resultset('EdifactMessage')->find($id);
    $msg->deleted(1);
    $msg->update;
}

if ( $cmd && $cmd eq 'import' ) {
    my $id      = $q->param('message_id');
    my $invoice = $schema->resultset('EdifactMessage')->find($id);
    process_invoice($invoice);
}

output_html_with_http_headers( $q, $cookie, $template->output );
