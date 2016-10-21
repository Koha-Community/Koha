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
use Koha::Account;
use Koha::AuthUtils qw(hash_password);
use Koha::Availability;
use C4::Auth qw( haspermission checkpw_internal );
use C4::Context;
use Koha::Exceptions;
use Koha::Exceptions::Password;
use Koha::Patrons;
use Koha::Patron::Categories;
use Koha::Patron::Modifications;
use Koha::Libraries;

use Scalar::Util qw(blessed looks_like_number);
use Try::Tiny;

use Try::Tiny;

sub list {
    my $c = shift->openapi->valid_input or return;

    my $params = $c->req->query_params->to_hash;
    my $patrons;
    if (keys %$params) {
        my @valid_params = Koha::Patrons->columns;
        foreach my $key (keys %$params) {
            delete $params->{$key} unless grep { $key eq $_ } @valid_params;
        }
        $patrons = Koha::Patrons->search($params);
    } else {
        $patrons = Koha::Patrons->search;
    }

    return $c->render(status => 200, openapi => $patrons);
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

        if ($body->{password}) { $body->{password} = hash_password($body->{password}) }; # bcrypt password if given

        my $patron = Koha::Patron->new($body)->validate->store;
        return $c->$cb($patron, 201);
    }
    catch {
        unless (blessed $_ && $_->can('rethrow')) {
            return $c->$cb({error => "Something went wrong, check Koha logs for details."}, 500);
        }
        if ($_->isa('Koha::Exceptions::Patron::DuplicateObject')) {
            return $c->$cb({ error => $_->error, conflict => $_->conflict }, 409);
        }
        elsif ($_->isa('Koha::Exceptions::Library::BranchcodeNotFound')) {
            return $c->$cb({ error => "Library with branchcode \"".$_->branchcode."\" does not exist" }, 400);
        }
        elsif ($_->isa('Koha::Exceptions::Category::CategorycodeNotFound')) {
            return $c->$cb({error => "Patron category \"".$_->categorycode."\" does not exist"}, 400);
        }
        else {
            return $c->$cb({error => "Something went wrong, check Koha logs for details."}, 500);
        }
    };
}

sub edit {
    my ($c, $args, $cb) = @_;

    my $patron;
    return try {
        $patron = Koha::Patrons->find($args->{borrowernumber});
        my $body = $c->req->json;
        $body->{borrowernumber} = $args->{borrowernumber};

        if ($c->stash('is_owner_access') || $c->stash('is_guarantor_access')){
            if (C4::Context->preference('OPACPatronDetails')) {
                die unless $patron->set($body)->validate;
                my $m = Koha::Patron::Modification->new->validate_changes($body, "edit")->store();
                return $c->$cb({}, 202);
            } else {
                return $c->$cb({ error => "You need a permission to change Your personal details"}, 403);
            }
        }
        else {
            if ($body->{password}) { $body->{password} = hash_password($body->{password}) }; # bcrypt password if given
            delete $body->{borrowernumber};
            die unless $patron->set($body)->validate;
            return $c->$cb({}, 204) unless $patron->is_changed; # No Content = No changes made
            $patron->store;
            return $c->$cb($patron, 200);
        }
    }
    catch {
        unless ($patron) {
            return $c->$cb({error => "Patron not found"}, 404);
        }
        unless (blessed $_ && $_->can('rethrow')) {
            return $c->$cb({error => "Something went wrong, check Koha logs for details."}, 500);
        }
        if ($_->isa('Koha::Exceptions::Patron::DuplicateObject')) {
            return $c->$cb({ error => $_->error, conflict => $_->conflict }, 409);
        }
        elsif ($_->isa('Koha::Exceptions::Library::BranchcodeNotFound')) {
            return $c->$cb({ error => "Library with branchcode \"".$_->branchcode."\" does not exist" }, 400);
        }
        elsif ($_->isa('Koha::Exceptions::Category::CategorycodeNotFound')) {
            return $c->$cb({error => "Patron category \"".$_->categorycode."\" does not exist"}, 400);
        }
        elsif ($_->isa('Koha::Exceptions::MissingParameter')) {
            return $c->$cb({error => "Missing mandatory parameter(s)", parameters => $_->parameter }, 400);
        }
        elsif ($_->isa('Koha::Exceptions::BadParameter')) {
            return $c->$cb({error => "Invalid parameter(s)", parameters => $_->parameter }, 400);
        }
        elsif ($_->isa('Koha::Exceptions::NoChanges')) {
            return $c->$cb({error => "No changes have been made"}, 204);
        }
        else {
            return $c->$cb({error => "Something went wrong, check Koha logs for details."}, 500);
        }
    };
}

sub delete {
    my ($c, $args, $cb) = @_;

    my $patron = Koha::Patrons->find($args->{borrowernumber});
    unless ($patron) {
        return $c->$cb({error => "Patron not found"}, 404);
    }

    # check if loans, reservations, debarrment, etc. before deletion!
    my $res = $patron->delete;

    if ($res eq '1') {
        return $c->$cb({}, 200);
    } elsif ($res eq '-1') {
        return $c->$cb({}, 404);
    } else {
        return $c->$cb({}, 400);
    }
}

sub pay {
    my ($c, $args, $cb) = @_;

    return try {
        my $patron = Koha::Patrons->find($args->{borrowernumber});
        unless ($patron) {
            return $c->$cb({error => "Patron not found"}, 404);
        }

        my $body = $c->req->json;
        my $amount = $body->{amount};
        my $note = $body->{note} || '';

        Koha::Account->new(
            {
                patron_id => $args->{borrowernumber},
            }
          )->pay(
            {
                amount => $amount,
                note => $note,
            }
          );

        return $c->$cb('', 204);
    } catch {
        if ($_->isa('DBIx::Class::Exception')) {
            return $c->$cb({ error => $_->msg }, 500);
        }
        else {
            return $c->$cb({
                error => 'Something went wrong, check the logs.'
            }, 500);
        }
    };
}

sub changepassword {
    my ($c, $args, $cb) = @_;

    my $patron;
    my $user;
    try {
        $patron = Koha::Patrons->find($args->{borrowernumber});
        $user = $c->stash('koha.user');

        my $OpacPasswordChange = C4::Context->preference("OpacPasswordChange");
        my $haspermission = haspermission($user->userid, {borrowers => 1});
        unless ($OpacPasswordChange && $user->borrowernumber == $args->{borrowernumber}) {
            Koha::Exceptions::BadSystemPreference->throw(
                preference => 'OpacPasswordChange'
            ) unless $haspermission;
        }

        my $pw = $args->{'body'};
        my $dbh = C4::Context->dbh;
        unless ($haspermission || checkpw_internal($dbh, $patron->userid, $pw->{'current_password'})) {
            Koha::Exceptions::Password::Invalid->throw;
        }
        $patron->change_password_to($pw->{'new_password'});
        return $c->$cb({}, 200);
    }
    catch {
        if (not defined $patron) {
            return $c->$cb({ error => "Patron not found." }, 404);
        }
        elsif (not defined $user) {
            return $c->$cb({ error => "User must be defined." }, 500);
        }

        die $_ unless blessed $_ && $_->can('rethrow');
        if ($_->isa('Koha::Exceptions::Password::Invalid')) {
            return $c->$cb({ error => "Wrong current password." }, 400);
        }
        elsif ($_->isa('Koha::Exceptions::Password::TooShort')) {
            return $c->$cb({ error => $_->error }, 400);
        }
        elsif ($_->isa('Koha::Exceptions::Password::TrailingWhitespaces')) {
            return $c->$cb({ error => $_->error }, 400);
        }
        elsif ($_->isa('Koha::Exceptions::BadSystemPreference')
               && $_->preference eq 'OpacPasswordChange') {
            return $c->$cb({ error => "OPAC password change is disabled" }, 403);
        }
        else {
            return $c->$cb({ error => "Something went wrong. $_" }, 500);
        }
    }
}

sub getstatus {
    my ($c, $args, $cb) = @_;

    return try {
        my $user = $c->stash('koha.user');

        my $patron = Koha::Patrons->find($args->{borrowernumber});
        unless ($patron) {
            return $c->$cb({error => "Patron not found"}, 404);
        }

        my $ret = $patron->TO_JSON;
        my %problems = map { ref($_) => $_ } $patron->status_not_ok;
        $ret->{blocks} = Koha::Availability->_swaggerize_exception(\%problems);

        return $c->$cb($ret, 200);
    } catch {
        if ( $_->isa('DBIx::Class::Exception') ) {
            return $c->$cb( { error => $_->msg }, 500 );
        }
        else {
            return $c->$cb(
                { error => "Something went wrong, check the logs." }, 500 );
        }
    };
}

1;
