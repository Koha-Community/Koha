#!/usr/bin/perl

# $Id$

#script to place reserves/requests
#writen 2/1/00 by chris@katipo.oc.nz


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
use C4::Search;
use C4::Output;
use C4::Auth;
use C4::Reserves2;
use C4::Biblio;
use C4::Koha;
use C4::Circulation::Circ2;
use HTML::Template;
use C4::Catalogue;
use CGI;
use C4::Date;

my $input = new CGI;

# get biblio information....
my $bib = $input->param('bib');
my $dat = bibdata($bib);

# get existing reserves .....
my ($count,$reserves) = FindReserves($bib);
my $totalcount = $count;
foreach my $res (@$reserves) {
    if ($res->{'found'} eq 'W') {
	$count--;
    }
}

# make priorities options
my $num = $count + 1;

#priorityoptions building
my @optionloop;
for (my $i=1; $i<=$num; $i++){
	my %option;
	$option{num}=$i;
	$option{selected}=($i==$num);
	push(@optionloop, \%option);
}

# todays date
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =localtime(time);
$year=$year+1900;
$mon++;
my $date=format_date("$year-$mon-$mday");


# get biblioitem information and build rows for form
my ($count2,@data) = bibitems($bib);

my @bibitemloop;
foreach my $dat (sort {$b->{'dateaccessioned'} cmp $a->{'dateaccessioned'}} @data) {
    $dat->{'dewey'}="" if ($dat->{'dewey'} == 0);
    $dat->{'volumeddesc'} = "&nbsp;" unless $dat->{'volumeddesc'};
    $dat->{'dewey'}=~ s/\.0000$//;
    $dat->{'dewey'}=~ s/00$//;

	my %abibitem;
	my @barcodeloop;
    my @barcodes = barcodes($dat->{'biblioitemnumber'});
    foreach my $num (@barcodes) {
		my %barcode;
		$barcode{'barcode'}=$num->{'barcode'};
		$barcode{'message'}=$num->{'itemlost'} == 1 ? "(lost)" :
	    $num->{'itemlost'} == 2 ? "(long overdue)" : "";
		push(@barcodeloop, \%barcode);
    }
	$abibitem{'barcodeloop'}=\@barcodeloop;
    $abibitem{'class'}="$dat->{'classification'}$dat->{'dewey'}$dat->{'subclass'}";
    my $select;
    $abibitem{'itemlost'}=(($dat->{'notforloan'})|| ($dat->{'itemlost'} == 1)) ;
	$abibitem{'biblioitemnumber'}=$dat->{'biblioitemnumber'};
	$abibitem{'description'}=$dat->{'description'};
	$abibitem{'volumeddesc'}=$dat->{'volumeddesc'};
	$abibitem{'publicationyear'}=$dat->{'publicationyear'};
	push(@bibitemloop,\%abibitem);
}



#existingreserves building
my @reserveloop;
my $branches = getbranches();
foreach my $res (sort {$a->{'found'} cmp $b->{'found'}} @$reserves){
	my %reserve;
#    my $prioropt = priorityoptions($totalcount, $res->{'priority'});
	my @optionloop;
	for (my $i=1; $i<=$totalcount; $i++){
		my %option;
		$option{num}=$i;
		$option{selected}=($i==$res->{'priority'});
		push(@optionloop, \%option);
	}
	my @branchloop;
	foreach my $br (keys %$branches) {
# 		(next) unless $branches->{$br}->{'IS'};
				# Only branches with the 'IS' branchrelation
				# can issue books
		my %abranch;
		$abranch{'selected'}=($br eq $res->{'branchcode'});
		$abranch{'branch'}=$br;
		$abranch{'branchname'}=$branches->{$br}->{'branchname'};
		push(@branchloop,\%abranch);
	}

    if ($res->{'found'} eq 'W') {
		my %env;
		my $item = $res->{'itemnumber'};
		$item = getiteminformation(\%env,$item);
		$reserve{'barcode'}=$item->{'barcode'};
		$reserve{'biblionumber'}=$item->{'biblionumber'};
		$reserve{'wbrcode'} = $res->{'branchcode'};
		$reserve{'wbrname'} = $branches->{$res->{'branchcode'}}->{'branchname'};
    }
    $reserve{'date'} = format_date($res->{'reservedate'});
	$reserve{'borrowernumber'}=$res->{'borrowernumber'};
	$reserve{'biblionumber'}=$res->{'biblionumber'};
	$reserve{'bornum'}=$res->{'borrowernumber'};
	$reserve{'firstname'}=$res->{'firstname'};
	$reserve{'bornum'}=$res->{'borrowernumber'};
	$reserve{'notes'}=$res->{'reservenotes'};
	$reserve{'wait'}=($res->{'found'} eq 'W');
	$reserve{'constrainttypea'}=($res->{'constrainttype'} eq 'a');
	$reserve{'constrainttypeo'}=($res->{'constrainttype'} eq 'o');
	$reserve{'voldesc'}=$res->{'volumeddesc'};
	$reserve{'itemtype'}=$res->{'itemtype'};
	$reserve{'branchloop'}=\@branchloop;
	$reserve{'optionloop'}=\@optionloop;
	push(@reserveloop,\%reserve);
}

my @branches;
my @select_branch;
my %select_branches;
my ($count2,@branches)=branches();
for (my $i=0;$i<$count2;$i++){
	push @select_branch, $branches[$i]->{'branchcode'};#
	$select_branches{$branches[$i]->{'branchcode'}} = $branches[$i]->{'branchname'};
}
my $CGIbranch=CGI::scrolling_list( -name     => 'pickup',
			-values   => \@select_branch,
			-labels   => \%select_branches,
			-size     => 1,
			-multiple => 0 );

#get the time for the form name...
my $time = time();

#setup colours
my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "request.tmpl",
							query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => {parameters => 1},
                         });
$template->param(	optionloop =>\@optionloop,
								CGIbranch => $CGIbranch,
								reserveloop => \@reserveloop,
								'time' => $time,
								bibitemloop => \@bibitemloop,
								date => $date,
								bib => $bib,
								title =>$dat->{title});
# printout the page
print $input->header(-expires=>'now'), $template->output;
