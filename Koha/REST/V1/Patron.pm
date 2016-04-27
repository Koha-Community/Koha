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

use C4::Members qw( AddMember ModMember );
use Koha::AuthUtils qw(hash_password);
use Koha::Patrons;
use Koha::Patron::Categories;
use Koha::Patron::Modifications;
use Koha::Libraries;

use Scalar::Util qw(blessed);
use Try::Tiny;

sub list {
    my $c = shift->openapi->valid_input or return;


    my $args   = $c->req->params->to_hash;
    my $filter = {};
    for my $filter_param ( keys %$args ) {
        $filter->{$filter_param} = { LIKE => $args->{$filter_param} . "%" };
    }

    return try {
        my $patrons = Koha::Patrons->search_limited($filter);
        return $c->render(status => 200, openapi => $patrons);
    }
    catch {
        if ( $_->isa('DBIx::Class::Exception') ) {
            return $c->render( status => 500, openapi => { error => $_->{msg} } );
        }
        else {
            return $c->render( status => 500, openapi => { error => "Something went wrong, check the logs." } );
        }
    };
}

sub get {
    my $c = shift->openapi->valid_input or return;

    my $borrowernumber = $c->validation->param('borrowernumber');
    my $patron = Koha::Patrons->find($borrowernumber);

    unless ($patron) {
        return $c->render(status => 404, openapi => { error => "Patron not found." });
    }

    return $c->render(status => 200, openapi => $patron);
}

sub add {
    my ($c, $args, $cb) = @_;

    return try {
        my $body = $c->req->json;

        Koha::Patron->new($body)->_validate;
        # TODO: Use AddMember until it has been moved to Koha-namespace
        my $borrowernumber = AddMember(%$body);
        my $patron = Koha::Patrons->find($borrowernumber);

        return $c->$cb($patron, 201);
    }
    catch {
        unless (blessed $_ && $_->can('rethrow')) {
            return $c->$cb({ error =>
                "Something went wrong, check Koha logs for details."}, 500);
        }
        if ($_->isa('Koha::Exceptions::Patron::DuplicateObject')) {
            return $c->$cb({ error => $_->error, conflict => $_->conflict }, 409);
        }
        elsif ($_->isa('Koha::Exceptions::Library::BranchcodeNotFound')) {
            return $c->$cb({ error => "Given branchcode does not exist" }, 400);
        }
        elsif ($_->isa('Koha::Exceptions::Category::CategorycodeNotFound')) {
            return $c->$cb({ error => "Given categorycode does not exist"}, 400);
        }
        else {
            return $c->$cb({ error =>
                "Something went wrong, check Koha logs for details."}, 500);
        }
    };
}

sub edit {
    my ($c, $args, $cb) = @_;

    my $patron;
    return try {
        my $user = $c->stash('koha.user');
        $patron = Koha::Patrons->find($args->{borrowernumber});
        my $body = $c->req->json;

        $body->{borrowernumber} = $args->{borrowernumber};

        if (!C4::Auth::haspermission($user->userid, { borrowers => 1 }) &&
            $user->borrowernumber == $patron->borrowernumber){
            if (C4::Context->preference('OPACPatronDetails')) {
                $body = _delete_unmodifiable_parameters($body);
                die unless $patron->set($body)->_validate;
                my $m = Koha::Patron::Modification->new($body)->store();
                return $c->$cb({}, 202);
            } else {
                return $c->$cb({ error => "You need a permission to change"
                                ." Your personal details"}, 403);
            }
        }
        else {
            delete $body->{borrowernumber};
            die unless $patron->set($body)->_validate;
            # TODO: Use ModMember until it has been moved to Koha-namespace
            $body->{borrowernumber} = $args->{borrowernumber};
            die unless ModMember(%$body);
            return $c->$cb($patron, 200);
        }
    }
    catch {
        unless ($patron) {
            return $c->$cb({error => "Patron not found"}, 404);
        }
        unless (blessed $_ && $_->can('rethrow')) {
            return $c->$cb({ error =>
                "Something went wrong, check Koha logs for details."}, 500);
        }
        if ($_->isa('Koha::Exceptions::Patron::DuplicateObject')) {
            return $c->$cb({ error => $_->error, conflict => $_->conflict }, 409);
        }
        elsif ($_->isa('Koha::Exceptions::Library::BranchcodeNotFound')) {
            return $c->$cb({ error => "Given branchcode does not exist" }, 400);
        }
        elsif ($_->isa('Koha::Exceptions::Category::CategorycodeNotFound')) {
            return $c->$cb({ error => "Given categorycode does not exist"}, 400);
        }
        elsif ($_->isa('Koha::Exceptions::MissingParameter')) {
            return $c->$cb({error => "Missing mandatory parameter(s)",
                            parameters => $_->parameter }, 400);
        }
        elsif ($_->isa('Koha::Exceptions::BadParameter')) {
            return $c->$cb({error => "Invalid parameter(s)",
                            parameters => $_->parameter }, 400);
        }
        elsif ($_->isa('Koha::Exceptions::NoChanges')) {
            return $c->$cb({error => "No changes have been made"}, 204);
        }
        else {
            return $c->$cb({ error =>
                "Something went wrong, check Koha logs for details."}, 500);
        }
    };
}

sub delete {
    my ($c, $args, $cb) = @_;

    my $patron;

    return try {
        $patron = Koha::Patrons->find($args->{borrowernumber});
        # check if loans, reservations, debarrment, etc. before deletion!
        my $res = $patron->delete;

        return $c->$cb({}, 200);
    }
    catch {
        unless ($patron) {
            return $c->$cb({error => "Patron not found"}, 404);
        }
        else {
            return $c->$cb({ error =>
                "Something went wrong, check Koha logs for details."}, 500);
        }
    };
}

sub _delete_unmodifiable_parameters {
    my ($body) = @_;

    my %columns = map { $_ => 1 } Koha::Patron::Modifications->columns;
    foreach my $param (keys %$body) {
        unless (exists $columns{$param}) {
            delete $body->{$param};
        }
    }
    return $body;
}

1;
