package Koha::SearchEngine::Search;

# This file is part of Koha.
#
# Copyright 2015 Catalyst IT
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

# This is a shim that gives you the appropriate search object for your
# system preference.

=head1 NAME

Koha::SearchEngine::Search - instantiate the search object that corresponds to
the C<SearchEngine> system preference.

=head1 DESCRIPTION

This allows you to be agnostic about what the search engine configuration is
and just get whatever search object you need.

=head1 SYNOPSIS

    use Koha::SearchEngine::Search;
    my $searcher = Koha::SearchEngine::Search->new();

=head1 METHODS

=head2 new

Creates a new C<Search> of whatever the relevant type is.

=cut

use Modern::Perl;
use C4::Context;
use C4::Biblio;
use POSIX qw( ceil );

sub new {
    my $engine = C4::Context->preference("SearchEngine") // 'Zebra';
    my $file = "Koha/SearchEngine/${engine}/Search.pm";
    my $class = "Koha::SearchEngine::${engine}::Search";
    require $file;
    shift @_;
    return $class->new(@_);
}

=head2 extract_biblionumber

    my $biblionumber = $searcher->extract_biblionumber( $marc );

Returns the biblionumber from $marc. The routine is called from the
extract_biblionumber method of the specific search engine.

=cut

sub extract_biblionumber {
    my ( $record ) = @_;
    return if ref($record) ne 'MARC::Record';
    my ( $biblionumbertagfield, $biblionumbertagsubfield ) = C4::Biblio::GetMarcFromKohaField( 'biblio.biblionumber' );
    if( $biblionumbertagfield < 10 ) {
        my $controlfield = $record->field( $biblionumbertagfield );
        return $controlfield ? $controlfield->data : undef;
    }
    return $record->subfield( $biblionumbertagfield, $biblionumbertagsubfield );
}

=head2 pagination_bar

my ( $PAGE_NUMBERS, $hits_to_paginate, $pages, $current_page_number,
    $previous_page_offset, $next_page_offset, $last_page_offset ) = Koha::SearchEngine::Search->pagination_bar(
    {
        hits              => $hits,
        max_result_window => $max_result_window,
        results_per_page  => $results_per_page,
        offset            => $offset,
        sort_by           => \@sort_by
    }
  );

Returns the variables needed for the page-nubers.inc to build search results

=cut

sub pagination_bar {
    my ( $self, $params ) = @_;
    my $hits             = $params->{hits};
    my $results_per_page = $params->{results_per_page};
    my $offset           = $params->{offset};
    my $sort_by          = $params->{sort_by};
    my @page_numbers;
    my $max_result_window = $params->{max_result_window};
    my $hits_to_paginate =
      ( $max_result_window && $max_result_window < $hits )
      ? $max_result_window
      : $hits;

    # total number of pages there will be
    my $pages            = ceil( $hits_to_paginate / $results_per_page );
    my $last_page_offset = ( $pages - 1 ) * $results_per_page;

    # default page number
    my $current_page_number = 1;
    $current_page_number = ( $offset / $results_per_page + 1 ) if $offset;
    my $previous_page_offset;
    if ( $offset >= $results_per_page ) {
        $previous_page_offset = $offset - $results_per_page;
    }
    my $next_page_offset = $offset + $results_per_page;

    # If we're within the first 10 pages, keep it simple
    if ( $current_page_number < 10 ) {

        # just show the first 10 pages
        # Loop through the pages
        my $pages_to_show = 10;
        $pages_to_show = $pages if $pages < 10;
        for ( my $i = 1 ; $i <= $pages_to_show ; $i++ ) {

            # the offset for this page
            my $this_offset =
              ( ( $i * $results_per_page ) - $results_per_page );

            # the page number for this page
            my $this_page_number = $i;

            # put it in the array
            push @page_numbers, {
                offset => $this_offset,
                pg     => $this_page_number,

                # it should only be highlighted if it's the current page
                highlight => $this_page_number == $current_page_number,
                sort_by   => join ' ',
                @$sort_by
            };
        }
    }

    # now, show up to twenty pages, with the current one smack in the middle
    # near the end of search results we will show 10 below and as many remaining above
    else {
        for (
            my $i = $current_page_number ;
            $i <= ( $current_page_number + 19 ) ;
            $i++
          )
        {
            my $this_offset =
              ( ( ( $i - 9 ) * $results_per_page ) - $results_per_page );
            my $this_page_number = $i - 9;
            if ( $this_page_number <= $pages ) {
                push @page_numbers,
                  {
                    offset    => $this_offset,
                    pg        => $this_page_number,
                    highlight => $this_page_number == $current_page_number,
                    sort_by   => join ' ',
                    @$sort_by
                  };
            }
        }
    }

    return ( \@page_numbers, $hits_to_paginate, $pages, $current_page_number,
        $previous_page_offset, $next_page_offset, $last_page_offset );

}

1;
