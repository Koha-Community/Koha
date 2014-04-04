#!/usr/bin/perl

# Copyright 2016 PTFS-Europe Ltd
#
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

=head1 housebound.pl

 Script to handle housebound management for patrons.  This single script
 handles display, creation, deletion and management of profiles and visits.

=cut

use Modern::Perl;
use CGI;
use C4::Auth;
use C4::Output;
use Koha::Libraries;
use Koha::Patrons;
use Koha::Patron::Categories;
use Koha::Patron::HouseboundProfile;
use Koha::Patron::HouseboundVisit;
use Koha::Patron::HouseboundVisits;

my $input = CGI->new;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => 'members/housebound.tt',
        query           => $input,
        type            => 'intranet',
        authnotrequired => 0,
        flagsrequired   => { borrowers => 1 },
    }
);

my $patron = Koha::Patrons->new->find($input->param('borrowernumber'));
my $method = $input->param('method') // q{};
my $visit_id = $input->param('visit_id') // q{};
my $branch = Koha::Libraries->new->find($patron->branchcode);
my $category = Koha::Patron::Categories->new->find($patron->categorycode);
my $houseboundprofile = $patron->housebound_profile;

my ( $houseboundvisits, $deliverers, $choosers );
my ( $houseboundvisit, $deliverer, $chooser );

if ( $method eq 'updateconfirm' ) {
    # We have received the input from the profile edit form.  We must save the
    # changes, and return to simple display.
    $houseboundprofile->set({
        day           => $input->param('day')           // q{},
        frequency     => $input->param('frequency')     // q{},
        fav_itemtypes => $input->param('fav_itemtypes') // q{},
        fav_subjects  => $input->param('fav_subjects')  // q{},
        fav_authors   => $input->param('fav_authors')   // q{},
        referral      => $input->param('referral')      // q{},
        notes         => $input->param('notes')         // q{},
    });
    die("Unable to store edited profile")
        unless ( $houseboundprofile->store );
    $method = undef;
} elsif ( $method eq 'createconfirm' ) {
    # We have received the input necessary to create a new profile.  We must
    # save it, and return to simple display.
    $houseboundprofile = Koha::Patron::HouseboundProfile->new({
        borrowernumber => $patron->borrowernumber,
        day            => $input->param('day')           // q{},
        frequency      => $input->param('frequency')     // q{},
        fav_itemtypes  => $input->param('fav_itemtypes') // q{},
        fav_subjects   => $input->param('fav_subjects')  // q{},
        fav_authors    => $input->param('fav_authors')   // q{},
        referral       => $input->param('referral')      // q{},
        notes          => $input->param('notes')         // q{},
    });
    die("Unable to store new profile")
        unless ( $houseboundprofile->store );
    $method = undef;
} elsif ( $method eq 'visit_update_or_create' ) {
    # We want to edit, edit a visit, so we must pass its details.
    $deliverers = Koha::Patrons->new->housebound_deliverers;
    $choosers = Koha::Patrons->new->housebound_choosers;
    $houseboundvisit = Koha::Patron::HouseboundVisits->find($visit_id)
        if ( $visit_id );
} elsif ( $method eq 'visit_delete' ) {
    # We want ot delete a specific visit.
    my $visit = Koha::Patron::HouseboundVisits->find($visit_id);
    die("Unable to delete visit") unless ( $visit->delete );
    $method = undef;
} elsif ( $method eq 'editvisitconfirm' ) {
    # We have received input for editing a visit.  We must store and return to
    # simple display.
    my $visit = Koha::Patron::HouseboundVisits->find($visit_id);
    $visit->set({
        borrowernumber      => $input->param('borrowernumber') // q{},
        appointment_date    => $input->param('date')           // q{},
        day_segment         => $input->param('segment')        // q{},
        chooser_brwnumber   => $input->param('chooser')        // q{},
        deliverer_brwnumber => $input->param('deliverer')      // q{},
    });
    die("Unable to store edited visit") unless ( $visit->store );
    $method = undef;
} elsif ( $method eq 'addvisitconfirm' ) {
    # We have received input for creating a visit.  We must store and return
    # to simple display.
    my $visit = Koha::Patron::HouseboundVisit->new({
        borrowernumber      => $input->param('borrowernumber') // q{},
        appointment_date    => $input->param('date')           // q{},
        day_segment         => $input->param('segment')        // q{},
        chooser_brwnumber   => $input->param('chooser')        // q{},
        deliverer_brwnumber => $input->param('deliverer')      // q{},
    });
    die("Unable to store new visit") unless ( $visit->store );
    $method = undef;
}

# We don't have any profile information, so we must display a creation form.
$method = 'update_or_create' if ( !$houseboundprofile );

$template->param(
    patron             => $patron,
    housebound_profile => $houseboundprofile,
    visit              => $houseboundvisit,
    branch             => $branch,
    category           => $category,
    method             => $method,
    choosers           => $choosers,
    deliverers         => $deliverers,
    houseboundview     => 'on',
);

output_html_with_http_headers $input, $cookie, $template->output;

=head1 AUTHOR

Alex Sassmannshausen <alex.sassmannshausen@ptfs-europe.com>

=cut
