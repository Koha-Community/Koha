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
use CGI;
use C4::Auth;
use C4::Context;
use C4::Branch; # GetBranches
use C4::Koha;
use C4::Dates;
use C4::Acquisition;
use C4::Output;
use C4::Circulation;
use Date::Calc qw(
  Today
  Add_Delta_YM
  );

=head1 NAME

plugin that shows a stats on borrowers

=head1 DESCRIPTION

=over 2

=cut

my $input = new CGI;
my $do_it=$input->param('do_it');
my $fullreportname = "reports/borrowers_stats.tmpl";
my $line = $input->param("Line");
my $column = $input->param("Column");
my @filters = $input->param("Filter");
my $digits = $input->param("digits");
my $period = $input->param("period");
my $borstat = $input->param("status");
my $borstat1 = $input->param("activity");
my $output = $input->param("output");
my $basename = $input->param("basename");
my $mime = $input->param("MIME");
my $del = $input->param("sep");

my ($template, $borrowernumber, $cookie)
	= get_template_and_user({template_name => $fullreportname,
				query => $input,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {reports=> 1},
				debug => 1,
				});
$template->param(do_it => $do_it);
if ($do_it) {
	my $results = calculate($line, $column, $digits, $borstat,$borstat1 ,\@filters);
	if ($output eq "screen"){
		$template->param(mainloop => $results);
		output_html_with_http_headers $input, $cookie, $template->output;
		exit(1);
	} else {
		print $input->header(-type => 'application/vnd.sun.xml.calc',
                                     -encoding    => 'utf-8',
                                     -name=>"$basename.csv",
                                     -attachment=>"$basename.csv");
		my $cols = @$results[0]->{loopcol};
		my $lines = @$results[0]->{looprow};
		my $sep;
		$sep =C4::Context->preference("delimiter");
		print @$results[0]->{line} ."/". @$results[0]->{column} .$sep;
		foreach my $col ( @$cols ) {
			print $col->{coltitle}.$sep;
		}
		print "Total\n";
		foreach my $line ( @$lines ) {
			my $x = $line->{loopcell};
			print $line->{rowtitle}.$sep;
			foreach my $cell (@$x) {
				print $cell->{value}.$sep;
			}
			print $line->{totalrow};
 			print "\n";
	 	}
		print "TOTAL";
		$cols = @$results[0]->{loopfooter};
		foreach my $col ( @$cols ) {
			print $sep.$col->{totalcol};
		}
		print $sep.@$results[0]->{total};
		exit(1);
	}
} else {
	my $dbh = C4::Context->dbh;
	my @values;
	my %labels;
	my $req;
	$req = $dbh->prepare( "select categorycode, description from categories order by description");
	$req->execute;
	my %select_catcode;
	my @select_catcode;
	push @select_catcode,"";
	$select_catcode{""} ="";
 	while (my ($catcode, $description) =$req->fetchrow) {
 		push @select_catcode, $catcode;
 		$select_catcode{$catcode} = $description;
 	}
 	my $CGICatCode=CGI::scrolling_list( -name     => 'Filter',
 				-id => 'catcode',
 				-values   => \@select_catcode,
 				-labels   => \%select_catcode,
 				-size     => 1,
 				-multiple => 0 );

	
my $branches = GetBranches;
my @branchloop;
my @select_branch;
#my %select_branches;
push @select_branch,"";
#$select_branches{""}="";
foreach my $thisbranch (sort keys %$branches) {
	push @select_branch,$thisbranch;
   # my $selected = 1 if $thisbranch eq $branch;
    my %row =(value => $thisbranch,
#                selected => $selected,
                branchname => $branches->{$thisbranch}->{'branchname'},
            );
    push @branchloop, \%row;
}
    my $CGIBranch=CGI::scrolling_list( -name     => 'Filter',
                             -id => 'branch',
                             -values   => \@select_branch,
#                             -labels   => \%select_branches,
                             -size     => 1,
                             -multiple => 0 );


 	$req = $dbh->prepare( "select distinctrow zipcode from borrowers order by zipcode");
 	$req->execute;
 	my @select_zipcode;
 	push @select_zipcode,"";
 	while (my ($value) =$req->fetchrow) {
 		if ($value) {
 			push @select_zipcode, $value;
 		}
 	}
# 
 	my $CGIZipCode=CGI::scrolling_list( -name     => 'Filter',
 				-id => 'zipcode',
 				-values   => \@select_zipcode,
 				-size     => 1,
 				-multiple => 0 );


	$req = $dbh->prepare( "SELECT authorised_value,lib FROM authorised_values WHERE category='Bsort1' order by lib");
 	$req->execute;
 	my @select_sort1;
	my %select_sort1;
 	push @select_sort1,"";
	$select_sort1{""}="";
 	my $hassort1;
 	while (my ($auth_value,$lib) =$req->fetchrow) {
 		if ($auth_value) {
 			$hassort1=1;
 			push @select_sort1, $auth_value;
			$select_sort1{$auth_value}=$lib
 		}
 	}
# 
 	my $CGIsort1=CGI::scrolling_list( -name     => 'Filter',
 				-id => 'sort1',
 				-values   => \@select_sort1,
				-labels	=>\%select_sort1,
 				-size     => 1,
 				-multiple => 0 );
	
	$req = $dbh->prepare( "select distinctrow sort2 from borrowers order by sort2");
	$req->execute;
	my @select_sort2;
	push @select_sort2,"";
	my $hassort2;
	while (my ($value) =$req->fetchrow) {
		if ($value) {
			$hassort2 = 1;
			push @select_sort2, $value;
		}
	}
	my $CGIsort2=CGI::scrolling_list( -name     => 'Filter',
				-id => 'sort2',
				-values   => \@select_sort2,
				-size     => 1,
				-multiple => 0 );
	
	my @mime = ( C4::Context->preference("MIME") );
	# warn 'MIME(s): ' . join ' ', @mime;
	my $CGIextChoice=CGI::scrolling_list(
				-name => 'MIME',
				-id => 'MIME',
				-values   => \@mime,
				-size     => 1,
				-multiple => 0 );
	
	my @dels = ( C4::Context->preference("delimiter") );
	my $CGIsepChoice=CGI::scrolling_list(
				-name => 'sep',
				-id => 'sep',
				-values   => \@dels,
				-size     => 1,
				-multiple => 0 );

	$template->param(		CGICatCode => $CGICatCode,
					CGIZipCode => $CGIZipCode,
					CGISort1 => $CGIsort1,
					hassort1 => $hassort1,
					CGISort2 => $CGIsort2,
					hassort2 => $hassort2,
					CGIextChoice => $CGIextChoice,
					CGIsepChoice => $CGIsepChoice,
					CGIBranch => $CGIBranch,
					DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(),
                    );

}
output_html_with_http_headers $input, $cookie, $template->output;



sub calculate {
	my ($line, $column, $digits, $status, $activity, $filters) = @_;
	my @mainloop;
	my @loopfooter;
	my @loopcol;
	my @loopline;
	my @looprow;
	my %globalline;
	my $grantotal =0;
# extract parameters
	my $dbh = C4::Context->dbh;

# Filters
 	my $linefilter = "";
#	warn "filtres ".@filters[0];
#	warn "filtres ".@filters[4];
#	warn "filtres ".@filters[5];
#	warn "filtres ".@filters[6];

	
 	$linefilter = @$filters[0] if ($line =~ /categorycode/ )  ;
 	$linefilter = @$filters[1] if ($line =~ /zipcode/ )  ;
 	$linefilter = @$filters[2] if ($line =~ /branchcode/ ) ;
 	$linefilter = @$filters[5] if ($line =~ /sort1/ ) ;
 	$linefilter = @$filters[6] if ($line =~ /sort2/ ) ;
# 
 	my $colfilter = "";
 	$colfilter = @$filters[0] if ($column =~ /categorycode/);
 	$colfilter = @$filters[1] if ($column =~ /zipcode/);
 	$colfilter = @$filters[2] if ($column =~ /branchcode/);
 	$colfilter = @$filters[5] if ($column =~ /sort1/);
 	$colfilter = @$filters[6] if ($column =~ /sort2/);

	my @loopfilter;
	for (my $i=0;$i<=6;$i++) {
		my %cell;
		if ( @$filters[$i] ) {
			$cell{filter} .= @$filters[$i];
			$cell{crit} .="Cat Code " if ($i==0);
			$cell{crit} .="Zip Code" if ($i==1);
			$cell{crit} .="Branchcode" if ($i==2);
			$cell{crit} .="Date of Birth" if ($i==3);
			$cell{crit} .="Date of Birth" if ($i==4);
			$cell{crit} .="Sort1" if ($i==5);
			$cell{crit} .="Sort2" if ($i==6);
			push @loopfilter, \%cell;
		}
	}
	if ($status) {
		push @loopfilter,{crit=>"Status",filter=>$status}
	}
		
	if ($activity) {
		push @loopfilter,{crit=>"Activity",filter=>$activity};
	}
# year of activity
	my ( $period_year, $period_month, $period_day )=Add_Delta_YM( Today(),-$period, 0);
	my $newperioddate=$period_year."-".$period_month."-".$period_day;
#	warn "PERIOD".$period;
# 1st, loop rows.
	my $linefield;
	if (($line =~/zipcode/) and ($digits)) {
		$linefield .="left($line,$digits)";
	} else{
		$linefield .= $line;
	}
	
	my $strsth;
	$strsth .= "select distinctrow $linefield from borrowers where $line is not null ";
	$linefilter =~ s/\*/%/g;
	if ( $linefilter ) {
		$strsth .= " and $linefield LIKE ? " ;
	}
	$strsth .= " and $status='1' " if ($status);
	$strsth .=" order by $linefield";
#	warn "". $strsth;
	
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
#		} else {
#			$cell{rowtitle} = "";
		}
 		$cell{totalrow} = 0;
		push @loopline, \%cell;
 	}

# 2nd, loop cols.
	my $colfield;
	if (($column =~/zipcode/) and ($digits)) {
		$colfield .= "left($column,$digits)";
	} else{
		$colfield .= $column;
	}
	my $strsth2;
	$colfilter =~ s/\*/%/g;
	$strsth2 .= "select distinctrow $colfield from borrowers where $column is not null";
	if ( $colfilter ) {
		$strsth2 .= " and $colfield LIKE ? ";
	}
	$strsth2 .= " and $status='1' " if ($status);
	$strsth2 .= " order by $colfield";
#	warn "". $strsth2;
	my $sth2 = $dbh->prepare( $strsth2 );
	if ($colfilter) {
		$sth2->execute($colfilter);
	} else {
		$sth2->execute;
	}
 	while (my ($celvalue) = $sth2->fetchrow) {
 		my %cell;
		my %ft;
		if ($celvalue) {
			$cell{coltitle} = $celvalue;
		}
		push @loopcol, \%cell;
 	}
	

	my $i=0;
	my @totalcol;
	my $hilighted=-1;
	
	#Initialization of cell values.....
	my %table;
#	warn "init table";
	foreach my $row ( @loopline ) {
		foreach my $col ( @loopcol ) {
#			warn " init table : $row->{rowtitle} / $col->{coltitle} ";
			$table{$row->{rowtitle}}->{$col->{coltitle}}=0;
		}
		$table{$row->{rowtitle}}->{totalrow}=0;
	}

# preparing calculation
	my $strcalc .= "SELECT $linefield, $colfield, count( * ) FROM borrowers WHERE 1 ";
	@$filters[0]=~ s/\*/%/g if (@$filters[0]);
	$strcalc .= " AND categorycode like '" . @$filters[0] ."'" if ( @$filters[0] );
	@$filters[1]=~ s/\*/%/g if (@$filters[1]);
	$strcalc .= " AND zipcode like '" . @$filters[1] ."'" if ( @$filters[1] );
	@$filters[2]=~ s/\*/%/g if (@$filters[2]);
	$strcalc .= " AND branchcode like '" . @$filters[2] ."'" if ( @$filters[2] );
	@$filters[3]=~ s/\*/%/g if (@$filters[3]);
	$strcalc .= " AND dateofbirth > '" . @$filters[3] ."'" if ( @$filters[3] );
	@$filters[4]=~ s/\*/%/g if (@$filters[4]);
	$strcalc .= " AND dateofbirth < '" . @$filters[4] ."'" if ( @$filters[4] );
	@$filters[5]=~ s/\*/%/g if (@$filters[5]);
	$strcalc .= " AND sort1 like '" . @$filters[5] ."'" if ( @$filters[5] );
	@$filters[6]=~ s/\*/%/g if (@$filters[6]);
	$strcalc .= " AND sort2 like '" . @$filters[6] ."'" if ( @$filters[6] );
	$strcalc .= " AND borrowernumber in (select distinct(borrowernumber) from old_issues where issuedate > '" . $newperioddate . "')" if ($activity eq 'active');
	$strcalc .= " AND borrowernumber not in (select distinct(borrowernumber) from old_issues where issuedate > '" . $newperioddate . "')" if ($activity eq 'nonactive');
	$strcalc .= " AND $status='1' " if ($status);
	$strcalc .= " group by $linefield, $colfield";
#	warn "". $strcalc;
	my $dbcalc = $dbh->prepare($strcalc);
	$dbcalc->execute;
#	warn "filling table";
	
	my $emptycol; 
	while (my ($row, $col, $value) = $dbcalc->fetchrow) {
#		warn "filling table $row / $col / $value ";
		$emptycol = 1 if ($col eq undef);
		$col = "zzEMPTY" if ($col eq undef);
		$row = "zzEMPTY" if ($row eq undef);
		
		$table{$row}->{$col}+=$value;
		$table{$row}->{totalrow}+=$value;
		$grantotal += $value;
	}
	
 	push @loopcol,{coltitle => "NULL"} if ($emptycol);
	
	foreach my $row ( sort keys %table ) {
		my @loopcell;
		#@loopcol ensures the order for columns is common with column titles
		# and the number matches the number of columns
		foreach my $col ( @loopcol ) {
			my $value =$table{$row}->{($col->{coltitle} eq "NULL")?"zzEMPTY":$col->{coltitle}};
			push @loopcell, {value => $value  } ;
		}
		push @looprow,{ 'rowtitle' => ($row eq "zzEMPTY")?"NULL":$row,
						'loopcell' => \@loopcell,
						'hilighted' => ($hilighted >0),
						'totalrow' => $table{$row}->{totalrow}
					};
		$hilighted = -$hilighted;
	}
	
	foreach my $col ( @loopcol ) {
		my $total=0;
		foreach my $row ( @looprow ) {
			$total += $table{($row->{rowtitle} eq "NULL")?"zzEMPTY":$row->{rowtitle}}->{($col->{coltitle} eq "NULL")?"zzEMPTY":$col->{coltitle}};
#			warn "value added ".$table{$row->{rowtitle}}->{$col->{coltitle}}. "for line ".$row->{rowtitle};
		}
#		warn "summ for column ".$col->{coltitle}."  = ".$total;
		push @loopfooter, {'totalcol' => $total};
	}
			

	# the header of the table
	$globalline{loopfilter}=\@loopfilter;
	# the core of the table
	$globalline{looprow} = \@looprow;
 	$globalline{loopcol} = \@loopcol;
# 	# the foot (totals by borrower type)
 	$globalline{loopfooter} = \@loopfooter;
 	$globalline{total}= $grantotal;
	$globalline{line} = $line;
	$globalline{column} = $column;
	push @mainloop,\%globalline;
	return \@mainloop;
}

