package Koha::SearchEngine;

use Moose;
use C4::Context;
use Koha::SearchEngine::Config;

has 'name' => (
    is => 'ro',
    default => sub {
        C4::Context->preference('SearchEngine');
    }
);

has config => (
    is => 'rw',
    lazy => 1,
    default => sub {
        Koha::SearchEngine::Config->new;
    }
#    lazy => 1,
#    builder => '_build_config',
);

#sub _build_config {
#    my ( $self ) = @_;
#    Koha::SearchEngine::Config->new( $self->name );
#);

1;
