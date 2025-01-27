#!/usr/bin/perl

# Copyright 2012 ByWater Solutions
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

=head1 printslip.pl

Script to allow SCO patrons to print a receipt for their checkout.

It is called from sco-main.pl

=cut

use Modern::Perl;
use CGI qw ( -utf8 );
use C4::Context;
use C4::Auth    qw( in_iprange get_session get_template_and_user );
use C4::Output  qw( output_html_with_http_headers );
use C4::Members qw( IssueSlip );

my $input = CGI->new;
unless ( C4::Context->preference('WebBasedSelfCheck') ) {

    # redirect to OPAC home if self-check is not enabled
    print $input->redirect("/cgi-bin/koha/opac-main.pl");
    exit;
}

unless ( in_iprange( C4::Context->preference('SelfCheckAllowByIPRanges') ) ) {

    # redirect to OPAC home if self-checkout not permitted from current IP
    print $input->redirect("/cgi-bin/koha/opac-main.pl");
    exit;
}

$input->param( -name => 'sco_user_login', -values => [1] );

# patrons still need to be able to print receipts
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "sco/printslip.tt",
        flagsrequired => { self_check => "self_checkout_module" },
        query         => $input,
        type          => "opac",
    }
);

my $jwt      = $input->cookie('JWT');
my $patronid = $jwt      ? Koha::Token->new->decode_jwt( { token => $jwt } )  : undef;
my $patron   = $patronid ? Koha::Patrons->find( { cardnumber => $patronid } ) : undef;

unless ($patron) {
    print $input->header( -type => 'text/plain', -status => '403 Forbidden' );
    exit;
}

my $print = $input->param('print');
my $error = $input->param('error');

my ( $slip, $is_html );
if ( my $letter =
    IssueSlip( Koha::Patrons->find($loggedinuser)->branchcode, $patron->borrowernumber, $print eq "qslip" ) )
{
    $slip    = $letter->{content};
    $is_html = $letter->{is_html};
}

$template->{VARS}->{slip}           = $slip;
$template->{VARS}->{plain}          = !$is_html;
$template->{VARS}->{borrowernumber} = $patron->borrowernumber;
$template->{VARS}->{stylesheet}     = C4::Context->preference("SlipCSS");
$template->{VARS}->{error}          = $error;

output_html_with_http_headers $input, $cookie, $template->output;
