package Koha::REST::V1::Patron;

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Mojo::Base 'Mojolicious::Controller';

use C4::Auth qw( haspermission );
use Koha::Patrons;

sub list {
    my ($c, $args, $cb) = @_;

    my $user = $c->stash('koha.user');
    unless ($user && haspermission($user->userid, {borrowers => 1})) {
        return $c->$cb({error => "You don't have the required permission"}, 403);
    }

    my $patrons = Koha::Patrons->search;

    $c->$cb($patrons->unblessed, 200);
}

sub get {
    my ($c, $args, $cb) = @_;

    my $user = $c->stash('koha.user');

    unless ( $user
        && ( $user->borrowernumber == $args->{borrowernumber}
            || haspermission($user->userid, {borrowers => 1}) ) )
    {
        return $c->$cb({error => "You don't have the required permission"}, 403);
    }

    my $patron = Koha::Patrons->find($args->{borrowernumber});
    unless ($patron) {
        return $c->$cb({error => "Patron not found"}, 404);
    }

    return $c->$cb($patron->unblessed, 200);
}

1;
