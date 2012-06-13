package Koha::SearchEngine::Solr;
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
