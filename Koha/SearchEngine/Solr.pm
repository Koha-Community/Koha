package Koha::SearchEngine::Solr;

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

use Moose;
use Koha::SearchEngine::Config;

extends 'Koha::SearchEngine', 'Data::SearchEngine::Solr';

has '+url' => (
    is => 'ro',
    isa => 'Str',
#    default => sub {
#        C4::Context->preference('SolrAPI');
#    },
    lazy => 1,
    builder => '_build_url',
    required => 1
);

sub _build_url {
    my ( $self ) = @_;
    $self->config->SolrAPI;
}

has '+options' => (
    is => 'ro',
    isa => 'HashRef',
    default => sub {
      {
        wt => 'json',
        fl => '*,score',
        fq => 'recordtype:biblio',
        facets => 'true'
      }
    }

);

has indexes => (
    is => 'ro',
    lazy => 1,
    default => sub {
#        my $dbh => ...;
    },
);

1;
