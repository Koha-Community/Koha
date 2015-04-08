package C4::Suggestions;

# Copyright 2000-2002 Katipo Communications
# Parts Copyright Biblibre 2011
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
use CGI;

use C4::Context;
use C4::Output;
use C4::Dates qw(format_date format_date_in_iso);
use C4::Debug;
use C4::Letters;
use Koha::DateUtils qw( dt_from_string );

use List::MoreUtils qw(any);
use C4::Dates qw(format_date_in_iso);
use base qw(Exporter);

our $VERSION = 3.07.00.049;
our @EXPORT  = qw(
  ConnectSuggestionAndBiblio
  CountSuggestion
  DelSuggestion
  GetSuggestion
  GetSuggestionByStatus
  GetSuggestionFromBiblionumber
  GetSuggestionInfoFromBiblionumber
  GetSuggestionInfo
  ModStatus
  ModSuggestion
  NewSuggestion
  SearchSuggestion
  DelSuggestionsOlderThan
);

=head1 NAME

C4::Suggestions - Some useful functions for dealings with aqorders.

=head1 SYNOPSIS

use C4::Suggestions;

=head1 DESCRIPTION

The functions in this module deal with the aqorders in OPAC and in librarian interface

A suggestion is done in the OPAC. It has the status "ASKED"

When a librarian manages the suggestion, he can set the status to "REJECTED" or "ACCEPTED".

When the book is ordered, the suggestion status becomes "ORDERED"

When a book is ordered and arrived in the library, the status becomes "AVAILABLE"

All aqorders of a borrower can be seen by the borrower itself.
Suggestions done by other borrowers can be seen when not "AVAILABLE"

=head1 FUNCTIONS

=head2 SearchSuggestion

(\@array) = &SearchSuggestion($suggestionhashref_to_search)

searches for a suggestion

return :
C<\@array> : the aqorders found. Array of hash.
Note the status is stored twice :
* in the status field
* as parameter ( for example ASKED => 1, or REJECTED => 1) . This is for template & translation purposes.

=cut

sub SearchSuggestion {
    my ($suggestion) = @_;
    my $dbh = C4::Context->dbh;
    my @sql_params;
    my @query = (
        q{
        SELECT suggestions.*,
            U1.branchcode       AS branchcodesuggestedby,
            B1.branchname       AS branchnamesuggestedby,
            U1.surname          AS surnamesuggestedby,
            U1.firstname        AS firstnamesuggestedby,
            U1.email            AS emailsuggestedby,
            U1.borrowernumber   AS borrnumsuggestedby,
            U1.categorycode     AS categorycodesuggestedby,
            C1.description      AS categorydescriptionsuggestedby,
            U2.surname          AS surnamemanagedby,
            U2.firstname        AS firstnamemanagedby,
            B2.branchname       AS branchnamesuggestedby,
            U2.email            AS emailmanagedby,
            U2.branchcode       AS branchcodemanagedby,
            U2.borrowernumber   AS borrnummanagedby
        FROM suggestions
            LEFT JOIN borrowers     AS U1 ON suggestedby=U1.borrowernumber
            LEFT JOIN branches      AS B1 ON B1.branchcode=U1.branchcode
            LEFT JOIN categories    AS C1 ON C1.categorycode=U1.categorycode
            LEFT JOIN borrowers     AS U2 ON managedby=U2.borrowernumber
            LEFT JOIN branches      AS B2 ON B2.branchcode=U2.branchcode
            LEFT JOIN categories    AS C2 ON C2.categorycode=U2.categorycode
        WHERE 1=1
    }
    );

    # filter on biblio informations
    foreach my $field (
        qw( title author isbn publishercode copyrightdate collectiontitle ))
    {
        if ( $suggestion->{$field} ) {
            push @sql_params, '%' . $suggestion->{$field} . '%';
            push @query,      qq{ AND suggestions.$field LIKE ? };
        }
    }

    # filter on user branch
    if ( C4::Context->preference('IndependentBranches') ) {
        my $userenv = C4::Context->userenv;
        if ($userenv) {
            if ( !C4::Context->IsSuperLibrarian() && !$suggestion->{branchcode} )
            {
                push @sql_params, $$userenv{branch};
                push @query,      q{
                    AND (suggestions.branchcode=? OR suggestions.branchcode='')
                };
            }
        }
    } else {
        if ( defined $suggestion->{branchcode} && $suggestion->{branchcode} ) {
            unless ( $suggestion->{branchcode} eq '__ANY__' ) {
                push @sql_params, $suggestion->{branchcode};
                push @query,      qq{ AND suggestions.branchcode=? };
            }
        }
    }

    # filter on nillable fields
    foreach my $field (
        qw( STATUS itemtype suggestedby managedby acceptedby budgetid biblionumber )
      )
    {
        if ( exists $suggestion->{$field}
                and defined $suggestion->{$field}
                and $suggestion->{$field} ne '__ANY__'
                and $suggestion->{$field} ne q||
        ) {
            if ( $suggestion->{$field} eq '__NONE__' ) {
                push @query, qq{ AND (suggestions.$field = '' OR suggestions.$field IS NULL) };
            }
            else {
                push @sql_params, $suggestion->{$field};
                push @query, qq{ AND suggestions.$field = ? };
            }
        }
    }

    # filter on date fields
    my $today = C4::Dates->today('iso');
    foreach my $field (qw( suggesteddate manageddate accepteddate )) {
        my $from = $field . "_from";
        my $to   = $field . "_to";
        if ( $suggestion->{$from} || $suggestion->{$to} ) {
            push @query, qq{ AND suggestions.$field BETWEEN ? AND ? };
            push @sql_params,
              format_date_in_iso( $suggestion->{$from} ) || '0000-00-00';
            push @sql_params,
              format_date_in_iso( $suggestion->{$to} ) || $today;
        }
    }

    $debug && warn "@query";
    my $sth = $dbh->prepare("@query");
    $sth->execute(@sql_params);
    my @results;

    # add status as field
    while ( my $data = $sth->fetchrow_hashref ) {
        $data->{ $data->{STATUS} } = 1;
        push( @results, $data );
    }

    return ( \@results );
}

=head2 GetSuggestion

\%sth = &GetSuggestion($suggestionid)

this function get the detail of the suggestion $suggestionid (input arg)

return :
    the result of the SQL query as a hash : $sth->fetchrow_hashref.

=cut

sub GetSuggestion {
    my ($suggestionid) = @_;
    my $dbh           = C4::Context->dbh;
    my $query         = q{
        SELECT *
        FROM   suggestions
        WHERE  suggestionid=?
    };
    my $sth = $dbh->prepare($query);
    $sth->execute($suggestionid);
    return ( $sth->fetchrow_hashref );
}

=head2 GetSuggestionFromBiblionumber

$ordernumber = &GetSuggestionFromBiblionumber($biblionumber)

Get a suggestion from it's biblionumber.

return :
the id of the suggestion which is related to the biblionumber given on input args.

=cut

sub GetSuggestionFromBiblionumber {
    my ($biblionumber) = @_;
    my $query = q{
        SELECT suggestionid
        FROM   suggestions
        WHERE  biblionumber=? LIMIT 1
    };
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute($biblionumber);
    my ($suggestionid) = $sth->fetchrow;
    return $suggestionid;
}

=head2 GetSuggestionInfoFromBiblionumber

Get a suggestion and borrower's informations from it's biblionumber.

return :
all informations (suggestion and borrower) of the suggestion which is related to the biblionumber given.

=cut

sub GetSuggestionInfoFromBiblionumber {
    my ($biblionumber) = @_;
    my $query = q{
        SELECT suggestions.*,
            U1.surname          AS surnamesuggestedby,
            U1.firstname        AS firstnamesuggestedby,
            U1.borrowernumber   AS borrnumsuggestedby
        FROM suggestions
            LEFT JOIN borrowers AS U1 ON suggestedby=U1.borrowernumber
        WHERE biblionumber=?
        LIMIT 1
    };
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute($biblionumber);
    return $sth->fetchrow_hashref;
}

=head2 GetSuggestionInfo

Get a suggestion and borrower's informations from it's suggestionid

return :
all informations (suggestion and borrower) of the suggestion which is related to the suggestionid given.

=cut

sub GetSuggestionInfo {
    my ($suggestionid) = @_;
    my $query = q{
        SELECT suggestions.*,
            U1.surname          AS surnamesuggestedby,
            U1.firstname        AS firstnamesuggestedby,
            U1.borrowernumber   AS borrnumsuggestedby
        FROM suggestions
            LEFT JOIN borrowers AS U1 ON suggestedby=U1.borrowernumber
        WHERE suggestionid=?
        LIMIT 1
    };
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute($suggestionid);
    return $sth->fetchrow_hashref;
}

=head2 GetSuggestionByStatus

$aqorders = &GetSuggestionByStatus($status,[$branchcode])

Get a suggestion from it's status

return :
all the suggestion with C<$status>

=cut

sub GetSuggestionByStatus {
    my $status     = shift;
    my $branchcode = shift;
    my $dbh        = C4::Context->dbh;
    my @sql_params = ($status);
    my $query      = q{
        SELECT suggestions.*,
            U1.surname          AS surnamesuggestedby,
            U1.firstname        AS firstnamesuggestedby,
            U1.branchcode       AS branchcodesuggestedby,
            B1.branchname       AS branchnamesuggestedby,
            U1.borrowernumber   AS borrnumsuggestedby,
            U1.categorycode     AS categorycodesuggestedby,
            C1.description      AS categorydescriptionsuggestedby,
            U2.surname          AS surnamemanagedby,
            U2.firstname        AS firstnamemanagedby,
            U2.borrowernumber   AS borrnummanagedby
        FROM suggestions
            LEFT JOIN borrowers     AS U1 ON suggestedby=U1.borrowernumber
            LEFT JOIN borrowers     AS U2 ON managedby=U2.borrowernumber
            LEFT JOIN categories    AS C1 ON C1.categorycode=U1.categorycode
            LEFT JOIN branches      AS B1 on B1.branchcode=U1.branchcode
        WHERE status = ?
    };

    # filter on branch
    if ( C4::Context->preference("IndependentBranches") || $branchcode ) {
        my $userenv = C4::Context->userenv;
        if ($userenv) {
            unless ( C4::Context->IsSuperLibrarian() ) {
                push @sql_params, $userenv->{branch};
                $query .= q{ AND (U1.branchcode = ? OR U1.branchcode ='') };
            }
        }
        if ($branchcode) {
            push @sql_params, $branchcode;
            $query .= q{ AND (U1.branchcode = ? OR U1.branchcode ='') };
        }
    }

    my $sth = $dbh->prepare($query);
    $sth->execute(@sql_params);
    my $results;
    $results = $sth->fetchall_arrayref( {} );
    return $results;
}

=head2 CountSuggestion

&CountSuggestion($status)

Count the number of aqorders with the status given on input argument.
the arg status can be :

=over 2

=item * ASKED : asked by the user, not dealed by the librarian

=item * ACCEPTED : accepted by the librarian, but not yet ordered

=item * REJECTED : rejected by the librarian (definitive status)

=item * ORDERED : ordered by the librarian (acquisition module)

=back

return :
the number of suggestion with this status.

=cut

sub CountSuggestion {
    my ($status) = @_;
    my $dbh = C4::Context->dbh;
    my $sth;
    my $userenv = C4::Context->userenv;
    if ( C4::Context->preference("IndependentBranches")
        && !C4::Context->IsSuperLibrarian() )
    {
        my $query = q{
            SELECT count(*)
            FROM suggestions
                LEFT JOIN borrowers ON borrowers.borrowernumber=suggestions.suggestedby
            WHERE STATUS=?
                AND (borrowers.branchcode='' OR borrowers.branchcode=?)
        };
        $sth = $dbh->prepare($query);
        $sth->execute( $status, $userenv->{branch} );
    }
    else {
        my $query = q{
            SELECT count(*)
            FROM suggestions
            WHERE STATUS=?
        };
        $sth = $dbh->prepare($query);
        $sth->execute($status);
    }
    my ($result) = $sth->fetchrow;
    return $result;
}

=head2 NewSuggestion


&NewSuggestion($suggestion);

Insert a new suggestion on database with value given on input arg.

=cut

sub NewSuggestion {
    my ($suggestion) = @_;

    for my $field ( qw(
        suggestedby
        managedby
        manageddate
        acceptedby
        accepteddate
        rejectedby
        rejecteddate
    ) ) {
        # Set the fields to NULL if not given.
        $suggestion->{$field} ||= undef;
    }

    $suggestion->{STATUS} = "ASKED" unless $suggestion->{STATUS};

    $suggestion->{suggesteddate} = dt_from_string unless $suggestion->{suggesteddate};

    my $rs = Koha::Database->new->schema->resultset('Suggestion');
    return $rs->create($suggestion)->id;
}

=head2 ModSuggestion

&ModSuggestion($suggestion)

Modify the suggestion according to the hash passed by ref.
The hash HAS to contain suggestionid
Data not defined is not updated unless it is a note or sort1
Send a mail to notify the user that did the suggestion.

Note that there is no function to modify a suggestion.

=cut

sub ModSuggestion {
    my ($suggestion) = @_;
    return unless( $suggestion and defined($suggestion->{suggestionid}) );

    for my $field ( qw(
        suggestedby
        managedby
        manageddate
        acceptedby
        accepteddate
        rejectedby
        rejecteddate
    ) ) {
        # Set the fields to NULL if not given.
        $suggestion->{$field} = undef
          if exists $suggestion->{$field}
          and ($suggestion->{$field} eq '0'
            or $suggestion->{$field} eq '' );
    }

    my $rs = Koha::Database->new->schema->resultset('Suggestion')->find($suggestion->{suggestionid});
    my $status_update_table = 1;
    eval {
        $rs->update($suggestion);
    };
    $status_update_table = 0 if( $@ );

    if ( $suggestion->{STATUS} ) {

        # fetch the entire updated suggestion so that we can populate the letter
        my $full_suggestion = GetSuggestion( $suggestion->{suggestionid} );
        if (
            my $letter = C4::Letters::GetPreparedLetter(
                module      => 'suggestions',
                letter_code => $full_suggestion->{STATUS},
                branchcode  => $full_suggestion->{branchcode},
                tables      => {
                    'branches'    => $full_suggestion->{branchcode},
                    'borrowers'   => $full_suggestion->{suggestedby},
                    'suggestions' => $full_suggestion,
                    'biblio'      => $full_suggestion->{biblionumber},
                },
            )
          )
        {
            C4::Letters::EnqueueLetter(
                {
                    letter         => $letter,
                    borrowernumber => $full_suggestion->{suggestedby},
                    suggestionid   => $full_suggestion->{suggestionid},
                    LibraryName    => C4::Context->preference("LibraryName"),
                    message_transport_type => 'email',
                }
            ) or warn "can't enqueue letter $letter";
        }
    }
    return $status_update_table;
}

=head2 ConnectSuggestionAndBiblio

&ConnectSuggestionAndBiblio($ordernumber,$biblionumber)

connect a suggestion to an existing biblio

=cut

sub ConnectSuggestionAndBiblio {
    my ( $suggestionid, $biblionumber ) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = q{
        UPDATE suggestions
        SET    biblionumber=?
        WHERE  suggestionid=?
    };
    my $sth = $dbh->prepare($query);
    $sth->execute( $biblionumber, $suggestionid );
}

=head2 DelSuggestion

&DelSuggestion($borrowernumber,$ordernumber)

Delete a suggestion. A borrower can delete a suggestion only if he is its owner.

=cut

sub DelSuggestion {
    my ( $borrowernumber, $suggestionid, $type ) = @_;
    my $dbh = C4::Context->dbh;

    # check that the suggestion comes from the suggestor
    my $query = q{
        SELECT suggestedby
        FROM   suggestions
        WHERE  suggestionid=?
    };
    my $sth = $dbh->prepare($query);
    $sth->execute($suggestionid);
    my ($suggestedby) = $sth->fetchrow;
    if ( $type eq 'intranet' || $suggestedby eq $borrowernumber ) {
        my $queryDelete = q{
            DELETE FROM suggestions
            WHERE suggestionid=?
        };
        $sth = $dbh->prepare($queryDelete);
        my $suggestiondeleted = $sth->execute($suggestionid);
        return $suggestiondeleted;
    }
}

=head2 DelSuggestionsOlderThan
    &DelSuggestionsOlderThan($days)

    Delete all suggestions older than TODAY-$days , that have be accepted or rejected.

=cut

sub DelSuggestionsOlderThan {
    my ($days) = @_;
    return unless $days;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare(
        q{
        DELETE FROM suggestions
        WHERE STATUS<>'ASKED'
            AND date < ADDDATE(NOW(), ?)
    }
    );
    $sth->execute("-$days");
}

1;
__END__


=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=cut

