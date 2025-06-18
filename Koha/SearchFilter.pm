package Koha::SearchFilter;

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
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use JSON qw( encode_json decode_json );

use Koha::Database;

use base qw(Koha::Object);

=head1 NAME

Koha::SearchFilter - Koha Search filter object class

=head1 API

=head2 Class methods

=head3 expand_filter

    my ($expanded_limit, $query_limit) = $filter->expand_filter;

    Returns the filter as an arrayref of limit queries, and the query parts combined
    into a string suitable to be passed to QueryBuilder

=cut

sub expand_filter {
    my $self = shift;

    my $query_part  = $self->query;
    my $limits_part = $self->limits;

    my $limits = decode_json($limits_part)->{limits};

    my $query     = decode_json($query_part);
    my $operators = $query->{operators};
    my $operands  = $query->{operands};
    my $indexes   = $query->{indexes};

    my $query_limit = "";
    for ( my $i = 0 ; $i < scalar @$operands ; $i++ ) {
        next unless @$operands[$i];
        my $index    = @$indexes[$i] ? @$indexes[$i] . "=" : "";
        my $query    = "(" . @$operands[$i] . ")";
        my $operator = "";
        $operator = @$operators[ $i - 1 ] ? " " . @$operators[ $i - 1 ] . " " : scalar @$operands > $i ? " AND " : ""
            if $i > 0;
        my $limit = $operator . $index . $query;
        $query_limit .= $limit;
    }
    $query_limit = "(" . $query_limit . ")" if $query_limit;

    return ( $limits, $query_limit );
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'SearchFilter';
}

1;
