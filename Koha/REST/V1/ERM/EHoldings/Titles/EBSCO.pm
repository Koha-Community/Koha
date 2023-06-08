package Koha::REST::V1::ERM::EHoldings::Titles::EBSCO;

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

use Mojo::Base 'Mojolicious::Controller';

use JSON qw( decode_json );
use Koha::ERM::Providers::EBSCO;

use Scalar::Util qw( blessed );
use Try::Tiny qw( catch try );

=head1 API

=head2 Methods

=head3 list

=cut

sub list {
    my $c = shift or return;

    return try {

        my $args = $c->validation->output;

        my $ebsco = Koha::ERM::Providers::EBSCO->new;

        # We cannot get base_total as a search kw is required by the API

        my ( $per_page, $page ) = $ebsco->build_query_pagination($args);

        my $additional_params = $ebsco->build_additional_params( $c->req->params->to_hash );

        unless ( defined $additional_params->{publication_title} ) {

            # TODO We can add  search on publisher, isxn, [subject or zdbid]
            return $c->render(
                status  => 400,
                openapi => {
                    errors => [
                        {
                            message =>
"A search keyword on publication_title is required"
                        }
                    ]
                }
            );
        }

        my $searchfield = 'titlename';
        my $params =
          sprintf '?orderby=relevance&offset=%s&count=%s&searchfield=%s',
          $page, $per_page, $searchfield;
        my $result =
          $ebsco->request( GET => '/titles' . $params, $additional_params );

        my $embed_header = $c->req->headers->header('x-koha-embed');
        my @titles;
        for my $t ( @{ $result->{titles} } ) {
            my $title = $ebsco->build_title($t);
            $title = $ebsco->embed( $title, $t, $embed_header );
            push @titles, $title;
        }
        my $total = $result->{totalResults};
        $total = 10000 if $total > 10000;

        $c->add_pagination_headers(
            {
               #base_total   => $base_total,
                page         => $page,
                per_page     => $per_page,
                query_params => $args,
                total        => $total,
            }
        );
        return $c->render( status => 200, openapi => \@titles );
    }
    catch {
        if ( blessed $_ ) {
            if ( $_->isa('Koha::Exceptions::Authorization::Unauthorized') ) {
                return $c->render(
                    status  => 401,
                    openapi => {
                        errors => [
                            {
                                message => "Check your ERMProviderEbscoApiKey/ERMProviderEbscoCustomerID system preferences."
                            }
                        ]
                    }
                );
            }
        }
        $c->unhandled_exception($_);
    };
}

=head3 get

=cut

sub get {
    my $c = shift or return;

    return try {
        my $ebsco = Koha::ERM::Providers::EBSCO->new;
        my $t     = $ebsco->request( GET => '/titles/' . $c->param('title_id') );
        unless ($t) {
            return $c->render(
                status  => 404,
                openapi => { error => "Title not found" }
            );
        }

        my $title = $ebsco->build_title($t);
        $title =
          $ebsco->embed( $title, $t, $c->req->headers->header('x-koha-embed') );

        return $c->render(
            status  => 200,
            openapi => $title,
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

1;
