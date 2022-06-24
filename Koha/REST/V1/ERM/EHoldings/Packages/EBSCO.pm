package Koha::REST::V1::ERM::EHoldings::Packages::EBSCO;

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

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {

        my $args       = $c->validation->output;
        my $params     = '?orderby=packagename&offset=1&count=1';
        my $ebsco      = Koha::ERM::Providers::EBSCO->new;
        my $result     = $ebsco->request( GET => '/packages' . $params );
        my $base_total = $result->{totalResults};

        my ( $per_page, $page ) = $ebsco->build_query_pagination($args);
        my $additional_params =
          $ebsco->build_additional_params( $c->req->params->to_hash );

        my $orderby = $additional_params->{name} ? 'relevance' : 'packagename';
        $params = sprintf '?orderby=%s&offset=%s&count=%s', $orderby, $page, $per_page;

        $result = $ebsco->request(
            GET => '/packages' . $params,
            $additional_params
        );

        my @packages;
        for my $p ( @{ $result->{packagesList} } ) {
            my $package = $ebsco->build_package($p);
            $package =
              $ebsco->embed( $package, $p, $c->req->headers->header('x-koha-embed') );
              push @packages, $package;
        }
        my $total = $result->{totalResults};
        $total = 10000 if $total > 10000;

        $c->add_pagination_headers(
            {
                base_total => $base_total,
                total      => $total,
                params     => $args,
            }
        );
        return $c->render( status => 200, openapi => \@packages );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my ( $vendor_id, $package_id ) = split '-',
          $c->validation->param('package_id');
        my $ebsco = Koha::ERM::Providers::EBSCO->new;
        my $p     = $ebsco->request(
            GET => '/vendors/' . $vendor_id . '/packages/' . $package_id );
        unless ($p) {
            return $c->render(
                status  => 404,
                openapi => { error => "Package not found" }
            );
        }

        my $package = $ebsco->build_package($p);

        $package =
          $ebsco->embed( $package, $p,
            $c->req->headers->header('x-koha-embed') );

          return $c->render(
            status  => 200,
            openapi => $package
          );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

1;
