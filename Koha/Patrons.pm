package Koha::Patrons;

# Copyright ByWater Solutions 2014
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

use Koha::ArticleRequests;
use Koha::ArticleRequest::Status;
use Koha::Patron;

use base qw(Koha::Objects);

=head1 NAME

Koha::Patron - Koha Patron Object class

=head1 API

=head2 Class Methods

=cut

=head3 search_housebound_choosers

Returns all Patrons which are Housebound choosers.

=cut

sub search_housebound_choosers {
    my ( $self ) = @_;
    my $cho = $self->_resultset
        ->search_related('housebound_role', {
            housebound_chooser => 1,
        })->search_related('borrowernumber');
    return Koha::Patrons->_new_from_dbic($cho);
}

=head3 search_housebound_deliverers

Returns all Patrons which are Housebound deliverers.

=cut

sub search_housebound_deliverers {
    my ( $self ) = @_;
    my $del = $self->_resultset
        ->search_related('housebound_role', {
            housebound_deliverer => 1,
        })->search_related('borrowernumber');
    return Koha::Patrons->_new_from_dbic($del);
}

=head3 guarantor

Returns a Koha::Patron object for this borrower's guarantor

=cut

sub guarantor {
    my ( $self ) = @_;

    return Koha::Patrons->find( $self->guarantorid() );
}

=head3 article_requests

my @requests = $borrower->article_requests();
my $requests = $borrower->article_requests();

Returns either a list of ArticleRequests objects,
or an ArtitleRequests object, depending on the
calling context.

=cut

sub article_requests {
    my ( $self ) = @_;

    $self->{_article_requests} ||= Koha::ArticleRequests->search({ borrowernumber => $self->borrowernumber() });

    return $self->{_article_requests};
}

=head3 article_requests_current

my @requests = $patron->article_requests_current

Returns the article requests associated with this patron that are incomplete

=cut

sub article_requests_current {
    my ( $self ) = @_;

    $self->{_article_requests_current} ||= Koha::ArticleRequests->search(
        {
            borrowernumber => $self->id(),
            -or          => [
                { status => Koha::ArticleRequest::Status::Pending },
                { status => Koha::ArticleRequest::Status::Processing }
            ]
        }
    );

    return $self->{_article_requests_current};
}

=head3 article_requests_finished

my @requests = $biblio->article_requests_finished

Returns the article requests associated with this patron that are completed

=cut

sub article_requests_finished {
    my ( $self, $borrower ) = @_;

    $self->{_article_requests_finished} ||= Koha::ArticleRequests->search(
        {
            borrowernumber => $self->id(),
            -or          => [
                { status => Koha::ArticleRequest::Status::Completed },
                { status => Koha::ArticleRequest::Status::Canceled }
            ]
        }
    );

    return $self->{_article_requests_finished};
}

=head3 type

=cut

sub _type {
    return 'Borrower';
}

sub object_class {
    return 'Koha::Patron';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
