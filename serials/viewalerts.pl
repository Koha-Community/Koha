#!/usr/bin/perl


# Copyright 2000-2002 Katipo Communications
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
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Koha;
use C4::Letters;
use C4::Serials;

my $dbh = C4::Context->dbh;

my $input = new CGI;
my $print = $input->param('print');

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => 'serials/viewalerts.tt',
                 query => $input,
                 type => "intranet",
                 authnotrequired => 0,
                 flagsrequired => {serials => '*'},
                 debug => 1,
                 });

my $subscriptionid=$input->param('subscriptionid');

my $borrowers = getalert('','issue',$subscriptionid);
my $subscription = GetSubscription($subscriptionid);

foreach (@$borrowers) {
    $_->{name} = findrelatedto('borrower',$_->{borrowernumber});
}
$template->param(alertloop => $borrowers,
                bibliotitle => $subscription->{bibliotitle},
                subscriptionid => $subscriptionid,
                (uc(C4::Context->preference("marcflavour"))) => 1
                );

output_html_with_http_headers $input, $cookie, $template->output;
