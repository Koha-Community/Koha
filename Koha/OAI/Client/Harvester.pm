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

use C4::Biblio qw( AddBiblio GetFrameworkCode ModBiblio DelBiblio );
use C4::AuthoritiesMarc qw (AddAuthority GuessAuthTypeCode ModAuthority DelAuthority );
use C4::Log qw( cronlogaction );
use HTTP::OAI;
use HTTP::OAI::Metadata::OAI_DC;
use Koha::DateUtils qw( dt_from_string );
use Koha::OaiServers;
use Koha::Import::Oaipmh::Biblio;
use Koha::Import::Oaipmh::Biblios;
use Koha::Import::Oaipmh::Authority;
use Koha::Import::Oaipmh::Authorities;
use Koha::XSLT::Base;
use MARC::File::XML;
use MARC::Record;
use Modern::Perl;
use DateTime;
use DateTime::Format::Strptime;
use Try::Tiny qw( catch try );
use Date::Calc qw(
    Add_Delta_Days
    Today
);

my $strp = DateTime::Format::Strptime->new(
    pattern   => '%FT%TZ',
    time_zone => 'floating',
);

our $verbose = 0;
our $server;
our $force       = 0;
our $days        = 0;
our $xslt_engine = Koha::XSLT::Base->new;

=head2 new

$harvester = Koha::OAI::Client::Harvester->new( { server => $server, verbose => $verbose, days => $days, force => $force } );

New instance of Koha::OAI::Client::Harvester

C<$server> An OAI repository (Koha::OaiServer)

C<$verbose> print log messages to stdout when enabled

C<$days> number of days to harvest from (optional)

C<$force> force harvesting (ignore records datestamps)

=cut

sub new {

    my ( $self, $args ) = @_;

    $server  = $args->{'server'};
    $verbose = $args->{'verbose'};
    $days    = $args->{'days'};
    $force   = $args->{'force'};
    return $self;
}

=head2 init

Starts harvesting

=cut

sub init {
    my ( $self, $args ) = @_;

    printlog("Starting OAI Harvest from repository");

    my $h = HTTP::OAI::Harvester->new(
        repository => HTTP::OAI::Identify->new(
            baseURL => $server->endpoint,
            version => '2.0',
        )
    );

    printlog( "Using HTTP::OAI::Harvester version " . $HTTP::OAI::Harvester::VERSION );

    printlog( "Using endpoint "
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
        printlog("Available metadata formats for this repository: $lmdflog");
    } catch {
        printlog("ListMetadataFormats failed");
    };

    if ( $server->add_xslt ) {
        printlog( "Using XSLT file " . $server->add_xslt );
    } else {
        printlog("Not using an XSLT file");
    }

    my $start_date = '';
    my $today_date = '';

    if ($days) {

        # Change this to yyyy-mm-dd
        my $dt_today = dt_from_string();
        my ( $nowyear, $nowmonth, $nowday ) = Today();
        my @date     = Add_Delta_Days( $nowyear, $nowmonth, $nowday, -$days );
        my $dt_start = DateTime->new( year => $date[0], month => $date[1], day => $date[2] );
        $start_date = $dt_start->ymd();
        printlog("Harvesting from $start_date");
    }

    printlog("Asking for records");
    my $response = $h->ListRecords(
        metadataPrefix => $server->dataformat,
        set            => $server->oai_set,
        from           => $start_date,
    );
    if ( $response->is_error ) {
        printlog( "Error requesting ListRecords: " . $response->code . " " . $response->message );
        exit;
    }
    printlog( "Request URL: " . $response->requestURL );

    my %stats;
    my @statuses = qw(added updated deleted in_error skipped total);
    foreach my $status (@statuses) {
        $stats{$status} = 0;
    }

    printlog("Starting processing results");
    while ( my $oai_record = $response->next ) {
        $stats{'total'}++;
        my $status = $self->processRecord($oai_record);
        $stats{$status}++;
    }

    my $results = '';
    foreach my $status (@statuses) {
        $results .= $stats{$status} . " $status\n";
    }
    printlog( "Harvest results:\n" . $results );

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
        ) or printlog("OAI_HARVEST_REPORT letter not found");

        my $success = C4::Letters::EnqueueLetter(
            {
                letter     => $letter,
                to_address => C4::Context->preference("OAI-PMH:HarvestEmailReport"), message_transport_type => 'email'
            }
        );
        if ($success) {
            printlog("Email report enqueued");
        } else {
            printlog("Unable to enqueue report email");
        }
    }

    printlog("Ending OAI Harvest from repository");
}

=head2 processRecord

This method processes an incoming OAI record

=cut

sub processRecord {
    my $self       = shift;
    my $oai_record = shift;
    my $status     = '';
    unless ( $oai_record->identifier ) {
        printlog("No identifier found");
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
                printlog("XSLT::Base error: $err");
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
        $imported_record = Koha::Import::Oaipmh::Biblios->find(
            {
                repository => $server->endpoint,
                identifier => $oai_record->identifier,
                recordtype => $server->recordtype,
            }
        );
    } else {
        $imported_record = Koha::Import::Oaipmh::Authorities->find(
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
                    printlog(
                        "Record " . $oai_record->identifier . " not deleted, biblionumber: $biblionumber ($error)" );
                    $status = 'in_error';
                } else {
                    $imported_record->delete;
                    printlog( "Record " . $oai_record->identifier . " deleted, biblionumber: $biblionumber" );
                    $status = 'deleted';
                }
            } else {
                my $authid = $imported_record->authid;
                DelAuthority( { authid => $authid } );
                $imported_record->delete;
                printlog( "Record " . $oai_record->identifier . " deleted, authid: $authid" );
                $status = 'deleted';
            }
        } else {
            my $existing_dt = $strp->parse_datetime( $imported_record->datestamp );
            my $incoming_dt = $strp->parse_datetime( $oai_record->datestamp );

            if ( $force || !$incoming_dt || !$existing_dt || $incoming_dt > $existing_dt ) {
                if ( $server->recordtype eq "biblio" ) {
                    my $biblionumber = $imported_record->biblionumber;
                    my $result       = ModBiblio( $marcrecord, $biblionumber, GetFrameworkCode($biblionumber) );
                    printlog( "Record " . $oai_record->identifier . " updated, biblionumber: $biblionumber" );
                } else {
                    my $authid = $imported_record->authid;
                    my $result = ModAuthority( $authid, $marcrecord, GuessAuthTypeCode($marcrecord) );
                    printlog( "Record " . $oai_record->identifier . " updated, authid: $authid" );
                }
                $imported_record->update(
                    {
                        datestamp => $imported_record->datestamp,
                    }
                );
                $status = 'updated';
            } else {
                printlog( "Record "
                        . $oai_record->identifier
                        . " skipped (incoming record was not newer than existing record)" );
                $status = 'skipped';
            }
        }
    } elsif ( !$to_delete ) {
        if ( $server->recordtype eq "biblio" ) {
            my ( $biblionumber, $biblioitemnumber ) = AddBiblio($marcrecord);
            printlog( $oai_record->identifier . " added, biblionumber: $biblionumber" );
            Koha::Import::Oaipmh::Biblio->new(
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
            printlog( $oai_record->identifier . " added, authid: $authid" );
            Koha::Import::Oaipmh::Authority->new(
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
        printlog( "Record " . $oai_record->identifier . " skipped (record not present or already deleted)" );
        $status = 'skipped';
    }
    return $status;
}

=head2 printlog

This method adds a cronlog and prints to stdout if verbose is enabled

=cut

sub printlog {
    my $message = shift;
    $message = $server->servername . ": " . $message;
    print $message . "\n" if ($verbose);
    cronlogaction( { info => $message } );
}

1;
