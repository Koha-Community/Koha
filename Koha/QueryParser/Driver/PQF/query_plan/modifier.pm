package Koha::QueryParser::Driver::PQF::query_plan::modifier;

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

use base 'OpenILS::QueryParser::query_plan::modifier';

use strict;
use warnings;

=head1 NAME

Koha::QueryParser::Driver::PQF::query_plan::modifer - modifier subclass for PQF driver

=head1 FUNCTIONS

=head2 Koha::QueryParser::Driver::PQF::query_plan::modifier::target_syntax

    my $pqf = $modifier->target_syntax($server, $query_plan);

Transforms an OpenILS::QueryParser::query_plan::modifier object into PQF. Do not use
directly. The second argument points ot the query_plan, since modifiers do
not have a reference to their parent query_plan.

=cut

sub target_syntax {
    my ($self, $server, $query_plan) = @_;
    my $pqf = '';

    my $attributes = $query_plan->QueryParser->bib1_mapping_by_name('modifier', $self->name, $server);
    $pqf = ($attributes->{'op'} ? $attributes->{'op'} . ' ' : '') . ($self->negate ? '@not @attr 1=_ALLRECORDS @attr 2=103 "" ' : '') . $attributes->{'attr_string'};
    return $pqf;
}

1;
