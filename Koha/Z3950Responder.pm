package Koha::Z3950Responder;

# Copyright ByWater Solutions 2016
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

use Modern::Perl;

use C4::Biblio qw( GetMarcFromKohaField );
use C4::Koha   qw( GetAuthorisedValues );

use Koha::Caches;

use Net::Z3950::SimpleServer;

=head1 NAME

Koha::Z3950Responder - Main class for interfacing with Net::Z3950::SimpleServer

=head1 SYNOPSIS

    use Koha::Z3950Responder;

    my $z = Koha::Z3950Responder->new( {
        add_item_status_subfield => 1,
        add_status_multi_subfield => 1,
        debug => 0,
        num_to_prefetch => 20,
        config_dir => '/home/koha/etc',
        yaz_options => [ ],
    } );

    $z->start();

=head1 DESCRIPTION

A daemon class that interfaces with Net::Z3950::SimpleServer to provider Z39.50/SRU
service. Uses a Session class for the actual functionality.

=head1 METHODS

=head2 INSTANCE METHODS

=head3 new

    $self->new({
        add_item_status_subfield => 1
    });

=cut

sub new {
    my ( $class, $config ) = @_;

    my ( $item_tag, $itemnumber_subfield ) = GetMarcFromKohaField("items.itemnumber");

    # We hardcode the strings for English so SOMETHING will work if the authorized value doesn't exist.
    my $status_strings = {
        AVAILABLE    => 'Available',
        CHECKED_OUT  => 'Checked Out',
        LOST         => 'Lost',
        NOT_FOR_LOAN => 'Not for Loan',
        DAMAGED      => 'Damaged',
        WITHDRAWN    => 'Withdrawn',
        IN_TRANSIT   => 'In Transit',
        ON_HOLD      => 'On Hold',
    };

    foreach my $val ( @{ GetAuthorisedValues('Z3950_STATUS') } ) {
        $status_strings->{ $val->{authorised_value} } = $val->{lib};
    }

    my $self = {
        %$config,
        item_tag            => $item_tag,
        itemnumber_subfield => $itemnumber_subfield,
        status_strings      => $status_strings,
    };

    # If requested, turn on debugging.
    if ( $self->{debug} ) {

        # Turn on single-process mode.
        unshift @{ $self->{yaz_options} }, '-S';
    } else {

        # Turn off Yaz's built-in logging apart from fatal errors (can be turned back on if desired).
        unshift @{ $self->{yaz_options} }, '-v', 'none,fatal';
    }

    # Set main config for SRU support and working directory
    if ( $self->{config_dir} ) {
        unshift @{ $self->{yaz_options} }, '-f', $self->{config_dir} . 'config.xml';
        unshift @{ $self->{yaz_options} }, '-w', $self->{config_dir};
    }

    # Set num to prefetch if not passed
    $self->{num_to_prefetch} //= 20;

    $self->{server} = Net::Z3950::SimpleServer->new(
        INIT   => sub { $self->init_handler(@_) },
        SEARCH => sub { $self->search_handler(@_) },
        FETCH  => sub { $self->fetch_handler(@_) },
        CLOSE  => sub { $self->close_handler(@_) },
    );

    return bless( $self, $class );
}

=head3 start

    $z->start();

Start the daemon and begin serving requests. Does not return unless initialization fails or a
fatal error occurs.

=cut

sub start {
    my ($self) = @_;

    # start_server from Net::Z3950::SimpleServer is going to fork
    C4::Context->dbh->disconnect;
    $self->{server}->launch_server( 'Koha::Z3950Responder', @{ $self->{yaz_options} } );
}

=head2 CALLBACKS

These methods are SimpleServer callbacks bound to this Z3950Responder object.
It's worth noting that these callbacks don't return anything; they both
receive and return data in the $args hashref.

=head3 init_handler

Callback that is called when a new connection is initialized

=cut

sub init_handler {

    # Called when the client first connects.
    my ( $self, $args ) = @_;

    # This holds all of the per-connection state.
    my $session;
    if ( C4::Context->preference('SearchEngine') eq 'Zebra' ) {
        use Koha::Z3950Responder::ZebraSession;
        $session = Koha::Z3950Responder::ZebraSession->new(
            {
                server => $self,
                peer   => $args->{PEER_NAME},
            }
        );
    } else {
        use Koha::Z3950Responder::GenericSession;
        $session = Koha::Z3950Responder::GenericSession->new(
            {
                server => $self,
                peer   => $args->{PEER_NAME}
            }
        );
    }

    $args->{HANDLE} = $session;

    $args->{IMP_NAME} = "Koha";
    $args->{IMP_VER}  = Koha::version;
}

=head3 search_handler

Callback that is called when a new search is performed

=cut

sub search_handler {
    my ( $self, $args ) = @_;

    my $SearchEngine = C4::Context->preference('SearchEngine');

    # Flushing L1 to make sure the search will be processed using the correct data
    Koha::Caches->flush_L1_caches();
    $self->init_handler($args)
        if $SearchEngine ne C4::Context->preference('SearchEngine');

    $args->{HANDLE}->search_handler($args);
}

=head3 fetch_handler

Callback that is called when records are requested

=cut

sub fetch_handler {
    my ( $self, $args ) = @_;

    $args->{HANDLE}->fetch_handler($args);
}

=head3 close_handler

Callback that is called when a session is terminated

=cut

sub close_handler {
    my ( $self, $args ) = @_;

    $args->{HANDLE}->close_handler($args);
}

1;
