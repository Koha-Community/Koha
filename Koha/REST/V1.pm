package Koha::REST::V1;

use Modern::Perl;
use Mojo::Base 'Mojolicious';

use C4::Auth qw( check_cookie_auth get_session );
use Koha::Borrowers;

sub startup {
    my $self = shift;

    my $route = $self->routes->under->to(
        cb => sub {
            my $c = shift;

            my ($status, $sessionID) = check_cookie_auth($c->cookie('CGISESSID'));
            if ($status eq "ok") {
                my $session = get_session($sessionID);
                my $user = Koha::Borrowers->find($session->param('number'));
                $c->stash('koha.user' => $user);
            }

            return 1;
        }
    );

    # Force charset=utf8 in Content-Type header for JSON responses
    $self->types->type(json => 'application/json; charset=utf8');

    $self->plugin(Swagger2 => {
        route => $route,
        url => $self->home->rel_file("api/v1/swagger.json"),
    });
}

1;
