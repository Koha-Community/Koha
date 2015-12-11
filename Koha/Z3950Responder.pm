#!/usr/bin/perl

package Koha::Z3950Responder;

# Copyright ByWater Solutions 2016
#
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

use C4::Biblio qw( GetMarcFromKohaField );
use C4::Koha qw( GetAuthorisedValues );

use Koha;
use Koha::Z3950Responder::Session;

use Net::Z3950::SimpleServer;

sub new {
    my ( $class, $config ) = @_;

    my ($item_tag, $itemnumber_subfield) = GetMarcFromKohaField( "items.itemnumber", '' );

    # We hardcode the strings for English so SOMETHING will work if the authorized value doesn't exist.
    my $status_strings = {
        AVAILABLE => 'Available',
        CHECKED_OUT => 'Checked Out',
        LOST => 'Lost',
        NOT_FOR_LOAN => 'Not for Loan',
        DAMAGED => 'Damaged',
        WITHDRAWN => 'Withdrawn',
        IN_TRANSIT => 'In Transit',
        ON_HOLD => 'On Hold',
    };

    foreach my $val ( @{ GetAuthorisedValues( 'Z3950_STATUS' ) } ) {
        $status_strings->{ $val->{authorised_value} } = $val->{lib};
    }

    my $self = {
        %$config,
        item_tag => $item_tag,
        itemnumber_subfield => $itemnumber_subfield,
        status_strings => $status_strings,
    };

    # Turn off Yaz's built-in logging (can be turned back on if desired).
    unshift @{ $self->{yaz_options} }, '-v', 'none';

    # If requested, turn on debugging.
    if ( $self->{debug} ) {
        # Turn on single-process mode.
        unshift @{ $self->{yaz_options} }, '-S';
    }

    $self->{server} = Net::Z3950::SimpleServer->new(
        INIT => sub { $self->init_handler(@_) },
        SEARCH => sub { $self->search_handler(@_) },
        PRESENT => sub { $self->present_handler(@_) },
        FETCH => sub { $self->fetch_handler(@_) },
        CLOSE => sub { $self->close_handler(@_) },
    );

    return bless( $self, $class );
}

sub start {
    my ( $self ) = @_;

    $self->{server}->launch_server( 'Koha::Z3950Responder', @{ $self->{yaz_options} } )
}

# The rest of these methods are SimpleServer callbacks bound to this Z3950Responder object. It's
# worth noting that these callbacks don't return anything; they both receive and return data in the
# $args hashref.

sub init_handler {
    # Called when the client first connects.
    my ( $self, $args ) = @_;

    # This holds all of the per-connection state.
    my $session = Koha::Z3950Responder::Session->new({
        server => $self,
        peer => $args->{PEER_NAME},
    });

    $args->{HANDLE} = $session;

    $args->{IMP_NAME} = "Koha";
    $args->{IMP_VER} = Koha::version;
}

sub search_handler {
    # Called when search is first sent.
    my ( $self, $args ) = @_;

    $args->{HANDLE}->search_handler($args);
}

sub present_handler {
    # Called when a set of records is requested.
    my ( $self, $args ) = @_;

    $args->{HANDLE}->present_handler($args);
}

sub fetch_handler {
    # Called when a given record is requested.
    my ( $self, $args ) = @_;

    $args->{HANDLE}->fetch_handler( $args );
}

sub close_handler {
    my ( $self, $args ) = @_;

    $args->{HANDLE}->close_handler( $args );
}

1;
