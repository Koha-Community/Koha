package Koha::Z3950Responder::Session;

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

use C4::Context;
use C4::Search qw( new_record_from_zebra );

use Koha::Items;
use Koha::Logger;

=head1 NAME

Koha::Z3950Responder::Session

=head1 SYNOPSIS

An abstract class where backend-specific session modules are derived from.
Z3950Responder creates one of the child classes depending on the SearchEngine
preference.

=head1 DESCRIPTION

This class contains common functions for handling searching for and fetching
of records. It can optionally add item status information to the returned
records. The backend-specific abstract methods need to be implemented in a
child class.

=head2 CONSTANTS

OIDs and diagnostic codes used in Z39.50

=cut

use constant {
    UNIMARC_OID => '1.2.840.10003.5.1',
    USMARC_OID  => '1.2.840.10003.5.10',
    MARCXML_OID => '1.2.840.10003.5.109.10'
};

use constant {
    ERR_TEMPORARY_ERROR      => 2,
    ERR_PRESENT_OUT_OF_RANGE => 13,
    ERR_RECORD_TOO_LARGE     => 16,
    ERR_NO_SUCH_RESULTSET    => 30,
    ERR_SEARCH_FAILED        => 125,
    ERR_SYNTAX_UNSUPPORTED   => 239,
    ERR_DB_DOES_NOT_EXIST    => 235,
};

=head1 FUNCTIONS

=head2 INSTANCE METHODS

=head3 new

    my $session = $self->new({
        server => $z3950responder,
        peer => 'PEER NAME'
    });

Instantiate a Session

=cut

sub new {
    my ( $class, $args ) = @_;

    my $self = bless(
        {
            %$args,
            logger     => Koha::Logger->get( { interface => 'z3950' } ),
            resultsets => {},
        },
        $class
    );

    if ( $self->{server}->{debug} ) {
        $self->{logger}->debug_to_screen();
    }

    $self->log_info('connected');

    return $self;
}

=head3 search_handler

    Callback that is called when a new search is performed

Calls C<start_search> for backend-specific retrieval logic

=cut

sub search_handler {
    my ( $self, $args ) = @_;

    my $database = $args->{DATABASES}->[0];

    if ( $database ne $Koha::SearchEngine::BIBLIOS_INDEX && $database ne $Koha::SearchEngine::AUTHORITIES_INDEX ) {
        $self->set_error( $args, $self->ERR_DB_DOES_NOT_EXIST, 'No such database' );
        return;
    }

    my $query = $args->{QUERY};
    $self->log_info("received search for '$query', (RS $args->{SETNAME})");

    my ( $resultset, $hits ) = $self->start_search( $args, $self->{server}->{num_to_prefetch} );
    return unless $resultset;

    $args->{HITS} = $hits;
    $self->{resultsets}->{ $args->{SETNAME} } = $resultset;
}

=head3 fetch_handler

    Callback that is called when records are requested

Calls C<fetch_record> for backend-specific retrieval logic

=cut

sub fetch_handler {
    my ( $self, $args ) = @_;

    $self->log_debug("received fetch for RS $args->{SETNAME}, record $args->{OFFSET}");

    my $server = $self->{server};

    my $form_oid    = $args->{REQ_FORM} // '';
    my $composition = $args->{COMP}     // '';
    $self->log_debug("    form OID '$form_oid', composition '$composition'");

    my $resultset = $self->{resultsets}->{ $args->{SETNAME} };

    # The offset comes across 1-indexed.
    my $offset = $args->{OFFSET} - 1;

    return unless $self->check_fetch( $resultset, $args, $offset, 1 );

    $args->{LAST} = 1 if ( $offset == $resultset->{hits} - 1 );

    my $record = $self->fetch_record( $resultset, $args, $offset, $server->{num_to_prefetch} );
    return unless $record;

    # Note that new_record_from_zebra is badly named and works also with Elasticsearch
    $record = C4::Search::new_record_from_zebra(
        $resultset->{database} eq 'biblios' ? 'biblioserver' : 'authorityserver',
        $record
    );

    if ( $server->{add_item_status_subfield} ) {
        my $tag = $server->{item_tag};

        foreach my $field ( $record->field($tag) ) {
            $self->add_item_status($field);
        }
    }

    if ( $form_oid eq $self->MARCXML_OID && $composition eq 'marcxml' ) {
        $args->{RECORD} = $record->as_xml_record();
    } elsif ( ( $form_oid eq $self->USMARC_OID || $form_oid eq $self->UNIMARC_OID )
        && ( !$composition || $composition eq 'F' ) )
    {
        $args->{RECORD} = $record->as_usmarc();
    } else {
        $self->set_error(
            $args, $self->ERR_SYNTAX_UNSUPPORTED,
            "Unsupported syntax/composition $form_oid/$composition"
        );
        return;
    }
}

=head3 close_handler

Callback that is called when a session is terminated

=cut

sub close_handler {
    my ( $self, $args ) = @_;

    # Override in a child class to add functionality
}

=head3 start_search

    my ($resultset, $hits) = $self->_start_search( $args, $self->{server}->{num_to_prefetch} );

A backend-specific method for starting a new search

=cut

sub start_search {
    die('Abstract method');
}

=head3 check_fetch

    $self->check_fetch($resultset, $args, $offset, $num_records);

Check that the fetch request parameters are within bounds of the result set.

=cut

sub check_fetch {
    my ( $self, $resultset, $args, $offset, $num_records ) = @_;

    if ( !defined($resultset) ) {
        $self->set_error( $args, ERR_NO_SUCH_RESULTSET, 'No such resultset' );
        return 0;
    }

    if ( $offset < 0 || $offset + $num_records > $resultset->{hits} ) {
        $self->set_error( $args, ERR_PRESENT_OUT_OF_RANGE, 'Present request out of range' );
        return 0;
    }

    return 1;
}

=head3 fetch_record

    my $record = $self->_fetch_record( $resultset, $args, $offset, $server->{num_to_prefetch} );

A backend-specific method for fetching a record

=cut

sub fetch_record {
    die('Abstract method');
}

=head3 add_item_status

    $self->add_item_status( $field );

Add item status to the given field

=cut

sub add_item_status {
    my ( $self, $field ) = @_;

    my $server = $self->{server};

    my $itemnumber_subfield = $server->{itemnumber_subfield};
    my $add_subfield        = $server->{add_item_status_subfield};
    my $status_strings      = $server->{status_strings};

    my $itemnumber = $field->subfield($itemnumber_subfield);
    next unless $itemnumber;

    my $item = Koha::Items->find($itemnumber);
    return unless $item;

    my $statuses = $item->z3950_status($status_strings);

    if ( $server->{add_status_multi_subfield} ) {
        $field->add_subfields( map { ( $add_subfield, $_ ) }
                ( @$statuses ? @$statuses : $status_strings->{AVAILABLE} ) );
    } else {
        $field->add_subfields( $add_subfield, @$statuses ? join( ', ', @$statuses ) : $status_strings->{AVAILABLE} );
    }
}

=head3 log_debug

    $self->log_debug('Message');

Output a debug message

=cut

sub log_debug {
    my ( $self, $msg ) = @_;
    $self->{logger}->debug("[$self->{peer}] $msg");
}

=head3 log_info

    $self->log_info('Message');

Output an info message

=cut

sub log_info {
    my ( $self, $msg ) = @_;
    $self->{logger}->info("[$self->{peer}] $msg");
}

=head3 log_error

    $self->log_error('Message');

Output an error message

=cut

sub log_error {
    my ( $self, $msg ) = @_;
    $self->{logger}->error("[$self->{peer}] $msg");
}

=head3 set_error

    $self->set_error($args, $self->ERR_SEARCH_FAILED, 'Backend connection failed' );

Set and log an error code and diagnostic message to be returned to the client

=cut

sub set_error {
    my ( $self, $args, $code, $msg ) = @_;

    ( $args->{ERR_CODE}, $args->{ERR_STR} ) = ( $code, $msg );

    $self->log_error("    returning error $code: $msg");
}

1;
