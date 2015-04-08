#!/usr/bin/perl

# Copyright 2008-2009 LibLime
#
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

use strict;
use warnings;
use CGI; 
use MARC::Record;
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Biblio;
use C4::Items;
use C4::Members; # to use GetMember
use C4::Search;		# enabled_staff_search_views
use C4::Acquisition qw(GetOrdersByBiblionumber);
use C4::Koha qw( GetFrameworksLoop );

my $query        = new CGI;
my $dbh          = C4::Context->dbh;
my $biblionumber = $query->param('biblionumber');
my $frameworkcode = $query->param('frameworkcode');
$frameworkcode = GetFrameworkCode( $biblionumber ) unless ($frameworkcode);
my $popup        =
  $query->param('popup')
  ;    # if set to 1, then don't insert links, it's just to show the biblio

# open template
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "catalogue/labeledMARCdetail.tt",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
    }
);

my $record = GetMarcBiblio($biblionumber);
if ( not defined $record ) {
    # biblionumber invalid -> report and exit
    $template->param( unknownbiblionumber => 1,
                biblionumber => $biblionumber
    );
    output_html_with_http_headers $query, $cookie, $template->output;
    exit;
}

my $tagslib = GetMarcStructure(1,$frameworkcode);
my $biblio = GetBiblioData($biblionumber);

if($query->cookie("holdfor")){ 
    my $holdfor_patron = GetMember('borrowernumber' => $query->cookie("holdfor"));
    $template->param(
        holdfor => $query->cookie("holdfor"),
        holdfor_surname => $holdfor_patron->{'surname'},
        holdfor_firstname => $holdfor_patron->{'firstname'},
        holdfor_cardnumber => $holdfor_patron->{'cardnumber'},
    );
}

#count of item linked
my $itemcount = GetItemsCount($biblionumber);
$template->param( count => $itemcount,
					bibliotitle => $biblio->{title}, );

#Getting framework loop
$template->param(frameworkloop => GetFrameworksLoop( $frameworkcode ) );

my @marc_data;
my $prevlabel = '';
for my $field ($record->fields)
{
	my $tag = $field->tag;
	next if ! exists $tagslib->{$tag}->{lib};
	my $label = $tagslib->{$tag}->{lib};
	if ($label eq $prevlabel)
	{
		$label = '';
	}
	else
	{
		$prevlabel = $label;
	}
	my $value = $tag < 10
		? $field->data
		: join ' ', map { $_->[1] } $field->subfields;
	push @marc_data, {
		label => $label,
		value => $value,
	};
}

$template->param (
	marc_data				=> \@marc_data,
    biblionumber            => $biblionumber,
    popup                   => $popup,
	labeledmarcview => 1,
	z3950_search_params		=> C4::Search::z3950_search_args($biblio),
	C4::Search::enabled_staff_search_views,
    searchid            => $query->param('searchid'),
);

my @allorders_using_biblio = GetOrdersByBiblionumber ($biblionumber);
my @deletedorders_using_biblio;
my @orders_using_biblio;
my @baskets_orders;
my @baskets_deletedorders;

foreach my $myorder (@allorders_using_biblio) {
    my $basket = $myorder->{'basketno'};
    if ((defined $myorder->{'datecancellationprinted'}) and  ($myorder->{'datecancellationprinted'} ne '0000-00-00') ){
        push @deletedorders_using_biblio, $myorder;
        unless (grep(/^$basket$/, @baskets_deletedorders)){
            push @baskets_deletedorders,$myorder->{'basketno'};
        }
    }
    else {
        push @orders_using_biblio, $myorder;
        unless (grep(/^$basket$/, @baskets_orders)){
            push @baskets_orders,$myorder->{'basketno'};
            }
    }
}

my $count_orders_using_biblio = scalar @orders_using_biblio ;
$template->param (countorders => $count_orders_using_biblio);

my $count_deletedorders_using_biblio = scalar @deletedorders_using_biblio ;
$template->param (countdeletedorders => $count_deletedorders_using_biblio);

my $holds= C4::Reserves::GetReservesFromBiblionumber({ biblionumber => $biblionumber, all_dates => 1 });
my $holdcount = scalar( @$holds );
$template->param( holdcount => scalar ( @$holds ) );

output_html_with_http_headers $query, $cookie, $template->output;
