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
use Koha::AuthUtils qw(hash_password);
use Koha::Patrons;
use Koha::Patron::Categories;
use Koha::Libraries;

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

    my $body = $c->req->json;

    # patron cardnumber and/or userid unique?
    if ($body->{cardnumber} || $body->{userid}) {
        my $patron = Koha::Patrons->find({cardnumber => $body->{cardnumber}, userid => $body->{userid} });
        if ($patron) {
            return $c->$cb({
                error => "Patron cardnumber and userid must be unique",
                conflict => { cardnumber => $patron->cardnumber, userid => $patron->userid }
            }, 409);
        }
    }

    my $branch = Koha::Libraries->find({branchcode => $body->{branchcode} });
    unless ($branch) {
        return $c->$cb({error => "Library with branchcode \"" . $body->{branchcode} . "\" does not exist"}, 404);
    }
    my $category = Koha::Patron::Categories->find({ categorycode => $body->{categorycode} });
    unless ($category) {
        return $c->$cb({error => "Patron category \"" . $body->{categorycode} . "\" does not exist"}, 404);
    }
    # All OK - save new patron

    if ($body->{password}) { $body->{password} = hash_password($body->{password}) }; # bcrypt password if given

    my $patron = eval {
        Koha::Patron->new($body)->store;
    };

    unless ($patron) {
        return $c->$cb({error => "Something went wrong, check Koha logs for details"}, 500);
    }

    return $c->$cb($patron, 201);
}

sub edit {
    my ($c, $args, $cb) = @_;

    my $patron = Koha::Patrons->find($args->{borrowernumber});
    unless ($patron) {
        return $c->$cb({error => "Patron not found"}, 404);
    }

    my $body = $c->req->json;

    # Can we change userid and/or cardnumber? in that case check that they are altered first
    if ($body->{cardnumber} || $body->{userid}) {
        if ( ($body->{cardnumber} && $body->{cardnumber} ne $patron->cardnumber) || ($body->{userid} && $body->{userid} ne $patron->userid) ) {
            my $conflictingPatron = Koha::Patrons->find({cardnumber => $body->{cardnumber}, userid => $body->{userid} });
            if ($conflictingPatron) {
                return $c->$cb({
                    error => "Patron cardnumber and userid must be unique",
                    conflict => { cardnumber => $conflictingPatron->cardnumber, userid => $conflictingPatron->userid }
                }, 409);
            }
        }
    }

    if ($body->{branchcode}) {
        my $branch = Koha::Libraries->find({branchcode => $body->{branchcode} });
        unless ($branch) {
            return $c->$cb({error => "Library with branchcode \"" . $body->{branchcode} . "\" does not exist"}, 404);
        }
    }

    if ($body->{categorycode}) {
        my $category = Koha::Patron::Categories->find({ categorycode => $body->{categorycode} });
        unless ($category) {
            return $c->$cb({error => "Patron category \"" . $body->{categorycode} . "\" does not exist"}, 404);
        }
    }
    # ALL OK - Update patron
    # Perhaps limit/validate what should be updated here? flags, et.al.
    if ($body->{password}) { $body->{password} = hash_password($body->{password}) }; # bcrypt password if given

    my $updatedpatron = eval {
        $patron->set($body);
    };

    if ($updatedpatron) {
        if ($updatedpatron->is_changed) {

            my $res = eval {
                $updatedpatron->store;
            };

            unless ($res) {
                return $c->$cb({error => "Something went wrong, check Koha logs for details"}, 500);
            }
            return $c->$cb($res, 200);

        } else {
            return $c->$cb({}, 204); # No Content = No changes made
        }
    } else {
        return $c->$cb({error => "Something went wrong, check Koha logs for details"}, 500);
    }
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

1;
