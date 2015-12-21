#!/usr/bin/perl

# Copyright 2010 BibLibre
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
# Koha; if not, write to the Free Software Foundation, Inc., 
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


use strict;
use warnings;

use CGI qw ( -utf8 );

use C4::Auth;
use C4::Debug;
use C4::Context;
use C4::Branch; # GetBranches
use C4::Koha;
use C4::Output;
use C4::Reports;
use C4::Members;
use Koha::DateUtils;
use Koha::Patron::Categories;
use List::MoreUtils qw/any/;
use YAML;

=head1 NAME

plugin that shows circulation stats

=head1 DESCRIPTION

=over 2

=cut

# my $debug = 1;	# override for now.
my $input = new CGI;
my $fullreportname = "reports/reserves_stats.tt";
my $do_it    = $input->param('do_it');
my $line     = $input->param("Line");
my $column   = $input->param("Column");
my $podsp    = $input->param("DisplayBy");
my $type     = $input->param("PeriodTypeSel");
my $daysel   = $input->param("PeriodDaySel");
my $monthsel = $input->param("PeriodMonthSel");
my $calc     = $input->param("Cellvalue");
my $output   = $input->param("output");
my $basename = $input->param("basename");
my $mime     = $input->param("MIME");
my $hash_params = $input->Vars;
my $filter_hashref;
foreach my $filter (grep {$_ =~/^filter/} keys %$hash_params){
	my $filterstring=$filter;
	$filterstring=~s/^filter_//g;
	$$filter_hashref{$filterstring}=$$hash_params{$filter} if (defined $$hash_params{$filter} && $$hash_params{$filter} ne "");
}
my ($template, $borrowernumber, $cookie) = get_template_and_user({
	template_name => $fullreportname,
	query => $input,
	type => "intranet",
	authnotrequired => 0,
	flagsrequired => {reports => '*'},
	debug => 0,
});
our $sep     = $input->param("sep") || '';
$sep = "\t" if ($sep eq 'tabulation');
$template->param(do_it => $do_it,
);

my $itemtypes = GetItemTypes();
my @patron_categories = Koha::Patron::Categories->search_limited({}, {order_by => ['description']});

my $ccodes    = GetKohaAuthorisedValues("items.ccode");
my $locations = GetKohaAuthorisedValues("items.location");
my $authvalue = GetKohaAuthorisedValues("items.authvalue");

my $Bsort1 = GetAuthorisedValues("Bsort1");
my $Bsort2 = GetAuthorisedValues("Bsort2");
my ($hassort1,$hassort2);
$hassort1=1 if $Bsort1;
$hassort2=1 if $Bsort2;


if ($do_it) {
# Displaying results
	my $results = calculate($line, $column,  $calc, $filter_hashref);
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
	exit; # exit either way after $do_it
}

my $dbh = C4::Context->dbh;
my @values;
my %labels;
my %select;

# create itemtype arrayref for <select>.
my @itemtypeloop;
for my $itype ( sort {$itemtypes->{$a}->{translated_description} cmp $itemtypes->{$b}->{translated_description}} keys(%$itemtypes)) {
	push @itemtypeloop, { code => $itype , description => $itemtypes->{$itype}->{translated_description} } ;
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
my $CGIextChoice = ( 'CSV' ); # FIXME translation
my $CGIsepChoice=GetDelimiterChoices;
 
$template->param(
    categoryloop => \@patron_categories,
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
	my ($linefield, $colfield, $process, $filters_hashref) = @_;
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
    foreach my $filter ( keys %$filters_hashref ) {
        $filters_hashref->{$filter} =~ s/\*/%/;
        if ( $filter =~ /date/ ) {
            $filters_hashref->{$filter} =
                eval { output_pref( { dt => dt_from_string( $filters_hashref->{$filter} ), dateonly => 1, dateformat => 'iso' }); };
        }
    }

    #display
    @loopfilter = map {
        {
            crit   => $_,
            filter => (
                $_ =~ /date/
                ? eval { output_pref( { dt => dt_from_string( $filters_hashref->{$_} ), dateonly => 1 }); }
                : $filters_hashref->{$_}
            )
        }
    } sort keys %$filters_hashref;




	my $linesql=changeifreservestatus($linefield);
	my $colsql=changeifreservestatus($colfield);
	#Initialization of cell values.....

	# preparing calculation
    my $strcalc = "(SELECT $linesql line, $colsql col, ";
        $strcalc .= ($process == 1) ? " COUNT(*)  calculation"                                 :
					($process == 2) ? "(COUNT(DISTINCT reserves.borrowernumber)) calculation"  :
        			($process == 3) ? "(COUNT(DISTINCT reserves.itemnumber)) calculation"      : 
        			($process == 4) ? "(COUNT(DISTINCT reserves.biblionumber)) calculation"    : '*';
	$strcalc .= "
        FROM reserves
        LEFT JOIN borrowers USING (borrowernumber)
	";
	$strcalc .= "LEFT JOIN biblio ON reserves.biblionumber=biblio.biblionumber "
        if ($linefield =~ /^biblio\./ or $colfield =~ /^biblio\./ or any {$_=~/biblio/}keys %$filters_hashref);
	$strcalc .= "LEFT JOIN items ON reserves.itemnumber=items.itemnumber "
        if ($linefield =~ /^items\./ or $colfield =~ /^items\./ or any {$_=~/items/}keys %$filters_hashref);

	my @sqlparams;
	my @sqlorparams;
	my @sqlor;
	my @sqlwhere;
	($debug) and print STDERR Dump($filters_hashref);
	foreach my $filter (keys %$filters_hashref){
		my $string;
		my $stringfield=$filter;
		$stringfield=~s/\_[a-z_]+$//;
		if ($filter=~/ /){
			$string=$stringfield;
		}
		elsif ($filter=~/_or/){
			 push @sqlor, qq{( }.changeifreservestatus($filter)." = ? ) ";
			 push @sqlorparams, $$filters_hashref{$filter};
		}
		elsif ($filter=~/_endex$/){
			$string = " $stringfield < ? ";
		}
		elsif ($filter=~/_end$/){
			$string = " $stringfield <= ? ";
		}
		elsif ($filter=~/_begin$/){
			$string = " $stringfield >= ? ";
		}
		else {
			$string = " $stringfield LIKE ? ";
		}
		if ($string){
			push @sqlwhere, $string;
			push @sqlparams, $$filters_hashref{$filter};
		}
	}

	$strcalc .= " WHERE ".join(" AND ",@sqlwhere) if (@sqlwhere);
	$strcalc .= " AND (".join(" OR ",@sqlor).")" if (@sqlor);
	$strcalc .= " GROUP BY line, col )";
	my $strcalc_old=$strcalc;
	$strcalc_old=~s/reserves/old_reserves/g;
	$strcalc.=qq{ UNION $strcalc_old ORDER BY line, col};
	($debug) and print STDERR $strcalc;
	my $dbcalc = $dbh->prepare($strcalc);
	push @loopfilter, {crit=>'SQL =', sql=>1, filter=>$strcalc};
	@sqlparams=(@sqlparams,@sqlorparams);
	$dbcalc->execute(@sqlparams,@sqlparams);
	my ($emptycol,$emptyrow); 
	my $data = $dbcalc->fetchall_hashref([qw(line col)]);
	my %cols_hash;
	foreach my $row (keys %$data){
		push @loopline, $row;
		foreach my $col (keys %{$$data{$row}}){
			$$data{$row}{totalrow}+=$$data{$row}{$col}{calculation};
			$grantotal+=$$data{$row}{$col}{calculation};
			$cols_hash{$col}=1 ;
		}
	}
	my $urlbase="do_it=1&amp;".join("&amp;",map{"filter_$_=$$filters_hashref{$_}"} keys %$filters_hashref);
	foreach my $row (sort @loopline) {
		my @loopcell;
		#@loopcol ensures the order for columns is common with column titles
		# and the number matches the number of columns
		foreach my $col (sort keys %cols_hash) {
			push @loopcell, {value =>( $$data{$row}{$col}{calculation} or ""),
	#						url_complement=>($urlbase=~/&amp;$/?$urlbase."&amp;":$urlbase)."filter_$linefield=$row&amp;filter_$colfield=$col"
							}
		}
		push @looprow, {
			'rowtitle_display' => display_value($linefield,$row),
			'rowtitle' => $row,
			'loopcell' => \@loopcell,
			'totalrow' => $$data{$row}{totalrow}
		};
	}
	for my $col ( sort keys %cols_hash ) {
		my $total = 0;
		foreach my $row (@loopline) {
			$total += $data->{$row}{$col}{calculation} if $data->{$row}{$col}{calculation};
			$debug and warn "value added ".$$data{$row}{$col}{calculation}. "for line ".$row;
		}
		push @loopfooter, {'totalcol' => $total};
		push @loopcol, {'coltitle' => $col,
						coltitle_display=>display_value($colfield,$col)};
	}
	# the header of the table
	$globalline{loopfilter}=\@loopfilter;
	# the core of the table
	$globalline{looprow} = \@looprow;
	$globalline{loopcol} = \@loopcol;
	# 	# the foot (totals by borrower type)
	$globalline{loopfooter} = \@loopfooter;
	$globalline{total}  = $grantotal;
	$globalline{line}   = $linefield;
	$globalline{column} = $colfield;
	return [(\%globalline)];
}

sub null_to_zzempty ($) {
	my $string = shift;
	defined($string)    or  return 'zzEMPTY';
	($string eq "NULL") and return 'zzEMPTY';
	return $string;		# else return the valid value
}
sub display_value {
    my ( $crit, $value ) = @_;
    my $display_value =
        ( $crit =~ /ccode/ )         ? $ccodes->{$value}
      : ( $crit =~ /location/ )      ? $locations->{$value}
      : ( $crit =~ /itemtype/ )      ? $itemtypes->{$value}->{description}
      : ( $crit =~ /branch/ )        ? GetBranchName($value)
      : ( $crit =~ /reservestatus/ ) ? reservestatushuman($value)
      :                                $value;    # default fallback
    if ($crit =~ /sort1/) {
        foreach (@$Bsort1) {
            ($value eq $_->{authorised_value}) or next;
            $display_value = $_->{lib} and last;
        }
    }
    elsif ($crit =~ /sort2/) {
        foreach (@$Bsort2) {
            ($value eq $_->{authorised_value}) or next;
            $display_value = $_->{lib} and last;
        }
    }
    elsif ( $crit =~ /category/ ) {
        foreach my $patron_category ( @patron_categories ) {
            ( $value eq $patron_category->categorycode ) or next;
            $display_value = $patron_category->description and last;
        }
    }
    return $display_value;
}
sub reservestatushuman{
	my ($val)=@_;
	my %hashhuman=(
	1=>"1- placed",
	2=>"2- processed",
	3=>"3- pending",
	4=>"4- satisfied",
	5=>"5- cancelled",
	6=>"6- not a status"
	);
	$hashhuman{$val};
}
sub changeifreservestatus{
	my ($val)=@_;
	($val=~/reservestatus/
		?$val=qq{ case 
					when priority>0 then 1 
					when priority=0 then
						(case 
						   when found='f' then 4
						   when found='w' then 
						   (case 
						    when cancellationdate is null then 3
							else 5
							end )
						   else 2 
						 end )
				    else 6 
					end }
		:$val);
}
1;
