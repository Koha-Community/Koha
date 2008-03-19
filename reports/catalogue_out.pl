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
use C4::Output;
use C4::Koha;
use C4::Circulation;
use Date::Manip;

=head1 NAME

plugin that shows a stats on borrowers

=head1 DESCRIPTION

=over 2

=cut

my $input = new CGI;
my $do_it=$input->param('do_it');
my $fullreportname = "reports/catalogue_out.tmpl";
my $limit = $input->param("Limit");
my $column = $input->param("Criteria");
my @filters = $input->param("Filter");
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
        );
if ($do_it) {
# Displaying results
    my $results = calculate($limit, $column, \@filters);
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
        print "num /". @$results[0]->{column} .$sep;
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
    
    my @dels = ( C4::Context->preference("delimiter") );
    my $CGIsepChoice=CGI::scrolling_list(
                -name     => 'sep',
                -id       => 'sep',
                -values   => \@dels,
                -size     => 1,
                -multiple => 0 );
    #doctype
    my $itemtypes = GetItemTypes;
    my @itemtypeloop;
    foreach my $thisitemtype (keys %$itemtypes) {
# 			my $selected = 1 if $thisbranch eq $branch;
            my %row =(value => $thisitemtype,
# 									selected => $selected,
                                    description => $itemtypes->{$thisitemtype}->{'description'},
                            );
            push @itemtypeloop, \%row;
    }
        
    #branch
    my $branches = GetBranches;
    my @branchloop;
    foreach my $thisbranch (keys %$branches) {
# 			my $selected = 1 if $thisbranch eq $branch;
            my %row =(value => $thisbranch,
# 									selected => $selected,
                                    branchname => $branches->{$thisbranch}->{'branchname'},
                            );
            push @branchloop, \%row;
    }
    
    $template->param(
                    CGIextChoice => $CGIextChoice,
                    CGIsepChoice => $CGIsepChoice,
                    itemtypeloop =>\@itemtypeloop,
                    branchloop =>\@branchloop,
                    );
output_html_with_http_headers $input, $cookie, $template->output;
}




sub calculate {
    my ($line, $column, $filters) = @_;
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
            $cell{filter} .= @$filters[$i];
            $cell{crit} .="Branch" if ($i==0);
            $cell{crit} .="Doc Type" if ($i==1);
            push @loopfilter, \%cell;
        }
    }
    my $colfield;
    my $colorder;
    if ($column){
        $column = "issues.".$column if (($column=~/branchcode/) or ($column=~/timestamp/));
        $column = "biblioitems.".$column if $column=~/itemtype/;
        $column = "borrowers.".$column if $column=~/categorycode/;
        my @colfilter ;
        $colfilter[0] = @$filters[0] if ($column =~ /branch/ )  ;
        $colfilter[0] = @$filters[1] if ($column =~ /itemtype/ )  ;
                                                
    # loop cols.
        $colfield .= $column;
        $colorder .= $column;
        
        my $strsth2;
        $strsth2 .= "select distinctrow $colfield 
          FROM `old_issues` 
            LEFT JOIN borrowers ON borrowers.borrowernumber=old_issues.borrowernumber 
            LEFT JOIN items ON old_issues.itemnumber=items.itemnumber 
            LEFT JOIN biblioitems ON biblioitems.biblioitemnumber=items.biblioitemnumber  
            WHERE old_issues.itemnumber=items.itemnumber 
            AND old_issues.borrowernumber=borrowers.borrowernumber";
        if ($colfilter[0]) {
            $colfilter[0] =~ s/\*/%/g;
            $strsth2 .= " AND $column LIKE '$colfilter[0]' " ;
        }
        $strsth2 .=" GROUP BY $colfield";
        $strsth2 .=" ORDER BY $colorder";
        warn "". $strsth2;
        
        my $sth2 = $dbh->prepare( $strsth2 );
        $sth2->execute;

        
    
        while (my ($celvalue) = $sth2->fetchrow) {
            my %cell;
    #		my %ft;
    #		warn "coltitle :".$celvalue;
            $cell{coltitle} = $celvalue;
    #		$ft{totalcol} = 0;
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
            $table[$i]->{($col->{coltitle})?$col->{coltitle}:"Global"}=0;
        }
    }


# preparing calculation
    my $strcalc ;
    
# Processing average loanperiods
    $strcalc .= "SELECT items.barcode, biblio.title, biblio.biblionumber, biblio.author";
    $strcalc .= " , $colfield " if ($colfield);
    $strcalc .= " FROM (items 
                        LEFT JOIN biblioitems ON biblioitems.biblioitemnumber = items.biblioitemnumber  
                        LEFT JOIN biblio ON biblio.biblionumber=items.biblionumber) 
                  LEFT JOIN old_issues ON  old_issues.itemnumber=items.itemnumber 
                  WHERE old_issues.itemnumber is null";
    @$filters[0]=~ s/\*/%/g if (@$filters[0]);
    $strcalc .= " AND items.homebranch like '" . @$filters[0] ."'" if ( @$filters[0] );
    @$filters[1]=~ s/\*/%/g if (@$filters[1]);
    $strcalc .= " AND biblioitems.itemtype like '" . @$filters[1] ."'" if ( @$filters[1] );
    
    $strcalc .= " GROUP BY items.itemnumber";
    $strcalc .= ", $colfield"          if ($column);
    $strcalc .= " ORDER BY $colfield " if ($colfield);
    my $max = (@loopcol) ? $line*@loopcol : $line ;
    $strcalc .= " LIMIT 0,$max"        if ($line);
    warn "SQL :". $strcalc;
    
    my $dbcalc = $dbh->prepare($strcalc);
    $dbcalc->execute;
# 	warn "filling table";
    my $previous_col;
    $i=1;
    while (my  @data = $dbcalc->fetchrow) {
        my ($barcode,$title,$biblionumber,$author, $col )=@data;
        $col = "zzEMPTY" if ($col eq undef);
        $i=1 if (($previous_col) and not($col eq $previous_col));
        $table[$i]->{$col}->{'barcode'}=$barcode;
        $table[$i]->{$col}->{'title'}=$title;
        $table[$i]->{$col}->{'biblionumber'}=$biblionumber;
        $table[$i]->{$col}->{'author'}=$author;
#		warn " ".$i." ".$col. " ".$row;
        $i++;
        $previous_col=$col;
    }
    
    push @loopcol,{coltitle => "Global"} if not($column);
    
    $max =(($line)?$line:@table);
    for ($i=1; $i<=$max;$i++) {
        my @loopcell;
        #@loopcol ensures the order for columns is common with column titles
        # and the number matches the number of columns
        my $colcount=0;
        foreach my $col ( @loopcol ) {
            my ($barcode, $author, $title, $biblionumber);
            if (@loopcol){
                $barcode =$table[$i]->{(($col->{coltitle} eq "NULL") or ($col->{coltitle} eq "Global"))?"zzEMPTY":$col->{coltitle}}->{'barcode'};
                $title =$table[$i]->{(($col->{coltitle} eq "NULL") or ($col->{coltitle} eq "Global"))?"zzEMPTY":$col->{coltitle}}->{'title'};
                $author =$table[$i]->{(($col->{coltitle} eq "NULL") or ($col->{coltitle} eq "Global"))?"zzEMPTY":$col->{coltitle}}->{'author'};
                $biblionumber =$table[$i]->{(($col->{coltitle} eq "NULL") or ($col->{coltitle} eq "Global"))?"zzEMPTY":$col->{coltitle}}->{'biblionumber'};
            } else {
                $barcode =$table[$i]->{"zzEMPTY"}->{'barcode'};
                $title =$table[$i]->{"zzEMPTY"}->{'title'};
                $author =$table[$i]->{"zzEMPTY"}->{'author'};
                $biblionumber =$table[$i]->{"zzEMPTY"}->{'biblionumber'};
            }
            push @loopcell, {author=> $author, title=>$title,biblionumber=>$biblionumber,barcode=>$barcode} ;
        }
        push @looprow,{ 'rowtitle' => $i ,
                        'loopcell' => \@loopcell,
                        'hilighted' => ($hilighted >0),
                    };
        $hilighted = -$hilighted;
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
