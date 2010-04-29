#!/usr/bin/perl

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
use CGI;
use Date::Calc qw(Today Day_of_Year Week_of_Year Add_Delta_Days);
use C4::Koha;
use C4::Biblio;
use C4::Auth;
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Acquisition;
use C4::Output;
use C4::Context;
use C4::Branch; # GetBranches
use C4::Serials;
use C4::Letters;

#use Smart::Comments;

my $query = new CGI;
my $dbh = C4::Context->dbh;

my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "serials/subscription-history.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {serials => 'edit_subscription'},
				debug => 1,
				});

my $subscriptionid = $query->param('subscriptionid');
my $modhistory = $query->param('modhistory');
my $subs = &GetSubscription($subscriptionid);

## FIXME : Check rights to edit if mod. Could/Should display an error message.
if ($subs->{'cannotedit'}){
  warn "Attempt to modify subscription $subscriptionid by ".C4::Context->userenv->{'id'}." not allowed";
  print $query->redirect("/cgi-bin/koha/serials/subscription-detail.pl?subscriptionid=$subscriptionid");
}

# Modifications has been sent
if ($modhistory) {
    my $histstartdate = format_date_in_iso($query->param('histstartdate'));
    my $histenddate = format_date_in_iso($query->param('histenddate'));
    my $recievedlist = $query->param('recievedlist');
    my $missinglist = $query->param('missinglist');
    my $opacnote = $query->param('opacnote');
    my $librariannote = $query->param('librariannote');
    my $return = ModSubscriptionHistory ($subscriptionid,$histstartdate,$histenddate,$recievedlist,$missinglist,$opacnote,$librariannote);
    $template->param(success => 1) if ($return == 1);

    # Getting modified data
    $subs = &GetSubscription($subscriptionid);
} 

# Date handling
for (qw(startdate firstacquidate histstartdate enddate histenddate)) {
    # TODO : Handle date formats properly.
     if ($subs->{$_} eq '0000-00-00') {
	$subs->{$_} = ''
    } else {
	$subs->{$_} = format_date($subs->{$_});
    }   
} 

$template->param($subs);
$template->param(history => ($subs->{manualhistory} == 1 ));


output_html_with_http_headers $query, $cookie, $template->output;
