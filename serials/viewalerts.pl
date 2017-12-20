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

use Modern::Perl;
use CGI qw ( -utf8 );
use C4::Auth;
use C4::Context;
use C4::Output;

use Koha::Subscriptions;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => 'serials/viewalerts.tt',
                 query => $input,
                 type => "intranet",
                 authnotrequired => 0,
                 flagsrequired => {serials => '*'},
                 debug => 1,
                 });

my $subscriptionid = $input->param('subscriptionid');

my $subscription = Koha::Subscriptions->find( $subscriptionid );
# FIXME raise a message if subscription does not exist (easy with 18403)

my $subscribers = $subscription->subscribers;

$template->param(
    subscribers    => $subscribers,
    bibliotitle    => $subscription->biblio->title,
    subscriptionid => $subscriptionid,
);

output_html_with_http_headers $input, $cookie, $template->output;
