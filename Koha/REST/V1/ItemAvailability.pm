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
    my $c = shift->openapi->valid_input or return;

    my @availabilities;
    my $user = $c->stash('koha.user');
    my $borrowernumber = $c->validation->param('borrowernumber');
    my $patron;
    my $librarian;

    return try {
        ($patron, $librarian) = _get_patron($c, $user, $borrowernumber);

        my $items = $c->validation->output->{'itemnumber'};
        foreach my $itemnumber (@$items) {
            if (my $item = Koha::Items->find($itemnumber)) {
                push @availabilities, Koha::Availability::Checkout->item({
                    patron => $patron,
                    item => $item
                })->in_intranet->swaggerize;
            }
        }
        $c->app->log->trace(Data::Dumper::Dumper(\@availabilities));
        return $c->render(status => 200, openapi => \@availabilities);
    }
    catch {
        if ($_->isa('Koha::Exceptions::AuthenticationRequired')) {
            return $c->render(status => 401, openapi => { error => "Authentication required." });
        }
        elsif ($_->isa('Koha::Exceptions::NoPermission')) {
            return $c->render( status => 403, openapi => {
                error => "Authorization failure. Missing required permission(s).",
                required_permissions => $_->required_permissions} );
        }
        Koha::Exceptions::rethrow_exception($_);
    };
}

sub hold {
    my $c = shift->openapi->valid_input or return;

    my @availabilities;
    my $user = $c->stash('koha.user');
    my $borrowernumber = $c->validation->param('borrowernumber');
    my $to_branch = $c->validation->param('branchcode');
    my $patron;
    my $librarian;

    return try {
        ($patron, $librarian) = _get_patron($c, $user, $borrowernumber);

        my $items = $c->validation->output->{'itemnumber'};
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

        $c->app->log->trace(Data::Dumper::Dumper(\@availabilities));
        return $c->render(status => 200, openapi => \@availabilities);
    }
    catch {
        if ($_->isa('Koha::Exceptions::AuthenticationRequired')) {
            return $c->render(status => 401, openapi => { error => "Authentication required." });
        }
        elsif ($_->isa('Koha::Exceptions::NoPermission')) {
            return $c->render(status => 403, openapi => {
                error => "Authorization failure. Missing required permission(s).",
                required_permissions => $_->required_permissions} );
        }
        Koha::Exceptions::rethrow_exception($_);
    };
}

sub search {
    my $c = shift->openapi->valid_input or return;

    my @availabilities;

    return try {
        my $items = $c->validation->output->{'itemnumber'};
        foreach my $itemnumber (@$items) {
            if (my $item = Koha::Items->find($itemnumber)) {
                push @availabilities, Koha::Availability::Search->item({
                    item => $item
                })->in_opac->swaggerize;
            }
        }
        $c->app->log->trace(Data::Dumper::Dumper(\@availabilities));
        return $c->render(status => 200, openapi => \@availabilities);
    }
    catch {
        Koha::Exceptions::rethrow_exception($_);
    };
}

sub _get_patron {
    my ($c, $user, $borrowernumber) = @_;

    my $patron;
    my $librarian = 0;

    unless ($user) {
        Koha::Exceptions::AuthenticationRequired->throw if $borrowernumber;
    }
    if ($user && haspermission($user->userid, { borrowers => 1 })) {
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
