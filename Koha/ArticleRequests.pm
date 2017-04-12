package Koha::ArticleRequests;

# Copyright ByWater Solutions 2015
#
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

use Modern::Perl;

use Carp;

use Koha::Database;

use Koha::ArticleRequest;
use Koha::ArticleRequest::Status;

use base qw(Koha::Objects);

=head1 NAME

Koha::ArticleRequests - Koha ArticleRequests Object class

=head1 API

=head2 Class Methods

=cut

=head3 search_limited

my $article_requests = Koha::ArticleRequests->search_limited( $params, $attributes );

Search for article requests according to logged in patron restrictions

=cut

sub search_limited {
    my ( $self, $params, $attributes ) = @_;

    my $userenv = C4::Context->userenv;
    my @restricted_branchcodes;
    if ( $userenv and $userenv->{number} ) {
        my $logged_in_user = Koha::Patrons->find( $userenv->{number} );
        @restricted_branchcodes = $logged_in_user->libraries_where_can_see_patrons;
    }
    # TODO This 'borrowernumber' relation name is confusing and needs to be renamed
    $params->{'borrowernumber.branchcode'} = { -in => \@restricted_branchcodes } if @restricted_branchcodes;
    $attributes->{join} = 'borrowernumber';
    return $self->search( $params, $attributes );
}

=head3 pending

=cut

sub pending {
    my ( $self, $branchcode ) = @_;
    my $params = { status => Koha::ArticleRequest::Status::Pending };
    $params->{'me.branchcode'} = $branchcode if $branchcode;
    return Koha::ArticleRequests->search_limited( $params );
}

=head3 processing

=cut

sub processing {
    my ( $self, $branchcode ) = @_;
    my $params = { status => Koha::ArticleRequest::Status::Processing };
    $params->{'me.branchcode'} = $branchcode if $branchcode;
    return Koha::ArticleRequests->search_limited( $params );
}

=head3 completed

=cut

sub completed {
    my ( $self, $branchcode ) = @_;
    my $params = { status => Koha::ArticleRequest::Status::Completed };
    $params->{'me.branchcode'} = $branchcode if $branchcode;
    return Koha::ArticleRequests->search_limited( $params );
}

=head3 canceled

=cut

sub canceled {
    my ( $self, $branchcode ) = @_;
    my $params = { status => Koha::ArticleRequest::Status::Canceled };
    $params->{'me.branchcode'} = $branchcode if $branchcode;
    return Koha::ArticleRequests->search_limited( $params );
}

=head3 _type

=cut

sub _type {
    return 'ArticleRequest';
}

sub object_class {
    return 'Koha::ArticleRequest';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
