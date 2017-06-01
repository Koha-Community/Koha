#!/usr/bin/perl

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

use CGI;

use C4::Auth;
use C4::Output;
use C4::Members;
use C4::Circulation qw( GetIssuingCharges );
use C4::Reserves;
use C4::Items;
use Koha::Holds;
use Koha::ItemTypes;
use Koha::Patrons;

my $input          = CGI->new;
my $borrowernumber = $input->param('borrowernumber');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "members/moremember-print.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { circulate => "circulate_remaining_permissions" },
        debug           => 1,
    }
);

my $logged_in_user = Koha::Patrons->find( $loggedinuser ) or die "Not logged in";
my $patron         = Koha::Patrons->find( $borrowernumber );
output_and_exit_if_error( $input, $cookie, $template, { module => 'members', logged_in_user => $logged_in_user, current_patron => $patron } );

my ( $total, $accts, $numaccts ) = GetMemberAccountRecords($borrowernumber);
foreach my $accountline (@$accts) {
    if (   $accountline->{accounttype} ne 'F'
        && $accountline->{accounttype} ne 'FU' )
    {
        $accountline->{printtitle} = 1;
    }
}

our $totalprice = 0;

my $holds_rs = Koha::Holds->search(
    { borrowernumber => $borrowernumber },
);

$template->param(
    patron => $patron,

    accounts => $accts,
    totaldue => $total,

    issues     => build_issue_data( $borrowernumber ),
    totalprice => $totalprice,

    reserves => build_reserve_data( $holds_rs ),
);

output_html_with_http_headers $input, $cookie, $template->output;

sub build_issue_data {
    my ( $borrowernumber ) = @_;
    my $issues = GetPendingIssues( $borrowernumber );

    my $return = [];

    my $today = DateTime->now( time_zone => C4::Context->tz );
    $today->truncate( to => 'day' );

    foreach my $issue ( @{$issues} ) {

        my %row = %{$issue};
        $totalprice += $issue->{replacementprice}
            if ( $issue->{replacementprice} );

        #find the charge for an item
        my ( $charge, $itemtype ) =
          GetIssuingCharges( $issue->{itemnumber}, $borrowernumber );

        $itemtype = Koha::ItemTypes->find( $itemtype );
        $row{'itemtype_description'} = $itemtype->description; #FIXME Should not it be translated_description

        $row{'charge'} = sprintf( "%.2f", $charge );

        $row{date_due} = $row{date_due_sql};

        push( @{$return}, \%row );
    }

    @{$return} = sort { $a->{date_due} eq $b->{date_due} } @{$return};

    return $return;

}

sub build_reserve_data {
    my $reserves = shift;

    my $return = [];

    my $today = DateTime->now( time_zone => C4::Context->tz );
    $today->truncate( to => 'day' );

    while ( my $reserve = $reserves->next() ) {

        my $row = {
            title          => $reserve->biblio()->title(),
            author         => $reserve->biblio()->author(),
            reservedate    => $reserve->reservedate(),
            expirationdate => $reserve->expirationdate(),
            waiting_at     => $reserve->branch()->branchname(),
        };

        push( @{$return}, $row );
    }

    @{$return} = sort { $a->{reservedate} <=> $b->{reservedate} } @{$return};

    return $return;
}
