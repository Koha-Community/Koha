package Koha::SearchEngine::Solr::Config;

# This file is part of Koha.
#
# Copyright 2012 BibLibre
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
use Moose::Role;
use YAML;

with 'Koha::SearchEngine::ConfigRole';

has index_config => (
    is => 'rw',
    lazy => 1,
    builder => '_load_index_config_file',
);

has solr_config => (
    is => 'rw',
    lazy => 1,
    builder => '_load_solr_config_file',
);

has index_filename => (
    is => 'rw',
    lazy => 1,
    default => C4::Context->config("installdir") . qq{/etc/searchengine/solr/indexes.yaml},
);
has solr_filename => (
    is => 'rw',
    lazy => 1,
    default => C4::Context->config("installdir") . qq{/etc/searchengine/solr/config.yaml},
);

sub _load_index_config_file {
    my ( $self, $filename ) = @_;
    $self->index_filename( $filename ) if defined $filename;
    die "The config index file (" . $self->index_filename . ") for Solr is not exist" if not -e $self->index_filename;

    return YAML::LoadFile($self->index_filename);
}

sub _load_solr_config_file {
    my ( $self ) = @_;
    die "The solr config index file (" . $self->solr_filename . ") for Solr is not exist" if not -e $self->solr_filename;

    return YAML::LoadFile($self->solr_filename);
}

sub set_config_filename {
    my ( $self, $filename ) = @_;
    $self->index_config( $self->_load_index_config_file( $filename ) );
}

sub SolrAPI {
    my ( $self ) = @_;
    return $self->solr_config->{SolrAPI};
}
sub indexes { # FIXME Return index list if param not an hashref (string ressource_type)
    my ( $self, $indexes ) = @_;
    return $self->write( { indexes => $indexes } ) if defined $indexes;
    return $self->index_config->{indexes};
}

sub index {
    my ( $self, $code ) = @_;
    my @index = map { ( $_->{code} eq $code ) ? $_ : () } @{$self->index_config->{indexes}};
    return $index[0];
}

sub ressource_types {
    my ( $self  ) = @_;
    my $config = $self->index_config;
    return $config->{ressource_types};
}

sub sortable_indexes {
    my ( $self ) = @_;
    my @sortable_indexes = map { $_->{sortable} ? $_ : () } @{ $self->index_config->{indexes} };
    return \@sortable_indexes;
}

sub facetable_indexes {
    my ( $self ) = @_;
    my @facetable_indexes = map { $_->{facetable} ? $_ : () } @{ $self->index_config->{indexes} };
    return \@facetable_indexes;
}

sub reload {
    my ( $self ) = @_;
    $self->index_config( $self->_load_index_config_file );
}
sub write {
    my ( $self, $values ) = @_;
    my $r;
    while ( my ( $k, $v ) = each %$values ) {
        $r->{$k} = $v;
    }

    if ( not grep /^ressource_type$/, keys %$values ) {
        $r->{ressource_types} = $self->ressource_types;
    }

    if ( not grep /^indexes$/, keys %$values ) {
        $r->{indexes} = $self->indexes;
    }

    eval {
        YAML::DumpFile( $self->index_filename, $r );
    };
    if ( $@ ) {
        die "Failed to dump the index config into the specified file ($@)";
    }

    $self->reload;
}

1;
