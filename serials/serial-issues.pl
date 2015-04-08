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


=head1 NAME

serial-issue.pl

=head1 DESCRIPTION

this script give more information about a susbcription given on input arg.

=head1 PARAMETERS

=over 4

=item selectview
can be equal to "full" or not.

=item biblionumber
the biblionumber this script has to give more infos.

=back


=cut

use strict;
use warnings;
use CGI;
use C4::Auth;
use C4::Koha;
use C4::Dates;
use C4::Serials;
use C4::Output;
use C4::Context;


my $query = new CGI;
my $dbh = C4::Context->dbh;
my $selectview = $query->param('selectview');
$selectview = C4::Context->preference("SubscriptionHistory") unless $selectview;

my ($template, $loggedinuser, $cookie);
my $biblionumber = $query->param('biblionumber');
if ($selectview eq "full"){
    my $subscriptions = GetFullSubscriptionsFromBiblionumber($biblionumber);

    my $title = $subscriptions->[0]{bibliotitle};
    my $yearmin=$subscriptions->[0]{year};
    my $yearmax=$subscriptions->[scalar(@$subscriptions)-1]{year};

    ($template, $loggedinuser, $cookie)
     = get_template_and_user({template_name => "serials/serial-issues-full.tt",
     query => $query,
     type => "intranet",
	 flagsrequired => {serials => '*'},
     });

 # replace CR by <br> in librarian note
 # $subscription->{opacnote} =~ s/\n/\<br\/\>/g;

    $template->param(
        biblionumber => $query->param('biblionumber'),
        years => $subscriptions,
        yearmin => $yearmin,
        yearmax =>$yearmax,
        bibliotitle => $title,
        suggestion => C4::Context->preference("suggestion"),
        virtualshelves => C4::Context->preference("virtualshelves"),
    );

} else {
    my $subscriptions = GetSubscriptionsFromBiblionumber($biblionumber);
    ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "serials/serial-issues.tt",
        query => $query,
        type => "intranet",
	    flagsrequired => {serials => '*'},
     });

 # replace CR by <br> in librarian note
 # $subscription->{opacnote} =~ s/\n/\<br\/\>/g;

    $template->param(
        biblionumber => "".$query->param('biblionumber'),
        subscription_LOOP => $subscriptions,
        suggestion => "".C4::Context->preference("suggestion"),
        virtualshelves => "".C4::Context->preference("virtualshelves"),
    );
}
$template->param((uc(C4::Context->preference("marcflavour"))) => 1);
output_html_with_http_headers $query, $cookie, $template->output;
