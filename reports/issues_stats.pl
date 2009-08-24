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
use Date::Manip;

use C4::Auth;
use C4::Debug;
use C4::Context;
use C4::Branch; # GetBranches
use C4::Koha;
use C4::Output;
use C4::Circulation;
use C4::Reports;
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Members;

=head1 NAME

plugin that shows circulation stats

=head1 DESCRIPTION

=over 2

=cut

# my $debug = 1;	# override for now.
my $input = new CGI;
my $fullreportname = "reports/issues_stats.tmpl";
my $do_it    = $input->param('do_it');
my $line     = $input->param("Line");
my $column   = $input->param("Column");
my @filters  = $input->param("Filter");
$filters[0]=format_date_in_iso($filters[0]);
$filters[1]=format_date_in_iso($filters[1]);
my $podsp    = $input->param("DisplayBy");
my $type     = $input->param("PeriodTypeSel");
my $daysel   = $input->param("PeriodDaySel");
my $monthsel = $input->param("PeriodMonthSel");
my $calc     = $input->param("Cellvalue");
my $output   = $input->param("output");
my $basename = $input->param("basename");
my $mime     = $input->param("MIME");
my ($template, $borrowernumber, $cookie) = get_template_and_user({
	template_name => $fullreportname,
	query => $input,
	type => "intranet",
	authnotrequired => 0,
	flagsrequired => {reports => 1},
	debug => 0,
});
our $sep     = $input->param("sep");
$sep = "\t" if ($sep eq 'tabulation');
$template->param(do_it => $do_it,
	DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(),
);

my $itemtypes = GetItemTypes();
my $categoryloop = GetBorrowercategoryList;

my $ccodes    = GetKohaAuthorisedValues("items.ccode");
my $locations = GetKohaAuthorisedValues("items.location");

my $Bsort1 = GetAuthorisedValues("Bsort1");
my $Bsort2 = GetAuthorisedValues("Bsort2");
my ($hassort1,$hassort2);
$hassort1=1 if $Bsort1;
$hassort2=1 if $Bsort2;


if ($do_it) {
# Displaying results
	my $results = calculate($line, $column, $podsp, $type, $daysel, $monthsel, $calc, \@filters);
	if ($output eq "screen"){
# Printing results to screen
		$template->param(mainloop => $results);
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
		foreach my $col ( @$cols ) {
			print $col->{coltitle}.$sep;
		}
		print "Total\n";
# Table
		foreach my $line ( @$lines ) {
			my $x = $line->{loopcell};
			print $line->{rowtitle}.$sep;
			print map {$_->{value}.$sep} @$x;
			print $line->{totalrow}, "\n";
		}
# footer
        print "TOTAL";
        $cols = @$results[0]->{loopfooter};
		print map {$sep.$_->{totalcol}} @$cols;
        print $sep.@$results[0]->{total};
	}
	exit(1); # exit either way after $do_it
}

my $dbh = C4::Context->dbh;
my @values;
my %labels;
my %select;

# create itemtype arrayref for <select>.
my @itemtypeloop;
for my $itype ( sort {$itemtypes->{$a}->{description} cmp $itemtypes->{$b}->{description}} keys(%$itemtypes)) {
	push @itemtypeloop, { code => $itype , description => $itemtypes->{$itype}->{description} } ;
}

    # location list
my @locations;
foreach (sort keys %$locations) {
	push @locations, { code => $_, description => "$_ - " . $locations->{$_} };
}
    
my @ccodes;
foreach (sort {$ccodes->{$a} cmp $ccodes->{$b}} keys %$ccodes) {
	push @ccodes, { code => $_, description => $ccodes->{$_} };
}

# various
my @mime = (C4::Context->preference("MIME"));

my $CGIextChoice=CGI::scrolling_list(
	-name     => 'MIME',
	-id       => 'MIME',
	-values   => \@mime,
	-size     => 1,
	-multiple => 0 );
    
my $CGIsepChoice=GetDelimiterChoices;
 
$template->param(
	categoryloop => $categoryloop,
	itemtypeloop => \@itemtypeloop,
	locationloop => \@locations,
	   ccodeloop => \@ccodes,
	  branchloop => GetBranchesLoop(C4::Context->userenv->{'branch'}),
	hassort1=> $hassort1,
	hassort2=> $hassort2,
	Bsort1 => $Bsort1,
	Bsort2 => $Bsort2,
	CGIextChoice => $CGIextChoice,
	CGIsepChoice => $CGIsepChoice,
);
output_html_with_http_headers $input, $cookie, $template->output;

sub calculate {
	my ($line, $column, $dsp, $type,$daysel,$monthsel ,$process, $filters) = @_;
	my @loopfooter;
	my @loopcol;
	my @loopline;
	my @looprow;
	my %globalline;
	my $grantotal =0;
# extract parameters
	my $dbh = C4::Context->dbh;

# Filters
# Checking filters
#
	my @loopfilter;
	for (my $i=0;$i<=10;$i++) {
		my %cell;
		(@$filters[$i]) or next;
        if (($i==1) and (@$filters[$i-1])) {
            $cell{err} = 1 if (@$filters[$i]<@$filters[$i-1]) ;
        }
            # format the dates filters, otherwise just fill as is
        if ($i>=2) {
          	$cell{filter} = @$filters[$i];
        } else {
          	$cell{filter} = format_date(@$filters[$i]);
		}
		$cell{crit} = 
		($i==0) ? "Period From"        :
		($i==1) ? "Period To"          :
		($i==2) ? "Patron Category ="  :
		($i==3) ? "Item Type ="        :
		($i==4) ? "Library ="          :
		($i==5) ? "Collection ="       :
		($i==6) ? "Location ="         :
		($i==7) ? "Item callnumber >=" :
		($i==8) ? "Item callnumber <"  :
		($i==9) ? "sort1 ="            :
		($i==10)? "sort2 ="            : "UNKNOWN FILTER ($i)";
		# FIXME - no translation mechanism !
		push @loopfilter, \%cell;
    }
	push @loopfilter,{crit=>"Event",       filter=>$type    };
	push @loopfilter,{crit=>"Display by",  filter=>$dsp     } if ($dsp);
	push @loopfilter,{crit=>"Select Day",  filter=>$daysel  } if ($daysel);
	push @loopfilter,{crit=>"Select Month",filter=>$monthsel} if ($monthsel);

	my @linefilter;
	$debug and warn "filtres ". join "|", @filters;
	my ($colsource, $linesource);
	$linefilter[1] = @$filters[1] if ($line =~ /datetime/);
	$linefilter[0] = ($line =~ /datetime/) ? @$filters[0]  :
					 ($line =~ /category/) ? @$filters[2]  :
					 ($line =~ /itemtype/) ? @$filters[3]  :
					 ($line =~ /branch/  ) ? @$filters[4]  :
					 ($line =~ /ccode/   ) ? @$filters[5]  :
					 ($line =~ /location/) ? @$filters[6]  :
					 ($line =~ /sort1/   ) ? @$filters[9]  :
					 ($line =~ /sort2/   ) ? @$filters[10] : undef ;
	if ($line =~ /ccode/ or $line =~ /location/) {
		$linesource = 'items';
	}

	my @colfilter;
	$colfilter[1] = @$filters[1] if ($column =~ /datetime/);
	$colfilter[0] = ($column =~ /datetime/) ? @$filters[0]  :
					($column =~ /category/) ? @$filters[2]  :
					($column =~ /itemtype/) ? @$filters[3]  :
					($column =~ /branch/  ) ? @$filters[4]  :
					($column =~ /ccode/   ) ? @$filters[5]  :
					($column =~ /location/) ? @$filters[6]  :
					($column =~ /sort1/   ) ? @$filters[9]  :
					($column =~ /sort1/   ) ? @$filters[10] : undef ;
	if ($column =~ /ccode/ or $column =~ /location/) {
		$colsource = 'items';
	}
# 1st, loop rows.
	my $linefield;
	if ($line =~ /datetime/) {
		# by Day, Month or Year (1,2,3 respectively)
		$linefield = ($dsp == 1) ? "  dayname($line)" :
					 ($dsp == 2) ? "monthname($line)" :
					 ($dsp == 3) ? "     Year($line)" :
					'date_format(`datetime`,"%Y-%m-%d")'; # Probably should be left alone or passed through C4::Dates
	} else {
		$linefield = $line;
	}
	my $lineorder = ($linefield =~ /dayname/) ? "weekday($line)" :
					($linefield =~ /^month/ ) ? "  month($line)" : $linefield;

	my $strsth = "SELECT distinctrow $linefield FROM statistics, ";
		# get stats on items if ccode or location, otherwise borrowers.
	$strsth .= ($linesource eq 'items' ) ?
			" items     WHERE (statistics.itemnumber=items.itemnumber) " :
			" borrowers WHERE (statistics.borrowernumber=borrowers.borrowernumber) ";
	$strsth .= " AND $line is not null ";

	if ($line =~ /datetime/) {
		if ($linefilter[1] and ($linefilter[0])) {
			$strsth .= " AND $line between ? AND ? ";
		} elsif ($linefilter[1]) {
			$strsth .= " AND $line < ? ";
		} elsif ($linefilter[0]) {
		$strsth .= " AND $line > ? ";
		}
		$strsth .= " AND type ='".$type."' " if $type;
		$strsth .= " AND   dayname(datetime) ='".   $daysel ."' " if $daysel;
		$strsth .= " AND monthname(datetime) ='". $monthsel ."' " if $monthsel;
	} elsif ($linefilter[0]) {
		$linefilter[0] =~ s/\*/%/g;
		$strsth .= " AND $line LIKE ? ";
	}
	$strsth .=" group by $linefield order by $lineorder ";
	$debug and warn $strsth;
	push @loopfilter, {crit=>'SQL =', sql=>1, filter=>$strsth};
	my $sth = $dbh->prepare( $strsth );
	if ((@linefilter) and ($linefilter[1])){
		$sth->execute($linefilter[0],$linefilter[1]);
	} elsif ($linefilter[0]) {
		$sth->execute($linefilter[0]);
	} else {
		$sth->execute;
	}

	while (my ($celvalue) = $sth->fetchrow) {
		my %cell = (rowtitle => $celvalue, totalrow => 0); # we leave 'rowtitle' as hash key (used when filling the table), and add coltitle_display
		$cell{rowtitle_display} =
			($line =~ /ccode/   ) ? $ccodes->{$celvalue}    :
			($line =~ /location/) ? $locations->{$celvalue} :
			($line =~ /itemtype/) ? $itemtypes->{$celvalue}->{description} :
			$celvalue; # default fallback
		if ($line =~ /sort1/) {
			foreach (@$Bsort1) {
				($celvalue eq $_->{authorised_value}) or next;
				$cell{rowtitle_display} = $_->{lib} and last;
			}
		} elsif ($line =~ /sort2/) {
			foreach (@$Bsort2) {
				($celvalue eq $_->{authorised_value}) or next;
				$cell{rowtitle_display} = $_->{lib} and last;
			}
		} elsif ($line =~ /category/) {
			foreach (@$categoryloop) {
				($celvalue eq $_->{categorycode}) or next;
				$cell{rowtitle_display} = $_->{description} and last;
			}
		}
		push @loopline, \%cell;
	}

# 2nd, loop cols.
	my $colfield;
	my $colorder;
	if ($column =~ /datetime/) {
		#Display by Day, Month or Year (1,2,3 respectively)
		$colfield = ($dsp == 1) ? "  dayname($column)" :
					($dsp == 2) ? "monthname($column)" :
					($dsp == 3) ? "     Year($column)" :
					'date_format(`datetime`,"%Y-%m-%d")'; # Probably should be left alone or passed through C4::Dates
	} else {
		$colfield = $column;
	}
	$colorder = ($colfield =~ /dayname/) ? "weekday($column)" :
				($colfield =~ /^month/ ) ? "  month($column)" : $colfield;
	my $strsth2 = "SELECT distinctrow $colfield FROM statistics, ";
	# get stats on items if ccode or location, otherwise borrowers.
	$strsth2 .= ($colsource eq 'items' ) ?
				"items     WHERE (statistics.itemnumber=items.itemnumber) " :
				"borrowers WHERE (statistics.borrowernumber=borrowers.borrowernumber) ";
	$strsth2 .= " AND $column IS NOT NULL ";

	if ($column =~ /datetime/){
        if (($colfilter[1]) and ($colfilter[0])){
			$strsth2 .= " AND $column BETWEEN ? AND ? " ;
        } elsif ($colfilter[1]) {
			$strsth2 .= " AND $column < ? " ;
        } elsif ($colfilter[0]) {
			$strsth2 .= " AND $column > ? " ;
        }
        $strsth2 .= " AND                type ='". $type     ."' " if $type;
        $strsth2 .= " AND   dayname(datetime) ='". $daysel   ."' " if $daysel;
        $strsth2 .= " AND monthname(datetime) ='". $monthsel ."' " if $monthsel;
    } elsif ($colfilter[0]) {
        $colfilter[0] =~ s/\*/%/g;
        $strsth2 .= " AND $column LIKE ? " ;
    }
	$strsth2 .=" GROUP BY $colfield ORDER BY $colorder ";

	my $sth2 = $dbh->prepare($strsth2);
	push @loopfilter, {crit=>'SQL =', sql=>1, filter=>$strsth2};
	if ((@colfilter) and ($colfilter[1])){
		$sth2->execute($colfilter[0], $colfilter[1]);
	} elsif ($colfilter[0]) {
		$sth2->execute($colfilter[0]);
	} else {
		$sth2->execute;
	}

	while (my ($celvalue) = $sth2->fetchrow) {
		my %cell = (coltitle => $celvalue); # we leave 'coltitle' as hash key (used when filling the table), and add coltitle_display
		$cell{coltitle_display} =
			($column =~ /ccode/   ) ?    $ccodes->{$celvalue} :
			($column =~ /location/) ? $locations->{$celvalue} :
			($column =~ /itemtype/) ? $itemtypes->{$celvalue}->{description} :
			$celvalue; # default fallback
		if ($column =~ /sort1/) {
			foreach (@$Bsort1) {
				($celvalue eq $_->{authorised_value}) or next;
				$cell{coltitle_display} = $_->{lib} and last;
			}
		} elsif ($column =~ /sort2/) {
			foreach (@$Bsort2) {
				($celvalue eq $_->{authorised_value}) or next;
				$cell{coltitle_display} = $_->{lib} and last;
			}
		} elsif ($column =~ /category/) {
			foreach (@$categoryloop) {
				($celvalue eq $_->{categorycode}) or next;
				$cell{coltitle_display} = $_->{description} and last;
			}
		}
		push @loopcol, \%cell;
	}

	#Initialization of cell values.....
	my %table;
	foreach my $row (@loopline) {
		foreach my $col (@loopcol) {
			$debug and warn " init table : $row->{rowtitle} ( $row->{rowtitle_display} ) / $col->{coltitle} ( $col->{coltitle_display} )  ";
			$table{$row->{rowtitle}}->{$col->{coltitle}} = 0;
		}
		$table{$row->{rowtitle}}->{totalrow} = 0;
	}

# preparing calculation
    my $strcalc = "SELECT $linefield, $colfield, ";
        $strcalc .= ($process == 1) ? " COUNT(*) "                                 :
					($process == 2) ? "(COUNT(DISTINCT borrowers.borrowernumber))" :
        			($process == 3) ? "(COUNT(DISTINCT statistics.itemnumber))"        : '';
	if ($process == 4) {
		my $rqbookcount = $dbh->prepare("SELECT count(*) FROM items");
		$rqbookcount->execute;
		my ($bookcount) = $rqbookcount->fetchrow;
		$strcalc .= "100*(COUNT(DISTINCT statistics.itemnumber))/ $bookcount " ;
	}
	$strcalc .= "
        FROM statistics
        LEFT JOIN borrowers ON statistics.borrowernumber=borrowers.borrowernumber
	";
	$strcalc .= "LEFT JOIN items ON statistics.itemnumber=items.itemnumber "
        if ($linefield =~ /^items\./ or $colfield =~ /^items\./ or ($colsource eq 'items')
            ||@$filters[5]||@$filters[6]||@$filters[7]||@$filters[8]);
        
	$strcalc .= "WHERE 1=1 ";
	@$filters = map {defined($_) and s/\*/%/g; $_} @$filters;
	$strcalc .= " AND statistics.datetime > '"       . @$filters[0] ."'" if (@$filters[0] );
	$strcalc .= " AND statistics.datetime < '"       . @$filters[1] ."'" if (@$filters[1] );
	$strcalc .= " AND borrowers.categorycode LIKE '" . @$filters[2] ."'" if (@$filters[2] );
	$strcalc .= " AND statistics.itemtype LIKE '"    . @$filters[3] ."'" if (@$filters[3] );
	$strcalc .= " AND statistics.branch LIKE '"      . @$filters[4] ."'" if (@$filters[4] );
	$strcalc .= " AND items.ccode LIKE '"            . @$filters[5] ."'" if (@$filters[5] );
	$strcalc .= " AND items.location LIKE '"         . @$filters[6] ."'" if (@$filters[6] );
	$strcalc .= " AND items.itemcallnumber >='"      . @$filters[7] ."'" if (@$filters[7] );
	$strcalc .= " AND items.itemcallnumber <'"       . @$filters[8] ."'" if (@$filters[8] );
	$strcalc .= " AND borrowers.sort1 LIKE '"        . @$filters[9] ."'" if (@$filters[9] );
	$strcalc .= " AND borrowers.sort2 LIKE '"        . @$filters[10]."'" if (@$filters[10]);
	$strcalc .= " AND dayname(datetime) LIKE '"      . $daysel      ."'" if ($daysel  );
	$strcalc .= " AND monthname(datetime) LIKE '"    . $monthsel    ."'" if ($monthsel);
	$strcalc .= " AND statistics.type LIKE '"        . $type        ."'" if ($type    );

	$strcalc .= " GROUP BY $linefield, $colfield order by $lineorder,$colorder";
	($debug) and warn $strcalc;
	my $dbcalc = $dbh->prepare($strcalc);
	push @loopfilter, {crit=>'SQL =', sql=>1, filter=>$strcalc};
	$dbcalc->execute;
	my ($emptycol,$emptyrow); 
	while (my ($row, $col, $value) = $dbcalc->fetchrow) {
		($debug) and warn "filling table $row / $col / $value ";
		unless (defined $col) {
			$emptycol = 1; 
			$col = "zzEMPTY" ;
		}
		unless (defined $row) {
			$emptyrow = 1;
			$row = "zzEMPTY"; 
		}
		$table{$row}->{$col}     += $value;
		$table{$row}->{totalrow} += $value;
		$grantotal += $value;
	}
	push @loopcol, {coltitle => "NULL", coltitle_display => 'NULL'} if ($emptycol);
	push @loopline,{rowtitle => "NULL", rowtitle_display => 'NULL'} if ($emptyrow);

	foreach my $row (@loopline) {
		my @loopcell;
		#@loopcol ensures the order for columns is common with column titles
		# and the number matches the number of columns
		foreach my $col (@loopcol) {
			my $value = $table{null_to_zzempty($row->{rowtitle})}->{null_to_zzempty($col->{coltitle})};
			push @loopcell, {value => $value};
		}
		my $rowtitle = ($row->{rowtitle} eq "NULL") ? "zzEMPTY" : $row->{rowtitle};
		push @looprow, {
			'rowtitle_display' => $row->{rowtitle_display},
			'rowtitle' => $rowtitle,
			'loopcell' => \@loopcell,
			'totalrow' => $table{$rowtitle}->{totalrow}
		};
	}
	for my $col ( @loopcol ) {
		my $total = 0;
		foreach my $row (@looprow) {
			$total += $table{null_to_zzempty($row->{rowtitle})}->{null_to_zzempty($col->{coltitle})};
			$debug and warn "value added ".$table{$row->{rowtitle}}->{$col->{coltitle}}. "for line ".$row->{rowtitle};
		}
		push @loopfooter, {'totalcol' => $total};
	}

	# the header of the table
	$globalline{loopfilter}=\@loopfilter;
	# the core of the table
	$globalline{looprow} = \@looprow;
	$globalline{loopcol} = \@loopcol;
	# 	# the foot (totals by borrower type)
	$globalline{loopfooter} = \@loopfooter;
	$globalline{total}  = $grantotal;
	$globalline{line}   = $line;
	$globalline{column} = $column;
	return [(\%globalline)];
}

sub null_to_zzempty ($) {
	my $string = shift;
	defined($string)    or  return 'zzEMPTY';
	($string eq "NULL") and return 'zzEMPTY';
	return $string;		# else return the valid value
}

1;
