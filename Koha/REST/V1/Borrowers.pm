package Koha::REST::V1::Borrowers;

use Modern::Perl;

use Mojo::Base 'Mojolicious::Controller';

use C4::Auth qw( haspermission );
use Koha::Borrowers;

sub list_borrowers {
    my ($c, $args, $cb) = @_;

    my $user = $c->stash('koha.user');
    unless ($user && haspermission($user->userid, {borrowers => 1})) {
        return $c->$cb({error => "You don't have the required permission"}, 403);
    }

    my $borrowers = Koha::Borrowers->search;

    $c->$cb($borrowers->unblessed, 200);
}

sub get_borrower {
    my ($c, $args, $cb) = @_;

    my $user = $c->stash('koha.user');

    unless ( $user
        && ( $user->borrowernumber == $args->{borrowernumber}
            || haspermission($user->userid, {borrowers => 1}) ) )
    {
        return $c->$cb({error => "You don't have the required permission"}, 403);
    }

    my $borrower = Koha::Borrowers->find($args->{borrowernumber});
    unless ($borrower) {
        return $c->$cb({error => "Borrower not found"}, 404);
    }

    return $c->$cb($borrower->unblessed, 200);
}

1;
