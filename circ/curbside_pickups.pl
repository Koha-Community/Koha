#! /usr/bin/perl

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
my $tab         = $input->param('tab'),
my @messages;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "circ/curbside_pickups.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { parameters => 'manage_curbside_pickups' },
    }
);

my $branchcode = C4::Context->userenv()->{'branch'};
my $libraries = Koha::Libraries->search( {}, { order_by => ['branchname'] } );
if ( $op eq 'find-patron' ) {
    my $cardnumber     = $input->param('cardnumber');
    my $borrowernumber = $input->param('borrowernumber');

    my $patron =
      $cardnumber
      ? Koha::Patrons->find( { cardnumber => $cardnumber } )
      : Koha::Patrons->find($borrowernumber);

    my $existing_curbside_pickups;

    if ( $patron ){
        $existing_curbside_pickups = Koha::CurbsidePickups->search(
            {
                branchcode                => $branchcode,
                borrowernumber            => $patron->id,
                delivered_datetime        => undef,
                scheduled_pickup_datetime => { '>' => \'DATE(NOW())' },
            }
        );
    } else {
        push @messages, {
            type => 'error',
            code => 'no_patron_found',
            cardnumber => $cardnumber
        };
    }

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
        Koha::CurbsidePickup->new(
            {
                branchcode                => $branchcode,
                borrowernumber            => $borrowernumber,
                scheduled_pickup_datetime => dt_from_string($scheduled_pickup_datetime),
                notes                     => $notes,
            }
        )->store();
    } catch {
        if ( $_->isa('Koha::Exceptions::CurbsidePickup::TooManyPickups') ) {
            push @messages, {
                type   => 'error',
                code   => 'too_many_pickups',
                patron => Koha::Patrons->find($borrowernumber)
            };
        } else {
            warn $_;
            push @messages, {
                type   => 'error',
                code   => 'something_wrong_happened',
            };
        }
    }
        # $self->_notify_new_pickup($curbside_pickup); TODO
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
    policy => Koha::CurbsidePickupPolicies->find({ branchcode => $branchcode }),
    curbside_pickups => Koha::CurbsidePickups->search(
        {
            branchcode                => $branchcode,
            scheduled_pickup_datetime => { '>' => \'DATE(NOW())' },
        }
      ),
);


output_html_with_http_headers $input, $cookie, $template->output;
