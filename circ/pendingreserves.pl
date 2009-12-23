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

# Modification by D.Ulm, actually works (as long as indep. branches not turned on)
#		Someone let me know what indep. branches is supposed to do and I'll make that part work too
#
# 		The reserve pull lists *works* as long as not for indepencdant branches, I can fix!

use strict;
use C4::Context;
use C4::Output;
use CGI;
use C4::Auth;
use C4::Branch qw/GetBranches/;
use C4::Koha qw/GetItemTypes GetKohaAuthorisedValues/;
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Debug;
use C4::Reserves qw/GetPendingReserves/;
use Date::Calc qw/Today Add_Delta_YMD/;
use JSON;

my $input       = new CGI;
my $order       = $input->param('order');
my $startdate   = $input->param('from');
my $enddate     = $input->param('to');


my $template_name = $input->param('json') ? "cataloguing/value_builder/ajax.tmpl" : "circ/pendingreserves.tmpl";

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => $template_name,
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { circulate => "circulate_remaining_permissions" },
        debug           => 1,
    }
);

if($input->param('json')){

    my $startindex = $input->param('startIndex');
    my $results    = $input->param('results');
    my $filters    = {
        holdingbranches => $input->param('holdingbranches') || "",
        locations      => $input->param('locations') || "",
        itemtypes      => $input->param('itemtypes') || "",
    };
    my ($count, $reservedata) = C4::Reserves::GetPendingReserves($filters, $startindex, $results);

    my $jsondatas = {
        recordsReturned => scalar @$reservedata,
        totalRecords    => $count,
        startIndex      => "0",
        sort            => "callnumbers",
        dir             => "asc",
        pageSize        => "40",
        records         => $reservedata,
    };
    
    
    $template->param(return => to_json($jsondatas));
}else{
    my (@itemtypesloop,@locationloop, @branch_loop);
    my $itemtypes = GetItemTypes;
    foreach my $thisitemtype (sort keys %$itemtypes) {
        push @itemtypesloop, {
             value       => $thisitemtype,
             description => $itemtypes->{$thisitemtype}->{'description'},
         };
    }
    my $locs = GetKohaAuthorisedValues( 'items.location' );
    foreach my $thisloc (sort keys %$locs) {
        push @locationloop, {
            value       => $thisloc,
            description => $locs->{$thisloc},
        };
     }
     my $branches = GetBranches();
     foreach my $branchcode (sort keys %{$branches}) {
        push @branch_loop, {
            value       => $branchcode,
            description => $branches->{$branchcode}->{branchname},
        };
     }
     
    $template->param(
        branches_loop  => \@branch_loop,
        itemtypes_loop => \@itemtypesloop,
        locations_loop => \@locationloop,
        "BiblioDefaultView".C4::Context->preference("BiblioDefaultView") => 1,
        DHTMLcalendar_dateformat =>  C4::Dates->DHTMLcalendar(),
    	dateformat    => C4::Context->preference("dateformat"),
    );
}
output_html_with_http_headers $input, $cookie, $template->output;
