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

use Modern::Perl;
use CGI qw ( -utf8 );

use C4::Context;
use C4::Output;
use C4::Letters;
use C4::Biblio qw( GetMarcFromKohaField );
use Koha::DateUtils qw( dt_from_string );
use Koha::Suggestions;

use base qw(Exporter);

our @EXPORT  = qw(
  ConnectSuggestionAndBiblio
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
  GetUnprocessedSuggestions
  MarcRecordFromNewSuggestion
);

=head1 NAME

C4::Suggestions - Some useful functions for dealings with aqorders.

=head1 SYNOPSIS

use C4::Suggestions;

=head1 DESCRIPTION

The functions in this module deal with the aqorders in OPAC and in librarian interface

A suggestion is done in the OPAC. It has the status "ASKED"

When a librarian manages the suggestion, they can set the status to "REJECTED" or "ACCEPTED".

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
            U1.cardnumber       AS cardnumbersuggestedby,
            U1.email            AS emailsuggestedby,
            U1.borrowernumber   AS borrnumsuggestedby,
            U1.categorycode     AS categorycodesuggestedby,
            C1.description      AS categorydescriptionsuggestedby,
            U2.surname          AS surnamemanagedby,
            U2.firstname        AS firstnamemanagedby,
            B2.branchname       AS branchnamesuggestedby,
            U2.email            AS emailmanagedby,
            U2.branchcode       AS branchcodemanagedby,
            U2.borrowernumber   AS borrnummanagedby,
            U3.surname          AS surnamelastmodificationby,
            U3.firstname        AS firstnamelastmodificationby,
            BU.budget_name      AS budget_name
        FROM suggestions
            LEFT JOIN borrowers     AS U1 ON suggestedby=U1.borrowernumber
            LEFT JOIN branches      AS B1 ON B1.branchcode=U1.branchcode
            LEFT JOIN categories    AS C1 ON C1.categorycode=U1.categorycode
            LEFT JOIN borrowers     AS U2 ON managedby=U2.borrowernumber
            LEFT JOIN branches      AS B2 ON B2.branchcode=U2.branchcode
            LEFT JOIN categories    AS C2 ON C2.categorycode=U2.categorycode
            LEFT JOIN borrowers     AS U3 ON lastmodificationby=U3.borrowernumber
            LEFT JOIN aqbudgets     AS BU ON budgetid=BU.budget_id
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
    if (   C4::Context->preference('IndependentBranches')
        && !C4::Context->IsSuperLibrarian() )
    {
        # If IndependentBranches is set and the logged in user is not superlibrarian
        # Then we want to filter by the user's library (i.e. cannot see suggestions from other libraries)
        my $userenv = C4::Context->userenv;
        if ($userenv) {
            {
                push @sql_params, $$userenv{branch};
                push @query,      q{
                    AND (suggestions.branchcode=? OR suggestions.branchcode='')
                };
            }
        }
    }
    elsif (defined $suggestion->{branchcode}
        && $suggestion->{branchcode}
        && $suggestion->{branchcode} ne '__ANY__' )
    {
        # If IndependentBranches is not set OR the logged in user is not superlibrarian
        # AND the branchcode filter is passed and not '__ANY__'
        # Then we want to filter using this parameter
        push @sql_params, $suggestion->{branchcode};
        push @query,      qq{ AND suggestions.branchcode=? };
    }

    # filter on nillable fields
    foreach my $field (
        qw( STATUS itemtype suggestedby managedby acceptedby budgetid biblionumber )
      )
    {
        if ( exists $suggestion->{$field}
                and defined $suggestion->{$field}
                and $suggestion->{$field} ne '__ANY__'
                and (
                    $suggestion->{$field} ne q||
                        or $field eq 'STATUS'
                )
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
    my $dtf = Koha::Database->new->schema->storage->datetime_parser;
    foreach my $field (qw( suggesteddate manageddate accepteddate )) {
        my $from = $field . "_from";
        my $to   = $field . "_to";
        my $from_dt;
        $from_dt = eval { dt_from_string( $suggestion->{$from} ) } if ( $suggestion->{$from} );
        my $to_dt;
        $to_dt = eval { dt_from_string( $suggestion->{$to} ) } if ( $suggestion->{$to} );
        if ( $from_dt ) {
            push @query, qq{ AND suggestions.$field >= ?};
            push @sql_params, $dtf->format_date($from_dt);
        }
        if ( $to_dt ) {
            push @query, qq{ AND suggestions.$field <= ?};
            push @sql_params, $dtf->format_date($to_dt);
        }
    }

    # By default do not search for archived suggestions
    unless ( exists $suggestion->{archived} && $suggestion->{archived} ) {
        push @query, q{ AND suggestions.archived = 0 };
    }

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
        ORDER BY suggestionid
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

=head2 NewSuggestion


&NewSuggestion($suggestion);

Insert a new suggestion on database with value given on input arg.

=cut

sub NewSuggestion {
    my ($suggestion) = @_;

    $suggestion->{STATUS} = "ASKED" unless $suggestion->{STATUS};

    $suggestion->{suggesteddate} = dt_from_string unless $suggestion->{suggesteddate};

    delete $suggestion->{branchcode} if $suggestion->{branchcode} eq '';

    my $suggestion_object = Koha::Suggestion->new( $suggestion )->store;
    my $suggestion_id = $suggestion_object->suggestionid;

    my $emailpurchasesuggestions = C4::Context->preference("EmailPurchaseSuggestions");
    if ($emailpurchasesuggestions) {
        my $full_suggestion = GetSuggestion( $suggestion_id); # We should not need to refetch it!
        if (
            my $letter = C4::Letters::GetPreparedLetter(
                module      => 'suggestions',
                letter_code => 'NEW_SUGGESTION',
                tables      => {
                    'branches'    => $full_suggestion->{branchcode},
                    'borrowers'   => $full_suggestion->{suggestedby},
                    'suggestions' => $full_suggestion,
                },
            )
        ){

            my $toaddress;
            if ( $emailpurchasesuggestions eq "BranchEmailAddress" ) {
                my $library =
                  Koha::Libraries->find( $full_suggestion->{branchcode} );
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
                    borrowernumber => $full_suggestion->{suggestedby},
                    suggestionid   => $full_suggestion->{suggestionid},
                    to_address     => $toaddress,
                    message_transport_type => 'email',
                }
            ) or warn "can't enqueue letter $letter";
        }
    }

    return $suggestion_id;
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

    my $suggestion_object = Koha::Suggestions->find( $suggestion->{suggestionid} );
    eval { # FIXME Must raise an exception instead
        $suggestion_object->set($suggestion)->store;
    };
    return 0 if $@;

    if ( $suggestion->{STATUS} && $suggestion_object->suggestedby ) {

        # fetch the entire updated suggestion so that we can populate the letter
        my $full_suggestion = GetSuggestion( $suggestion->{suggestionid} );

        my $patron = Koha::Patrons->find( $full_suggestion->{suggestedby} );

        my $transport = (C4::Context->preference("FallbackToSMSIfNoEmail")) && ($patron->smsalertnumber) && (!$patron->email) ? 'sms' : 'email';

        if (
            my $letter = C4::Letters::GetPreparedLetter(
                module      => 'suggestions',
                letter_code => $full_suggestion->{STATUS},
                branchcode  => $full_suggestion->{branchcode},
                lang        => $patron->lang,
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
                    message_transport_type => $transport,
                }
            ) or warn "can't enqueue letter $letter";
        }
    }
    return 1; # No useful if the exception is raised earlier
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

Delete a suggestion. A borrower can delete a suggestion only if they are its owner.

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
    We do now allow a negative number. If you want to delete all suggestions, just use Koha::Suggestions->delete or so.

=cut

sub DelSuggestionsOlderThan {
    my ($days) = @_;
    return unless $days && $days > 0;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare(
        q{
        DELETE FROM suggestions
        WHERE STATUS<>'ASKED'
            AND manageddate < ADDDATE(NOW(), ?)
    }
    );
    $sth->execute("-$days");
}

sub GetUnprocessedSuggestions {
    my ( $number_of_days_since_the_last_modification ) = @_;

    $number_of_days_since_the_last_modification ||= 0;

    my $dbh = C4::Context->dbh;

    my $s = $dbh->selectall_arrayref(q|
        SELECT *
        FROM suggestions
        WHERE STATUS = 'ASKED'
            AND budgetid IS NOT NULL
            AND CAST(NOW() AS DATE) - INTERVAL ? DAY = CAST(suggesteddate AS DATE)
    |, { Slice => {} }, $number_of_days_since_the_last_modification );
    return $s;
}

=head2 MarcRecordFromNewSuggestion

    $record = MarcRecordFromNewSuggestion ( $suggestion )

This function build a marc record object from a suggestion

=cut

sub MarcRecordFromNewSuggestion {
    my ($suggestion) = @_;
    my $record = MARC::Record->new();

    if (my $isbn = $suggestion->{isbn}) {
        for my $field (qw(biblioitems.isbn biblioitems.issn)) {
            my ($tag, $subfield) = GetMarcFromKohaField($field, '');
            $record->append_fields(
                MARC::Field->new($tag, ' ', ' ', $subfield => $isbn)
            );
        }
    }
    else {
        my ($title_tag, $title_subfield) = GetMarcFromKohaField('biblio.title', '');
        $record->append_fields(
            MARC::Field->new($title_tag, ' ', ' ', $title_subfield => $suggestion->{title})
        );

        my ($author_tag, $author_subfield) = GetMarcFromKohaField('biblio.author', '');
        if ($record->field( $author_tag )) {
            $record->field( $author_tag )->add_subfields( $author_subfield => $suggestion->{author} );
        }
        else {
            $record->append_fields(
                MARC::Field->new($author_tag, ' ', ' ', $author_subfield => $suggestion->{author})
            );
        }
    }

    my ($it_tag, $it_subfield) = GetMarcFromKohaField('biblioitems.itemtype', '');
    if ($record->field( $it_tag )) {
        $record->field( $it_tag )->add_subfields( $it_subfield => $suggestion->{itemtype} );
    }
    else {
        $record->append_fields(
            MARC::Field->new($it_tag, ' ', ' ', $it_subfield => $suggestion->{itemtype})
        );
    }

    return $record;
}

1;
__END__


=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=cut

