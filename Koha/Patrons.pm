package Koha::Patrons;

# Copyright 2014 ByWater Solutions
# Copyright 2016 Koha Development Team
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
use Koha::DateUtils qw( dt_from_string );

use Koha::ArticleRequests;
use Koha::Patron;
use Koha::Exceptions::Patron;
use Koha::Patron::Categories;

use base qw(Koha::Objects);

=head1 NAME

Koha::Patron - Koha Patron Object class

=head1 API

=head2 Class Methods

=cut

=head3 search_limited

my $patrons = Koha::Patrons->search_limit( $params, $attributes );

Returns all the patrons the logged in user is allowed to see

=cut

sub search_limited {
    my ( $self, $params, $attributes ) = @_;

    my $userenv = C4::Context->userenv;
    my @restricted_branchcodes;
    if ( $userenv and $userenv->{number} ) {
        my $logged_in_user = Koha::Patrons->find( $userenv->{number} );
        @restricted_branchcodes = $logged_in_user->libraries_where_can_see_patrons;
    }
    $params->{'me.branchcode'} = { -in => \@restricted_branchcodes } if @restricted_branchcodes;
    return $self->search( $params, $attributes );
}

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

=head3 search_upcoming_membership_expires

my $patrons = Koha::Patrons->search_upcoming_membership_expires();

The 'before' and 'after' represent the number of days before/after the date
that is set by the preference MembershipExpiryDaysNotice.
If the pref is 14, before 2 and after 3 then you will get all expires
from 12 to 17 days.

=cut

sub search_upcoming_membership_expires {
    my ( $self, $params ) = @_;
    my $before = $params->{before} || 0;
    my $after  = $params->{after} || 0;
    delete $params->{before};
    delete $params->{after};

    my $days = C4::Context->preference("MembershipExpiryDaysNotice") || 0;
    my $date_before = dt_from_string->add( days => $days - $before );
    my $date_after = dt_from_string->add( days => $days + $after );
    my $dtf = Koha::Database->new->schema->storage->datetime_parser;

    $params->{dateexpiry} = {
        ">=" => $dtf->format_date( $date_before ),
        "<=" => $dtf->format_date( $date_after ),
    };
    return $self->SUPER::search(
        $params, { join => ['branchcode', 'categorycode'] }
    );
}

=head3 search_patrons_to_anonymise

    my $patrons = Koha::Patrons->search_patrons_to_anonymise( { before => $older_than_date, [ library => $library ] } );

This method returns all patrons who has an issue history older than a given date.

=cut

sub search_patrons_to_anonymise {
    my ( $class, $params ) = @_;
    my $older_than_date = $params->{before};
    my $library         = $params->{library};
    $older_than_date = $older_than_date ? dt_from_string($older_than_date) : dt_from_string;
    $library ||=
      ( C4::Context->preference('IndependentBranches') && C4::Context->userenv && !C4::Context->IsSuperLibrarian() && C4::Context->userenv->{branch} )
      ? C4::Context->userenv->{branch}
      : undef;
    my $anonymous_patron = C4::Context->preference('AnonymousPatron') || undef;

    my $dtf = Koha::Database->new->schema->storage->datetime_parser;
    my $rs = $class->_resultset->search(
        {   returndate                  => { '<'   =>  $dtf->format_datetime($older_than_date), },
            'old_issues.borrowernumber' => { 'not' => undef },
            privacy                     => { '<>'  => 0 },                  # Keep forever
            ( $library ? ( 'old_issues.branchcode' => $library ) : () ),
            ( $anonymous_patron ? ( 'old_issues.borrowernumber' => { '!=' => $anonymous_patron } ) : () ),
        },
        {   join     => ["old_issues"],
            distinct => 1,
        }
    );
    return Koha::Patrons->_new_from_dbic($rs);
}

=head3 delete

    Koha::Patrons->search({ some filters here })->delete({ move => 1 });

    Delete passed set of patron objects.
    Wrapper for Koha::Patron->delete. (We do not want to bypass Koha::Patron
    and let DBIx do the job without further housekeeping.)
    Includes a move to deletedborrowers if move flag set.

    Just like DBIx, the delete will only succeed when all entries could be
    deleted. Returns true or throws an exception.

=cut

sub delete {
    my ( $self, $params ) = @_;
    my $patrons_deleted;
    $self->_resultset->result_source->schema->txn_do( sub {
        my ( $set, $params ) = @_;
        my $count = $set->count;
        while ( my $patron = $set->next ) {

            next unless $patron->in_storage;

            $patron->move_to_deleted if $params->{move};
            $patron->delete;

            $patrons_deleted++;
        }
    }, $self, $params );
    return $patrons_deleted;
}

=head3 filter_by_expiration_date

    Koha::Patrons->filter_by_expiration_date{{ days => $x });

    Returns set of Koha patron objects expired $x days.

=cut

sub filter_by_expiration_date {
    my ( $class, $params ) = @_;

    return $class->filter_by_last_update(
        {
            timestamp_column_name => 'dateexpiry',
            days                  => $params->{days} || 0,
            days_inclusive        => 1,
        }
    );
}

=head3 search_unsubscribed

    Koha::Patrons->search_unsubscribed;

    Returns a set of Koha patron objects for patrons that recently
    unsubscribed and are not locked (candidates for locking).
    Depends on UnsubscribeReflectionDelay.

=cut

sub search_unsubscribed {
    my ( $class ) = @_;

    my $delay = C4::Context->preference('UnsubscribeReflectionDelay');
    if( !defined($delay) || $delay eq q{} ) {
        # return empty set
        return $class->search({ borrowernumber => undef });
    }
    my $parser = Koha::Database->new->schema->storage->datetime_parser;
    my $dt = dt_from_string()->subtract( days => $delay );
    my $str = $parser->format_datetime($dt);
    my $fails = C4::Context->preference('FailedLoginAttempts') || 0;
    my $cond = [ undef, 0, 1..$fails-1 ]; # NULL, 0, 1..fails-1 (if fails>0)
    return $class->search(
        {
            'patron_consents.refused_on' => { '<=' => $str },
            'login_attempts' => $cond,
        },
        { join => 'patron_consents' },
    );
}

=head3 search_anonymize_candidates

    Koha::Patrons->search_anonymize_candidates({ locked => 1 });

    Returns a set of Koha patron objects for patrons whose account is expired
    and locked (if parameter set). These are candidates for anonymizing.
    Depends on PatronAnonymizeDelay.

=cut

sub search_anonymize_candidates {
    my ( $class, $params ) = @_;

    my $delay = C4::Context->preference('PatronAnonymizeDelay');
    if( !defined($delay) || $delay eq q{} ) {
        # return empty set
        return $class->search({ borrowernumber => undef });
    }
    my $cond = {};
    my $parser = Koha::Database->new->schema->storage->datetime_parser;
    my $dt = dt_from_string()->subtract( days => $delay );
    my $str = $parser->format_datetime($dt);
    $cond->{dateexpiry} = { '<=' => $str };
    $cond->{anonymized} = 0; # not yet done
    if( $params->{locked} ) {
        my $fails = C4::Context->preference('FailedLoginAttempts') || 0;
        $cond->{login_attempts} = [ -and => { '!=' => undef }, { -not_in => [0, 1..$fails-1 ] } ]; # -not_in does not like undef
    }
    return $class->search( $cond );
}

=head3 search_anonymized

    Koha::Patrons->search_anonymized;

    Returns a set of Koha patron objects for patron accounts that have been
    anonymized before and could be removed.
    Depends on PatronRemovalDelay.

=cut

sub search_anonymized {
    my ( $class ) = @_;

    my $delay = C4::Context->preference('PatronRemovalDelay');
    if( !defined($delay) || $delay eq q{} ) {
        # return empty set
        return $class->search({ borrowernumber => undef });
    }
    my $cond = {};
    my $parser = Koha::Database->new->schema->storage->datetime_parser;
    my $dt = dt_from_string()->subtract( days => $delay );
    my $str = $parser->format_datetime($dt);
    $cond->{dateexpiry} = { '<=' => $str };
    $cond->{anonymized} = 1;
    return $class->search( $cond );
}

=head3 lock

    Koha::Patrons->search({ some filters })->lock({ expire => 1, remove => 1 })

    Lock the passed set of patron objects. Optionally expire and remove holds.
    Wrapper around Koha::Patron->lock.

=cut

sub lock {
    my ( $self, $params ) = @_;
    my $count = $self->count;
    while( my $patron = $self->next ) {
        $patron->lock($params);
    }
}

=head3 anonymize

    Koha::Patrons->search({ some filters })->anonymize();

    Anonymize passed set of patron objects.
    Wrapper around Koha::Patron->anonymize.

=cut

sub anonymize {
    my ( $self ) = @_;
    my $count = $self->count;
    while( my $patron = $self->next ) {
        $patron->anonymize;
    }
}

=head3 search_patrons_to_update_category

    my $patrons = Koha::Patrons->search_patrons_to_update_category( {
                      from          => $from_category,
                      fine_max      => $fine_max,
                      fine_min      => $fin_min,
                      too_young     => $too_young,
                      too_old      => $too_old,
                  });

This method returns all patron who should be updated from one category to another meeting criteria:

from          - borrower categorycode
fine_min      - with fines totaling at least this amount
fine_max      - with fines above this amount
too_young     - if passed, select patrons who are under the age limit for the current category
too_old       - if passed, select patrons who are over the age limit for the current category

=cut

sub search_patrons_to_update_category {
    my ( $self, $params ) = @_;
    my %query;
    my $search_params;

    my $cat_from = Koha::Patron::Categories->find($params->{from});
    $search_params->{categorycode}=$params->{from};
    if ($params->{too_young} || $params->{too_old}){
        my $dtf = Koha::Database->new->schema->storage->datetime_parser;
        if( $cat_from->dateofbirthrequired && $params->{too_young} ) {
            my $date_after = dt_from_string()->subtract( years => $cat_from->dateofbirthrequired);
            $search_params->{dateofbirth}{'>'} = $dtf->format_datetime( $date_after );
        }
        if( $cat_from->upperagelimit && $params->{too_old} ) {
            my $date_before = dt_from_string()->subtract( years => $cat_from->upperagelimit);
            $search_params->{dateofbirth}{'<'} = $dtf->format_datetime( $date_before );
        }
    }
    if ($params->{fine_min} || $params->{fine_max}) {
        $query{join} = ["accountlines"];
        $query{columns} = ["borrowernumber"];
        $query{group_by} = ["borrowernumber"];
        $query{having} = \['COALESCE(sum(accountlines.amountoutstanding),0) <= ?',$params->{fine_max}] if defined $params->{fine_max};
        $query{having} = \['COALESCE(sum(accountlines.amountoutstanding),0) >= ?',$params->{fine_min}] if defined $params->{fine_min};
    }
    return $self->search($search_params,\%query);
}

=head3 update_category_to

    Koha::Patrons->search->update_category_to( {
            category   => $to_category,
        });

Update supplied patrons from current category to another and take care of guarantor info.
To make sure all the conditions are met, the caller has the responsibility to
call search_patrons_to_update to filter the Koha::Patrons set

=cut

sub update_category_to {
    my ( $self, $params ) = @_;
    my $counter = 0;
    while( my $patron = $self->next ) {
        $counter++;
        $patron->categorycode($params->{category})->store();
    }
    return $counter;
}

=head3 filter_by_attribute_type

my $patrons = Koha::Patrons->filter_by_attribute_type($attribute_type_code);

Return a Koha::Patrons set with patrons having the attribute defined.

=cut

sub filter_by_attribute_type {
    my ( $self, $attribute_type ) = @_;
    my $rs = Koha::Patron::Attributes->search( { code => $attribute_type } )
      ->_resultset()->search_related('borrowernumber');
    return Koha::Patrons->_new_from_dbic($rs);
}

=head3 filter_by_attribute_value

my $patrons = Koha::Patrons->filter_by_attribute_value($attribute_value);

Return a Koha::Patrons set with patrong having the attribute value passed in parameter.

=cut

sub filter_by_attribute_value {
    my ( $self, $attribute_value ) = @_;
    my $rs = Koha::Patron::Attributes->search(
        {
            'borrower_attribute_types.staff_searchable' => 1,
            attribute => { like => "%$attribute_value%" }
        },
        { join => 'borrower_attribute_types' }
    )->_resultset()->search_related('borrowernumber');
    return Koha::Patrons->_new_from_dbic($rs);
}

=head3 filter_by_amount_owed

    Koha::Patrons->filter_by_amount_owed(
        {
            less_than  => '2.00',
            more_than  => '0.50',
            debit_type => $debit_type_code,
            library    => $branchcode
        }
    );

Returns patrons filtered by how much money they owe, between passed limits.

Optionally limit to debts of a particular debit_type or/and owed to a particular library.

=head4 arguments hashref

=over 4

=item less_than (optional)  - filter out patrons who owe less than Amount

=item more_than (optional)  - filter out patrons who owe more than Amount

=item debit_type (optional) - filter the amount owed by debit type

=item library (optional)    - filter the amount owed to a particular branch

=back

=cut

sub filter_by_amount_owed {
    my ( $self, $options ) = @_;

    return $self
      unless (
        defined($options)
        && (   defined( $options->{less_than} )
            || defined( $options->{more_than} ) )
      );

    my $where = {};
    my $group_by =
      [ map { 'me.' . $_ } $self->_resultset->result_source->columns ];

    my $attrs = {
        join     => 'accountlines',
        group_by => $group_by,
        '+select' =>
          { sum => 'accountlines.amountoutstanding', '-as' => 'outstanding' },
        '+as' => 'outstanding'
    };

    $where->{'accountlines.debit_type_code'} = $options->{debit_type}
      if defined( $options->{debit_type} );

    $where->{'accountlines.branchcode'} = $options->{library}
      if defined( $options->{library} );

    $attrs->{'having'} = [
        { 'outstanding' => { '<' => $options->{less_than} } },
        { 'outstanding' => undef }
      ]
      if ( defined( $options->{less_than} )
        && !defined( $options->{more_than} ) );

    $attrs->{'having'} = { 'outstanding' => { '>' => $options->{more_than} } }
      if (!defined( $options->{less_than} )
        && defined( $options->{more_than} ) );

    $attrs->{'having'}->{'-and'} = [
        { 'outstanding' => { '>' => $options->{more_than} } },
        { 'outstanding' => { '<' => $options->{less_than} } }
      ]
      if ( defined( $options->{less_than} )
        && defined( $options->{more_than} ) );

    return $self->search( $where, $attrs );
}

=head3 filter_by_have_permission

    my $patrons = Koha::Patrons->search->filter_by_have_permission('suggestions.suggestions_manage');

    my $patrons = Koha::Patrons->search->filter_by_have_permission('suggestions');

Filter patrons who have a given subpermission or the whole permission.

=cut

sub filter_by_have_permission {
    my ($self, $subpermission) = @_;

    my ($p, $sp) = split '\.', $subpermission;

    my $perm = Koha::Database->new()->schema()->resultset('Userflag')->find({flag => $p});

    Koha::Exceptions::ObjectNotFound->throw( sprintf( "Permission %s not found", $p ) )
      unless $perm;

    my $bit = $perm->bit;

    return $self->search(
        {
            -and => [
                -or => [
                    \"me.flags & (1 << $bit)",
                    { 'me.flags' => 1 },
                    (
                        $sp
                        ? {
                            -and => [
                                { 'user_permissions.module_bit' => $bit },
                                { 'user_permissions.code'       => $sp }
                            ]
                          }
                        : ()
                    )
                ]
            ]
        },
        { prefetch => 'user_permissions' }
    );
}

=head3 _type

=cut

sub _type {
    return 'Borrower';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::Patron';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
