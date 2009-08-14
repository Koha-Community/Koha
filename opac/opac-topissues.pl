#!/usr/bin/perl


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

=over 2

=cut

my $input = new CGI;
my $branches = GetBranches();
my $itemtypes = GetItemTypes();

my ($template, $borrowernumber, $cookie)
	= get_template_and_user({template_name => 'opac-topissues.tmpl',
				query => $input,
				type => "opac",
				authnotrequired => 1,
				debug => 1,
				});
my $dbh = C4::Context->dbh;
# Displaying results
my $limit = $input->param('limit') || 10;
my $branch = $input->param('branch') || '';
my $itemtype = $input->param('itemtype') || '';
my $timeLimit = $input->param('timeLimit') || 3;
my $whereclause = '';
$whereclause .= 'items.homebranch='.$dbh->quote($branch)." AND " if ($branch);
$whereclause .= 'biblioitems.itemtype='.$dbh->quote($itemtype)." AND " if $itemtype;
$whereclause .= ' TO_DAYS(NOW()) - TO_DAYS(biblio.datecreated) <= '.($timeLimit*30).' AND ' if $timeLimit < 999;
$whereclause =~ s/ AND $// if $whereclause;
$whereclause = " WHERE ".$whereclause if $whereclause;

my $query = "SELECT datecreated, biblio.biblionumber, title, 
                author, sum( items.issues ) AS tot, biblioitems.itemtype,
                biblioitems.publishercode,biblioitems.publicationyear,
                itemtypes.description
                FROM biblio
                LEFT JOIN items USING (biblionumber)
                LEFT JOIN biblioitems USING (biblionumber)
                LEFT JOIN itemtypes ON itemtypes.itemtype = biblioitems.itemtype
                $whereclause
                GROUP BY biblio.biblionumber
                HAVING tot >0
                ORDER BY tot DESC
                LIMIT $limit
                ";

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
                branch => $branches->{$branch}->{branchname} || 'all locations',
                itemtype => $itemtypes->{$itemtype}->{description} || 'item types',
                timeLimit => $timeLimit,
                results_loop => \@results,
                );

$template->param( branchloop => GetBranchesLoop(C4::Context->userenv->{'branch'}));

#doctype
$itemtypes = GetItemTypes;
my @itemtypeloop;
foreach my $thisitemtype (sort {$itemtypes->{$a}->{'description'} cmp $itemtypes->{$b}->{'description'}} keys %$itemtypes) {
        my $selected = 1 if $thisitemtype eq $itemtype;
        my %row =(value => $thisitemtype,
                    description => $itemtypes->{$thisitemtype}->{'description'},
                    selected => $selected,
                 );
        push @itemtypeloop, \%row;
}

$template->param(
                 itemtypeloop =>\@itemtypeloop,
                 dateformat    => C4::Context->preference("dateformat"),
                );
output_html_with_http_headers $input, $cookie, $template->output;

