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


=head1 view_holdsqueue

This script displays items in the tmp_holdsqueue table

=cut

use strict;
use warnings;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Biblio;
use C4::Items;
use C4::Koha;                  # GetItemTypes
use C4::Branch; # GetBranches
use C4::Dates qw/format_date/;

my $query = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "circ/view_holdsqueue.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { circulate => "circulate_remaining_permissions" },
        debug           => 1,
    }
);

my $params = $query->Vars;
my $run_report = $params->{'run_report'};
my $branchlimit = $params->{'branchlimit'};
my $itemtypeslimit = $params->{'itemtypeslimit'};

if ( $run_report ) {
    my $items = GetHoldsQueueItems( $branchlimit,$itemtypeslimit );
    $template->param(
					 branch    => $branchlimit,
                     total     => scalar @$items,
                     itemsloop => $items,
                     run_report => $run_report,
                     dateformat => C4::Context->preference("dateformat"),
                 );
}

# getting all branches.
my $branches = GetBranches;
my $branch   = C4::Context->userenv->{"branchname"};
my @branchloop;
foreach my $thisbranch (sort { $branches->{$a}->{branchname} cmp $branches->{$b}->{branchname} } keys %$branches ) {
    my $selected = 1 if $thisbranch eq $branch;
    my %row = (
        value      => $thisbranch,
        selected   => $selected,
        branchname => $branches->{$thisbranch}->{'branchname'},
    );
    push @branchloop, \%row;
}

# getting all itemtypes
my $itemtypes = &GetItemTypes();
my @itemtypesloop;
foreach my $thisitemtype ( sort keys %$itemtypes ) {
    my %row = (
        value       => $thisitemtype,
        description => $itemtypes->{$thisitemtype}->{'description'},
    );
    push @itemtypesloop, \%row;
}

$template->param( branchloop     => \@branchloop,
                  itemtypeloop   => \@itemtypesloop,
);

sub GetHoldsQueueItems {
	my ($branchlimit,$itemtypelimit) = @_;
	my $dbh = C4::Context->dbh;

    my @bind_params = ();
	my $query = q/SELECT tmp_holdsqueue.*, biblio.author, items.ccode, items.location, items.enumchron, items.cn_sort
                  FROM tmp_holdsqueue
                  JOIN biblio USING (biblionumber)
                  LEFT JOIN items USING (itemnumber)
                /;
    if ($branchlimit) {
	    $query .=" WHERE tmp_holdsqueue.holdingbranch = ?";
        push @bind_params, $branchlimit;
    }
    $query .= " ORDER BY ccode, location, cn_sort, author, title, pickbranch, reservedate";
	my $sth = $dbh->prepare($query);
	$sth->execute(@bind_params);
	my $items = [];
    while ( my $row = $sth->fetchrow_hashref ){
		$row->{reservedate} = format_date($row->{reservedate});
        push @$items, $row;
    }
    return $items;

}
# writing the template
output_html_with_http_headers $query, $cookie, $template->output;
