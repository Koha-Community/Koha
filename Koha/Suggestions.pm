package Koha::Suggestions;

# Copyright ByWater Solutions 2015
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


use Koha::Database;
use Koha::DateUtils qw(dt_from_string);
use Koha::Suggestion;

use base qw(Koha::Objects);

=head1 NAME

Koha::Suggestions - Koha Suggestion object set class

=head1 API

=head2 Class methods

=head3 search_limited

    my $suggestions = Koha::Suggestions->search_limited( $params, $attributes );

Returns all the suggestions the logged in user is allowed to see.

=cut

sub search_limited {
    my ( $self, $params, $attributes ) = @_;

    my $resultset = $self;

    # filter on user branch
    if (   C4::Context->preference('IndependentBranches')
        && !C4::Context->IsSuperLibrarian() )
    {
        # If IndependentBranches is set and the logged in user is not superlibrarian
        # Then we want to filter by the user's library (i.e. cannot see suggestions
        # from other libraries)
        my $userenv = C4::Context->userenv;

        $resultset = $self->search({ 'me.branchcode' => $userenv->{branch} })
            if $userenv && $userenv->{branch};
    }

    return $resultset->search( $params, $attributes);
}

=head3 filter_by_pending

    my $open = $suggestions->filter_by_pending;

Filters the resultset on those that are considered pending (i.e. STATUS = ASKED).

=cut

sub filter_by_pending {
    my ($self) = @_;

    return $self->search( { STATUS => 'ASKED' } );
}

=head3 filter_by_suggested_days_range

    my $suggestions = $suggestions->filter_by_suggested_days_range( $days );

Filters the resultset on those placed within some I<$days> range.

=cut

sub filter_by_suggested_days_range {
    my ( $self, $days ) = @_;

    my $dtf = Koha::Database->new->schema->storage->datetime_parser;

    return $self->search(
        { suggesteddate => { '>=' => $dtf->format_date( dt_from_string->subtract( days => $days ) ) } } );
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'Suggestion';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::Suggestion';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
