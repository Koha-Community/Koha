package Koha::SearchEngine::Elasticsearch::Indexer;

# Copyright 2013 Catalyst IT
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

use Carp qw( carp croak );
use Modern::Perl;
use Try::Tiny       qw( catch try );
use List::Util      qw( any );
use List::MoreUtils qw( natatime );
use base            qw(Koha::SearchEngine::Elasticsearch);

use Koha::Exceptions;
use Koha::Exceptions::Elasticsearch;
use Koha::SearchEngine::Zebra::Indexer;
use Koha::BackgroundJob::UpdateElasticIndex;
use C4::AuthoritiesMarc qw//;
use C4::Context;
use Koha::Biblios;

=head1 NAME

Koha::SearchEngine::Elasticsearch::Indexer - handles adding new records to the index

=head1 SYNOPSIS

    my $indexer = Koha::SearchEngine::Elasticsearch::Indexer->new(
        { index => Koha::SearchEngine::BIBLIOS_INDEX } );
    $indexer->drop_index();
    $indexer->update_index(\@biblionumbers, \@records);


=head1 CONSTANTS

=over 4

=item C<Koha::SearchEngine::Elasticsearch::Indexer::INDEX_STATUS_OK>

Represents an index state where index is created and in a working state.

=item C<Koha::SearchEngine::Elasticsearch::Indexer::INDEX_STATUS_REINDEX_REQUIRED>

Not currently used, but could be useful later, for example if can detect when new field or mapping added.

=item C<Koha::SearchEngine::Elasticsearch::Indexer::INDEX_STATUS_RECREATE_REQUIRED>

Representings an index state where index needs to be recreated and is not in a working state.

=back

=cut

use constant {
    INDEX_STATUS_OK                => 0,
    INDEX_STATUS_REINDEX_REQUIRED  => 1,
    INDEX_STATUS_RECREATE_REQUIRED => 2,
};

=head1 FUNCTIONS

=head2 update_index($biblionums, $records)

    try {
        $self->update_index($biblionums, $records);
    } catch {
        die("Something went wrong trying to update index:" .  $_[0]);
    }

Converts C<MARC::Records> C<$records> to Elasticsearch documents and performs
an update request for these records on the Elasticsearch index.

=over 4

=item C<$biblionums>

Arrayref of biblio numbers for the C<$records>, the order must be the same as
and match up with C<$records>.

=item C<$records>

Arrayref of C<MARC::Record>s.

=back

=cut

sub update_index {
    my ( $self, $record_ids, $records ) = @_;

    my $index_record_ids = [];
    unless ( $records && @$records ) {
        for my $record_id ( sort { $a <=> $b } @$record_ids ) {

            next unless $record_id;

            my $record = $self->_get_record($record_id);
            if ($record) {
                push @$records,          $record;
                push @$index_record_ids, $record_id;
            }
        }
    } else {
        $index_record_ids = $record_ids;
    }

    my $documents = $self->marc_records_to_documents($records);
    my @body;
    for ( my $i = 0 ; $i < scalar @$index_record_ids ; $i++ ) {
        my $id       = $index_record_ids->[$i];
        my $document = $documents->[$i];
        push @body, { index => { _id => "$id" } };
        push @body, $document;
    }
    my $response;
    if (@body) {
        try {
            my $elasticsearch = $self->get_elasticsearch();
            $response = $elasticsearch->bulk(
                index => $self->index_name,
                body  => \@body
            );
            if ( $response->{errors} ) {
                carp "One or more ElasticSearch errors occurred when indexing documents";
            }
        } catch {
            Koha::Exceptions::Elasticsearch::BadResponse->throw(
                type    => $_->{type},
                details => $_->{text},
            );
        };
    }
    return $response;
}

=head2 set_index_status_ok

Convenience method for setting index status to C<INDEX_STATUS_OK>.

=cut

sub set_index_status_ok {
    my ($self) = @_;
    $self->index_status(INDEX_STATUS_OK);
}

=head2 is_index_status_ok

Convenience method for checking if index status is C<INDEX_STATUS_OK>.

=cut

sub is_index_status_ok {
    my ($self) = @_;
    return $self->index_status == INDEX_STATUS_OK;
}

=head2 set_index_status_reindex_required

Convenience method for setting index status to C<INDEX_REINDEX_REQUIRED>.

=cut

sub set_index_status_reindex_required {
    my ($self) = @_;
    $self->index_status(INDEX_STATUS_REINDEX_REQUIRED);
}

=head2 is_index_status_reindex_required

Convenience method for checking if index status is C<INDEX_STATUS_REINDEX_REQUIRED>.

=cut

sub is_index_status_reindex_required {
    my ($self) = @_;
    return $self->index_status == INDEX_STATUS_REINDEX_REQUIRED;
}

=head2 set_index_status_recreate_required

Convenience method for setting index status to C<INDEX_STATUS_RECREATE_REQUIRED>.

=cut

sub set_index_status_recreate_required {
    my ($self) = @_;
    $self->index_status(INDEX_STATUS_RECREATE_REQUIRED);
}

=head2 is_index_status_recreate_required

Convenience method for checking if index status is C<INDEX_STATUS_RECREATE_REQUIRED>.

=cut

sub is_index_status_recreate_required {
    my ($self) = @_;
    return $self->index_status == INDEX_STATUS_RECREATE_REQUIRED;
}

=head2 index_status($status)

Will either set the current index status to C<$status> and return C<$status>,
or return the current index status if called with no arguments.

=over 4

=item C<$status>

Optional argument. If passed will set current index status to C<$status> if C<$status> is
a valid status. See L</CONSTANTS>.

=back

=cut

sub index_status {
    my ( $self, $status ) = @_;
    my $key = 'ElasticsearchIndexStatus_' . $self->index;

    if ( defined $status ) {
        unless (
            any { $status == $_ } (
                INDEX_STATUS_OK,
                INDEX_STATUS_REINDEX_REQUIRED,
                INDEX_STATUS_RECREATE_REQUIRED,
            )
            )
        {
            Koha::Exception->throw("Invalid index status: $status");
        }
        C4::Context->set_preference( $key, $status );
        return $status;
    } else {
        return C4::Context->preference($key);
    }
}

=head2 update_mappings

Generate Elasticsearch mappings from mappings stored in database and
perform a request to update Elasticsearch index mappings. Will throw an
error and set index status to C<INDEX_STATUS_RECREATE_REQUIRED> if update
failed.

=cut

sub update_mappings {
    my ($self)        = @_;
    my $elasticsearch = $self->get_elasticsearch();
    my $mappings      = $self->get_elasticsearch_mappings();

    try {
        my $response = $elasticsearch->indices->put_mapping(
            index => $self->index_name,
            body  => $mappings,
        );
    } catch {
        $self->set_index_status_recreate_required();
        my $reason     = $_[0]->{vars}->{body}->{error}->{reason};
        my $index_name = $self->index_name;
        Koha::Exception->throw(
            error =>
                "Unable to update mappings for index \"$index_name\". Reason was: \"$reason\". Index needs to be recreated and reindexed",
        );
    };
    $self->set_index_status_ok();
}

=head2 update_index_background($record_numbers, $server)

This has exactly the same API as C<update_index> however it'll
return immediately. It'll start a background process that does the adding.

If it fails to add to Elasticsearch then it'll add to a queue that will cause
it to be updated by a regular index cron job in the future.

=cut

sub update_index_background {
    my ( $self, $record_numbers, $server ) = @_;

    Koha::BackgroundJob::UpdateElasticIndex->new->enqueue(
        { record_ids => $record_numbers, record_server => $server } );
}

=head2 index_records

This function takes an array of record numbers and fetches the records to send to update_index
for actual indexing.

If $records parameter is provided the records will be used as-is, this is only utilized for authorities
at the moment.

The other variables are used for parity with Zebra indexing calls. Currently the calls are passed through
to Zebra as well.

Will obey the chunk_size defined in koha-conf for amount of records to send during a single reindex, or default
to 5000.

=cut

sub index_records {
    my ( $self, $record_numbers, $op, $server, $records ) = @_;
    $record_numbers = [$record_numbers] if ref $record_numbers ne 'ARRAY' && defined $record_numbers;
    $records        = [$records]        if ref $records ne 'ARRAY'        && defined $records;
    if ( $op eq 'specialUpdate' ) {
        my $config    = $self->get_elasticsearch_params;
        my $at_a_time = $config->{chunk_size} // 5000;
        my ( $record_chunks, $record_id_chunks );
        $record_chunks    = natatime $at_a_time, @$records        if ($records);
        $record_id_chunks = natatime $at_a_time, @$record_numbers if ($record_numbers);
        if ($records) {
            while ( ( my @records = $record_chunks->() ) && ( my @record_ids = $record_id_chunks->() ) ) {
                $self->update_index( \@record_ids, \@records );
            }
        } else {
            while ( my @record_ids = $record_id_chunks->() ) {
                $self->update_index_background( \@record_ids, $server );
            }
        }
    } elsif ( $op eq 'recordDelete' ) {
        $self->delete_index_background($record_numbers);
    }

    #FIXME Current behaviour is to index Zebra when using ES, at some point we should stop
    Koha::SearchEngine::Zebra::Indexer::index_records( $self, $record_numbers, $op, $server, undef );
}

sub _get_record {
    my ( $self, $record_id ) = @_;

    my $record;

    if ( $self->index eq $Koha::SearchEngine::BIBLIOS_INDEX ) {
        my $biblio = Koha::Biblios->find($record_id);
        $record = $biblio->metadata_record( { embed_items => 1 } )
            if $biblio;
    } else {
        $record = C4::AuthoritiesMarc::GetAuthority($record_id);
    }

    return $record;
}

=head2 delete_index($biblionums)

C<$biblionums> is an arrayref of biblionumbers to delete from the index.

=cut

sub delete_index {
    my ( $self, $biblionums ) = @_;

    my $elasticsearch = $self->get_elasticsearch();
    my @body          = map { { delete => { _id => "$_" } } } @{$biblionums};
    my $result        = $elasticsearch->bulk(
        index => $self->index_name,
        body  => \@body,
    );
    if ( $result->{errors} ) {
        croak "An Elasticsearch error occurred during bulk delete";
    }
}

=head2 delete_index_background($biblionums)

Identical to L</delete_index($biblionums)>

=cut

# TODO: Should be made async
sub delete_index_background {
    my $self = shift;
    $self->delete_index(@_);
}

=head2 drop_index

Drops the index from the Elasticsearch server.

=cut

sub drop_index {
    my ($self) = @_;
    if ( $self->index_exists ) {
        my $elasticsearch = $self->get_elasticsearch();
        $elasticsearch->indices->delete( index => $self->index_name );
        $self->set_index_status_recreate_required();
    }
}

=head2 create_index

Creates the index (including mappings) on the Elasticsearch server.

=cut

sub create_index {
    my ($self)        = @_;
    my $settings      = $self->get_elasticsearch_settings();
    my $elasticsearch = $self->get_elasticsearch();
    $elasticsearch->indices->create(
        index => $self->index_name,
        body  => { settings => $settings }
    );
    $self->update_mappings();
}

=head2 index_exists

Checks if index has been created on the Elasticsearch server. Returns C<1> or the
empty string to indicate whether index exists or not.

=cut

sub index_exists {
    my ($self) = @_;
    my $elasticsearch = $self->get_elasticsearch();
    return $elasticsearch->indices->exists(
        index => $self->index_name,
    );
}

1;

__END__

=head1 AUTHOR

=over 4

=item Chris Cormack C<< <chrisc@catalyst.net.nz> >>

=item Robin Sheat C<< <robin@catalyst.net.nz> >>

=back
