#!/usr/bin/perl

# Copyright 2021 Aleisha Amohia <aleisha@catalyst.net.nz>
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

=head1 NAME

moddeliverydate.pl

=head1 DESCRIPTION

Modify just the estimated delivery date of an individual order when
its basket is closed.

=cut

use Modern::Perl;

use CGI             qw ( -utf8 );
use C4::Auth        qw( get_template_and_user );
use C4::Output      qw( output_html_with_http_headers );
use C4::Acquisition qw( GetOrder GetBasket ModOrder );

use Koha::Acquisition::Booksellers;
use Koha::DateUtils qw( dt_from_string );

my $input = CGI->new;
my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
    {
        template_name => 'acqui/moddeliverydate.tt',
        query         => $input,
        type          => 'intranet',
        flagsrequired => { 'acquisition' => 'order_manage' },
    }
);

my $op          = $input->param('op');
my $ordernumber = $input->param('ordernumber');
my $referrer    = $input->param('referrer') || $input->referer();
my $order       = GetOrder($ordernumber);
my $basket      = GetBasket( $order->{basketno} );
my $bookseller  = Koha::Acquisition::Booksellers->find( $basket->{booksellerid} );

if ( $op and $op eq 'cud-save' ) {
    my $estimated_delivery_date = $input->param('estimated_delivery_date');
    $order->{'estimated_delivery_date'} = $estimated_delivery_date ? dt_from_string($estimated_delivery_date) : undef;
    ModOrder($order);
    print $input->redirect($referrer);
    exit;
} else {
    $template->param( estimated_delivery_date => $order->{'estimated_delivery_date'} );
}

if ($op) {
    $template->param( $op => 1 );
}

$template->param(
    basketname     => $basket->{'basketname'},
    basketno       => $order->{basketno},
    booksellerid   => $bookseller->id,
    booksellername => $bookseller->name,
    ordernumber    => $ordernumber,
    referrer       => $referrer,
);

output_html_with_http_headers $input, $cookie, $template->output;
