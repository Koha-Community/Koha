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
use Date::Manip;

=head1 NAME

plugin that shows a stats on borrowers

=head1 DESCRIPTION

=over 2

=cut

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
                            debug => 1,
                            });
$template->param(do_it => $do_it,
        DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(),
                );
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
                            -id => 'itemtype',
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
    # location list
    $req = $dbh->prepare("select distinctrow location from items order by location");
    $req->execute;
    undef @select;
    push @select,"";
    while (my ($value) =$req->fetchrow) {
        push @select, $value;
    }
    my $CGIlocation=CGI::scrolling_list( -name     => 'Filter',
                            -id => 'location',
                            -values   => \@select,
                            -size     => 1,
                            -multiple => 0 );
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
        CGIBorCat => $CGIBorCat,
        CGIItemType => $CGIItemTypes,
        CGIBranch => $CGIBranch,
        hassort1=> $hassort1,
        hassort2=> $hassort2,
        HlghtSort2 => $hglghtsort2,
        CGISort1 => $CGISort1,
        CGISort2 => $CGISort2,
        CGIextChoice => $CGIextChoice,
        CGIsepChoice => $CGIsepChoice,
        CGILocation => $CGIlocation,
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
        for (my $i=0;$i<=9;$i++) {
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
                        $cell{crit} .="Borrower Cat=" if ($i==2);
                        $cell{crit} .="Doc Type=" if ($i==3);
                        $cell{crit} .="Branch=" if ($i==4);
                        $cell{crit} .="Location=" if ($i==5);
                        $cell{crit} .="Item callnumber>=" if ($i==6);
                        $cell{crit} .="Item callnumber<" if ($i==7);
                        $cell{crit} .="sort1=" if ($i==8);
                        $cell{crit} .="sort2=" if ($i==9);

                        push @loopfilter, \%cell;
                }
        }
        push @loopfilter,{crit=>"Event",filter=>$type};
        push @loopfilter,{crit=>"Display by ",filter=>$dsp} if ($dsp);
        push @loopfilter,{crit=>"Select Day ",filter=>$daysel} if ($daysel);
        push @loopfilter,{crit=>"Select Month ",filter=>$monthsel} if ($monthsel);
        
        
        my @linefilter;
#	warn "filtres ".@filters[0];
#	warn "filtres ".@filters[1];
#	warn "filtres ".@filters[2];
#	warn "filtres ".@filters[3];
        
        $linefilter[0] = @$filters[0] if ($line =~ /datetime/ )  ;
        $linefilter[1] = @$filters[1] if ($line =~ /datetime/ )  ;
        $linefilter[0] = @$filters[2] if ($line =~ /category/ )  ;
        $linefilter[0] = @$filters[3] if ($line =~ /itemtype/ )  ;
        $linefilter[0] = @$filters[4] if ($line =~ /branch/ )  ;
        $linefilter[0] = @$filters[5] if ($line =~ /location/ ) ;
        $linefilter[0] = @$filters[6] if ($line =~ /sort1/ ) ;
        $linefilter[0] = @$filters[7] if ($line =~ /sort2/ ) ;

        my @colfilter ;
        $colfilter[0] = @$filters[0] if ($column =~ /datetime/) ;
        $colfilter[1] = @$filters[1] if ($column =~ /datetime/) ;
        $colfilter[0] = @$filters[2] if ($column =~ /category/) ;
        $colfilter[0] = @$filters[3] if ($column =~ /itemtype/) ;
        $colfilter[0] = @$filters[4] if ($column =~ /branch/ )  ;
        $colfilter[0] = @$filters[5] if ($column =~ /location/  )  ;
        $colfilter[0] = @$filters[6] if ($column =~ /sort1/  )  ;
        $colfilter[0] = @$filters[7] if ($column =~ /sort2/  )  ;
# 1st, loop rows.                             
        my $linefield;                               
        if (($line =~/datetime/) and ($dsp == 1)) {
                #Display by day
                $linefield .="dayname($line)";  
        } elsif (($line=~/datetime/) and ($dsp == 2)) {
                #Display by Month
                $linefield .="monthname($line)";  
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
        $strsth .= "select distinctrow $linefield from statistics, borrowers where (statistics.borrowernumber=borrowers.borrowernumber) and $line is not null ";
        
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
#         warn "". $strsth;
        
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
        $strsth2 .= "select distinctrow $colfield from statistics, borrowers where (statistics.borrowernumber=borrowers.borrowernumber) and $column is not null ";
        
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
#	warn "". $strsth2;
        
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
        $strcalc .= "LEFT JOIN items ON statistics.itemnumber=items.itemnumber " if @$filters[5] or @$filters[6];
        
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
        $strcalc .= " AND items.location like '" . @$filters[5] ."'" if ( @$filters[5] );
        @$filters[6]=~ s/\*/%/g if (@$filters[6]);
        $strcalc .= " AND items.itemcallnumber >='" . @$filters[6] ."'" if ( @$filters[6] );
        @$filters[7]=~ s/\*/%/g if (@$filters[7]);
        $strcalc .= " AND items.itemcallnumber <'" . @$filters[7] ."'" if ( @$filters[7] );
        @$filters[8]=~ s/\*/%/g if (@$filters[8]);
        $strcalc .= " AND borrowers.sort1 like '" . @$filters[8] ."'" if ( @$filters[8] );
        @$filters[9]=~ s/\*/%/g if (@$filters[9]);
        $strcalc .= " AND borrowers.sort2 like '" . @$filters[9] ."'" if ( @$filters[9] );
        $strcalc .= " AND dayname(datetime) like '" . $daysel ."'" if ( $daysel );
        $strcalc .= " AND monthname(datetime) like '" . $monthsel ."'" if ( $monthsel );
        $strcalc .= " AND statistics.type like '" . $type ."'" if ( $type );
        
        $strcalc .= " group by $linefield, $colfield order by $lineorder,$colorder";
        warn "". $strcalc;
        my $dbcalc = $dbh->prepare($strcalc);
        $dbcalc->execute;
# 	warn "filling table";
        my $emptycol; 
        while (my ($row, $col, $value) = $dbcalc->fetchrow) {
#                 warn "filling table $row / $col / $value ";
                $emptycol = 1 if ($col eq undef);
                $col = "zzEMPTY" if ($col eq undef);
                $row = "zzEMPTY" if ($row eq undef);
                
                $table{$row}->{$col}+=$value;
                $table{$row}->{totalrow}+=$value;
                $grantotal += $value;
        }
        push @loopcol,{coltitle => "NULL"} if ($emptycol);

        foreach my $row (@loopline) {
                my @loopcell;
                #@loopcol ensures the order for columns is common with column titles
                # and the number matches the number of columns
                foreach my $col ( @loopcol ) {
                        my $value =$table{($row->{rowtitle} eq "NULL")?"zzEMPTY":$row->{rowtitle}}->{($col->{coltitle} eq "NULL")?"zzEMPTY":$col->{coltitle}};
                        push @loopcell, {value => $value  } ;
                }
                push @looprow,{ 'rowtitle' => ($row->{rowtitle} eq "NULL")?"zzEMPTY":$row->{rowtitle},
                                'loopcell' => \@loopcell,
                                'hilighted' => ($hilighted >0),
                                'totalrow' => $table{($row->{rowtitle} eq "NULL")?"zzEMPTY":$row->{rowtitle}}->{totalrow}
                                                };
                $hilighted = -$hilighted;
        }
        
#	warn "footer processing";
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

1;
