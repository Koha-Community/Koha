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
use List::MoreUtils qw( uniq );
use JSON qw( to_json );
use Module::Load::Conditional qw( can_load );
use Text::Unaccent qw( unac_string );

use C4::Context;
use C4::Log;
use Koha::AuthUtils;
use Koha::Checkouts;
use Koha::Database;
use Koha::DateUtils;
use Koha::Holds;
use Koha::Old::Checkouts;
use Koha::Patron::Categories;
use Koha::Patron::HouseboundProfile;
use Koha::Patron::HouseboundRole;
use Koha::Patron::Images;
use Koha::Patrons;
use Koha::Virtualshelves;
use Koha::Club::Enrollments;
use Koha::Account;
use Koha::Subscription::Routinglists;

if ( ! can_load( modules => { 'Koha::NorwegianPatronDB' => undef } ) ) {
   warn "Unable to load Koha::NorwegianPatronDB";
}

use base qw(Koha::Object);

our $RESULTSET_PATRON_ID_MAPPING = {
    Accountline          => 'borrowernumber',
    Aqbasketuser         => 'borrowernumber',
    Aqbudget             => 'budget_owner_id',
    Aqbudgetborrower     => 'borrowernumber',
    ArticleRequest       => 'borrowernumber',
    BorrowerAttribute    => 'borrowernumber',
    BorrowerDebarment    => 'borrowernumber',
    BorrowerFile         => 'borrowernumber',
    BorrowerModification => 'borrowernumber',
    ClubEnrollment       => 'borrowernumber',
    Issue                => 'borrowernumber',
    ItemsLastBorrower    => 'borrowernumber',
    Linktracker          => 'borrowernumber',
    Message              => 'borrowernumber',
    MessageQueue         => 'borrowernumber',
    OldIssue             => 'borrowernumber',
    OldReserve           => 'borrowernumber',
    Rating               => 'borrowernumber',
    Reserve              => 'borrowernumber',
    Review               => 'borrowernumber',
    SearchHistory        => 'userid',
    Statistic            => 'borrowernumber',
    Suggestion           => 'suggestedby',
    TagAll               => 'borrowernumber',
    Virtualshelfcontent  => 'borrowernumber',
    Virtualshelfshare    => 'borrowernumber',
    Virtualshelve        => 'owner',
};

=head1 NAME

Koha::Patron - Koha Patron Object class

=head1 API

=head2 Class Methods

=cut

=head3 new

=cut

sub new {
    my ( $class, $params ) = @_;

    return $class->SUPER::new($params);
}

=head3 fixup_cardnumber

Autogenerate next cardnumber from highest value found in database

=cut

sub fixup_cardnumber {
    my ( $self ) = @_;
    my $max = Koha::Patrons->search({
        cardnumber => {-regexp => '^-?[0-9]+$'}
    }, {
        select => \'CAST(cardnumber AS SIGNED)',
        as => ['cast_cardnumber']
    })->_resultset->get_column('cast_cardnumber')->max;
    $self->cardnumber(($max || 0) +1);
}

=head3 trim_whitespace

trim whitespace from data which has some non-whitespace in it.
Could be moved to Koha::Object if need to be reused

=cut

sub trim_whitespaces {
    my( $self ) = @_;

    my $schema  = Koha::Database->new->schema;
    my @columns = $schema->source($self->_type)->columns;

    for my $column( @columns ) {
        my $value = $self->$column;
        if ( defined $value ) {
            $value =~ s/^\s*|\s*$//g;
            $self->$column($value);
        }
    }
    return $self;
}

=head3 plain_text_password

$patron->plain_text_password( $password );

stores a copy of the unencrypted password in the object
for use in code before encrypting for db

=cut

sub plain_text_password {
    my ( $self, $password ) = @_;
    if ( $password ) {
        $self->{_plain_text_password} = $password;
        return $self;
    }
    return $self->{_plain_text_password}
        if $self->{_plain_text_password};

    return;
}

=head3 store

Patron specific store method to cleanup record
and do other necessary things before saving
to db

=cut

sub store {
    my ($self) = @_;

    $self->_result->result_source->schema->txn_do(
        sub {
            if (
                C4::Context->preference("autoMemberNum")
                and ( not defined $self->cardnumber
                    or $self->cardnumber eq '' )
              )
            {
                # Warning: The caller is responsible for locking the members table in write
                # mode, to avoid database corruption.
                # We are in a transaction but the table is not locked
                $self->fixup_cardnumber;
            }

            unless( $self->category->in_storage ) {
                Koha::Exceptions::Object::FKConstraint->throw(
                    broken_fk => 'categorycode',
                    value     => $self->categorycode,
                );
            }

            $self->trim_whitespaces;

            # We don't want invalid dates in the db (mysql has a bad habit of inserting 0000-00-00)
            $self->dateofbirth(undef) unless $self->dateofbirth;
            $self->debarred(undef)    unless $self->debarred;

            # Set default values if not set
            $self->sms_provider_id(undef) unless $self->sms_provider_id;
            $self->guarantorid(undef)     unless $self->guarantorid;

            unless ( $self->in_storage ) {    #AddMember

                # Generate a valid userid/login if needed
                $self->generate_userid
                  if not $self->userid or not $self->has_valid_userid;

                # Add expiration date if it isn't already there
                unless ( $self->dateexpiry ) {
                    $self->dateexpiry( $self->category->get_expiry_date );
                }

                # Add enrollment date if it isn't already there
                unless ( $self->dateenrolled ) {
                    $self->dateenrolled(dt_from_string);
                }

                # Set the privacy depending on the patron's category
                my $default_privacy = $self->category->default_privacy || q{};
                $default_privacy =
                    $default_privacy eq 'default' ? 1
                  : $default_privacy eq 'never'   ? 2
                  : $default_privacy eq 'forever' ? 0
                  :                                                   undef;
                $self->privacy($default_privacy);

                unless ( defined $self->privacy_guarantor_checkouts ) {
                    $self->privacy_guarantor_checkouts(0);
                }

                # Make a copy of the plain text password for later use
                $self->plain_text_password( $self->password );

                # Create a disabled account if no password provided
                $self->password( $self->password
                    ? Koha::AuthUtils::hash_password( $self->password )
                    : '!' );

                $self->borrowernumber(undef);

                $self = $self->SUPER::store;

                # If NorwegianPatronDBEnable is enabled, we set syncstatus to something that a
                # cronjob will use for syncing with NL
                if (   C4::Context->preference('NorwegianPatronDBEnable')
                    && C4::Context->preference('NorwegianPatronDBEnable') == 1 )
                {
                    Koha::Database->new->schema->resultset('BorrowerSync')
                      ->create(
                        {
                            'borrowernumber' => $self->borrowernumber,
                            'synctype'       => 'norwegianpatrondb',
                            'sync'           => 1,
                            'syncstatus'     => 'new',
                            'hashed_pin' =>
                              Koha::NorwegianPatronDB::NLEncryptPIN($self->plain_text_password),
                        }
                      );
                }

                $self->add_enrolment_fee_if_needed;

                logaction( "MEMBERS", "CREATE", $self->borrowernumber, "" )
                  if C4::Context->preference("BorrowersLog");
            }
            else {    #ModMember

                # Come from ModMember, but should not be possible (?)
                $self->dateenrolled(undef) unless $self->dateenrolled;
                $self->dateexpiry(undef)   unless $self->dateexpiry;


                my $self_from_storage = $self->get_from_storage;
                # FIXME We should not deal with that here, callers have to do this job
                # Moved from ModMember to prevent regressions
                unless ( $self->userid ) {
                    my $stored_userid = $self_from_storage->userid;
                    $self->userid($stored_userid);
                }

                # Password must be updated using $self->update_password
                $self->password($self_from_storage->password);

                if ( C4::Context->preference('FeeOnChangePatronCategory')
                    and $self->category->categorycode ne
                    $self_from_storage->category->categorycode )
                {
                    $self->add_enrolment_fee_if_needed;
                }

                # If NorwegianPatronDBEnable is enabled, we set syncstatus to something that a
                # cronjob will use for syncing with NL
                if (   C4::Context->preference('NorwegianPatronDBEnable')
                    && C4::Context->preference('NorwegianPatronDBEnable') == 1 )
                {
                    my $borrowersync = Koha::Database->new->schema->resultset('BorrowerSync')->find({
                        'synctype'       => 'norwegianpatrondb',
                        'borrowernumber' => $self->borrowernumber,
                    });
                    # Do not set to "edited" if syncstatus is "new". We need to sync as new before
                    # we can sync as changed. And the "new sync" will pick up all changes since
                    # the patron was created anyway.
                    if ( $borrowersync->syncstatus ne 'new' && $borrowersync->syncstatus ne 'delete' ) {
                        $borrowersync->update( { 'syncstatus' => 'edited' } );
                    }
                    # Set the value of 'sync'
                    # FIXME THIS IS BROKEN # $borrowersync->update( { 'sync' => $data{'sync'} } );

                    # Try to do the live sync
                    Koha::NorwegianPatronDB::NLSync({ 'borrowernumber' => $self->borrowernumber });
                }

                my $borrowers_log = C4::Context->preference("BorrowersLog");
                my $previous_cardnumber = $self_from_storage->cardnumber;
                if ($borrowers_log
                    && ( !defined $previous_cardnumber
                        || $previous_cardnumber ne $self->cardnumber )
                    )
                {
                    logaction(
                        "MEMBERS",
                        "MODIFY",
                        $self->borrowernumber,
                        to_json(
                            {
                                cardnumber_replaced => {
                                    previous_cardnumber => $previous_cardnumber,
                                    new_cardnumber      => $self->cardnumber,
                                }
                            },
                            { utf8 => 1, pretty => 1 }
                        )
                    );
                }

                logaction( "MEMBERS", "MODIFY", $self->borrowernumber,
                    "UPDATE (executed w/ arg: " . $self->borrowernumber . ")" )
                  if $borrowers_log;

                $self = $self->SUPER::store;
            }
        }
    );
    return $self;
}

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
            $self->holds->delete;

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

    return scalar Koha::Patron::Images->find( $self->borrowernumber );
}

sub library {
    my ( $self ) = @_;
    return Koha::Library->_new_from_dbic($self->_result->branchcode);
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

=head3 merge_with

    my $patron = Koha::Patrons->find($id);
    $patron->merge_with( \@patron_ids );

    This subroutine merges a list of patrons into the patron record. This is accomplished by finding
    all related patron ids for the patrons to be merged in other tables and changing the ids to be that
    of the keeper patron.

=cut

sub merge_with {
    my ( $self, $patron_ids ) = @_;

    my @patron_ids = @{ $patron_ids };

    # Ensure the keeper isn't in the list of patrons to merge
    @patron_ids = grep { $_ ne $self->id } @patron_ids;

    my $schema = Koha::Database->new()->schema();

    my $results;

    $self->_result->result_source->schema->txn_do( sub {
        foreach my $patron_id (@patron_ids) {
            my $patron = Koha::Patrons->find( $patron_id );

            next unless $patron;

            # Unbless for safety, the patron will end up being deleted
            $results->{merged}->{$patron_id}->{patron} = $patron->unblessed;

            while (my ($r, $field) = each(%$RESULTSET_PATRON_ID_MAPPING)) {
                my $rs = $schema->resultset($r)->search({ $field => $patron_id });
                $results->{merged}->{ $patron_id }->{updated}->{$r} = $rs->count();
                $rs->update({ $field => $self->id });
            }

            $patron->move_to_deleted();
            $patron->delete();
        }
    });

    return $results;
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
    my $issues = Koha::Checkouts->search($criteria);
    return 1 if $issues->count; # 0 || N

    # Check old issues table
    my $old_issues = Koha::Old::Checkouts->search($criteria);
    return $old_issues->count;  # 0 || N
}

=head3 is_debarred

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

=head3 is_expired

my $is_expired = $patron->is_expired;

Returns 1 if the patron is expired or 0;

=cut

sub is_expired {
    my ($self) = @_;
    return 0 unless $self->dateexpiry;
    return 0 if $self->dateexpiry =~ '^9999';
    return 1 if dt_from_string( $self->dateexpiry ) < dt_from_string->truncate( to => 'day' );
    return 0;
}

=head3 is_going_to_expire

my $is_going_to_expire = $patron->is_going_to_expire;

Returns 1 if the patron is going to expired, depending on the NotifyBorrowerDeparture pref or 0

=cut

sub is_going_to_expire {
    my ($self) = @_;

    my $delay = C4::Context->preference('NotifyBorrowerDeparture') || 0;

    return 0 unless $delay;
    return 0 unless $self->dateexpiry;
    return 0 if $self->dateexpiry =~ '^9999';
    return 1 if dt_from_string( $self->dateexpiry )->subtract( days => $delay ) < dt_from_string->truncate( to => 'day' );
    return 0;
}

=head3 update_password

my $updated = $patron->update_password( $userid, $password );

Update the userid and the password of a patron.
If the userid already exists, returns and let DBIx::Class warns
This will add an entry to action_logs if BorrowersLog is set.

=cut

sub update_password {
    my ( $self, $userid, $password ) = @_;
    eval { $self->userid($userid)->store; };
    return if $@; # Make sure the userid is not already in used by another patron

    return 0 if $password eq '****' or $password eq '';

    if ( C4::Context->preference('NorwegianPatronDBEnable') && C4::Context->preference('NorwegianPatronDBEnable') == 1 ) {
        # Update the hashed PIN in borrower_sync.hashed_pin, before Koha hashes it
        Koha::NorwegianPatronDB::NLUpdateHashedPIN( $self->borrowernumber, $password );
    }

    my $digest = Koha::AuthUtils::hash_password($password);
    $self->update(
        {
            password       => $digest,
            login_attempts => 0,
        }
    );

    logaction( "MEMBERS", "CHANGE PASS", $self->borrowernumber, "" ) if C4::Context->preference("BorrowersLog");
    return $digest;
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

    $self->dateexpiry($expiry_date);
    $self->date_renewed( dt_from_string() );
    $self->store();

    $self->add_enrolment_fee_if_needed;

    logaction( "MEMBERS", "RENEW", $self->borrowernumber, "Membership renewed" ) if C4::Context->preference("BorrowersLog");
    return dt_from_string( $expiry_date )->truncate( to => 'day' );
}

=head3 has_overdues

my $has_overdues = $patron->has_overdues;

Returns the number of patron's overdues

=cut

sub has_overdues {
    my ($self) = @_;
    my $dtf = Koha::Database->new->schema->storage->datetime_parser;
    return $self->_result->issues->search({ date_due => { '<' => $dtf->format_datetime( dt_from_string() ) } })->count;
}

=head3 track_login

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

=head3 move_to_deleted

my $is_moved = $patron->move_to_deleted;

Move a patron to the deletedborrowers table.
This can be done before deleting a patron, to make sure the data are not completely deleted.

=cut

sub move_to_deleted {
    my ($self) = @_;
    my $patron_infos = $self->unblessed;
    delete $patron_infos->{updated_on}; #This ensures the updated_on date in deletedborrowers will be set to the current timestamp
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

=head3 checkouts

my $checkouts = $patron->checkouts

=cut

sub checkouts {
    my ($self) = @_;
    my $checkouts = $self->_result->issues;
    return Koha::Checkouts->_new_from_dbic( $checkouts );
}

=head3 pending_checkouts

my $pending_checkouts = $patron->pending_checkouts

This method will return the same as $self->checkouts, but with a prefetch on
items, biblio and biblioitems.

It has been introduced to replaced the C4::Members::GetPendingIssues subroutine

It should not be used directly, prefer to access fields you need instead of
retrieving all these fields in one go.


=cut

sub pending_checkouts {
    my( $self ) = @_;
    my $checkouts = $self->_result->issues->search(
        {},
        {
            order_by => [
                { -desc => 'me.timestamp' },
                { -desc => 'issuedate' },
                { -desc => 'issue_id' }, # Sort by issue_id should be enough
            ],
            prefetch => { item => { biblio => 'biblioitems' } },
        }
    );
    return Koha::Checkouts->_new_from_dbic( $checkouts );
}

=head3 old_checkouts

my $old_checkouts = $patron->old_checkouts

=cut

sub old_checkouts {
    my ($self) = @_;
    my $old_checkouts = $self->_result->old_issues;
    return Koha::Old::Checkouts->_new_from_dbic( $old_checkouts );
}

=head3 get_overdues

my $overdue_items = $patron->get_overdues

Return the overdue items

=cut

sub get_overdues {
    my ($self) = @_;
    my $dtf = Koha::Database->new->schema->storage->datetime_parser;
    return $self->checkouts->search(
        {
            'me.date_due' => { '<' => $dtf->format_datetime(dt_from_string) },
        },
        {
            prefetch => { item => { biblio => 'biblioitems' } },
        }
    );
}

=head3 get_routing_lists

my @routinglists = $patron->get_routing_lists

Returns the routing lists a patron is subscribed to.

=cut

sub get_routing_lists {
    my ($self) = @_;
    my $routing_list_rs = $self->_result->subscriptionroutinglists;
    return Koha::Subscription::Routinglists->_new_from_dbic($routing_list_rs);
}

=head3 get_age

my $age = $patron->get_age

Return the age of the patron

=cut

sub get_age {
    my ($self)    = @_;
    my $today_str = dt_from_string->strftime("%Y-%m-%d");
    return unless $self->dateofbirth;
    my $dob_str   = dt_from_string( $self->dateofbirth )->strftime("%Y-%m-%d");

    my ( $dob_y,   $dob_m,   $dob_d )   = split /-/, $dob_str;
    my ( $today_y, $today_m, $today_d ) = split /-/, $today_str;

    my $age = $today_y - $dob_y;
    if ( $dob_m . $dob_d > $today_m . $today_d ) {
        $age--;
    }

    return $age;
}

=head3 account

my $account = $patron->account

=cut

sub account {
    my ($self) = @_;
    return Koha::Account->new( { patron_id => $self->borrowernumber } );
}

=head3 holds

my $holds = $patron->holds

Return all the holds placed by this patron

=cut

sub holds {
    my ($self) = @_;
    my $holds_rs = $self->_result->reserves->search( {}, { order_by => 'reservedate' } );
    return Koha::Holds->_new_from_dbic($holds_rs);
}

=head3 old_holds

my $old_holds = $patron->old_holds

Return all the historical holds for this patron

=cut

sub old_holds {
    my ($self) = @_;
    my $old_holds_rs = $self->_result->old_reserves->search( {}, { order_by => 'reservedate' } );
    return Koha::Old::Holds->_new_from_dbic($old_holds_rs);
}

=head3 notice_email_address

  my $email = $patron->notice_email_address;

Return the email address of patron used for notices.
Returns the empty string if no email address.

=cut

sub notice_email_address{
    my ( $self ) = @_;

    my $which_address = C4::Context->preference("AutoEmailPrimaryAddress");
    # if syspref is set to 'first valid' (value == OFF), look up email address
    if ( $which_address eq 'OFF' ) {
        return $self->first_valid_email_address;
    }

    return $self->$which_address || '';
}

=head3 first_valid_email_address

my $first_valid_email_address = $patron->first_valid_email_address

Return the first valid email address for a patron.
For now, the order  is defined as email, emailpro, B_email.
Returns the empty string if the borrower has no email addresses.

=cut

sub first_valid_email_address {
    my ($self) = @_;

    return $self->email() || $self->emailpro() || $self->B_email() || q{};
}

=head3 get_club_enrollments

=cut

sub get_club_enrollments {
    my ( $self, $return_scalar ) = @_;

    my $e = Koha::Club::Enrollments->search( { borrowernumber => $self->borrowernumber(), date_canceled => undef } );

    return $e if $return_scalar;

    return wantarray ? $e->as_list : $e;
}

=head3 get_enrollable_clubs

=cut

sub get_enrollable_clubs {
    my ( $self, $is_enrollable_from_opac, $return_scalar ) = @_;

    my $params;
    $params->{is_enrollable_from_opac} = $is_enrollable_from_opac
      if $is_enrollable_from_opac;
    $params->{is_email_required} = 0 unless $self->first_valid_email_address();

    $params->{borrower} = $self;

    my $e = Koha::Clubs->get_enrollable($params);

    return $e if $return_scalar;

    return wantarray ? $e->as_list : $e;
}

=head3 account_locked

my $is_locked = $patron->account_locked

Return true if the patron has reach the maximum number of login attempts (see pref FailedLoginAttempts).
Otherwise return false.
If the pref is not set (empty string, null or 0), the feature is considered as disabled.

=cut

sub account_locked {
    my ($self) = @_;
    my $FailedLoginAttempts = C4::Context->preference('FailedLoginAttempts');
    return ( $FailedLoginAttempts
          and $self->login_attempts
          and $self->login_attempts >= $FailedLoginAttempts )? 1 : 0;
}

=head3 can_see_patron_infos

my $can_see = $patron->can_see_patron_infos( $patron );

Return true if the patron (usually the logged in user) can see the patron's infos for a given patron

=cut

sub can_see_patron_infos {
    my ( $self, $patron ) = @_;
    return $self->can_see_patrons_from( $patron->library->branchcode );
}

=head3 can_see_patrons_from

my $can_see = $patron->can_see_patrons_from( $branchcode );

Return true if the patron (usually the logged in user) can see the patron's infos from a given library

=cut

sub can_see_patrons_from {
    my ( $self, $branchcode ) = @_;
    my $can = 0;
    if ( $self->branchcode eq $branchcode ) {
        $can = 1;
    } elsif ( $self->has_permission( { borrowers => 'view_borrower_infos_from_any_libraries' } ) ) {
        $can = 1;
    } elsif ( my $library_groups = $self->library->library_groups ) {
        while ( my $library_group = $library_groups->next ) {
            if ( $library_group->parent->has_child( $branchcode ) ) {
                $can = 1;
                last;
            }
        }
    }
    return $can;
}

=head3 libraries_where_can_see_patrons

my $libraries = $patron-libraries_where_can_see_patrons;

Return the list of branchcodes(!) of libraries the patron is allowed to see other patron's infos.
The branchcodes are arbitrarily returned sorted.
We are supposing here that the object is related to the logged in patron (use of C4::Context::only_my_library)

An empty array means no restriction, the patron can see patron's infos from any libraries.

=cut

sub libraries_where_can_see_patrons {
    my ( $self ) = @_;
    my $userenv = C4::Context->userenv;

    return () unless $userenv; # For tests, but userenv should be defined in tests...

    my @restricted_branchcodes;
    if (C4::Context::only_my_library) {
        push @restricted_branchcodes, $self->branchcode;
    }
    else {
        unless (
            $self->has_permission(
                { borrowers => 'view_borrower_infos_from_any_libraries' }
            )
          )
        {
            my $library_groups = $self->library->library_groups({ ft_hide_patron_info => 1 });
            if ( $library_groups->count )
            {
                while ( my $library_group = $library_groups->next ) {
                    my $parent = $library_group->parent;
                    if ( $parent->has_child( $self->branchcode ) ) {
                        push @restricted_branchcodes, $parent->children->get_column('branchcode');
                    }
                }
            }

            @restricted_branchcodes = ( $self->branchcode ) unless @restricted_branchcodes;
        }
    }

    @restricted_branchcodes = grep { defined $_ } @restricted_branchcodes;
    @restricted_branchcodes = uniq(@restricted_branchcodes);
    @restricted_branchcodes = sort(@restricted_branchcodes);
    return @restricted_branchcodes;
}

sub has_permission {
    my ( $self, $flagsrequired ) = @_;
    return unless $self->userid;
    # TODO code from haspermission needs to be moved here!
    return C4::Auth::haspermission( $self->userid, $flagsrequired );
}

=head3 is_adult

my $is_adult = $patron->is_adult

Return true if the patron has a category with a type Adult (A) or Organization (I)

=cut

sub is_adult {
    my ( $self ) = @_;
    return $self->category->category_type =~ /^(A|I)$/ ? 1 : 0;
}

=head3 is_child

my $is_child = $patron->is_child

Return true if the patron has a category with a type Child (C)

=cut
sub is_child {
    my( $self ) = @_;
    return $self->category->category_type eq 'C' ? 1 : 0;
}

=head3 has_valid_userid

my $patron = Koha::Patrons->find(42);
$patron->userid( $new_userid );
my $has_a_valid_userid = $patron->has_valid_userid

my $patron = Koha::Patron->new( $params );
my $has_a_valid_userid = $patron->has_valid_userid

Return true if the current userid of this patron is valid/unique, otherwise false.

Note that this should be done in $self->store instead and raise an exception if needed.

=cut

sub has_valid_userid {
    my ($self) = @_;

    return 0 unless $self->userid;

    return 0 if ( $self->userid eq C4::Context->config('user') );    # DB user

    my $already_exists = Koha::Patrons->search(
        {
            userid => $self->userid,
            (
                $self->in_storage
                ? ( borrowernumber => { '!=' => $self->borrowernumber } )
                : ()
            ),
        }
    )->count;
    return $already_exists ? 0 : 1;
}

=head3 generate_userid

my $patron = Koha::Patron->new( $params );
$patron->generate_userid

Generate a userid using the $surname and the $firstname (if there is a value in $firstname).

Set a generated userid ($firstname.$surname if there is a $firstname, or $surname if there is no value in $firstname) plus offset (0 if the $userid is unique, or a higher numeric value if not unique).

=cut

sub generate_userid {
    my ($self) = @_;
    my $offset = 0;
    my $firstname = $self->firstname // q{};
    my $surname = $self->surname // q{};
    #The script will "do" the following code and increment the $offset until the generated userid is unique
    do {
      $firstname =~ s/[[:digit:][:space:][:blank:][:punct:][:cntrl:]]//g;
      $surname =~ s/[[:digit:][:space:][:blank:][:punct:][:cntrl:]]//g;
      my $userid = lc(($firstname)? "$firstname.$surname" : $surname);
      $userid = unac_string('utf-8',$userid);
      $userid .= $offset unless $offset == 0;
      $self->userid( $userid );
      $offset++;
     } while (! $self->has_valid_userid );

     return $self;

}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'Borrower';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>
Alex Sassmannshausen <alex.sassmannshausen@ptfs-europe.com>

=cut

1;
