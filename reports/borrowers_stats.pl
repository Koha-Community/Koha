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
use HTML::Template;
use C4::Search;
use C4::Output;
use C4::Koha;
use C4::Interface::CGI::Output;
use C4::Circulation::Circ2;

=head1 NAME

plugin that shows a stats on borrowers

=head1 DESCRIPTION


=over2

=cut

my $input = new CGI;
my $do_it=$input->param('do_it');
my $fullreportname = "reports/borrowers_stats.tmpl";
my $line = $input->param("Line");
my $column = $input->param("Column");
my @filters = $input->param("Filter");
my $digits = $input->param("digits");
my $borstat = $input->param("status");
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
	my $results = calculate($line, $column, $digits, $borstat, \@filters);
	$template->param(mainloop => $results);
# 	print $input->header(-type => 'application/vnd.ms-excel', -name=>"export.csv");
# 	my $lines = @$results[0]->{looprow};
# 	foreach my $line (@$lines) {
# 		my $x = $line->{loopcell};
# 		foreach my $cell (@$x) {
# 			print $cell->{value}.";";
# 		}
# 		print "\n";
# 	}
} else {
	my $dbh = C4::Context->dbh;
	my @values;
	my %labels;
	my $req;
	$req = $dbh->prepare( "select categorycode, description from categories");
	$req->execute;
	my %select_catcode;
	my @select_catcode;
	push @select_catcode,"";
	$select_catcode{""} = "";
	while (my ($catcode, $description) =$req->fetchrow) {
		push @select_catcode, $catcode;
		$select_catcode{$catcode} = $description
	}
	my $CGICatCode=CGI::scrolling_list( -name     => 'Filter',
				-id => 'Filter',
				-values   => \@select_catcode,
				-labels   => \%select_catcode,
				-size     => 1,
				-multiple => 0 );
	
	$req = $dbh->prepare( "select distinctrow sort1 from borrowers");
	$req->execute;
	my @select_sort1;
	push @select_sort1,"";
	while (my ($value) =$req->fetchrow) {
		push @select_sort1, $value;
	}
	my $CGIsort1=CGI::scrolling_list( -name     => 'Filter',
				-id => 'Filter',
				-values   => \@select_sort1,
				-size     => 1,
				-multiple => 0 );
	
	$req = $dbh->prepare( "select distinctrow sort2 from borrowers");
	$req->execute;
	my @select_sort2;
	push @select_sort2,"";
	while (my ($value) =$req->fetchrow) {
		push @select_sort2, $value;
	}
	my $CGIsort2=CGI::scrolling_list( -name     => 'Filter',
				-id => 'Filter',
				-values   => \@select_sort2,
				-size     => 1,
				-multiple => 0 );
	$template->param(CGICatcode => $CGICatCode,
					CGISort1 => $CGIsort1,
					CGISort2 => $CGIsort2
					);

}
output_html_with_http_headers $input, $cookie, $template->output;



sub calculate {
	my ($line, $column, $digits, $status, $filters) = @_;
	my @mainloop;
	my @loopfooter;
	my @loopcol;
	my @looprow;
	my %globalline;
	my $grantotal =0;
# extract parameters
	my $dbh = C4::Context->dbh;

# Filters
	my $linefilter = "";
	$linefilter = @$filters[0] if ($line =~ /categorycode/ )  ;
	$linefilter = @$filters[1] if ($line =~ /zipcode/ )  ;
	$linefilter = @$filters[2] if ($line =~ /sort1/ ) ;
	$linefilter = @$filters[3] if ($line =~ /sort2/ ) ;

	my $colfilter = "";
	$colfilter = @$filters[0] if ($column =~ /categorycode/);
	$colfilter = @$filters[1] if ($column =~ /zipcode/);
	$colfilter = @$filters[2] if ($column =~ /sort1/);
	$colfilter = @$filters[3] if ($column =~ /sort2/);

	my @loopfilter;
	for (my $i=0;$i<=3;$i++) {
		my %cell;
		if ( @$filters[$i] ) {
			$cell{filter} .= @$filters[$i];
			$cell{crit} .="Category Code " if ($i==0);
			$cell{crit} .="Zip Code" if ($i==1);
			$cell{crit} .="Sort1" if ($i==2);
			$cell{crit} .="Sort2" if ($i==3);
			push @loopfilter, \%cell;
		}
	}
	if ($status) {
		push @loopfilter,{crit=>"Status",filter=>$status}
	}
# 1st, loop rows.
#problem with NULL Values.
	my $strsth;
	$strsth .= "select distinctrow $line from borrowers where $line is not null ";
	$linefilter =~ s/\*/%/g;
	if ( $linefilter ) {
		$strsth .= " and $line LIKE ? " ;
	}
	$strsth .= " and $status='1' " if ($status);
	$strsth .=" order by $line";
	warn "". $strsth;
	
	my $sth = $dbh->prepare( $strsth );
	if ( $linefilter ) {
		$sth->execute($linefilter);
	} else {
		$sth->execute;
	}
 	while ( my ($celvalue) = $sth->fetchrow) {
 		my %cell;
		if ($celvalue) {
			$cell{rowtitle} = $celvalue;
		} else {
			$cell{rowtitle} = "";
		}
 		$cell{totalrow} = 0;
		push @looprow, \%cell;
 	}

# 2nd, loop cols.
	my $strsth2;
	$colfilter =~ s/\*/%/g;
	$strsth2 .= "select distinctrow $column from borrowers where $column is not null";
	if ( $colfilter ) {
		$strsth2 .= " and $column LIKE ? ";
	} 
	$strsth2 .= " and $status='1' " if ($status);
	$strsth2 .= " order by $column";
	warn "". $strsth2;
	my $sth2 = $dbh->prepare( $strsth2 );
	if ($colfilter) {
		$sth2->execute($colfilter);
	} else {
		$sth2->execute;
	}
 	while (my ($celvalue) = $sth2->fetchrow) {
 		my %cell;
		my %ft;
		$cell{coltitle} = $celvalue;
 		$ft{totalcol} = 0;
		push @loopcol, \%cell;
		push @loopfooter, \%ft;
 	}
# now, parse each category. Before filling the result array, fill it with 0 to have every itemtype column.
 	my $strcalc .= "SELECT  count( * ) FROM borrowers WHERE $line = ? and $column= ? ";
	$strcalc .= " AND categorycode like '" . @$filters[1] ."%' " if ( @$filters[1] );
	$strcalc .= " AND sort1 like ' " . @$filters[2] ."%'" if ( @$filters[2] );
	$strcalc .= " AND sort2 like ' " . @$filters[3] ."%'" if ( @$filters[3] );
	$strcalc .= " AND zipcode like ' " . @$filters[4] ."%'" if ( @$filters[4] );
	$strcalc .= " and $status='1' " if ($status);
	warn "". $strcalc;
	my $dbcalc = $dbh->prepare($strcalc);
	my $i=0;
	my @totalcol;
	my $hilighted=-1;
	# for each line
	for (my $i=0; $i<=$#looprow; $i++) {
		my $row = $looprow[$i]->{'rowtitle'};
		my @loopcell;
		my $totalrow=0;
		# for each column
		for (my $j=0;$j<=$#loopcol;$j++) {
			my $col = $loopcol[$j]->{'coltitle'};
			$dbcalc->execute($row,$col);
			my ($value) = $dbcalc->fetchrow;
# 			warn "$row / $col / $value";
			$totalrow += $value;
			$grantotal += $value;
			$loopfooter[$j]->{'totalcol'} +=$value;
			push @loopcell,{value => $value};
		}
		$looprow[$i]->{'totalrow'}=$totalrow;
		$looprow[$i]->{'loopcell'}=\@loopcell;
		$looprow[$i]->{'hilighted'} = 1 if $hilighted eq 1;
		$hilighted = -$hilighted;
	}

# 	# the header of the table
 	$globalline{loopfilter}=\@loopfilter;
	$globalline{looprow} = \@looprow;
# 	# the core of the table
 	$globalline{loopcol} = \@loopcol;
# 	# the foot (totals by borrower type)
 	$globalline{loopfooter} = \@loopfooter;
 	$globalline{total}= $grantotal;
	$globalline{line} = $line;
	$globalline{column} = $column;
	push @mainloop,\%globalline;
	return \@mainloop;
}

1;