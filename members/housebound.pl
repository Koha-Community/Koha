#!/usr/bin/perl

# Copyright 2016 PTFS-Europe Ltd
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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

=head1 housebound.pl

 Script to handle housebound management for patrons.  This single script
 handles display, creation, deletion and management of profiles and visits.

=cut

use Modern::Perl;
use CGI;
use C4::Auth qw( get_template_and_user );
use C4::Context;
use C4::Output qw( output_and_exit_if_error output_and_exit output_html_with_http_headers );
use DateTime;
use Koha::Libraries;
use Koha::Patrons;
use Koha::Patron::Categories;
use Koha::Patron::HouseboundProfile;
use Koha::Patron::HouseboundVisit;
use Koha::Patron::HouseboundVisits;

my $input = CGI->new;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => 'members/housebound.tt',
        query         => $input,
        type          => 'intranet',
        flagsrequired => { borrowers => 'edit_borrowers' },
    }
);

my @messages;    # For error messages.
my $op       = $input->param('op')       // q{};
my $visit_id = $input->param('visit_id') // q{};

# Get patron
my $borrowernumber = $input->param('borrowernumber');
my $logged_in_user = Koha::Patrons->find($loggedinuser);
my $patron         = Koha::Patrons->find($borrowernumber);
output_and_exit_if_error(
    $input, $cookie, $template,
    { module => 'members', logged_in_user => $logged_in_user, current_patron => $patron }
);

# Get supporting cast
my ( $houseboundprofile, $visit );
if ($patron) {    # FIXME This test is not needed - output_and_exit_if_error handles it
    $houseboundprofile = $patron->housebound_profile;
}
if ($visit_id) {
    $visit = eval { return Koha::Patron::HouseboundVisits->find($visit_id); };
    push @messages, { type => 'error', code => 'error_on_visit_load' }
        if ( $@ or !$visit );
}

# Main processing
my ( $deliverers, $choosers, $houseboundvisit );

if ( $op eq 'cud-updateconfirm' and $houseboundprofile ) {

    # We have received the input from the profile edit form.  We must save the
    # changes, and return to simple display.
    $houseboundprofile->set(
        {
            day           => scalar $input->param('day')           // q{},
            frequency     => scalar $input->param('frequency')     // q{},
            fav_itemtypes => scalar $input->param('fav_itemtypes') // q{},
            fav_subjects  => scalar $input->param('fav_subjects')  // q{},
            fav_authors   => scalar $input->param('fav_authors')   // q{},
            referral      => scalar $input->param('referral')      // q{},
            notes         => scalar $input->param('notes')         // q{},
        }
    );
    my $success = eval { return $houseboundprofile->store };
    push @messages, { type => 'error', code => 'error_on_profile_store' }
        if ( $@ or !$success );
    $op = undef;
} elsif ( $op eq 'cud-createconfirm' ) {

    # We have received the input necessary to create a new profile.  We must
    # save it, and return to simple display.
    $houseboundprofile = Koha::Patron::HouseboundProfile->new(
        {
            borrowernumber => $patron->borrowernumber,
            day            => scalar $input->param('day')           // q{},
            frequency      => scalar $input->param('frequency')     // q{},
            fav_itemtypes  => scalar $input->param('fav_itemtypes') // q{},
            fav_subjects   => scalar $input->param('fav_subjects')  // q{},
            fav_authors    => scalar $input->param('fav_authors')   // q{},
            referral       => scalar $input->param('referral')      // q{},
            notes          => scalar $input->param('notes')         // q{},
        }
    );
    my $success = eval { return $houseboundprofile->store };
    push @messages, { type => 'error', code => 'error_on_profile_create' }
        if ( $@ or !$success );
    $op = undef;
} elsif ( $op eq 'visit_update_or_create' ) {

    # We want to edit, edit a visit, so we must pass its details.
    $deliverers      = Koha::Patrons->search_housebound_deliverers;
    $choosers        = Koha::Patrons->search_housebound_choosers;
    $houseboundvisit = $visit;
} elsif ( $op eq 'cud-visit_delete' and $visit ) {

    # We want to delete a specific visit.
    my $success = eval { return $visit->delete };
    push @messages, { type => 'error', code => 'error_on_visit_delete' }
        if ( $@ or !$success );
    $op = undef;
} elsif ( $op eq 'cud-editvisitconfirm' and $visit ) {

    # We have received input for editing a visit.  We must store and return to
    # simple display.
    $visit->set(
        {
            borrowernumber      => scalar $input->param('borrowernumber') // q{},
            appointment_date    => scalar $input->param('date')           // q{},
            day_segment         => scalar $input->param('segment')        // q{},
            chooser_brwnumber   => scalar $input->param('chooser')        // q{},
            deliverer_brwnumber => scalar $input->param('deliverer')      // q{},
        }
    );
    my $success = eval { return $visit->store };
    push @messages, { type => 'error', code => 'error_on_visit_store' }
        if ( $@ or !$success );
    $op = undef;
} elsif ( $op eq 'cud-addvisitconfirm' and !$visit ) {

    # We have received input for creating a visit.  We must store and return
    # to simple display.
    my $visit = Koha::Patron::HouseboundVisit->new(
        {
            borrowernumber      => scalar $input->param('borrowernumber') // q{},
            appointment_date    => scalar $input->param('date')           // q{},
            day_segment         => scalar $input->param('segment')        // q{},
            chooser_brwnumber   => scalar $input->param('chooser')        // q{},
            deliverer_brwnumber => scalar $input->param('deliverer')      // q{},
        }
    );
    my $success = eval { return $visit->store };
    push @messages, { type => 'error', code => 'error_on_visit_create' }
        if ( $@ or !$success );
    $op = undef;
}

# We don't have any profile information, so we must display a creation form.
$op = 'update_or_create' if ( !$houseboundprofile );

# Ensure template has all patron details.
$template->param( patron => $patron );

$template->param(
    housebound_profile => $houseboundprofile,
    visit              => $houseboundvisit,
    messages           => \@messages,
    op                 => $op,
    choosers           => $choosers,
    deliverers         => $deliverers,
    houseboundview     => 'on',
);

output_html_with_http_headers $input, $cookie, $template->output;

=head1 AUTHOR

Alex Sassmannshausen <alex.sassmannshausen@ptfs-europe.com>

=cut
