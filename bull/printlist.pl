#!/usr/bin/perl
# NOTE: Use standard 8-space tabs for this file (indents are 4 spaces)

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

use HTML::Template;
use strict;
require Exporter;
use C4::Context;
use C4::Output;  # contains gettemplate
use CGI;
use C4::Auth;
use C4::Bull;
use C4::Interface::CGI::Output;
use C4::Koha;

my $query=new CGI;

my $serialseq=$query->param('serialseq');
my $subscriptionid=$query->param('subscriptionid');
my $subscription = getsubscription($subscriptionid);
$subscription->{'distributedto'} =~ s/\n/<br\/>/g;

my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "bull/printlist.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {catalogue => 1},
				debug => 1,
				});
$template->param(serialseq => $serialseq,
				title => $subscription->{bibliotitle},
				branchname => getbranchdetail(C4::Context->userenv->{'branch'})->{branchname},
				branchaddress1 => getbranchdetail(C4::Context->userenv->{'branch'})->{address1},
				branchaddress2 => getbranchdetail(C4::Context->userenv->{'branch'})->{address2},
				branchaddress3 => getbranchdetail(C4::Context->userenv->{'branch'})->{address3},
				branchphone => getbranchdetail(C4::Context->userenv->{'branch'})->{branchphone},
				branchemail => getbranchdetail(C4::Context->userenv->{'branch'})->{branchemail},
				distributedto => $subscription->{'distributedto'},
				);
output_html_with_http_headers $query, $cookie, $template->output;


# Local Variables:
# tab-width: 8
# End:
