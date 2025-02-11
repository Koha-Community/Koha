package Koha::Plugin::BackendClass;

use Modern::Perl;

use base qw(Koha::Plugins::Base);

our $VERSION  = "v1.01";
our $metadata = {
    name            => 'BackendClass',
    author          => 'Koha Community',
    description     => 'Plugin testing backends as their own class',
    date_authored   => '2013-01-14',
    date_updated    => '2013-01-14',
    minimum_version => '3.11',
    maximum_version => undef,
    version         => $VERSION,
    namespace       => 'backend_class',
};

sub new {
    my ( $class, $args ) = @_;
    $args->{'metadata'} = $metadata;
    my $self = $class->SUPER::new($args);
    return $self;
}

sub ill_backend {
    my ($self) = @_;
    return 'BackendClass';
}

sub new_ill_backend {
    my ( $self, $args ) = @_;
    require Koha::Plugin::ILL::TestClass;
    return Koha::Plugin::ILL::TestClass->new($args);
}

1;
