package Koha::StockRotationStages;

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
use Koha::StockRotationStage;

use base qw(Koha::Objects);

=head1 NAME

StockRotationStages - Koha StockRotationStages Object class

=head1 SYNOPSIS

StockRotationStages class used primarily by stockrotation .pls and the stock
rotation cron script.

=head1 DESCRIPTION

Standard Koha::Objects definitions, and additional methods.

=head1 API

=head2 Class Methods

=cut

=head3 investigate

  my $report = $stages->investigate($rota_so_far);

Return a report detailing the current status and required actions for all
relevant items spread over the set of stages.

For details of intent and context of this procedure, please see
Koha::StockRotationRota->investigate.

=cut

sub investigate {
    my ( $self, $report ) = @_;

    while ( my $stage = $self->next ) {
        $report = $stage->investigate($report);
    }

    return $report;
}

=head3 _type

=cut

sub _type {
    return 'Stockrotationstage';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::StockRotationStage';
}

1;

=head1 AUTHOR

Alex Sassmannshausen <alex.sassmannshausen@ptfs-europe.com>

=cut
