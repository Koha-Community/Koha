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
use Data::Dumper;

use vars qw($debug);

BEGIN {
	$debug = $ENV{DEBUG} || 0;
}

=head1 viewlog.pl

plugin that shows a stats on borrowers

=cut

my $input    = new CGI;

$debug or $debug = $input->param('debug') || 0;
my $do_it    = $input->param('do_it');
my $module   = $input->param("module");
my $user     = $input->param("user");
my $action   = $input->param("action");
my $object   = $input->param("object");
my $info     = $input->param("info");
my $datefrom = $input->param("from");
my $dateto   = $input->param("to");
my $basename = $input->param("basename");
my $mime     = $input->param("MIME");
my $del      = $input->param("sep");
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
);

if ($do_it) {

    my $results = GetLogs($datefrom,$dateto,$user,$module,$action,$object,$info);
    my $total = scalar @$results;
    warn "Total records retrieved = $total";
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
            $module  => 1,
            looprow  => $results,
            do_it    => 1,
            datefrom => $datefrom,
            dateto   => $dateto,
            user     => $user,
            module   => $module,
            object   => $object,
            action   => $action,
            info     => $info,
            src      => $src,
        );
        output_html_with_http_headers $input, $cookie, $template->output;
    } else {
        # Printing to a csv file
        print $input->header(
            -type       => 'application/vnd.sun.xml.calc',
            -attachment => "$basename.csv",
            -filename   => "$basename.csv"
        );
        my $sep = C4::Context->preference("delimiter");
        foreach my $line (@$results) {
            ($module eq "catalogue") or next;
			foreach (qw(timestamp firstname surname action info title author)) {
				print $line->{$_} . $sep;
			}	
		}
    }
	exit;
} else {
    my @values;
    my %labels;
    my %select;
    my @mime = ( C4::Context->preference("MIME") );
    my $CGIextChoice = CGI::scrolling_list(
        -name     => 'MIME',
        -id       => 'MIME',
        -values   => \@mime,
        -size     => 1,
        -multiple => 0
    );
    my @dels         = ( C4::Context->preference("delimiter") );
    my $CGIsepChoice = CGI::scrolling_list(
        -name     => 'sep',
        -id       => 'sep',
        -values   => \@dels,
        -size     => 1,
        -multiple => 0
    );
    $template->param(
        total        => 0,
        CGIextChoice => $CGIextChoice,
        CGIsepChoice => $CGIsepChoice,
    );
    output_html_with_http_headers $input, $cookie, $template->output;
}
