package Koha::SearchEngine::Elasticsearch::Browse;

# Copyright 2015 Catalyst IT
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

=head1 NAME

Koha::SearchEngine::ElasticSearch::Browse - browse functions for Elasticsearch

=head1 SYNOPSIS

    my $browser =
      Koha::SearchEngine::Elasticsearch::Browse->new( { index => 'biblios' } );
    my $results = $browser->browse(
        'prefi', 'title',
        {
            results   => '500',
            fuzziness => 2,
        }
    );
    foreach my $r (@$results) {
        push @hits, $r->{text};
    }

=head1 DESCRIPTION

This provides an easy interface to the "browse" functionality. Essentially,
it does a fast prefix search on defined fields. The fields have to be marked
as "suggestible" in the database when indexing takes place.

=head1 METHODS

=cut

use base qw(Koha::SearchEngine::Elasticsearch);
use Modern::Perl;

=head2 browse

    my $results = $browser->browse($prefix, $field, \%options);

Does a prefix search for C<$prefix>, looking in C<$field>. Options are:

=over 4

=item count

The number of results to return. For Koha browse purposes, this should
probably be fairly high. Defaults to 500.

=item fuzziness

How much allowing for typos and misspellings is done. If 0, then it must match
exactly. If unspecified, it defaults to '1', which is probably the most useful.
Otherwise, it is a number specifying the Levenshtein edit distance relative to
the string length, according to the following lengths:

=over 4

=item 0..2

must match exactly

=item 3..5

C<fuzziness> edits allowed

=item >5

C<fuzziness>+1 edits allowed

=back

In all cases the maximum number of edits allowed is two (an elasticsearch
restriction.)

=back

=head3 Returns

This returns an arrayref of hashrefs. Each hashref contains a "text" element
that contains the field as returned. There may be other fields in that
hashref too, but they're less likely to be important.

The array will be ordered as returned from Elasticsearch, which seems to be
in order of some form of relevance.

=cut

sub browse {
    my ( $self, $prefix, $field, $options ) = @_;

    my $query         = $self->_build_query( $prefix, $field, $options );
    my $elasticsearch = $self->get_elasticsearch();
    my $results       = $elasticsearch->search(
        index => $self->index_name,
        body  => $query
    );

    return $results->{suggest}{suggestions}[0]{options};
}

=head2 _build_query

    my $query = $self->_build_query($prefix, $field, $options);

Arguments are the same as for L<browse>. This will return a query structure
for elasticsearch to use.

=cut

sub _build_query {
    my ( $self, $prefix, $field, $options ) = @_;

    $options = {} unless $options;
    my $f = $options->{fuzziness} // 1;
    my $l = length($prefix);
    my $fuzzie;
    if ( $l <= 2 ) {
        $fuzzie = 0;
    } elsif ( $l <= 5 ) {
        $fuzzie = $f;
    } else {
        $fuzzie = $f + 1;
    }
    $fuzzie = 2 if $fuzzie > 2;

    my $size  = $options->{count} // 500;
    my $query = {

        # this is an annoying thing, if we set size to 0 it gets rewritten
        # to 10. There's a bug somewhere in one of the libraries.
        size    => 1,
        suggest => {
            suggestions => {
                text       => $prefix,
                completion => {
                    field => $field . '__suggestion',
                    size  => $size,
                    fuzzy => {
                        fuzziness => $fuzzie,
                    }
                }
            }
        }
    };
    return $query;
}

1;

__END__

=head1 AUTHOR

=over 4

=item Robin Sheat << <robin@catalyst.net.nz> >>

=back

=cut
