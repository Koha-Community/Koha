package Koha::Plugin::TestItemBarcodeTransform;

## It's good practice to use Modern::Perl
use Modern::Perl;

use Koha::Exception;
use Koha::Plugins::Tab;

use Mojo::JSON qw( decode_json );

## Required for all plugins
use base qw(Koha::Plugins::Base);

our $VERSION  = 1.01;
our $metadata = {
    name            => 'Test Plugin for item_barcode_transform',
    author          => 'Kyle M Hall',
    description     => 'Test plugin for item_barcode_transform',
    date_authored   => '2021-10-14',
    date_updated    => '2021-10-14',
    minimum_version => '21.11',
    maximum_version => undef,
    version         => $VERSION,
};

## This is the minimum code required for a plugin's 'new' method
## More can be added, but none should be removed
sub new {
    my ( $class, $args ) = @_;
    $args->{'metadata'} = $metadata;
    my $self = $class->SUPER::new($args);
    return $self;
}

sub item_barcode_transform {
    my ( $self, $barcode ) = @_;
    my $param = $$barcode;
    if ( Scalar::Util::looks_like_number($$barcode) ) {
        $$barcode = $$barcode * 4;
    }
    Koha::Exception->throw("item_barcode_transform called with parameter: $param");
}

1;
