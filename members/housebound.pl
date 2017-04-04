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
use C4::Context;
use C4::Members::Attributes qw(GetBorrowerAttributes);
use C4::Output;
use DateTime;
use Koha::DateUtils;
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
        flagsrequired   => { borrowers => 'edit_borrowers' },
    }
);

my @messages;                   # For error messages.
my $method = $input->param('method') // q{};
my $visit_id = $input->param('visit_id') // q{};

# Get patron
my $patron = eval {
    my $borrowernumber = $input->param('borrowernumber') // q{};
    return Koha::Patrons->find($borrowernumber);
};
push @messages, { type => 'error', code => 'error_on_patron_load' }
    if ( $@ or !$patron );

# Get supporting cast
my ( $branch, $category, $houseboundprofile, $visit, $patron_image );
if ( $patron ) {
    $patron_image = $patron->image;
    $branch = Koha::Libraries->new->find($patron->branchcode);
    $category = Koha::Patron::Categories->new->find($patron->categorycode);
    $houseboundprofile = $patron->housebound_profile;
}
if ( $visit_id ) {
    $visit = eval {
        return Koha::Patron::HouseboundVisits->find($visit_id);
    };
    push @messages, { type => 'error', code => 'error_on_visit_load' }
        if ( $@ or !$visit );
}

# Main processing
my ( $deliverers, $choosers, $houseboundvisit );

if ( $method eq 'updateconfirm' and $houseboundprofile ) {
    # We have received the input from the profile edit form.  We must save the
    # changes, and return to simple display.
    $houseboundprofile->set({
        day           => scalar $input->param('day')           // q{},
        frequency     => scalar $input->param('frequency')     // q{},
        fav_itemtypes => scalar $input->param('fav_itemtypes') // q{},
        fav_subjects  => scalar $input->param('fav_subjects')  // q{},
        fav_authors   => scalar $input->param('fav_authors')   // q{},
        referral      => scalar $input->param('referral')      // q{},
        notes         => scalar $input->param('notes')         // q{},
    });
    my $success = eval { return $houseboundprofile->store };
    push @messages, { type => 'error', code => 'error_on_profile_store' }
        if ( $@ or !$success );
    $method = undef;
} elsif ( $method eq 'createconfirm' ) {
    # We have received the input necessary to create a new profile.  We must
    # save it, and return to simple display.
    $houseboundprofile = Koha::Patron::HouseboundProfile->new({
        borrowernumber => $patron->borrowernumber,
        day            => scalar $input->param('day')           // q{},
        frequency      => scalar $input->param('frequency')     // q{},
        fav_itemtypes  => scalar $input->param('fav_itemtypes') // q{},
        fav_subjects   => scalar $input->param('fav_subjects')  // q{},
        fav_authors    => scalar $input->param('fav_authors')   // q{},
        referral       => scalar $input->param('referral')      // q{},
        notes          => scalar $input->param('notes')         // q{},
    });
    my $success = eval { return $houseboundprofile->store };
    push @messages, { type => 'error', code => 'error_on_profile_create' }
        if ( $@ or !$success );
    $method = undef;
} elsif ( $method eq 'visit_update_or_create' ) {
    # We want to edit, edit a visit, so we must pass its details.
    $deliverers = Koha::Patrons->search_housebound_deliverers;
    $choosers = Koha::Patrons->search_housebound_choosers;
    $houseboundvisit = $visit;
} elsif ( $method eq 'visit_delete' and $visit ) {
    # We want ot delete a specific visit.
    my $success = eval { return $visit->delete };
    push @messages, { type => 'error', code => 'error_on_visit_delete' }
        if ( $@ or !$success );
    $method = undef;
} elsif ( $method eq 'editvisitconfirm' and $visit ) {
    # We have received input for editing a visit.  We must store and return to
    # simple display.
    $visit->set({
        borrowernumber      => scalar $input->param('borrowernumber')      // q{},
        appointment_date    => dt_from_string($input->param('date') // q{}),
        day_segment         => scalar $input->param('segment')             // q{},
        chooser_brwnumber   => scalar $input->param('chooser')             // q{},
        deliverer_brwnumber => scalar $input->param('deliverer')           // q{},
    });
    my $success = eval { return $visit->store };
    push @messages, { type => 'error', code => 'error_on_visit_store' }
        if ( $@ or !$success );
    $method = undef;
} elsif ( $method eq 'addvisitconfirm' and !$visit ) {
    # We have received input for creating a visit.  We must store and return
    # to simple display.
    my $visit = Koha::Patron::HouseboundVisit->new({
        borrowernumber      => scalar $input->param('borrowernumber')      // q{},
        appointment_date    => dt_from_string($input->param('date') // q{}),
        day_segment         => scalar $input->param('segment')             // q{},
        chooser_brwnumber   => scalar $input->param('chooser')             // q{},
        deliverer_brwnumber => scalar $input->param('deliverer')           // q{},
    });
    my $success = eval { return $visit->store };
    push @messages, { type => 'error', code => 'error_on_visit_create' }
        if ( $@ or !$success );
    $method = undef;
}

# We don't have any profile information, so we must display a creation form.
$method = 'update_or_create' if ( !$houseboundprofile );

# Ensure template has all patron details.
$template->param(%{$patron->unblessed}) if ( $patron );

# Load extended patron attributes if necessary (taken from members/files.pl).
if ( C4::Context->preference('ExtendedPatronAttributes') and $patron ) {
    my $attributes = GetBorrowerAttributes($patron->borrowernumber);
    $template->param(
        ExtendedPatronAttributes => 1,
        extendedattributes => $attributes
    );
}

$template->param( adultborrower => 1 ) if ( $category->category_type eq 'A' || $category->category_type eq 'I' );
$template->param(
    picture            => $patron_image,
    housebound_profile => $houseboundprofile,
    visit              => $houseboundvisit,
    branch             => $branch,
    category           => $category,
    messages           => \@messages,
    method             => $method,
    choosers           => $choosers,
    deliverers         => $deliverers,
    houseboundview     => 'on',
);

output_html_with_http_headers $input, $cookie, $template->output;

=head1 AUTHOR

Alex Sassmannshausen <alex.sassmannshausen@ptfs-europe.com>

=cut
