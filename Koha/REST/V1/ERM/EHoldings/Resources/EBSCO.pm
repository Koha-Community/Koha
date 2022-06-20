package Koha::REST::V1::ERM::EHoldings::Resources::EBSCO;

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
use Try::Tiny;

=head1 API

=head2 Methods

=head3 list

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {

        my $args = $c->validation->output;

  # FIXME Do we need more validation here? Don't think so we have the API specs.
        my ( $vendor_id, $package_id ) = split '-',
          $c->validation->param('package_id') || q{};
        my $title_id = $c->validation->param('title_id') || q{};

        my $url =
          $title_id
          ? sprintf '/titles/%s', $title_id
          : sprintf '/vendors/%s/packages/%s/titles', $vendor_id, $package_id;

        my $params =
          '?orderby=titlename&offset=1&count=1&searchfield=titlename';
        my $result;
        try {
            $result =
              Koha::ERM::Providers::EBSCO->request( GET => $url . $params );
        }
        catch {
            if ( blessed $_ ) {
                if ( $_->isa('Koha::Exceptions::ObjectNotFound') ) {
                    return $c->render(
                        status  => 404,
                        openapi => { error => $_->error }
                    );

                }
            }

            $c->unhandled_exception($_);
        };

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
        my $searchfield = 'titlename';

        $params =
          sprintf '?orderby=titlename&offset=%s&count=%s&searchfield=%s',
          $page, $per_page, $searchfield;
        $result = Koha::ERM::Providers::EBSCO->request(
            GET => $url . $params,
            $additional_params
        );

        my @resources;
        for my $t ( @{ $result->{titles} } ) {
            my $r =
              $t->{customerResourcesList}->[0];   # FIXME What about the others?
            my $resource = {
                resource_id => $r->{vendorId} . '-'
                  . $r->{packageId} . '-'
                  . $r->{titleId},
                package_id  => $r->{vendorId} . '-' . $r->{packageId},
                title_id    => $r->{titleId},
                is_selected => $r->{isSelected},
                started_on  => $r->{managedCoverageList}->[0]->{beginCoverage},
                ended_on    => $r->{managedCoverageList}->[0]->{endCoverage},
            };
            my $embed_header = $c->req->headers->header('x-koha-embed') || q{};
            foreach my $embed_req ( split /\s*,\s*/, $embed_header ) {
                if ( $embed_req eq 'title.publication_title' ) {
                    $resource->{title} = {
                        publication_title => $t->{titleName},
                        publisher_name    => $t->{publisherName},
                        publication_type  => $t->{pubType},
                    };
                }
                elsif ( $embed_req eq 'package.name' ) {
                    $resource->{package} = { name => $t->{packageName}, };
                }

            }
            push @resources, $resource;
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
        return $c->render( status => 200, openapi => \@resources );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 get

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my ( $vendor_id, $package_id, $resource_id ) = split '-',
          $c->validation->param('resource_id');
        my $t;
        try {
            $t =
              Koha::ERM::Providers::EBSCO->request( GET => '/vendors/'
                  . $vendor_id
                  . '/packages/'
                  . $package_id
                  . '/titles/'
                  . $resource_id );

        }
        catch {
            if ( blessed $_ ) {
                if ( $_->isa('Koha::Exceptions::ObjectNotFound') ) {
                    return $c->render(
                        status  => 404,
                        openapi => { error => $_->error }
                    );

                }
            }

            $c->unhandled_exception($_);
        };

        unless ($t) {
            return $c->render(
                status  => 404,
                openapi => { error => "Resource not found" }
            );
        }

        my $r = $t->{customerResourcesList}->[0]; # FIXME What about the others?
        my $resource = {
            resource_id => $r->{vendorId} . '-'
              . $r->{packageId} . '-'
              . $r->{titleId},
            package_id => $r->{vendorId} . '-' . $r->{packageId},
            title_id   => $r->{titleId},
            started_on => $r->{managedCoverageList}->[0]->{beginCoverage},
            ended_on   => $r->{managedCoverageList}->[0]->{endCoverage},
        };

        my $embed_header = $c->req->headers->header('x-koha-embed') || q{};
        foreach my $embed_req ( split /\s*,\s*/, $embed_header ) {
            if ( $embed_req eq 'title' ) {
                $resource->{title} = {
                    publication_title => $t->{titleName},
                    publisher_name    => $t->{publisherName},
                    publication_type  => $t->{pubType},
                };
                for my $identifier ( @{ $t->{identifiersList} } ) {

                    # FIXME $identifier->{type} : 0 for ISSN and 1 for ISBN
                    if ( $identifier->{subtype} == 1 ) {
                        $resource->{title}->{print_identifier} =
                          $identifier->{id};
                    }
                    elsif ( $identifier->{subtype} == 1 ) {
                        $resource->{title}->{online_identifier} =
                          $identifier->{id};
                    }
                }
            }
            elsif ( $embed_req eq 'package' ) {
                $resource->{package} = {

                    #content_type => $e->{contentType}, FIXME We don't have that
                    name         => $r->{packageName},
                    package_id   => $r->{vendorId} . '-' . $r->{packageId},
                    package_type => $r->{packageType},
                    vendor_id    => $r->{vendorId},
                };
            }
            elsif ( $embed_req eq 'vendor' ) {
                $resource->{vendor} = {
                    name         => $r->{vendorName},
                    id           => $r->{vendorId},
                    package_type => $r->{packageType},
                };
            }
        }

        return $c->render(
            status  => 200,
            openapi => $resource,
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

1;
