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
    my $c = shift or return;

    return try {

        my $ebsco = Koha::ERM::Providers::EBSCO->new;

        # FIXME Do we need more validation here? Don't think so we have the API specs.
        my ( $vendor_id, $package_id ) = split '-',
          $c->param('package_id') || q{};
        my $title_id = $c->param('title_id') || q{};

        my $url =
          $title_id
          ? sprintf '/titles/%s', $title_id
          : sprintf '/vendors/%s/packages/%s/titles', $vendor_id, $package_id;

        my $params =
          '?orderby=titlename&offset=1&count=1&searchfield=titlename';
        my $result;
        try {
            $result =
              $ebsco->request( GET => $url . $params );
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

        my ( $per_page, $page ) = $ebsco->build_query_pagination(
            {
                per_page => $c->stash('koha.pagination.per_page'),
                page     => $c->stash('koha.pagination.page'),
            }
        );

        my $additional_params = $ebsco->build_additional_params( $c->req->params->to_hash );
        my $searchfield = 'titlename';

        $params =
          sprintf '?orderby=titlename&offset=%s&count=%s&searchfield=%s',
          $page, $per_page, $searchfield;

        $result = $ebsco->request(
            GET => $url . $params,
            $additional_params
        );

        my @resources;
        for my $t ( @{ $result->{titles} } ) {
            my $r =
              $t->{customerResourcesList}->[0];   # FIXME What about the others?

            my $resource = $ebsco->build_resource($r);

            $resource = $ebsco->embed( $resource, $t,
                $c->req->headers->header('x-koha-embed') );

            push @resources, $resource;
        }
        my $total = $result->{totalResults};
        $total = 10000 if $total > 10000;
        $c->add_pagination_headers(
            {
                base_total   => $base_total,
                page         => $page,
                per_page     => $per_page,
                total        => $total,
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
    my $c = shift or return;

    return try {
        my ( $vendor_id, $package_id, $resource_id ) = split '-',
          $c->param('resource_id');
        my $ebsco      = Koha::ERM::Providers::EBSCO->new;
        my $t = try {
              return $ebsco->request( GET => '/vendors/'
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
        my $resource = $ebsco->build_resource($r);

        $resource = $ebsco->embed( $resource, {%$t, %$r}, $c->req->headers->header('x-koha-embed') );

        return $c->render(
            status  => 200,
            openapi => $resource,
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 edit

=cut

sub edit {
    my $c = shift or return;

    return try {
        my $body        = $c->req->json;
        my $is_selected = $body->{is_selected};
        my ( $vendor_id, $package_id, $resource_id ) = split '-',
          $c->param('resource_id');

        my $ebsco = Koha::ERM::Providers::EBSCO->new;
        my $t     = try {
            return $ebsco->request( GET => '/vendors/'
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

        $ebsco->request(
            PUT => '/vendors/'
              . $vendor_id
              . '/packages/'
              . $package_id
              . '/titles/'
              . $resource_id,
            undef,
            {
                isSelected => $is_selected,
                titleName  => $t->{titleName},
                pubType    => $t->{pubType}
            }
        );

        return $c->render(
            status  => 200,
            openapi => { is_selected => $is_selected } # We don't want to refetch the resource to make sure it has been updated
        );
    }
    catch {
        $c->unhandled_exception($_);
    };

}

1;
