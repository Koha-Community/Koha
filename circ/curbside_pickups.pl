#!/usr/bin/perl

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

use Modern::Perl;
use CGI qw ( -utf8 );
use Try::Tiny;
use C4::Context;
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use Koha::DateUtils qw( dt_from_string );
use Koha::CurbsidePickups;
use Koha::CurbsidePickupPolicies;
use Koha::Libraries;
use Koha::Patrons;

my $input       = CGI->new;
my $op          = $input->param('op') || 'list';
my $tab         = $input->param('tab');
my $auto_refresh  = $input->param('auto_refresh');
my $refresh_delay = $input->param('refresh_delay');
my @messages;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "circ/curbside_pickups.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { circulate => 'manage_curbside_pickups' },
    }
);

my $branchcode = C4::Context->userenv()->{'branch'};
my $libraries = Koha::Libraries->search( {}, { order_by => ['branchname'] } );
if ( $op eq 'find-patron' ) {
    my $borrowernumber = $input->param('borrowernumber');

    my $patron = Koha::Patrons->find($borrowernumber);

    my $existing_curbside_pickups = Koha::CurbsidePickups->search(
        {
            branchcode                => $branchcode,
            borrowernumber            => $patron->id,
            delivered_datetime        => undef,
        }
    )->filter_by_scheduled_today;

    $tab = 'schedule-pickup';
    $template->param(
        patron      => $patron,
        existing_curbside_pickups => $existing_curbside_pickups,
    );
}
elsif ( $op eq 'create-pickup' ) {
    my $borrowernumber            = $input->param('borrowernumber');
    my $scheduled_pickup_datetime = $input->param('pickup_time');
    my $notes                     = $input->param('notes');

    try {
        my $pickup = Koha::CurbsidePickup->new(
            {
                branchcode                => $branchcode,
                borrowernumber            => $borrowernumber,
                scheduled_pickup_datetime => dt_from_string($scheduled_pickup_datetime),
                notes                     => $notes,
            }
        )->store;
        $pickup->notify_new_pickup;
    } catch {
        if ( $_->isa('Koha::Exceptions::CurbsidePickup::NotEnabled') ) {
            push @messages, {
                type   => 'error',
                code   => 'not_enabled',
            };
        } elsif ( $_->isa('Koha::Exceptions::CurbsidePickup::LibraryIsClosed') ) {
            push @messages, {
                type   => 'error',
                code   => 'library_is_closed',
                patron => Koha::Patrons->find($borrowernumber)
            };
        } elsif ( $_->isa('Koha::Exceptions::CurbsidePickup::NoWaitingHolds') ) {
            push @messages, {
                type   => 'error',
                code   => 'no_waiting_holds',
            };
        } elsif ( $_->isa('Koha::Exceptions::CurbsidePickup::TooManyPickups') ) {
            push @messages, {
                type   => 'error',
                code   => 'too_many_pickups',
                patron => Koha::Patrons->find($borrowernumber)
            };
        } elsif ( $_->isa('Koha::Exceptions::CurbsidePickup::NoMatchingSlots') ) {
            push @messages, {
                type   => 'error',
                code   => 'no_matching_slots',
            };
        } elsif ( $_->isa('Koha::Exceptions::CurbsidePickup::NoMorePickupsAvailable') ) {
            push @messages, {
                type   => 'error',
                code   => 'no_more_pickups_available',
            };
        } else {
            warn $_;
            push @messages, {
                type   => 'error',
                code   => 'something_wrong_happened',
            };
        }
    }
}
elsif ( $op eq 'cancel' ) {
    my $id              = $input->param('id');
    my $curbside_pickup = Koha::CurbsidePickups->find($id);
    $curbside_pickup->delete() if $curbside_pickup;
}
elsif ( $op eq 'mark-as-staged' ) {
    my $id              = $input->param('id');
    my $curbside_pickup = Koha::CurbsidePickups->find($id);
    $curbside_pickup->mark_as_staged if $curbside_pickup;
}
elsif ( $op eq 'mark-as-unstaged' ) {
    my $id              = $input->param('id');
    my $curbside_pickup = Koha::CurbsidePickups->find($id);
    $curbside_pickup->mark_as_unstaged if $curbside_pickup;
}
elsif ( $op eq 'mark-patron-has-arrived' ) {
    my $id              = $input->param('id');
    my $curbside_pickup = Koha::CurbsidePickups->find($id);
    $curbside_pickup->mark_patron_has_arrived if $curbside_pickup;
}
elsif ( $op eq 'mark-as-delivered' ) {
    my $id = $input->param('id');
    my $curbside_pickup = Koha::CurbsidePickups->find($id);
    # FIXME Add a try-catch here
    $curbside_pickup->mark_as_delivered if $curbside_pickup;
}

$template->param(
    messages => \@messages,
    op       => $op,
    tab      => $tab,
    auto_refresh  => $auto_refresh,
    refresh_delay => $refresh_delay,
    policy => Koha::CurbsidePickupPolicies->find({ branchcode => $branchcode }),
    curbside_pickups => Koha::CurbsidePickups->search(
        {
            branchcode => $branchcode,
        },
        { order_by => [ { -desc => 'delivered_datetime' }, 'arrival_datetime', 'scheduled_pickup_datetime' ], }
      )->filter_by_scheduled_today,
);


output_html_with_http_headers $input, $cookie, $template->output;
