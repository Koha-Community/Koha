#!/usr/bin/perl
# WARNING: 4-character tab stops here

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

subscription-renew.pl

=head1 DESCRIPTION

this script renew an existing subscription.

=head1 Parameters

=over 4

=item op
op use to know the operation to do on this template.
 * renew : to renew the subscription.

Note that if op = modsubscription there are a lot of other parameters.

=item subscriptionid
Id of the subscription this script has to renew

=back

=cut

use strict;

use CGI;
use C4::Koha;
use C4::Auth;
use C4::Dates qw/format_date/;
use C4::Context;
use C4::Auth;
use C4::Output;
use C4::Serials;

my $query = new CGI;
my $dbh   = C4::Context->dbh;

my $mode           = $query->param('mode');
my $op             = $query->param('op');
my $subscriptionid = $query->param('subscriptionid');
my $done = 0;    # for after form has been submitted
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "serials/subscription-renew.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { serials => 1 },
        debug           => 1,
    }
);

if ( $op eq "renew" ) {
    ReNewSubscription(
        $subscriptionid,             $loggedinuser,
        $query->param('startdate'),  $query->param('numberlength'),
        $query->param('weeklength'), $query->param('monthlength'),
        $query->param('note')
    );  
}

my $subscription = GetSubscription($subscriptionid);
if ($subscription->{'cannotedit'}){
  warn "Attempt to renew subscription $subscriptionid by ".C4::Context->userenv->{'id'}." not allowed";
  print $query->redirect("/cgi-bin/koha/serials/subscription-detail.pl?subscriptionid=$subscriptionid");
}  

$template->param(
    startdate => format_date(
             GetExpirationDate($subscriptionid)
          || POSIX::strftime( "%Y-%m-%d", localtime )
    ),
    numberlength   => $subscription->{numberlength},
    weeklength     => $subscription->{weeklength},
    monthlength    => $subscription->{monthlength},
    subscriptionid => $subscriptionid,
    bibliotitle    => $subscription->{bibliotitle},
    $op            => 1,
    popup          => ($query->param('mode')eq "popup"),  
);

# Print the page
output_html_with_http_headers $query, $cookie, $template->output;

# Local Variables:
# tab-width: 4
# End:
