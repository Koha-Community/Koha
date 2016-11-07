package Koha::Patron;

# Copyright ByWater Solutions 2014
# Copyright PTFS Europe 2016
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

use C4::Context;
use C4::Log;
use Koha::Database;
use Koha::DateUtils;
use Koha::Holds;
use Koha::Issues;
use Koha::OldIssues;
use Koha::Patron::Categories;
use Koha::Patron::HouseboundProfile;
use Koha::Patron::HouseboundRole;
use Koha::Patron::Images;
use Koha::Patrons;
use Koha::Virtualshelves;

use base qw(Koha::Object);

=head1 NAME

Koha::Patron - Koha Patron Object class

=head1 API

=head2 Class Methods

=cut

=head3 delete

$patron->delete

Delete patron's holds, lists and finally the patron.

Lists owned by the borrower are deleted, but entries from the borrower to
other lists are kept.

=cut

sub delete {
    my ($self) = @_;

    my $deleted;
    $self->_result->result_source->schema->txn_do(
        sub {
            # Delete Patron's holds
            # FIXME Should be $patron->get_holds
            $_->delete for Koha::Holds->search( { borrowernumber => $self->borrowernumber } );

            # Delete all lists and all shares of this borrower
            # Consistent with the approach Koha uses on deleting individual lists
            # Note that entries in virtualshelfcontents added by this borrower to
            # lists of others will be handled by a table constraint: the borrower
            # is set to NULL in those entries.
            # NOTE:
            # We could handle the above deletes via a constraint too.
            # But a new BZ report 11889 has been opened to discuss another approach.
            # Instead of deleting we could also disown lists (based on a pref).
            # In that way we could save shared and public lists.
            # The current table constraints support that idea now.
            # This pref should then govern the results of other routines/methods such as
            # Koha::Virtualshelf->new->delete too.
            # FIXME Could be $patron->get_lists
            $_->delete for Koha::Virtualshelves->search( { owner => $self->borrowernumber } );

            $deleted = $self->SUPER::delete;

            logaction( "MEMBERS", "DELETE", $self->borrowernumber, "" ) if C4::Context->preference("BorrowersLog");
        }
    );
    return $deleted;
}


=head3 category

my $patron_category = $patron->category

Return the patron category for this patron

=cut

sub category {
    my ( $self ) = @_;
    return Koha::Patron::Category->_new_from_dbic( $self->_result->categorycode );
}

=head3 guarantor

Returns a Koha::Patron object for this patron's guarantor

=cut

sub guarantor {
    my ( $self ) = @_;

    return unless $self->guarantorid();

    return Koha::Patrons->find( $self->guarantorid() );
}

sub image {
    my ( $self ) = @_;

    return Koha::Patron::Images->find( $self->borrowernumber )
}

=head3 guarantees

Returns the guarantees (list of Koha::Patron) of this patron

=cut

sub guarantees {
    my ( $self ) = @_;

    return Koha::Patrons->search( { guarantorid => $self->borrowernumber } );
}

=head3 housebound_profile

Returns the HouseboundProfile associated with this patron.

=cut

sub housebound_profile {
    my ( $self ) = @_;
    my $profile = $self->_result->housebound_profile;
    return Koha::Patron::HouseboundProfile->_new_from_dbic($profile)
        if ( $profile );
    return;
}

=head3 housebound_role

Returns the HouseboundRole associated with this patron.

=cut

sub housebound_role {
    my ( $self ) = @_;

    my $role = $self->_result->housebound_role;
    return Koha::Patron::HouseboundRole->_new_from_dbic($role) if ( $role );
    return;
}

=head3 siblings

Returns the siblings of this patron.

=cut

sub siblings {
    my ( $self ) = @_;

    my $guarantor = $self->guarantor;

    return unless $guarantor;

    return Koha::Patrons->search(
        {
            guarantorid => {
                '!=' => undef,
                '=' => $guarantor->id,
            },
            borrowernumber => {
                '!=' => $self->borrowernumber,
            }
        }
    );
}

=head3 wants_check_for_previous_checkout

    $wants_check = $patron->wants_check_for_previous_checkout;

Return 1 if Koha needs to perform PrevIssue checking, else 0.

=cut

sub wants_check_for_previous_checkout {
    my ( $self ) = @_;
    my $syspref = C4::Context->preference("checkPrevCheckout");

    # Simple cases
    ## Hard syspref trumps all
    return 1 if ($syspref eq 'hardyes');
    return 0 if ($syspref eq 'hardno');
    ## Now, patron pref trumps all
    return 1 if ($self->checkprevcheckout eq 'yes');
    return 0 if ($self->checkprevcheckout eq 'no');

    # More complex: patron inherits -> determine category preference
    my $checkPrevCheckoutByCat = $self->category->checkprevcheckout;
    return 1 if ($checkPrevCheckoutByCat eq 'yes');
    return 0 if ($checkPrevCheckoutByCat eq 'no');

    # Finally: category preference is inherit, default to 0
    if ($syspref eq 'softyes') {
        return 1;
    } else {
        return 0;
    }
}

=head3 do_check_for_previous_checkout

    $do_check = $patron->do_check_for_previous_checkout($item);

Return 1 if the bib associated with $ITEM has previously been checked out to
$PATRON, 0 otherwise.

=cut

sub do_check_for_previous_checkout {
    my ( $self, $item ) = @_;

    # Find all items for bib and extract item numbers.
    my @items = Koha::Items->search({biblionumber => $item->{biblionumber}});
    my @item_nos;
    foreach my $item (@items) {
        push @item_nos, $item->itemnumber;
    }

    # Create (old)issues search criteria
    my $criteria = {
        borrowernumber => $self->borrowernumber,
        itemnumber => \@item_nos,
    };

    # Check current issues table
    my $issues = Koha::Issues->search($criteria);
    return 1 if $issues->count; # 0 || N

    # Check old issues table
    my $old_issues = Koha::OldIssues->search($criteria);
    return $old_issues->count;  # 0 || N
}

=head2 is_debarred

my $debarment_expiration = $patron->is_debarred;

Returns the date a patron debarment will expire, or undef if the patron is not
debarred

=cut

sub is_debarred {
    my ($self) = @_;

    return unless $self->debarred;
    return $self->debarred
      if $self->debarred =~ '^9999'
      or dt_from_string( $self->debarred ) > dt_from_string;
    return;
}

=head2 is_expired

my $is_expired = $patron->is_expired;

Returns 1 if the patron is expired or 0;

=cut

sub is_expired {
    my ($self) = @_;
    return 0 unless $self->dateexpiry;
    return 0 if $self->dateexpiry eq '0000-00-00';
    return 1 if dt_from_string( $self->dateexpiry ) < dt_from_string;
    return 0;
}

=head2 update_password

my $updated = $patron->update_password( $userid, $password );

Update the userid and the password of a patron.
If the userid already exists, returns and let DBIx::Class warns
This will add an entry to action_logs if BorrowersLog is set.

=cut

sub update_password {
    my ( $self, $userid, $password ) = @_;
    eval { $self->userid($userid)->store; };
    return if $@; # Make sure the userid is not already in used by another patron
    $self->password($password)->store;
    logaction( "MEMBERS", "CHANGE PASS", $self->borrowernumber, "" ) if C4::Context->preference("BorrowersLog");
    return 1;
}

=head3 renew_account

my $new_expiry_date = $patron->renew_account

Extending the subscription to the expiry date.

=cut

sub renew_account {
    my ($self) = @_;
    my $date;
    if ( C4::Context->preference('BorrowerRenewalPeriodBase') eq 'combination' ) {
        $date = ( dt_from_string gt dt_from_string( $self->dateexpiry ) ) ? dt_from_string : dt_from_string( $self->dateexpiry );
    } else {
        $date =
            C4::Context->preference('BorrowerRenewalPeriodBase') eq 'dateexpiry'
            ? dt_from_string( $self->dateexpiry )
            : dt_from_string;
    }
    my $expiry_date = $self->category->get_expiry_date($date);

    $self->dateexpiry($expiry_date)->store;

    $self->add_enrolment_fee_if_needed;

    logaction( "MEMBERS", "RENEW", $self->borrowernumber, "Membership renewed" ) if C4::Context->preference("BorrowersLog");
    return dt_from_string( $expiry_date )->truncate( to => 'day' );
}

=head2 has_overdues

my $has_overdues = $patron->has_overdues;

Returns the number of patron's overdues

=cut

sub has_overdues {
    my ($self) = @_;
    my $dtf = Koha::Database->new->schema->storage->datetime_parser;
    return $self->_result->issues->search({ date_due => { '<' => $dtf->format_datetime( dt_from_string() ) } })->count;
}

=head2 track_login

    $patron->track_login;
    $patron->track_login({ force => 1 });

    Tracks a (successful) login attempt.
    The preference TrackLastPatronActivity must be enabled. Or you
    should pass the force parameter.

=cut

sub track_login {
    my ( $self, $params ) = @_;
    return if
        !$params->{force} &&
        !C4::Context->preference('TrackLastPatronActivity');
    $self->lastseen( dt_from_string() )->store;
}

=head2 move_to_deleted

my $is_moved = $patron->move_to_deleted;

Move a patron to the deletedborrowers table.
This can be done before deleting a patron, to make sure the data are not completely deleted.

=cut

sub move_to_deleted {
    my ($self) = @_;
    my $patron_infos = $self->unblessed;
    return Koha::Database->new->schema->resultset('Deletedborrower')->create($patron_infos);
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

=head3 add_enrolment_fee_if_needed

my $enrolment_fee = $patron->add_enrolment_fee_if_needed;

Add enrolment fee for a patron if needed.

=cut

sub add_enrolment_fee_if_needed {
    my ($self) = @_;
    my $enrolment_fee = $self->category->enrolmentfee;
    if ( $enrolment_fee && $enrolment_fee > 0 ) {
        # insert fee in patron debts
        C4::Accounts::manualinvoice( $self->borrowernumber, '', '', 'A', $enrolment_fee );
    }
    return $enrolment_fee || 0;
}

=head3 type

=cut

sub _type {
    return 'Borrower';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>
Alex Sassmannshausen <alex.sassmannshausen@ptfs-europe.com>

=cut

1;
