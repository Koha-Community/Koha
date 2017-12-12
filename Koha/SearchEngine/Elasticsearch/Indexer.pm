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
use base qw(Koha::SearchEngine::Elasticsearch);
use Data::Dumper;

# For now just marc, but we can do anything here really
use Catmandu::Importer::MARC;
use Catmandu::Store::ElasticSearch;

Koha::SearchEngine::Elasticsearch::Indexer->mk_accessors(qw( store ));

=head1 NAME

Koha::SearchEngine::Elasticsearch::Indexer - handles adding new records to the index

=head1 SYNOPSIS

    my $indexer = Koha::SearchEngine::Elasticsearch::Indexer->new(
        { index => Koha::SearchEngine::BIBLIOS_INDEX } );
    $indexer->drop_index();
    $indexer->update_index(\@biblionumbers, \@records);

=head1 FUNCTIONS

=head2 $indexer->update_index($biblionums, $records);

C<$biblionums> is an arrayref containing the biblionumbers for the records.

C<$records> is an arrayref containing the L<MARC::Record>s themselves.

The values in the arrays must match up, and the 999$c value in the MARC record
will be rewritten using the values in C<$biblionums> to ensure they are correct.
If C<$biblionums> is C<undef>, this won't happen, but you should be sure that
999$c is correct on your own then.

Note that this will modify the original record if C<$biblionums> is supplied.
If that's a problem, clone them first.

=cut

sub update_index {
    my ($self, $biblionums, $records) = @_;

    # TODO should have a separate path for dealing with a large number
    # of records at once where we use the bulk update functions in ES.
    if ($biblionums) {
        $self->_sanitise_records($biblionums, $records);
    }

    $self->ensure_mappings_updated();
    $self->bulk_index($records);
    return 1;
}

sub bulk_index {
    my ($self, $records) = @_;
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

sub ensure_mappings_updated {
    my ($self) = @_;
    unless ($self->{_mappings_updated}) {
        $self->update_mappings();
    }
}

sub update_mappings {
    my ($self) = @_;
    my $conf = $self->get_elasticsearch_params();
    my $elasticsearch = $self->get_elasticsearch();
    my $mappings = $self->get_elasticsearch_mappings();

    foreach my $type (keys %{$mappings}) {
        my $response = $elasticsearch->indices->put_mapping(
            index => $conf->{index_name},
            type => $type,
            body => {
                $type => $mappings->{$type}
            }
        );
        # TODO: process response, produce errors etc
    }
    $self->{_mappings_updated} = 1;
}

=head2 $indexer->update_index_background($biblionums, $records)

This has exactly the same API as C<update_index_background> however it'll
return immediately. It'll start a background process that does the adding.

If it fails to add to Elasticsearch then it'll add to a queue that will cause
it to be updated by a regular index cron job in the future.

# TODO implement in the future - I don't know the best way of doing this yet.
# If fork: make sure process group is changed so apache doesn't wait for us.

=cut

sub update_index_background {
    my $self = shift;
    $self->update_index(@_);
}

=head2 $indexer->delete_index($biblionums)

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

=head2 $indexer->delete_index_background($biblionums)

Identical to L<delete_index>, this will return immediately and start a
background process to do the actual deleting.

=cut

# TODO implement in the future

sub delete_index_background {
    my $self = shift;
    $self->delete_index(@_);
}

=head2 $indexer->drop_index();

Drops the index from the elasticsearch server. Calling C<update_index>
after this will recreate it again.

=cut

sub drop_index {
    my ($self) = @_;
    if ($self->index_exists) {
        my $conf = $self->get_elasticsearch_params();
        my $elasticsearch = $self->get_elasticsearch();
        my $response = $elasticsearch->indices->delete(index => $conf->{index_name});
        # TODO: Handle response? Convert errors to exceptions/die
    }
}

sub create_index {
    my ($self) = @_;
    my $conf = $self->get_elasticsearch_params();
    my $settings = $self->get_elasticsearch_settings();
    my $elasticsearch = $self->get_elasticsearch();
    my $response = $elasticsearch->indices->create(
        index => $conf->{index_name},
        body => {
            settings => $settings
        }
    );
    # TODO: Handle response? Convert errors to exceptions/die
}

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
