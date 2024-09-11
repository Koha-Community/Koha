package Koha::Patron;

# Copyright ByWater Solutions 2014
# Copyright PTFS Europe 2016
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

use List::MoreUtils qw( any uniq );
use JSON qw( to_json );
use Unicode::Normalize qw( NFKD );
use Try::Tiny;
use DateTime ();

use C4::Auth qw( checkpw_hash );
use C4::Context;
use C4::Letters qw( GetPreparedLetter EnqueueLetter SendQueuedMessages );
use C4::Log qw( logaction );
use C4::Scrubber;
use Koha::Account;
use Koha::ArticleRequests;
use Koha::AuthUtils;
use Koha::Caches;
use Koha::Checkouts;
use Koha::CirculationRules;
use Koha::Club::Enrollments;
use Koha::CurbsidePickups;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Encryption;
use Koha::Exceptions;
use Koha::Exceptions::Password;
use Koha::Holds;
use Koha::Old::Checkouts;
use Koha::OverdueRules;
use Koha::Patron::Attributes;
use Koha::Patron::Categories;
use Koha::Patron::Consents;
use Koha::Patron::Debarments;
use Koha::Patron::HouseboundProfile;
use Koha::Patron::HouseboundRole;
use Koha::Patron::Images;
use Koha::Patron::Messages;
use Koha::Patron::Modifications;
use Koha::Patron::MessagePreferences;
use Koha::Patron::Relationships;
use Koha::Patron::Restrictions;
use Koha::Patrons;
use Koha::Plugins;
use Koha::Recalls;
use Koha::Result::Boolean;
use Koha::Subscription::Routinglists;
use Koha::Token;
use Koha::Virtualshelves;

use base qw(Koha::Object);

use constant ADMINISTRATIVE_LOCKOUT => -1;

our $RESULTSET_PATRON_ID_MAPPING = {
    Accountline          => 'borrowernumber',
    Aqbasketuser         => 'borrowernumber',
    Aqbudget             => 'budget_owner_id',
    Aqbudgetborrower     => 'borrowernumber',
    ArticleRequest       => 'borrowernumber',
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

    my $max = $self->cardnumber;
    Koha::Plugins->call( 'patron_barcode_transform', \$max );

    $max ||= Koha::Patrons->search({
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
    my $self   = shift;
    my $params = @_ ? shift : {};

    my $guarantors = $params->{guarantors} // [];

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

            unless ( $self->category->in_storage ) {
                Koha::Exceptions::Object::FKConstraint->throw(
                    broken_fk => 'categorycode',
                    value     => $self->categorycode,
                );
            }

            $self->trim_whitespaces;

            my $new_cardnumber = $self->cardnumber;
            Koha::Plugins->call( 'patron_barcode_transform', \$new_cardnumber );
            $self->cardnumber($new_cardnumber);

            # Set surname to uppercase if uppercasesurname is true
            $self->surname( uc( $self->surname ) )
                if C4::Context->preference("uppercasesurnames");

            $self->relationship(undef)    # We do not want to store an empty string in this field
                if defined $self->relationship
                and $self->relationship eq "";

            for my $note_field (qw( borrowernotes opacnote )) {
                if ( !$self->in_storage || $self->_result->is_column_changed($note_field) ) {
                    $self->$note_field( C4::Scrubber->new('note')->scrub( $self->$note_field ) );
                }
            }

            unless ( $self->in_storage ) {    #AddMember

                # Generate a valid userid/login if needed
                $self->generate_userid unless $self->userid;
                Koha::Exceptions::Patron::InvalidUserid->throw( userid => $self->userid )
                    unless $self->has_valid_userid;

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
                    :                                 undef;
                $self->privacy($default_privacy);

                # Call any check_password plugins if password is passed
                if ( C4::Context->config("enable_plugins") && $self->password ) {
                    my @plugins = Koha::Plugins->new()->GetPlugins(
                        {
                            method => 'check_password',
                        }
                    );
                    foreach my $plugin (@plugins) {

                        # This plugin hook will also be used by a plugin for the Norwegian national
                        # patron database. This is why we need to pass both the password and the
                        # borrowernumber to the plugin.
                        my $ret = $plugin->check_password(
                            {
                                password       => $self->password,
                                borrowernumber => $self->borrowernumber
                            }
                        );
                        if ( $ret->{'error'} == 1 ) {
                            Koha::Exceptions::Password::Plugin->throw();
                        }
                    }
                }

                # Make a copy of the plain text password for later use
                $self->plain_text_password( $self->password );

                $self->password_expiration_date(
                      $self->password
                    ? $self->category->get_password_expiry_date || undef
                    : undef
                );

                # Create a disabled account if no password provided
                $self->password(
                    $self->password
                    ? Koha::AuthUtils::hash_password( $self->password )
                    : '!'
                );

                $self->borrowernumber(undef);

                if (    C4::Context->preference('ChildNeedsGuarantor')
                    and ( $self->is_child or $self->category->can_be_guarantee )
                    and $self->contactname eq ""
                    and !@$guarantors )
                {
                    Koha::Exceptions::Patron::Relationship::NoGuarantor->throw();
                }

                foreach my $guarantor (@$guarantors) {
                    if ( $guarantor->is_child ) {
                        Koha::Exceptions::Patron::Relationship::InvalidRelationship->throw( invalid_guarantor => 1 );
                    }
                }

                $self = $self->SUPER::store;

                $self->add_enrolment_fee_if_needed(0);

                logaction( "MEMBERS", "CREATE", $self->borrowernumber, "" )
                    if C4::Context->preference("BorrowersLog");
            } else {    #ModMember

                my $self_from_storage = $self->get_from_storage;

                # Do not accept invalid userid here
                $self->generate_userid unless $self->userid;
                Koha::Exceptions::Patron::InvalidUserid->throw( userid => $self->userid )
                    unless $self->has_valid_userid;

                # If a borrower has set their privacy to never we should immediately anonymize
                # their checkouts
                if ( $self->privacy() == 2 && $self_from_storage->privacy() != 2 ) {
                    try {
                        $self->old_checkouts->anonymize;
                    } catch {
                        Koha::Exceptions::Patron::FailedAnonymizing->throw( error => @_ );
                    };
                }

                # Password must be updated using $self->set_password
                $self->password( $self_from_storage->password );

                if ( $self->category->categorycode ne $self_from_storage->category->categorycode ) {

                    # Add enrolement fee on category change if required
                    $self->add_enrolment_fee_if_needed(1)
                        if C4::Context->preference('FeeOnChangePatronCategory');

                    # Clean up guarantors on category change if required
                    $self->guarantor_relationships->delete
                        unless ( $self->category->can_be_guarantee );

                }

                my @existing_guarantors = $self->guarantor_relationships()->guarantors->as_list;
                push @$guarantors, @existing_guarantors;

                if (    C4::Context->preference('ChildNeedsGuarantor')
                    and ( $self->is_child or $self->category->can_be_guarantee )
                    and $self->contactname eq ""
                    and !@$guarantors )
                {
                    Koha::Exceptions::Patron::Relationship::NoGuarantor->throw();
                }

                foreach my $guarantor (@$guarantors) {
                    if ( $guarantor->is_child ) {
                        Koha::Exceptions::Patron::Relationship::InvalidRelationship->throw( invalid_guarantor => 1 );
                    }
                }

                # Actionlogs
                if ( C4::Context->preference("BorrowersLog") ) {
                    my $info;
                    my $from_storage = $self_from_storage->unblessed;
                    my $from_object  = $self->unblessed;

                    # Object's dateexpiry is a DateTime object which stringifies to iso8601 datetime,
                    # but the column in only a date so we need to convert the datetime to just a date
                    # to know if it has actually changed.
                    $from_object->{dateexpiry} = dt_from_string( $from_object->{dateexpiry} )->ymd
                        if $from_object->{dateexpiry};

                    my @skip_fields = (qw/lastseen updated_on/);
                    for my $key ( keys %{$from_storage} ) {
                        next if any { /$key/ } @skip_fields;
                        my $storage_value = $from_storage->{$key} // q{};
                        my $object_value  = $from_object->{$key}  // q{};
                        if (   ( $storage_value || $object_value )
                            && ( $storage_value ne $object_value ) )
                        {
                            $info->{$key} = {
                                before => $from_storage->{$key},
                                after  => $from_object->{$key}
                            };
                        }
                    }

                    if ( defined($info) ) {
                        logaction(
                            "MEMBERS",
                            "MODIFY",
                            $self->borrowernumber,
                            to_json(
                                $info,
                                { utf8 => 1, pretty => 1, canonical => 1 }
                            )
                        );
                    }
                }

                # Final store
                $self = $self->SUPER::store;
            }
        }
    );
    return $self;
}

=head3 delete

$patron->delete

Delete patron's holds, lists and finally the patron.

Lists owned by the borrower are deleted or ownership is transferred depending on the
ListOwnershipUponPatronDeletion pref, but entries from the borrower to other lists are kept.

=cut

sub delete {
    my ($self) = @_;

    my $anonymous_patron = C4::Context->preference("AnonymousPatron");
    Koha::Exceptions::Patron::FailedDeleteAnonymousPatron->throw() if $anonymous_patron && $self->id eq $anonymous_patron;

    # Check if patron is protected
    Koha::Exceptions::Patron::FailedDeleteProtectedPatron->throw() if $self->protected == 1;

    $self->_result->result_source->schema->txn_do(
        sub {
            # Cancel Patron's holds
            my $holds = $self->holds;
            while( my $hold = $holds->next ){
                $hold->cancel;
            }

            # Handle lists (virtualshelves)
            $self->virtualshelves->disown_or_delete;

            # We cannot have a FK on borrower_modifications.borrowernumber, the table is also used
            # for patron selfreg
            $_->delete for Koha::Patron::Modifications->search( { borrowernumber => $self->borrowernumber } )->as_list;

            $self->SUPER::delete;

            logaction( "MEMBERS", "DELETE", $self->borrowernumber, "" ) if C4::Context->preference("BorrowersLog");
        }
    );
    return $self;
}

=head3 category

my $patron_category = $patron->category

Return the patron category for this patron

=cut

sub category {
    my ( $self ) = @_;
    return Koha::Patron::Category->_new_from_dbic( $self->_result->categorycode );
}

=head3 image

=cut

sub image {
    my ( $self ) = @_;

    return Koha::Patron::Images->find( $self->borrowernumber );
}

=head3 library

Returns a Koha::Library object representing the patron's home library.

=cut

sub library {
    my ( $self ) = @_;
    return Koha::Library->_new_from_dbic($self->_result->branchcode);
}

=head3 sms_provider

Returns a Koha::SMS::Provider object representing the patron's SMS provider.

=cut

sub sms_provider {
    my ( $self ) = @_;
    my $sms_provider_rs = $self->_result->sms_provider;
    return unless $sms_provider_rs;
    return Koha::SMS::Provider->_new_from_dbic($sms_provider_rs);
}

=head3 guarantor_relationships

Returns Koha::Patron::Relationships object for this patron's guarantors

Returns the set of relationships for the patrons that are guarantors for this patron.

Note that a guarantor should exist as a patron in Koha; it was not possible
to add them without a guarantor_id in the interface for some time. Bug 30472
restricts it on db level.

=cut

sub guarantor_relationships {
    my ($self) = @_;

    return Koha::Patron::Relationships->search( { guarantee_id => $self->id } );
}

=head3 is_guarantee

Returns true if the patron has a guarantor.

=cut

sub is_guarantee {
    my ($self) = @_;
    return $self->guarantor_relationships()->count();
}


=head3 guarantee_relationships

Returns Koha::Patron::Relationships object for this patron's guarantors

Returns the set of relationships for the patrons that are guarantees for this patron.

The method returns Koha::Patron::Relationship objects for the sake
of consistency with the guantors method.
A guarantee by definition must exist as a patron in Koha.

=cut

sub guarantee_relationships {
    my ($self) = @_;

    return Koha::Patron::Relationships->search(
        { guarantor_id => $self->id },
        {
            prefetch => 'guarantee',
            order_by => { -asc => [ 'guarantee.surname', 'guarantee.firstname' ] },
        }
    );
}

=head3 is_guarantor

Returns true if the patron is a guarantor.

=cut

sub is_guarantor {
    my ($self) = @_;
    return $self->guarantee_relationships()->count();
}


=head3 relationships_debt

Returns the amount owed by the patron's guarantors *and* the other guarantees of those guarantors

=cut

sub relationships_debt {
    my ($self, $params) = @_;

    my $include_guarantors  = $params->{include_guarantors};
    my $only_this_guarantor = $params->{only_this_guarantor};
    my $include_this_patron = $params->{include_this_patron};

    my @guarantors;
    if ( $only_this_guarantor ) {
        @guarantors = $self->guarantee_relationships->count ? ( $self ) : ();
        Koha::Exceptions::BadParameter->throw( { parameter => 'only_this_guarantor' } ) unless @guarantors;
    } elsif ( $self->guarantor_relationships->count ) {
        # I am a guarantee, just get all my guarantors
        @guarantors = $self->guarantor_relationships->guarantors->as_list;
    } else {
        # I am a guarantor, I need to get all the guarantors of all my guarantees
        @guarantors = map { $_->guarantor_relationships->guarantors->as_list } $self->guarantee_relationships->guarantees->as_list;
    }

    my $non_issues_charges = 0;
    my $seen = $include_this_patron ? {} : { $self->id => 1 }; # For tracking members already added to the total
    foreach my $guarantor (@guarantors) {
        $non_issues_charges += $guarantor->account->non_issues_charges if $include_guarantors && !$seen->{ $guarantor->id };

        # We've added what the guarantor owes, not added in that guarantor's guarantees as well
        my @guarantees = map { $_->guarantee } $guarantor->guarantee_relationships->as_list;
        my $guarantees_non_issues_charges = 0;
        foreach my $guarantee (@guarantees) {
            next if $seen->{ $guarantee->id };
            $guarantees_non_issues_charges += $guarantee->account->non_issues_charges;
            # Mark this guarantee as seen so we don't double count a guarantee linked to multiple guarantors
            $seen->{ $guarantee->id } = 1;
        }

        $non_issues_charges += $guarantees_non_issues_charges;
        $seen->{ $guarantor->id } = 1;
    }

    return $non_issues_charges;
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
    my ($self) = @_;

    my @guarantors = $self->guarantor_relationships()->guarantors()->as_list;

    return unless @guarantors;

    my @siblings =
      map { $_->guarantee_relationships()->guarantees()->as_list } @guarantors;

    return unless @siblings;

    my %seen;
    @siblings =
      grep { !$seen{ $_->id }++ && ( $_->id != $self->id ) } @siblings;

    return Koha::Patrons->search( { borrowernumber => { -in => [ map { $_->id } @siblings ] } } );
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

    my $anonymous_patron = C4::Context->preference("AnonymousPatron");
    return if $anonymous_patron && $self->id eq $anonymous_patron;

    # Do not merge other patrons into a protected patron
    return if $self->protected;

    my @patron_ids = @{ $patron_ids };

    # Ensure the keeper isn't in the list of patrons to merge
    @patron_ids = grep { $_ ne $self->id } @patron_ids;

    my $schema = Koha::Database->new()->schema();

    my $results;

    $self->_result->result_source->schema->txn_do( sub {
        foreach my $patron_id (@patron_ids) {

            next if $patron_id eq $anonymous_patron;

            my $patron = Koha::Patrons->find( $patron_id );

            next unless $patron;

            # Do not merge protected patrons into other patrons
            next if $patron->protected;

            # Unbless for safety, the patron will end up being deleted
            $results->{merged}->{$patron_id}->{patron} = $patron->unblessed;

            my $attributes = $patron->extended_attributes;
            my $new_attributes = [
                map { { code => $_->code, attribute => $_->attribute } }
                    $attributes->as_list
            ];
            $attributes->delete; # We need to delete before trying to merge them to prevent exception on unique and repeatable
            for my $attribute ( @$new_attributes ) {
                try {
                    $self->add_extended_attribute($attribute);
                } catch {
                    # Don't block the merge if there is a non-repeatable attribute that cannot be added to the current patron.
                    unless ( $_->isa('Koha::Exceptions::Patron::Attribute::NonRepeatable') ) {
                        $_->rethrow;
                    }
                };
            }

            while (my ($r, $field) = each(%$RESULTSET_PATRON_ID_MAPPING)) {
                my $rs = $schema->resultset($r)->search({ $field => $patron_id });
                $results->{merged}->{ $patron_id }->{updated}->{$r} = $rs->count();
                $rs->update({ $field => $self->id });
                if ( $r eq 'BorrowerDebarment' ) {
                    Koha::Patron::Debarments::UpdateBorrowerDebarmentFlags($self->id);
                }
            }

            $patron->move_to_deleted();
            $patron->delete();
        }
    });

    return $results;
}


=head3 messaging_preferences

    my $patron = Koha::Patrons->find($id);
    $patron->messaging_preferences();

=cut

sub messaging_preferences {
    my ( $self ) = @_;

    return Koha::Patron::MessagePreferences->search({
        borrowernumber => $self->borrowernumber,
    });
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

    my @item_nos;
    my $biblio = Koha::Biblios->find( $item->{biblionumber} );
    if ( $biblio->is_serial ) {
        push @item_nos, $item->{itemnumber};
    } else {
        # Get all itemnumbers for given bibliographic record.
        @item_nos = $biblio->items->get_column( 'itemnumber' );
    }

    # Create (old)issues search criteria
    my $criteria = {
        borrowernumber => $self->borrowernumber,
        itemnumber => \@item_nos,
    };

    my $delay = C4::Context->preference('CheckPrevCheckoutDelay') || 0;
    if ($delay) {
        my $dtf = Koha::Database->new->schema->storage->datetime_parser;
        my $newer_than = dt_from_string()->subtract( days => $delay );
        $criteria->{'returndate'} = { '>'   =>  $dtf->format_datetime($newer_than), };
    }

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

=head3 is_active

$patron->is_active({ [ since => $date ], [ days|weeks|months|years => $value ] })

A patron is considered 'active' if the following conditions hold:

    - account did not expire
    - account has not been anonymized
    - enrollment or lastseen within period specified

Note: lastseen is updated for triggers defined in preference
TrackLastPatronActivityTriggers. This includes logins, issues, holds, etc.

The period to check is defined by $date or $value in days, weeks or months. You should
pass one of those; otherwise an exception is thrown.

=cut

sub is_active {
    my ( $self, $params ) = @_;
    return 0 if $self->is_expired or $self->anonymized;

    my $dt;
    if ( $params->{since} ) {
        $dt = dt_from_string( $params->{since}, 'iso' );
    } elsif ( grep { $params->{$_} } qw(days weeks months years) ) {
        $dt = dt_from_string();
        foreach my $duration (qw(days weeks months years)) {
            $dt = $dt->subtract( $duration => $params->{$duration} ) if $params->{$duration};
        }
    } else {
        Koha::Exceptions::MissingParameter->throw('is_active needs date or period');
    }

    # Enrollment within this period?
    return 1 if DateTime->compare( dt_from_string( $self->dateenrolled ), $dt ) > -1;

    # We look at lastseen regardless of TrackLastPatronActivityTriggers. If lastseen is set
    # recently, the triggers may have been removed after that, etc.
    return 1 if $self->lastseen && DateTime->compare( dt_from_string( $self->lastseen ), $dt ) > -1;

    return 0;
}

=head3 password_expired

my $password_expired = $patron->password_expired;

Returns 1 if the patron's password is expired or 0;

=cut

sub password_expired {
    my ($self) = @_;
    return 0 unless $self->password_expiration_date;
    return 1 if dt_from_string( $self->password_expiration_date ) <= dt_from_string->truncate( to => 'day' );
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
    return 1 if dt_from_string( $self->dateexpiry, undef, 'floating' )->subtract( days => $delay ) < dt_from_string(undef, undef, 'floating')->truncate( to => 'day' );
    return 0;
}

=head3 set_password

    $patron->set_password({ password => $plain_text_password [, skip_validation => 1, action => NAME ] });

Set the patron's password.

Allows optional action parameter to change name of action logged (when enabled). Used for reset password.

=head4 Exceptions

The passed string is validated against the current password enforcement policy.
Validation can be skipped by passing the I<skip_validation> parameter.

Exceptions are thrown if the password is not good enough.

=over 4

=item Koha::Exceptions::Password::TooShort

=item Koha::Exceptions::Password::WhitespaceCharacters

=item Koha::Exceptions::Password::TooWeak

=item Koha::Exceptions::Password::Plugin (if a "check password" plugin is enabled)

=back

=cut

sub set_password {
    my ( $self, $args ) = @_;

    my $password = $args->{password};
    my $action   = $args->{action} || "CHANGE PASS";

    unless ( $args->{skip_validation} ) {
        my ( $is_valid, $error ) = Koha::AuthUtils::is_password_valid( $password, $self->category );

        if ( !$is_valid ) {
            if ( $error eq 'too_short' ) {
                my $min_length = $self->category->effective_min_password_length;
                $min_length = 3 if not $min_length or $min_length < 3;

                my $password_length = length($password);
                Koha::Exceptions::Password::TooShort->throw(
                    length => $password_length, min_length => $min_length );
            }
            elsif ( $error eq 'has_whitespaces' ) {
                Koha::Exceptions::Password::WhitespaceCharacters->throw();
            }
            elsif ( $error eq 'too_weak' ) {
                Koha::Exceptions::Password::TooWeak->throw();
            }
        }
    }

    if ( C4::Context->config("enable_plugins") ) {
        # Call any check_password plugins
        my @plugins = Koha::Plugins->new()->GetPlugins({
            method => 'check_password',
        });
        foreach my $plugin ( @plugins ) {
            # This plugin hook will also be used by a plugin for the Norwegian national
            # patron database. This is why we need to pass both the password and the
            # borrowernumber to the plugin.
            my $ret = $plugin->check_password(
                {
                    password       => $password,
                    borrowernumber => $self->borrowernumber
                }
            );
            # This plugin hook will also be used by a plugin for the Norwegian national
            # patron database. This is why we need to call the actual plugins and then
            # check skip_validation afterwards.
            if ( $ret->{'error'} == 1 && !$args->{skip_validation} ) {
                Koha::Exceptions::Password::Plugin->throw();
            }
        }
    }

    if ( C4::Context->preference('NotifyPasswordChange') ) {
        my $self_from_storage = $self->get_from_storage;
        if ( !C4::Auth::checkpw_hash( $password, $self_from_storage->password ) ) {
            my $emailaddr = $self_from_storage->notice_email_address;

            # if we manage to find a valid email address, send notice
            if ($emailaddr) {
                my $letter = C4::Letters::GetPreparedLetter(
                    module      => 'members',
                    letter_code => 'PASSWORD_CHANGE',
                    branchcode  => $self_from_storage->branchcode,
                    ,
                    lang   => $self_from_storage->lang || 'default',
                    tables => {
                        'branches'  => $self_from_storage->branchcode,
                        'borrowers' => $self_from_storage->borrowernumber,
                    },
                    want_librarian => 1,
                ) or return;

                my $message_id = C4::Letters::EnqueueLetter(
                    {
                        letter                 => $letter,
                        borrowernumber         => $self_from_storage->id,
                        to_address             => $emailaddr,
                        message_transport_type => 'email'
                    }
                );
                C4::Letters::SendQueuedMessages( { message_id => $message_id } ) if $message_id;
            }
        }
    }

    my $digest = Koha::AuthUtils::hash_password($password);

    $self->password_expiration_date( $self->category->get_password_expiry_date || undef );

    # We do not want to call $self->store and retrieve password from DB
    $self->password($digest);
    $self->login_attempts(0);
    $self->SUPER::store;

    logaction( "MEMBERS", $action, $self->borrowernumber, "" )
        if C4::Context->preference("BorrowersLog");

    return $self;
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

    $self->add_enrolment_fee_if_needed(1);

    logaction( "MEMBERS", "RENEW", $self->borrowernumber, "Membership renewed" ) if C4::Context->preference("BorrowersLog");
    return dt_from_string( $expiry_date )->truncate( to => 'day' );
}

=head3 has_overdues

my $has_overdues = $patron->has_overdues;

Returns the number of patron's overdues

=cut

sub has_overdues {
    my ($self) = @_;
    my $date = dt_from_string();
    my $dtf = Koha::Database->new->schema->storage->datetime_parser;
    return $self->_result->issues->search({ date_due => { '<' => $dtf->format_datetime($date) } })->count;
}



=head3 has_restricting_overdues

my $has_restricting_overdues = $patron->has_restricting_overdues({ issue_branchcode => $branchcode });

Returns true if patron has overdues that would result in debarment.

=cut

sub has_restricting_overdues {
    my ( $self, $params ) = @_;
    $params //= {};
    my $date = dt_from_string()->truncate( to => 'day' );

    # If ignoring unrestricted overdues, calculate which delay value for
    # overdue messages is set with restrictions. Then only include overdue
    # issues older than that date when counting.
    #TODO: bail out/throw exception if $params->{issue_branchcode} not set?
    my $debarred_delay = _get_overdue_debarred_delay( $params->{issue_branchcode}, $self->categorycode() );
    return 0 unless defined $debarred_delay;

    # Emulate the conditions in overdue_notices.pl.
    # The overdue_notices-script effectively truncates both issues.date_due and current date
    # to days when selecting overdue issues.
    # Hours and minutes for issues.date_due is usually set to 23 and 59 respectively, though can theoretically
    # be set to any other value (truncated to minutes, except if CalcDateDue gets a $startdate)
    #
    # No matter what time of day date_due is set to, overdue_notices.pl will select all issues that are due
    # the current date or later. We can emulate this query by instead of truncating both to days in the SQL-query,
    # using the condition that date_due must be less then the current date truncated to days (time set to 00:00:00)
    # offset by one day in the future.

    $date->add( days => 1 );

    my $calendar;
    if ( C4::Context->preference('OverdueNoticeCalendar') ) {
        $calendar = Koha::Calendar->new( branchcode => $params->{issue_branchcode} );
    }

    my $dtf    = Koha::Database->new->schema->storage->datetime_parser;
    my $issues = $self->_result->issues->search( { date_due => { '<' => $dtf->format_datetime($date) } } );
    my $now    = dt_from_string();

    while ( my $issue = $issues->next ) {
        my $days_between =
            C4::Context->preference('OverdueNoticeCalendar')
            ? $calendar->days_between( dt_from_string( $issue->date_due ), $now )->in_units('days')
            : $now->delta_days( dt_from_string( $issue->date_due ) )->in_units('days');
        if ( $days_between >= $debarred_delay ) {
            return 1;
        }
    }
    return 0;
}

# Fetch first delayX value from overduerules where debarredX is set, or 0 for no delay
sub _get_overdue_debarred_delay {
    my ( $branchcode, $categorycode ) = @_;
    my $dbh = C4::Context->dbh();

    # We get default rules if there is no rule for this branch
    my $rule = Koha::OverdueRules->find(
        {
            branchcode   => $branchcode,
            categorycode => $categorycode
        }
        )
        || Koha::OverdueRules->find(
        {
            branchcode   => q{},
            categorycode => $categorycode
        }
        );

    if ($rule) {
        return $rule->delay1 if $rule->debarred1;
        return $rule->delay2 if $rule->debarred2;
        return $rule->delay3 if $rule->debarred3;
    }
}

=head3 update_lastseen

  $patron->update_lastseen('activity');

Updates the lastseen field, limited to one update per day, whenever the activity passed is
listed in TrackLastPatronActivityTriggers.

The method should be called upon successful completion of the activity.

=cut

sub update_lastseen {
    my ( $self, $activity ) = @_;
    my $tracked_activities = {
        map { ( lc $_, 1 ); } split /\s*\,\s*/,
        C4::Context->preference('TrackLastPatronActivityTriggers')
    };
    return $self unless $tracked_activities->{$activity};

    my $cache     = Koha::Caches->get_instance();
    my $cache_key = "track_activity_" . $self->borrowernumber;
    my $cached    = $cache->get_from_cache($cache_key);
    my $now       = dt_from_string();
    return $self if $cached && $cached eq $now->ymd;

    $self->lastseen($now)->store;
    $cache->set_in_cache( $cache_key, $now->ymd );
    return $self;
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

=head3 can_request_article

    if ( $patron->can_request_article( $library->id ) ) { ... }

Returns true if the patron can request articles. As limits apply for the patron
on the same day, those completed the same day are considered as current.

A I<library_id> can be passed as parameter, falling back to userenv if absent.

=cut

sub can_request_article {
    my ($self, $library_id) = @_;

    $library_id //= C4::Context->userenv ? C4::Context->userenv->{'branch'} : undef;

    my $rule = Koha::CirculationRules->get_effective_rule(
        {
            branchcode   => $library_id,
            categorycode => $self->categorycode,
            rule_name    => 'open_article_requests_limit'
        }
    );

    my $limit = ($rule) ? $rule->rule_value : undef;

    return 1 unless defined $limit;

    my $count = Koha::ArticleRequests->search(
        [   { borrowernumber => $self->borrowernumber, status => [ 'REQUESTED', 'PENDING', 'PROCESSING' ] },
            { borrowernumber => $self->borrowernumber, status => 'COMPLETED', updated_on => { '>=' => \'CAST(NOW() AS DATE)' } },
        ]
    )->count;
    return $count < $limit ? 1 : 0;
}

=head3 article_request_fee

    my $fee = $patron->article_request_fee(
        {
          [ library_id => $library->id, ]
        }
    );

Returns the fee to be charged to the patron when it places an article request.

A I<library_id> can be passed as parameter, falling back to userenv if absent.

=cut

sub article_request_fee {
    my ($self, $params) = @_;

    my $library_id = $params->{library_id};

    $library_id //= C4::Context->userenv ? C4::Context->userenv->{'branch'} : undef;

    my $rule = Koha::CirculationRules->get_effective_rule(
        {
            branchcode   => $library_id,
            categorycode => $self->categorycode,
            rule_name    => 'article_request_fee'
        }
    );

    my $fee = ($rule) ? $rule->rule_value + 0 : 0;

    return $fee;
}

=head3 add_article_request_fee_if_needed

    my $fee = $patron->add_article_request_fee_if_needed(
        {
          [ item_id    => $item->id,
            library_id => $library->id, ]
        }
    );

If an article request fee needs to be charged, it adds a debit to the patron's
account.

Returns the fee line.

A I<library_id> can be passed as parameter, falling back to userenv if absent.

=cut

sub add_article_request_fee_if_needed {
    my ($self, $params) = @_;

    my $library_id = $params->{library_id};
    my $item_id    = $params->{item_id};

    $library_id //= C4::Context->userenv ? C4::Context->userenv->{'branch'} : undef;

    my $amount = $self->article_request_fee(
        {
            library_id => $library_id,
        }
    );

    my $debit_line;

    if ( $amount > 0 ) {
        $debit_line = $self->account->add_debit(
            {
                amount     => $amount,
                user_id    => C4::Context->userenv ? C4::Context->userenv->{'number'} : undef,
                interface  => C4::Context->interface,
                library_id => $library_id,
                type       => 'ARTICLE_REQUEST',
                item_id    => $item_id,
            }
        );
    }

    return $debit_line;
}

=head3 article_requests

    my $article_requests = $patron->article_requests;

Returns the patron article requests.

=cut

sub article_requests {
    my ($self) = @_;

    return Koha::ArticleRequests->_new_from_dbic( scalar $self->_result->article_requests );
}

=head3 add_enrolment_fee_if_needed

my $enrolment_fee = $patron->add_enrolment_fee_if_needed($renewal);

Add enrolment fee for a patron if needed.

$renewal - boolean denoting whether this is an account renewal or not

=cut

sub add_enrolment_fee_if_needed {
    my ($self, $renewal) = @_;
    my $enrolment_fee = $self->category->enrolmentfee;
    if ( $enrolment_fee && $enrolment_fee > 0 ) {
        my $type = $renewal ? 'ACCOUNT_RENEW' : 'ACCOUNT';
        $self->account->add_debit(
            {
                amount     => $enrolment_fee,
                user_id    => C4::Context->userenv ? C4::Context->userenv->{'number'} : undef,
                interface  => C4::Context->interface,
                library_id => C4::Context->userenv ? C4::Context->userenv->{'branch'} : undef,
                type       => $type
            }
        );
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

=head3 overdues

my $overdue_items = $patron->overdues

Return the overdue items

=cut

sub overdues {
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


=head3 restrictions

  my $restrictions = $patron->restrictions;

Returns the patron restrictions.

=cut

sub restrictions {
    my ($self) = @_;
    my $restrictions_rs = $self->_result->restrictions;
    return Koha::Patron::Restrictions->_new_from_dbic($restrictions_rs);
}

=head3 get_routing_lists

my $routinglists = $patron->get_routing_lists

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

    return unless $self->dateofbirth;

    #Set timezone to floating to avoid any datetime math issues caused by DST
    my $date_of_birth = dt_from_string( $self->dateofbirth, undef, 'floating' );
    my $today         = dt_from_string(undef, undef, 'floating')->truncate( to => 'day' );

    return $today->subtract_datetime( $date_of_birth )->years;
}

=head3 is_valid_age

my $is_valid = $patron->is_valid_age

Return 1 if patron's age is between allowed limits, returns 0 if it's not.

=cut

sub is_valid_age {
    my ($self) = @_;
    my $age = $self->get_age;

    my $patroncategory = $self->category;
    my ($low,$high) = ($patroncategory->dateofbirthrequired, $patroncategory->upperagelimit);

    return (defined($age) && (($high && ($age > $high)) or ($low && ($age < $low)))) ? 0 : 1;
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

=head3 curbside_pickups

my $curbside_pickups = $patron->curbside_pickups;

Return all the curbside pickups for this patron

=cut

sub curbside_pickups {
    my ($self) = @_;
    my $curbside_pickups_rs = $self->_result->curbside_pickups_borrowernumbers->search;
    return Koha::CurbsidePickups->_new_from_dbic($curbside_pickups_rs);
}

=head3 bookings

  my $bookings = $item->bookings();

Returns the bookings for this patron.

=cut

sub bookings {
    my ( $self, $params ) = @_;
    my $bookings_rs = $self->_result->bookings->search($params);
    return Koha::Bookings->_new_from_dbic( $bookings_rs );
}

=head3 return_claims

my $return_claims = $patron->return_claims

=cut

sub return_claims {
    my ($self) = @_;
    my $return_claims = $self->_result->return_claims_borrowernumbers;
    return Koha::Checkouts::ReturnClaims->_new_from_dbic( $return_claims );
}

=head3 notice_email_address

  my $email = $patron->notice_email_address;

Return the email address of patron used for notices.
Returns the empty string if no email address.

=cut

sub notice_email_address{
    my ( $self ) = @_;

    my $which_address = C4::Context->preference("EmailFieldPrimary");

    # if syspref is set to 'first valid' (value == OFF), look up email address
    if ( $which_address eq 'OFF' ) {
        return $self->first_valid_email_address;
    }

    # if syspref is set to 'selected addresses' (value == MULTI), look up email addresses
    if ( $which_address eq 'MULTI' ) {
        my @addresses;
        my $selected_fields = C4::Context->preference("EmailFieldSelection");
        for my $email_field ( split ",", $selected_fields ) {
            my $email_address = $self->$email_field;
            push @addresses, $email_address if $email_address;
        }
        return join(",",@addresses);
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

    my $email = q{};

    my @fields = split /\s*\|\s*/,
      C4::Context->preference('EmailFieldPrecedence');
    for my $field (@fields) {
        $email = $self->$field;
        last if ($email);
    }

    return $email;
}

=head3 get_club_enrollments

=cut

sub get_club_enrollments {
    my ( $self ) = @_;

    return Koha::Club::Enrollments->search( { borrowernumber => $self->borrowernumber(), date_canceled => undef } );
}

=head3 get_enrollable_clubs

=cut

sub get_enrollable_clubs {
    my ( $self, $is_enrollable_from_opac ) = @_;

    my $params;
    $params->{is_enrollable_from_opac} = $is_enrollable_from_opac
      if $is_enrollable_from_opac;
    $params->{is_email_required} = 0 unless $self->first_valid_email_address();

    $params->{borrower} = $self;

    return Koha::Clubs->get_enrollable($params);
}


=head3 get_lists_with_patron

    my @lists = $patron->get_lists_with_patron;

FIXME: This method returns a DBIC resultset instead of a Koha::Objects-based
iterator.

=cut

sub get_lists_with_patron {
    my ( $self ) = @_;
    my $borrowernumber = $self->borrowernumber;

    return Koha::Database->new()->schema()->resultset('PatronList')->search(
        {
            'patron_list_patrons.borrowernumber' => $borrowernumber,
        },
        {
            join => 'patron_list_patrons',
            collapse => 1,
            order_by => 'name',
        }
    );
}

=head3 account_locked

my $is_locked = $patron->account_locked

Return true if the patron has reached the maximum number of login attempts
(see pref FailedLoginAttempts). If login_attempts is < 0, this is interpreted
as an administrative lockout (independent of FailedLoginAttempts; see also
Koha::Patron->lock).
Otherwise return false.
If the pref is not set (empty string, null or 0), the feature is considered as
disabled.

=cut

sub account_locked {
    my ($self) = @_;
    my $FailedLoginAttempts = C4::Context->preference('FailedLoginAttempts');
    return 1 if $FailedLoginAttempts
          and $self->login_attempts
          and $self->login_attempts >= $FailedLoginAttempts;
    return 1 if ($self->login_attempts || 0) < 0; # administrative lockout
    return 0;
}

=head3 can_see_patron_infos

my $can_see = $patron->can_see_patron_infos( $patron );

Return true if the patron (usually the logged in user) can see the patron's infos for a given patron

=cut

sub can_see_patron_infos {
    my ( $self, $patron ) = @_;
    return unless $patron;
    return $self->can_see_patrons_from( $patron->branchcode );
}

=head3 can_see_patrons_from

my $can_see = $patron->can_see_patrons_from( $branchcode );

Return true if the patron (usually the logged in user) can see the patron's infos from a given library

=cut

sub can_see_patrons_from {
    my ( $self, $branchcode ) = @_;

    return $self->can_see_things_from(
        {
            branchcode => $branchcode,
            permission => 'borrowers',
            subpermission => 'view_borrower_infos_from_any_libraries',
        }
    );
}

=head3 can_edit_items_from

    my $can_edit = $patron->can_edit_items_from( $branchcode );

Return true if the I<Koha::Patron> can edit items from the given branchcode

=cut

sub can_edit_items_from {
    my ( $self, $branchcode ) = @_;

    return 1 if C4::Context->IsSuperLibrarian();

    my $userenv = C4::Context->userenv();
    if ( $userenv && C4::Context->preference('IndependentBranches') ) {
        return $userenv->{branch} eq $branchcode;
    }

    return $self->can_see_things_from(
        {
            branchcode    => $branchcode,
            permission    => 'editcatalogue',
            subpermission => 'edit_any_item',
        }
    );
}

=head3 libraries_where_can_edit_items

    my $libraries = $patron->libraries_where_can_edit_items;

Return the list of branchcodes(!) of libraries the patron is allowed to items for.
The branchcodes are arbitrarily returned sorted.
We are supposing here that the object is related to the logged in patron (use of C4::Context::only_my_library)

An empty array means no restriction, the user can edit any item.

=cut

sub libraries_where_can_edit_items {
    my ($self) = @_;

    return $self->libraries_where_can_see_things(
        {
            permission    => 'editcatalogue',
            subpermission => 'edit_any_item',
            group_feature => 'ft_limit_item_editing',
        }
    );
}

=head3 libraries_where_can_see_patrons

my $libraries = $patron->libraries_where_can_see_patrons;

Return the list of branchcodes(!) of libraries the patron is allowed to see other patron's infos.
The branchcodes are arbitrarily returned sorted.
We are supposing here that the object is related to the logged in patron (use of C4::Context::only_my_library)

An empty array means no restriction, the patron can see patron's infos from any libraries.

=cut

sub libraries_where_can_see_patrons {
    my ($self) = @_;

    return $self->libraries_where_can_see_things(
        {
            permission    => 'borrowers',
            subpermission => 'view_borrower_infos_from_any_libraries',
            group_feature => 'ft_hide_patron_info',
        }
    );
}

=head3 can_see_things_from

my $can_see = $patron->can_see_things_from( $branchcode );

Return true if the I<Koha::Patron> can perform some action on the given thing

=cut

sub can_see_things_from {
    my ( $self, $params ) = @_;

    my $branchcode    = $params->{branchcode};
    my $permission    = $params->{permission};
    my $subpermission = $params->{subpermission};

    return 1 if C4::Context->IsSuperLibrarian();

    my $can = 0;
    if ( $self->branchcode eq $branchcode ) {
        $can = 1;
    } elsif ( $self->has_permission( { $permission => $subpermission } ) ) {
        $can = 1;
    } elsif ( my @branches = $self->libraries_where_can_see_patrons ) {
        $can = ( any { $_ eq $branchcode } @branches ) ? 1 : 0;
    }
    return $can;
}

=head3 can_log_into

my $can_log_into = $patron->can_log_into( $library );

Given a I<Koha::Library> object, it returns a boolean representing
the fact the patron can log into a the library.

=cut

sub can_log_into {
    my ( $self, $library ) = @_;

    my $can = 0;

    if ( C4::Context->preference('IndependentBranches') ) {
        $can = 1
          if $self->is_superlibrarian
          or $self->branchcode eq $library->id;
    }
    else {
        # no restrictions
        $can = 1;
    }

   return $can;
}

=head3 libraries_where_can_see_things

    my $libraries = $patron->libraries_where_can_see_things;

Returns a list of libraries where an aribitarary action is allowed to be taken by the logged in librarian
against an object based on some branchcode related to the object ( patron branchcode, item homebranch, etc ).

We are supposing here that the object is related to the logged in librarian (use of C4::Context::only_my_library)

An empty array means no restriction, the thing can see thing's infos from any libraries.

=cut

sub libraries_where_can_see_things {
    my ( $self, $params ) = @_;
    my $permission    = $params->{permission};
    my $subpermission = $params->{subpermission};
    my $group_feature = $params->{group_feature};

    return @{ $self->{"_restricted_branchcodes:$permission:$subpermission:$group_feature"} }
        if exists( $self->{"_restricted_branchcodes:$permission:$subpermission:$group_feature"} );

    my $userenv = C4::Context->userenv;

    return () unless $userenv; # For tests, but userenv should be defined in tests...

    my @restricted_branchcodes;
    if (C4::Context::only_my_library) {
        push @restricted_branchcodes, $self->branchcode;
    }
    else {
        unless (
            $self->has_permission(
                { $permission => $subpermission }
            )
          )
        {
            my $library_groups = $self->library->library_groups({ $group_feature => 1 });
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

    $self->{"_restricted_branchcodes:$permission:$subpermission:$group_feature"} = \@restricted_branchcodes;
    return @{ $self->{"_restricted_branchcodes:$permission:$subpermission:$group_feature"} };
}

=head3 has_permission

my $permission = $patron->has_permission($required);

See C4::Auth::haspermission for details of syntax for $required

=cut

sub has_permission {
    my ( $self, $flagsrequired ) = @_;
    return unless $self->userid;
    # TODO code from haspermission needs to be moved here!
    return C4::Auth::haspermission( $self->userid, $flagsrequired );
}

=head3 is_superlibrarian

  my $is_superlibrarian = $patron->is_superlibrarian;

Return true if the patron is a superlibrarian.

=cut

sub is_superlibrarian {
    my ($self) = @_;
    return $self->has_permission( { superlibrarian => 1 } ) ? 1 : 0;
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

    $patron->generate_userid;

    If you do not have a plugin for generating a userid, we will call
    the internal method here that returns firstname.surname[.number],
    where number is an optional suffix to make the userid unique.
    (Its behavior has not been changed on bug 32426.)

    If you have plugin(s), the first valid response will be used.
    A plugin is assumed to return a valid userid as suggestion, but not
    assumed to save it already.
    Does not fallback to internal (you could arrange for that in your plugin).
    Clears userid when there are no valid plugin responses.

=cut

sub generate_userid {
    my ( $self ) = @_;
    my @responses = Koha::Plugins->call(
        'patron_generate_userid',
        {
            patron  => $self,                 #FIXME To be deprecated
            payload => { patron => $self },
        },
    );
    unless( @responses ) {
        # Empty list only possible when there are NO enabled plugins for this method.
        # In that case we provide internal response.
        return $self->_generate_userid_internal;
    }
    # If a plugin returned false value or invalid value, we do however not return
    # internal response. The plugins should deal with that themselves. So we prevent
    # unexpected/unwelcome internal codes for plugin failures.
    foreach my $response ( grep { $_ } @responses ) {
        $self->userid( $response );
        return $self if $self->has_valid_userid;
    }
    $self->userid(undef);
    return $self;
}

sub _generate_userid_internal { # as we always did
    my ($self) = @_;
    my $offset = 0;
    my $firstname = $self->firstname // q{};
    my $surname = $self->surname // q{};
    #The script will "do" the following code and increment the $offset until the generated userid is unique
    do {
      $firstname =~ s/[[:digit:][:space:][:blank:][:punct:][:cntrl:]]//g;
      $surname =~ s/[[:digit:][:space:][:blank:][:punct:][:cntrl:]]//g;
      my $userid = lc(($firstname)? "$firstname.$surname" : $surname);
      $userid = NFKD( $userid );
      $userid =~ s/\p{NonspacingMark}//g;
      $userid .= $offset unless $offset == 0;
      $self->userid( $userid );
      $offset++;
     } while (! $self->has_valid_userid );

     return $self;
}

=head3 add_extended_attribute

=cut

sub add_extended_attribute {
    my ($self, $attribute) = @_;

    return Koha::Patron::Attribute->new(
        {
            %$attribute,
            ( borrowernumber => $self->borrowernumber ),
        }
    )->store;

}

=head3 extended_attributes

Return object of Koha::Patron::Attributes type with all attributes set for this patron

Or setter FIXME

=cut

sub extended_attributes {
    my ( $self, $attributes ) = @_;
    if ($attributes) {    # setter
        my $schema = $self->_result->result_source->schema;
        $schema->txn_do(
            sub {
                # Remove the existing one
                $self->extended_attributes->filter_by_branch_limitations->delete;

                # Insert the new ones
                my $new_types = {};
                for my $attribute (@$attributes) {
                    $self->add_extended_attribute($attribute);
                    $new_types->{$attribute->{code}} = 1;
                }

                # Check globally mandatory types
                my @required_attribute_types =
                    Koha::Patron::Attribute::Types->search(
                        {
                            mandatory => 1,
                            category_code => [ undef, $self->categorycode ],
                            'borrower_attribute_types_branches.b_branchcode' =>
                              undef,
                        },
                        { join => 'borrower_attribute_types_branches' }
                    )->get_column('code');
                for my $type ( @required_attribute_types ) {
                    Koha::Exceptions::Patron::MissingMandatoryExtendedAttribute->throw(
                        type => $type,
                    ) if !$new_types->{$type};
                }
            }
        );
    }

    my $rs = $self->_result->borrower_attributes;
    # We call search to use the filters in Koha::Patron::Attributes->search
    return Koha::Patron::Attributes->_new_from_dbic($rs)->search;
}

=head3 messages

    my $messages = $patron->messages;

Return the message attached to the patron.

=cut

sub messages {
    my ( $self ) = @_;
    my $messages_rs = $self->_result->messages_borrowernumbers->search;
    return Koha::Patron::Messages->_new_from_dbic($messages_rs);
}

=head3 lock

    Koha::Patrons->find($id)->lock({ expire => 1, remove => 1 });

    Lock and optionally expire a patron account.
    Remove holds and article requests if remove flag set.
    In order to distinguish from locking by entering a wrong password, let's
    call this an administrative lockout.

=cut

sub lock {
    my ( $self, $params ) = @_;
    $self->login_attempts( ADMINISTRATIVE_LOCKOUT );
    if( $params->{expire} ) {
        $self->dateexpiry( dt_from_string->subtract(days => 1) );
    }
    $self->store;
    if( $params->{remove} ) {
        $self->holds->delete;
        $self->article_requests->delete;
    }
    return $self;
}

=head3 anonymize

    Koha::Patrons->find($id)->anonymize;

    Anonymize or clear borrower fields. Fields in BorrowerMandatoryField
    are randomized, other personal data is cleared too.
    Patrons with issues are skipped.

=cut

sub anonymize {
    my ( $self ) = @_;
    if( $self->_result->issues->count ) {
        warn "Exiting anonymize: patron ".$self->borrowernumber." still has issues";
        return;
    }
    # Mandatory fields come from the corresponding pref, but email fields
    # are removed since scrambled email addresses only generate errors
    my $mandatory = { map { (lc $_, 1); } grep { !/email/ }
        split /\s*\|\s*/, C4::Context->preference('BorrowerMandatoryField') };
    $mandatory->{userid} = 1; # needed since sub store does not clear field
    my @columns = $self->_result->result_source->columns;
    @columns = grep { !/borrowernumber|branchcode|categorycode|^date|password|flags|updated_on|lastseen|lang|login_attempts|anonymized|auth_method/ } @columns;
    push @columns, 'dateofbirth'; # add this date back in
    foreach my $col (@columns) {
        $self->_anonymize_column($col, $mandatory->{lc $col} );
    }
    $self->anonymized(1)->store;
}

sub _anonymize_column {
    my ( $self, $col, $mandatory ) = @_;
    my $col_info = $self->_result->result_source->column_info($col);
    my $type = $col_info->{data_type};
    my $nullable = $col_info->{is_nullable};
    my $val;
    if( $type =~ /char|text/ ) {
        $val = $mandatory
            ? Koha::Token->new->generate({ pattern => '\w{10}' })
            : $nullable
            ? undef
            : q{};
    } elsif( $type =~ /integer|int$|float|dec|double/ ) {
        $val = $nullable ? undef : 0;
    } elsif( $type =~ /date|time/ ) {
        $val = $nullable ? undef : dt_from_string;
    }
    $self->$col($val);
}

=head3 add_guarantor

    my $relationship = $patron->add_guarantor(
        {
            borrowernumber => $borrowernumber,
            relationships  => $relationship,
        }
    );

    Adds a new guarantor to a patron.

=cut

sub add_guarantor {
    my ( $self, $params ) = @_;

    my $guarantor_id = $params->{guarantor_id};
    my $relationship = $params->{relationship};

    return Koha::Patron::Relationship->new(
        {
            guarantee_id => $self->id,
            guarantor_id => $guarantor_id,
            relationship => $relationship
        }
    )->store();
}

=head3 get_extended_attribute

my $attribute_value = $patron->get_extended_attribute( $code );

Return the attribute for the code passed in parameter.

It not exist it returns undef

Note that this will not work for repeatable attribute types.

Maybe you certainly not want to use this method, it is actually only used for SHOW_BARCODE
(which should be a real patron's attribute (not extended)

=cut

sub get_extended_attribute {
    my ( $self, $code, $value ) = @_;
    my $rs = $self->_result->borrower_attributes;
    return unless $rs;
    my $attribute = $rs->search({ code => $code, ( $value ? ( attribute => $value ) : () ) });
    return unless $attribute->count;
    return $attribute->next;
}

=head3 set_default_messaging_preferences

    $patron->set_default_messaging_preferences

Sets default messaging preferences on patron.

See Koha::Patron::MessagePreference(s) for more documentation, especially on
thrown exceptions.

=cut

sub set_default_messaging_preferences {
    my ($self, $categorycode) = @_;

    my $options = Koha::Patron::MessagePreferences->get_options;

    foreach my $option (@$options) {
        # Check that this option has preference configuration for this category
        unless (Koha::Patron::MessagePreferences->search({
            message_attribute_id => $option->{message_attribute_id},
            categorycode         => $categorycode || $self->categorycode,
        })->count) {
            next;
        }

        # Delete current setting
        Koha::Patron::MessagePreferences->search({
             borrowernumber => $self->borrowernumber,
             message_attribute_id => $option->{message_attribute_id},
        })->delete;

        Koha::Patron::MessagePreference->new_from_default({
            borrowernumber => $self->borrowernumber,
            categorycode   => $categorycode || $self->categorycode,
            message_attribute_id => $option->{message_attribute_id},
        });
    }

    return $self;
}

=head3 is_accessible

    if ( $patron->is_accessible({ user => $logged_in_user }) ) { ... }

This overloaded method validates whether the current I<Koha::Patron> object can be accessed
by the logged in user.

Returns 0 if the I<user> parameter is missing.

=cut

sub is_accessible {
    my ( $self, $params ) = @_;

    unless ( defined( $params->{user} ) ) {
        Koha::Exceptions::MissingParameter->throw( error => "The `user` parameter is mandatory" );
    }

    my $consumer = $params->{user};
    return $consumer->can_see_patron_infos($self);
}

=head3 unredact_list

This method returns the list of database fields that should be visible, even for restricted users,
for both API and UI output purposes

=cut

sub unredact_list {
    return ['branchcode'];
}

=head3 to_api

    my $json = $patron->to_api;

Overloaded method that returns a JSON representation of the Koha::Patron object,
suitable for API output.

=cut

sub to_api {
    my ( $self, $params ) = @_;

    my $json_patron = $self->SUPER::to_api( $params );

    return unless $json_patron;

    $json_patron->{restricted} = ( $self->is_debarred )
                                    ? Mojo::JSON->true
                                    : Mojo::JSON->false;

    return $json_patron;
}

=head3 to_api_mapping

This method returns the mapping for representing a Koha::Patron object
on the API.

=cut

sub to_api_mapping {
    return {
        borrowernotes       => 'staff_notes',
        borrowernumber      => 'patron_id',
        branchcode          => 'library_id',
        categorycode        => 'category_id',
        checkprevcheckout   => 'check_previous_checkout',
        contactfirstname    => undef,                     # Unused
        contactname         => undef,                     # Unused
        contactnote         => 'altaddress_notes',
        contacttitle        => undef,                     # Unused
        dateenrolled        => 'date_enrolled',
        dateexpiry          => 'expiry_date',
        dateofbirth         => 'date_of_birth',
        debarred            => undef,                     # replaced by 'restricted'
        debarredcomment     => undef,    # calculated, API consumers will use /restrictions instead
        emailpro            => 'secondary_email',
        flags               => undef,    # permissions manipulation handled in /permissions
        gonenoaddress       => 'incorrect_address',
        lastseen            => 'last_seen',
        lost                => 'patron_card_lost',
        opacnote            => 'opac_notes',
        othernames          => 'other_name',
        password            => undef,            # password manipulation handled in /password
        phonepro            => 'secondary_phone',
        relationship        => 'relationship_type',
        sex                 => 'gender',
        smsalertnumber      => 'sms_number',
        sort1               => 'statistics_1',
        sort2               => 'statistics_2',
        autorenew_checkouts => 'autorenew_checkouts',
        streetnumber        => 'street_number',
        streettype          => 'street_type',
        zipcode             => 'postal_code',
        B_address           => 'altaddress_address',
        B_address2          => 'altaddress_address2',
        B_city              => 'altaddress_city',
        B_country           => 'altaddress_country',
        B_email             => 'altaddress_email',
        B_phone             => 'altaddress_phone',
        B_state             => 'altaddress_state',
        B_streetnumber      => 'altaddress_street_number',
        B_streettype        => 'altaddress_street_type',
        B_zipcode           => 'altaddress_postal_code',
        altcontactaddress1  => 'altcontact_address',
        altcontactaddress2  => 'altcontact_address2',
        altcontactaddress3  => 'altcontact_city',
        altcontactcountry   => 'altcontact_country',
        altcontactfirstname => 'altcontact_firstname',
        altcontactphone     => 'altcontact_phone',
        altcontactsurname   => 'altcontact_surname',
        altcontactstate     => 'altcontact_state',
        altcontactzipcode   => 'altcontact_postal_code',
        password_expiration_date => undef,
        primary_contact_method => undef,
        secret              => undef,
        auth_method         => undef,
    };
}

=head3 strings_map

Returns a map of column name to string representations including the string.

=cut

sub strings_map {
    my ( $self, $params ) = @_;

    return {
        library_id => {
            str  => $self->library->branchname,
            type => 'library',
        },
        category_id => {
            str  => $self->category->description,
            type => 'patron_category',
        }
    };
}

=head3 queue_notice

    Koha::Patrons->queue_notice({ letter_params => $letter_params, message_name => 'DUE'});
    Koha::Patrons->queue_notice({ letter_params => $letter_params, message_transports => \@message_transports });
    Koha::Patrons->queue_notice({ letter_params => $letter_params, message_transports => \@message_transports, test_mode => 1 });

    Queue messages to a patron. Can pass a message that is part of the message_attributes
    table or supply the transport to use.

    If passed a message name we retrieve the patrons preferences for transports
    Otherwise we use the supplied transport. In the case of email or sms we fall back to print if
    we have no address/number for sending

    $letter_params is a hashref of the values to be passed to GetPreparedLetter

    test_mode will only report which notices would be sent, but nothing will be queued

=cut

sub queue_notice {
    my ( $self, $params ) = @_;
    my $letter_params = $params->{letter_params};
    my $test_mode = $params->{test_mode};

    return unless $letter_params;
    return unless exists $params->{message_name} xor $params->{message_transports}; # We only want one of these

    my $library = Koha::Libraries->find( $letter_params->{branchcode} );
    my $from_email_address = $library->from_email_address;

    my @message_transports;
    my $letter_code;
    $letter_code = $letter_params->{letter_code};
    if( $params->{message_name} ){
        my $messaging_prefs = C4::Members::Messaging::GetMessagingPreferences( {
                borrowernumber => $letter_params->{borrowernumber},
                message_name => $params->{message_name}
        } );
        @message_transports = ( keys %{ $messaging_prefs->{transports} } );
        $letter_code = $messaging_prefs->{transports}->{$message_transports[0]} unless $letter_code;
    } else {
        @message_transports = @{$params->{message_transports}};
    }
    return unless defined $letter_code;
    $letter_params->{letter_code} = $letter_code;
    my $print_sent = 0;
    my %return;
    foreach my $mtt (@message_transports){
        next if ($mtt eq 'itiva' and C4::Context->preference('TalkingTechItivaPhoneNotification') );
        # Notice is handled by TalkingTech_itiva_outbound.pl
        if (   ( $mtt eq 'email' and not $self->notice_email_address )
            or ( $mtt eq 'sms'   and not $self->smsalertnumber )
            or ( $mtt eq 'phone' and not $self->phone ) )
        {
            push @{ $return{fallback} }, $mtt;
            $mtt = 'print';
        }
        next if $mtt eq 'print' && $print_sent;
        $letter_params->{message_transport_type} = $mtt;
        my $letter = C4::Letters::GetPreparedLetter( %$letter_params );
        C4::Letters::EnqueueLetter({
            letter => $letter,
            borrowernumber => $self->borrowernumber,
            from_address   => $from_email_address,
            message_transport_type => $mtt
        }) unless $test_mode;
        push @{$return{sent}}, $mtt;
        $print_sent = 1 if $mtt eq 'print';
    }
    return \%return;
}

=head3 safe_to_delete

    my $result = $patron->safe_to_delete;
    if ( $result eq 'has_guarantees' ) { ... }
    elsif ( $result ) { ... }
    else { # cannot delete }

This method tells if the Koha:Patron object can be deleted. Possible return values

=over 4

=item 'ok'

=item 'has_checkouts'

=item 'has_debt'

=item 'has_guarantees'

=item 'is_anonymous_patron'

=item 'is_protected'

=back

=cut

sub safe_to_delete {
    my ($self) = @_;

    my $anonymous_patron = C4::Context->preference('AnonymousPatron');

    my $error;

    if ( $anonymous_patron && $self->id eq $anonymous_patron ) {
        $error = 'is_anonymous_patron';
    }
    elsif ( $self->checkouts->count ) {
        $error = 'has_checkouts';
    }
    elsif ( $self->account->outstanding_debits->total_outstanding > 0 ) {
        $error = 'has_debt';
    }
    elsif ( $self->guarantee_relationships->count ) {
        $error = 'has_guarantees';
    }
    elsif ( $self->protected ) {
        $error = 'is_protected';
    }

    if ( $error ) {
        return Koha::Result::Boolean->new(0)->add_message({ message => $error });
    }

    return Koha::Result::Boolean->new(1);
}

=head3 recalls

    my $recalls = $patron->recalls;

Return the patron's recalls.

=cut

sub recalls {
    my ( $self ) = @_;

    return Koha::Recalls->search({ patron_id => $self->borrowernumber });
}

=head3 account_balance

    my $balance = $patron->account_balance

Return the patron's account balance

=cut

sub account_balance {
    my ($self) = @_;
    return $self->account->balance;
}

=head3 notify_library_of_registration

$patron->notify_library_of_registration( $email_patron_registrations );

Send patron registration email to library if EmailPatronRegistrations system preference is enabled.

=cut

sub notify_library_of_registration {
    my ( $self, $email_patron_registrations ) = @_;

    if (
        my $letter = C4::Letters::GetPreparedLetter(
            module      => 'members',
            letter_code => 'OPAC_REG',
            branchcode  => $self->branchcode,
            lang        => $self->lang || 'default',
            tables      => {
                'borrowers' => $self->borrowernumber
            },
        )
    ) {
        my $to_address;
        if ( $email_patron_registrations eq "BranchEmailAddress" ) {
            my $library = Koha::Libraries->find( $self->branchcode );
            $to_address = $library->inbound_email_address;
        }
        elsif ( $email_patron_registrations eq "KohaAdminEmailAddress" ) {
            $to_address = C4::Context->preference('ReplytoDefault')
            || C4::Context->preference('KohaAdminEmailAddress');
        }
        else {
            $to_address =
                C4::Context->preference('EmailAddressForPatronRegistrations')
                || C4::Context->preference('ReplytoDefault')
                || C4::Context->preference('KohaAdminEmailAddress');
        }

        my $message_id = C4::Letters::EnqueueLetter(
            {
                letter                 => $letter,
                borrowernumber         => $self->borrowernumber,
                to_address             => $to_address,
                message_transport_type => 'email'
            }
        ) or warn "can't enqueue letter $letter";
        if ( $message_id ) {
            return 1;
        }
    }
}

=head3 has_messaging_preference

my $bool = $patron->has_messaging_preference({
    message_name => $message_name, # A value from message_attributes.message_name
    message_transport_type => $message_transport_type, # email, sms, phone, itiva, etc...
    wants_digest => $wants_digest, # 1 if you are looking for the digest version, don't pass if you just want either
});

=cut

sub has_messaging_preference {
    my ( $self, $params ) = @_;

    my $message_name           = $params->{message_name};
    my $message_transport_type = $params->{message_transport_type};
    my $wants_digest           = $params->{wants_digest};

    return $self->_result->search_related_rs(
        'borrower_message_preferences',
        $params,
        {
            prefetch =>
              [ 'borrower_message_transport_preferences', 'message_attribute' ]
        }
    )->count;
}

=head3 can_patron_change_staff_only_lists

$patron->can_patron_change_staff_only_lists;

Return 1 if a patron has 'Superlibrarian' or 'Catalogue' permission.
Otherwise, return 0.

=cut

sub can_patron_change_staff_only_lists {
    my ( $self, $params ) = @_;
    return 1 if C4::Auth::haspermission( $self->userid, { 'catalogue' => 1 });
    return 0;
}

=head3 can_patron_change_permitted_staff_lists

$patron->can_patron_change_permitted_staff_lists;

Return 1 if a patron has 'Superlibrarian' or 'Catalogue' and 'edit_public_list_contents' permissions.
Otherwise, return 0.

=cut

sub can_patron_change_permitted_staff_lists {
    my ( $self, $params ) = @_;
    return 1 if C4::Auth::haspermission( $self->userid, { 'catalogue' => 1, lists => 'edit_public_list_contents' } );
    return 0;
}

=head3 encode_secret

  $patron->encode_secret($secret32);

Secret (TwoFactorAuth expects it in base32 format) is encrypted.
You still need to call ->store.

=cut

sub encode_secret {
    my ( $self, $secret ) = @_;
    if( $secret ) {
        return $self->secret( Koha::Encryption->new->encrypt_hex($secret) );
    }
    return $self->secret($secret);
}

=head3 decoded_secret

  my $secret32 = $patron->decoded_secret;

Decode the patron secret. We expect to get back a base32 string, but this
is not checked here. Caller of encode_secret is responsible for that.

=cut

sub decoded_secret {
    my ( $self ) = @_;
    if( $self->secret ) {
        return Koha::Encryption->new->decrypt_hex( $self->secret );
    }
    return $self->secret;
}

=head3 virtualshelves

    my $shelves = $patron->virtualshelves;

=cut

sub virtualshelves {
    my $self = shift;
    return Koha::Virtualshelves->_new_from_dbic( scalar $self->_result->virtualshelves );
}

=head3 get_savings

    my $savings = $patron->get_savings;

Use the replacement price of patron's old and current issues to calculate how much they have 'saved' by using the library.

=cut

sub get_savings {
    my ($self) = @_;

    my @itemnumbers = grep { defined $_ } ( $self->old_checkouts->get_column('itemnumber'), $self->checkouts->get_column('itemnumber') );

    return Koha::Items->search(
        { itemnumber => { -in => \@itemnumbers } },
        {   select => [ { sum => 'me.replacementprice' } ],
            as     => ['total_savings']
        }
    )->next->get_column('total_savings') // 0;
}

=head3 alert_subscriptions

    my $subscriptions = $patron->alert_subscriptions;

Return a Koha::Subscriptions object containing subscriptions for which the patron has subscribed to email alerts.

=cut

sub alert_subscriptions {
    my ($self) = @_;

    my @alerts           = $self->_result->alerts;
    my @subscription_ids = map { $_->externalid } @alerts;

    return Koha::Subscriptions->search( { subscriptionid => \@subscription_ids } );
}

=head3 consent

    my $consent = $patron->consent(TYPE);

    Returns the first consent of type TYPE (there should be only one) or a new instance
    of Koha::Patron::Consent.

=cut

sub consent {
    my ( $self, $type ) = @_;
    Koha::Exceptions::MissingParameter->throw('Missing consent type') if !$type;
    my $consents = Koha::Patron::Consents->search(
        {
            borrowernumber => $self->borrowernumber,
            type           => $type,
        }
    );
    return $consents && $consents->count
        ? $consents->next
        : Koha::Patron::Consent->new( { borrowernumber => $self->borrowernumber, type => $type } );
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'Borrower';
}

=head1 AUTHORS

Kyle M Hall <kyle@bywatersolutions.com>
Alex Sassmannshausen <alex.sassmannshausen@ptfs-europe.com>
Martin Renvoize <martin.renvoize@ptfs-europe.com>

=cut

1;
