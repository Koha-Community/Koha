package Koha::Z3950Responder::ZebraSession;

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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use base qw( Koha::Z3950Responder::Session );

use Koha::Logger;

use ZOOM;

=head1 NAME

Koha::Z3950Responder::ZebraSession

=head1 SYNOPSIS

Zebra-specific session class that uses C<Koha::Session> as the base class.

=head1 FUNCTIONS

=head2 INSTANCE METHODS

=head3 start_search

    my ($resultset, $hits) = $self->_start_search( $args, $self->{server}->{num_to_prefetch} );

Connect to Zebra and do the search

=cut

sub start_search {
    my ( $self, $args, $num_to_prefetch, $in_retry ) = @_;

    my $database = $args->{DATABASES}->[0];
    my ( $connection, $results );

    eval {
        $connection = C4::Context->Zconn(

            # We're depending on the caller to have done some validation.
            $database eq 'biblios' ? 'biblioserver' : 'authorityserver',
            0    # No, no async, doesn't really help much for single-server searching
        );

        $results = $connection->search_pqf( $args->{QUERY} );

        $self->log_debug('    retry successful') if ($in_retry);
    };
    if ($@) {
        die $@ if ( ref($@) ne 'ZOOM::Exception' );

        if ( $@->diagset() eq 'ZOOM' && $@->code() == 10004 && !$in_retry ) {
            $self->log_debug('    upstream server lost connection, retrying');
            return $self->_start_search( $args, $num_to_prefetch, 1 );
        }

        $self->_set_error_from_zoom( $args, $@ );
        $connection = undef;
    }

    my $hits      = $results ? $results->size() : -1;
    my $resultset = {
        database   => $database,
        connection => $connection,
        results    => $results,
        query      => $args->{QUERY},
        hits       => $hits
    };

    return ( $resultset, $hits );
}

=head3 fetch_record

    my $record = $self->_fetch_record( $resultset, $args, $offset, $server->{num_to_prefetch} );

Fetch a record from Zebra. Caches records in session to avoid too many fetches.

=cut

sub fetch_record {
    my ( $self, $resultset, $args, $index, $num_to_prefetch ) = @_;

    my $record;

    eval {
        if ( !$resultset->{results}->record_immediate($index) ) {
            my $start = $num_to_prefetch ? int( $index / $num_to_prefetch ) * $num_to_prefetch : $index;

            if ( $start + $num_to_prefetch >= $resultset->{results}->size() ) {
                $num_to_prefetch = $resultset->{results}->size() - $start;
            }

            $self->log_debug("    fetch uncached, fetching $num_to_prefetch records starting at $start");

            $resultset->{results}->records( $start, $num_to_prefetch, 0 );
        }

        $record = $resultset->{results}->record_immediate($index)->raw();
    };
    if ($@) {
        die $@ if ( ref($@) ne 'ZOOM::Exception' );
        $self->_set_error_from_zoom( $args, $@ );
        return;
    } else {
        return $record;
    }
}

=head3 close_handler

Callback that is called when a session is terminated

=cut

sub close_handler {
    my ( $self, $args ) = @_;

    foreach my $resultset ( values %{ $self->{resultsets} } ) {
        $resultset->{results}->destroy();
    }
}

=head3 _set_error_from_zoom

    $self->_set_error_from_zoom( $args, $@ );

Log and set error code and diagnostic message from a ZOOM exception

=cut

sub _set_error_from_zoom {
    my ( $self, $args, $exception ) = @_;

    $self->set_error( $args, $self->ERR_TEMPORARY_ERROR, 'Cannot connect to upstream server' );
    $self->log_error( "Zebra upstream error: "
            . $exception->message() . " ("
            . $exception->code() . ") "
            . ( $exception->addinfo() // '' ) . " "
            . $exception->diagset() );
}

1;
