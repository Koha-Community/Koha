#!/usr/bin/perl


# Copyright 2000-2002 Katipo Communications
# Parts Copyright Catalyst IT 2011
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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings;

use CGI;
use C4::Auth;
use C4::Context;
use C4::Search;
use C4::Output;
use C4::Koha;
use C4::Branch;
use Date::Manip;

=head1 NAME

plugin that shows a stats on borrowers

=head1 DESCRIPTION

=cut

my $input = new CGI;
my $branches = GetBranches();
my $itemtypes = GetItemTypes();

my ($template, $borrowernumber, $cookie)
	= get_template_and_user({template_name => 'opac-topissues.tmpl',
				query => $input,
				type => "opac",
               authnotrequired => ( C4::Context->preference("OpacPublic") ? 1 : 0 ),
				debug => 1,
				});
my $dbh = C4::Context->dbh;
# Displaying results
my $limit = $input->param('limit') || 10;
my $branch = $input->param('branch') || '';
my $itemtype = $input->param('itemtype') || '';
my $timeLimit = $input->param('timeLimit') || 3;
my $advanced_search_types = C4::Context->preference('AdvancedSearchTypes');

my $whereclause = '';
$whereclause .= ' AND items.homebranch='.$dbh->quote($branch) if ($branch);
$whereclause .= ' AND TO_DAYS(NOW()) - TO_DAYS(biblio.datecreated) <= '.($timeLimit*30) if $timeLimit < 999;
$whereclause =~ s/ AND $// if $whereclause;
my $query;

if($advanced_search_types eq 'ccode'){
    $whereclause .= ' AND authorised_values.authorised_value='.$dbh->quote($itemtype) if $itemtype;
    $query = "SELECT datecreated, biblio.biblionumber, title,
                    author, sum( items.issues ) AS tot, biblioitems.itemtype,
                    biblioitems.publishercode,biblioitems.publicationyear,
                    authorised_values.lib as description
                    FROM biblio
                    LEFT JOIN items USING (biblionumber)
                    LEFT JOIN biblioitems USING (biblionumber)
                    LEFT JOIN authorised_values ON items.ccode = authorised_values.authorised_value
                    WHERE 1
                    $whereclause
                    AND authorised_values.category = 'ccode' 
                    GROUP BY biblio.biblionumber
                    HAVING tot >0
                    ORDER BY tot DESC
                    LIMIT $limit
                    ";
    $template->param(ccodesearch => 1);
}else{
    if ($itemtype){
	if (C4::Context->preference('item-level_itypes')){
	    $whereclause .= ' AND items.itype = ' . $dbh->quote($itemtype);
	}
	else {
	    $whereclause .= ' AND biblioitems.itemtype='.$dbh->quote($itemtype);
        }
    }
    $query = "SELECT datecreated, biblio.biblionumber, title,
                    author, sum( items.issues ) AS tot, biblioitems.itemtype,
                    biblioitems.publishercode,biblioitems.publicationyear,
                    itemtypes.description
                    FROM biblio
                    LEFT JOIN items USING (biblionumber)
                    LEFT JOIN biblioitems USING (biblionumber)
                    LEFT JOIN itemtypes ON itemtypes.itemtype = biblioitems.itemtype
                    WHERE 1
                    $whereclause
                    GROUP BY biblio.biblionumber
                    HAVING tot >0
                    ORDER BY tot DESC
                    LIMIT $limit
                    ";
     $template->param(itemtypesearch => 1);
}

my $sth = $dbh->prepare($query);
$sth->execute();
my @results;
while (my $line= $sth->fetchrow_hashref) {
    push @results, $line;
}

my $timeLimitFinite = $timeLimit;
if($timeLimit eq 999){ $timeLimitFinite = 0 };

$template->param(do_it => 1,
                limit => $limit,
                branch => $branches->{$branch}->{branchname},
                itemtype => $itemtypes->{$itemtype}->{description},
                timeLimit => $timeLimit,
                timeLimitFinite => $timeLimit,
                results_loop => \@results,
                );

$template->param( branchloop => GetBranchesLoop(C4::Context->userenv?C4::Context->userenv->{'branch'}:''));

# the index parameter is different for item-level itemtypes
my $itype_or_itemtype = (C4::Context->preference("item-level_itypes"))?'itype':'itemtype';
$itemtypes = GetItemTypes;
my @itemtypesloop;
if (!$advanced_search_types or $advanced_search_types eq 'itemtypes') {
        foreach my $thisitemtype ( sort {$itemtypes->{$a}->{'description'} cmp $itemtypes->{$b}->{'description'} } keys %$itemtypes ) {
        my %row =( value => $thisitemtype,
                   description => $itemtypes->{$thisitemtype}->{'description'},
                   selected    => $thisitemtype eq $itemtype,
            );
        push @itemtypesloop, \%row;
        }
} else {
    my $advsearchtypes = GetAuthorisedValues($advanced_search_types, '', 'opac');
        for my $thisitemtype (@$advsearchtypes) {
                my $selected;
            $selected = 1 if $thisitemtype->{authorised_value} eq $itemtype;
                my %row =( value => $thisitemtype->{authorised_value},
                selected    => $thisitemtype eq $itemtype,
                description => $thisitemtype->{'lib'},
            );
                push @itemtypesloop, \%row;
        }
}

$template->param(
                 itemtypeloop =>\@itemtypesloop,
                );
output_html_with_http_headers $input, $cookie, $template->output;

