package Koha::StockRotationRota;

# Copyright PTFS Europe 2016
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

use Modern::Perl;

use Koha::Database;
use Koha::StockRotationStages;
use Koha::StockRotationItem;
use Koha::StockRotationItems;

use base qw(Koha::Object);

=head1 NAME

StockRotationRota - Koha StockRotationRota Object class

=head1 SYNOPSIS

StockRotationRota class used primarily by stockrotation .pls and the stock
rotation cron script.

=head1 DESCRIPTION

Standard Koha::Objects definitions, and additional methods.

=head1 API

=head2 Class Methods

=cut

=head3 stockrotationstages

  my $stages = Koha::StockRotationRota->stockrotationstages;

Returns the stages associated with the current rota.

=cut

sub stockrotationstages {
    my ( $self ) = @_;
    my $rs = $self->_result->stockrotationstages;
    return Koha::StockRotationStages->_new_from_dbic( $rs );
}

=head3 add_item

  my $rota = $rota->add_item($itemnumber);

Add item identified by $ITEMNUMBER to this rota, which means we associate it
with the first stage of this rota.  Should the item already be associated with
a rota, move it from that rota to this rota.

=cut

sub add_item {
    my ( $self, $itemnumber ) = @_;
    my $sritem = Koha::StockRotationItems->find($itemnumber);
    if ($sritem) {
        $sritem->stage_id($self->first_stage->stage_id)
            ->indemand(0)->fresh(1)->store;
    } else {
        $sritem = Koha::StockRotationItem->new({
            itemnumber_id => $itemnumber,
            stage_id      => $self->first_stage->stage_id,
            indemand      => 0,
            fresh         => 1,
        })->store;
    }
    return $self;
}

=head3 first_stage

  my $stage = $rota->first_stage;

Return the first stage attached to this rota (the one that has an undefined
`stagebefore`).

=cut

sub first_stage {
    my ( $self ) = @_;
    my $guess = $self->stockrotationstages->next;
    my $stage = $guess->first_sibling;
    return ( $stage ) ? $stage : $guess;
}

=head3 stockrotationitems

  my $items = $rota->stockrotationitems;

Return all items associated with this rota via its stages.

=cut

sub stockrotationitems {
    my ( $self ) = @_;
    my $rs = Koha::StockRotationItems->search(
        { 'stage.rota_id' => $self->rota_id }, { join =>  [ qw/stage/ ] }
    );
    return $rs;
}

=head3 investigate

  my $report = $rota->investigate($report_so_far);

Aim here is to return $report augmented with content for this rota.  We
delegate to $stage->investigate.

The report will include some basic information and 2 primary reports:

- per rota report in 'rotas'. This report is mainly used by admins to do check
  & compare results.

- branched report in 'branched'.  This is the workhorse: emails to libraries
  are compiled from these reports, and they will have the actionable work.

Both reports are generated in stage based investigations; the rota report is
then glued into place at this stage.

=cut

sub investigate {
    my ( $self, $report ) = @_;
    my $count = $self->stockrotationitems->count;
    $report->{sum_items} += $count;

    if ( $self->active ) {
        $report->{rotas_active}++;
        # stockrotationstages->investigate augments $report with the stage's
        # content.  This is how 'branched' slowly accumulates all items.
        $report = $self->stockrotationstages->investigate($report);
        # Add our rota report to the full report.
        push @{$report->{rotas}}, {
            name  => $self->title,
            id    => $self->rota_id,
            items => $report->{tmp_items} || [],
            log   => $report->{tmp_log} || [],
        };
        delete $report->{tmp_items};
        delete $report->{tmp_log};
    } else {                    # Rota is not active.
        $report->{rotas_inactive}++;
        $report->{items_inactive} += $count;
    }

    return $report;
}

=head3 _type

=cut

sub _type {
    return 'Stockrotationrota';
}

1;

=head1 AUTHOR

Alex Sassmannshausen <alex.sassmannshausen@ptfs-europe.com>

=cut
