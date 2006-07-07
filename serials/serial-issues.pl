#!/usr/bin/perl

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

# $Id$

use strict;
use CGI;
use C4::Auth;
use C4::Koha;
use C4::Date;
use C4::Serials;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Context;
use HTML::Template;

my $query = new CGI;
my $op = $query->param('op');
my $dbh = C4::Context->dbh;
my $selectview = $query->param('selectview');
$selectview = C4::Context->preference("SubscriptionHistory") unless $selectview;

my $sth;
# my $id;
my ($template, $loggedinuser, $cookie);
my $biblionumber = $query->param('biblionumber');
if ($selectview eq "full"){
 my $subscriptions = GetFullSubscriptionListFromBiblionumber($biblionumber);
 
 my $title = $subscriptions->[0]{bibliotitle};
 my $yearmin=$subscriptions->[0]{year};
 my $yearmax=$subscriptions->[scalar(@$subscriptions)-1]{year};

 ($template, $loggedinuser, $cookie)
 = get_template_and_user({template_name => "serials/serial-issues-full.tmpl",
     query => $query,
     type => "intranet",
     authnotrequired => 1,
     debug => 1,
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
 my $subscriptions = GetSubscriptionListFromBiblionumber($biblionumber);
 
 ($template, $loggedinuser, $cookie)
 = get_template_and_user({template_name => "serials/serial-issues.tmpl",
     query => $query,
     type => "intranet",
     authnotrequired => 1,
     debug => 1,
     });
 
 # replace CR by <br> in librarian note
 # $subscription->{opacnote} =~ s/\n/\<br\/\>/g;
 
 $template->param(
  biblionumber => $query->param('biblionumber'),
  subscription_LOOP => $subscriptions,
  suggestion => C4::Context->preference("suggestion"),
  virtualshelves => C4::Context->preference("virtualshelves"),
  );
}
output_html_with_http_headers $query, $cookie, $template->output;
