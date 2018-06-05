package Koha::SearchEngine::Zebra::Search;

# This file is part of Koha.
#
# Copyright 2012 BibLibre
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

use base qw(Class::Accessor);

use C4::Search; # :(
use C4::AuthoritiesMarc;
use Koha::SearchEngine::Search;

=head1 NAME

Koha::SearchEngine::Zebra::Search - Search implementation for Zebra

=head1 METHODS

=head2 search

=cut

sub search {
    my ($self,$query_string) = @_;

     my $query = Data::SearchEngine::Query->new(
       count => 10,
       page => 1,
       query => $query_string,
     );

    my $results = $self->searchengine->search($query);

    foreach my $item (@{ $results->items }) {
        my $title = $item->get_value('ste_title');
        #utf8::encode($title);
        print "$title\n";
    }
}

=head2 search_compat

This passes straight through to C4::Search::getRecords.

=cut

sub search_compat {
    shift; # get rid of $self

    return getRecords(@_);
}

=head2 simple_search_compat

This passes straight through to C4::Search::SimpleSearch.

=cut


sub simple_search_compat {
    shift;
    return C4::Search::SimpleSearch(@_);
}

=head2 extract_biblionumber

    my $biblionumber = $searcher->extract_biblionumber( $searchresult );

$searchresult comes from simple_search_compat.

Returns the biblionumber from the search result record.

=cut

sub extract_biblionumber {
    my ( $self, $searchresultrecord ) = @_;
    my $record = C4::Search::new_record_from_zebra( 'biblioserver', $searchresultrecord );
    return Koha::SearchEngine::Search::extract_biblionumber( $record );
}

=head2 search_auth_compat

This passes the search query on to C4::AuthoritiesMarc::SearchAuthorities

=cut

sub search_auth_compat {
    my ( $self, $q, $startfrom, $resperpage ) = @_;

    my @params = (
        @{$q}{ 'marclist', 'and_or', 'excluding', 'operator', 'value' },
        $startfrom - 1,
        $resperpage, @{$q}{ 'authtypecode', 'orderby' }
    );
    C4::AuthoritiesMarc::SearchAuthorities(@params);
}

sub max_result_window { undef }

1;
