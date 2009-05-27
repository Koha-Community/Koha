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

=head1 NAME

ISBDdetail.pl : script to show a biblio in ISBD format

=head1 SYNOPSIS


=head1 DESCRIPTION

This script needs a biblionumber as parameter 

=head1 FUNCTIONS

=over 2

=cut

use strict;

use C4::Auth;
use C4::Context;
use C4::Output;
use CGI;
use C4::Koha;
use C4::Biblio;
use C4::Items;
use C4::Branch;     # GetBranchDetail
use C4::Serials;    # CountSubscriptionFromBiblionumber
use C4::Search;		# enabled_staff_search_views

#---- Internal function


my $query = new CGI;
my $dbh = C4::Context->dbh;

my $biblionumber = $query->param('biblionumber');

# open template
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "catalogue/ISBDdetail.tmpl",
        query         => $query,
        type          => "intranet",
	authnotrequired => 0,
	flagsrequired   => { catalogue => 1 },
    }
);

# my @blocs = split /\@/,$ISBD;
# my @fields = $record->fields();
my $res = GetISBDView($biblionumber);

# count of item linked with biblio
my $itemcount = GetItemsCount($biblionumber);
$template->param( count => $itemcount);
my $subscriptionsnumber = CountSubscriptionFromBiblionumber($biblionumber);
 
if ($subscriptionsnumber) {
    my $subscriptions     = GetSubscriptionsFromBiblionumber($biblionumber);
    my $subscriptiontitle = $subscriptions->[0]{'bibliotitle'};
    $template->param(
        subscriptionsnumber => $subscriptionsnumber,
        subscriptiontitle   => $subscriptiontitle,
    );
}

$template->param (
    ISBD                => $res,
    biblionumber        => $biblionumber,
	isbdview => 1,
	z3950_search_params	=> C4::Search::z3950_search_args(GetBiblioData($biblionumber)),
	C4::Search::enabled_staff_search_views,
);

output_html_with_http_headers $query, $cookie, $template->output;

