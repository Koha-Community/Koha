package Koha::Middleware::UserEnv;
use Modern::Perl;

use parent qw(Plack::Middleware);

use C4::Context;

sub call {
    my ( $self, $env ) =@_;

    my $req = Plack::Request->new($env);

    C4::Context->_unset_userenv;

    return $self->app->($env);
}

1;
