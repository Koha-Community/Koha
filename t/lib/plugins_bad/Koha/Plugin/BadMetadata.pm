package Koha::Plugin::BadMetadata;

use Modern::Perl;

use base qw(Koha::Plugins::Base);

our $VERSION  = "0.0.1";
our $metadata = {
    name            => 'Bad Metadata',
    author          => 'Jane Doe',
    description     => 'For testing plugin metadata validation',
    date_authored   => '2001/01/01',
    date_updated    => '2015',
    minimum_version => '3.11',
    maximum_version => undef,
    version         => $VERSION,
};

=head1 Methods

=head2 new

=cut

sub new {
    my ( $class, $args ) = @_;
    $args->{'metadata'} = $metadata;
    my $self = $class->SUPER::new($args);
    return $self;
}

1;
