#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2004 Biblibre
# Parts copyright 2011 Catalyst IT Ltd.
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
#use warnings; FIXME - Bug 2505
use CGI;
use C4::Auth;    # get_template_and_user
use C4::Output;
use C4::Acquisition;
use C4::Dates;
use C4::Debug;

my $input = new CGI;
my $title                   = $input->param( 'title');
utf8::decode($title);
my $author                  = $input->param('author');
utf8::decode($author);
my $isbn                    = $input->param('isbn');
utf8::decode($isbn);
my $name                    = $input->param( 'name' );
utf8::decode($name);
my $ean                     = $input->param('ean');
utf8::decode($ean);
my $basket                  = $input->param( 'basket' );
utf8::decode($basket);
my $basketgroupname             = $input->param('basketgroupname');
utf8::decode($basketgroupname);
my $booksellerinvoicenumber = $input->param( 'booksellerinvoicenumber' );
utf8::decode($booksellerinvoicenumber);

my $do_search               = $input->param('do_search') || 0;
my $from_placed_on          = C4::Dates->new($input->param('from'));
my $to_placed_on            = C4::Dates->new($input->param('to'));
if ( not $input->param('from') ) {
    # FIXME Dirty but we can't sent a Date::Calc to C4::Dates ?
    # We would use a function like Add_Delta_YM(-1, 0, 0);
    $$from_placed_on{dmy_arrayref}[5] -= 1;
}

my $dbh = C4::Context->dbh;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "acqui/histsearch.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => '*' },
        debug           => 1,
    }
);

my ( $from_iso, $to_iso, $d );
if ( $d = $input->param('from') ) {
    $from_iso = C4::Dates->new($d)->output('iso');
}
if ( $d = $input->param('iso') ) {
    $to_iso = C4::Dates->new($d)->output('iso');
}

my ( $order_loop, $total_qty, $total_price, $total_qtyreceived );
# If we're supplied any value then we do a search. Otherwise we don't.
if ($do_search) {
    ( $order_loop, $total_qty, $total_price, $total_qtyreceived ) = GetHistory(
        title => $title,
        author => $author,
        isbn   => $isbn,
        ean   => $ean,
        name => $name,
        from_placed_on => $from_iso,
        to_placed_on => $to_iso,
        basket => $basket,
        booksellerinvoicenumber => $booksellerinvoicenumber,
        basketgroupname => $basketgroupname,
    );
}

my $from_date = $from_placed_on ? $from_placed_on->output('syspref') : undef;
my $to_date = $to_placed_on ? $to_placed_on->output('syspref') : undef;

$template->param(
    suggestions_loop        => $order_loop,
    total_qty               => $total_qty,
    total_qtyreceived       => $total_qtyreceived,
    total_price             => sprintf( "%.2f", $total_price ),
    numresults              => $order_loop ? scalar(@$order_loop) : undef,
    title                   => $title,
    author                  => $author,
    isbn		    => $isbn,
    ean                     => $ean,
    name                    => $name,
    basket                  => $basket,
    booksellerinvoicenumber => $booksellerinvoicenumber,
    basketgroupname         => $basketgroupname,
    from_placed_on          => $from_date,
    to_placed_on            => $to_date,
    debug                   => $debug || $input->param('debug') || 0,
    uc(C4::Context->preference("marcflavour")) => 1
);

output_html_with_http_headers $input, $cookie, $template->output;
