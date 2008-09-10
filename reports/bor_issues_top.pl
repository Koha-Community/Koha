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
use C4::Output;
use C4::Context;
use C4::Branch; # GetBranches
use C4::Koha;
use C4::Circulation;
use C4::Members;
use C4::Reports;
use C4::Debug;
use C4::Dates qw(format_date format_date_in_iso);

=head1 NAME

plugin that shows a stats on borrowers

=head1 DESCRIPTION

=over 2

=cut

$debug = 1;
$debug and open DEBUG, ">/tmp/bor_issues_top.debug.log";

my $input = new CGI;
my $fullreportname = "reports/bor_issues_top.tmpl";
my $do_it   = $input->param('do_it');
my $limit   = $input->param("Limit");
my $column  = $input->param("Criteria");
my @filters = $input->param("Filter");
foreach ( @filters[0..3] ) {
	$_ and $_ = format_date_in_iso($_);	
}
my $output   = $input->param("output");
my $basename = $input->param("basename");
# my $mime     = $input->param("MIME");
my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => $fullreportname,
                query => $input,
                type => "intranet",
                authnotrequired => 0,
                flagsrequired => {reports => 1},
                debug => 1,
                });
our $sep     = $input->param("sep");
$sep = "\t" if ($sep eq 'tabulation');
$template->param(do_it => $do_it,
        DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(),
        );
if ($do_it) {
# Displaying results
    my $results = calculate($limit, $column, \@filters);
    if ($output eq "screen"){
# Printing results to screen
        $template->param(mainloop => $results, limit=>$limit);
        output_html_with_http_headers $input, $cookie, $template->output;
    } else {
# Printing to a csv file
        print $input->header(-type => 'application/vnd.sun.xml.calc',
                            -encoding    => 'utf-8',
                            -attachment=>"$basename.csv",
                            -filename=>"$basename.csv" );
        my $cols  = @$results[0]->{loopcol};
        my $lines = @$results[0]->{looprow};
# header top-right
        print @$results[0]->{line} ."/". @$results[0]->{column} .$sep;
# Other header
		print join($sep, map {$_->{coltitle}} @$cols);
        print $sep . "Total\n";
# Table
        foreach my $line ( @$lines ) {
            my $x = $line->{loopcell};
            print $line->{rowtitle}.$sep;
			print join($sep, map {$_->{value}} @$x);
            print $sep,$line->{totalrow};
            print "\n";
        }
# footer
        print "TOTAL";
        $cols = @$results[0]->{loopfooter};
		print join($sep, map {$_->{totalcol}} @$cols);
        print $sep.@$results[0]->{total};
    }
    exit(1);
}

my $dbh = C4::Context->dbh;
my @values;

# here each element returned by map is a hashref, get it?
my @mime  = ( map { +{type =>$_} } (split /[;:]/,C4::Context->preference("MIME")) );
my $delims = GetDelimiterChoices;
my $branches = GetBranches;
my @branchloop;
foreach (sort keys %$branches) {
# 	my $selected = 1 if $thisbranch eq $branch;
	my %row = ( value => $_,
#				selected => $selected,
				branchname => $branches->{$_}->{branchname},
			);
	push @branchloop, \%row;
}

my $itemtypes = GetItemTypes;
my @itemtypeloop;
foreach (sort {$itemtypes->{$a}->{description} cmp $itemtypes->{$b}->{description}} keys %$itemtypes) {
	my %row = (value => $_,
               description => $itemtypes->{$_}->{description},
              );
    push @itemtypeloop, \%row;
}
    
my ($codes,$labels) = GetborCatFromCatType(undef,undef);
my @borcatloop;
foreach (sort keys %$labels) {
	my %row =(value => $_,
              description => $labels->{$_},
             );
    push @borcatloop, \%row;
}
    
$template->param(
	    mimeloop => \@mime,
	  CGIseplist => $delims,
	  branchloop => \@branchloop,
	itemtypeloop => \@itemtypeloop,
	  borcatloop => \@borcatloop,
);
output_html_with_http_headers $input, $cookie, $template->output;


sub calculate {
    my ($line, $column, $filters) = @_;
    my @loopcol;
    my @loopline;
    my @looprow;
    my %globalline;
	my %columns;
    my $grantotal =0;
    my $dbh = C4::Context->dbh;

# Checking filters
    my @loopfilter;
	my @cellmap = (
		"Issue From",
		"Issue To",
		"Return From",
		"Return To",
		"Branch",
		"Doc Type",
		"Bor Cat",
		"Day",
		"Month",
		"Year"
	);
    for (my $i=0;$i<=6;$i++) {
        my %cell;
        if ( @$filters[$i] ) {
            if (($i==1) and (@$filters[$i-1])) {
                $cell{err} = 1 if (@$filters[$i]<@$filters[$i-1]) ;
            }
            # format the dates filters, otherwise just fill as is
            $cell{filter} .= ($i>=4) ? @$filters[$i] : format_date(@$filters[$i]);
			defined ($cellmap[$i]) and
				$cell{crit} .= $cellmap[$i];
            push @loopfilter, \%cell;
        }
    }
    my $colfield;
    my $colorder;
    if ($column){
        $column = "old_issues." .$column if (($column=~/branchcode/) or ($column=~/timestamp/));
        $column = "biblioitems.".$column if $column=~/itemtype/;
        $column = "borrowers."  .$column if $column=~/categorycode/;
        my @colfilter ;
		if ($column =~ /timestamp/) {
        	$colfilter[0] = @$filters[0];
       		$colfilter[1] = @$filters[1];
		} elsif ($column =~ /returndate/) {
        	$colfilter[0] = @$filters[2];
        	$colfilter[1] = @$filters[3];
		} elsif ($column =~ /branchcode/) {
			$colfilter[0] = @$filters[4];
		} elsif ($column =~ /itemtype/) {
			$colfilter[0] = @$filters[5];
		} elsif ($column =~ /category/) {
			$colfilter[0] = @$filters[6];
		} elsif ($column =~ /sort2/   ) {
			# $colfilter[0] = @$filters[11];
		}
        # $colfilter[0] = @$filters[7] if ($column =~ /timestamp/ ) ; FIXME This can't be right.
        # $colfilter[0] = @$filters[8] if ($column =~ /timestamp/ ) ; FIXME 
        # $colfilter[0] = @$filters[9] if ($column =~ /timestamp/ ) ; FIXME Only this line would have effect.

    #warn "filtre col ".$colfilter[0]." ".$colfilter[1];
                                                
    # loop cols.
        if ($column eq "Day") {
            #Display by day
            $column = "old_issues.timestamp";
            $colfield .="dayname($column)";  
            $colorder .="weekday($column)";
        } elsif ($column eq "Month") {
            #Display by Month
            $column = "old_issues.timestamp";
            $colfield .="monthname($column)";  
            $colorder .="month($column)";  
        } elsif ($column eq "Year") {
            #Display by Year
            $column = "old_issues.timestamp";
            $colfield .="Year($column)";
            $colorder .= $column;
        } else {
            $colfield .= $column;
            $colorder .= $column;
        }  

        my $strsth2;
        $strsth2 .= "SELECT DISTINCTROW $colfield 
                     FROM `old_issues` 
                     LEFT JOIN borrowers   ON old_issues.borrowernumber=borrowers.borrowernumber 
                     LEFT JOIN items       ON old_issues.itemnumber=items.itemnumber 
                     LEFT JOIN biblioitems ON (biblioitems.biblioitemnumber=items.biblioitemnumber)
                     WHERE 1";
        if (($column=~/timestamp/) or ($column=~/returndate/)){
            if ($colfilter[1] and $colfilter[0]){
                $strsth2 .= " AND $column between '$colfilter[0]' AND '$colfilter[1]' " ;
            } elsif ($colfilter[1]) {
                $strsth2 .= " AND $column < '$colfilter[1]' " ;
            } elsif ($colfilter[0]) {
                $strsth2 .= " AND $column > '$colfilter[0]' " ;
            }
        } elsif ($colfilter[0]) {
            $colfilter[0] =~ s/\*/%/g;
            $strsth2 .= " AND $column LIKE '$colfilter[0]' " ;
        }
        $strsth2 .=" GROUP BY $colfield";
        $strsth2 .=" ORDER BY $colorder";

        $debug and print DEBUG "bor_issues_top (old_issues) SQL: $strsth2\n";
        my $sth2 = $dbh->prepare($strsth2);
        $sth2->execute;
        print DEBUG "rows: ", $sth2->rows, "\n";
        while (my @row = $sth2->fetchrow) {
			$columns{($row[0] ||'NULL')}++;
            push @loopcol, +{ coltitle => $row[0] || 'NULL' };
        }

		$strsth2 =~ s/old_issues/issues/g;
        $debug and print DEBUG "bor_issues_top (issues) SQL: $strsth2\n";
		$sth2 = $dbh->prepare($strsth2);
        $sth2->execute;
        $debug and print DEBUG "rows: ", $sth2->rows, "\n";
        while (my @row = $sth2->fetchrow) {
			$columns{($row[0] ||'NULL')}++;
            push @loopcol, +{ coltitle => $row[0] || 'NULL' };
        }
		$debug and print DEBUG "full array: ", Dumper(\%columns), "\n";
    }

    #Initialization of cell values.....
    my @table;
    for (my $i=1;$i<=$line;$i++) {
        foreach (keys %columns) {
#			warn " init table : $row->{rowtitle} / $_ ";
            $table[$i]->{ $_ || "total" }->{'name'}=0;
        }
    }

    my $strcalc ;

# Processing average loanperiods
    $strcalc .= "SELECT  CONCAT(borrowers.surname , \",\\t\",borrowers.firstname),  COUNT(*) AS RANK, borrowers.borrowernumber AS ID";
    $strcalc .= " , $colfield " if ($colfield);
    $strcalc .= " FROM `old_issues`
                  LEFT JOIN  borrowers  ON old_issues.borrowernumber=borrowers.borrowernumber
                  LEFT JOIN    items    ON items.itemnumber=old_issues.itemnumber
                  LEFT JOIN biblioitems ON (biblioitems.biblioitemnumber=items.biblioitemnumber)
                  WHERE 1";
	my @filterterms = (
		'old_issues.timestamp  >',
		'old_issues.timestamp  <',
		'old_issues.returndate >',
		'old_issues.returndate <',
		'old_issues.branchcode  like',
		'biblioitems.itemtype   like',
		'borrowers.categorycode like',
		'dayname(old_issues.timestamp) like',
		'monthname(old_issues.timestamp) like',
		'monthname(old_issues.timestamp) like',
		'year(old_issues.timestamp) like',
	);
    foreach ((@$filters)[0..9]) {
		my $term = shift @filterterms;	# go through both arrays in step
		($_) or next;
		s/\*/%/g;
		$strcalc .= " AND $term '$_' ";
	}
    
    $strcalc .= " GROUP BY borrowers.borrowernumber";
    $strcalc .= ", $colfield" if ($column);
    $strcalc .= " ORDER BY RANK DESC";
    $strcalc .= ",$colfield " if ($colfield);
# 	my $max;
# 	if (@loopcol) {
# 		$max = $line*@loopcol;
# 	} else { $max=$line;}
# 	$strcalc .= " LIMIT 0,$max";

    $debug and print DEBUG "(old_issues) SQL : $strcalc\n";
    my $dbcalc = $dbh->prepare($strcalc);
    $dbcalc->execute;
    $debug and print DEBUG "rows: ", $dbcalc->rows, "\n";
	my %patrons = ();
	# DATA STRUCTURE is going to look like this:
	# 	(2253=> {name=>"John Doe",
	# 				allcols=>{MAIN=>12, MEDIA_LIB=>3}
	# 			},
	# 	)
    while (my @data = $dbcalc->fetchrow) {
        my ($row, $rank, $id, $col) = @data;
        $col = "zzEMPTY" if (!defined($col));
		unless ($patrons{$id}) {
			$patrons{$id} = {name=>$row, allcols=>{}, newcols=>{}, oldcols=>{}};
		}
		$patrons{$id}->{oldcols}->{$col} = $rank;
    }

	use Data::Dumper;

	$strcalc =~ s/old_issues/issues/g;
    $debug and print DEBUG "(issues) SQL : $strcalc\n";
    $dbcalc = $dbh->prepare($strcalc);
    $dbcalc->execute;
    $debug and print DEBUG "rows: ", $dbcalc->rows, "\n";
    while (my @data = $dbcalc->fetchrow) {
        my ($row, $rank, $id, $col) = @data;
        $col = "zzEMPTY" if (!defined($col));
		unless ($patrons{$id}) {
			$patrons{$id} = {name=>$row, allcols=>{}, newcols=>{}, oldcols=>{}};
		}
		$patrons{$id}->{newcols}->{$col} = $rank;
    }

	foreach my $id (keys %patrons) {
		my @uniq = keys %{{ %{$patrons{$id}->{newcols}}, %{$patrons{$id}->{oldcols}} }};		# get uniq keys, see perlfaq4
		foreach (@uniq) {
			my $count = ($patrons{$id}->{newcols}->{$_} || 0) +
						($patrons{$id}->{oldcols}->{$_} || 0);
			$patrons{$id}->{allcols}->{$_} = $count;
			$patrons{$id}->{total} += $count;
		}
	}
    $debug and print DEBUG "\n\npatrons: ", Dumper(\%patrons);
    
	my $i = 1;
	my @cols_in_order = sort keys %columns;		# if you want to order the columns, do something here
	my @ranked_ids = sort {
						   $patrons{$b}->{total} <=> $patrons{$a}->{total}
						|| $patrons{$a}->{name}  cmp $patrons{$b}->{name}
						} keys %patrons;
    foreach my $id (@ranked_ids) {
        my @loopcell;
        foreach my $key (@cols_in_order) {
            push @loopcell, {
				value => $patrons{$id}->{name},
				count => $patrons{$id}->{allcols}->{$key},
				reference => $id,
			};
        }
        push @looprow,{ 'rowtitle' => $i++ ,
                        'loopcell' => \@loopcell,
                        'hilighted' => ($i%2),
                    };
    }
	
    # the header of the table
    $globalline{loopfilter}=\@loopfilter;
    # the core of the table
    $globalline{looprow} = \@looprow;
    $globalline{loopcol} = [ map {+{coltitle=>$_}} @cols_in_order ];
 	# the foot (totals by borrower type)
    $globalline{loopfooter} = [];
    $globalline{total}= $grantotal;		# FIXME: useless
    $globalline{line} = $line;
    $globalline{column} = $column;
    return [\%globalline];	# reference to a 1 element array: that element is a hashref
}

$debug and close DEBUG;
1;
__END__
