package Koha::Plugin::BrokenInstall;

use Modern::Perl;

use base qw(Koha::Plugins::Base);

our $VERSION  = 1.01;
our $metadata = {
    name            => 'Broken install plugin',
    author          => 'Kyle M Hall',
    description     => 'Broken install plugin',
    date_authored   => '2013-01-14',
    date_updated    => '2013-01-14',
    minimum_version => '3.11',
    maximum_version => undef,
    version         => $VERSION,
};

=head1 METHODS

=head2 new

instantiate the plugin

=cut

sub new {
    my ( $class, $args ) = @_;
    $args->{'metadata'} = $metadata;
    my $self = $class->SUPER::new($args);
    return $self;
}

=head2 install

install method that dies

=cut

sub install {
    die "Why Liz? WHY?";
}

1;
