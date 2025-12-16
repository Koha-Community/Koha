package C4::XISBN;

# Copyright (C) 2007 LibLime
# Joshua Ferraro <jmf@liblime.com>
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

use Modern::Perl;
use base 'Exporter';

BEGIN {
    our @EXPORT_OK = qw(
        get_xisbns
    );
}

use XML::Simple;

use C4::Biblio              qw(TransformMarcToKoha);
use C4::Koha                qw( GetNormalizedISBN );
use C4::Search              qw( new_record_from_zebra );
use C4::External::Syndetics qw( get_syndetics_editions );
use LWP::UserAgent;

use Koha::Biblios;
use Koha::SearchEngine;
use Koha::SearchEngine::Search;

=head1 NAME

C4::XISBN - Functions for retrieving XISBN content in Koha

=head1 FUNCTIONS

This module provides facilities for retrieving ThingISBN and XISBN content in Koha

=cut

sub _get_biblio_from_xisbn {
    my $xisbn = shift;

    my $searcher = Koha::SearchEngine::Search->new( { index => $Koha::SearchEngine::BIBLIOS_INDEX } );
    my ( $errors, $results, $total_hits ) = $searcher->simple_search_compat( "nb=$xisbn", 0, 1 );
    return unless ( !$errors && scalar @$results );

    my $record       = C4::Search::new_record_from_zebra( 'biblioserver', $results->[0] );
    my $biblionumber = C4::Biblio::TransformMarcToKoha(
        {
            kohafields => ['biblio.biblionumber'],
            record     => $record
        }
    )->{biblionumber};
    return unless $biblionumber;

    my $biblio = Koha::Biblios->find($biblionumber);
    return unless $biblio;
    my $isbn = $biblio->biblioitem->isbn;
    $biblio = $biblio->unblessed;
    $biblio->{normalized_isbn} = GetNormalizedISBN($isbn);
    return $biblio;
}

=head1 get_xisbns($isbn, $biblionumber);

=head2 $isbn is an ISBN string

=cut

=head2 get_xisbns

Missing POD for get_xisbns.

=cut

sub get_xisbns {
    my ( $isbn, $biblionumber ) = @_;
    my ( $response, $thing_response, $syndetics_response, $errors );

    # THINGISBN
    if ( C4::Context->preference('ThingISBN') ) {
        my $url = "http://www.librarything.com/api/thingISBN/" . $isbn;
        $thing_response = _get_url( $url, 'thingisbn' );
    }

    if ( C4::Context->preference("SyndeticsEnabled") && C4::Context->preference("SyndeticsEditions") ) {
        my $syndetics_preresponse = &get_syndetics_editions($isbn);
        my @syndetics_response;
        for my $response (@$syndetics_preresponse) {
            push @syndetics_response, { content => $response->{a} };
        }
        $syndetics_response = { isbn => \@syndetics_response };
    }

    $response->{isbn} = [ @{ $syndetics_response->{isbn} or [] }, @{ $thing_response->{isbn} or [] } ];
    my @xisbns;
    my $unique_xisbns;    # a hashref

    # loop through each ISBN and scope to the local collection
    for my $response_data ( @{ $response->{isbn} } ) {
        next if $unique_xisbns->{ $response_data->{content} };
        $unique_xisbns->{ $response_data->{content} }++;
        my $xbiblio = _get_biblio_from_xisbn( $response_data->{content} );
        next unless $xbiblio;
        push @xisbns, $xbiblio if $xbiblio && $xbiblio->{biblionumber} ne $biblionumber;
    }
    if (wantarray) {
        return ( \@xisbns, $errors );
    } else {
        return \@xisbns;
    }
}

sub _get_url {
    my ( $url, $service_type ) = @_;
    my $ua = LWP::UserAgent->new( timeout => 2 );

    my $response = $ua->get($url);
    if ( $response->is_success ) {
        warn "WARNING could not retrieve $service_type $url" unless $response;
        if ($response) {
            my $xmlsimple = XML::Simple->new();
            my $content   = $xmlsimple->XMLin(
                $response->content,
                ForceArray   => [qw(isbn)],
                ForceContent => 1,
            );
            return $content;
        }
    } else {
        warn "WARNING: URL Request Failed " . $response->status_line . "\n";
    }

}

1;
__END__

=head1 NOTES

=cut

=head1 AUTHOR

Joshua Ferraro <jmf@liblime.com>

=cut

