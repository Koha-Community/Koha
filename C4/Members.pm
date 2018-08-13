package C4::Members;

# Copyright 2000-2003 Katipo Communications
# Copyright 2010 BibLibre
# Parts Copyright 2010 Catalyst IT
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


use strict;
#use warnings; FIXME - Bug 2505
use C4::Context;
use String::Random qw( random_string );
use Scalar::Util qw( looks_like_number );
use Date::Calc qw/Today check_date Date_to_Days/;
use List::MoreUtils qw( uniq );
use JSON qw(to_json);
use C4::Log; # logaction
use C4::Overdues;
use C4::Reserves;
use C4::Accounts;
use C4::Biblio;
use C4::Letters;
use C4::Members::Attributes qw(SearchIdMatchingAttribute UpdateBorrowerAttribute);
use C4::NewsChannels; #get slip news
use DateTime;
use Koha::Database;
use Koha::DateUtils;
use Text::Unaccent qw( unac_string );
use Koha::AuthUtils qw(hash_password);
use Koha::Database;
use Koha::Holds;
use Koha::List::Patron;
use Koha::Patrons;
use Koha::Patron::Categories;
use Koha::Schema;

our (@ISA,@EXPORT,@EXPORT_OK,$debug);

BEGIN {
    $debug = $ENV{DEBUG} || 0;
    require Exporter;
    @ISA = qw(Exporter);
    #Get data
    push @EXPORT, qw(

        &GetAllIssues

        &GetBorrowersToExpunge

        &IssueSlip
    );

    #Modify data
    push @EXPORT, qw(
        &changepassword
    );

    #Check data
    push @EXPORT, qw(
        &checkuserpassword
        &checkcardnumber
    );
}

=head1 NAME

C4::Members - Perl Module containing convenience functions for member handling

=head1 SYNOPSIS

use C4::Members;

=head1 DESCRIPTION

This module contains routines for adding, modifying and deleting members/patrons/borrowers 

=head1 FUNCTIONS

=head2 patronflags

 $flags = &patronflags($patron);

This function is not exported.

The following will be set where applicable:
 $flags->{CHARGES}->{amount}        Amount of debt
 $flags->{CHARGES}->{noissues}      Set if debt amount >$5.00 (or syspref noissuescharge)
 $flags->{CHARGES}->{message}       Message -- deprecated

 $flags->{CREDITS}->{amount}        Amount of credit
 $flags->{CREDITS}->{message}       Message -- deprecated

 $flags->{  GNA  }                  Patron has no valid address
 $flags->{  GNA  }->{noissues}      Set for each GNA
 $flags->{  GNA  }->{message}       "Borrower has no valid address" -- deprecated

 $flags->{ LOST  }                  Patron's card reported lost
 $flags->{ LOST  }->{noissues}      Set for each LOST
 $flags->{ LOST  }->{message}       Message -- deprecated

 $flags->{DBARRED}                  Set if patron debarred, no access
 $flags->{DBARRED}->{noissues}      Set for each DBARRED
 $flags->{DBARRED}->{message}       Message -- deprecated

 $flags->{ NOTES }
 $flags->{ NOTES }->{message}       The note itself.  NOT deprecated

 $flags->{ ODUES }                  Set if patron has overdue books.
 $flags->{ ODUES }->{message}       "Yes"  -- deprecated
 $flags->{ ODUES }->{itemlist}      ref-to-array: list of overdue books
 $flags->{ ODUES }->{itemlisttext}  Text list of overdue items -- deprecated

 $flags->{WAITING}                  Set if any of patron's reserves are available
 $flags->{WAITING}->{message}       Message -- deprecated
 $flags->{WAITING}->{itemlist}      ref-to-array: list of available items

=over 

=item C<$flags-E<gt>{ODUES}-E<gt>{itemlist}> is a reference-to-array listing the
overdue items. Its elements are references-to-hash, each describing an
overdue item. The keys are selected fields from the issues, biblio,
biblioitems, and items tables of the Koha database.

=item C<$flags-E<gt>{ODUES}-E<gt>{itemlisttext}> is a string giving a text listing of
the overdue items, one per line.  Deprecated.

=item C<$flags-E<gt>{WAITING}-E<gt>{itemlist}> is a reference-to-array listing the
available items. Each element is a reference-to-hash whose keys are
fields from the reserves table of the Koha database.

=back

All the "message" fields that include language generated in this function are deprecated, 
because such strings belong properly in the display layer.

The "message" field that comes from the DB is OK.

=cut

# TODO: use {anonymous => hashes} instead of a dozen %flaginfo
# FIXME rename this function.
# DEPRECATED Do not use this subroutine!
sub patronflags {
    my %flags;
    my ( $patroninformation) = @_;
    my $dbh=C4::Context->dbh;
    my $patron = Koha::Patrons->find( $patroninformation->{borrowernumber} );
    my $account = $patron->account;
    my $owing = $account->non_issues_charges;
    if ( $owing > 0 ) {
        my %flaginfo;
        my $noissuescharge = C4::Context->preference("noissuescharge") || 5;
        $flaginfo{'message'} = sprintf 'Patron owes %.02f', $owing;
        $flaginfo{'amount'}  = sprintf "%.02f", $owing;
        if ( $owing > $noissuescharge && !C4::Context->preference("AllowFineOverride") ) {
            $flaginfo{'noissues'} = 1;
        }
        $flags{'CHARGES'} = \%flaginfo;
    }
    elsif ( ( my $balance = $account->balance ) < 0 ) {
        my %flaginfo;
        $flaginfo{'message'} = sprintf 'Patron has credit of %.02f', -$balance;
        $flaginfo{'amount'}  = sprintf "%.02f", $balance;
        $flags{'CREDITS'} = \%flaginfo;
    }

    # Check the debt of the guarntees of this patron
    my $no_issues_charge_guarantees = C4::Context->preference("NoIssuesChargeGuarantees");
    $no_issues_charge_guarantees = undef unless looks_like_number( $no_issues_charge_guarantees );
    if ( defined $no_issues_charge_guarantees ) {
        my $p = Koha::Patrons->find( $patroninformation->{borrowernumber} );
        my @guarantees = $p->guarantees();
        my $guarantees_non_issues_charges;
        foreach my $g ( @guarantees ) {
            $guarantees_non_issues_charges += $g->account->non_issues_charges;
        }

        if ( $guarantees_non_issues_charges > $no_issues_charge_guarantees ) {
            my %flaginfo;
            $flaginfo{'message'} = sprintf 'patron guarantees owe %.02f', $guarantees_non_issues_charges;
            $flaginfo{'amount'}  = $guarantees_non_issues_charges;
            $flaginfo{'noissues'} = 1 unless C4::Context->preference("allowfineoverride");
            $flags{'CHARGES_GUARANTEES'} = \%flaginfo;
        }
    }

    if (   $patroninformation->{'gonenoaddress'}
        && $patroninformation->{'gonenoaddress'} == 1 )
    {
        my %flaginfo;
        $flaginfo{'message'}  = 'Borrower has no valid address.';
        $flaginfo{'noissues'} = 1;
        $flags{'GNA'}         = \%flaginfo;
    }
    if ( $patroninformation->{'lost'} && $patroninformation->{'lost'} == 1 ) {
        my %flaginfo;
        $flaginfo{'message'}  = 'Borrower\'s card reported lost.';
        $flaginfo{'noissues'} = 1;
        $flags{'LOST'}        = \%flaginfo;
    }
    if ( $patroninformation->{'debarred'} && check_date( split( /-/, $patroninformation->{'debarred'} ) ) ) {
        if ( Date_to_Days(Date::Calc::Today) < Date_to_Days( split( /-/, $patroninformation->{'debarred'} ) ) ) {
            my %flaginfo;
            $flaginfo{'debarredcomment'} = $patroninformation->{'debarredcomment'};
            $flaginfo{'message'}         = $patroninformation->{'debarredcomment'};
            $flaginfo{'noissues'}        = 1;
            $flaginfo{'dateend'}         = $patroninformation->{'debarred'};
            $flags{'DBARRED'}           = \%flaginfo;
        }
    }
    if (   $patroninformation->{'borrowernotes'}
        && $patroninformation->{'borrowernotes'} )
    {
        my %flaginfo;
        $flaginfo{'message'} = $patroninformation->{'borrowernotes'};
        $flags{'NOTES'}      = \%flaginfo;
    }
    my ( $odues, $itemsoverdue ) = C4::Overdues::checkoverdues($patroninformation->{'borrowernumber'});
    if ( $odues && $odues > 0 ) {
        my %flaginfo;
        $flaginfo{'message'}  = "Yes";
        $flaginfo{'itemlist'} = $itemsoverdue;
        foreach ( sort { $a->{'date_due'} cmp $b->{'date_due'} }
            @$itemsoverdue )
        {
            $flaginfo{'itemlisttext'} .=
              "$_->{'date_due'} $_->{'barcode'} $_->{'title'} \n";  # newline is display layer
        }
        $flags{'ODUES'} = \%flaginfo;
    }

    my $waiting_holds = $patron->holds->search({ found => 'W' });
    my $nowaiting = $waiting_holds->count;
    if ( $nowaiting > 0 ) {
        my %flaginfo;
        $flaginfo{'message'}  = "Reserved items available";
        $flaginfo{'itemlist'} = $waiting_holds->unblessed;
        $flags{'WAITING'}     = \%flaginfo;
    }
    return ( \%flags );
}

=head2 GetAllIssues

  $issues = &GetAllIssues($borrowernumber, $sortkey, $limit);

Looks up what the patron with the given borrowernumber has borrowed,
and sorts the results.

C<$sortkey> is the name of a field on which to sort the results. This
should be the name of a field in the C<issues>, C<biblio>,
C<biblioitems>, or C<items> table in the Koha database.

C<$limit> is the maximum number of results to return.

C<&GetAllIssues> an arrayref, C<$issues>, of hashrefs, the keys of which
are the fields from the C<issues>, C<biblio>, C<biblioitems>, and
C<items> tables of the Koha database.

=cut

#'
sub GetAllIssues {
    my ( $borrowernumber, $order, $limit ) = @_;

    return unless $borrowernumber;
    $order = 'date_due desc' unless $order;

    my $dbh = C4::Context->dbh;
    my $query =
'SELECT *, issues.timestamp as issuestimestamp, issues.renewals AS renewals,items.renewals AS totalrenewals,items.timestamp AS itemstimestamp
  FROM issues 
  LEFT JOIN items on items.itemnumber=issues.itemnumber
  LEFT JOIN biblio ON items.biblionumber=biblio.biblionumber
  LEFT JOIN biblioitems ON items.biblioitemnumber=biblioitems.biblioitemnumber
  WHERE borrowernumber=? 
  UNION ALL
  SELECT *, old_issues.timestamp as issuestimestamp, old_issues.renewals AS renewals,items.renewals AS totalrenewals,items.timestamp AS itemstimestamp 
  FROM old_issues 
  LEFT JOIN items on items.itemnumber=old_issues.itemnumber
  LEFT JOIN biblio ON items.biblionumber=biblio.biblionumber
  LEFT JOIN biblioitems ON items.biblioitemnumber=biblioitems.biblioitemnumber
  WHERE borrowernumber=? AND old_issues.itemnumber IS NOT NULL
  order by ' . $order;
    if ($limit) {
        $query .= " limit $limit";
    }

    my $sth = $dbh->prepare($query);
    $sth->execute( $borrowernumber, $borrowernumber );
    return $sth->fetchall_arrayref( {} );
}

sub checkcardnumber {
    my ( $cardnumber, $borrowernumber ) = @_;

    # If cardnumber is null, we assume they're allowed.
    return 0 unless defined $cardnumber;

    my $dbh = C4::Context->dbh;
    my $query = "SELECT * FROM borrowers WHERE cardnumber=?";
    $query .= " AND borrowernumber <> ?" if ($borrowernumber);
    my $sth = $dbh->prepare($query);
    $sth->execute(
        $cardnumber,
        ( $borrowernumber ? $borrowernumber : () )
    );

    return 1 if $sth->fetchrow_hashref;

    my ( $min_length, $max_length ) = get_cardnumber_length();
    return 2
        if length $cardnumber > $max_length
        or length $cardnumber < $min_length;

    return 0;
}

=head2 get_cardnumber_length

    my ($min, $max) = C4::Members::get_cardnumber_length()

Returns the minimum and maximum length for patron cardnumbers as
determined by the CardnumberLength system preference, the
BorrowerMandatoryField system preference, and the width of the
database column.

=cut

sub get_cardnumber_length {
    my $borrower = Koha::Schema->resultset('Borrower');
    my $field_size = $borrower->result_source->column_info('cardnumber')->{size};
    my ( $min, $max ) = ( 0, $field_size ); # borrowers.cardnumber is a nullable varchar(20)
    $min = 1 if C4::Context->preference('BorrowerMandatoryField') =~ /cardnumber/;
    if ( my $cardnumber_length = C4::Context->preference('CardnumberLength') ) {
        # Is integer and length match
        if ( $cardnumber_length =~ m|^\d+$| ) {
            $min = $max = $cardnumber_length
                if $cardnumber_length >= $min
                    and $cardnumber_length <= $max;
        }
        # Else assuming it is a range
        elsif ( $cardnumber_length =~ m|(\d*),(\d*)| ) {
            $min = $1 if $1 and $min < $1;
            $max = $2 if $2 and $max > $2;
        }

    }
    $min = $max if $min > $max;
    return ( $min, $max );
}

=head2 GetBorrowersToExpunge

  $borrowers = &GetBorrowersToExpunge(
      not_borrowed_since => $not_borrowed_since,
      expired_before       => $expired_before,
      category_code        => $category_code,
      patron_list_id       => $patron_list_id,
      branchcode           => $branchcode
  );

  This function get all borrowers based on the given criteria.

=cut

sub GetBorrowersToExpunge {

    my $params = shift;
    my $filterdate       = $params->{'not_borrowed_since'};
    my $filterexpiry     = $params->{'expired_before'};
    my $filterlastseen   = $params->{'last_seen'};
    my $filtercategory   = $params->{'category_code'};
    my $filterbranch     = $params->{'branchcode'} ||
                        ((C4::Context->preference('IndependentBranches')
                             && C4::Context->userenv 
                             && !C4::Context->IsSuperLibrarian()
                             && C4::Context->userenv->{branch})
                         ? C4::Context->userenv->{branch}
                         : "");  
    my $filterpatronlist = $params->{'patron_list_id'};

    my $dbh   = C4::Context->dbh;
    my $query = q|
        SELECT *
        FROM (
            SELECT borrowers.borrowernumber,
                   MAX(old_issues.timestamp) AS latestissue,
                   MAX(issues.timestamp) AS currentissue
            FROM   borrowers
            JOIN   categories USING (categorycode)
            LEFT JOIN (
                SELECT guarantorid
                FROM borrowers
                WHERE guarantorid IS NOT NULL
                    AND guarantorid <> 0
            ) as tmp ON borrowers.borrowernumber=tmp.guarantorid
            LEFT JOIN old_issues USING (borrowernumber)
            LEFT JOIN issues USING (borrowernumber)|;
    if ( $filterpatronlist  ){
        $query .= q| LEFT JOIN patron_list_patrons USING (borrowernumber)|;
    }
    $query .= q| WHERE  category_type <> 'S'
        AND tmp.guarantorid IS NULL
    |;
    my @query_params;
    if ( $filterbranch && $filterbranch ne "" ) {
        $query.= " AND borrowers.branchcode = ? ";
        push( @query_params, $filterbranch );
    }
    if ( $filterexpiry ) {
        $query .= " AND dateexpiry < ? ";
        push( @query_params, $filterexpiry );
    }
    if ( $filterlastseen ) {
        $query .= ' AND lastseen < ? ';
        push @query_params, $filterlastseen;
    }
    if ( $filtercategory ) {
        $query .= " AND categorycode = ? ";
        push( @query_params, $filtercategory );
    }
    if ( $filterpatronlist ){
        $query.=" AND patron_list_id = ? ";
        push( @query_params, $filterpatronlist );
    }
    $query .= " GROUP BY borrowers.borrowernumber";
    $query .= q|
        ) xxx WHERE currentissue IS NULL|;
    if ( $filterdate ) {
        $query.=" AND ( latestissue < ? OR latestissue IS NULL ) ";
        push @query_params,$filterdate;
    }

    warn $query if $debug;

    my $sth = $dbh->prepare($query);
    if (scalar(@query_params)>0){  
        $sth->execute(@query_params);
    }
    else {
        $sth->execute;
    }
    
    my @results;
    while ( my $data = $sth->fetchrow_hashref ) {
        push @results, $data;
    }
    return \@results;
}

=head2 IssueSlip

  IssueSlip($branchcode, $borrowernumber, $quickslip)

  Returns letter hash ( see C4::Letters::GetPreparedLetter )

  $quickslip is boolean, to indicate whether we want a quick slip

  IssueSlip populates ISSUESLIP and ISSUEQSLIP, and will make the following expansions:

  Both slips:

      <<branches.*>>
      <<borrowers.*>>

  ISSUESLIP:

      <checkedout>
         <<biblio.*>>
         <<items.*>>
         <<biblioitems.*>>
         <<issues.*>>
      </checkedout>

      <overdue>
         <<biblio.*>>
         <<items.*>>
         <<biblioitems.*>>
         <<issues.*>>
      </overdue>

      <news>
         <<opac_news.*>>
      </news>

  ISSUEQSLIP:

      <checkedout>
         <<biblio.*>>
         <<items.*>>
         <<biblioitems.*>>
         <<issues.*>>
      </checkedout>

  NOTE: Fields from tables issues, items, biblio and biblioitems are available

=cut

sub IssueSlip {
    my ($branch, $borrowernumber, $quickslip) = @_;

    # FIXME Check callers before removing this statement
    #return unless $borrowernumber;

    my $patron = Koha::Patrons->find( $borrowernumber );
    return unless $patron;

    my $pending_checkouts = $patron->pending_checkouts; # Should be $patron->checkouts->pending?

    my ($letter_code, %repeat, %loops);
    if ( $quickslip ) {
        my $today_start = dt_from_string->set( hour => 0, minute => 0, second => 0 );
        my $today_end = dt_from_string->set( hour => 23, minute => 59, second => 0 );
        $today_start = Koha::Database->new->schema->storage->datetime_parser->format_datetime( $today_start );
        $today_end = Koha::Database->new->schema->storage->datetime_parser->format_datetime( $today_end );
        $letter_code = 'ISSUEQSLIP';

        # issue date or lastreneweddate is today
        my $todays_checkouts = $pending_checkouts->search(
            {
                -or => {
                    issuedate => {
                        '>=' => $today_start,
                        '<=' => $today_end,
                    },
                    lastreneweddate =>
                      { '>=' => $today_start, '<=' => $today_end, }
                }
            }
        );
        my @checkouts;
        while ( my $c = $todays_checkouts->next ) {
            my $all = $c->unblessed_all_relateds;
            push @checkouts, {
                biblio      => $all,
                items       => $all,
                biblioitems => $all,
                issues      => $all,
            };
        }

        %repeat =  (
            checkedout => \@checkouts, # Historical syntax
        );
        %loops = (
            issues => [ map { $_->{issues}{itemnumber} } @checkouts ], # TT syntax
        );
    }
    else {
        my $today = Koha::Database->new->schema->storage->datetime_parser->format_datetime( dt_from_string );
        # Checkouts due in the future
        my $checkouts = $pending_checkouts->search({ date_due => { '>' => $today } });
        my @checkouts; my @overdues;
        while ( my $c = $checkouts->next ) {
            my $all = $c->unblessed_all_relateds;
            push @checkouts, {
                biblio      => $all,
                items       => $all,
                biblioitems => $all,
                issues      => $all,
            };
        }

        # Checkouts due in the past are overdues
        my $overdues = $pending_checkouts->search({ date_due => { '<=' => $today } });
        while ( my $o = $overdues->next ) {
            my $all = $o->unblessed_all_relateds;
            push @overdues, {
                biblio      => $all,
                items       => $all,
                biblioitems => $all,
                issues      => $all,
            };
        }
        my $news = GetNewsToDisplay( "slip", $branch );
        my @news = map {
            $_->{'timestamp'} = $_->{'newdate'};
            { opac_news => $_ }
        } @$news;
        $letter_code = 'ISSUESLIP';
        %repeat      = (
            checkedout => \@checkouts,
            overdue    => \@overdues,
            news       => \@news,
        );
        %loops = (
            issues => [ map { $_->{issues}{itemnumber} } @checkouts ],
            overdues   => [ map { $_->{issues}{itemnumber} } @overdues ],
            opac_news => [ map { $_->{opac_news}{idnew} } @news ],
        );
    }

    return  C4::Letters::GetPreparedLetter (
        module => 'circulation',
        letter_code => $letter_code,
        branchcode => $branch,
        lang => $patron->lang,
        tables => {
            'branches'    => $branch,
            'borrowers'   => $borrowernumber,
        },
        repeat => \%repeat,
        loops => \%loops,
    );
}

=head2 DeleteExpiredOpacRegistrations

    Delete accounts that haven't been upgraded from the 'temporary' category
    Returns the number of removed patrons

=cut

sub DeleteExpiredOpacRegistrations {

    my $delay = C4::Context->preference('PatronSelfRegistrationExpireTemporaryAccountsDelay');
    my $category_code = C4::Context->preference('PatronSelfRegistrationDefaultCategory');

    return 0 if not $category_code or not defined $delay or $delay eq q||;

    my $query = qq|
SELECT borrowernumber
FROM borrowers
WHERE categorycode = ? AND DATEDIFF( NOW(), dateenrolled ) > ? |;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute( $category_code, $delay );
    my $cnt=0;
    while ( my ($borrowernumber) = $sth->fetchrow_array() ) {
        Koha::Patrons->find($borrowernumber)->delete;
        $cnt++;
    }
    return $cnt;
}

=head2 DeleteUnverifiedOpacRegistrations

    Delete all unverified self registrations in borrower_modifications,
    older than the specified number of days.

=cut

sub DeleteUnverifiedOpacRegistrations {
    my ( $days ) = @_;
    my $dbh = C4::Context->dbh;
    my $sql=qq|
DELETE FROM borrower_modifications
WHERE borrowernumber = 0 AND DATEDIFF( NOW(), timestamp ) > ?|;
    my $cnt=$dbh->do($sql, undef, ($days) );
    return $cnt eq '0E0'? 0: $cnt;
}

END { }    # module clean-up code here (global destructor)

1;

__END__

=head1 AUTHOR

Koha Team

=cut
