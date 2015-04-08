#!/usr/bin/perl

# Copyright 2012 Prosentient Systems
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
#use warnings; FIXME - Bug 2505
use CGI;
use C4::Output;
use C4::Auth qw/:DEFAULT get_session/;
use C4::Branch; # GetBranches
use C4::Members;
use C4::Members::Attributes qw(GetBorrowerAttributes);
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
my $roadtype = C4::Koha::GetAuthorisedValueByCode( 'ROADTYPE', $borrower->{streettype} );
my $address = $borrower->{'streetnumber'} . " $roadtype " . $borrower->{'address'};

$template->param(

    findborrower      => $findborrower,
    borrower          => $borrower,
    borrowernumber    => $borrowernumber,
    branch            => $branch,
    branchname        => GetBranchName($borrower->{'branchcode'}),
    title             => $borrower->{'title'},
    initials          => $borrower->{'initials'},
    firstname         => $borrower->{'firstname'},
    surname           => $borrower->{'surname'},
    othernames        => $borrower->{'othernames'},
    categorycode      => $borrower->{'categorycode'},
    categoryname      => $borrower->{description},
    address           => $address,
    address2          => $borrower->{'address2'},
    phone             => $borrower->{'phone'},
    phonepro          => $borrower->{'phonepro'},
    mobile            => $borrower->{'mobile'},
    email             => $borrower->{'email'},
    emailpro          => $borrower->{'emailpro'},
    borrowernotes     => $borrower->{'borrowernotes'},
    city              => $borrower->{'city'},
    state             => $borrower->{'state'},
    zipcode           => $borrower->{'zipcode'},
    country           => $borrower->{'country'},
    cardnumber        => $borrower->{'cardnumber'},
    RoutingSerials => C4::Context->preference('RoutingSerials'),
);

if (C4::Context->preference('ExtendedPatronAttributes')) {
    my $attributes = GetBorrowerAttributes($borrowernumber);
    $template->param(
        ExtendedPatronAttributes => 1,
        extendedattributes => $attributes
    );
}

my ($picture, $dberror) = GetPatronImage($borrower->{'borrowernumber'});
$template->param( picture => 1 ) if $picture;

output_html_with_http_headers $query, $cookie, $template->output;
