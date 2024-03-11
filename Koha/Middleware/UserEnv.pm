package Koha::Middleware::UserEnv;
use Modern::Perl;

use parent qw(Plack::Middleware);

use C4::Context;

=head1 NAME

Koha::Middleware::UserEnv - Middleware to ensure fresh userenv in all requests

=head1 METHODS

=head2 call

This method is called for each request, and will unset the userenv to avoid contamination between requests.

=cut

sub call {
    my ( $self, $env ) = @_;

    my $req = Plack::Request->new($env);

    C4::Context->unset_userenv;

    return $self->app->($env);
}

1;
