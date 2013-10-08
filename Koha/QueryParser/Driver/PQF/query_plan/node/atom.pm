package Koha::QueryParser::Driver::PQF::query_plan::node::atom;

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

use base 'OpenILS::QueryParser::query_plan::node::atom';

use strict;
use warnings;

=head1 NAME

Koha::QueryParser::Driver::PQF::query_plan::node::atom - atom subclass for PQF driver

=head1 FUNCTIONS

=head2 Koha::QueryParser::Driver::PQF::query_plan::node::atom::target_syntax

    my $pqf = $atom->target_syntax($server);

Transforms an OpenILS::QueryParser::query_plan::node::atom object into PQF. Do not use
directly.

=cut

sub target_syntax {
    my ($self, $server) = @_;

    my $content = $self->content;
    $content =~ s/"/\\"/g;

    return ' "' .  $content . '" ';
}

1;
