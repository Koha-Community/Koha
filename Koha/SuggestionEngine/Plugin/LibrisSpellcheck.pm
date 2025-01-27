package Koha::SuggestionEngine::Plugin::LibrisSpellcheck;

# Copyright (C) 2015 Eivin Giske Skaaren
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
use LWP::UserAgent;
use XML::Simple qw( XMLin );
use C4::Context;
use base qw(Koha::SuggestionEngine::Base);

sub NAME {
    return 'LibrisSpellcheck';
}

sub get_suggestions {
    my ( $self, $query ) = @_;
    my $key      = C4::Context->preference('LibrisKey');
    my $base     = C4::Context->preference('LibrisURL');
    my $search   = $query->{'search'};
    my $response = LWP::UserAgent->new->get( $base . "spell?query={$search}&key=$key" );
    my $xml      = XMLin( $response->content, NoAttr => 1, ForceArray => qr/term/ );

    my @terms;
    my $label;

    if ( $xml->{suggestion}->{term} ) {
        for ( @{ $xml->{suggestion}->{term} } ) {
            push @terms, $_;
        }
        $label = join( ' ', @terms );
    } else {
        return;    # No result from LIBRIS
    }

    my @results;
    push @results,
        {
        'search'  => $label,    #$thissearch,
        relevance => 100,

        # FIXME: it'd be nice to have some empirical measure of
        #        "relevance" in this case, but we don't.
        label => $label
        };
    return \@results;
}

1;
__END__

=head1 NAME

Koha::SuggestionEngine::Plugin::LibrisSpellcheck

=head2 FUNCTIONS

This module provides facilities for using the LIBRIS spell checker API

=over

=item NAME

my $name = $plugin->NAME;

=back

=over

=item get_suggestions(query)

Sends in the search query and gets an XML with a suggestion

my $suggestions = $plugin->get_suggestions(\%query);

=back

=cut

=head1 NOTES

=cut

=head1 AUTHOR

Eivin Giske Skaaren <eskaaren@yahoo.no>

=cut
