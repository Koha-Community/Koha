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

        my $args   = $c->validation->output;
        my $params = '?orderby=packagename&offset=1&count=1';
        my $result =
          Koha::ERM::Providers::EBSCO->request( GET => '/packages' . $params );
        my $base_total = $result->{totalResults};

        my $per_page = $args->{_per_page}
          // C4::Context->preference('RESTdefaultPageSize') // 20;
        if ( $per_page == -1 || $per_page > 100 ) { $per_page = 100; }
        my $page = $args->{_page} || 1;

        my ( $search, $content_type, $selection_type );
        my $query_params = $c->req->params->to_hash;
        my $additional_params;
        if ( $query_params->{q} ) {
            my $q = decode_json $query_params->{q};
            while ( my ( $attr, $value ) = each %$q ) {
                $additional_params->{$attr} = $value;
            }
        }

        my $orderby = $additional_params->{name} ? 'relevance' : 'packagename';
        $params = sprintf '?orderby=%s&offset=%s&count=%s', $orderby, $page,
          $per_page;
        $result = Koha::ERM::Providers::EBSCO->request(
            GET => '/packages' . $params,
            $additional_params
        );

        my @packages;
        for my $p ( @{ $result->{packagesList} } ) {
            my $package = {
                content_type => $p->{contentType},
                created_on   => undef,
                is_selected  => $p->{isSelected},
                name         => $p->{packageName},
                package_id   => $p->{vendorId} . '-' . $p->{packageId},
                package_type => $p->{packageType},
                vendor_id    => $p->{vendorId},
            };
            my $embed_header = $c->req->headers->header('x-koha-embed') || q{};
            foreach my $embed_req ( split /\s*,\s*/, $embed_header ) {
                if ( $embed_req eq 'vendor.name' ) {
                    $package->{vendor} = { name => $p->{vendorName}, };
                }
                elsif ( $embed_req eq 'resources+count' ) {
                    $package->{resources_count} = $p->{titleCount};
                }
            }
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
        my $p = Koha::ERM::Providers::EBSCO->request(
            GET => '/vendors/' . $vendor_id . '/packages/' . $package_id );
        unless ($p) {
            return $c->render(
                status  => 404,
                openapi => { error => "Package not found" }
            );
        }

        my $package = {
            content_type => $p->{contentType},
            name         => $p->{packageName},
            package_id   => $p->{vendorId} . '-' . $p->{packageId},
            package_type => $p->{packageType},
            vendor_id    => $p->{vendorId},
        };

        my $embed_header = $c->req->headers->header('x-koha-embed') || q{};
        foreach my $embed_req ( split /\s*,\s*/, $embed_header ) {
            if ( $embed_req eq 'vendor' ) {
                $package->{vendor} = {
                    id   => $p->{vendorId},
                    name => $p->{vendorName},
                };
            }
            elsif ( $embed_req eq 'resources+count' ) {
                $package->{resources_count} = $p->{titleCount};
            }
        }

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
