package Koha::ArticleRequest;

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
use Koha::Patrons;
use Koha::Biblios;
use Koha::Items;
use Koha::Libraries;
use Koha::DateUtils qw( dt_from_string );
use Koha::ArticleRequest::Status;
use Koha::Exceptions::ArticleRequest;

use base qw(Koha::Object);

=head1 NAME

Koha::ArticleRequest - Koha Article Request Object class

=head1 API

=head2 Class methods

=cut

=head3 request

    $article_request->request;

Marks the article as requested. Send a notification if appropriate.

=cut

sub request {
    my ($self) = @_;

    Koha::Exceptions::ArticleRequest::LimitReached->throw(
        error => 'Patron cannot request more articles for today'
    ) unless $self->borrower->can_request_article;

    $self->status(Koha::ArticleRequest::Status::Requested);
    $self->SUPER::store();
    $self->notify();
    return $self;
}

=head3 set_pending

    $article_request->set_pending;

Marks the article as pending. Send a notification if appropriate.

=cut

sub set_pending {
    my ($self) = @_;

    $self->status(Koha::ArticleRequest::Status::Pending);
    $self->SUPER::store();
    $self->notify();
    return $self;
}

=head3 process

    $article_request->process;

Marks the article as in process. Send a notification if appropriate.

=cut

sub process {
    my ($self) = @_;

    $self->status(Koha::ArticleRequest::Status::Processing);
    $self->store();
    $self->notify();
    return $self;
}

=head3 complete

    $article_request->complete;

Marks the article as completed. Send a notification if appropriate.

=cut

sub complete {
    my ($self) = @_;

    $self->status(Koha::ArticleRequest::Status::Completed);
    $self->store();
    $self->notify();
    return $self;
}

=head3 cancel

    $article_request->cancel;

Marks the article as cancelled. Send a notification if appropriate.

=cut

sub cancel {
    my ( $self, $notes ) = @_;

    $self->status(Koha::ArticleRequest::Status::Canceled);
    $self->notes($notes) if $notes;
    $self->store();
    $self->notify();
    return $self;
}

=head3 biblio

Returns the Koha::Biblio object for this article request

=cut

sub biblio {
    my ($self) = @_;

    $self->{_biblio} ||= Koha::Biblios->find( $self->biblionumber() );

    return $self->{_biblio};
}

=head3 item

Returns the Koha::Item object for this article request

=cut

sub item {
    my ($self) = @_;

    $self->{_item} ||= Koha::Items->find( $self->itemnumber() );

    return $self->{_item};
}

=head3 borrower

Returns the Koha::Patron object for this article request

=cut

sub borrower {
    my ($self) = @_;

    $self->{_borrower} ||= Koha::Patrons->find( $self->borrowernumber() );

    return $self->{_borrower};
}

=head3 branch

Returns the Koha::Library object for this article request

=cut

sub branch {
    my ($self) = @_;

    $self->{_branch} ||= Koha::Libraries->find( $self->branchcode() );

    return $self->{_branch};
}

=head3 store

Override the default store behavior so that new opac requests
will have notifications sent.

=cut

sub store {
    my ($self) = @_;
    if ( $self->in_storage ) {
        return $self->SUPER::store;
    } else {
        $self->created_on( dt_from_string() );
        return $self->request;
    }
}

=head2 Internal methods

=head3 notify

    $self->notify();

internal method to be called when changing an article request status.
If a letter exists for the new status, it enqueues it.

=cut

sub notify {
    my ($self) = @_;

    my $status = $self->status;

    require C4::Letters;
    if (
        my $letter = C4::Letters::GetPreparedLetter(
            module                 => 'circulation',
            letter_code            => "AR_$status", # AR_REQUESTED, AR_PENDING, AR_PROCESSING, AR_COMPLETED, AR_CANCELED
            message_transport_type => 'email',
            lang                   => $self->borrower->lang,
            tables                 => {
                article_requests => $self->id,
                borrowers        => $self->borrowernumber,
                biblio           => $self->biblionumber,
                biblioitems      => $self->biblionumber,
                items            => $self->itemnumber,
                branches         => $self->branchcode,
            },
        )
      )
    {
        C4::Letters::EnqueueLetter(
            {
                letter                 => $letter,
                borrowernumber         => $self->borrowernumber,
                message_transport_type => 'email',
            }
        ) or warn "can't enqueue letter ". $letter->{code};
    }
}

=head3 _type

=cut

sub _type {
    return 'ArticleRequest';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
