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
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use C4::Log    qw(logaction);
use Koha::Acquisition::Baskets;

my $input = CGI->new;
my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
    {
        template_name => 'acqui/cancelorder.tt',
        query         => $input,
        type          => 'intranet',
        flagsrequired => { 'acquisition' => 'order_manage' },
    }
);

my $op            = $input->param('op') || q{};
my $ordernumber   = $input->param('ordernumber');
my $biblionumber  = $input->param('biblionumber');
my $order         = Koha::Acquisition::Orders->find($ordernumber);
my $basketno      = $order->basketno;
my $basket        = Koha::Acquisition::Baskets->find( { basketno => $basketno }, { prefetch => 'booksellerid' } );
my $referrer      = $input->param('referrer') || $input->referer;
my $delete_biblio = $input->param('del_biblio') ? 1 : 0;

if ( $op eq "cud-confirmcancel" ) {
    my $reason = $input->param('reason');
    my @messages;
    if ( !$order ) {
        push @messages, Koha::Object::Message->new( { message => 'error_order_not_found', type => 'error' } );
        $template->param( error_order_not_found => 1 );
    } elsif ( $order->datecancellationprinted ) {
        push @messages, Koha::Object::Message->new( { message => 'error_order_already_cancelled', type => 'error' } );
        $template->param( error_order_already_cancelled => 1 );
    } else {
        $order->cancel( { reason => $reason, delete_biblio => $delete_biblio } );
        @messages = @{ $order->object_messages };
    }

    if ( scalar @messages > 0 ) {
        $template->param( error_delitem => 1 )
            if $messages[0]->message eq 'error_delitem';
        $template->param( error_delbiblio => 1 )
            if $messages[0]->message eq 'error_delbiblio';
    } else {

        # Log the cancellation of the order
        if ( C4::Context->preference("AcquisitionLog") ) {
            logaction( 'ACQUISITIONS', 'CANCEL_ORDER', $ordernumber );
        }
        $template->param( success_cancelorder => 1 );
    }
    $template->param( confirmcancel => 1 );
}

$template->param(
    ordernumber  => $ordernumber,
    biblionumber => $biblionumber,
    basket       => $basket,
    referrer     => $referrer,
    del_biblio   => $delete_biblio,
);

output_html_with_http_headers $input, $cookie, $template->output;
