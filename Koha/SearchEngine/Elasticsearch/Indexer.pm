package Koha::SearchEngine::Elasticsearch::Indexer;

# Copyright 2013 Catalyst IT
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

use Carp;
use Modern::Perl;
use Try::Tiny;
use List::Util qw(any);
use base qw(Koha::SearchEngine::Elasticsearch);
use Data::Dumper;

# For now just marc, but we can do anything here really
use Catmandu::Importer::MARC;
use Catmandu::Store::ElasticSearch;

use Koha::Exceptions;
use C4::Context;

Koha::SearchEngine::Elasticsearch::Indexer->mk_accessors(qw( store ));

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
    INDEX_STATUS_OK => 0,
    INDEX_STATUS_REINDEX_REQUIRED => 1,
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

The values in the arrays must match up, and the 999$c value in the MARC record
will be rewritten using the values in C<$biblionums> to ensure they are correct.
If C<$biblionums> is C<undef>, this won't happen, so in that case you should make
sure that 999$c is correct.

Note that this will modify the original record if C<$biblionums> is supplied.
If that's a problem, clone them first.

=over 4

=item C<$biblionums>

Arrayref of biblio numbers for the C<$records>, the order must be the same as
and match up with C<$records>.

=item C<$records>

Arrayref of C<MARC::Record>s.

=back

=cut

sub update_index {
    my ($self, $biblionums, $records) = @_;

    if ($biblionums) {
        $self->_sanitise_records($biblionums, $records);
    }

    my $conf = $self->get_elasticsearch_params();
    my $elasticsearch = $self->get_elasticsearch();
    my $documents = $self->marc_records_to_documents($records);
    my @body;

    foreach my $document_info (@{$documents}) {
        my ($id, $document) = @{$document_info};
        push @body, {
            index => {
                _id => $id
            }
        };
        push @body, $document;
    }
    if (@body) {
        my $response = $elasticsearch->bulk(
            index => $conf->{index_name},
            type => 'data', # is just hard coded in Indexer.pm?
            body => \@body
        );
    }
    # TODO: handle response
    return 1;
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
    my ($self, $status) = @_;
    my $key = 'ElasticsearchIndexStatus_' . $self->index;

    if (defined $status) {
        unless (any { $status == $_ } (
                INDEX_STATUS_OK,
                INDEX_STATUS_REINDEX_REQUIRED,
                INDEX_STATUS_RECREATE_REQUIRED,
            )
        ) {
            Koha::Exceptions::Exception->throw("Invalid index status: $status");
        }
        C4::Context->set_preference($key, $status);
        return $status;
    }
    else {
        return C4::Context->preference($key);
    }
}

=head2 update_mappings

Generate Elasticsearch mappings from mappings stored in database and
perform a request to update Elasticsearch index mappings. Will throw an
error and set index status to C<INDEX_STATUS_RECREATE_REQUIRED> if update
failes.

=cut

sub update_mappings {
    my ($self) = @_;
    my $conf = $self->get_elasticsearch_params();
    my $elasticsearch = $self->get_elasticsearch();
    my $mappings = $self->get_elasticsearch_mappings();

    foreach my $type (keys %{$mappings}) {
        try {
            my $response = $elasticsearch->indices->put_mapping(
                index => $conf->{index_name},
                type => $type,
                body => {
                    $type => $mappings->{$type}
                }
            );
        } catch {
            $self->set_index_status_recreate_required();
            my $reason = $_[0]->{vars}->{body}->{error}->{reason};
            Koha::Exceptions::Exception->throw(
                error => "Unable to update mappings for index \"$conf->{index_name}\". Reason was: \"$reason\". Index needs to be recreated and reindexed",
            );
        };
    }
    $self->set_index_status_ok();
}

=head2 update_index_background($biblionums, $records)

This has exactly the same API as C<update_index> however it'll
return immediately. It'll start a background process that does the adding.

If it fails to add to Elasticsearch then it'll add to a queue that will cause
it to be updated by a regular index cron job in the future.

=cut

# TODO implement in the future - I don't know the best way of doing this yet.
# If fork: make sure process group is changed so apache doesn't wait for us.

sub update_index_background {
    my $self = shift;
    $self->update_index(@_);
}

=head2 delete_index($biblionums)

C<$biblionums> is an arrayref of biblionumbers to delete from the index.

=cut

sub delete_index {
    my ($self, $biblionums) = @_;

    if ( !$self->store ) {
        my $params  = $self->get_elasticsearch_params();
        $self->store(
            Catmandu::Store::ElasticSearch->new(
                %$params,
                index_settings => $self->get_elasticsearch_settings(),
                index_mappings => $self->get_elasticsearch_mappings(),
            )
        );
    }
    $self->store->bag->delete($_) foreach @$biblionums;
    $self->store->bag->commit;
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
    if ($self->index_exists) {
        my $conf = $self->get_elasticsearch_params();
        my $elasticsearch = $self->get_elasticsearch();
        $elasticsearch->indices->delete(index => $conf->{index_name});
        $self->set_index_status_recreate_required();
    }
}

=head2 create_index

Creates the index (including mappings) on the Elasticsearch server.

=cut

sub create_index {
    my ($self) = @_;
    my $conf = $self->get_elasticsearch_params();
    my $settings = $self->get_elasticsearch_settings();
    my $elasticsearch = $self->get_elasticsearch();
    $elasticsearch->indices->create(
        index => $conf->{index_name},
        body => {
            settings => $settings
        }
    );
    $self->update_mappings();
}

=head2 index_exists

Checks if index has been created on the Elasticsearch server. Returns C<1> or the
empty string to indicate whether index exists or not.

=cut

sub index_exists {
    my ($self) = @_;
    my $conf = $self->get_elasticsearch_params();
    my $elasticsearch = $self->get_elasticsearch();
    return $elasticsearch->indices->exists(
        index => $conf->{index_name},
    );
}

sub _sanitise_records {
    my ($self, $biblionums, $records) = @_;

    confess "Unequal number of values in \$biblionums and \$records." if (@$biblionums != @$records);

    my $c = @$biblionums;
    for (my $i=0; $i<$c; $i++) {
        my $bibnum = $biblionums->[$i];
        my $rec = $records->[$i];
        # I've seen things you people wouldn't believe. Attack ships on fire
        # off the shoulder of Orion. I watched C-beams glitter in the dark near
        # the Tannhauser gate. MARC records where 999$c doesn't match the
        # biblionumber column. All those moments will be lost in time... like
        # tears in rain...
        if ( $rec ) {
            $rec->delete_fields($rec->field('999'));
            $rec->append_fields(MARC::Field->new('999','','','c' => $bibnum, 'd' => $bibnum));
        }
    }
}

1;

__END__

=head1 AUTHOR

=over 4

=item Chris Cormack C<< <chrisc@catalyst.net.nz> >>

=item Robin Sheat C<< <robin@catalyst.net.nz> >>

=back
