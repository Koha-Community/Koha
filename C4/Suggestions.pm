package C4::Suggestions;

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA


use strict;
use CGI;
use Mail::Sendmail;

use C4::Context;
use C4::Output;
use C4::Dates qw(format_date);
use vars qw($VERSION @ISA @EXPORT);

BEGIN {
	# set the version for version checking
	$VERSION = 3.01;
	require Exporter;
	@ISA = qw(Exporter);
	@EXPORT = qw(
		&NewSuggestion
		&SearchSuggestion
		&GetSuggestion
		&GetSuggestionByStatus
		&DelSuggestion
		&CountSuggestion
		&ModStatus
		&ConnectSuggestionAndBiblio
		&GetSuggestionFromBiblionumber
	);
}

=head1 NAME

C4::Suggestions - Some useful functions for dealings with suggestions.

=head1 SYNOPSIS

use C4::Suggestions;

=head1 DESCRIPTION

The functions in this module deal with the suggestions in OPAC and in librarian interface

A suggestion is done in the OPAC. It has the status "ASKED"

When a librarian manages the suggestion, he can set the status to "REJECTED" or "ACCEPTED".

When the book is ordered, the suggestion status becomes "ORDERED"

When a book is ordered and arrived in the library, the status becomes "AVAILABLE"

All suggestions of a borrower can be seen by the borrower itself.
Suggestions done by other borrowers can be seen when not "AVAILABLE"

=head1 FUNCTIONS

=head2 SearchSuggestion

(\@array) = &SearchSuggestion($user,$author,$title,$publishercode,$status,$suggestedbyme,$branchcode)

searches for a suggestion

return :
C<\@array> : the suggestions found. Array of hash.
Note the status is stored twice :
* in the status field
* as parameter ( for example ASKED => 1, or REJECTED => 1) . This is for template & translation purposes.

=cut

sub SearchSuggestion  {
    my ($user,$author,$title,$publishercode,$status,$suggestedbyme,$branchcode)=@_;
    my $dbh = C4::Context->dbh;
    my $query = "
    SELECT suggestions.*,
        U1.branchcode   AS branchcodesuggestedby,
        U1.surname   AS surnamesuggestedby,
        U1.firstname AS firstnamesuggestedby,
        U1.borrowernumber AS borrnumsuggestedby,
        U1.branchcode AS branchcodesuggestedby,
        U2.surname   AS surnamemanagedby,
        U2.firstname AS firstnamemanagedby,
        U2.borrowernumber AS borrnummanagedby
    FROM suggestions
    LEFT JOIN borrowers AS U1 ON suggestedby=U1.borrowernumber
    LEFT JOIN borrowers AS U2 ON managedby=U2.borrowernumber
    WHERE 1=1 ";

    my @sql_params;
    if ($author) {
       push @sql_params,"%".$author."%";
       $query .= " and author like ?";
    }
    if ($title) {
        push @sql_params,"%".$title."%";
        $query .= " and suggestions.title like ?";
    }
    if ($publishercode) {
        push @sql_params,"%".$publishercode."%";
        $query .= " and publishercode like ?";
    }
    if (C4::Context->preference("IndependantBranches") || $branchcode) {
        my $userenv = C4::Context->userenv;
        if ($userenv) {
            unless ($userenv->{flags} % 2 == 1){
                push @sql_params,$userenv->{branch};
                $query .= " and (U1.branchcode = ? or U1.branchcode ='')";
            }
        }
        if ($branchcode) {
            push @sql_params,$branchcode;
            $query .= " and (U1.branchcode = ? or U1.branchcode ='')";
        }
    }
    if ($status) {
        push @sql_params,$status;
        $query .= " and status=?";
    }
    if ($suggestedbyme) {
        unless ($suggestedbyme eq -1) {
            push @sql_params,$user;
            $query .= " and suggestedby=?";
        }
    } else {
        $query .= " and managedby is NULL";
    }
    my $sth=$dbh->prepare($query);
    $sth->execute(@sql_params);
    my @results;
    my $even=1; # the even variable is used to set even / odd lines, for highlighting
    while (my $data=$sth->fetchrow_hashref){
        $data->{$data->{STATUS}} = 1;
        if ($even) {
            $even=0;
            $data->{even}=1;
        } else {
            $even=1;
        }
#         $data->{date} = format_date($data->{date});
        push(@results,$data);
    }
    return (\@results);
}

=head2 GetSuggestion

\%sth = &GetSuggestion($suggestionid)

this function get the detail of the suggestion $suggestionid (input arg)

return :
    the result of the SQL query as a hash : $sth->fetchrow_hashref.

=cut

sub GetSuggestion {
    my ($suggestionid) = @_;
    my $dbh = C4::Context->dbh;
    my $query = "
        SELECT *
        FROM   suggestions
        WHERE  suggestionid=?
    ";
    my $sth = $dbh->prepare($query);
    $sth->execute($suggestionid);
    return($sth->fetchrow_hashref);
}

=head2 GetSuggestionFromBiblionumber

$suggestionid = &GetSuggestionFromBiblionumber($dbh,$biblionumber)

Get a suggestion from it's biblionumber.

return :
the id of the suggestion which is related to the biblionumber given on input args.

=cut

sub GetSuggestionFromBiblionumber {
    my ($dbh,$biblionumber) = @_;
    my $query = qq|
        SELECT suggestionid
        FROM   suggestions
        WHERE  biblionumber=?
    |;
    my $sth = $dbh->prepare($query);
    $sth->execute($biblionumber);
    my ($suggestionid) = $sth->fetchrow;
    return $suggestionid;
}

=head2 GetSuggestionByStatus

$suggestions = &GetSuggestionByStatus($status,[$branchcode])

Get a suggestion from it's status

return :
all the suggestion with C<$status>

=cut

sub GetSuggestionByStatus {
    my $status = shift;
    my $branchcode = shift;
    my $dbh = C4::Context->dbh;
    my @sql_params=($status);  
    my $query = qq(SELECT suggestions.*,
                        U1.surname   AS surnamesuggestedby,
                        U1.firstname AS firstnamesuggestedby,
            U1.branchcode AS branchcodesuggestedby,
						U1.borrowernumber AS borrnumsuggestedby,
                        U2.surname   AS surnamemanagedby,
                        U2.firstname AS firstnamemanagedby,
						U2.borrowernumber AS borrnummanagedby
                        FROM suggestions
                        LEFT JOIN borrowers AS U1 ON suggestedby=U1.borrowernumber
                        LEFT JOIN borrowers AS U2 ON managedby=U2.borrowernumber
                        WHERE status = ?);
    if (C4::Context->preference("IndependantBranches") || $branchcode) {
        my $userenv = C4::Context->userenv;
        if ($userenv) {
            unless ($userenv->{flags} % 2 == 1){
                push @sql_params,$userenv->{branch};
                $query .= " and (U1.branchcode = ? or U1.branchcode ='')";
            }
        }
        if ($branchcode) {
            push @sql_params,$branchcode;
            $query .= " and (U1.branchcode = ? or U1.branchcode ='')";
        }
    }
    
    my $sth = $dbh->prepare($query);
    $sth->execute(@sql_params);
    
    my $results;
    $results=  $sth->fetchall_arrayref({});
#     map{$_->{date} = format_date($_->{date})} @$results;
    return $results;
}

=head2 CountSuggestion

&CountSuggestion($status)

Count the number of suggestions with the status given on input argument.
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
    if (C4::Context->preference("IndependantBranches")){
        my $userenv = C4::Context->userenv;
        if ($userenv->{flags} % 2 == 1){
            my $query = qq |
                SELECT count(*)
                FROM   suggestions
                WHERE  status=?
            |;
            $sth = $dbh->prepare($query);
            $sth->execute($status);
        }
        else {
            my $query = qq |
                SELECT count(*)
                FROM suggestions LEFT JOIN borrowers ON borrowers.borrowernumber=suggestions.suggestedby
                WHERE status=?
                AND (borrowers.branchcode='' OR borrowers.branchcode =?)
            |;
            $sth = $dbh->prepare($query);
            $sth->execute($status,$userenv->{branch});
        }
    }
    else {
        my $query = qq |
            SELECT count(*)
            FROM suggestions
            WHERE status=?
        |;
         $sth = $dbh->prepare($query);
        $sth->execute($status);
    }
    my ($result) = $sth->fetchrow;
    return $result;
}

=head2 NewSuggestion


&NewSuggestion($borrowernumber,$title,$author,$publishercode,$note,$copyrightdate,$volumedesc,$publicationyear,$place,$isbn,$biblionumber)

Insert a new suggestion on database with value given on input arg.

=cut

sub NewSuggestion {
    my ($borrowernumber,$title,$author,$publishercode,$note,$copyrightdate,$volumedesc,$publicationyear,$place,$isbn,$biblionumber,$reason) = @_;
    my $dbh = C4::Context->dbh;
    my $query = qq |
        INSERT INTO suggestions
            (status,suggestedby,title,author,publishercode,note,copyrightdate,
            volumedesc,publicationyear,place,isbn,biblionumber,reason)
        VALUES ('ASKED',?,?,?,?,?,?,?,?,?,?,?,?)
    |;
    my $sth = $dbh->prepare($query);
    $sth->execute($borrowernumber,$title,$author,$publishercode,$note,$copyrightdate,$volumedesc,$publicationyear,$place,$isbn,$biblionumber,$reason);
}

=head2 ModStatus

&ModStatus($suggestionid,$status,$managedby,$biblionumber)

Modify the status (status can be 'ASKED', 'ACCEPTED', 'REJECTED', 'ORDERED')
and send a mail to notify the user that did the suggestion.

Note that there is no function to modify a suggestion : only the status can be modified, thus the name of the function.

=cut

sub ModStatus {
    my ($suggestionid,$status,$managedby,$biblionumber,$reason) = @_;
    my $dbh = C4::Context->dbh;
    my $sth;
    if ($managedby>0) {
        if ($biblionumber) {
        my $query = qq|
            UPDATE suggestions
            SET    status=?,managedby=?,biblionumber=?,reason=?
            WHERE  suggestionid=?
        |;
        $sth = $dbh->prepare($query);
        $sth->execute($status,$managedby,$biblionumber,$reason,$suggestionid);
        } else {
            my $query = qq|
                UPDATE suggestions
                SET    status=?,managedby=?,reason=?
                WHERE  suggestionid=?
            |;
            $sth = $dbh->prepare($query);
            $sth->execute($status,$managedby,$reason,$suggestionid);
        }
   } else {
        if ($biblionumber) {
            my $query = qq|
                UPDATE suggestions
                SET    status=?,biblionumber=?,reason=?
                WHERE  suggestionid=?
            |;
            $sth = $dbh->prepare($query);
            $sth->execute($status,$biblionumber,$reason,$suggestionid);
        }
        else {
            my $query = qq|
                UPDATE suggestions
                SET    status=?,reason=?
                WHERE  suggestionid=?
            |;
            $sth = $dbh->prepare($query);
            $sth->execute($status,$reason,$suggestionid);
        }
    }
    # check mail sending.
    my $queryMail = "
        SELECT suggestions.*,
            boby.surname AS bysurname,
            boby.firstname AS byfirstname,
            boby.email AS byemail,
            lib.surname AS libsurname,
            lib.firstname AS libfirstname,
            lib.email AS libemail
        FROM suggestions
            LEFT JOIN borrowers AS boby ON boby.borrowernumber=suggestedby
            LEFT JOIN borrowers AS lib ON lib.borrowernumber=managedby
        WHERE suggestionid=?
    ";
    $sth = $dbh->prepare($queryMail);
    $sth->execute($suggestionid);
    my $emailinfo = $sth->fetchrow_hashref;
    my $template = gettemplate("suggestion/mail_suggestion_$status.tmpl", "intranet", CGI->new());

    $template->param(
        byemail => $emailinfo->{byemail},
        libemail => $emailinfo->{libemail},
        status => $emailinfo->{status},
        title => $emailinfo->{title},
        author =>$emailinfo->{author},
        libsurname => $emailinfo->{libsurname},
        libfirstname => $emailinfo->{libfirstname},
        byfirstname => $emailinfo->{byfirstname},
        bysurname => $emailinfo->{bysurname},
        reason => $emailinfo->{reason}
    );
    my %mail = (
        To => $emailinfo->{byemail},
        From => $emailinfo->{libemail},
        Subject => 'Koha suggestion',
        Message => "".$template->output,
        'Content-Type' => 'text/plain; charset="utf8"',
    );
    sendmail(%mail);
}

=head2 ConnectSuggestionAndBiblio

&ConnectSuggestionAndBiblio($suggestionid,$biblionumber)

connect a suggestion to an existing biblio

=cut

sub ConnectSuggestionAndBiblio {
    my ($suggestionid,$biblionumber) = @_;
    my $dbh=C4::Context->dbh;
    my $query = "
        UPDATE suggestions
        SET    biblionumber=?
        WHERE  suggestionid=?
    ";
    my $sth = $dbh->prepare($query);
    $sth->execute($biblionumber,$suggestionid);
}

=head2 DelSuggestion

&DelSuggestion($borrowernumber,$suggestionid)

Delete a suggestion. A borrower can delete a suggestion only if he is its owner.

=cut

sub DelSuggestion {
    my ($borrowernumber,$suggestionid,$type) = @_;
    my $dbh = C4::Context->dbh;
    # check that the suggestion comes from the suggestor
    my $query = "
        SELECT suggestedby
        FROM   suggestions
        WHERE  suggestionid=?
    ";
    my $sth = $dbh->prepare($query);
    $sth->execute($suggestionid);
    my ($suggestedby) = $sth->fetchrow;
    if ($type eq "intranet" || $suggestedby eq $borrowernumber ) {
        my $queryDelete = "
            DELETE FROM suggestions
            WHERE suggestionid=?
        ";
        $sth = $dbh->prepare($queryDelete);
        my $suggestiondeleted=$sth->execute($suggestionid);
        return $suggestiondeleted;  
    }
}

1;
__END__


=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut

