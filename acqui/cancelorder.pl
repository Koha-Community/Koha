#!/usr/bin/perl

# Copyright 2014 BibLibre
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

=head1 NAME

cancelorder.pl

=head1 DESCRIPTION

Ask confirmation for cancelling an order line
and add possibility to indicate a reason for cancellation
(saved in aqorders.notes)

=cut

use Modern::Perl;

use CGI;
use C4::Auth;
use C4::Output;
use C4::Acquisition;

my $input = new CGI;
my ($template, $loggedinuser, $cookie, $flags) = get_template_and_user( {
    template_name   => 'acqui/cancelorder.tt',
    query           => $input,
    type            => 'intranet',
    authnotrequired => 0,
    flagsrequired   => { 'acquisition' => 'order_manage' },
    debug           => 1,
} );

my $action = $input->param('action');
my $ordernumber = $input->param('ordernumber');
my $biblionumber = $input->param('biblionumber');
my $referrer = $input->param('referrer') || $input->referer;
my $del_biblio = $input->param('del_biblio') ? 1 : 0;

if($action and $action eq "confirmcancel") {
    my $reason = $input->param('reason');
    my $error = DelOrder($biblionumber, $ordernumber, $del_biblio, $reason);

    if($error) {
        $template->param(error_delitem => 1) if $error->{'delitem'};
        $template->param(error_delbiblio => 1) if $error->{'delbiblio'};
    } else {
        $template->param(success_cancelorder => 1);
    }
    $template->param(confirmcancel => 1);
}

$template->param(
    ordernumber => $ordernumber,
    biblionumber => $biblionumber,
    referrer => $referrer,
    del_biblio => $del_biblio,
);

output_html_with_http_headers $input, $cookie, $template->output;
