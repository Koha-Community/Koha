package Koha::REST::V1::Lists::Contents;

use Modern::Perl;
use Try::Tiny;
use Scalar::Util qw(blessed);

use Mojo::Base 'Mojolicious::Controller';

use Koha::Virtualshelves;

sub add {
    my $c = shift->openapi->valid_input or return;

    try {
        my $body = $c->req->json;
        if ($body->{listname} eq 'labels printing') {
            my $content = Koha::Virtualshelfcontent->new(
                {
                    listname => $body->{listname},
                    biblionumber => $body->{biblionumber},
                    borrowernumber => $body->{borrowernumber},
                    flags => $body->{itemnumber},
                }
            )->store;
            return $c->render(status => 200, openapi => $content);
        } else {
            return $c->render( status => 400, openapi => {});
        }
    } catch {
        Koha::Exceptions::rethrow_exception($_);
    };
}
sub delete {
    my $c = shift->openapi->valid_input or return;

    my $body = $c->req->json;
    my $shelf = Koha::Virtualshelves->find({owner => $body->{borrowernumber}, shelfname => $body->{listname}});
    my $content = $shelf->get_contents;
    unless ($content) {
        return $c->render( status  => 404,
                           openapi => { error => "Notice not found" } );
    }

    my $res = $content->delete;

    if ($res eq '1') {
        return $c->render( status => 200, openapi => {});
    } elsif ($res eq '-1') {
        return $c->render( status => 404, openapi => {});
    } else {
        return $c->render( status => 400, openapi => {});
    }
}

1;