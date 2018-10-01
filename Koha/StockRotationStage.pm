package Koha::StockRotationStage;

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
use Koha::Library;
use Koha::StockRotationRota;

use base qw(Koha::Object);

=head1 NAME

StockRotationStage - Koha StockRotationStage Object class

=head1 SYNOPSIS

StockRotationStage class used primarily by stockrotation .pls and the stock
rotation cron script.

=head1 DESCRIPTION

Standard Koha::Objects definitions, and additional methods.

=head1 API

=head2 Class Methods

=cut

=head3 _type

=cut

sub _type {
    return 'Stockrotationstage';
}

sub _relation {
    my ( $self, $method, $type ) = @_;
    return sub {
        my $rs = $self->_result->$method;
        return 0 if !$rs;
        my $namespace = 'Koha::' . $type;
        return $namespace->_new_from_dbic( $rs );
    }
}

=head3 stockrotationitems

  my $stages = Koha::StockRotationStage->stockrotationitems;

Returns the items associated with the current stage.

=cut

sub stockrotationitems {
    my ( $self ) = @_;
    return &{$self->_relation(qw/ stockrotationitems StockRotationItems /)};
}

=head3 branchcode

  my $branch = Koha::StockRotationStage->branchcode;

Returns the branch associated with the current stage.

=cut

sub branchcode {
    my ( $self ) = @_;
    return &{$self->_relation(qw/ branchcode Library /)};
}

=head3 rota

  my $rota = Koha::StockRotationStage->rota;

Returns the rota associated with the current stage.

=cut

sub rota {
    my ( $self ) = @_;
    return &{$self->_relation(qw/ rota StockRotationRota /)};
}

=head3 siblings

  my $siblings = $stage->siblings;

Koha::Object wrapper around DBIx::Class::Ordered.

=cut

sub siblings {
    my ( $self ) = @_;
    return &{$self->_relation(qw/ siblings StockRotationStages /)};
}

=head3 next_siblings

  my $next_siblings = $stage->next_siblings;

Koha::Object wrapper around DBIx::Class::Ordered.

=cut

sub next_siblings {
    my ( $self ) = @_;
    return &{$self->_relation(qw/ next_siblings StockRotationStages /)};
}

=head3 previous_siblings

  my $previous_siblings = $stage->previous_siblings;

Koha::Object wrapper around DBIx::Class::Ordered.

=cut

sub previous_siblings {
    my ( $self ) = @_;
    return &{$self->_relation(qw/ previous_siblings StockRotationStages /)};
}

=head3 next_sibling

  my $next = $stage->next_sibling;

Koha::Object wrapper around DBIx::Class::Ordered.

=cut

sub next_sibling {
    my ( $self ) = @_;
    return &{$self->_relation(qw/ next_sibling StockRotationStage /)};
}

=head3 previous_sibling

  my $previous = $stage->previous_sibling;

Koha::Object Wrapper around DBIx::Class::Ordered.

=cut

sub previous_sibling {
    my ( $self ) = @_;
    return &{$self->_relation(qw/ previous_sibling StockRotationStage /)};
}

=head3 first_sibling

  my $first = $stage->first_sibling;

Koha::Object Wrapper around DBIx::Class::Ordered.

=cut

sub first_sibling {
    my ( $self ) = @_;
    return &{$self->_relation(qw/ first_sibling StockRotationStage /)};
}

=head3 last_sibling

  my $last = $stage->last_sibling;

Koha::Object Wrapper around DBIx::Class::Ordered.

=cut

sub last_sibling {
    my ( $self ) = @_;
    return &{$self->_relation(qw/ last_sibling StockRotationStage /)};
}

=head3 move_previous

  1|0 = $stage->move_previous;

Koha::Object Wrapper around DBIx::Class::Ordered.

=cut

sub move_previous {
    my ( $self ) = @_;
    return $self->_result->move_previous;
}

=head3 move_next

  1|0 = $stage->move_next;

Koha::Object Wrapper around DBIx::Class::Ordered.

=cut

sub move_next {
    my ( $self ) = @_;
    return $self->_result->move_next;
}

=head3 move_first

  1|0 = $stage->move_first;

Koha::Object Wrapper around DBIx::Class::Ordered.

=cut

sub move_first {
    my ( $self ) = @_;
    return $self->_result->move_first;
}

=head3 move_last

  1|0 = $stage->move_last;

Koha::Object Wrapper around DBIx::Class::Ordered.

=cut

sub move_last {
    my ( $self ) = @_;
    return $self->_result->move_last;
}

=head3 move_to

  1|0 = $stage->move_to($position);

Koha::Object Wrapper around DBIx::Class::Ordered.

=cut

sub move_to {
    my ( $self, $position ) = @_;
    return $self->_result->move_to($position)
        if ( $position le $self->rota->stockrotationstages->count );
    return 0;
}

=head3 move_to_group

  1|0 = $stage->move_to_group($rota_id, [$position]);

Koha::Object Wrapper around DBIx::Class::Ordered.

=cut

sub move_to_group {
    my ( $self, $rota_id, $position ) = @_;
    return $self->_result->move_to_group($rota_id, $position);
}

=head3 delete

  1|0 = $stage->delete;

Koha::Object Wrapper around DBIx::Class::Ordered.

=cut

sub delete {
    my ( $self ) = @_;
    return $self->_result->delete;
}

=head3 investigate

  my $report = $stage->investigate($report_so_far);

Return a stage based report.  This report will mutate and augment the report
that is passed to it.  It slots item reports into the branched and temporary
rota sections of the report.  It also increments a number of counters.

For details of intent and context of this procedure, please see
Koha::StockRotationRota->investigate.

=cut

sub investigate {
    my ( $self, $report ) = @_;
    my $new_stage = $self->next_sibling;
    my $duration = $self->duration;
    # Generate stage items report
    my $items_report = $self->stockrotationitems->investigate;

    # Merge into general report

    ## Branched indexes
    ### The branched indexes work as follows:
    ### - They contain information about the relevant branch
    ### - They contain an index of actionable items for that branch
    ### - They contain an index of non-actionable items for that branch

    ### Items are assigned to a particular branched index as follows:
    ### - 'advanceable' : assigned to branch of the current stage
    ###   (this should also be the current holding branch)
    ### - 'log' items are always assigned to branch of current stage.
    ### - 'indemand' : assigned to branch of current stage
    ###   (this should also be the current holding branch)
    ### - 'initiable' : assigned to the current holding branch of item
    ### - 'repatriable' : assigned to the current holding branch of item

    ### 'Advanceable', 'log', 'indemand':

    # Set up our stage branch info.
    my $stagebranch = $self->_result->branchcode;
    my $stagebranchcode = $stagebranch->branchcode;

    # Initiate our stage branch index if it does not yet exist.
    if ( !$report->{branched}->{$stagebranchcode} ) {
        $report->{branched}->{$stagebranchcode} = {
            code  => $stagebranchcode,
            name  => $stagebranch->branchname,
            email => $stagebranch->branchreplyto
              ? $stagebranch->branchreplyto
              : $stagebranch->branchemail,
            phone => $stagebranch->branchphone,
            items => [],
            log => [],
        };
    }

    push @{$report->{branched}->{$stagebranchcode}->{items}},
        @{$items_report->{advanceable_items}};
    push @{$report->{branched}->{$stagebranchcode}->{log}},
        @{$items_report->{log}};
    push @{$report->{branched}->{$stagebranchcode}->{items}},
        @{$items_report->{indemand_items}};

    ### 'Initiable' & 'Repatriable'
    foreach my $ireport (@{$items_report->{initiable_items}}) {
        my $branch = $ireport->{branch};
        my $branchcode = $branch->branchcode;
        if ( !$report->{branched}->{$branchcode} ) {
            $report->{branched}->{$branchcode} = {
                code  => $branchcode,
                name  => $branch->branchname,
                email => $stagebranch->branchreplyto
                  ? $stagebranch->branchreplyto
                  : $stagebranch->branchemail,
                phone => $branch->branchphone,
                items => [],
                log => [],
            };
        }
        push @{$report->{branched}->{$branchcode}->{items}}, $ireport;
    }

    foreach my $ireport (@{$items_report->{repatriable_items}}) {
        my $branch = $ireport->{branch};
        my $branchcode = $branch->branchcode;
        if ( !$report->{branched}->{$branchcode} ) {
            $report->{branched}->{$branchcode} = {
                code  => $branchcode,
                name  => $branch->branchname,
                email => $stagebranch->branchreplyto
                  ? $stagebranch->branchreplyto
                  : $stagebranch->branchemail,
                phone => $branch->branchphone,
                items => [],
                log => [],
            };
        }
        push @{$report->{branched}->{$branchcode}->{items}}, $ireport;
    }

    ## Per rota indexes
    ### Per rota indexes are item reports pushed into the index for the
    ### current rota.  We don't know where that index is yet as we don't know
    ### about the current rota.  To resolve this we assign our items and log
    ### to tmp indexes.  They will be merged into the proper rota index at the
    ### rota level.
    push @{$report->{tmp_items}}, @{$items_report->{items}};
    push @{$report->{tmp_log}}, @{$items_report->{log}};

    ## Collection of items
    ### Finally we just add our collection of items to the full item index.
    push @{$report->{items}}, @{$items_report->{items}};

    ## Assemble counters
    $report->{actionable} += $items_report->{actionable};
    $report->{indemand} += scalar @{$items_report->{indemand_items}};
    $report->{advanceable} += scalar @{$items_report->{advanceable_items}};
    $report->{initiable} += scalar @{$items_report->{initiable_items}};
    $report->{repatriable} += scalar @{$items_report->{repatriable_items}};
    $report->{stationary} += scalar @{$items_report->{log}};

    return $report;
}

1;

=head1 AUTHOR

Alex Sassmannshausen <alex.sassmannshausen@ptfs-europe.com>

=cut
