#!/usr/bin/perl

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
#
#   Written by Antoine Farnault antoine@koha-fr.org on Nov. 2006.


=head1 cleanborrowers.pl

This script allows to do 2 things.

=over 2

=item * Anonymise the borrowers' issues if issue is older than a given date. see C<datefilter1>.

=item * Delete the borrowers who has not borrowered since a given date. see C<datefilter2>.

=back

=cut

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Members;        # GetBorrowersWhoHavexxxBorrowed.
use C4::Circulation;    # AnonymiseIssueHistory.
use Date::Calc qw/Today Add_Delta_YM/;

my $cgi = new CGI;

# Fetch the paramater list as a hash in scalar context:
#  * returns paramater list as tied hash ref
#  * we can edit the values by changing the key
#  * multivalued CGI paramaters are returned as a packaged string separated by "\0" (null)
my $params = $cgi->Vars;

my $filterdate1;               # the date which filter on issue history.
my $filterdate2;               # the date which filter on borrowers last issue.

# getting the template
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "tools/cleanborrowers.tmpl",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => 'delete_anonymize_patrons', catalogue => 1 },
    }
);

if ( $params->{'step2'} ) {
    $filterdate1 = format_date_in_iso($params->{'filterdate1'});
    $filterdate2 = format_date_in_iso($params->{'filterdate2'});
    my %checkboxes = map { $_ => 1 } split /\0/, $params->{'checkbox'};

    my $totalDel;
    my $membersToDelete;
    if ($checkboxes{borrower}) {
        $membersToDelete = GetBorrowersWhoHaveNotBorrowedSince($filterdate1);
        $totalDel = scalar @$membersToDelete;
            
    }
    my $totalAno;
    my $membersToAnonymize;
    if ($checkboxes{issue}) {
        $membersToAnonymize =
          GetBorrowersWithIssuesHistoryOlderThan($filterdate2);
        $totalAno = scalar @$membersToAnonymize;
    }

    $template->param(
        step2            => 1,
        totalToDelete    => $totalDel,
        totalToAnonymize => $totalAno,
        memberstodelete_list => $membersToDelete,    
        memberstoanonymize_list => $membersToAnonymize,    
        filterdate1      => format_date($filterdate1),
        filterdate2      => format_date($filterdate2),
    );
### TODO : Use GetBorrowersNamesAndLatestIssue function in order to get the borrowers to delete or anonymize.
### Now, we are only using total, which is not enough imlo
    #writing the template
    output_html_with_http_headers $cgi, $cookie, $template->output;
    exit;
}

if ( $params->{'step3'} ) {
    $filterdate1 = format_date_in_iso($params->{'filterdate1'});
    $filterdate2 = format_date_in_iso($params->{'filterdate2'});
    my $do_delete = $params->{'do_delete'};
    my $do_anonym = $params->{'do_anonym'};

    my ( $totalDel, $totalAno, $radio ) = ( 0, 0, 0 );
    
    # delete members
    if ($do_delete) {
        my $membersToDelete = GetBorrowersWhoHaveNotBorrowedSince($filterdate1);
        $totalDel = scalar(@$membersToDelete);
        $radio    = $params->{'radio'};
        if ( $radio eq 'trash' ) {
            my $i;
            for ( $i = 0 ; $i < $totalDel ; $i++ ) {
                MoveMemberToDeleted( $membersToDelete->[$i]->{'borrowernumber'} );
                DelMember( $membersToDelete->[$i]->{'borrowernumber'} );
            }
        }
        else {    # delete completly.
            my $i;
            for ( $i = 0 ; $i < $totalDel ; $i++ ) {
               DelMember($membersToDelete->[$i]->{'borrowernumber'});
            }
        }
        $template->param(
            do_delete => '1',
            TotalDel  => $totalDel
        );
    }
    
    # Anonymising all members
    if ($do_anonym) {
        $totalAno = AnonymiseIssueHistory($filterdate2);
        $template->param(
            filterdate1 => $filterdate2,
            do_anonym   => '1',
        );
    }
    
    $template->param(
        step3 => '1',
        trash => ( $radio eq "trash" ) ? (1) : (0),
    );

    #writing the template
    output_html_with_http_headers $cgi, $cookie, $template->output;
    exit;
}

#default value set to the template are the 'CNIL' value.
my ( $year, $month, $day ) = &Today();
$filterdate1 = format_date(sprintf("%-04.4d-%-02.2d-%02.2d", Add_Delta_YM($year, $month, $day, -1, 0)));
$filterdate2 = format_date(sprintf("%-04.4d-%-02.2d-%02.2d", Add_Delta_YM($year, $month, $day, 0, -3)));

$template->param(
    step1       => '1',
    filterdate1 => $filterdate1,
    filterdate2 => $filterdate2,
    DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(),
);

#writing the template
output_html_with_http_headers $cgi, $cookie, $template->output;
