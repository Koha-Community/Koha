#!/usr/bin/perl
# WARNING: This file uses 4-character tabs!


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
use CGI qw/:standard/;
use C4::Circulation::Circ2;
use C4::Output;
use C4::Auth;
use C4::Print;
use C4::Interface::CGI::Output;
use HTML::Template;
use DBI;
use C4::Koha;


# this is a reorganisation of circulationold.pl
# dividing it up into three scripts......
# this will be the first one that chooses branch and printer settings....

#general design stuff...
my $headerbackgroundcolor='#99cc33';
my $circbackgroundcolor='#ffffcc';
my $circbackgroundcolor='white';
my $linecolor1='#ffffcc';
my $linecolor2='white';
my $backgroundimage="/images/background-mem.gif";

# try to get the branch and printer settings from the http....
my %env;
my $query=new CGI;
my $branches=getbranches(\%env);
my $printers=getprinters(\%env);
my $branch=$query->param('branch');
my $printer=$query->param('printer');

($branch) || ($branch=$query->cookie('branch'));
($printer) || ($printer=$query->cookie('printer'));

($branches->{$branch}) || ($branch=(keys %$branches)[0]);
($printers->{$printer}) || ($printer=(keys %$printers)[0]);


# is you force a selection....
my $oldbranch = $branch;
my $oldprinter = $printer;

#$branch='';
#$printer='';


$env{'branchcode'}=$branch;
$env{'printer'}=$printer;
$env{'queue'}=$printer;

# set up select options....
my $branchcount=0;
my $printercount=0;
my @branchloop;
foreach my $br (keys %$branches) {
    next unless $br =~ /\S/;
    #(next) unless ($branches->{$_}->{'IS'}); # FIXME disabled to fix bug 202
    $branchcount++;
	my %branch;
	$branch{selected}=($br eq $oldbranch);
	$branch{name}=$branches->{$br}->{'branchname'};
	$branch{value}=$br;
    push(@branchloop,\%branch);
}
my @printerloop;
foreach (keys %$printers) {
    (next) unless ($_);
    $printercount++;
	my %printer;
	$printer{selected}=($_ eq $oldprinter);
	$printer{name}=$printers->{$_}->{'printername'};
	$printer{value}=$_;
    push(@printerloop,\%printer);
}

# if there is only one....
my $printername;
my $branchname;

my $oneprinter=($printercount==1) ;
my $onebranch=($branchcount==1) ;
if ($printercount==1) {
    my ($tmpprinter)=keys %$printers;
	$printername=$printers->{$tmpprinter}->{printername};
}
if ($branchcount==1) {
    my ($tmpbranch)=keys %$branches;
	$branchname=$branches->{$tmpbranch}->{branchname};
}


#############################################################################################
# Start writing page....
# set header with cookie....

my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "circ/selectbranchprinter.tmpl",
							query => $query,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => {circulate => 1},
                         });
$template->param(headerbackgroundcolor => $headerbackgroundcolor,
							backgroundimage => $backgroundimage,
							oneprinter => $oneprinter,
							onebranch => $onebranch,
							printername => $printername,
							branchname => $branchname,
							printerloop => \@printerloop,
							branchloop => \@branchloop
							);

my $branchcookie=$query->cookie(-name => 'branch', -value => "$branch", -expires => '+1y');
my $printercookie=$query->cookie(-name => 'printer', -value => "$printer", -expires => '+1y');

my $cookies=[$cookie,$branchcookie, $printercookie]; 
output_html_with_http_headers $query, $cookies, $template->output;


# Local Variables:
# tab-width: 4
# End:
