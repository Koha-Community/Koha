package Koha::REST::V1::Illrequests;

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

use Mojo::Base 'Mojolicious::Controller';

use Koha::Illrequests;
use Koha::Libraries;

=head1 NAME

Koha::REST::V1::Illrequests

=head2 Operations

=head3 list

Return a list of ILL requests, after applying filters.

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    my $args = $c->req->params->to_hash // {};
    my $filter;
    my $output = [];

    # Create a hash where all keys are embedded values
    # Enables easy checking
    my %embed;
    if (defined $args->{embed}) {
        %embed = map { $_ => 1 }  @{$args->{embed}};
        delete $args->{embed};
    }

    for my $filter_param ( keys %$args ) {
        my @values = split(/,/, $args->{$filter_param});
        $filter->{$filter_param} = \@values;
    }

    my $requests = Koha::Illrequests->search($filter);

    if ( scalar (keys %embed) )
    {
        # Need to embed stuff
        my @results = map { $_->TO_JSON(\%embed) } $requests->as_list;
        return $c->render( status => 200, openapi => \@results );
    }
    else
    {
        return $c->render( status => 200, openapi => $requests );
    }
}

1;
