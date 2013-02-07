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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

=head1 NAME

ISBDdetail.pl : script to show a biblio in ISBD format

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

This script needs a biblionumber as parameter 

=head1 FUNCTIONS

=cut

use strict;
#use warnings; FIXME - Bug 2505

use C4::Auth;
use C4::Context;
use C4::Output;
use CGI;
use C4::Koha;
use C4::Biblio;
use C4::Items;
use C4::Members; # to use GetMember
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

my $res = GetISBDView($biblionumber, "intranet");
if ( not defined $res ) {
       # biblionumber invalid -> report and exit
       $template->param( unknownbiblionumber => 1,
                               biblionumber => $biblionumber
       );
       output_html_with_http_headers $query, $cookie, $template->output;
       exit;
}

if($query->cookie("holdfor")){ 
    my $holdfor_patron = GetMember('borrowernumber' => $query->cookie("holdfor"));
    $template->param(
        holdfor => $query->cookie("holdfor"),
        holdfor_surname => $holdfor_patron->{'surname'},
        holdfor_firstname => $holdfor_patron->{'firstname'},
        holdfor_cardnumber => $holdfor_patron->{'cardnumber'},
    );
}

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
my $record = GetMarcBiblio($biblionumber);

$template->param (
    ISBD                => $res,
    biblionumber        => $biblionumber,
    isbdview            => 1,
    z3950_search_params => C4::Search::z3950_search_args(GetBiblioData($biblionumber)),
    ocoins => GetCOinSBiblio($record),
    C4::Search::enabled_staff_search_views,
);


my ( $holdcount, $holds ) = C4::Reserves::GetReservesFromBiblionumber($biblionumber,1);
$template->param( holdcount => $holdcount, holds => $holds );

output_html_with_http_headers $query, $cookie, $template->output;

