#!/usr/bin/perl

package Koha::Z3950Responder::Session;

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

use C4::Circulation qw( GetTransfers );
use C4::Context;
use C4::Items qw( GetItem );
use C4::Reserves qw( GetReserveStatus );
use C4::Search qw();
use Koha::Logger;

use ZOOM;

use constant {
    UNIMARC_OID => '1.2.840.10003.5.1',
    USMARC_OID => '1.2.840.10003.5.10',
    MARCXML_OID => '1.2.840.10003.5.109.10'
};

use constant {
    ERR_TEMPORARY_ERROR => 2,
    ERR_PRESENT_OUT_OF_RANGE => 13,
    ERR_RECORD_TOO_LARGE => 16,
    ERR_NO_SUCH_RESULTSET => 30,
    ERR_SYNTAX_UNSUPPORTED => 230,
    ERR_DB_DOES_NOT_EXIST => 235,
};

sub new {
    my ( $class, $args ) = @_;

    my $self = bless( {
        %$args,
        logger => Koha::Logger->get({ interface => 'z3950' }),
        resultsets => {},
    }, $class );

    if ( $self->{server}->{debug} ) {
        $self->{logger}->debug_to_screen();
    }

    $self->_log_info("connected");

    return $self;
}

sub _log_debug {
    my ( $self, $msg ) = @_;
    $self->{logger}->debug("[$self->{peer}] $msg");
}

sub _log_info {
    my ( $self, $msg ) = @_;
    $self->{logger}->info("[$self->{peer}] $msg");
}

sub _log_error {
    my ( $self, $msg ) = @_;
    $self->{logger}->error("[$self->{peer}] $msg");
}

sub _set_error {
    my ( $self, $args, $code, $msg ) = @_;
    ( $args->{ERR_CODE}, $args->{ERR_STR} ) = ( $code, $msg );

    $self->_log_error("    returning error $code: $msg");
}

sub _set_error_from_zoom {
    my ( $self, $args, $exception ) = @_;

    $self->_set_error( $args, ERR_TEMPORARY_ERROR, 'Cannot connect to upstream server' );
    $self->_log_error(
        "Zebra upstream error: " .
        $exception->message() . " (" .
        $exception->code() . ") " .
        ( $exception->addinfo() // '' ) . " " .
        $exception->diagset()
    );
}

# This code originally went through C4::Search::getRecords, but had to use so many escape hatches
# that it was easier to directly connect to Zebra.
sub _start_search {
    my ( $self, $args, $in_retry ) = @_;

    my $database = $args->{DATABASES}->[0];
    my ( $connection, $results );

    eval {
        $connection = C4::Context->Zconn(
            # We're depending on the caller to have done some validation.
            $database eq 'biblios' ? 'biblioserver' : 'authorityserver',
            0 # No, no async, doesn't really help much for single-server searching
        );

        $results = $connection->search_pqf( $args->{QUERY} );

        $self->_log_debug('    retry successful') if ($in_retry);
    };
    if ($@) {
        die $@ if ( ref($@) ne 'ZOOM::Exception' );

        if ( $@->diagset() eq 'ZOOM' && $@->code() == 10004 && !$in_retry ) {
            $self->_log_debug('    upstream server lost connection, retrying');
            return $self->_start_search( $args, 1 );
        }

        _set_error_from_zoom( $args, $@ );
        $connection = undef;
    }

    return ( $connection, $results, $results ? $results->size() : -1 );
}

sub _check_fetch {
    my ( $self, $resultset, $args, $offset, $num_records ) = @_;

    if ( !defined( $resultset ) ) {
        $self->_set_error( $args, ERR_NO_SUCH_RESULTSET, 'No such resultset' );
        return 0;
    }

    if ( $offset + $num_records > $resultset->{hits} )  {
        $self->_set_error( $args, ERR_PRESENT_OUT_OF_RANGE, 'Fetch request out of range' );
        return 0;
    }

    return 1;
}

sub _fetch_record {
    my ( $self, $resultset, $args, $index, $num_to_prefetch ) = @_;

    my $record;

    eval {
        if ( !$resultset->{results}->record_immediate( $index ) ) {
            my $start = int( $index / $num_to_prefetch ) * $num_to_prefetch;

            if ( $start + $num_to_prefetch >= $resultset->{results}->size() ) {
                $num_to_prefetch = $resultset->{results}->size() - $start;
            }

            $self->_log_debug("    fetch uncached, fetching $num_to_prefetch records starting at $start");

            $resultset->{results}->records( $start, $num_to_prefetch, 0 );
        }

        $record = $resultset->{results}->record_immediate( $index )->raw();
    };
    if ($@) {
        die $@ if ( ref($@) ne 'ZOOM::Exception' );
        $self->_set_error_from_zoom( $args, $@ );
        return;
    } else {
        return $record;
    }
}

sub search_handler {
    # Called when search is first sent.
    my ( $self, $args ) = @_;

    my $database = $args->{DATABASES}->[0];

    if ( $database !~ /^(biblios|authorities)$/ ) {
        $self->_set_error( ERR_DB_DOES_NOT_EXIST, 'No such database' );
        return;
    }

    my $query = $args->{QUERY};
    $self->_log_info("received search for '$query', (RS $args->{SETNAME})");

    my ( $connection, $results, $num_hits ) = $self->_start_search( $args );
    return unless $connection;

    $args->{HITS} = $num_hits;
    my $resultset = $self->{resultsets}->{ $args->{SETNAME} } = {
        database => $database,
        connection => $connection,
        results => $results,
        query => $args->{QUERY},
        hits => $args->{HITS},
    };
}

sub present_handler {
    # Called when a set of records is requested.
    my ( $self, $args ) = @_;

    $self->_log_debug("received present for $args->{SETNAME}, $args->{START}+$args->{NUMBER}");

    my $resultset = $self->{resultsets}->{ $args->{SETNAME} };
    # The offset comes across 1-indexed.
    my $offset = $args->{START} - 1;

    return unless $self->_check_fetch( $resultset, $args, $offset, $args->{NUMBER} );

}

sub fetch_handler {
    # Called when a given record is requested.
    my ( $self, $args ) = @_;
    my $session = $args->{HANDLE};
    my $server = $self->{server};

    $self->_log_debug("received fetch for $args->{SETNAME}, record $args->{OFFSET}");
    my $form_oid = $args->{REQ_FORM} // '';
    my $composition = $args->{COMP} // '';
    $self->_log_debug("    form OID $form_oid, composition $composition");

    my $resultset = $session->{resultsets}->{ $args->{SETNAME} };
    # The offset comes across 1-indexed.
    my $offset = $args->{OFFSET} - 1;

    return unless $self->_check_fetch( $resultset, $args, $offset, 1 );

    $args->{LAST} = 1 if ( $offset == $resultset->{hits} - 1 );

    my $record = $self->_fetch_record( $resultset, $args, $offset, $server->{num_to_prefetch} );
    return unless $record;

    $record = C4::Search::new_record_from_zebra(
        $resultset->{database} eq 'biblios' ? 'biblioserver' : 'authorityserver',
        $record
    );

    if ( $server->{add_item_status_subfield} ) {
        my $tag = $server->{item_tag};

        foreach my $field ( $record->field($tag) ) {
            $self->add_item_status( $field );
        }
    }

    if ( $form_oid eq MARCXML_OID && $composition eq 'marcxml' ) {
        $args->{RECORD} = $record->as_xml_record();
    } elsif ( ( $form_oid eq USMARC_OID || $form_oid eq UNIMARC_OID ) && ( !$composition || $composition eq 'F' ) ) {
        $args->{RECORD} = $record->as_usmarc();
    } else {
        $self->_set_error( $args, ERR_SYNTAX_UNSUPPORTED, "Unsupported syntax/composition $form_oid/$composition" );
        return;
    }
}

sub add_item_status {
    my ( $self, $field ) = @_;

    my $server = $self->{server};

    my $itemnumber_subfield = $server->{itemnumber_subfield};
    my $add_subfield = $server->{add_item_status_subfield};
    my $status_strings = $server->{status_strings};

    my $itemnumber = $field->subfield($itemnumber_subfield);
    next unless $itemnumber;

    my $item = GetItem( $itemnumber );
    return unless $item;

    my @statuses;

    if ( $item->{onloan} ) {
        push @statuses, $status_strings->{CHECKED_OUT};
    }

    if ( $item->{itemlost} ) {
        push @statuses, $status_strings->{LOST};
    }

    if ( $item->{notforloan} ) {
        push @statuses, $status_strings->{NOT_FOR_LOAN};
    }

    if ( $item->{damaged} ) {
        push @statuses, $status_strings->{DAMAGED};
    }

    if ( $item->{withdrawn} ) {
        push @statuses, $status_strings->{WITHDRAWN};
    }

    if ( scalar( GetTransfers( $itemnumber ) ) ) {
        push @statuses, $status_strings->{IN_TRANSIT};
    }

    if ( GetReserveStatus( $itemnumber ) ne '' ) {
        push @statuses, $status_strings->{ON_HOLD};
    }

    $field->delete_subfield( code => $itemnumber_subfield );

    if ( $server->{add_status_multi_subfield} ) {
        $field->add_subfields( map { ( $add_subfield, $_ ) } ( @statuses ? @statuses : $status_strings->{AVAILABLE} ) );
    } else {
        $field->add_subfields( $add_subfield, @statuses ? join( ', ', @statuses ) : $status_strings->{AVAILABLE} );
    }
}

sub close_handler {
    my ( $self, $args ) = @_;

    foreach my $resultset ( values %{ $self->{resultsets} } ) {
        $resultset->{results}->destroy();
    }
}

1;
