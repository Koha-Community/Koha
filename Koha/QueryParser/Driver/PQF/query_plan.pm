package Koha::QueryParser::Driver::PQF::query_plan;

# This file is part of Koha.
#
# Copyright 2012 C & P Bibliography Services
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

use base 'OpenILS::QueryParser::query_plan';

use strict;
use warnings;

=head1 NAME

Koha::QueryParser::Driver::PQF::query_plan - query_plan subclass for PQF driver

=head1 FUNCTIONS

=head2 Koha::QueryParser::Driver::PQF::query_plan::target_syntax

    my $pqf = $query_plan->target_syntax($server);

Transforms an OpenILS::QueryParser::query_plan object into PQF. Do not use directly.

=cut

sub target_syntax {
    my ($self, $server) = @_;
    my $pqf = '';
    my $node_pqf;
    my $node_count = 0;

    for my $node ( @{$self->query_nodes} ) {

        if (ref($node)) {
            $node_pqf = $node->target_syntax($server);
            $node_count++ if $node_pqf;
            $pqf .= $node_pqf;
        }
    }
    $pqf = ($self->joiner eq '|' ? ' @or ' : ' @and ') x ($node_count - 1) . $pqf;
    $node_count = ($node_count ? '1' : '0');
    for my $node ( @{$self->filters} ) {
        if (ref($node)) {
            $node_pqf = $node->target_syntax($server);
            $node_count++ if $node_pqf;
            $pqf .= $node_pqf;
        }
    }
    $pqf = ($self->joiner eq '|' ? ' @or ' : ' @and ') x ($node_count - 1) . $pqf;
    foreach my $modifier ( @{$self->modifiers} ) {
        my $modifierpqf = $modifier->target_syntax($server, $self);
        $pqf = $modifierpqf . ' ' . $pqf if $modifierpqf;
    }
    return ($self->negate ? '@not @attr 1=_ALLRECORDS @attr 2=103 "" ' : '') . $pqf;
}

1;
