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
use C4::Members;
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use Koha::DateUtils qw( dt_from_string );
use Koha::CurbsidePickups;
use Koha::CurbsidePickupPolicies;
use Koha::Libraries;
use Koha::Patrons;

my $input = CGI->new;
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => "opac-curbside-pickups.tt",
        query         => $input,
        type          => "opac",
    }
);

unless ( C4::Context->preference('CurbsidePickup') ) {
    print $input->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

my $op = $input->param('op') || 'list';

my $logged_in_patron = Koha::Patrons->find($borrowernumber);
my $branchcode       = $input->param('pickup_branch');
my @messages;

if ( $op eq 'cud-create-pickup' ) {
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
                type => 'error',
                code => 'not_enabled',
            };
        } elsif ( $_->isa('Koha::Exceptions::CurbsidePickup::LibraryIsClosed') ) {
            push @messages, {
                type   => 'error',
                code   => 'library_is_closed',
                patron => Koha::Patrons->find($borrowernumber)
            };
        } elsif ( $_->isa('Koha::Exceptions::CurbsidePickup::NoWaitingHolds') ) {
            push @messages, {
                type => 'error',
                code => 'no_waiting_holds',
            };
        } elsif ( $_->isa('Koha::Exceptions::CurbsidePickup::TooManyPickups') ) {
            push @messages, {
                type   => 'error',
                code   => 'too_many_pickups',
                patron => Koha::Patrons->find($borrowernumber)
            };
        } elsif ( $_->isa('Koha::Exceptions::CurbsidePickup::NoMatchingSlots') ) {
            push @messages, {
                type => 'error',
                code => 'no_matching_slots',
            };
        } elsif ( $_->isa('Koha::Exceptions::CurbsidePickup::NoMorePickupsAvailable') ) {
            push @messages, {
                type => 'error',
                code => 'no_more_pickups_available',
            };
        } else {
            warn $_;
            push @messages, {
                type => 'error',
                code => 'something_wrong_happened',
            };
        }
    }
} elsif ( $op eq 'cud-cancel-pickup' ) {
    my $id              = $input->param('pickup_id');
    my $curbside_pickup = Koha::CurbsidePickups->search( { borrowernumber => $borrowernumber } )->find($id);
    $curbside_pickup->delete
        if $curbside_pickup
        && !$curbside_pickup->delivered_datetime;
} elsif ( $op eq 'cud-arrival-alert' ) {
    my $id              = $input->param('pickup_id');
    my $curbside_pickup = Koha::CurbsidePickups->search( { borrowernumber => $borrowernumber } )->find($id);
    $curbside_pickup->mark_patron_has_arrived if $curbside_pickup;
    push @messages, {
        type => 'message',
        code => 'library_notified',
    };
}

$template->param(
    messages => \@messages,
    policies => Koha::CurbsidePickupPolicies->search(
        {
            enabled                 => 1,
            patron_scheduled_pickup => 1,
        }
    ),
    patron_curbside_pickups => Koha::CurbsidePickups->search(
        {
            borrowernumber => $logged_in_patron->borrowernumber,
        },
        { order_by => { -asc => 'scheduled_pickup_datetime' } }
    )->filter_by_scheduled_today,
    curbside_pickups => Koha::CurbsidePickups->search(
        {},
        { order_by => { -asc => 'scheduled_pickup_datetime' } }
    )->filter_by_scheduled_today,
    curbside_pickups_view => 1,
);

output_html_with_http_headers $input, $cookie, $template->output, undef,
    { force_no_caching => 1 };
