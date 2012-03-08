#!/usr/bin/perl

# Copyright 2011 BibLibre SARL
# This file is part of Koha.
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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

=head1 NAME

subscription-history.pl

=head1 DESCRIPTION

Modify subscription history

=cut

use Modern::Perl;

use CGI;
use C4::Auth;
use C4::Output;

use C4::Biblio;
use C4::Dates qw(format_date_in_iso);
use C4::Serials;

my $input = new CGI;
my ($template, $loggedinuser, $cookie, $flags) = get_template_and_user( {
    template_name   => 'serials/subscription-history.tt',
    query           => $input,
    type            => 'intranet',
    authnotrequired => 0,
    flagsrequired   => { 'serials' => 'edit_subscription' },
    debug           => 1,
} );

my $subscriptionid  = $input->param('subscriptionid');
my $op              = $input->param('op');

if(!defined $subscriptionid || $subscriptionid eq '') {
    print $input->redirect('/cgi-bin/koha/serials/serials-home.pl');
    exit;
}

if($op && $op eq 'mod') {
    my $histstartdate   = $input->param('histstartdate');
    my $histenddate     = $input->param('histenddate');
    my $receivedlist    = $input->param('receivedlist');
    my $missinglist     = $input->param('missinglist');
    my $opacnote        = $input->param('opacnote');
    my $librariannote   = $input->param('librariannote');

    ModSubscriptionHistory( $subscriptionid, format_date_in_iso($histstartdate),
        format_date_in_iso($histenddate), $receivedlist, $missinglist, $opacnote,
        $librariannote );

    print $input->redirect("/cgi-bin/koha/serials/subscription-detail.pl?subscriptionid=$subscriptionid");
    exit;
} else {
    my $history = GetSubscriptionHistoryFromSubscriptionId($subscriptionid);
    my (undef, $biblio) = GetBiblio($history->{'biblionumber'});

    $template->param(
        subscriptionid  => $subscriptionid,
        title           => $biblio->{'title'},
        histstartdate   => $history->{'histstartdate'},
        histenddate     => $history->{'histenddate'},
        receivedlist    => $history->{'recievedlist'},
        missinglist     => $history->{'missinglist'},
        opacnote        => $history->{'opacnote'},
        librariannote   => $history->{'librariannote'},
    );

    output_html_with_http_headers $input, $cookie, $template->output;
}
