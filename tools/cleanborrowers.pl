#!/usr/bin/perl

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
#
#   Written by Antoine Farnault antoine@koha-fr.org on Nov. 2006.

=head1 cleanborrowers.pl

This script allows to do 2 things.

=over 2

=item * Anonymise the borrowers' issues if issue is older than a given date. see C<datefilter1>.

=item * Delete the borrowers who has not borrowed since a given date. see C<datefilter2>.

=back

=cut

use Modern::Perl;

use CGI qw ( -utf8 );
use C4::Auth;
use C4::Output;
use C4::Members;        # GetBorrowersWhoHavexxxBorrowed.
use C4::Circulation;    # AnonymiseIssueHistory.
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Patron::Categories;
use Date::Calc qw/Today Add_Delta_YM/;
use Koha::List::Patron;

my $cgi = new CGI;

# Fetch the paramater list as a hash in scalar context:
#  * returns paramater list as tied hash ref
#  * we can edit the values by changing the key
#  * multivalued CGI paramaters are returned as a packaged string separated by "\0" (null)
my $params = $cgi->Vars;

my $step = $params->{step} || 1;
my $not_borrowed_since =    # the date which filter on issue history.
  $params->{not_borrowed_since}
  ? dt_from_string $params->{not_borrowed_since}
  : undef;
my $last_issue_date =         # the date which filter on borrowers last issue.
  $params->{last_issue_date}
  ? dt_from_string $params->{last_issue_date}
  : undef;
my $borrower_dateexpiry =
  $params->{borrower_dateexpiry}
  ? dt_from_string $params->{borrower_dateexpiry}
  : undef;
my $patron_list_id = $params->{patron_list_id};

my $borrower_categorycode = $params->{'borrower_categorycode'} || q{};

# getting the template
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "tools/cleanborrowers.tt",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => 'delete_anonymize_patrons', catalogue => 1 },
    }
);

my $branch = $params->{ branch } || '*';
$template->param( current_branch => $branch );
$template->param( OnlyMine => C4::Context->only_my_library );

if ( $step == 2 ) {

    my %checkboxes = map { $_ => 1 } split /\0/, $params->{'checkbox'};

    my $patrons_to_delete;
    if ( $checkboxes{borrower} ) {
        $patrons_to_delete = GetBorrowersToExpunge(
             _get_selection_params(
                  $not_borrowed_since,
                  $borrower_dateexpiry,
                  $borrower_categorycode,
                  $patron_list_id,
                  $branch
             )
        );
    }
    _skip_borrowers_with_nonzero_balance($patrons_to_delete);

    my $members_to_anonymize;
    if ( $checkboxes{issue} ) {
        if ( $branch eq '*' ) {
            $members_to_anonymize = GetBorrowersWithIssuesHistoryOlderThan($last_issue_date);
        } else {
            $members_to_anonymize = GetBorrowersWithIssuesHistoryOlderThan($last_issue_date, $branch);
        }
    }

    $template->param(
        patrons_to_delete    => $patrons_to_delete,
        patrons_to_anonymize => $members_to_anonymize,
        patron_list_id       => $patron_list_id
    );
}

elsif ( $step == 3 ) {
    my $do_delete = $params->{'do_delete'};
    my $do_anonym = $params->{'do_anonym'};

    my ( $totalDel, $totalAno, $radio ) = ( 0, 0, 0 );

    # delete members
    if ($do_delete) {
        my $patrons_to_delete = GetBorrowersToExpunge(
                _get_selection_params(
                    $not_borrowed_since,
                    $borrower_dateexpiry,
                    $borrower_categorycode,
                    $patron_list_id,
                    $branch
                )
            );
        _skip_borrowers_with_nonzero_balance($patrons_to_delete);

        $totalDel = scalar(@$patrons_to_delete);
        $radio    = $params->{'radio'};
        for ( my $i = 0 ; $i < $totalDel ; $i++ ) {
            $radio eq 'testrun' && last;
            my $borrowernumber = $patrons_to_delete->[$i]->{'borrowernumber'};
            $radio eq 'trash' && MoveMemberToDeleted($borrowernumber);
            C4::Members::HandleDelBorrower($borrowernumber);
            DelMember($borrowernumber);
        }
        $template->param(
            do_delete => '1',
            TotalDel  => $totalDel
        );
    }

    # Anonymising all members
    if ($do_anonym) {
        #FIXME: anonymisation errors are not handled
        ($totalAno,my $anonymisation_error) = AnonymiseIssueHistory($last_issue_date);
        $template->param(
            do_anonym   => '1',
        );
    }

    $template->param(
        trash => ( $radio eq "trash" ) ? (1) : (0),
        testrun => ( $radio eq "testrun" ) ? 1: 0,
    );
} else { # $step == 1
    my @all_lists = GetPatronLists();
    my @non_empty_lists;
    foreach my $list (@all_lists){
    my @patrons = $list->patron_list_patrons();
        if( scalar @patrons ) { push(@non_empty_lists,$list) }
    }
    $template->param( patron_lists => [ @non_empty_lists ] );
}

my $patron_categories = Koha::Patron::Categories->search_limited({}, {order_by => ['description']});

$template->param(
    step                   => $step,
    not_borrowed_since   => $not_borrowed_since,
    borrower_dateexpiry    => $borrower_dateexpiry,
    last_issue_date        => $last_issue_date,
    borrower_categorycodes => $patron_categories,
    borrower_categorycode  => $borrower_categorycode,
);

#writing the template
output_html_with_http_headers $cgi, $cookie, $template->output;

sub _skip_borrowers_with_nonzero_balance {
    my $borrowers = shift;
    my $balance;
    @$borrowers = map {
        (undef, undef, $balance) = GetMemberIssuesAndFines( $_->{borrowernumber} );
        (defined $balance && $balance != 0) ? (): ($_);
    } @$borrowers;
}

sub _get_selection_params {
    my ($not_borrowed_since, $borrower_dateexpiry,
        $borrower_categorycode, $patron_list_id, $branch) = @_;

    my $params = {};
    $params->{not_borrowed_since} = output_pref({
        dt         => $not_borrowed_since,
        dateformat => 'iso',
        dateonly   => 1
    }) if $not_borrowed_since;
    $params->{expired_before} = output_pref({
        dt         => $borrower_dateexpiry,
        dateformat => 'iso',
        dateonly   => 1
    }) if $borrower_dateexpiry;
    $params->{category_code} = $borrower_categorycode if $borrower_categorycode;
    $params->{patron_list_id} = $patron_list_id if $patron_list_id;

    if ( defined $branch and $branch ne '*' ) {
        $params->{ branchcode } = $branch;
    }

    return $params;
};
