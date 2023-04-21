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

use Koha::Account::Lines;
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

    # Handle possible fees
    my $debit = $self->borrower->add_article_request_fee_if_needed({ item_id => $self->itemnumber });
    $self->debit_id( $debit->id )
        if $debit;

    $self->store();
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
    $self->store();
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
    my ( $self, $params ) = @_;

    my $cancellation_reason = $params->{cancellation_reason};
    my $notes = $params->{notes};

    $self->status(Koha::ArticleRequest::Status::Canceled);
    $self->cancellation_reason($cancellation_reason) if $cancellation_reason;
    $self->notes($notes) if $notes;
    $self->store();
    $self->notify();

    my $debit = $self->debit;

    if ( $debit ) {
        # fees found, refund
        my $account = $self->borrower->account;

        my $total_reversible = $debit->debit_offsets->filter_by_reversible->total;
        if ( $total_reversible ) {

            $account->add_credit(
                {
                    amount       => abs $total_reversible,
                    interface    => C4::Context->interface,
                    type         => 'REFUND',
                }
            );
        }

        if ( $debit->amountoutstanding ) {
            $debit->reduce({
                reduction_type => 'REFUND',
                amount         => $debit->amountoutstanding,
                interface      => C4::Context->interface,
            })->discard_changes;
        }
    }

    return $self;
}

=head3 biblio

Returns the Koha::Biblio object for this article request

=cut

sub biblio {
    my ($self) = @_;

    my $rs = $self->_result->biblionumber;
    return unless $rs;
    return Koha::Biblio->_new_from_dbic($rs);
}

=head3 debit

    my $debit = $article_request->debit;

Returns the related Koha::Account::Line object for this article request

=cut

sub debit {
    my ($self) = @_;

    my $debit_rs = $self->_result->debit;
    return unless $debit_rs;

    return Koha::Account::Line->_new_from_dbic( $debit_rs );
}

=head3 item

Returns the Koha::Item object for this article request

=cut

sub item {
    my ($self) = @_;
    my $rs = $self->_result->itemnumber;
    return unless $rs;
    return Koha::Item->_new_from_dbic($rs);
}

=head3 borrower

Returns the Koha::Patron object for this article request

=cut

sub borrower {
    my ($self) = @_;
    my $rs = $self->_result->borrowernumber;
    return unless $rs;
    return Koha::Patron->_new_from_dbic($rs);
}

=head3 branch

Returns the Koha::Library object for this article request

=cut

sub branch {
    my ($self) = @_;
    my $rs = $self->_result->branchcode;
    return unless $rs;
    return Koha::Library->_new_from_dbic($rs);
}

=head3 store

Override the default store behavior so that new opac requests
will have notifications sent.

=cut

sub store {
    my ($self) = @_;

    if ( !$self->in_storage ) {
        $self->created_on( dt_from_string() );
    }

    return $self->SUPER::store;
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
    my $reason = $self->notes;
    if ( !defined $reason && $self->cancellation_reason ) {
        my $av = Koha::AuthorisedValues->search(
            {
                category            => 'AR_CANCELLATION',
                authorised_value    => $self->cancellation_reason
            }
        )->next;
        $reason = $av->lib_opac ? $av->lib_opac : $av->lib if $av;
    }

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
            substitute => {
                reason => $reason,
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
        ) or warn "can't enqueue letter " . $letter->{code};
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
