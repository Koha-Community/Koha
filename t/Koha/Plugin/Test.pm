package Koha::Plugin::Test;

## It's good practive to use Modern::Perl
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
