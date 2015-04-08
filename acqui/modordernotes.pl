#!/usr/bin/perl

# Copyright 2011 BibLibre SARL
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

modordernotes.pl

=head1 DESCRIPTION

Modify just notes when basket is closed.

=cut

use Modern::Perl;

use CGI;
use C4::Auth;
use C4::Output;
use C4::Acquisition;
use C4::Bookseller qw( GetBookSellerFromId);

my $input = new CGI;
my ($template, $loggedinuser, $cookie, $flags) = get_template_and_user( {
    template_name   => 'acqui/modordernotes.tt',
    query           => $input,
    type            => 'intranet',
    authnotrequired => 0,
    flagsrequired   => { 'acquisition' => '*' },
    debug           => 1,
} );

my $op = $input->param('op');
my $ordernumber = $input->param('ordernumber');
my $referrer = $input->param('referrer') || $input->referer();
my $type = $input->param('type');
my $order = GetOrder($ordernumber);
my $basket = GetBasket($order->{basketno});
my ($bookseller) = GetBookSellerFromId($basket->{booksellerid});


if($op and $op eq 'save') {
    my $ordernotes = $input->param('ordernotes');
    if ($type eq "vendor") {
        $order->{'order_vendornote'} = $ordernotes;
    } else {
        $order->{'order_internalnote'} = $ordernotes;
    }
    ModOrder($order);
    print $input->redirect($referrer);
    exit;
} else {
    if ($type eq "vendor") {
        $template->param(ordernotes => $order->{'order_vendornote'});
    } else {
        $template->param(ordernotes => $order->{'order_internalnote'});
    }
}

if($op) {
    $template->param($op => 1);
}

$template->param(
    basketname           => $basket->{'basketname'},
    basketno             => $order->{basketno},
    booksellerid         => $bookseller->{'id'},
    booksellername       => $bookseller->{'name'},
    ordernumber => $ordernumber,
    referrer => $referrer,
    type => $type,
);


output_html_with_http_headers $input, $cookie, $template->output;
