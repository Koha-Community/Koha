#!/usr/bin/perl

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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA


=head1 NAME

histsearch.pl

=head1 DESCRIPTION

this script offer a interface to search among order.

=head1 CGI PARAMETERS

=over 4

=item title
if the script has to filter the results on title.

=item author
if the script has to filter the results on author.

=item name
if the script has to filter the results on supplier.

=item fromplacedon
to filter on started date.

=item toplacedon
to filter on ended date.

=back

=cut

use strict;
require Exporter;
use CGI;
use C4::Auth;    # get_template_and_user
use C4::Output;
use C4::Acquisition;
use C4::Dates;

use vars qw($debug);

BEGIN {
        $debug = $ENV{DEBUG} || 0;
}

my $input          = new CGI;
$debug or $debug = $input->param('debug') || 0;
my $title          = $input->param( 'title');
my $author         = $input->param('author');
my $name           = $input->param( 'name' );
my $from_placed_on = C4::Dates->new($input->param('from'));
my $to_placed_on   = C4::Dates->new($input->param(  'to'));

my $dbh = C4::Context->dbh;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "acqui/histsearch.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => 1 },
        debug           => 1,
    }
);

my $from_iso = C4::Dates->new($input->param('from'))->output('iso') if $input->param('from');
my   $to_iso =   C4::Dates->new($input->param('to'))->output('iso') if $input->param('iso');
my ( $order_loop, $total_qty, $total_price, $total_qtyreceived ) =
  &GetHistory( $title, $author, $name, $from_iso, $to_iso );
  
$template->param(
    suggestions_loop        => $order_loop,
    total_qty               => $total_qty,
    total_qtyreceived       => $total_qtyreceived,
    total_price             => sprintf( "%.2f", $total_price ),
    numresults              => scalar(@$order_loop),
    title                   => $title,
    author                  => $author,
    name                    => $name,
    from_placed_on          => $from_placed_on->output('syspref'),
    to_placed_on            =>   $to_placed_on->output('syspref'),
    DHTMLcalendar_dateformat=> C4::Dates->DHTMLcalendar(),
	dateformat              => C4::Dates->new()->format(),
    debug                   => $debug,
);

output_html_with_http_headers $input, $cookie, $template->output;
