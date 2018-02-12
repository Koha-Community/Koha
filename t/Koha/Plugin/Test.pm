package Koha::Plugin::Test;

## It's good practice to use Modern::Perl
use Modern::Perl;

## Required for all plugins
use base qw(Koha::Plugins::Base);

our $VERSION = 1.01;
our $metadata = {
    name            => 'Test Plugin',
    author          => 'Kyle M Hall',
    description     => 'Test plugin',
    date_authored   => '2013-01-14',
    date_updated    => '2013-01-14',
    minimum_version => '3.11',
    maximum_version => undef,
    version         => $VERSION,
    my_example_tag  => 'find_me',
};

## This is the minimum code required for a plugin's 'new' method
## More can be added, but none should be removed
sub new {
    my ( $class, $args ) = @_;
    $args->{'metadata'} = $metadata;
    my $self = $class->SUPER::new($args);
    return $self;
}

sub report {
    my ( $self, $args ) = @_;
    return "Koha::Plugin::Test::report";
}

sub tool {
    my ( $self, $args ) = @_;
    return "Koha::Plugin::Test::tool";
}

sub to_marc {
    my ( $self, $args ) = @_;
    return "Koha::Plugin::Test::to_marc";
}

sub opac_online_payment {
    my ( $self, $args ) = @_;
    return "Koha::Plugin::Test::opac_online_payment";
}

sub opac_online_payment_begin {
    my ( $self, $args ) = @_;
    return "Koha::Plugin::Test::opac_online_payment_begin";
}

sub opac_online_payment_end {
    my ( $self, $args ) = @_;
    return "Koha::Plugin::Test::opac_online_payment_end";
}

sub opac_head {
    my ( $self, $args ) = @_;
    return "Koha::Plugin::Test::opac_head";
}

sub opac_js {
    my ( $self, $args ) = @_;
    return "Koha::Plugin::Test::opac_js";
}

sub configure {
    my ( $self, $args ) = @_;
    return "Koha::Plugin::Test::configure";;
}

sub install {
    my ( $self, $args ) = @_;
    return "Koha::Plugin::Test::install";
}

sub uninstall {
    my ( $self, $args ) = @_;
    return "Koha::Plugin::Test::uninstall";
}

sub test_output {
    my ( $self ) = @_;
    $self->output( '¡Hola output!', 'json' );
}

sub test_output_html {
    my ( $self ) = @_;
    $self->output_html( '¡Hola output_html!' );
}
