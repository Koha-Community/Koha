package Koha::REST::Plugin::Pagination;

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Mojo::Base 'Mojolicious::Plugin';

=head1 NAME

Koha::REST::Plugin::Pagination

=head1 API

=head2 Mojolicious::Plugin methods

=head3 register

=cut

sub register {
    my ( $self, $app ) = @_;

=head2 Helper methods

=head3 add_pagination_headers

    my $patrons = Koha::Patrons->search( ... );
    $c->add_pagination_headers({
        total  => $patrons->count,
        params => {
            _page     => ...
            _per_page => ...
            ...
        }
    });

Adds a Link header to the response message $c carries, following RFC5988, including
the following relation types: 'prev', 'next', 'first' and 'last'.
It also adds X-Total-Count, containing the total results count.

If page size is omitted, it defaults to the value of the RESTdefaultPageSize syspref.

=cut

    $app->helper(
        'add_pagination_headers' => sub {
            my ( $c, $args ) = @_;

            my $total    = $args->{total};
            my $req_page = $args->{params}->{_page};
            my $per_page = $args->{params}->{_per_page} //
                            C4::Context->preference('RESTdefaultPageSize') // 20;

            # do we need to paginate?
            return $c unless $req_page;

            my $pages = int $total / $per_page;
            $pages++
                if $total % $per_page > 0;

            my @links;

            if ( $pages > 1 and $req_page > 1 ) {    # Previous exists?
                push @links,
                    _build_link(
                    $c,
                    {   page     => $req_page - 1,
                        per_page => $per_page,
                        rel      => 'prev',
                        params   => $args->{params}
                    }
                    );
            }

            if ( $pages > 1 and $req_page < $pages ) {    # Next exists?
                push @links,
                    _build_link(
                    $c,
                    {   page     => $req_page + 1,
                        per_page => $per_page,
                        rel      => 'next',
                        params   => $args->{params}
                    }
                    );
            }

            push @links,
                _build_link( $c,
                { page => 1, per_page => $per_page, rel => 'first', params => $args->{params} } );
            push @links,
                _build_link( $c,
                { page => $pages, per_page => $per_page, rel => 'last', params => $args->{params} } );

            # Add Link header
            $c->res->headers->add( 'Link' => join( ',', @links ) );

            # Add X-Total-Count header
            $c->res->headers->add( 'X-Total-Count' => $total );
            return $c;
        }
    );

=head3 dbic_merge_pagination

    $filter = $c->dbic_merge_pagination({
        filter => $filter,
        params => {
            page     => $params->{_page},
            per_page => $params->{_per_page}
        }
    });

Adds I<page> and I<rows> elements to the filter parameter.

=cut

    $app->helper(
        'dbic_merge_pagination' => sub {
            my ( $c, $args ) = @_;
            my $filter = $args->{filter};

            $filter->{page} = $args->{params}->{_page};
            $filter->{rows} = $args->{params}->{_per_page};

            return $filter;
        }
    );
}

=head2 Internal methods

=head3 _build_link

    my $link = _build_link( $c, { page => 1, per_page => 5, rel => 'prev' });

Returns a string, suitable for using in Link headers following RFC5988.

=cut

sub _build_link {
    my ( $c, $args ) = @_;

    my $params = $args->{params};

    $params->{_page}     = $args->{page};
    $params->{_per_page} = $args->{per_page};

    my $link = '<'
        . $c->req->url->clone->query(
            $params
        )->to_abs
        . '>; rel="'
        . $args->{rel} . '"';

    # TODO: Find a better solution for this horrible (but needed) fix
    $link =~ s|api/v1/app\.pl/||;

    return $link;
}

1;
