package Koha::Suggestion;

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

use C4::Context;
use C4::Letters;

use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Patrons;
use Koha::AuthorisedValues;
use Koha::Exceptions::Suggestion;

use base qw(Koha::Object);

=head1 NAME

Koha::Suggestion - Koha Suggestion object class

=head1 API

=head2 Class methods

=cut

=head3 store

Override the default store behavior so that new suggestions have
a suggesteddate of today

=cut

sub store {
    my ($self) = @_;

    $self->STATUS("ASKED") unless $self->STATUS;
    my @status_constants = qw(ASKED CHECKED ACCEPTED REJECTED ORDERED AVAILABLE);
    Koha::Exceptions::Suggestion::StatusForbidden->throw( STATUS => $self->STATUS )
        unless ( grep { $self->STATUS eq $_ } @status_constants )
        || Koha::AuthorisedValues->search(
        {
            category         => 'SUGGEST_STATUS',
            authorised_value => $self->STATUS
        }
    )->count;

    $self->branchcode(undef) if defined $self->branchcode && $self->branchcode eq '';
    unless ( $self->suggesteddate() ) {
        $self->suggesteddate( dt_from_string()->ymd );
    }

    my $emailpurchasesuggestions = C4::Context->preference("EmailPurchaseSuggestions");

    my $result = $self->SUPER::store();

    if( $emailpurchasesuggestions ){

        if (
            my $letter = C4::Letters::GetPreparedLetter(
                module      => 'suggestions',
                letter_code => 'NEW_SUGGESTION',
                tables      => {
                    'branches'    => $result->branchcode,
                    'borrowers'   => $result->suggestedby,
                    'suggestions' => $result->unblessed,
                },
            )
        ){

            my $toaddress;
            if ( $emailpurchasesuggestions eq "BranchEmailAddress" ) {
                my $library = $result->library;
                $toaddress = $library->inbound_email_address;
            }
            elsif ( $emailpurchasesuggestions eq "KohaAdminEmailAddress" ) {
                $toaddress = C4::Context->preference('ReplytoDefault')
                  || C4::Context->preference('KohaAdminEmailAddress');
            }
            else {
                $toaddress =
                     C4::Context->preference($emailpurchasesuggestions)
                  || C4::Context->preference('ReplytoDefault')
                  || C4::Context->preference('KohaAdminEmailAddress');
            }

            C4::Letters::EnqueueLetter(
                {
                    letter         => $letter,
                    borrowernumber => $result->suggestedby,
                    suggestionid   => $result->id,
                    to_address     => $toaddress,
                    message_transport_type => 'email',
                }
            ) or warn "can't enqueue letter $letter";
        }
    }

    return $result;
}

=head3 library

my $library = $suggestion->library;

Returns the library of the suggestion (Koha::Library for branchcode field)

=cut

sub library {
    my ($self) = @_;
    my $library_rs = $self->_result->branchcode;
    return unless $library_rs;
    return Koha::Library->_new_from_dbic($library_rs);
}

=head3 suggester

    my $patron = $suggestion->suggester

Returns the I<Koha::Patron> for the suggestion generator. I<undef> is
returned if no suggester is linked.

=cut

sub suggester {
    my ($self) = @_;

    my $suggester_rs = $self->_result->suggester;
    return unless $suggester_rs;
    return Koha::Patron->_new_from_dbic($suggester_rs);
}

=head3 manager

my $manager = $suggestion->manager;

Returns the manager of the suggestion (Koha::Patron for managedby field)

=cut

sub manager {
    my ($self) = @_;
    my $manager_rs = $self->_result->managedby;
    return unless $manager_rs;
    return Koha::Patron->_new_from_dbic($manager_rs);
}

=head3 rejecter

my $rejecter = $suggestion->rejecter;

Returns the rejecter of the suggestion (Koha::Patron for rejectebby field)

=cut

sub rejecter {
    my ($self) = @_;
    my $rejecter_rs = $self->_result->managedby;
    return unless $rejecter_rs;
    return Koha::Patron->_new_from_dbic($rejecter_rs);
}

=head3 last_modifier

my $last_modifier = $suggestion->last_modifier;

Returns the librarian who last modified the suggestion (Koha::Patron for lastmodificationby field)

=cut

sub last_modifier {
    my ($self) = @_;
    my $last_modifier_rs = $self->_result->managedby;
    return unless $last_modifier_rs;
    return Koha::Patron->_new_from_dbic($last_modifier_rs);
}

=head3 fund

my $fund = $suggestion->fund;

Return the fund associated to the suggestion

=cut

sub fund {
    my ($self) = @_;
    my $fund_rs = $self->_result->budgetid;
    return unless $fund_rs;
    return Koha::Acquisition::Fund->_new_from_dbic($fund_rs);
}

=head3 type

=cut

sub _type {
    return 'Suggestion';
}

=head3 to_api_mapping

This method returns the mapping for representing a Koha::Patron object
on the API.

=cut

sub to_api_mapping {
    return {
        suggestionid         => 'suggestion_id',
        suggestedby          => 'suggested_by',
        suggesteddate        => 'suggestion_date',
        managedby            => 'managed_by',
        manageddate          => 'managed_date',
        acceptedby           => 'accepted_by',
        accepteddate         => 'accepted_date',
        rejectedby           => 'rejected_by',
        rejecteddate         => 'rejected_date',
        lastmodificationdate => 'last_status_change_date',
        lastmodificationby   => 'last_status_change_by',
        STATUS               => 'status',
        note                 => 'note',
        staff_note           => 'staff_note',
        author               => 'author',
        title                => 'title',
        copyrightdate        => 'copyright_date',
        publishercode        => 'publisher_code',
        date                 => 'timestamp',
        volumedesc           => 'volume_desc',
        publicationyear      => 'publication_year',
        place                => 'publication_place',
        isbn                 => 'isbn',
        biblionumber         => 'biblio_id',
        reason               => 'reason',
        patronreason         => 'patron_reason',
        budgetid             => 'budget_id',
        branchcode           => 'library_id',
        collectiontitle      => 'collection_title',
        itemtype             => 'item_type',
        quantity             => 'quantity',
        currency             => 'currency',
        price                => 'item_price',
        total                => 'total_price',
        archived             => 'archived',
    };
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
