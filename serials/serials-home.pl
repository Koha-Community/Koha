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

=head1 NAME

serials-home.pl

=head1 DESCRIPTION

this script is the main page for serials/

=head1 PARAMETERS

=over 4

=item title

=item ISSN

=item biblionumber

=back

=cut


use strict;
use CGI;
use C4::Auth;
use C4::Serials;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Context;
use HTML::Template;

my $query = new CGI;
my $title = $query->param('title');
my $ISSN = $query->param('ISSN');
my $routing = $query->param('routing');
my $searched = $query->param('searched');
my $biblionumber = $query->param('biblionumber');
my $alt_links = 0;
if(C4::Context->preference("RoutingSerials")){
    $alt_links = 0;
}
my @subscriptions = GetSubscriptions($title,$ISSN,$biblionumber);
my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "serials/serials-home.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {catalogue => 1},
				debug => 1,
				});

# to toggle between create or edit routing list options
if($routing){ 
    for(my $i=0;$i<@subscriptions;$i++){
	my $checkrouting = check_routing($subscriptions[$i]->{'subscriptionid'});
	$subscriptions[$i]->{'routingedit'} = $checkrouting;
	# warn "check $checkrouting";
    }
}

$template->param(
	subscriptions => \@subscriptions,
	title => $title,
	ISSN => $ISSN,
        done_searched => $searched,
        routing => $routing,
        alt_links => $alt_links,
	);
output_html_with_http_headers $query, $cookie, $template->output;
