#!/usr/bin/perl

# Routing.pl script used to create a routing list for a serial subscription
# In this instance it is in fact a setting up of a list of reserves for the item
# where the hierarchical order can be changed on the fly and a routing list can be
# printed out
use strict;
use CGI;
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Koha;
use C4::Dates;
use C4::Acquisition;
use C4::Serials;

my $query = new CGI;
my $subscriptionid = $query->param('subscriptionid');
my $routingid = $query->param('routingid');
my $rank = $query->param('rank');

reorder_members($subscriptionid,$routingid,$rank);

print $query->redirect("/cgi-bin/koha/serials/routing.pl?subscriptionid=$subscriptionid");

