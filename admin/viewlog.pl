#!/usr/bin/perl

# $Id$

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
use C4::Interface::CGI::Output;
use C4::Log;
use Date::Manip;

=head1 NAME

plugin that shows a stats on catalogers

=head1 DESCRIPTION


=over2

=cut

my $input = new CGI;
my $do_it=$input->param('do_it');
my $fullreportname = "parameters/viewlog.tmpl";
my $modulename = $input->param("module");
my $userfilter = $input->param("user");
my $actionfilter = $input->param("action");
my $fromfilter = $input->param("from");
my $tofilter = $input->param("to");
my $basename = $input->param("basename");
my $mime = $input->param("MIME");
my $del = $input->param("sep");
my $output = $input->param("output");


my ($template, $borrowernumber, $cookie)
	= get_template_and_user({template_name => $fullreportname,
				query => $input,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {editcatalogue => 1},
				debug => 1,
				});
$template->param(do_it => $do_it);
if ($do_it) {
# Displaying results
	#building filters
	my @filters;
	push @filters, {name=> 'user', value=> $userfilter} if ($userfilter);
	push @filters, {name=> 'action', value=> $actionfilter} if ($actionfilter);
	push @filters, {name=> 'from', value=> $fromfilter} if ($fromfilter);
	push @filters, {name=> 'to', value=> $tofilter} if ($tofilter);
	if ($modulename eq "catalogue"){
		my $titlefilter = $input->param("title");
		my $authorfilter = $input->param("author");
		my $publisherfilter = $input->param("publisher");
		my $callnumberfilter = $input->param("itemcallnumber");
		
		push @filters, {name=> 'title', value=> $titlefilter} if ($titlefilter);
		push @filters, {name=> 'author', value=> $authorfilter} if ($authorfilter);
		push @filters, {name=> 'publisher', value=> $publisherfilter} if ($publisherfilter);
		push @filters, {name=> 'callnumber', value=> $callnumberfilter} if ($callnumberfilter);
	}
	
	my ($count, $results) = displaylog( $modulename, @filters);
	if ($output eq "screen"){
# Printing results to screen
		$template->param(modulename =>$modulename, $modulename => 1, looprow => $results,counter=>$count);
		output_html_with_http_headers $input, $cookie, $template->output;
		exit(1);
	} else {
# Printing to a csv file
		print $input->header(-type => 'application/vnd.sun.xml.calc',
			-attachment=>"$basename.csv",
			-filename=>"$basename.csv" );
		my $sep;
		$sep =C4::Context->preference("delimiter");
# header top-right
# Other header
# Table
		foreach my $line ( @$results ) {
			if ($modulename eq "catalogue"){
				print $line->{timestamp}.$sep;
				print $line->{firstname}.$sep;
				print $line->{surname}.$sep;
				print $line->{action}.$sep;
				print $line->{info}.$sep;
				print $line->{title}.$sep;
				print $line->{author}.$sep;
			}
 			print "\n";
	 	}
# footer
		exit(1);
	}
} else {
	my $dbh = C4::Context->dbh;
	my @values;
	my %labels;
	my %select;
	my $req;
	
	my @mime = ( C4::Context->preference("MIME") );
#	foreach my $mime (@mime){
#		warn "".$mime;
#	}
	
	my $CGIextChoice=CGI::scrolling_list(
				-name     => 'MIME',
				-id       => 'MIME',
				-values   => \@mime,
				-size     => 1,
				-multiple => 0 );
	
	my @dels = ( C4::Context->preference("delimiter") );
	my $CGIsepChoice=CGI::scrolling_list(
				-name     => 'sep',
				-id       => 'sep',
				-values   => \@dels,
				-size     => 1,
				-multiple => 0 );
	
	$template->param(
					CGIextChoice => $CGIextChoice,
					CGIsepChoice => $CGIsepChoice
					);
output_html_with_http_headers $input, $cookie, $template->output;
}
