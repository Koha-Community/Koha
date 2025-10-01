#!/usr/bin/perl

#script to modify reserves/requests
#written 2/1/00 by chris@katipo.oc.nz
#last update 27/1/2000 by chris@katipo.co.nz

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use CGI qw ( -utf8 );
use C4::Output;
use C4::Auth qw( get_template_and_user );
use Koha::Holds;

my $query = CGI->new;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => "opac-account.tt",
        query         => $query,
        type          => "opac",
    }
);

my $op                  = $query->param('op');
my $reserve_id          = $query->param('reserve_id');
my $new_pickup_location = $query->param('new_pickup_location');

if ( $reserve_id && $borrowernumber ) {

    my $hold = Koha::Holds->find($reserve_id);

    unless ( $hold && $hold->borrowernumber == $borrowernumber ) {

        # whatcha tryin to do?
        print $query->redirect('/cgi-bin/koha/errors/403.pl');
        exit;
    }

    if ( $op eq 'cud-request_cancellation' ) {
        $hold->add_cancellation_request
            if $hold->cancellation_requestable_from_opac;
    } elsif ( $op eq 'cud-change_branch' && $new_pickup_location ) {

        if ( $hold->can_update_pickup_location_opac ) {
            $hold->set_pickup_location( { library_id => $new_pickup_location } );
        } else {

            # whatcha tryin to do?
            print $query->redirect('/cgi-bin/koha/errors/403.pl');
            exit;
        }
    } elsif ( $op eq 'cud-cancel' && $hold->is_cancelable_from_opac ) {
        $hold->cancel;
    }
}

print $query->redirect("/cgi-bin/koha/opac-user.pl?opac-user-holds=1");
