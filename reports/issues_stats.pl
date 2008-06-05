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
use C4::Branch; # GetBranches
use C4::Koha;
use C4::Output;
use C4::Circulation;
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Members;
use Date::Manip;

=head1 NAME

plugin that shows a stats on borrowers

=head1 DESCRIPTION

=over 2

=cut

my $debug = 1;
my $input = new CGI;
my $do_it=$input->param('do_it');
my $fullreportname = "reports/issues_stats.tmpl";
my $line = $input->param("Line");
my $column = $input->param("Column");
my @filters = $input->param("Filter");
$filters[0]=format_date_in_iso($filters[0]);
$filters[1]=format_date_in_iso($filters[1]);
my $podsp = $input->param("DisplayBy");
my $type = $input->param("PeriodTypeSel");
my $daysel = $input->param("PeriodDaySel");
my $monthsel = $input->param("PeriodMonthSel");
my $calc = $input->param("Cellvalue");
my $output = $input->param("output");
my $basename = $input->param("basename");
my $mime = $input->param("MIME");
my $del = $input->param("sep");
#warn "calcul : ".$calc;
my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => $fullreportname,
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => {reports => 1},
                            debug => 0,
                            });
$template->param(do_it => $do_it,
        DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(),
                );

my $itemtypes = GetItemTypes();
my $categoryloop = GetBorrowercategoryList;

my $ccodes = GetKohaAuthorisedValues("items.ccode");
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
            exit(1);
    } else {
# Printing to a csv file
        print $input->header(-type => 'application/vnd.sun.xml.calc',
                            -encoding    => 'utf-8',
                            -attachment=>"$basename.csv",
                            -filename=>"$basename.csv" );
        my $cols = @$results[0]->{loopcol};
        my $lines = @$results[0]->{looprow};
        my $sep;
        $sep =C4::Context->preference("delimiter");
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
                foreach my $cell (@$x) {
                        print $cell->{value}.$sep;
                }
                print $line->{totalrow};
                print "\n";
        }
# footer
        print "TOTAL";
        $cols = @$results[0]->{loopfooter};
        foreach my $col ( @$cols ) {
                print $sep.$col->{totalcol};
        }
        print $sep.@$results[0]->{total};
        exit(1);
    }
# Displaying choices
} else {
    my $dbh = C4::Context->dbh;
    my @values;
    my %labels;
    my %select;

   # create itemtype arrayref for <select>.
   my @itemtypeloop;
    for my $itype ( keys(%$itemtypes)) {
		push @itemtypeloop, { code => $itype , description => $itemtypes->{$itype}->{description} } ;
	}
    
    my $branches=GetBranches();
	my @branchloop;
    foreach (keys %$branches) {
        my $thisbranch = ''; 
        my %row = (branchcode => $_,
            selected => ($thisbranch eq $_ ? 1 : 0),
            code => $branches->{$_}->{'branchcode'},
            description => $branches->{$_}->{'branchname'},
        );
        push @branchloop, \%row;
    }

    # location list
    my @locations;
    foreach (sort keys %$locations) {
        push @locations, { code => $_, description => "$_ - " . $locations->{$_} };
    }
    
    my @ccodes;
    foreach (keys %$ccodes) {
        push @ccodes, { code => $_, description => $ccodes->{$_} };
    }

    # various
    my @mime = ( C4::Context->preference("MIME") );
    
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
        categoryloop => $categoryloop,
		itemtypeloop => \@itemtypeloop,
		hassort1=> $hassort1,
        hassort2=> $hassort2,
		Bsort1 => $Bsort1,
		Bsort2 => $Bsort2,
        CGIextChoice => $CGIextChoice,
        CGIsepChoice => $CGIsepChoice,
        locationloop => \@locations,
		ccodeloop => \@ccodes,
        branchloop => \@branchloop,
        );
    output_html_with_http_headers $input, $cookie, $template->output;
}




sub calculate {
        my ($line, $column, $dsp, $type,$daysel,$monthsel ,$process, $filters) = @_;
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
# Checking filters
#
        my @loopfilter;
        for (my $i=0;$i<=10;$i++) {
                my %cell;
                if ( @$filters[$i] ) {
                        if (($i==1) and (@$filters[$i-1])) {
                                $cell{err} = 1 if (@$filters[$i]<@$filters[$i-1]) ;
                            }
                        # format the dates filters, otherwise just fill as is
                        if ($i>=2) {
                            $cell{filter} .= @$filters[$i];
                        } else {
                            $cell{filter} .= format_date(@$filters[$i]);
                        }
                        $cell{crit} .="Period From" if ($i==0);
                        $cell{crit} .="Period To" if ($i==1);
                        $cell{crit} .="Patron Category=" if ($i==2);
                        $cell{crit} .="Item Type=" if ($i==3);
                        $cell{crit} .="Library=" if ($i==4);
                        $cell{crit} .="Collection=" if ($i==5);
                        $cell{crit} .="Location=" if ($i==6);
                        $cell{crit} .="Item callnumber>=" if ($i==7);
                        $cell{crit} .="Item callnumber<" if ($i==8);
                        $cell{crit} .="sort1=" if ($i==9);
                        $cell{crit} .="sort2=" if ($i==10);
						# FIXME - no translation mechanism !
                        push @loopfilter, \%cell;
                }
        }
        push @loopfilter,{crit=>"Event",filter=>$type};
        push @loopfilter,{crit=>"Display by ",filter=>$dsp} if ($dsp);
        push @loopfilter,{crit=>"Select Day ",filter=>$daysel} if ($daysel);
        push @loopfilter,{crit=>"Select Month ",filter=>$monthsel} if ($monthsel);
        
        
        my @linefilter;
      $debug and warn "filtres ". join "|", @filters;
        my ($colsource, $linesource);
        $linefilter[0] = @$filters[0] if ($line =~ /datetime/ )  ;
        $linefilter[1] = @$filters[1] if ($line =~ /datetime/ )  ;
		if ($line =~ /category/ )  {
        	$linefilter[0] = @$filters[2] ;
		}
		if ($line =~ /itemtype/ ) {
        	$linefilter[0] = @$filters[3] ;
		}
        $linefilter[0] = @$filters[4] if ($line =~ /branch/ )  ;
		if ($line =~ /ccode/ ) {
        	$linefilter[0] = @$filters[5] ;
			$linesource = 'items';
		}
		if ($line =~ /location/ ) {
        	$linefilter[0] = @$filters[6] ;
			$linesource = 'items';
		}
        $linefilter[0] = @$filters[9] if ($line =~ /sort1/ ) ;
        $linefilter[0] = @$filters[10] if ($line =~ /sort2/ ) ;

        my @colfilter ;
        $colfilter[0] = @$filters[0] if ($column =~ /datetime/) ;
        $colfilter[1] = @$filters[1] if ($column =~ /datetime/) ;
        $colfilter[0] = @$filters[2] if ($column =~ /category/) ;
        $colfilter[0] = @$filters[3] if ($column =~ /itemtype/) ;
        $colfilter[0] = @$filters[4] if ($column =~ /branch/ )  ;
		if ($column =~ /ccode/ ) {
        	$colfilter[0] = @$filters[5] ;
			$colsource = 'items';
		}
		if ($column =~ /location/ ) {
        	$colfilter[0] = @$filters[6] ;
			$colsource = 'items';
		}
        $colfilter[0] = @$filters[9] if ($column =~ /sort1/  )  ;
        $colfilter[0] = @$filters[10] if ($column =~ /sort2/  )  ;
# 1st, loop rows.                             
        my $linefield;                               
        if (($line =~/datetime/) and ($dsp == 1)) {
                #Display by day
                $linefield .="dayname($line)";  
        } elsif (($line=~/datetime/) and ($dsp == 2)) {
                #Display by Month
                $linefield .="monthname($line) ";  
        } elsif (($line=~/datetime/) and ($dsp == 3)) {
                #Display by Year
                $linefield .="Year($line)";
        } elsif ($line=~/datetime/) {
                $linefield .= 'date_format(`datetime`,"%Y-%m-%d")';
        } else {
                $linefield .= $line;
        }  
        my $lineorder = $linefield;
        $lineorder = "weekday($line)" if $linefield =~ /dayname/;
        $lineorder = "month($line)" if $linefield =~ "^month";
        $lineorder = $linefield if (not ($linefield =~ "^month") and not($linefield =~ /dayname/));

        my $strsth;
        $strsth .= "select distinctrow $linefield from statistics, ";
		# get stats on items if ccode or location, otherwise borrowers.
		$strsth .= ($linesource eq 'items' ) ? 
						"items where (statistics.itemnumber=items.itemnumber) " 
						: " borrowers where (statistics.borrowernumber=borrowers.borrowernumber) ";
		$strsth .= " and $line is not null ";
        
        if ($line=~/datetime/) {
                if ($linefilter[1] and ($linefilter[0])){
                        $strsth .= " and $line between ? and ? " ;
                } elsif ($linefilter[1]) {
                                $strsth .= " and $line < ? " ;
                } elsif ($linefilter[0]) {
                        $strsth .= " and $line > ? " ;
                }
                $strsth .= " and type ='".$type."' " if $type;
                $strsth .= " and dayname(datetime) ='". $daysel ."' " if $daysel;
                $strsth .= " and monthname(datetime) ='". $monthsel ."' " if $monthsel;
        } elsif ($linefilter[0]) {
                $linefilter[0] =~ s/\*/%/g;
                $strsth .= " and $line LIKE ? " ;
        }
        $strsth .=" group by $linefield";
        $strsth .=" order by $lineorder";
        $debug and warn $strsth;
        
        my $sth = $dbh->prepare( $strsth );
        if (( @linefilter ) and ($linefilter[1])){
                $sth->execute("'".$linefilter[0]."'","'".$linefilter[1]."'");
        } elsif ($linefilter[0]) {
                $sth->execute($linefilter[0]);
        } else {
                $sth->execute;
        }
        
        while ( my ($celvalue) = $sth->fetchrow) {
                my %cell;
				if($line =~ /ccode/) {
					$cell{rowtitle_display} = $ccodes->{$celvalue};
				} elsif($line=~/location/) {
					 $cell{rowtitle_display} = $locations->{$celvalue};
				} elsif($line=~/sort1/) {
					for my $s (@$Bsort1) {
						$cell{rowtitle_display} = $s->{lib} if ($celvalue eq $s->{authorised_value});
					}
					$cell{rowtitle_display} = $celvalue unless  $cell{rowtitle_display};
				} elsif($line=~/sort2/) {
					for my $s (@$Bsort2) {
						$cell{rowtitle_display} = $s->{lib} if ($celvalue eq $s->{authorised_value});
					}
					$cell{rowtitle_display} = $celvalue unless  $cell{rowtitle_display};
				} elsif($line=~/categorycode/) {
					for my $s (@$categoryloop) { 
						$cell{rowtitle_display} = $s->{description} if ($celvalue eq $s->{categorycode});
					}
					$cell{rowtitle_display} = $celvalue unless  $cell{rowtitle_display};
				} elsif($line=~/itemtype/) {
					$cell{rowtitle_display} = $itemtypes->{$celvalue}->{description};
				} else {
               		$cell{rowtitle_display} = $celvalue;
				}					
                if ($celvalue) {
                        $cell{rowtitle} = $celvalue;
                } else {
                        $cell{rowtitle} = "";
                }
                $cell{totalrow} = 0;
                push @loopline, \%cell;
        }

# 2nd, loop cols.
        my $colfield;
        my $colorder;                               
        if (($column =~/datetime/) and ($dsp == 1)) {
                #Display by day
                $colfield .="dayname($column)";  
        } elsif (($column=~/datetime/) and ($dsp == 2)) {
                #Display by Month
                $colfield .="monthname($column)";  
        } elsif (($column=~/datetime/) and ($dsp == 3)) {
                #Display by Year
                $colfield .="Year($column)";
        } elsif ($column=~/datetime/) {
                $colfield .='date_format(`datetime`,"%Y-%m-%d")';	
        } else {
                $colfield .= $column;
        }  
        $colorder = "weekday($line)" if $colfield =~ "^dayname";
        $colorder = "month($line)" if $colfield =~ "^month";
        $colorder = $colfield if (not ($colfield =~ "^month") and not($colfield =~ "^dayname"));
        
        my $strsth2; 
        $strsth2 .= "select distinctrow $colfield from statistics, ";
		# get stats on items if ccode or location, otherwise borrowers.
		$strsth2 .= ($colsource eq 'items' ) ? 
						"items where (statistics.itemnumber=items.itemnumber) " 
						: " borrowers where (statistics.borrowernumber=borrowers.borrowernumber) ";
		$strsth2 .= " and $column is not null ";
        
        if ($column=~/datetime/){
                if (($colfilter[1]) and ($colfilter[0])){
                        $strsth2 .= " and $column between ? and ? " ;
                } elsif ($colfilter[1]) {
                        $strsth2 .= " and $column < ? " ;
                } elsif ($colfilter[0]) {
                        $strsth2 .= " and $column > ? " ;
                }
                $strsth2 .= " and type ='".$type."' " if $type;
                $strsth2 .= " and dayname(datetime) ='". $daysel ."' " if $daysel;
                $strsth2 .= " and monthname(datetime) ='". $monthsel ."' " if $monthsel;
        } elsif ($colfilter[0]) {
                $colfilter[0] =~ s/\*/%/g;
                $strsth2 .= " and $column LIKE ? " ;
        }
        $strsth2 .=" group by $colfield";
        $strsth2 .=" order by $colorder";
        
        my $sth2 = $dbh->prepare( $strsth2 );
        if (( @colfilter ) and ($colfilter[1])){
                $sth2->execute("'".$colfilter[0]."'","'".$colfilter[1]."'");
        } elsif ($colfilter[0]) {
                $sth2->execute($colfilter[0]);
        } else {
                $sth2->execute;
        }
        

        while (my ($celvalue) = $sth2->fetchrow) {
                my %cell;
                my %ft;
				if($column =~ /ccode/) {
					$cell{coltitle_display} = $ccodes->{$celvalue};
				} elsif($column=~/location/) {
					 $cell{coltitle_display} = $locations->{$celvalue};
				} elsif($column=~/itemtype/) {
					$cell{coltitle_display} = $itemtypes->{$celvalue}->{description};
				} elsif($column=~/sort1/) {
					for my $s (@$Bsort1) {
						$cell{coltitle_display} = $s->{lib} if ($celvalue eq $s->{authorised_value});
					}
					$cell{coltitle_display} = $celvalue unless  $cell{coltitle_display};
				} elsif($column=~/sort2/) {
					for my $s (@$Bsort2) {
						$cell{coltitle_display} = $s->{lib} if ($celvalue eq $s->{authorised_value});
					}
					$cell{coltitle_display} = $celvalue unless  $cell{coltitle_display};
				} elsif($column=~/category/) {
					for my $s (@$categoryloop) {
						$cell{coltitle_display} = $s->{description} if ($celvalue eq $s->{categorycode});
					}
					$cell{coltitle_display} = $celvalue unless  $cell{coltitle_display};
				} else {
               		$cell{coltitle_display} = $celvalue;
				}					
               	$cell{coltitle} = $celvalue;
				# we leave this as 'coltitle' since we use it as hash key when filling the table, and add a title_display key.
                $ft{totalcol} = 0;
                push @loopcol, \%cell;
        }
#	warn "fin des titres colonnes";

        my $i=0;
        my @totalcol;
        
        #Initialization of cell values.....
        my %table;
#	warn "init table";
        foreach my $row ( @loopline ) {
                foreach my $col ( @loopcol ) {
				$debug and warn " init table : $row->{rowtitle} ( $row->{rowtitle_display} ) / $col->{coltitle} ( $col->{coltitle_display} )  ";
                        $table{$row->{rowtitle}}->{$col->{coltitle}}=0;
                }
                $table{$row->{rowtitle}}->{totalrow}=0;
        }

# preparing calculation
        my $strcalc ;

        $strcalc .= "SELECT $linefield, $colfield, ";
        $strcalc .= "COUNT( * ) " if ($process ==1);
        if ($process ==2){
                $strcalc .= "(COUNT(DISTINCT borrowers.borrowernumber))" ;
        }
        if ($process ==3){
                $strcalc .= "(COUNT(DISTINCT issues.itemnumber))" ;
        }
        if ($process ==4){
                my $rqbookcount = $dbh->prepare("SELECT count(*) FROM items");
                $rqbookcount->execute;
                my ($bookcount) = $rqbookcount->fetchrow;
                $strcalc .= "100*(COUNT(DISTINCT issues.itemnumber))/ $bookcount " ;
        }
        $strcalc .= "FROM statistics ";
        $strcalc .= "LEFT JOIN borrowers ON statistics.borrowernumber=borrowers.borrowernumber ";
        $strcalc .= "LEFT JOIN items ON statistics.itemnumber=items.itemnumber " if ( ($colsource eq 'items') || @$filters[5] || @$filters[6] ||@$filters[7] || @$filters[8] );
        
        $strcalc .= "WHERE 1=1 ";
        @$filters[0]=~ s/\*/%/g if (@$filters[0]);
        $strcalc .= " AND statistics.datetime > '" . @$filters[0] ."'" if ( @$filters[0] );
        @$filters[1]=~ s/\*/%/g if (@$filters[1]);
        $strcalc .= " AND statistics.datetime < '" . @$filters[1] ."'" if ( @$filters[1] );
        @$filters[2]=~ s/\*/%/g if (@$filters[2]);
        $strcalc .= " AND borrowers.categorycode like '" . @$filters[2] ."'" if ( @$filters[2] );
        @$filters[3]=~ s/\*/%/g if (@$filters[3]);
        $strcalc .= " AND statistics.itemtype like '" . @$filters[3] ."'" if ( @$filters[3] );
        @$filters[4]=~ s/\*/%/g if (@$filters[4]);
        $strcalc .= " AND statistics.branch like '" . @$filters[4] ."'" if ( @$filters[4] );
        @$filters[5]=~ s/\*/%/g if (@$filters[5]);
        $strcalc .= " AND items.ccode like '" . @$filters[5] ."'" if ( @$filters[5] );
        @$filters[6]=~ s/\*/%/g if (@$filters[6]);
        $strcalc .= " AND items.location like '" . @$filters[6] ."'" if ( @$filters[6] );
        @$filters[7]=~ s/\*/%/g if (@$filters[7]);
        $strcalc .= " AND items.itemcallnumber >='" . @$filters[7] ."'" if ( @$filters[7] );
        @$filters[8]=~ s/\*/%/g if (@$filters[8]);
        $strcalc .= " AND items.itemcallnumber <'" . @$filters[8] ."'" if ( @$filters[8] );
        @$filters[9]=~ s/\*/%/g if (@$filters[9]);
        $strcalc .= " AND borrowers.sort1 like '" . @$filters[9] ."'" if ( @$filters[9] );
        @$filters[10]=~ s/\*/%/g if (@$filters[10]);
        $strcalc .= " AND borrowers.sort2 like '" . @$filters[10] ."'" if ( @$filters[10] );
        $strcalc .= " AND dayname(datetime) like '" . $daysel ."'" if ( $daysel );
        $strcalc .= " AND monthname(datetime) like '" . $monthsel ."'" if ( $monthsel );
        $strcalc .= " AND statistics.type like '" . $type ."'" if ( $type );
        
        $strcalc .= " group by $linefield, $colfield order by $lineorder,$colorder";
        ($debug) and warn "". $strcalc;
        my $dbcalc = $dbh->prepare($strcalc);
        $dbcalc->execute;
# 	warn "filling table";
        my ($emptycol,$emptyrow); 
        while (my ($row, $col, $value) = $dbcalc->fetchrow) {
                ($debug) and warn "filling table $row / $col / $value ";
				if ($col eq undef) {
                	$emptycol = 1; 
                	$col = "zzEMPTY" ;
				}
				if ($row eq undef) {
					$emptyrow = 1;
                	$row = "zzEMPTY"; 
                }
                $table{$row}->{$col}+=$value;
                $table{$row}->{totalrow}+=$value;
                $grantotal += $value;
        }
        push @loopcol,{coltitle => "NULL", coltitle_display => 'NULL'} if ($emptycol);
        push @loopline,{rowtitle => "NULL", rowtitle_display => 'NULL'} if ($emptyrow);

        foreach my $row (@loopline) {
                my @loopcell;
                #@loopcol ensures the order for columns is common with column titles
                # and the number matches the number of columns
                foreach my $col ( @loopcol ) {
                        my $value =$table{($row->{rowtitle} eq "NULL")?"zzEMPTY":$row->{rowtitle}}->{($col->{coltitle} eq "NULL")?"zzEMPTY":$col->{coltitle}};
                        push @loopcell, {value => $value  } ;
                }
                push @looprow,	{ 'rowtitle' => ($row->{rowtitle} eq "NULL")?"zzEMPTY":$row->{rowtitle},
								'rowtitle_display' => ($row->{rowtitle_display} eq "NULL")?"NULL":$row->{rowtitle_display},
                                'loopcell' => \@loopcell,
                                'totalrow' => $table{($row->{rowtitle} eq "NULL")?"zzEMPTY":$row->{rowtitle}}->{totalrow}
                                                };
        }
#	warn "footer processing";
        for my $col ( @loopcol ) {
                my $total=0;
                foreach my $row ( @looprow ) {
                        $total += $table{($row->{rowtitle} eq "NULL")?"zzEMPTY":$row->{rowtitle}}->{($col->{coltitle} eq "NULL")?"zzEMPTY":$col->{coltitle}};
			$debug and warn "value added ".$table{$row->{rowtitle}}->{$col->{coltitle}}. "for line ".$row->{rowtitle};
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

1;
