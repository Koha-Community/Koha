# Copyright BibLibre 2023
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

package Koha::OAI::Client::Harvester;

=head1 NAME

Koha::OAI::Client::Harvester - OAI Harvester

=head1 DESCRIPTION

Koha::OAI::Client::Harvester contains OAI-PMH harvester main functions

=cut

use utf8;
use open qw( :std :utf8 );

use C4::Biblio          qw( AddBiblio GetFrameworkCode ModBiblio DelBiblio );
use C4::AuthoritiesMarc qw (AddAuthority GuessAuthTypeCode ModAuthority DelAuthority );
use HTTP::OAI;
use HTTP::OAI::Metadata::OAI_DC;
use Koha::DateUtils qw( dt_from_string );
use Koha::OAIServers;
use Koha::Import::OAI::Biblio;
use Koha::Import::OAI::Biblios;
use Koha::Import::OAI::Authority;
use Koha::Import::OAI::Authorities;
use Koha::XSLT::Base;
use MARC::File::XML;
use MARC::Record;
use Modern::Perl;
use DateTime;
use DateTime::Format::Strptime;
use Try::Tiny qw( catch try );

our $xslt_engine = Koha::XSLT::Base->new;

=head2 new
$harvester = Koha::OAI::Client::Harvester->new( { server => $server, days => $days, force => $force, logger => \&logger } );

New instance of Koha::OAI::Client::Harvester

C<$server> An OAI repository (Koha::OAIServer)

C<$days> number of days to harvest from (optional)

C<$force> force harvesting (ignore records datestamps)

C<$logger> a callback function to handle logs (optional)

=cut

sub new {
    my ( $self, $args ) = @_;
    return bless $args, $self;
}

=head2 init

Starts harvesting

=cut

sub init {
    my ( $self, $args ) = @_;
    $self->printlog("Starting OAI Harvest from repository");
    my $server = $self->{server};
    my $days   = $self->{days};
    my $init_results;

    my $h = HTTP::OAI::Harvester->new(
        repository => HTTP::OAI::Identify->new(
            baseURL => $server->endpoint,
            version => '2.0',
        )
    );

    $self->printlog( "Using HTTP::OAI::Harvester version " . $HTTP::OAI::Harvester::VERSION );

    $self->printlog( "Using endpoint "
            . $server->endpoint
            . ", set "
            . $server->oai_set
            . ", dataformat "
            . $server->dataformat
            . ", recordtype "
            . $server->recordtype );

    try {
        my $lmdf    = $h->ListMetadataFormats();
        my $lmdflog = "";
        for ( $lmdf->metadataFormat ) {
            $lmdflog .= $_->metadataPrefix . " ";
        }
        $self->printlog("Available metadata formats for this repository: $lmdflog");
        $init_results->{metadata_formats} = $lmdflog;
    } catch {
        $self->printlog("ListMetadataFormats failed");
    };

    if ( $server->add_xslt ) {
        $self->printlog( "Using XSLT file " . $server->add_xslt );
    } else {
        $self->printlog("Not using an XSLT file");
    }

    my $start_date = '';
    my $today_date = '';

    if ($days) {

        # Change this to yyyy-mm-dd
        my $dt_start = dt_from_string->subtract( days => $days );
        $start_date = $dt_start->ymd();
        $self->printlog("Harvesting from $start_date");
    }

    $self->printlog("Asking for records");
    my $response = $h->ListRecords(
        metadataPrefix => $server->dataformat,
        set            => $server->oai_set,
        from           => $start_date,
    );
    if ( $response->is_error ) {
        $self->printlog( "Error requesting ListRecords: " . $response->code . " " . $response->message );
        $init_results->{is_error} = $response->message;
        return $init_results;
    }
    $self->printlog( "Request URL: " . $response->requestURL );

    my %stats;
    my @statuses = qw(added updated deleted in_error skipped total);
    foreach my $status (@statuses) {
        $stats{$status} = 0;
    }

    $self->printlog("Starting processing results");
    while ( my $oai_record = $response->next ) {
        $stats{'total'}++;
        my $status = $self->processRecord($oai_record);
        $stats{$status}++;
    }
    $init_results->{total} = $stats{'total'};

    my $results = '';
    foreach my $status (@statuses) {
        $results .= $stats{$status} . " $status\n";
    }
    $self->printlog( "Harvest results:\n" . $results );

    if ( C4::Context->preference("OAI-PMH:HarvestEmailReport") ) {

        my $letter = C4::Letters::GetPreparedLetter(
            (
                module      => 'catalogue',
                letter_code => 'OAI_HARVEST_REPORT',
                substitute  => {
                    servername => $server->servername,
                    endpoint   => $server->endpoint,
                    set        => $server->oai_set,
                    dataformat => $server->dataformat,
                    recordtype => $server->recordtype,
                    added      => $stats{'added'},
                    updated    => $stats{'updated'},
                    deleted    => $stats{'deleted'},
                    skipped    => $stats{'skipped'},
                    in_error   => $stats{'in_error'},
                    total      => $stats{'total'}
                },
            )
        ) or $self->printlog("OAI_HARVEST_REPORT letter not found");

        my $message_id = C4::Letters::EnqueueLetter(
            {
                letter     => $letter,
                to_address => C4::Context->preference("OAI-PMH:HarvestEmailReport"), message_transport_type => 'email'
            }
        );
        if ($message_id) {
            $self->printlog("Email report enqueued");
            $init_results->{letter_message_id} = $message_id;
        } else {
            $self->printlog("Unable to enqueue report email");
        }
    }

    $self->printlog("Ending OAI Harvest from repository");
    return $init_results;
}

=head2 processRecord

This method processes an incoming OAI record

=cut

sub processRecord {
    my $self       = shift;
    my $oai_record = shift;
    my $status     = '';
    my $server     = $self->{server};
    my $force      = $self->{force};
    unless ( $oai_record->identifier ) {
        $self->printlog("No identifier found");
        $status = 'skipped';
        return $status;
    }

    my $to_delete;
    my $outputUnimarc;
    my $marcrecord;
    if ( $oai_record->status && $oai_record->status eq "deleted" ) {
        $to_delete = 1;
    } else {
        if ( $server->add_xslt ) {
            $outputUnimarc = $xslt_engine->transform( $oai_record->metadata->dom, $server->add_xslt );
            my $err = $xslt_engine->err;
            if ($err) {
                $self->printlog("XSLT::Base error: $err");
                $status = 'in_error';
                return $status;
            }
        } else {
            $outputUnimarc = $oai_record->metadata->dom;
        }
        $marcrecord = MARC::Record->new_from_xml( $outputUnimarc, 'UTF-8' );
    }
    my $imported_record;
    if ( $server->recordtype eq "biblio" ) {
        $imported_record = Koha::Import::OAI::Biblios->find(
            {
                repository => $server->endpoint,
                identifier => $oai_record->identifier,
                recordtype => $server->recordtype,
            }
        );
    } else {
        $imported_record = Koha::Import::OAI::Authorities->find(
            {
                repository => $server->endpoint,
                identifier => $oai_record->identifier,
                recordtype => $server->recordtype,
            }
        );
    }

    if ($imported_record) {
        if ($to_delete) {
            if ( $server->recordtype eq "biblio" ) {
                my $biblionumber = $imported_record->biblionumber;
                my $error        = DelBiblio($biblionumber);
                if ($error) {
                    $self->printlog(
                        "Record " . $oai_record->identifier . " not deleted, biblionumber: $biblionumber ($error)" );
                    $status = 'in_error';
                } else {
                    $self->printlog( "Record " . $oai_record->identifier . " deleted, biblionumber: $biblionumber" );
                    $status = 'deleted';
                }
            } else {
                my $authid = $imported_record->authid;
                DelAuthority( { authid => $authid } );
                $self->printlog( "Record " . $oai_record->identifier . " deleted, authid: $authid" );
                $status = 'deleted';
            }
        } else {
            my $existing_dt = dt_from_string( $imported_record->datestamp, 'iso' );
            my $incoming_dt = $oai_record->datestamp ? dt_from_string( $oai_record->datestamp, 'iso' ) : dt_from_string;
            if ( $force || $incoming_dt > $existing_dt ) {
                if ( $server->recordtype eq "biblio" ) {
                    my $biblionumber = $imported_record->biblionumber;
                    my $result       = ModBiblio( $marcrecord, $biblionumber, GetFrameworkCode($biblionumber) );
                    $self->printlog( "Record " . $oai_record->identifier . " updated, biblionumber: $biblionumber" );
                } else {
                    my $authid = $imported_record->authid;
                    my $result = ModAuthority( $authid, $marcrecord, GuessAuthTypeCode($marcrecord) );
                    $self->printlog( "Record " . $oai_record->identifier . " updated, authid: $authid" );
                }
                $imported_record->update(
                    {
                        datestamp => $incoming_dt,
                    }
                );
                $status = 'updated';
            } else {
                $self->printlog( "Record "
                        . $oai_record->identifier
                        . " skipped (incoming record was not newer than existing record)" );
                $status = 'skipped';
            }
        }
    } elsif ( !$to_delete ) {
        if ( $server->recordtype eq "biblio" ) {
            my ( $biblionumber, $biblioitemnumber ) = AddBiblio($marcrecord);
            $self->printlog( $oai_record->identifier . " added, biblionumber: $biblionumber" );
            Koha::Import::OAI::Biblio->new(
                {
                    repository   => $server->endpoint,
                    identifier   => $oai_record->identifier,
                    biblionumber => $biblionumber,
                    recordtype   => $server->recordtype,
                    datestamp    => $oai_record->datestamp,
                }
            )->store;
        } else {
            my $authid = AddAuthority( $marcrecord, "", GuessAuthTypeCode($marcrecord) );
            $self->printlog( $oai_record->identifier . " added, authid: $authid" );
            Koha::Import::OAI::Authority->new(
                {
                    repository => $server->endpoint,
                    identifier => $oai_record->identifier,
                    authid     => $authid,
                    recordtype => $server->recordtype,
                    datestamp  => $oai_record->datestamp,
                }
            )->store;
        }
        $status = 'added';
    } else {
        $self->printlog( "Record " . $oai_record->identifier . " skipped (record not present or already deleted)" );
        $status = 'skipped';
    }
    return $status;
}

=head2 $self->printlog

This method gives the caller an opportunity to handle log messages

=cut

sub printlog {
    my ( $self, $message ) = @_;
    return unless $self->{logger};
    $message = $self->{server}->servername . ": " . $message;
    $self->{logger}->($message);
}

1;
