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
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use C4::Members qw( GetBorrowersToExpunge );
use Koha::Old::Checkouts;
use Koha::Patron::Categories;
use Koha::Patrons;
use Koha::List::Patron qw( GetPatronLists );

my $cgi = CGI->new;

# Fetch the parameter list as a hash in scalar context:
#  * returns parameter list as tied hash ref
#  * we can edit the values by changing the key
#  * multivalued CGI parameters are returned as a packaged string separated by "\0" (null)
my $params = $cgi->Vars;

my $step = $params->{step} || 1;
my $not_borrowed_since =    # the date which filter on issue history.
  $params->{not_borrowed_since};
my $last_issue_date =         # the date which filter on borrowers last issue.
  $params->{last_issue_date};
my $patron_list_id = $params->{patron_list_id};
my $borrower_dateexpiry = $params->{borrower_dateexpiry};
my $borrower_lastseen = $params->{borrower_lastseen};

my $borrower_categorycode = $params->{'borrower_categorycode'} || q{};

# getting the template
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "tools/cleanborrowers.tt",
        query           => $cgi,
        type            => "intranet",
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
                  $borrower_lastseen,
                  $borrower_categorycode,
                  $patron_list_id,
                  $branch
             )
        );
    }
    _skip_borrowers_with_nonzero_balance($patrons_to_delete);

    my $patrons_to_anonymize =
        $checkboxes{issue}
      ? $branch eq '*'
          ? Koha::Patrons->search_patrons_to_anonymise( { before => $last_issue_date } )
          : Koha::Patrons->search_patrons_to_anonymise( { before => $last_issue_date, library => $branch } )
      : undef;

    $template->param(
        patrons_to_delete    => $patrons_to_delete,
        patrons_to_anonymize => $patrons_to_anonymize,
        patron_list_id       => $patron_list_id,
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
                    $borrower_lastseen,
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
            my $patron = Koha::Patrons->find($borrowernumber);
            $radio eq 'trash' && $patron->move_to_deleted;
            $patron->delete;
        }
        $template->param(
            do_delete => '1',
            TotalDel  => $totalDel
        );
    }

    # Anonymising all members
    if ($do_anonym) {
        #FIXME: anonymisation errors are not handled
        my $rows = Koha::Old::Checkouts
                     ->filter_by_anonymizable
                     ->filter_by_last_update({
                         to => $last_issue_date, timestamp_column_name => 'returndate' })
                     ->anonymize;

        $template->param(
            do_anonym   => $rows,
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

my $patron_categories = Koha::Patron::Categories->search_with_library_limits({}, {order_by => ['description']});

$template->param(
    step                   => $step,
    not_borrowed_since   => $not_borrowed_since,
    borrower_dateexpiry    => $borrower_dateexpiry,
    borrower_lastseen      => $borrower_lastseen,
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
        my $patron = Koha::Patrons->find( $_->{borrowernumber} );
        my $balance = $patron->account->balance;
        (defined $balance && $balance != 0) ? (): ($_);
    } @$borrowers;
}

sub _get_selection_params {
    my ($not_borrowed_since, $borrower_dateexpiry, $borrower_lastseen,
        $borrower_categorycode, $patron_list_id, $branch) = @_;

    my $params = {};
    $params->{not_borrowed_since} = $not_borrowed_since;
    $params->{expired_before} = $borrower_dateexpiry;
    $params->{last_seen} = $borrower_lastseen;
    $params->{category_code} = $borrower_categorycode if $borrower_categorycode;
    $params->{patron_list_id} = $patron_list_id if $patron_list_id;

    if ( defined $branch and $branch ne '*' ) {
        $params->{ branchcode } = $branch;
    }

    return $params;
};
