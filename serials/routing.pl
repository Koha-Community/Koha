#!/usr/bin/perl

# This file is part of Koha
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


=head1 Routing.pl

script used to create a routing list for a serial subscription
In this instance it is in fact a setting up of a list of reserves for the item
where the hierarchical order can be changed on the fly and a routing list can be
printed out

=cut

use strict;
use warnings;
use CGI;
use C4::Koha;
use C4::Auth;
use C4::Dates;
use C4::Output;
use C4::Acquisition;
use C4::Output;
use C4::Context;

use C4::Members;
use C4::Serials;

use URI::Escape;

my $query = new CGI;
my $subscriptionid = $query->param('subscriptionid');
my $serialseq = $query->param('serialseq');
my $routingid = $query->param('routingid');
my $borrowernumber = $query->param('borrowernumber');
my $notes = $query->param('notes');
my $op = $query->param('op') || q{};
my $date_selected = $query->param('date_selected');
$date_selected ||= q{};
my $dbh = C4::Context->dbh;

if($op eq 'delete'){
    delroutingmember($routingid,$subscriptionid);
}

if($op eq 'add'){
    addroutingmember($borrowernumber,$subscriptionid);
}
if($op eq 'save'){
    my $sth = $dbh->prepare('UPDATE serial SET routingnotes = ? WHERE subscriptionid = ?');
    $sth->execute($notes,$subscriptionid);
    my $urldate = URI::Escape::uri_escape($date_selected);
    print $query->redirect("routing-preview.pl?subscriptionid=$subscriptionid&issue=$urldate");
}

my @routinglist = getroutinglist($subscriptionid);
my $subs = GetSubscription($subscriptionid);
my ($count,@serials) = GetSerials($subscriptionid);
my $serialdates = GetLatestSerials($subscriptionid,$count);

my $dates = [];
foreach my $dateseq (@{$serialdates}) {
    my $d = {};
    $d->{publisheddate} = $dateseq->{publisheddate};
    $d->{serialseq} = $dateseq->{serialseq};
    $d->{serialid} = $dateseq->{serialid};
    if($date_selected eq $dateseq->{serialid}){
        $d->{selected} = ' selected';
    } else {
        $d->{selected} = q{};
    }
    push @{$dates}, $d;
}

my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => 'serials/routing.tt',
				query => $query,
				type => 'intranet',
				authnotrequired => 0,
				flagsrequired => {serials => 'routing'},
				debug => 1,
				});

my $member_loop = [];
for my $routing ( @routinglist ) {
    my $member=GetMember('borrowernumber' => $routing->{borrowernumber});
    $member->{location} = $member->{branchcode};
    if ($member->{firstname} ) {
        $member->{name} = $member->{firstname} . q| |;
    }
    else {
        $member->{name} = q{};
    }
    if ($member->{surname} ) {
        $member->{name} .= $member->{surname};
    }
    $member->{routingid}=$routing->{routingid} || q{};
    $member->{ranking} = $routing->{ranking} || q{};

    push(@{$member_loop}, $member);
}

$template->param(
    title => $subs->{bibliotitle},
    subscriptionid => $subscriptionid,
    memberloop => $member_loop,
    op => $op eq 'new',
    dates => $dates,
    routingnotes => $serials[0]->{'routingnotes'},
    hasRouting => check_routing($subscriptionid),
    (uc(C4::Context->preference("marcflavour"))) => 1

    );

output_html_with_http_headers $query, $cookie, $template->output;
