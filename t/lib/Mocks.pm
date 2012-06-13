package t::lib::Mocks;

use Modern::Perl;
use Test::MockModule;
use t::lib::Mocks::Context;

our (@ISA,@EXPORT,@EXPORT_OK);
BEGIN {
    require Exporter;
    @ISA = qw(Exporter);
    push @EXPORT, qw(
        &set_solr
        &set_zebra
    );
}

my $context = new Test::MockModule('C4::Context');
sub set_solr {
    $context->mock('preference', sub { &t::lib::Mocks::Context::MockPreference( @_, "Solr", $context ) });
}
sub set_zebra {
    $context->mock('preference', sub { &t::lib::Mocks::Context::MockPreference( @_, "Zebra", $context ) });
}
