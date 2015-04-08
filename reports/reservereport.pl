#!/usr/bin/perl

#written 26/4/2000
#script to display reports

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

# script now takes a branchcode arg
# eg: http://koha.rangitikei.katipo.co.nz/cgi-bin/koha/reports/reservereport.pl?branch=BL

use strict;
#use warnings; FIXME - Bug 2505
use C4::Stats;
use C4::Dates qw/format_date/;
use CGI;
use C4::Output;
use C4::Branch; # GetBranches
use C4::Auth;
use C4::Koha;
use C4::Items;


my $input = new CGI;
my $time  = $input->param('time');
my $branch = $input->param('branch');
my $sort = $input->param('sort');

if (!$branch) {
    $branch = "ALL";
}

my $branches=GetBranches();

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "reports/reservereport.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { reports => '*' },
        debug           => 1,
    }
);

# building up branches dropdown box

my %branchall;
my $branchcount=0;
my @branchloop;

foreach my $br (keys %$branches) {
        $branchcount++;
            my %branch1;
            $branch1{name}=$branches->{$br}->{'branchname'};
            $branch1{value}=$br;
        push(@branchloop,\%branch1);
    }  

my ( $count, $data ) = unfilledreserves($branch);

my @dataloop;
my $toggle;
for ( my $i = 0 ; $i < $count ; $i++ ) {
    my %line;
	$toggle = $i%2 ? 0 : 1;
	$line{'borrowernumber'} = $data->[$i]->{'borrowernumber'};
	$line{'surname'} = $data->[$i]->{'surname'};
	$line{'firstname'} = $data->[$i]->{'firstname'};
        $line{'sortdate'}       = $data->[$i]->{'reservedate'};
        $line{'reservedate'}    = format_date($data->[$i]->{'reservedate'});
	$line{'biblionumber'} = $data->[$i]->{'biblionumber'};
	$line{'title'} = $data->[$i]->{'title'};
	$line{'classification'} = $data->[$i]->{'classification'};
	$line{'dewey'} = $data->[$i]->{'dewey'};
        $line{'status'} = $data->[$i]->{'found'};
        $line{'branchcode'} = $data->[$i]->{'branchcode'};
	$line{'toggle'} = $toggle;
     if ( $line{'status'} ne 'W' ) {
	 
	 # its not waiting, we need to find if its on issue, or on the shelf
	 # FIXME still need to shift the text to the template so its translateable
	 if ( $data->[$i]) {
	     # find if its on issue
	     my @items = GetItemsInfo( $line{biblionumber} );
	     my $onissue = 0;
	     foreach my $item (@items) {
		 if ( $item->{'datedue'} eq 'Reserved' ) {
		     $onissue = 0;
		     if ($item->{'branchname'} eq ''){
			 $line{'status'}='In Transit';
		     }
		     else {			 
			 $line{'status'} = "On shelf at $item->{'branchname'}";
		     }
		     
		 }
		 
		 else {
		     $onissue = 1;
		 }
	     }		 
	     if ($onissue) {
		 $line{'status'} = 'On Issue';
	     }
	 }
	 else {
	     $line{'status'}="Waiting for pickup";
	     
	 }
     }
    push( @dataloop, \%line );
}

if ($sort eq 'name'){ 
    @dataloop = sort {$a->{'surname'} cmp $b->{'surname'}} @dataloop;                                                                                         
}                                                                                                                                                             
elsif ($sort eq 'date'){                                                                                                                                      
    @dataloop = sort {$a->{'sortdate'} cmp $b->{'sortdate'}} @dataloop;                                                                                       
}                                                                                                                                                             
elsif ($sort eq 'title'){                                                                                                                                     
    @dataloop = sort {$a->{'title'} cmp $b->{'title'}} @dataloop;                                                                                             
}                                                                                                                                                             
else {                                                                                                                                                        
    @dataloop = sort {$a->{'status'} cmp $b->{'status'}} @dataloop;                                                                                           
}                                                                                                                                                             


$template->param(
    count    => $count,
    dataloop => \@dataloop,
    branchcode => $branch,
    branchloop => \@branchloop
    
);

output_html_with_http_headers $input, $cookie, $template->output;
