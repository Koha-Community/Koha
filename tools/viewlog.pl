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

use strict;
use C4::Auth;
use CGI;
use C4::Context;
use C4::Koha;
use C4::Dates;
use C4::Output;
use C4::Log;
use C4::Items;
use C4::Branch;
use C4::Debug;
# use Data::Dumper;
use C4::Search;		# enabled_staff_search_views

use vars qw($debug $cgi_debug);

=head1 viewlog.pl

plugin that shows stats

=cut

my $input    = new CGI;

$debug or $debug = $cgi_debug;
my $do_it    = $input->param('do_it');
my @modules   = $input->param("modules");
my $user     = $input->param("user");
my $action   = $input->param("action");
my $object   = $input->param("object");
my $info     = $input->param("info");
my $datefrom = $input->param("from");
my $dateto   = $input->param("to");
my $basename = $input->param("basename");
my $mime     = $input->param("MIME");
#my $del      = $input->param("sep");
my $output   = $input->param("output") || "screen";
my $src      = $input->param("src");    # this param allows us to be told where we were called from -fbcit

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "tools/viewlog.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => 'view_system_logs' },
        debug           => 1,
    }
);

if ($src eq 'circ') {   # if we were called from circulation, use the circulation menu and get data to populate it -fbcit
    use C4::Members;
    my $borrowernumber = $object;
    my $data = GetMember($borrowernumber,'borrowernumber');
    my ($picture, $dberror) = GetPatronImage($data->{'cardnumber'});
    $template->param( picture => 1 ) if $picture;
    $template->param(   menu            => 1,
                        title           => $data->{'title'},
                        initials        => $data->{'initials'},
                        surname         => $data->{'surname'},
                        borrowernumber  => $borrowernumber,
                        firstname       => $data->{'firstname'},
                        cardnumber      => $data->{'cardnumber'},
                        categorycode    => $data->{'categorycode'},
                        categoryname	=> $data->{'description'},
                        address         => $data->{'address'},
                        address2        => $data->{'address2'},
                        city            => $data->{'city'},
			zipcode		=> $data->{'zipcode'},
                        phone           => $data->{'phone'},
                        phonepro        => $data->{'phonepro'},
                        email           => $data->{'email'},
                        branchcode      => $data->{'branchcode'},
                        branchname		=> GetBranchName($data->{'branchcode'}),
    );
}

$template->param(
	DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(),
	              dateformat => C4::Dates->new()->format(),
				       debug => $debug,
	C4::Search::enabled_staff_search_views,
);
#
#### This code was never really used - maybe some day some will fix it ###
#my @mime = ( C4::Context->preference("MIME") );
#my $CGIextChoice = CGI::scrolling_list(
#        -name     => 'MIME',
#        -id       => 'MIME',
#        -values   => \@mime,
#        -size     => 1,
#        -multiple => 0
#);
#my @dels         = ( C4::Context->preference("delimiter") );
#my $CGIsepChoice = CGI::scrolling_list(
#        -name     => 'sep',
#        -id       => 'sep',
#        -values   => \@dels,
#        -size     => 1,
#        -multiple => 0
#);
#$template->param(
#        CGIextChoice => $CGIextChoice,
#        CGIsepChoice => $CGIsepChoice,
#);
#
if ($do_it) {

    my $results = GetLogs($datefrom,$dateto,$user,\@modules,$action,$object,$info);
    my $total = scalar @$results;
    foreach my $result (@$results){
	if ($result->{'info'} eq 'item'){
	    # get item information so we can create a working link
	    my $item=GetItem($result->{'object'});
	    $result->{'biblionumber'}=$item->{'biblionumber'};
	    $result->{'biblioitemnumber'}=$item->{'biblionumber'};		
	}
    }
    
    if ( $output eq "screen" ) {
        # Printing results to screen
        $template->param (
			logview => 1,
            total    => $total,
            looprow  => $results,
            do_it    => 1,
            datefrom => $datefrom,
            dateto   => $dateto,
            user     => $user,
            object   => $object,
            action   => $action,
            info     => $info,
            src      => $src,
        );
	    #module   => 'fix this', #this seems unused in actual code
	foreach my $module (@modules) {
		$template->param($module  => 1);
	}

        output_html_with_http_headers $input, $cookie, $template->output;
    } else {
        # Printing to a csv file
        print $input->header(
            -type       => 'text/csv',
            -attachment => "$basename.csv",
            -filename   => "$basename.csv"
        );
        my $sep = C4::Context->preference("delimiter");
        foreach my $line (@$results) {
            #next unless $modules[0] eq "catalogue";
		foreach (qw(timestamp firstname surname action info title author)) {
			print $line->{$_} . $sep;
		}	
	}
    }
	exit;
} else {
    #my @values;
    #my %labels;
    #my %select;
	#initialize some paramaters that might not be used in the template - it seems to evaluate EXPR even if a false TMPL_IF
	$template->param(
        	total => 0,
		module => "",
		info => ""
	);
	output_html_with_http_headers $input, $cookie, $template->output;
}
