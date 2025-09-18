package Koha::Checkouts;

# Copyright ByWater Solutions 2015
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

use C4::Context;
use C4::Circulation qw( AddReturn );
use Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue;
use Koha::Checkout;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

use base qw(Koha::Objects);

=head1 NAME

Koha::Checkouts - Koha Checkout object set class

=head1 API

=head2 Class Methods

=cut

=head3 calculate_dropbox_date

my $dt = Koha::Checkouts::calculate_dropbox_date();

=cut

sub calculate_dropbox_date {
    my $userenv    = C4::Context->userenv;
    my $branchcode = $userenv->{branch} // q{};

    my $daysmode = Koha::CirculationRules->get_effective_daysmode(
        {
            categorycode => undef,
            itemtype     => undef,
            branchcode   => $branchcode,
        }
    );
    my $calendar     = Koha::Calendar->new( branchcode => $branchcode, days_mode => $daysmode );
    my $today        = dt_from_string;
    my $dropbox_date = $calendar->addDuration( $today, -1 );

    return $dropbox_date;
}

=head3 automatic_checkin

my $automatic_checkins = Koha::Checkouts->automatic_checkin()

Checks in every due issue which itemtype has automatic_checkin enabled. Also if the AutoCheckinAutoFill system preference is enabled, the item is trapped for the next patron.

=cut

sub automatic_checkin {
    my ( $self, $params ) = @_;

    my $current_date = dt_from_string;

    my $dtf           = Koha::Database->new->schema->storage->datetime_parser;
    my $due_checkouts = $self->search(
        { date_due => { '<=' => $dtf->format_datetime($current_date) } },
        { prefetch => 'item' }
    );

    my $autofill_next = C4::Context->preference('AutomaticCheckinAutoFill');

    while ( my $checkout = $due_checkouts->next ) {
        if ( $checkout->item->itemtype->automatic_checkin ) {
            my ( $returned, $messages ) = C4::Circulation::AddReturn(
                $checkout->item->barcode, $checkout->branchcode, undef,
                dt_from_string( $checkout->date_due )
            );
            if ($autofill_next) {
                if ( $messages->{ResFound} ) {
                    my $is_transfer = $checkout->branchcode ne $messages->{ResFound}->{branchcode};
                    C4::Reserves::ModReserveAffect(
                        $checkout->item->itemnumber, $checkout->borrowernumber,
                        $is_transfer, $messages->{ResFound}->{reserve_id}, $checkout->{desk_id}, 0
                    );
                    if ($is_transfer) {
                        C4::Items::ModItemTransfer(
                            $checkout->item->itemnumber,         $checkout->branchcode,
                            $messages->{ResFound}->{branchcode}, "Reserve"
                        );
                    }
                }
            }

            # If item is checked in let's update the holds queue, after hold/transfers handled above
            Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue->new->enqueue(
                { biblio_ids => [ $checkout->item->biblionumber ] } )
                if $returned && C4::Context->preference('RealTimeHoldsQueue');
        }
    }
}

=head3 type

=cut

sub _type {
    return 'Issue';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::Checkout';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
