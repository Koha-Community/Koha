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
use C4::Output;
use C4::Koha;
use C4::Circulation;
use C4::Reports;
use C4::Dates qw/format_date format_date_in_iso/;
use Date::Calc qw(Delta_Days);

=head1 NAME

plugin that shows a stats on borrowers

=head1 DESCRIPTION

=over 2

=cut

my $input = new CGI;
my $do_it=$input->param('do_it');
my $fullreportname = "reports/issues_avg_stats.tmpl";
my $line = $input->param("Line");
my $column = $input->param("Column");
my @filters = $input->param("Filter");
$filters[0]=format_date_in_iso($filters[0]);
$filters[1]=format_date_in_iso($filters[1]);
$filters[2]=format_date_in_iso($filters[2]);
$filters[3]=format_date_in_iso($filters[3]);
my $podsp = $input->param("IssueDisplay");
my $rodsp = $input->param("ReturnDisplay");
my $calc = $input->param("Cellvalue");
my $output = $input->param("output");
my $basename = $input->param("basename");
my $mime = $input->param("MIME");
#warn "calcul : ".$calc;
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
    my $results = calculate($line, $column, $rodsp, $podsp, $calc, \@filters);
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
    my $req;
    $req = $dbh->prepare("select distinctrow categorycode,description from categories order by description");
    $req->execute;
    my @select;
    push @select,"";
    $select{""}="";
    while (my ($value, $desc) =$req->fetchrow) {
        push @select, $value;
        $select{$value}=$desc;
    }
    my $CGIBorCat=CGI::scrolling_list( -name     => 'Filter',
                -id => 'borcat',
                -values   => \@select,
                -labels   => \%select,
                -size     => 1,
                -multiple => 0 );
    
    $req = $dbh->prepare( "select distinctrow itemtype,description from itemtypes order by description");
    $req->execute;
    undef @select;
    undef %select;
    push @select,"";
    $select{""}="";
    while (my ($value,$desc) =$req->fetchrow) {
        push @select, $value;
        $select{$value}=$desc;
    }
    my $CGIItemTypes=CGI::scrolling_list( -name     => 'Filter',
                -id => 'itemtypes',
                -values   => \@select,
                -labels    => \%select,
                -size     => 1,
                -multiple => 0 );
    
    $req = $dbh->prepare("select distinctrow sort1 from borrowers where sort1 is not null order by sort1");
    $req->execute;
    undef @select;
    push @select,"";
    my $hassort1;
    while (my ($value) =$req->fetchrow) {
        $hassort1 =1 if ($value);
        push @select, $value;
    }
    my $branches=GetBranches();
    my @select_branch;
    my %select_branches;
    push @select_branch,"";
    $select_branches{""} = "";
    foreach my $branch (keys %$branches) {
        push @select_branch, $branch;
        $select_branches{$branch} = $branches->{$branch}->{'branchname'};
    }
    my $CGIBranch=CGI::scrolling_list( -name     => 'Filter',
                -id => 'branch',
                -values   => \@select_branch,
                -labels   => \%select_branches,
                -size     => 1,
                -multiple => 0 );
    
    my $CGISort1=CGI::scrolling_list( -name     => 'Filter',
                -id => 'sort1',
                -values   => \@select,
                -size     => 1,
                -multiple => 0 );
    
    $req = $dbh->prepare("select distinctrow sort2 from borrowers where sort2 is not null order by sort2");
    $req->execute;
    undef @select;
    push @select,"";
    my $hassort2;
    my $hglghtsort2;
    while (my ($value) =$req->fetchrow) {
        $hassort2 =1 if ($value);
        $hglghtsort2= !($hassort1);
        push @select, $value;
    }
    my $CGISort2=CGI::scrolling_list( -name     => 'Filter',
                -id => 'sort2',
                -values   => \@select,
                -size     => 1,
                -multiple => 0 );
    
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
    
    my $CGIsepChoice=GetDelimiterChoices;
    
    $template->param(
                    CGIBorCat => $CGIBorCat,
                    CGIItemType => $CGIItemTypes,
                    CGIBranch => $CGIBranch,
                    hassort1=> $hassort1,
                    hassort2=> $hassort2,
                    HlghtSort2 => $hglghtsort2,
                    CGISort1 => $CGISort1,
                    CGISort2 => $CGISort2,
                    CGIextChoice => $CGIextChoice,
                    CGIsepChoice => $CGIsepChoice
                    );
output_html_with_http_headers $input, $cookie, $template->output;
}




sub calculate {
    my ($line, $column, $rodsp, $podsp, $process, $filters) = @_;
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
    for (my $i=0;$i<=6;$i++) {
        my %cell;
        if ( @$filters[$i] ) {
            if (($i==1) and (@$filters[$i-1])) {
                $cell{err} = 1 if (@$filters[$i]<@$filters[$i-1]) ;
            }
            # format the dates filters, otherwise just fill as is
            if ($i>=4) {
                $cell{filter} .= @$filters[$i];
            } else {
                $cell{filter} .= format_date(@$filters[$i]);
            }
            $cell{crit} .="Issue From" if ($i==0);
            $cell{crit} .="Issue To" if ($i==1);
            $cell{crit} .="Issue Month" if ($i==2);
            $cell{crit} .="Issue Day" if ($i==3);
            $cell{crit} .="Return From" if ($i==4);
            $cell{crit} .="Return To" if ($i==5);
            $cell{crit} .="Return Month" if ($i==6);
            $cell{crit} .="Return Day" if ($i==7);
            $cell{crit} .="Borrower Cat" if ($i==8);
            $cell{crit} .="Doc Type" if ($i==9);
            $cell{crit} .="Branch" if ($i==10);
            $cell{crit} .="Sort1" if ($i==11);
            $cell{crit} .="Sort2" if ($i==12);
            push @loopfilter, \%cell;
        }
    }
    push @loopfilter,{crit=>"Issue Display",filter=>$rodsp} if ($rodsp);
    push @loopfilter,{crit=>"Return Display",filter=>$podsp} if ($podsp);

    
    
    my @linefilter;
#	warn "filtres ".@filters[0];
#	warn "filtres ".@filters[1];
#	warn "filtres ".@filters[2];
#	warn "filtres ".@filters[3];
    $line = "old_issues.".$line if ($line=~/branchcode/) or ($line=~/timestamp/);
    $line = "biblioitems.".$line if $line=~/itemtype/;
    
    $linefilter[0] = @$filters[0] if ($line =~ /timestamp/ )  ;
    $linefilter[1] = @$filters[1] if ($line =~ /timestamp/ )  ;
    $linefilter[2] = @$filters[2] if ($line =~ /timestamp/ )  ;
    $linefilter[3] = @$filters[3] if ($line =~ /timestamp/ )  ;
    $linefilter[0] = @$filters[4] if ($line =~ /returndate/ )  ;
    $linefilter[1] = @$filters[5] if ($line =~ /returndate/ )  ;
    $linefilter[2] = @$filters[6] if ($line =~ /returndate/ )  ;
    $linefilter[3] = @$filters[7] if ($line =~ /returndate/ )  ;
    $linefilter[0] = @$filters[8] if ($line =~ /category/ )  ;
    $linefilter[0] = @$filters[9] if ($line =~ /itemtype/ )  ;
    $linefilter[0] = @$filters[10] if ($line =~ /branch/ )  ;
# 	$linefilter[0] = @$filters[11] if ($line =~ /sort2/ ) ;
    $linefilter[0] = @$filters[11] if ($line =~ /sort1/ ) ;
    $linefilter[0] = @$filters[12] if ($line =~ /sort2/ ) ;
#warn "filtre lignes".$linefilter[0]." ".$linefilter[1];
# 
    $column = "old_issues.".$column if (($column=~/branchcode/) or ($column=~/timestamp/));
    $column = "biblioitems.".$column if $column=~/itemtype/;
    my @colfilter ;
    $colfilter[0] = @$filters[0] if ($column =~ /timestamp/ )  ;
    $colfilter[1] = @$filters[1] if ($column =~ /timestamp/ )  ;
    $colfilter[2] = @$filters[2] if ($column =~ /timestamp/ )  ;
    $colfilter[3] = @$filters[3] if ($column =~ /timestamp/ )  ;
    $colfilter[0] = @$filters[4] if ($column =~ /returndate/ )  ;
    $colfilter[1] = @$filters[5] if ($column =~ /returndate/ )  ;
    $colfilter[2] = @$filters[6] if ($column =~ /returndate/ )  ;
    $colfilter[3] = @$filters[7] if ($column =~ /returndate/ )  ;
    $colfilter[0] = @$filters[8] if ($column =~ /category/ )  ;
    $colfilter[0] = @$filters[9] if ($column =~ /itemtype/ )  ;
    $colfilter[0] = @$filters[10] if ($column =~ /branch/ )  ;
# 	$colfilter[0] = @$filters[11] if ($column =~ /sort2/ ) ;
    $colfilter[0] = @$filters[11] if ($column =~ /sort1/ ) ;
    $colfilter[0] = @$filters[12] if ($column =~ /sort2/ ) ;
#warn "filtre col ".$colfilter[0]." ".$colfilter[1];
                                            
# 1st, loop rows.                             
    my $linefield;
    my $lineorder;                               
    if ((($line =~/timestamp/) and ($podsp == 1)) or  (($line =~/returndate/) and ($rodsp == 1))) {
        #Display by day
        $linefield .="dayname($line)";  
        $lineorder .="weekday($line)";  
    } elsif ((($line =~/timestamp/) and ($podsp == 2)) or  (($line =~/returndate/) and ($rodsp == 2))) {
        #Display by Month
        $linefield .="monthname($line)";  
        $lineorder .="month($line)";  
    } elsif ((($line =~/timestamp/) and ($podsp == 3)) or  (($line =~/returndate/) and ($rodsp == 3))) {
        #Display by Year
        $linefield .="Year($line)";
        $lineorder .= $line;  
    } elsif (($line=~/timestamp/) or ($line=~/returndate/)){
        $linefield .= "date_format(\'$line\',\"%Y-%m-%d\")";
        $lineorder .= $line;  
    } else {
        $linefield .= $line;
        $lineorder .= $line;  
    }  
    
    my $strsth;
    $strsth .= "select distinctrow $linefield 
                FROM `old_issues` 
                LEFT JOIN borrowers ON borrowers.borrowernumber=old_issues.borrowernumber
                LEFT JOIN items ON old_issues.itemnumber=items.itemnumber
                LEFT JOIN biblioitems ON (biblioitems.biblioitemnumber=items.biblioitemnumber) 
                LEFT JOIN issuingrules ON 
                    (issuingrules.branchcode=old_issues.branchcode
                    AND  issuingrules.itemtype=biblioitems.itemtype 
                    AND  issuingrules.categorycode=borrowers.categorycode) 
                WHERE 1";
    
    if (($line=~/timestamp/) or ($line=~/returndate/)){
        if ($linefilter[1] and ($linefilter[0])){
            $strsth .= " AND $line BETWEEN '$linefilter[0]' AND '$linefilter[1]' " ;
        } elsif ($linefilter[1]) {
                $strsth .= " AND $line < \'$linefilter[1]\' " ;
        } elsif ($linefilter[0]) {
            $strsth .= " AND $line > \'$linefilter[0]\' " ;
        }
        if ($linefilter[2]){
            $strsth .= " AND dayname($line) = '$linefilter[2]' " ;
        }
        if ($linefilter[3]){
            $strsth .= " AND monthname($line) = '$linefilter[3]' " ;
        }
    } elsif ($linefilter[0]) {
        $linefilter[0] =~ s/\*/%/g;
        $strsth .= " AND $line LIKE '$linefilter[0]' " ;
    }
    $strsth .=" GROUP BY $linefield";
    $strsth .=" ORDER BY $lineorder";
   
    my $sth = $dbh->prepare( $strsth );
    $sth->execute;

    
    while ( my ($celvalue) = $sth->fetchrow) {
        my %cell;
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
    if ((($column =~/timestamp/) and ($podsp == 1)) or  (($column =~/returndate/) and ($rodsp == 1))) {
        #Display by day
        $colfield .="dayname($column)";  
        $colorder .="weekday($column)";
    } elsif ((($column =~/timestamp/) and ($podsp == 2)) or  (($column =~/returndate/) and ($rodsp == 2))) {
        #Display by Month
        $colfield .="monthname($column)";  
        $colorder .="month($column)";  
    } elsif ((($column =~/timestamp/) and ($podsp == 3)) or  (($column =~/returndate/) and ($rodsp == 3))) {
        #Display by Year
        $colfield .="Year($column)";
        $colorder .= $column;
    } elsif (($column=~/timestamp/) or ($column=~/returndate/)){
        $colfield .= 'date_format( '."'".$column."'". ', "%Y-%m-%d")';
        $colorder .= $column;
    } else {
        $colfield .= $column;
        $colorder .= $column;
    }  
    
    my $strsth2;
    $strsth2 .= "SELECT distinctrow $colfield 
                  FROM `old_issues`
                  LEFT JOIN borrowers ON borrowers.borrowernumber=old_issues.borrowernumber
                  LEFT JOIN items  ON items.itemnumber=old_issues.itemnumber  
                  LEFT JOIN biblioitems ON (biblioitems.biblioitemnumber=items.biblioitemnumber) 
                  LEFT JOIN issuingrules ON 
                    (issuingrules.branchcode=old_issues.branchcode 
                    AND  issuingrules.itemtype=biblioitems.itemtype 
                    AND  issuingrules.categorycode=borrowers.categorycode) 
                  WHERE 1";
    
    if (($column=~/timestamp/) or ($column=~/returndate/)){
        if ($colfilter[1] and ($colfilter[0])){
            $strsth2 .= " AND $column BETWEEN '$colfilter[0]' AND '$colfilter[1]' " ;
        } elsif ($colfilter[1]) {
                $strsth2 .= " AND $column < '$colfilter[1]' " ;
        } elsif ($colfilter[0]) {
            $strsth2 .= " AND $column > '$colfilter[0]' " ;
        }
        if ($colfilter[2]){
            $strsth2 .= " AND dayname($column) = '$colfilter[2]' " ;
        }
        if ($colfilter[3]){
            $strsth2 .= " AND monthname($column) = '$colfilter[3]' " ;
        }
    } elsif ($colfilter[0]) {
        $colfilter[0] =~ s/\*/%/g;
        $strsth2 .= " AND $column LIKE '$colfilter[0]' " ;
    }
    $strsth2 .=" GROUP BY $colfield";
    $strsth2 .=" ORDER BY $colorder";
    warn "". $strsth2;
    
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
#		warn "coltitle :".$celvalue;
        $cell{coltitle} = $celvalue;
        $ft{totalcol} = 0;
        push @loopcol, \%cell;
    }
#	warn "fin des titres colonnes";

    my $i=0;
    my @totalcol;
    my $hilighted=-1;
    
    #Initialization of cell values.....
    my %table;
    my %wgttable;
    my %cnttable;
    
#	warn "init table";
    foreach my $row ( @loopline ) {
        foreach my $col ( @loopcol ) {
#			warn " init table : $row->{rowtitle} / $col->{coltitle} ";
            $table{$row->{rowtitle}}->{$col->{coltitle}}=0;
        }
        $table{$row->{rowtitle}}->{totalrow}=0;
    }

# preparing calculation
    my $strcalc ;
    
# Processing average loanperiods
    $strcalc .= "SELECT $linefield, $colfield, ";
    $strcalc .= " issuedate, returndate, old_issues.timestamp, COUNT(*), date_due, old_issues.renewals, issuelength FROM `old_issues`,borrowers,biblioitems LEFT JOIN items ON (biblioitems.biblioitemnumber=items.biblioitemnumber) LEFT JOIN issuingrules ON (issuingrules.branchcode=branchcode AND  issuingrules.itemtype=biblioitems.itemtype AND  issuingrules.categorycode=categorycode) WHERE old_issues.itemnumber=items.itemnumber AND old_issues.borrowernumber=borrowers.borrowernumber";

    @$filters[0]=~ s/\*/%/g if (@$filters[0]);
    $strcalc .= " AND old_issues.timestamp > '" . @$filters[0] ."'" if ( @$filters[0] );
    @$filters[1]=~ s/\*/%/g if (@$filters[1]);
    $strcalc .= " AND old_issues.timestamp < '" . @$filters[1] ."'" if ( @$filters[1] );
    @$filters[4]=~ s/\*/%/g if (@$filters[4]);
    $strcalc .= " AND old_issues.returndate > '" . @$filters[4] ."'" if ( @$filters[4] );
    @$filters[5]=~ s/\*/%/g if (@$filters[5]);
    $strcalc .= " AND old_issues.returndate < '" . @$filters[5] ."'" if ( @$filters[5] );
    @$filters[8]=~ s/\*/%/g if (@$filters[8]);
    $strcalc .= " AND borrowers.categorycode like '" . @$filters[8] ."'" if ( @$filters[8] );
    @$filters[9]=~ s/\*/%/g if (@$filters[9]);
    $strcalc .= " AND biblioitems.itemtype like '" . @$filters[9] ."'" if ( @$filters[9] );
    @$filters[10]=~ s/\*/%/g if (@$filters[10]);
    $strcalc .= " AND old_issues.branchcode like '" . @$filters[10] ."'" if ( @$filters[10] );
    @$filters[11]=~ s/\*/%/g if (@$filters[11]);
    $strcalc .= " AND borrowers.sort1 like '" . @$filters[11] ."'" if ( @$filters[11] );
    @$filters[12]=~ s/\*/%/g if (@$filters[12]);
    $strcalc .= " AND borrowers.sort2 like '" . @$filters[12] ."'" if ( @$filters[12] );
    $strcalc .= " AND dayname(timestamp) like '" . @$filters[2]."'" if (@$filters[2]);
    $strcalc .= " AND monthname(timestamp) like '" . @$filters[3] ."'" if ( @$filters[3] );
    $strcalc .= " AND dayname(returndate) like '" . @$filters[5]."'" if (@$filters[5]);
    $strcalc .= " AND monthname(returndate) like '" . @$filters[6] ."'" if ( @$filters[6] );
    
    $strcalc .= " group by  $linefield, $colfield, issuedate, returndate order by $linefield, $colfield";
    warn "SQL :". $strcalc;
    
    my $dbcalc = $dbh->prepare($strcalc);
    $dbcalc->execute;
# 	warn "filling table";
    my $issues_count=0;
    my $previous_row; 
    my $previous_col;
    my $loanlength; 
    my $err;
    my $emptycol;
    my $weightrow;
    
    while (my  @data = $dbcalc->fetchrow) {
        my ($row, $col, $issuedate, $returndate, $weight)=@data;
#		warn "filling table $row / $col / $issuedate / $returndate /$weight";
        $emptycol=1 if (!defined($col));
        $col = "zzEMPTY" if (!defined($col));
        $row = "zzEMPTY" if (!defined($row));
        # fill returndate to avoid an error with date calc (needed for all non returned issues)
        $returndate= join '-',Date::Calc::Today if $returndate eq '0000-00-00';
    #  DateCalc returns => 0:0:WK:DD:HH:MM:SS   the weeks, days, hours, minutes,
    #  and seconds between the two
        $loanlength = Delta_Days(split(/-/,$issuedate),split (/-/,$returndate)) ;
    #		warn "512 Same row and col DateCalc returns :$loanlength with return ". $returndate ."issue ". $issuedate ."weight : ". $weight;
    #		warn "513 row :".$row." column :".$col;
        $table{$row}->{$col}+=$weight*$loanlength;
    #		$table{$row}->{totalrow}+=$weight*$loanlength;
        $cnttable{$row}->{$col}= 1;
        $wgttable{$row}->{$col}+=$weight;
    }
    
    push @loopcol,{coltitle => "NULL"} if ($emptycol);
    
    foreach my $row ( sort keys %table ) {
        my @loopcell;
    #@loopcol ensures the order for columns is common with column titles
    # and the number matches the number of columns
        my $colcount=0;
        foreach my $col ( @loopcol ) {
            my $value =$table{$row}->{(($col->{coltitle} eq "NULL")or ($col->{coltitle} eq ""))?"zzEMPTY":$col->{coltitle}} / $wgttable{$row}->{(($col->{coltitle} eq "NULL")or ($col->{coltitle} eq ""))?"zzEMPTY":$col->{coltitle}} if ($table{$row}->{(($col->{coltitle} eq "NULL")or ($col->{coltitle} eq ""))?"zzEMPTY":$col->{coltitle}});

            $table{$row}->{(($col->{coltitle} eq "NULL")or ($col->{coltitle} eq ""))?"zzEMPTY":$col->{coltitle}} = $value;
            $table{$row}->{totalrow}+=$value;
            #warn "row : $row col:$col  $cnttable{$row}->{(($col->{coltitle} eq \"NULL\")or ($col->{coltitle} eq \"\"))?\"zzEMPTY\":$col->{coltitle}}";
            $colcount+=$cnttable{$row}->{(($col->{coltitle} eq "NULL")or ($col->{coltitle} eq ""))?"zzEMPTY":$col->{coltitle}};
            push @loopcell, {value => ($value)?sprintf("%.2f",$value):0  } ;
        }
        #warn "row : $row colcount:$colcount";
        my $total = $table{$row}->{totalrow}/$colcount if ($colcount>0);
        push @looprow,{ 'rowtitle' => ($row eq "zzEMPTY")?"NULL":$row,
                        'loopcell' => \@loopcell,
                        'hilighted' => ($hilighted >0),
                        'totalrow' => ($total)?sprintf("%.2f",$total):0
                    };
        $hilighted = -$hilighted;
    }
# 	
# #	warn "footer processing";
    foreach my $col ( @loopcol ) {
        my $total=0;
        my $nbrow=0;
        foreach my $row ( @looprow ) {
            $total += $cnttable{($row->{rowtitle} eq "NULL")?"zzEMPTY":$row->{rowtitle}}->{($col->{coltitle} eq "NULL")?"zzEMPTY":$col->{coltitle}}*$table{($row->{rowtitle} eq "NULL")?"zzEMPTY":$row->{rowtitle}}->{($col->{coltitle} eq "NULL")?"zzEMPTY":$col->{coltitle}};
            $nbrow +=$cnttable{($row->{rowtitle} eq "NULL")?"zzEMPTY":$row->{rowtitle}}->{($col->{coltitle} eq "NULL")?"zzEMPTY":$col->{coltitle}};;
#			warn "value added ".$table{$row->{rowtitle}}->{$col->{coltitle}}. "for line ".$row->{rowtitle};
        }
#		warn "summ for column ".$col->{coltitle}."  = ".$total;
        $total = $total/$nbrow if ($nbrow);
        push @loopfooter, {'totalcol' => ($total)?sprintf("%.2f",$total):0};
    
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
