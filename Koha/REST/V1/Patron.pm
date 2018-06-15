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
use C4::Log;
use C4::Members;
use Koha::Exceptions;
use Koha::Exceptions::Password;
use Koha::Patrons;
use Koha::Patron::Categories;
use Koha::Patron::Modifications;
use Koha::Patron::AllData;
use Koha::Libraries;

use Scalar::Util qw(blessed looks_like_number);
use Try::Tiny;

sub list {
    my $c = shift->openapi->valid_input or return;

    my $user = $c->stash('koha.user');
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

    # TODO Koha-Suomi: Remove this ugly hack below and replace huge return arrays
    #      with pagination feature (already implemented in Koha 17.11 onwards)
    # Safety switch to avoid spamming action log with thousands of lines:
    my $log = $patrons->count < 100 if C4::Context->preference('BorrowersViewLog');

    if (!$c->stash('is_owner_access') && $log) {
        foreach my $patron (@{$patrons->as_list}) {
            next if $patron->borrowernumber == $user->borrowernumber;
            C4::Log::logaction('MEMBERS', 'VIEW', $patron->borrowernumber, '');
        }
    }

    return $c->render(status => 200, openapi => $patrons);
}

sub get {
    my $c = shift->openapi->valid_input or return;

    my $user = $c->stash('koha.user');
    my $borrowernumber = $c->validation->param('borrowernumber');
    my $patron = Koha::Patrons->find($borrowernumber);

    unless ($patron) {
        return $c->render(status => 404, openapi => { error => "Patron not found." });
    }

    if (!$c->stash('is_owner_access')                    &&
        $patron->borrowernumber != $user->borrowernumber &&
        C4::Context->preference('BorrowersViewLog'))
    {
        C4::Log::logaction('MEMBERS', 'VIEW', $patron->borrowernumber, '');
    }

    return $c->render(status => 200, openapi => $patron);
}

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $body = $c->req->json;

        if ($body->{password}) { $body->{password} = hash_password($body->{password}) }; # bcrypt password if given

        my $patron = Koha::Patron->new($body)->validate->store;
        if (C4::Context->preference('BorrowersLog')) {
            C4::Log::logaction('MEMBERS', 'CREATE', $patron->borrowernumber, '');
        }
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

        if ($c->stash('is_owner_access') || $c->stash('is_guarantor_access')){
            if (C4::Context->preference('OPACPatronDetails')) {
                die unless $patron->set($body)->validate;
                my $verification
                        = _parameters_require_modification_request($body);
                if (keys %{$verification->{not_required}}) {

                    # Get modified fields for action logging
                    my $logdata = C4::Members::getModifiedPatronFieldsForLogs(
                        $verification->{not_required}, $patron->unblessed
                    ) if C4::Context->preference('BorrowersLog');

                    # Update changes
                    Koha::Patrons->find($borrowernumber)->set(
                        $verification->{not_required})->store;

                    # Store action log of modification
                    if ($logdata) {
                        C4::Log::logaction('MEMBERS', 'MODIFY', $borrowernumber,
                            "UPDATED FIELD(S): $logdata"
                        );
                    }

                    unless (keys %{$verification->{required}}) {
                        return $c->render( status => 200, openapi => $patron );
                    }
                }
                if (keys %{$verification->{required}}) {
                    $verification->{required}->{borrowernumber} = $borrowernumber;
                    my $m = Koha::Patron::Modification->new(
                        $verification->{required}
                    )->store();

                    my $logdata = C4::Members::getModifiedPatronFieldsForLogs(
                        $verification->{required}, $patron->unblessed
                    ) if C4::Context->preference('BorrowersLog');

                    if ($logdata) {
                        C4::Log::logaction('MEMBERS', 'MODIFY', $borrowernumber,
                            "MOD REQUEST FIELD(S): $logdata"
                        );
                    }

                    return $c->render( status => 202, openapi => {});
                }
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

            # Get modified fields for action logging
            my $logdata = C4::Members::getModifiedPatronFieldsForLogs(
                $body, $patron->unblessed
            ) if C4::Context->preference('BorrowersLog');

            # Store action log of modification
            if ($logdata) {
                C4::Log::logaction('MEMBERS', 'MODIFY', $patron->borrowernumber,
                    "UPDATED FIELD(S): $logdata"
                );
            }

            return $c->render( status => 200, openapi => $patron);
        }
    }
    catch {
        unless ($patron) {
            return $c->render( status => 404, openapi => {error => "Patron not found"});
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
        Koha::Exceptions::rethrow_exception($_);
    };
}

sub patch {
    # TODO:
    # Currently PUT implements a more PATCH-like feature where the whole object
    # is not required. We can simply use the logic provided by current PUT for
    # PATCH request. However, the PUT request should be fixed to require
    # a complete patron object.
    return edit(@_);
}

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $patron = Koha::Patrons->find($c->validation->param('borrowernumber'));
    unless ($patron) {
        return $c->render( status => 404, openapi => {error => "Patron not found"});
    }

    my $borrowernumber = $patron->borrowernumber;

    # check if loans, reservations, debarrment, etc. before deletion!
    my $res = $patron->delete;

    if (C4::Context->preference('BorrowersLog')) {
        C4::Log::logaction('MEMBERS', 'DELETE', $borrowernumber, '');
    }

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

sub api_changepassword {
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

        if (C4::Context->preference('BorrowersLog')) {
            C4::Log::logaction('MEMBERS', 'MODIFY', $patron->borrowernumber,
                "Change password");
        }

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
        elsif ($_->isa('Koha::Exceptions::Password::Policy')) {
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

        if (C4::Context->preference('BorrowersViewLog')) {
            C4::Log::logaction('MEMBERS', 'VIEW', $patron->borrowernumber,
                               'Patron status request');
        }

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

sub getalldata {
    my $c = shift->openapi->valid_input or return;
    my $retval;
    my $error;
    return try {
        my $patron = Koha::Patrons->find($c->validation->param('borrowernumber'))->unblessed;
        my $section = $c->validation->param('section');
        unless ($patron) {
            return $c->render(status  => 404,
                              openapi => {error => "Patron not found"});
        }

        unless ($section) {
            ($retval, $error) = Koha::Patron::AllData->getall({borrowernumber => $patron->{borrowernumber}});
        } else {
            my $method = "get".$section;
            ($retval, $error) = Koha::Patron::AllData->$method({borrowernumber => $patron->{borrowernumber}});
        }
        if ($error) {
            return $c->render(status  => 500,
                              openapi => { error => $error });
        } elsif (!$retval) {
            return $c->render(status  => 404,
                              openapi => {error => "Data not found"});
        }
        return $c->render( status => 200, openapi => $retval);
    } catch {
        return $c->render(status  => 500,
                              openapi => { error => "Something went wrong. $_" });
    }

}

# Takes a HASHref of parameters
# Returns a HASHref that contains
# 1. not_required HASHref
#       - parameters that do not need librarian confirmation
# 2. required HASHref
#       - parameters that do need librarian confirmation
sub _parameters_require_modification_request {
    my ($body) = @_;

    my $not_required = {
        'privacy' => 1,
        'smsalertnumber' => 1,
        'email' => 1,
    };

    my $params = {
        not_required => {},
        required     => {},
    };
    foreach my $param (keys %$body) {
        if ($not_required->{$param}) {
            $params->{not_required}->{$param} = $body->{$param};
        }
        else {
            $params->{required}->{$param} = $body->{$param};
        }
    }

    return $params;
}

1;
