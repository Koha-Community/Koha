package Koha::SearchEngine::Zebra;
use Moose;

extends 'Data::SearchEngine::Zebra';

# the configuration file is retrieved from KOHA_CONF by default, provide it from there²
has '+conf_file' => (
    is => 'ro',
    isa => 'Str',
    default =>  $ENV{KOHA_CONF},
    required => 1
);

1;
