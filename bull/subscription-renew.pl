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

use strict;
require Exporter;
use CGI;
use C4::Koha;
use C4::Auth;
use C4::Date;
use HTML::Template;
use C4::Context;
use C4::Search;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Bull;

my $query = new CGI;
my $dbh = C4::Context->dbh;

my $op = $query->param('op');
my $subscriptionid = $query->param('subscriptionid');

my ($template, $loggedinuser, $cookie)
		= get_template_and_user({template_name => "bull/subscription-renew.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {catalogue => 1},
				debug => 1,
				});
if ($op eq "renew") {
	subscriptionrenew($subscriptionid,$loggedinuser,$query->param('startdate'),$query->param('numberlength'),$query->param('weeklength'),$query->param('monthlength'),$query->param('note'));
}

my $subscription= getsubscription($subscriptionid);

$template->param(startdate => format_date(subscriptionexpirationdate($subscriptionid)),
				numberlength => $subscription->{numberlength},
				weeklength => $subscription->{weeklength},
				monthlength => $subscription->{monthlength},
				subscriptionid => $subscriptionid,
				bibliotitle => $subscription->{bibliotitle},
				$op => 1,
			);

# Print the page
output_html_with_http_headers $query, $cookie, $template->output;

# Local Variables:
# tab-width: 4
# End:
