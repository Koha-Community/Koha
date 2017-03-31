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
    my $c = shift->openapi->valid_input or return;

    return try {
        my $body = $c->req->json;

        if ($body->{password}) { $body->{password} = hash_password($body->{password}) }; # bcrypt password if given

        my $patron = Koha::Patron->new($body)->validate->store;
        return $c->render(status => 201, openapi => $patron);
    }
    catch {
        unless (blessed $_ && $_->can('rethrow')) {
            return $c->render(status  => 500,
                              openapi => {error => "Something went wrong, check Koha logs for details."});
        }
        if ($_->isa('Koha::Exceptions::Patron::DuplicateObject')) {
            return $c->render(status  => 409,
                              openapi => { error => $_->error, conflict => $_->conflict });
        }
        elsif ($_->isa('Koha::Exceptions::Library::BranchcodeNotFound')) {
            return $c->render(status  => 400,
                              openapi => { error => "Library with branchcode \"".$_->branchcode."\" does not exist" });
        }
        elsif ($_->isa('Koha::Exceptions::Category::CategorycodeNotFound')) {
            return $c->render(status  => 400,
                              openapi => {error => "Patron category \"".$_->categorycode."\" does not exist"});
        }
        else {
            return $c->render(status  => 500,
                              openapi => {error => "Something went wrong, check Koha logs for details."});
        }
    };
}

sub edit {
    my $c = shift->openapi->valid_input or return;

    my $patron;
    return try {
        my $borrowernumber = $c->validation->param('borrowernumber');
        $patron = Koha::Patrons->find($borrowernumber);
        my $body = $c->req->json;
        $body->{borrowernumber} = $c->validation->param('borrowernumber');

        if ($c->stash('is_owner_access') || $c->stash('is_guarantor_access')){
            if (C4::Context->preference('OPACPatronDetails')) {
                die unless $patron->set($body)->validate;
                my $m = Koha::Patron::Modification->new->validate_changes($body, "edit")->store();
                return $c->render( status => 202, openapi => {});
            } else {
                return $c->render( status => 403,
                                   openapi => { error => "You need a permission to change Your personal details"});
            }
        }
        else {
            if ($body->{password}) { $body->{password} = hash_password($body->{password}) }; # bcrypt password if given
            delete $body->{borrowernumber};
            die unless $patron->set($body)->validate;
            return $c->render( status => 204, openapi => {}) unless $patron->is_changed; # No Content = No changes made
            $patron->store;
            return $c->render( status => 200, openapi => $patron);
        }
    }
    catch {
        unless ($patron) {
            return $c->render( status => 404, openapi => {error => "Patron not found"});
        }
        unless (blessed $_ && $_->can('rethrow')) {
            return $c->render( status => 500, openapi => {error => "Something went wrong, check Koha logs for details."});
        }
        if ($_->isa('Koha::Exceptions::Patron::DuplicateObject')) {
            return $c->render( status => 409, openapi => { error => $_->error, conflict => $_->conflict });
        }
        elsif ($_->isa('Koha::Exceptions::Library::BranchcodeNotFound')) {
            return $c->render( status => 400, openapi => { error => "Library with branchcode \"".$_->branchcode."\" does not exist" });
        }
        elsif ($_->isa('Koha::Exceptions::Category::CategorycodeNotFound')) {
            return $c->render( status => 400, openapi => {error => "Patron category \"".$_->categorycode."\" does not exist"});
        }
        elsif ($_->isa('Koha::Exceptions::MissingParameter')) {
            return $c->render( status => 400, openapi => {error => "Missing mandatory parameter(s)", parameters => $_->parameter });
        }
        elsif ($_->isa('Koha::Exceptions::BadParameter')) {
            return $c->render( status => 400, openapi => {error => "Invalid parameter(s)", parameters => $_->parameter });
        }
        elsif ($_->isa('Koha::Exceptions::NoChanges')) {
            return $c->render( status => 204, openapi => {error => "No changes have been made"});
        }
        else {
            return $c->render( status => 500, openapi => {error => "Something went wrong, check Koha logs for details."});
        }
        Koha::Exceptions::rethrow_exception($_);
    };
}

sub patch {
    return edit(@_);
}

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $patron = Koha::Patrons->find($c->validation->param('borrowernumber'));
    unless ($patron) {
        return $c->render( status => 404, openapi => {error => "Patron not found"});
    }

    # check if loans, reservations, debarrment, etc. before deletion!
    my $res = $patron->delete;

    if ($res eq '1') {
        return $c->render( status => 200, openapi => {});
    } elsif ($res eq '-1') {
        return $c->render( status => 404, openapi => {});
    } else {
        return $c->render( status => 400, openapi => {});
    }
}

sub pay {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $patron = Koha::Patrons->find($c->validation->param('borrowernumber'));
        unless ($patron) {
            return $c->render(status => 404, openapi => {error => "Patron not found"});
        }

        my $body = $c->req->json;
        my $amount = $body->{amount};
        my $note = $body->{note} || '';

        Koha::Account->new(
            {
                patron_id => $c->validation->param('borrowernumber'),
            }
          )->pay(
            {
                amount => $amount,
                note => $note,
            }
          );

        return $c->render(status => 204, openapi => '');
    } catch {
        if ($_->isa('DBIx::Class::Exception')) {
            return $c->render(status => 500, openapi => { error => $_->msg });
        }
        else {
            return $c->render(status => 500,
                              openapi => {
                error => 'Something went wrong, check the logs.'
            });
        }
    };
}

sub changepassword {
    my $c = shift->openapi->valid_input or return;

    my $patron;
    my $user;
    try {
        $patron = Koha::Patrons->find($c->validation->param('borrowernumber'));
        $user = $c->stash('koha.user');

        my $OpacPasswordChange = C4::Context->preference("OpacPasswordChange");
        my $haspermission = haspermission($user->userid, {borrowers => 1});
        unless ($OpacPasswordChange && $user->borrowernumber == $c->validation->param('borrowernumber')) {
            Koha::Exceptions::BadSystemPreference->throw(
                preference => 'OpacPasswordChange'
            ) unless $haspermission;
        }

        my $pw = $c->req->json;
        my $dbh = C4::Context->dbh;
        unless ($haspermission || checkpw_internal($dbh, $patron->userid, $pw->{'current_password'})) {
            Koha::Exceptions::Password::Invalid->throw;
        }
        $patron->change_password_to($pw->{'new_password'});
        return $c->render(status => 200, openapi => {});
    }
    catch {
        if (not defined $patron) {
            return $c->render(status => 404,
                              openapi => { error => "Patron not found." });
        }
        elsif (not defined $user) {
            return $c->render(status  => 500,
                              openapi => { error => "User must be defined." });
        }

        die $_ unless blessed $_ && $_->can('rethrow');
        if ($_->isa('Koha::Exceptions::Password::Invalid')) {
            return $c->render(status  => 400,
                              openapi => { error => "Wrong current password." });
        }
        elsif ($_->isa('Koha::Exceptions::Password::TooShort')) {
            return $c->render(status => 400, openapi => { error => $_->error });
        }
        elsif ($_->isa('Koha::Exceptions::Password::TrailingWhitespaces')) {
            return $c->render(status => 400, openapi => { error => $_->error });
        }
        elsif ($_->isa('Koha::Exceptions::BadSystemPreference')
               && $_->preference eq 'OpacPasswordChange') {
            return $c->render(status => 403,
                              openapi => {
                                error => "OPAC password change is disabled"
                    });
        }
        else {
            return $c->render(status  => 500,
                              openapi => { error => "Something went wrong. $_" });
        }
    }
}

sub getstatus {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $user = $c->stash('koha.user');

        my $patron = Koha::Patrons->find($c->validation->param('borrowernumber'));
        unless ($patron) {
            return $c->render(status  => 404,
                              openapi => {error => "Patron not found"});
        }

        my $ret = $patron->TO_JSON;
        my %problems = map { ref($_) => $_ } $patron->status_not_ok;
        $ret->{blocks} = Koha::Availability->_swaggerize_exception(\%problems);

        return $c->render(status => 200, openapi => $ret);
    } catch {
        if ( $_->isa('DBIx::Class::Exception') ) {
            return $c->render(status => 500, openapi => { error => $_->msg });
        }
        else {
            return $c->render( status => 500, openapi =>
                { error => "Something went wrong, check the logs." });
        }
    };
}

1;
