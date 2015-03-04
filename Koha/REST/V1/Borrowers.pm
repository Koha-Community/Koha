package Koha::REST::V1::Borrowers;

use Modern::Perl;

use Mojo::Base 'Mojolicious::Controller';

use Koha::Borrowers;

sub list_borrowers {
    my ($c, $args, $cb) = @_;

    my $borrowers = Koha::Borrowers->search;

    $c->$cb($borrowers->unblessed, 200);
}

sub get_borrower {
    my ($c, $args, $cb) = @_;

    my $borrower = Koha::Borrowers->find($args->{borrowernumber});

    if ($borrower) {
        return $c->$cb($borrower->unblessed, 200);
    }

    $c->$cb({error => "Borrower not found"}, 404);
}

1;
