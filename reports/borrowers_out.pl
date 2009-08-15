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
use C4::Koha;
use C4::Output;
use C4::Circulation;
use C4::Reports;
use C4::Members;
use C4::Dates qw/format_date_in_iso/;

=head1 NAME

plugin that shows a stats on borrowers

=head1 DESCRIPTION

=over 2

=cut

my $input = new CGI;
my $do_it=$input->param('do_it');
my $fullreportname = "reports/borrowers_out.tmpl";
my $limit = $input->param("Limit");
my $column = $input->param("Criteria");
my @filters = $input->param("Filter");
my $output = $input->param("output");
my $basename = $input->param("basename");
my $mime = $input->param("MIME");
our $sep     = $input->param("sep");
$sep = "\t" if ($sep eq 'tabulation');
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
    
	my $CGIsepChoice = GetDelimiterChoices;
    
    my ($codes,$labels) = GetborCatFromCatType(undef,undef);
    my @borcatloop;
    foreach my $thisborcat (sort keys %$labels) {
            my %row =(value => $thisborcat,
                                    description => $labels->{$thisborcat},
                            );
            push @borcatloop, \%row;
    }
    $template->param(
                    CGIextChoice => $CGIextChoice,
                    CGIsepChoice => $CGIsepChoice,
                    borcatloop =>\@borcatloop,
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
    for (my $i=0;$i<=2;$i++) {
        my %cell;
        if ( @$filters[$i] ) {
            if (($i==1) and (@$filters[$i-1])) {
                $cell{err} = 1 if (@$filters[$i]<@$filters[$i-1]) ;
            }
            $cell{filter} .= @$filters[$i];
            $cell{crit} .="Bor Cat" if ($i==0);
            $cell{crit} .="Without issues since" if ($i==1);
            push @loopfilter, \%cell;
        }
    }
    my $colfield;
    my $colorder;
    if ($column){
        $column = "borrowers.".$column if $column=~/categorycode/ || $column=~/branchcode/;
        my @colfilter ;
        $colfilter[0] = @$filters[0] if ($column =~ /category/ )  ;
    # 	$colfilter[0] = @$filters[11] if ($column =~ /sort2/ ) ;
    #warn "filtre col ".$colfilter[0]." ".$colfilter[1];
                                                
    # loop cols.
        $colfield .= $column;
        $colorder .= $column;
        
        my $strsth2;
        $strsth2 .= "select distinctrow $colfield FROM borrowers LEFT JOIN `old_issues` ON old_issues.borrowernumber=borrowers.borrowernumber";
        if ($colfilter[0]) {
            $colfilter[0] =~ s/\*/%/g;
            $strsth2 .= " and $column LIKE '$colfilter[0]' " ;
        }
        $strsth2 .=" group by $colfield";
        $strsth2 .=" order by $colorder";
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
    
# Processing calculation
    $strcalc .= "SELECT CONCAT( borrowers.surname , \"\\t\",borrowers.firstname, \"\\t\", borrowers.cardnumber)";
    $strcalc .= " , $colfield " if ($colfield);
    $strcalc .= " FROM borrowers ";
    $strcalc .= "WHERE 1 ";
    @$filters[0]=~ s/\*/%/g if (@$filters[0]);
    $strcalc .= " AND borrowers.categorycode like '" . @$filters[0] ."'" if ( @$filters[0] );
    if (@$filters[1]){
        my $strqueryfilter="SELECT DISTINCT borrowernumber FROM old_issues where old_issues.timestamp> @$filters[1] ";
#        my $queryfilter = $dbh->prepare("SELECT DISTINCT borrowernumber FROM old_issues where old_issues.timestamp> ".format_date_in_iso(@$filters[1]));
        $strcalc .= " AND borrowers.borrowernumber not in ($strqueryfilter)";
        
# 		$queryfilter->execute(@$filters[1]);
# 		while (my ($borrowernumber)=$queryfilter->fetchrow){
# 			$strcalc .= " AND borrowers.borrowernumber <> $borrowernumber ";
# 		}
    } else {
        my $strqueryfilter="SELECT DISTINCT borrowernumber FROM old_issues ";
#        my $queryfilter = $dbh->prepare("SELECT DISTINCT borrowernumber FROM old_issues ");
#        $queryfilter->execute;
        $strcalc .= " AND borrowers.borrowernumber not in ($strqueryfilter)";
# 		while (my ($borrowernumber)=$queryfilter->fetchrow){
# 			$strcalc .= " AND borrowers.borrowernumber <> $borrowernumber ";
# 		}
    }
    $strcalc .= " group by borrowers.borrowernumber";
    $strcalc .= ", $colfield" if ($column);
    $strcalc .= " order by $colfield " if ($colfield);
    my $max;
    if (@loopcol) {
        $max = $line*@loopcol;
    } else { $max=$line;}
    $strcalc .= " LIMIT 0,$max" if ($line);
    warn "SQL :". $strcalc;
    
    my $dbcalc = $dbh->prepare($strcalc);
    $dbcalc->execute;
# 	warn "filling table";
    my $previous_col;
    $i=1;
    while (my  @data = $dbcalc->fetchrow) {
        my ($row, $col )=@data;
        $col = "zzEMPTY" if (!defined($col));
        $i=1 if (($previous_col) and not($col eq $previous_col));
        $table[$i]->{$col}=$row;
#		warn " $i $col $row";
        $i++;
        $previous_col=$col;
    }
    
    push @loopcol,{coltitle => "Global"} if not($column);
    
    $max =(($line)?$line:@table -1);
    for ($i=1; $i<=$max;$i++) {
        my @loopcell;
        #@loopcol ensures the order for columns is common with column titles
        # and the number matches the number of columns
        my $colcount=0;
        foreach my $col ( @loopcol ) {
            my $value;
            if (@loopcol){
                $value =$table[$i]->{(($col->{coltitle} eq "NULL") or ($col->{coltitle} eq "Global"))?"zzEMPTY":$col->{coltitle}};
            } else {
                $value =$table[$i]->{"zzEMPTY"};
            }
            push @loopcell, {value => $value} ;
        }
        push @looprow,{ 'rowtitle' => $i ,
                        'loopcell' => \@loopcell,
                    };
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
