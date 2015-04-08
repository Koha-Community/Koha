#!/usr/bin/perl

# Copyright 2012 Koha Team
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


=head1 NAME

serials-search.pl

=head1 DESCRIPTION

this script is the search page for serials

=cut

use Modern::Perl;
use CGI;
use C4::Auth;
use C4::Branch;
use C4::Context;
use C4::Output;
use C4::Serials;

use Koha::DateUtils;

my $query         = new CGI;
my $title         = $query->param('title_filter') || '';
my $ISSN          = $query->param('ISSN_filter') || '';
my $EAN           = $query->param('EAN_filter') || '';
my $callnumber    = $query->param('callnumber_filter') || '';
my $publisher     = $query->param('publisher_filter') || '';
my $bookseller    = $query->param('bookseller_filter') || '';
my $biblionumber  = $query->param('biblionumber') || '';
my $branch        = $query->param('branch_filter') || '';
my $location      = $query->param('location_filter') || '';
my $expiration_date = $query->param('expiration_date_filter') || '';
my $routing       = $query->param('routing') || C4::Context->preference("RoutingSerials");
my $searched      = $query->param('searched') || 0;
my @subscriptionids = $query ->param('subscriptionid');
my $op            = $query->param('op');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "serials/serials-search.tt",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { serials => '*' },
        debug           => 1,
    }
);

if ( $op and $op eq "close" ) {
    for my $subscriptionid ( @subscriptionids ) {
        C4::Serials::CloseSubscription( $subscriptionid );
    }
} elsif ( $op and $op eq "reopen" ) {
    for my $subscriptionid ( @subscriptionids ) {
        C4::Serials::ReopenSubscription( $subscriptionid );
    }
}

my $expiration_date_dt = $expiration_date ? dt_from_string( $expiration_date ) : undef;
my @subscriptions;
if ($searched){
    @subscriptions = SearchSubscriptions(
        {
            biblionumber => $biblionumber,
            title        => $title,
            issn         => $ISSN,
            ean          => $EAN,
            callnumber   => $callnumber,
            publisher    => $publisher,
            bookseller   => $bookseller,
            branch       => $branch,
            location     => $location,
            expiration_date => $expiration_date_dt,
        }
    );
}

# to toggle between create or edit routing list options
if ($routing) {
    for my $subscription ( @subscriptions) {
        $subscription->{routingedit} = check_routing( $subscription->{subscriptionid} );
    }
}

my (@openedsubscriptions, @closedsubscriptions);
for my $sub ( @subscriptions ) {
    unless ( $sub->{closed} ) {
        push @openedsubscriptions, $sub
            unless $sub->{cannotdisplay};
    } else {
        push @closedsubscriptions, $sub
            unless $sub->{cannotdisplay};
    }
}

my $branches = GetBranches();
my @branches_loop;
foreach (sort keys %$branches){
    my $selected = 0;
    $selected = 1 if( defined $branch and $branch eq $_ );
    push @branches_loop, {
        branchcode  => $_,
        branchname  => $branches->{$_}->{'branchname'},
        selected    => $selected,
    };
}


$template->param(
    openedsubscriptions => \@openedsubscriptions,
    closedsubscriptions => \@closedsubscriptions,
    total         => @openedsubscriptions + @closedsubscriptions,
    title_filter  => $title,
    ISSN_filter   => $ISSN,
    EAN_filter    => $EAN,
    callnumber_filter => $callnumber,
    publisher_filter => $publisher,
    bookseller_filter  => $bookseller,
    branch_filter => $branch,
    locations     => C4::Koha::GetAuthorisedValues('LOC', $location),
    expiration_date_filter => $expiration_date_dt,
    branches_loop => \@branches_loop,
    done_searched => $searched,
    routing       => $routing,
    marcflavour   => (uc(C4::Context->preference("marcflavour")))
);

output_html_with_http_headers $query, $cookie, $template->output;
