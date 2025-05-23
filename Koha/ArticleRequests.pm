package Koha::ArticleRequests;

# Copyright ByWater Solutions 2015
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

use Koha::Database;

use Koha::ArticleRequest::Status;
use Koha::ArticleRequest;

use base qw(Koha::Objects);

=head1 NAME

Koha::ArticleRequests - Koha ArticleRequests Object class

=head1 API

=head2 Class methods

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
    $attributes->{join}                    = 'borrowernumber';
    return $self->search( $params, $attributes );
}

=head3 filter_by_current

    my $current_article_requests = $article_requests->filter_by_current;

Returns a new resultset, filtering out finished article requests.

=cut

sub filter_by_current {
    my ($self) = @_;

    return $self->search(
        {
            status => [
                Koha::ArticleRequest::Status::Requested,
                Koha::ArticleRequest::Status::Pending,
                Koha::ArticleRequest::Status::Processing,
            ]
        }
    );
}

=head3 filter_by_finished

    my $finished_article_requests = $article_requests->filter_by_finished;

Returns a new resultset, filtering out current article requests.

=cut

sub filter_by_finished {
    my ($self) = @_;

    return $self->search(
        {
            status => [
                Koha::ArticleRequest::Status::Completed,
                Koha::ArticleRequest::Status::Canceled,
            ]
        }
    );
}

=head3 requested

=cut

sub requested {
    my ( $self, $branchcode ) = @_;
    my $params = { status => Koha::ArticleRequest::Status::Requested };
    $params->{'me.branchcode'} = $branchcode if $branchcode;
    return Koha::ArticleRequests->search_limited($params);
}

=head3 pending

=cut

sub pending {
    my ( $self, $branchcode ) = @_;
    my $params = { status => Koha::ArticleRequest::Status::Pending };
    $params->{'me.branchcode'} = $branchcode if $branchcode;
    return Koha::ArticleRequests->search_limited($params);
}

=head3 processing

=cut

sub processing {
    my ( $self, $branchcode ) = @_;
    my $params = { status => Koha::ArticleRequest::Status::Processing };
    $params->{'me.branchcode'} = $branchcode if $branchcode;
    return Koha::ArticleRequests->search_limited($params);
}

=head3 completed

=cut

sub completed {
    my ( $self, $branchcode ) = @_;
    my $params = { status => Koha::ArticleRequest::Status::Completed };
    $params->{'me.branchcode'} = $branchcode if $branchcode;
    return Koha::ArticleRequests->search_limited($params);
}

=head3 canceled

=cut

sub canceled {
    my ( $self, $branchcode ) = @_;
    my $params = { status => Koha::ArticleRequest::Status::Canceled };
    $params->{'me.branchcode'} = $branchcode if $branchcode;
    return Koha::ArticleRequests->search_limited($params);
}

=head3 _type

=cut

sub _type {
    return 'ArticleRequest';
}

=head2 object_class

Missing POD for object_class.

=cut

sub object_class {
    return 'Koha::ArticleRequest';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
