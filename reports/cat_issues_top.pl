#!/usr/bin/perl


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

use Modern::Perl;
use C4::Auth;
use CGI qw ( -utf8 );
use C4::Context;
use C4::Output;
use C4::Koha;
use C4::Circulation;
use C4::Reports;
use C4::Members;
use Koha::DateUtils;
use Koha::ItemTypes;

=head1 NAME

plugin that shows a stats on borrowers

=head1 DESCRIPTION

=cut

my $input = new CGI;
my $do_it=$input->param('do_it');
my $fullreportname = "reports/cat_issues_top.tt";
my $limit = $input->param("Limit");
my $column = $input->param("Criteria");
my @filters = $input->multi_param("Filter");
foreach ( @filters[0..3] ) {
    $_ and $_ = eval { output_pref( { dt => dt_from_string ( $_ ), dateonly => 1, dateformat => 'iso' } ); };
}

my $output = $input->param("output");
my $basename = $input->param("basename");
#warn "calcul : ".$calc;
my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => $fullreportname,
                query => $input,
                type => "intranet",
                authnotrequired => 0,
                flagsrequired => { reports => '*'},
                debug => 1,
                });
our $sep     = $input->param("sep");
$sep = "\t" if ($sep eq 'tabulation');
$template->param(do_it => $do_it,
        );
if ($do_it) {
# Displaying results
    my $results = calculate($limit, $column, \@filters);
    if ($output eq "screen"){
# Printing results to screen
        $template->param(mainloop => $results,
                        limit => $limit);
        output_html_with_http_headers $input, $cookie, $template->output;
        exit;
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
                print $cell->{count};
            }
            print "\n";
        }
        exit;
    }
# Displaying choices
} else {
    my $dbh = C4::Context->dbh;
    my @values;
    my %labels;
    my %select;
    my $req;
    
    my $CGIextChoice = ( 'CSV' ); # FIXME translation
    my $CGIsepChoice=GetDelimiterChoices;

    #doctype
    my $itemtypes = Koha::ItemTypes->search_with_localization;

    #ccode
    my $ccodes = GetAuthorisedValues('CCODE');
    my @ccodeloop;
    for my $thisccode (@$ccodes) {
            my %row = (value => $thisccode->{authorised_value},
                       description => $thisccode->{lib},
                            );
            push @ccodeloop, \%row;
    }

    @ccodeloop = sort {$a->{value} cmp $b->{value}} @ccodeloop;

    #shelvingloc
    my $shelvinglocs = GetAuthorisedValues('LOC');
    my @shelvinglocloop;
    for my $thisloc (@$shelvinglocs) {
            my %row = (value => $thisloc->{authorised_value},
                       description => $thisloc->{lib},
                            );
            push @shelvinglocloop, \%row;
    }

    @shelvinglocloop = sort {$a->{value} cmp $b->{value}} @shelvinglocloop;

    my $patron_categories = Koha::Patron::Categories->search_limited({}, {order_by => ['categorycode']});

    $template->param(
                    CGIextChoice => $CGIextChoice,
                    CGIsepChoice => $CGIsepChoice,
                    itemtypes => $itemtypes,
                    ccodeloop =>\@ccodeloop,
                    shelvinglocloop =>\@shelvinglocloop,
                    patron_categories => $patron_categories,
                    );
output_html_with_http_headers $input, $cookie, $template->output;
}




sub calculate {
    my ($line, $column, $filters) = @_;
    my @mainloop;
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
    for (my $i=0;$i<=12;$i++) {
        my %cell;
        if ( @$filters[$i] ) {
            if (($i==1) and (@$filters[$i-1])) {
                $cell{err} = 1 if (@$filters[$i]<@$filters[$i-1]) ;
            }
            # format the dates filters, otherwise just fill as is
            if ($i>=2) {
                $cell{filter} .= @$filters[$i];
            } else {
                $cell{filter} .= eval { output_pref( { dt => dt_from_string( @$filters[$i] ), dateonly => 1 }); }
                   if ( @$filters[$i] );
            }
            $cell{crit} .="Issue From" if ($i==0);
            $cell{crit} .="Issue To" if ($i==1);
            $cell{crit} .="Return From" if ($i==2);
            $cell{crit} .="Return To" if ($i==3);
            $cell{crit} .="Branch" if ($i==4);
            $cell{crit} .="Doc Type" if ($i==5);
            $cell{crit} .="Call number" if ($i==6);
            $cell{crit} .="Collection code" if ($i==7);
            $cell{crit} .="Shelving location" if ($i==8);
            $cell{crit} .="Bor Cat" if ($i==9);
            $cell{crit} .="Day" if ($i==10);
            $cell{crit} .="Month" if ($i==11);
            $cell{crit} .="Year" if ($i==12);
            push @loopfilter, \%cell;
        }
    }
    my $colfield;
    my $colorder;
    if ($column){
        $column = "old_issues.".$column if (($column=~/branchcode/) or ($column=~/timestamp/));
        if($column=~/itemtype/){
            $column = C4::Context->preference('item-level_itypes') ? "items.itype": "biblioitems.itemtype";
        }
        $column = "borrowers.".$column if $column=~/categorycode/;
        my @colfilter ;
        $colfilter[0] = @$filters[0] if ($column =~ /timestamp/ )  ;
        $colfilter[1] = @$filters[1] if ($column =~ /timestamp/ )  ;
        $colfilter[0] = @$filters[2] if ($column =~ /returndate/ )  ;
        $colfilter[1] = @$filters[3] if ($column =~ /returndate/ )  ;
        $colfilter[0] = @$filters[4] if ($column =~ /branch/ )  ;
        $colfilter[0] = @$filters[5] if ($column =~ /itemtype/ )  ;
      # These limits does not currently exist, maybe later?
      # $colfilter[0] = @$filters[6] if ($column =~ /ccode/ )  ;
      # $colfilter[0] = @$filters[7] if ($column =~ /location/ )  ;
        $colfilter[0] = @$filters[8] if ($column =~ /category/ )  ;
      # This commented out row (sort2) was not removed when adding new filters for ccode, shelving location and call number
      # $colfilter[0] = @$filters[11] if ($column =~ /sort2/ ) ;
        $colfilter[0] = @$filters[9] if ($column =~ /timestamp/ ) ;
        $colfilter[0] = @$filters[10] if ($column =~ /timestamp/ ) ;
        $colfilter[0] = @$filters[11] if ($column =~ /timestamp/ ) ;
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
        $strsth2 .= "SELECT distinctrow $colfield 
                     FROM `old_issues` 
                     LEFT JOIN borrowers ON borrowers.borrowernumber=old_issues.borrowernumber 
                     LEFT JOIN items ON old_issues.itemnumber=items.itemnumber 
                     LEFT JOIN biblioitems  ON biblioitems.biblioitemnumber=items.biblioitemnumber 
                     WHERE 1";
        if (($column=~/timestamp/) or ($column=~/returndate/)){
            if ($colfilter[1] and ($colfilter[0])){
                $strsth2 .= " and $column between '$colfilter[0]' and '$colfilter[1]' " ;
            } elsif ($colfilter[1]) {
                    $strsth2 .= " and $column < '$colfilter[1]' " ;
            } elsif ($colfilter[0]) {
                $strsth2 .= " and $column > '$colfilter[0]' " ;
            }
        } elsif ($colfilter[0]) {
            $colfilter[0] =~ s/\*/%/g;
            $strsth2 .= " and $column LIKE '$colfilter[0]' " ;
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
            $cell{coltitle} = ($celvalue?$celvalue:"NULL");
            push @loopcol, \%cell;
        }
    #	warn "fin des titres colonnes";
    }
    
    my $i=0;
#	my @totalcol;
    my $hilighted=-1;
    
    #Initialization of cell values.....
    my @table;
    
#	warn "init table";
    for (my $i=1;$i<=$line;$i++) {
        foreach my $col ( @loopcol ) {
#			warn " init table : $row->{rowtitle} / $col->{coltitle} ";
            $table[$i]->{($col->{coltitle})?$col->{coltitle}:"total"}->{'name'}=0;
        }
    }


# preparing calculation
    my $strcalc ;
    
# Processing average loanperiods
    $strcalc .= "SELECT DISTINCT biblio.title, COUNT(biblio.biblionumber) AS RANK, biblio.biblionumber AS ID";
    $strcalc .= ", itemcallnumber as CALLNUM";
    $strcalc .= ", ccode as CCODE";
    $strcalc .= ", location as LOC";
    $strcalc .= " , $colfield " if ($colfield);
    $strcalc .= " FROM `old_issues` 
                  LEFT JOIN items USING(itemnumber) 
                  LEFT JOIN biblio USING(biblionumber) 
                  LEFT JOIN biblioitems USING(biblionumber)
                  LEFT JOIN borrowers USING(borrowernumber)
                  WHERE 1";

    @$filters[0]=~ s/\*/%/g if (@$filters[0]);
    $strcalc .= " AND old_issues.timestamp > '" . @$filters[0] ."'" if ( @$filters[0] );
    @$filters[1]=~ s/\*/%/g if (@$filters[1]);
    $strcalc .= " AND old_issues.timestamp < '" . @$filters[1] ."'" if ( @$filters[1] );
    @$filters[2]=~ s/\*/%/g if (@$filters[2]);
    $strcalc .= " AND old_issues.returndate > '" . @$filters[2] ."'" if ( @$filters[2] );
    @$filters[3]=~ s/\*/%/g if (@$filters[3]);
    $strcalc .= " AND old_issues.returndate < '" . @$filters[3] ."'" if ( @$filters[3] );
    @$filters[4]=~ s/\*/%/g if (@$filters[4]);
    $strcalc .= " AND old_issues.branchcode like '" . @$filters[4] ."'" if ( @$filters[4] );
    @$filters[5]=~ s/\*/%/g if (@$filters[5]);
    if ( @$filters[5] ){
        if(C4::Context->preference('item-level_itypes') ){
            $strcalc .= " AND items.itype like "
        }else{
            $strcalc .= " AND biblioitems.itemtype like "
        } 
        $strcalc .= "'" . @$filters[5] ."'" ;
    }
    @$filters[6]=~ s/\*/%/g if (@$filters[6]);
    $strcalc .= " AND itemcallnumber like '" . @$filters[6] ."'" if ( @$filters[6] );
    @$filters[7]=~ s/\*/%/g if (@$filters[7]);
    $strcalc .= " AND ccode like '" . @$filters[7] ."'" if ( @$filters[7] );
    @$filters[8]=~ s/\*/%/g if (@$filters[8]);
    $strcalc .= " AND location like '" . @$filters[8] ."'" if ( @$filters[8] );
    @$filters[9]=~ s/\*/%/g if (@$filters[9]);
    $strcalc .= " AND borrowers.categorycode like '" . @$filters[9] ."'" if ( @$filters[9] );
    @$filters[10]=~ s/\*/%/g if (@$filters[10]);
    $strcalc .= " AND dayname(old_issues.timestamp) like '" . @$filters[10]."'" if (@$filters[10]);
    @$filters[11]=~ s/\*/%/g if (@$filters[11]);
    $strcalc .= " AND monthname(old_issues.timestamp) like '" . @$filters[11]."'" if (@$filters[11]);
    @$filters[12]=~ s/\*/%/g if (@$filters[12]);
    $strcalc .= " AND year(old_issues.timestamp) like '" . @$filters[12] ."'" if ( @$filters[12] );
    
    $strcalc .= " group by biblio.biblionumber";
    $strcalc .= ", $colfield" if ($column);
    $strcalc .= " order by RANK DESC";
    $strcalc .= ", $colfield " if ($colfield);
    
    my $dbcalc = $dbh->prepare($strcalc);
    $dbcalc->execute;
    my $previous_col;
    my %indice;
    while (my  @data = $dbcalc->fetchrow) {
        my ($row, $rank, $id, $callnum, $ccode, $loc, $col )=@data;
        $col = "zzEMPTY" if (!defined($col));
        $indice{$col}=1 if (not($indice{$col}));
        $table[$indice{$col}]->{$col}->{'name'}=$row;
        $table[$indice{$col}]->{$col}->{'count'}=$rank;
        $table[$indice{$col}]->{$col}->{'link'}=$id;
        $indice{$col}++;
    }
    
    push @loopcol,{coltitle => "Global"} if not($column);
    
    for ($i=1; $i<=$line;$i++) {
        my @loopcell;
        #@loopcol ensures the order for columns is common with column titles
        # and the number matches the number of columns
        my $colcount=0;
        foreach my $col ( @loopcol ) {
            my $value;
            my $count=0;
            my $link;
            if (@loopcol){
                $value =$table[$i]->{(($col->{coltitle} eq "NULL") or ($col->{coltitle} eq "Global"))?"zzEMPTY":$col->{coltitle}}->{'name'};
                $count =$table[$i]->{(($col->{coltitle} eq "NULL") or ($col->{coltitle} eq "Global"))?"zzEMPTY":$col->{coltitle}}->{'count'};
                $link =$table[$i]->{(($col->{coltitle} eq "NULL") or ($col->{coltitle} eq "Global"))?"zzEMPTY":$col->{coltitle}}->{'link'};
            } else {
                $value =$table[$i]->{"zzEMPTY"}->{'name'};
                $count =$table[$i]->{"zzEMPTY"}->{'count'};
                $link =$table[$i]->{"zzEMPTY"}->{'link'};
            }
            push @loopcell, {value => $value, count =>$count, reference => $link} ;
        }
        #my $total = $table[$i]->{totalrow}/$colcount if ($colcount>0);
        push @looprow,{ 'rowtitle' => $i ,
                        'loopcell' => \@loopcell,
                        'hilighted' => ($hilighted >0),
                    };
        $hilighted = -$hilighted;
    }
# 	
            

    # the header of the table
    $globalline{loopfilter}=\@loopfilter;
    # the core of the table
    $globalline{looprow} = \@looprow;
    $globalline{loopcol} = \@loopcol;
# 	# the foot (totals by borrower type)
    $globalline{total}= $grantotal;
    $globalline{line} = $line;
    $globalline{column} = $column;
    push @mainloop,\%globalline;
    return \@mainloop;
}

1;
