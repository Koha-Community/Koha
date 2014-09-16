package Koha::ElasticSearch;

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

use base qw(Class::Accessor);

use C4::Context;
use Carp;
use Elasticsearch;
use Koha::Database;
use Modern::Perl;

use Data::Dumper;    # TODO remove

__PACKAGE__->mk_ro_accessors(qw( index ));

=head1 NAME

Koha::ElasticSearch - Base module for things using elasticsearch

=head1 ACCESSORS

=over 4

=item index

The name of the index to use, generally 'biblios' or 'authorities'.

=back

=head1 FUNCTIONS

=cut

sub new {
    my $class = shift @_;
    my $self = $class->SUPER::new(@_);
    # Check for a valid index
    croak('No index name provided') unless $self->index;
    return $self;
}

=head2 get_elasticsearch_params

    my $params = $self->get_elasticsearch_params();

This provides a hashref that contains the parameters for connecting to the
ElasicSearch servers, in the form:

    {
        'servers' => ['127.0.0.1:9200', 'anotherserver:9200'],
        'index_name' => 'koha_instance',
    }

This is configured by the following in the C<config> block in koha-conf.xml:

    <elasticsearch>
        <server>127.0.0.1:9200</server>
        <server>anotherserver:9200</server>
        <index_name>koha_instance</index_name>
    </elasticsearch>

=cut

sub get_elasticsearch_params {
    my ($self) = @_;

    # Copy the hash so that we're not modifying the original
    my $es = { %{ C4::Context->config('elasticsearch') } };
    die "No 'elasticsearch' block is defined in koha-conf.xml.\n" if ( !$es );

    # Helpfully, the multiple server lines end up in an array for us anyway
    # if there are multiple ones, but not if there's only one.
    my $server = $es->{server};
    delete $es->{server};
    if ( ref($server) eq 'ARRAY' ) {

        # store it called 'servers'
        $es->{servers} = $server;
    }
    elsif ($server) {
        $es->{servers} = [$server];
    }
    else {
        die "No elasticsearch servers were specified in koha-conf.xml.\n";
    }
    die "No elasticserver index_name was specified in koha-conf.xml.\n"
      if ( !$es->{index_name} );
    # Append the name of this particular index to our namespace
    $es->{index_name} .= '_' . $self->index;
    return $es;
}

=head2 get_elasticsearch_settings

    my $settings = $self->get_elasticsearch_settings();

This provides the settings provided to elasticsearch when an index is created.
These can do things like define tokenisation methods.

A hashref containing the settings is returned.

=cut

sub get_elasticsearch_settings {
    my ($self) = @_;

    # Ultimately this should come from a file or something, and not be
    # hardcoded.
    my $settings = {
        index => {
            analysis => {
                analyzer => {
                    analyser_phrase => {
                        tokenizer => 'keyword',
                        filter    => 'lowercase',
                    },
                    analyser_standard => {
                        tokenizer => 'standard',
                        filter    => 'lowercase',
                    }
                }
            }
        }
    };
    return $settings;
}

=head2 get_elasticsearch_mappings

    my $mappings = $self->get_elasticsearch_mappings();

This provides the mappings that get passed to elasticsearch when an index is
created.

=cut

sub get_elasticsearch_mappings {
    my ($self) = @_;

    my $mappings = {
        data => {
            properties => {
                record => {
                    store          => "yes",
                    include_in_all => "false",
                    type           => "string",
                },
            }
        }
    };
    $self->_foreach_mapping(
        sub {
            my ( undef, $name, $type, $facet ) = @_;

            # TODO if this gets any sort of complexity to it, it should
            # be broken out into its own function.

            # TODO be aware of date formats, but this requires pre-parsing
            # as ES will simply reject anything with an invalid date.
            my $es_type =
              $type eq 'boolean'
              ? 'boolean'
              : 'string';
            $mappings->{data}{properties}{$name} = {
                search_analyzer => "analyser_standard",
                index_analyzer  => "analyser_standard",
                type            => $es_type,
                fields          => {
                    phrase => {
                        search_analyzer => "analyser_phrase",
                        index_analyzer  => "analyser_phrase",
                        type            => "string"
                    },
                },
            };
            $mappings->{data}{properties}{$name}{null_value} = 0
              if $type eq 'boolean';
            if ($facet) {
                $mappings->{data}{properties}{ $name . '__facet' } = {
                    type  => "string",
                    index => "not_analyzed",
                };
            }
        }
    );
    return $mappings;
}

# Provides the rules for data conversion.
sub get_fixer_rules {
    my ($self) = @_;

    my $marcflavour = lc C4::Context->preference('marcflavour');
    my @rules;
    $self->_foreach_mapping(
        sub {
            my ( undef, $name, $type, $facet, $marcs ) = @_;
            my $field = $marcs->{$marcflavour};
            return unless defined $marcs->{$marcflavour};
            my $options = '';

            # There's a bug when using 'split' with something that
            # selects a range
            # The split makes everything into nested arrays, but that's not
            # really a big deal, ES doesn't mind.
            $options = '-split => 1' unless $field =~ m|_/| || $type eq 'sum';
            push @rules, "marc_map('$field','${name}', $options)";
            if ($facet) {
                push @rules, "marc_map('$field','${name}__facet', $options)";
            }
            if ( $type eq 'boolean' ) {

                # boolean gets special handling, basically if it doesn't exist,
                # it's added and set to false. Otherwise we can't query it.
                push @rules,
                  "unless exists('$name') add_field('$name', 0) end";
            }
            if ($type eq 'sum' ) {
                push @rules, "sum('$name')";
            }
        }
    );

    return \@rules;
}

=head2 _foreach_mapping

    $self->_foreach_mapping(
        sub {
            my ( $id, $name, $type, $facet, $marcs ) = @_;
            my $marc = $marcs->{marc21};
        }
    );

This allows you to apply a function to each entry in the elasticsearch mappings
table, in order to build the mappings for whatever is needed.

In the provided function, the files are:

=over 4

=item C<$id>

An ID number, corresponding to the entry in the database.

=item C<$name>

The field name for elasticsearch (corresponds to the 'mapping' column in the
database.

=item C<$type>

The type for this value, e.g. 'string'.

=item C<$facet>

True if this value should be facetised. This only really makes sense if the
field is understood by the facet processing code anyway.

=item C<$marc>

A hashref containing the MARC field specifiers for each MARC type. It's quite
possible for this to be undefined if there is otherwise an entry in a
different MARC form.

=back

=cut

sub _foreach_mapping {
    my ( $self, $sub ) = @_;

    # TODO use a caching framework here
    my $database = Koha::Database->new();
    my $schema   = $database->schema();
    my $rs       = $schema->resultset('ElasticsearchMapping')->search();
    for my $row ( $rs->all ) {
        $sub->(
            $row->id,
            $row->mapping,
            $row->type,
            $row->facet,
            {
                marc21  => $row->marc21,
                unimarc => $row->unimarc,
                normarc => $row->normarc
            }
        );
    }
}

1;

__END__

=head1 AUTHOR

=over 4

=item Chris Cormack C<< <chrisc@catalyst.net.nz> >>

=item Robin Sheat C<< <robin@catalyst.net.nz> >>

=back

=cut
