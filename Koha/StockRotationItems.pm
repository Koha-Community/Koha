package Koha::StockRotationItems;

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
use Koha::StockRotationItem;

use base qw(Koha::Objects);

=head1 NAME

StockRotationItems - Koha StockRotationItems Object class

=head1 SYNOPSIS

StockRotationItems class used primarily by stockrotation .pls and the stock
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

=head3 object_class

=cut

sub object_class {
    return 'Koha::StockRotationItem';
}

=head3 investigate

  my $report = $items->investigate;

Return a stockrotation report about this set of stockrotationitems.

In this part of the overall investigation process we split individual item
reports into appropriate action segments of our items report and increment
some counters.

The report generated here will be used on the stage level to slot our item
reports into appropriate sections of the branched report.

For details of intent and context of this procedure, please see
Koha::StockRotationRota->investigate.

=cut

sub investigate {
    my ( $self ) = @_;

    my $items_report = {
        items => [],
        log => [],
        initiable_items => [],
        repatriable_items => [],
        advanceable_items => [],
        indemand_items => [],
        actionable => 0,
        stationary => 0,
    };
    while ( my $item = $self->next ) {
        my $report = $item->investigate;
        if ( $report->{reason} eq 'initiation' ) {
            $items_report->{initiable}++;
            $items_report->{actionable}++;
            push @{$items_report->{items}}, $report;
            push @{$items_report->{initiable_items}}, $report;
        } elsif ( $report->{reason} eq 'repatriation' ) {
            $items_report->{repatriable}++;
            $items_report->{actionable}++;
            push @{$items_report->{items}}, $report;
            push @{$items_report->{repatriable_items}}, $report;
        } elsif ( $report->{reason} eq 'advancement' ) {
            $items_report->{actionable}++;
            push @{$items_report->{items}}, $report;
            push @{$items_report->{advanceable_items}}, $report;
        } elsif ( $report->{reason} eq 'in-demand' ) {
            $items_report->{actionable}++;
            push @{$items_report->{items}}, $report;
            push @{$items_report->{indemand_items}}, $report;
        } else {
            $items_report->{stationary}++;
            push @{$items_report->{log}}, $report;
        }
    }

    return $items_report;
}

1;

=head1 AUTHOR

Alex Sassmannshausen <alex.sassmannshausen@ptfs-europe.com>

=cut
