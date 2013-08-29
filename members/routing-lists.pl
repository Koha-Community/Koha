#!/usr/bin/perl

# Copyright 2012 Prosentient Systems
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
#use warnings; FIXME - Bug 2505
use CGI;
use C4::Output;
use C4::Auth qw/:DEFAULT get_session/;
use C4::Branch; # GetBranches
use C4::Members;
use C4::Context;
use C4::Serials;
use CGI::Session;

my $query = new CGI;

my $sessionID = $query->cookie("CGISESSID") ;
my $session = get_session($sessionID);

# branch are now defined by the userenv
# but first we have to check if someone has tried to change them

my $branch = $query->param('branch');
if ($branch){
    # update our session so the userenv is updated
    $session->param('branch', $branch);
    $session->param('branchname', GetBranchName($branch));
}

my ( $template, $loggedinuser, $cookie ) = get_template_and_user (
    {
        template_name   => 'members/routing-lists.tt',
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { circulate => 'circulate_remaining_permissions' },
    }
);

my $branches = GetBranches();

my $findborrower = $query->param('findborrower');
$findborrower =~ s|,| |g;

my $borrowernumber = $query->param('borrowernumber');

$branch  = C4::Context->userenv->{'branch'};

# get the borrower information.....
my $borrower;
if ($borrowernumber) {
    $borrower = GetMemberDetails( $borrowernumber, 0 );
}


##################################################################################
# BUILD HTML
# I'm trying to show the title of subscriptions where the borrowernumber is attached via a routing list

if ($borrowernumber) {
# new op dev
  my $count;
  my @borrowerSubscriptions;
  ($count, @borrowerSubscriptions) = GetSubscriptionsFromBorrower($borrowernumber );
  my @subscripLoop;

    foreach my $num_res (@borrowerSubscriptions) {
        my %getSubscrip;
        $getSubscrip{subscriptionid}	= $num_res->{'subscriptionid'};
        $getSubscrip{title}			= $num_res->{'title'};
        $getSubscrip{borrowernumber}		= $num_res->{'borrowernumber'};
        push( @subscripLoop, \%getSubscrip );
    }

    $template->param(
        countSubscrip => scalar @subscripLoop,
        subscripLoop  => \@subscripLoop,
        routinglistview => 1
    );

    $template->param( adultborrower => 1 ) if ( $borrower->{'category_type'} eq 'A' );
}

##################################################################################


# Computes full borrower address
my (undef, $roadttype_hashref) = &GetRoadTypes();
my $address = $borrower->{'streetnumber'}.' '.$roadttype_hashref->{$borrower->{'streettype'}}.' '.$borrower->{'address'};

$template->param(

    findborrower      => $findborrower,
    borrower          => $borrower,
    borrowernumber    => $borrowernumber,
    branch            => $branch,
    branchname        => GetBranchName($borrower->{'branchcode'}),
    firstname         => $borrower->{'firstname'},
    surname           => $borrower->{'surname'},
    categorycode      => $borrower->{'categorycode'},
    categoryname      => $borrower->{description},
    address           => $address,
    address2          => $borrower->{'address2'},
    email             => $borrower->{'email'},
    emailpro          => $borrower->{'emailpro'},
    borrowernotes     => $borrower->{'borrowernotes'},
    city              => $borrower->{'city'},
    zipcode           => $borrower->{'zipcode'},
    country           => $borrower->{'country'},
    phone             => $borrower->{'phone'} || $borrower->{'mobile'},
    cardnumber        => $borrower->{'cardnumber'},
    RoutingSerials => C4::Context->preference('RoutingSerials'),
);

my ($picture, $dberror) = GetPatronImage($borrower->{'borrowernumber'});
$template->param( picture => 1 ) if $picture;

output_html_with_http_headers $query, $cookie, $template->output;
