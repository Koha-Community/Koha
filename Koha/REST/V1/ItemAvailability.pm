package Koha::REST::V1::ItemAvailability;

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

use Koha::Exceptions;

use Koha::Availability::Checkout;
use Koha::Availability::Hold;
use Koha::Availability::Search;

use Try::Tiny;

sub checkout {
    my ($c, $args, $cb) = @_;

    my @availabilities;
    my $user = $c->stash('koha.user');
    my $borrowernumber = $args->{'borrowernumber'};
    my $patron;
    my $librarian;

    return try {
        ($patron, $librarian) = _get_patron($c, $user, $borrowernumber);

        my $items = $args->{'itemnumber'};
        foreach my $itemnumber (@$items) {
            if (my $item = Koha::Items->find($itemnumber)) {
                push @availabilities, Koha::Availability::Checkout->item({
                    patron => $patron,
                    item => $item
                })->in_intranet->swaggerize;
            }
        }
        return $c->$cb(\@availabilities, 200);
    }
    catch {
        if ( $_->isa('DBIx::Class::Exception') ) {
            return $c->$cb( { error => $_->{msg} }, 500 );
        }
        elsif ($_->isa('Koha::Exceptions::AuthenticationRequired')) {
            return $c->$cb(
                { error => "Authentication required." }, 401 );
        }
        elsif ($_->isa('Koha::Exceptions::NoPermission')) {
            return $c->$cb({
                error => "Authorization failure. Missing required permission(s).",
                required_permissions => $_->required_permissions}, 403 );
        }
        else {
            return $c->$cb(
                { error => "Something went wrong, check the logs. $_" }, 500 );
        }
    };
}

sub hold {
    my ($c, $args, $cb) = @_;

    my @availabilities;
    my $user = $c->stash('koha.user');
    my $borrowernumber = $args->{'borrowernumber'};
    my $to_branch = $args->{'branchcode'};
    my $patron;
    my $librarian;

    return try {
        ($patron, $librarian) = _get_patron($c, $user, $borrowernumber);

        my $items = $args->{'itemnumber'};
        my $params = {
            patron => $patron,
        };
        if ($to_branch) {
            $params->{'to_branch'} = $to_branch;
        }
        foreach my $itemnumber (@$items) {
            if (my $item = Koha::Items->find($itemnumber)) {
                $params->{'item'} = $item;
                my $availability = Koha::Availability::Hold->item($params);
                unless ($librarian) {
                    push @availabilities, $availability->in_opac->swaggerize;
                } else {
                    push @availabilities, $availability->in_intranet->swaggerize;
                }
            }
        }

        return $c->$cb(\@availabilities, 200);
    }
    catch {
        if ( $_->isa('DBIx::Class::Exception') ) {
            return $c->$cb( { error => $_->{msg} }, 500 );
        }
        elsif ($_->isa('Koha::Exceptions::AuthenticationRequired')) {
            return $c->$cb(
                { error => "Authentication required." }, 401 );
        }
        elsif ($_->isa('Koha::Exceptions::NoPermission')) {
            return $c->$cb({
                error => "Authorization failure. Missing required permission(s).",
                required_permissions => $_->required_permissions}, 403 );
        }
        else {
            return $c->$cb(
                { error => "Something went wrong, check the logs. $_" }, 500 );
        }
    };
}

sub search {
    my ($c, $args, $cb) = @_;

    my @availabilities;

    return try {
        my $items = $args->{'itemnumber'};
        foreach my $itemnumber (@$items) {
            if (my $item = Koha::Items->find($itemnumber)) {
                push @availabilities, Koha::Availability::Search->item({
                    item => $item
                })->in_opac->swaggerize;
            }
        }
        return $c->$cb(\@availabilities, 200);
    }
    catch {
        if ( $_->isa('DBIx::Class::Exception') ) {
            return $c->$cb( { error => $_->{msg} }, 500 );
        }
        else {
            return $c->$cb(
                { error => "Something went wrong, check the logs. $_" }, 500 );
        }
    };
}

sub _get_patron {
    my ($c, $user, $borrowernumber) = @_;

    my $patron;
    my $librarian = 0;

    unless ($user) {
        Koha::Exceptions::AuthenticationRequired->throw;
    }
    if (haspermission($user->userid, { borrowers => 1 })) {
        $librarian = 1;
    }
    if ($borrowernumber) {
        if ($borrowernumber == $user->borrowernumber) {
            $patron = $user;
        } else {
            if ($librarian) {
                $patron = Koha::Patrons->find($borrowernumber);
            } else {
                Koha::Exceptions::NoPermission->throw(
                    required_permissions => "borrowers"
                );
            }
        }
    } else {
        $patron = $user;
    }

    return ($patron, $librarian);
}

1;
