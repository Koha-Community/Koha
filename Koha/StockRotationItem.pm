package Koha::StockRotationItem;

# Copyright PTFS Europe 2016
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

use Modern::Perl;

use DateTime;
use DateTime::Duration;
use Koha::Database;
use Koha::DateUtils qw/dt_from_string/;
use Koha::Item::Transfer;
use Koha::Item;
use Koha::StockRotationStage;
use Try::Tiny;

use base qw(Koha::Object);

=head1 NAME

StockRotationItem - Koha StockRotationItem Object class

=head1 SYNOPSIS

StockRotationItem class used primarily by stockrotation .pls and the stock
rotation cron script.

=head1 DESCRIPTION

Standard Koha::Objects definitions, and additional methods.

=head1 API

=head2 Class Methods

=cut

=head3 _type

=cut

sub _type {
    return 'Stockrotationitem';
}

=head3 itemnumber

  my $item = Koha::StockRotationItem->itemnumber;

Returns the item associated with the current stock rotation item.

=cut

sub itemnumber {
    my ( $self ) = @_;
    my $rs = $self->_result->itemnumber;
    return Koha::Item->_new_from_dbic( $rs );
}

=head3 stage

  my $stage = Koha::StockRotationItem->stage;

Returns the stage associated with the current stock rotation item.

=cut

sub stage {
    my ( $self ) = @_;
    my $rs = $self->_result->stage;
    return Koha::StockRotationStage->_new_from_dbic( $rs );
}

=head3 needs_repatriating

  1|0 = $item->needs_repatriating;

Return 1 if this item is currently not at the library it should be at
according to our stockrotation plan.

=cut

sub needs_repatriating {
    my ( $self ) = @_;
    my ( $item, $stage ) = ( $self->itemnumber, $self->stage );
    if ( $self->itemnumber->get_transfer ) {
        return 0;               # We're in transit.
    } elsif ( $item->holdingbranch ne $stage->branchcode_id
                  || $item->homebranch ne $stage->branchcode_id ) {
        return 1;               # We're not where we should be.
    } else {
        return 0;               # We're at home.
    }
}

=head3 needs_advancing

  1|0 = $item->needs_advancing;

Return 1 if this item is ready to be moved on to the next stage in its rota.

=cut

sub needs_advancing {
    my ( $self ) = @_;
    return 0 if $self->itemnumber->get_transfer; # intransfer: don't advance.
    return 1 if $self->fresh;                    # Just on rota: advance.
    my $completed = $self->itemnumber->_result->branchtransfers->search(
        { 'reason' => "StockrotationAdvance" },
        { order_by => { -desc => 'datearrived' } }
    );
    # Do maths on whether we need to be moved on.
    if ( $completed->count ) {
        my $arrival = dt_from_string(
            $completed->next->datearrived, 'iso'
        );
        my $duration = DateTime::Duration
            ->new( days => $self->stage->duration );
        if ( $arrival + $duration le dt_from_string() ) {
            return 1;
        } else {
            return 0;
        }
    } else {
        warn "We have no historical branch transfer for itemnumber " . $self->itemnumber->itemnumber . "; This should not have happened!";
    }
}

=head3 repatriate

  1|0 = $sritem->repatriate

Put this item into branch transfer with 'StockrotationRepatriation' comment, so
that it may return to it's stage.branch to continue its rota as normal.

Note: Stockrotation falls outside of the normal branch transfer limits and so we
pass 'ignore_limits' in the call to request_transfer.

=cut

sub repatriate {
    my ( $self, $msg ) = @_;

    # Create the transfer.
    my $transfer = try {
        $self->itemnumber->request_transfer(
            {
                to            => $self->stage->branchcode,
                reason        => "StockrotationRepatriation",
                comment       => $msg,
                ignore_limits => 1
            }
        );
    };

    # Ensure the homebranch is still in sync with the rota stage
    $self->itemnumber->homebranch( $self->stage->branchcode_id )->store;

    return defined($transfer) ? 1 : 0;
}

=head3 advance

  1|0 = $sritem->advance;

Put this item into branch transfer with 'StockrotationAdvance' comment, to
transfer it to the next stage in its rota.

If this is the last stage in the rota and this rota is cyclical, we return to
the first stage.  If it is not cyclical, then we delete this
StockRotationItem.

If this item is 'indemand', and advance is invoked, we disable 'indemand' and
advance the item as per usual.

Note: Stockrotation falls outside of the normal branch transfer limits and so we
pass 'ignore_limits' in the call to request_transfer.

=cut

sub advance {
    my ($self)         = @_;
    my $item           = $self->itemnumber;
    my $current_branch = $item->holdingbranch;
    my $transfer;

    # Find and interpret our stage
    my $stage = $self->stage;
    my $new_stage;
    if ( $self->indemand && !$self->fresh ) {
        $self->indemand(0)->store;                          # De-activate indemand
        $new_stage = $stage;
    }
    else {
        # New to rota?
        if ( $self->fresh ) {
            $new_stage = $self->stage->first_sibling || $self->stage;
            $self->fresh(0)->store;                         # Reset fresh
        }
        # Last stage?
        elsif ( !$stage->last_sibling ) {
            # Cyclical rota?
            if ( $stage->rota->cyclical ) {
                $new_stage =
                  $stage->first_sibling || $stage;           # Revert to first stage.
            }
            else {
                $self->delete;                               # StockRotationItem is done.
                return 1;
            }
        }
        else {
            $new_stage = $self->stage->next_sibling;         # Just advance
        }
    }

    # Update stage and record transfer
    $self->stage_id( $new_stage->stage_id )->store;          # Set new stage
    $item->homebranch( $new_stage->branchcode_id )->store;   # Update homebranch
    $transfer = try {
        $item->request_transfer(
            {
                to            => $new_stage->branchcode,
                reason        => "StockrotationAdvance",
                ignore_limits => 1                      # Ignore transfer limits
            }
        );                                              # Add transfer
    }
    catch {
        if ( $_->isa('Koha::Exceptions::Item::Transfer::Found') ) {
            my $exception = $_;
            my $found_transfer = $_->transfer;
            if (   $found_transfer->in_transit
                || $found_transfer->reason eq 'Reserve' )
            {
                return $item->request_transfer(
                    {
                        to            => $new_stage->branchcode,
                        reason        => "StockrotationAdvance",
                        ignore_limits => 1,
                        enqueue       => 1
                    }
                );                                      # Queue transfer
            } else {
                return $item->request_transfer(
                    {
                        to            => $new_stage->branchcode,
                        reason        => "StockrotationAdvance",
                        ignore_limits => 1,
                        replace       => 1
                    }
                );                                      # Replace transfer
            }
        } else {
            $_->rethrow();
        }
    };
    $transfer->receive
      if $item->holdingbranch eq $new_stage->branchcode_id;  # Already at branch

    return $transfer;
}

=head3 investigate

  my $report = $item->investigate;

Return the base set of information, namely this individual item's report, for
generating stockrotation reports about this stockrotationitem.

=cut

sub investigate {
    my ( $self ) = @_;
    my $item_report = {
        title      => $self->itemnumber->_result->biblioitem
            ->biblionumber->title,
        author     => $self->itemnumber->_result->biblioitem
            ->biblionumber->author,
        callnumber => $self->itemnumber->itemcallnumber,
        location   => $self->itemnumber->location,
        onloan     => $self->itemnumber->onloan,
        barcode    => $self->itemnumber->barcode,
        itemnumber => $self->itemnumber_id,
        branch => $self->itemnumber->_result->holdingbranch,
        object => $self,
    };
    my $reason;
    if ( $self->fresh ) {
        $reason = 'initiation';
    } elsif ( $self->needs_repatriating ) {
        $reason = 'repatriation';
    } elsif ( $self->needs_advancing ) {
        $reason = 'advancement';
        $reason = 'in-demand' if $self->indemand;
    } else {
        $reason = 'not-ready';
    }
    $item_report->{reason} = $reason;

    return $item_report;
}

1;

=head1 AUTHOR

Alex Sassmannshausen <alex.sassmannshausen@ptfs-europe.com>

=cut
