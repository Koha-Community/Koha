package Koha::SearchEngine::Elasticsearch;

# Copyright 2015 Catalyst IT
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

use Koha::Database;
use Koha::Exceptions::Config;
use Koha::SearchFields;
use Koha::SearchMarcMaps;

use Carp;
use JSON;
use Modern::Perl;
use Readonly;
use Search::Elasticsearch;
use Try::Tiny;
use YAML::Syck;

__PACKAGE__->mk_ro_accessors(qw( index ));
__PACKAGE__->mk_accessors(qw( sort_fields ));

# Constants to refer to the standard index names
Readonly our $BIBLIOS_INDEX     => 'biblios';
Readonly our $AUTHORITIES_INDEX => 'authorities';

=head1 NAME

Koha::SearchEngine::Elasticsearch - Base module for things using elasticsearch

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
        'nodes' => ['127.0.0.1:9200', 'anotherserver:9200'],
        'index_name' => 'koha_instance_index',
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
    my $conf = C4::Context->config('elasticsearch');
    die "No 'elasticsearch' block is defined in koha-conf.xml.\n" if ( !$conf );
    my $es = { %{ $conf } };

    # Helpfully, the multiple server lines end up in an array for us anyway
    # if there are multiple ones, but not if there's only one.
    my $server = $es->{server};
    delete $es->{server};
    if ( ref($server) eq 'ARRAY' ) {

        # store it called 'nodes' (which is used by newer Search::Elasticsearch)
        $es->{nodes} = $server;
    }
    elsif ($server) {
        $es->{nodes} = [$server];
    }
    else {
        die "No elasticsearch servers were specified in koha-conf.xml.\n";
    }
    die "No elasticserver index_name was specified in koha-conf.xml.\n"
      if ( !$es->{index_name} );
    # Append the name of this particular index to our namespace
    $es->{index_name} .= '_' . $self->index;

    $es->{key_prefix} = 'es_';
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

    # Use state to speed up repeated calls
    state $settings = undef;
    if (!defined $settings) {
        my $config_file = C4::Context->config('elasticsearch_index_config');
        $config_file ||= C4::Context->config('intranetdir') . '/admin/searchengine/elasticsearch/index_config.yaml';
        $settings = LoadFile( $config_file );
    }

    return $settings;
}

=head2 get_elasticsearch_mappings

    my $mappings = $self->get_elasticsearch_mappings();

This provides the mappings that get passed to elasticsearch when an index is
created.

=cut

sub get_elasticsearch_mappings {
    my ($self) = @_;

    # Use state to speed up repeated calls
    state %all_mappings;
    state %sort_fields;

    if (!defined $all_mappings{$self->index}) {
        $sort_fields{$self->index} = {};
        my $mappings = {
            data => _get_elasticsearch_mapping('general', '')
        };
        my $marcflavour = lc C4::Context->preference('marcflavour');
        $self->_foreach_mapping(
            sub {
                my ( $name, $type, $facet, $suggestible, $sort, $marc_type ) = @_;
                return if $marc_type ne $marcflavour;
                # TODO if this gets any sort of complexity to it, it should
                # be broken out into its own function.

                # TODO be aware of date formats, but this requires pre-parsing
                # as ES will simply reject anything with an invalid date.
                my $es_type = 'text';
                if ($type eq 'boolean') {
                    $es_type = 'boolean';
                } elsif ($type eq 'number' || $type eq 'sum') {
                    $es_type = 'integer';
                } elsif ($type eq 'isbn' || $type eq 'stdno') {
                    $es_type = 'stdno';
                }

                $mappings->{data}{properties}{$name} = _get_elasticsearch_mapping('search', $es_type);

                if ($facet) {
                    $mappings->{data}{properties}{ $name . '__facet' } = _get_elasticsearch_mapping('facet', $es_type);
                }
                if ($suggestible) {
                    $mappings->{data}{properties}{ $name . '__suggestion' } = _get_elasticsearch_mapping('suggestible', $es_type);
                }
                # Sort is a bit special as it can be true, false, undef.
                # We care about "true" or "undef",
                # "undef" means to do the default thing, which is make it sortable.
                if (!defined $sort || $sort) {
                    $mappings->{data}{properties}{ $name . '__sort' } = _get_elasticsearch_mapping('sort', $es_type);
                    $sort_fields{$self->index}{$name} = 1;
                }
            }
        );
        $all_mappings{$self->index} = $mappings;
    }
    $self->sort_fields(\%{$sort_fields{$self->index}});

    return $all_mappings{$self->index};
}

=head2 _get_elasticsearch_mapping

Get the ES mappings for the given purpose and data type

$mapping = _get_elasticsearch_mapping('search', 'text');

=cut

sub _get_elasticsearch_mapping {

    my ( $purpose, $type ) = @_;

    # Use state to speed up repeated calls
    state $settings = undef;
    if (!defined $settings) {
        my $config_file = C4::Context->config('elasticsearch_field_config');
        $config_file ||= C4::Context->config('intranetdir') . '/admin/searchengine/elasticsearch/field_config.yaml';
        $settings = LoadFile( $config_file );
    }

    if (!defined $settings->{$purpose}) {
        die "Field purpose $purpose not defined in field config";
    }
    if ($type eq '') {
        return $settings->{$purpose};
    }
    if (defined $settings->{$purpose}{$type}) {
        return $settings->{$purpose}{$type};
    }
    if (defined $settings->{$purpose}{'default'}) {
        return $settings->{$purpose}{'default'};
    }
    return undef;
}

sub reset_elasticsearch_mappings {
    my ( $reset_fields ) = @_;
    my $mappings_yaml = C4::Context->config('elasticsearch_index_mappings');
    $mappings_yaml ||= C4::Context->config('intranetdir') . '/admin/searchengine/elasticsearch/mappings.yaml';
    my $indexes = LoadFile( $mappings_yaml );

    while ( my ( $index_name, $fields ) = each %$indexes ) {
        while ( my ( $field_name, $data ) = each %$fields ) {
            my $field_type = $data->{type};
            my $field_label = $data->{label};
            my $mappings = $data->{mappings};
            my $search_field = Koha::SearchFields->find_or_create({ name => $field_name, label => $field_label, type => $field_type }, { key => 'name' });
            for my $mapping ( @$mappings ) {
                my $marc_field = Koha::SearchMarcMaps->find_or_create({ index_name => $index_name, marc_type => $mapping->{marc_type}, marc_field => $mapping->{marc_field} });
                $search_field->add_to_search_marc_maps($marc_field, { facet => $mapping->{facet} || 0, suggestible => $mapping->{suggestible} || 0, sort => $mapping->{sort} } );
            }
        }
    }
}

# This overrides the accessor provided by Class::Accessor so that if
# sort_fields isn't set, then it'll generate it.
sub sort_fields {
    my $self = shift;
    if (@_) {
        $self->_sort_fields_accessor(@_);
        return;
    }
    my $val = $self->_sort_fields_accessor();
    return $val if $val;

    # This will populate the accessor as a side effect
    $self->get_elasticsearch_mappings();
    return $self->_sort_fields_accessor();
}

# Provides the rules for data conversion.
sub get_fixer_rules {
    my ($self) = @_;

    my $marcflavour = lc C4::Context->preference('marcflavour');
    my @rules;

    $self->_foreach_mapping(
        sub {
            my ( $name, $type, $facet, $suggestible, $sort, $marc_type, $marc_field ) = @_;
            return if $marc_type ne $marcflavour;
            my $options ='';

            push @rules, "marc_map('$marc_field','${name}.\$append', $options)";
            if ($facet) {
                push @rules, "marc_map('$marc_field','${name}__facet.\$append', $options)";
            }
            if ($suggestible) {
                push @rules,
                    #"marc_map('$marc_field','${name}__suggestion.input.\$append', '')"; #must not have nested data structures in .input
                    "marc_map('$marc_field','${name}__suggestion.input.\$append')";
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
            if ($self->sort_fields()->{$name}) {
                if ($sort || !defined $sort) {
                    push @rules, "marc_map('$marc_field','${name}__sort.\$append', $options)";
                }
            }
        }
    );

    push @rules, "move_field(_id,es_id)"; #Also you must set the Catmandu::Store::ElasticSearch->new(key_prefix: 'es_');
    return \@rules;
}

=head2 _foreach_mapping

    $self->_foreach_mapping(
        sub {
            my ( $name, $type, $facet, $suggestible, $sort, $marc_type,
                $marc_field )
              = @_;
            return unless $marc_type eq 'marc21';
            print "Data comes from: " . $marc_field . "\n";
        }
    );

This allows you to apply a function to each entry in the elasticsearch mappings
table, in order to build the mappings for whatever is needed.

In the provided function, the files are:

=over 4

=item C<$name>

The field name for elasticsearch (corresponds to the 'mapping' column in the
database.

=item C<$type>

The type for this value, e.g. 'string'.

=item C<$facet>

True if this value should be facetised. This only really makes sense if the
field is understood by the facet processing code anyway.

=item C<$sort>

True if this is a field that a) needs special sort handling, and b) if it
should be sorted on. False if a) but not b). Undef if not a). This allows,
for example, author to be sorted on but not everything marked with "author"
to be included in that sort.

=item C<$marc_type>

A string that indicates the MARC type that this mapping is for, e.g. 'marc21',
'unimarc', 'normarc'.

=item C<$marc_field>

A string that describes the MARC field that contains the data to extract.
These are of a form suited to Catmandu's MARC fixers.

=back

=cut

sub _foreach_mapping {
    my ( $self, $sub ) = @_;

    # TODO use a caching framework here
    my $search_fields = Koha::Database->schema->resultset('SearchField')->search(
        {
            'search_marc_map.index_name' => $self->index,
        },
        {   join => { search_marc_to_fields => 'search_marc_map' },
            '+select' => [
                'search_marc_to_fields.facet',
                'search_marc_to_fields.suggestible',
                'search_marc_to_fields.sort',
                'search_marc_map.marc_type',
                'search_marc_map.marc_field',
            ],
            '+as'     => [
                'facet',
                'suggestible',
                'sort',
                'marc_type',
                'marc_field',
            ],
        }
    );

    while ( my $search_field = $search_fields->next ) {
        $sub->(
            $search_field->name,
            $search_field->type,
            $search_field->get_column('facet'),
            $search_field->get_column('suggestible'),
            $search_field->get_column('sort'),
            $search_field->get_column('marc_type'),
            $search_field->get_column('marc_field'),
        );
    }
}

=head2 process_error

    die process_error($@);

This parses an Elasticsearch error message and produces a human-readable
result from it. This result is probably missing all the useful information
that you might want in diagnosing an issue, so the warning is also logged.

Note that currently the resulting message is not internationalised. This
will happen eventually by some method or other.

=cut

sub process_error {
    my ($self, $msg) = @_;

    warn $msg; # simple logging

    # This is super-primitive
    return "Unable to understand your search query, please rephrase and try again.\n" if $msg =~ /ParseException/;

    return "Unable to perform your search. Please try again.\n";
}

=head2 _read_configuration

    my $conf = _read_configuration();

Reads the I<configuration file> and returns a hash structure with the
configuration information. It raises an exception if mandatory entries
are missing.

The hashref structure has the following form:

    {
        'nodes' => ['127.0.0.1:9200', 'anotherserver:9200'],
        'index_name' => 'koha_instance',
    }

This is configured by the following in the C<config> block in koha-conf.xml:

    <elasticsearch>
        <server>127.0.0.1:9200</server>
        <server>anotherserver:9200</server>
        <index_name>koha_instance</index_name>
    </elasticsearch>

=cut

sub _read_configuration {

    my $configuration;

    my $conf = C4::Context->config('elasticsearch');
    Koha::Exceptions::Config::MissingEntry->throw(
        "Missing 'elasticsearch' block in config file")
      unless defined $conf;

    if ( $conf && $conf->{server} ) {
        my $nodes = $conf->{server};
        if ( ref($nodes) eq 'ARRAY' ) {
            $configuration->{nodes} = $nodes;
        }
        else {
            $configuration->{nodes} = [$nodes];
        }
    }
    else {
        Koha::Exceptions::Config::MissingEntry->throw(
            "Missing 'server' entry in config file for elasticsearch");
    }

    if ( defined $conf->{index_name} ) {
        $configuration->{index_name} = $conf->{index_name};
    }
    else {
        Koha::Exceptions::Config::MissingEntry->throw(
            "Missing 'index_name' entry in config file for elasticsearch");
    }

    return $configuration;
}

1;

__END__

=head1 AUTHOR

=over 4

=item Chris Cormack C<< <chrisc@catalyst.net.nz> >>

=item Robin Sheat C<< <robin@catalyst.net.nz> >>

=item Jonathan Druart C<< <jonathan.druart@bugs.koha-community.org> >>

=back

=cut
