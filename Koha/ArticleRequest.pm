package Koha::ArticleRequest;

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
use Koha::Patrons;
use Koha::Biblios;
use Koha::Items;
use Koha::Libraries;
use Koha::ArticleRequest::Status;
use Koha::DateUtils qw(dt_from_string);

use base qw(Koha::Object);

=head1 NAME

Koha::ArticleRequest - Koha Article Request Object class

=head1 API

=head2 Class Methods

=cut

=head3 open

=cut

sub open {
    my ($self) = @_;

    $self->status(Koha::ArticleRequest::Status::Pending);
    $self->SUPER::store();
    $self->notify();
    return $self;
}

=head3 process

=cut

sub process {
    my ($self) = @_;

    $self->status(Koha::ArticleRequest::Status::Processing);
    $self->store();
    $self->notify();
    return $self;
}

=head3 complete

=cut

sub complete {
    my ($self) = @_;

    $self->status(Koha::ArticleRequest::Status::Completed);
    $self->store();
    $self->notify();
    return $self;
}

=head3 cancel

=cut

sub cancel {
    my ( $self, $notes ) = @_;

    $self->status(Koha::ArticleRequest::Status::Canceled);
    $self->notes($notes) if $notes;
    $self->store();
    $self->notify();
    return $self;
}

=head3 notify

=cut

sub notify {
    my ($self) = @_;

    my $status = $self->status;

    require C4::Letters;
    if (
        my $letter = C4::Letters::GetPreparedLetter(
            module                 => 'circulation',
            letter_code            => "AR_$status", # AR_PENDING, AR_PROCESSING, AR_COMPLETED, AR_CANCELED
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
        ) or warn "can't enqueue letter $letter";
    }
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

Override the default store behavior so that new opan requests
will have notifications sent.

=cut

sub store {
    my ($self) = @_;

    if ( $self->in_storage() ) {
        my $now = dt_from_string();
        $self->updated_on($now);

        return $self->SUPER::store();
    }
    else {
        $self->open();
        return $self->SUPER::store();
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
