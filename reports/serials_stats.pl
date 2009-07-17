#!/usr/bin/perl

# Copyright 2009 SARL Biblibre
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
use warnings;
use C4::Auth;
use CGI;
use C4::Context;
use C4::Branch; # GetBranches
use C4::Dates qw/format_date/;
use C4::Output;
use C4::Koha;
use C4::Reports;
use C4::Serials;

=head1 serials_out

plugin that shows a stats on serials

=head1 DESCRIPTION

=over 2

=cut

my $input      = new CGI;
my $templatename   = "reports/serials_stats.tmpl";
my $do_it      = $input->param("do_it");
my $bookseller = $input->param("bookseller");
my $branchcode = $input->param("branchcode");
my $expired    = $input->param("expired");
my $order      = $input->param("order");
my $output     = $input->param("output");
my $basename   = $input->param("basename");
my $mime       = $input->param("MIME");
our $sep       = $input->param("sep") || '';
$sep = "\t" if ($sep eq 'tabulation');

my ($template, $borrowernumber, $cookie)
	= get_template_and_user({template_name => $templatename,
				query => $input,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {reports => 1},
				debug => 1,
				});
				
				
				
my $dbh = C4::Context->dbh;

if($do_it){
    my $where = "WHERE 1 ";
    my @args;
    # if a specific branchcode was selected
    if( $branchcode ne '' ){
        $where .= "AND branchcode = ? ";
        push @args,$branchcode;
    }
    
    # if a specific bookseller was selected
    if($bookseller ne ''){
        $where .= "AND aqbooksellerid = ? ";
        push @args,$bookseller;
    }

    my $sth = $dbh->prepare("SELECT * 
                             FROM subscription 
                               LEFT JOIN aqbooksellers 
                               ON (aqbooksellers.id=subscription.aqbooksellerid)
                               LEFT JOIN biblio
                               ON (biblio.biblionumber=subscription.biblionumber)
                               $where
                            ");

    $sth->execute(@args);
    
    ## hash generation of items by branchcode
    my @datas;

    while(my $row = $sth->fetchrow_hashref){
        $row->{'enddate'} = format_date(GetExpirationDate($row->{'subscriptionid'}));
        $row->{'startdate'} = format_date($row->{'startdate'});
        push @datas, $row if ($expired || (not $expired && not HasSubscriptionExpired($row->{subscriptionid})) );
    }
    
    if($output eq 'screen'){
        $template->param(datas => \@datas,
                         do_it => 1);
    }else{
        binmode STDOUT, ':utf8';
        print $input->header(-type => 'application/vnd.sun.xml.calc',
                         -encoding => 'utf-8',
                             -name => "$basename.csv",
                       -attachment => "$basename.csv");
        print "Vendor".$sep;
        print "Title".$sep;
        print "Subscription id".$sep;
        print "Branch".$sep;
        print "Callnumber".$sep;
        print "Subscription Begin".$sep;
        print "Subscription End\n";
        
        foreach my $item (@datas){
            print $item->{name}.$sep;
            print $item->{title}.$sep;
            print $item->{subscriptionid}.$sep;
            print $item->{branchcode}.$sep;
            print $item->{callnumber}.$sep;
            print $item->{startdate}.$sep;
            print $item->{enddate}."\n";
        }
        exit(1);
    }
}else{
    ## We generate booksellers list
    my @booksellers;
    
    my $sth = $dbh->prepare("SELECT aqbooksellerid, aqbooksellers.name 
                                FROM subscription 
                                  LEFT JOIN aqbooksellers ON (subscription.aqbooksellerid=aqbooksellers.id ) 
                                GROUP BY aqbooksellerid");
    $sth->execute();
    
    while(my $row = $sth->fetchrow_hashref){
        push(@booksellers,$row)
    }
   
    ## We generate branchlist
    my $branches=GetBranches();
	my @branchloop;
	foreach (sort {$branches->{$a}->{'branchname'} cmp $branches->{$b}->{'branchname'}} keys %$branches) {
		my $thisbranch = ''; # FIXME: populate $thisbranch to preselect one
		my %row = (branchcode => $_,
			selected => ($thisbranch eq $_ ? 1 : 0),
			branchname => $branches->{$_}->{'branchname'},
		);
		push @branchloop, \%row;
	} 
    
    my @mime = ( C4::Context->preference("MIME") );
	# warn 'MIME(s): ' . join ' ', @mime;
	my $CGIextChoice=CGI::scrolling_list(
				-name => 'MIME',
				-id => 'MIME',
				-values   => \@mime,
				-size     => 1,
				-multiple => 0 );
	my $CGIsepChoice=GetDelimiterChoices;
	$template->param(
		CGIextChoice => $CGIextChoice,
		CGIsepChoice => $CGIsepChoice,
        booksellers  => \@booksellers,
        branches     => \@branchloop);
}

output_html_with_http_headers $input, $cookie, $template->output;
