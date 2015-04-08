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

use strict;
#use warnings; FIXME - Bug 2505
use C4::Auth;
use CGI;
use C4::Context;
use C4::Branch; # GetBranches
use C4::Output;
use C4::Koha;
use C4::Reports;
use C4::Circulation;

=head1 NAME

plugin that shows a stats on borrowers

=head1 DESCRIPTION

=over 2

=cut

our $debug = 0;
my $input = new CGI;
my $fullreportname = "reports/catalogue_stats.tt";
my $do_it       = $input->param('do_it');
my $line        = $input->param("Line");
my $column      = $input->param("Column");
my @filters     = $input->param("Filter");
my $deweydigits = $input->param("deweydigits");
my $lccndigits  = $input->param("lccndigits");
my $cotedigits  = $input->param("cotedigits");
my $output      = $input->param("output");
my $basename    = $input->param("basename");
our $sep        = $input->param("sep");
$sep = "\t" if ($sep eq 'tabulation');
my $item_itype;
if(C4::Context->preference('item-level_itypes')) {
	$item_itype = "items\.itype"
} else {
	$item_itype = "itemtype";
}
if(C4::Context->preference('marcflavour') ne "UNIMARC" && ($line=~ /publicationyear/ )) {
    $line = "copyrightdate";
}
if(C4::Context->preference('marcflavour') ne "UNIMARC" && ($column =~ /publicationyear/ )) {
    $column = "copyrightdate";
}

my ($template, $borrowernumber, $cookie)
	= get_template_and_user({template_name => $fullreportname,
				query => $input,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {reports => '*'},
				debug => 1,
				});
$template->param(do_it => $do_it);
if ($do_it) {
	my $results = calculate($line, $column, $deweydigits, $lccndigits, $cotedigits, \@filters);
	if ($output eq "screen"){
		$template->param(mainloop => $results);
		output_html_with_http_headers $input, $cookie, $template->output;
		exit;
	} else {
		print $input->header(-type => 'application/vnd.sun.xml.calc',
                                     -encoding    => 'utf-8',
							 -attachment=>"$basename.csv",
							 -name=>"$basename.csv" );
		my $cols  = @$results[0]->{loopcol};
		my $lines = @$results[0]->{looprow};
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
		exit;
	}
} else {
	my $dbh = C4::Context->dbh;
	my @values;
	my %labels;
	my $count=0;
	my $req;
	my @select;
	# FIXME: no such field "dewey"
	# $req = $dbh->prepare("select count(dewey) from biblioitems ");
	# $req->execute;
	my $hasdewey = 0;

# (rch) biblioitems.lccn is mapped to lccn MARC21 010$a in default framework.
# This is not the LC Classification.  It's the Control Number.
# So I'm just going to remove this bit.  Call Number is handled in itemcallnumber.
#
	my $haslccn = 0;
#	$req = $dbh->prepare( "select count(lccn) from biblioitems ");
#	$req->execute;
#	my $hlghtlccn;
#	while (my ($value) =$req->fetchrow) {
#		$hlghtlccn = !($hasdewey);
#		$haslccn =1 if (($value>2) and (! $haslccn));
#		$count++ if (($value) and (! $haslccn));
#		push @select, $value;
#	}
#   my $CGIlccn = {
#       values   => \@select,
#   };

# No need to test for data here.  If you don't have itemcallnumbers, you probably know it.
# FIXME: Hardcoding to 5 chars on itemcallnum. 
#
    my $hascote = 1;
    my $highcote = 5;

	$req = $dbh->prepare("select itemtype, description from itemtypes order by description");
	$req->execute;
	my $CGIitemtype = $req->fetchall_arrayref({});

	my $authvals = GetKohaAuthorisedValues("items.ccode");
	my @authvals;
	foreach (sort {$authvals->{$a} cmp $authvals->{$b} || $a cmp $b} keys %$authvals) {
		push @authvals, { code => $_, description => $authvals->{$_} };
	}
	
	my $locations = GetKohaAuthorisedValues("items.location");
	my @locations;
	foreach (sort keys %$locations) {
		push @locations, { code => $_, description => "$_ - " . $locations->{$_} };
	}
	
	my @mime  = ( map { +{type =>$_} } (split /[;:]/, 'CSV') ); # FIXME translation
	
	$template->param(hasdewey=>$hasdewey,
					haslccn   => $haslccn,
					hascote   => $hascote,
					CGIItemType => $CGIitemtype,
					CGIBranch    => GetBranchesLoop(C4::Context->userenv->{'branch'}),
					locationloop => \@locations,
					authvals     => \@authvals,
					CGIextChoice => \@mime,
					CGIsepChoice => GetDelimiterChoices,
					item_itype => $item_itype
					);

}
output_html_with_http_headers $input, $cookie, $template->output;

## End of Main Body


sub calculate {
	my ($line, $column, $deweydigits, $lccndigits, $cotedigits, $filters) = @_;
	my @mainloop;
	my @loopfooter;
	my @loopcol;
	my @loopline;
	my @looprow;
	my %globalline;
	my $grantotal =0;
    my $barcodelike   = @$filters[13];
    my $barcodefilter = @$filters[14];
    my $not;
    
# extract parameters
	my $dbh = C4::Context->dbh;

# if barcodefilter is empty set as %
if($barcodefilter){
    # Check if barcodefilter is "like" or "not like"
    if(!$barcodelike){
        $not = "not";
    }
    # Change * to %
    $barcodefilter =~ s/\*/%/g;
}

# Filters
# Checking filters
#
	my @loopfilter;
	for (my $i=0;$i<=12;$i++) {
		my %cell;
		if ( @$filters[$i] ) {
			if ((($i==1) or ($i==3) or ($i==5) or ($i==9)) and (@$filters[$i-1])) {
				$cell{err} = 1 if (@$filters[$i]<@$filters[$i-1]) ;
			}
			$cell{filter} .= @$filters[$i];
			$cell{crit} .=
				($i== 0) ? "Dewey Classification From" :
				($i== 1) ? "Dewey Classification To"   :
				($i== 2) ? "Lccn Classification From"  :
				($i== 3) ? "Lccn Classification To"    :
				($i== 4) ? "Item CallNumber From"  :
				($i== 5) ? "Item CallNumber To"    :
				($i== 6) ? "Item type"             :
				($i== 7) ? "Publisher"                 :
				($i== 8) ? "Publication year From"     :
				($i== 9) ? "Publication year To"       :
				($i==10) ? "Library :"                  :
				($i==11) ? "Shelving Location :"                :
				($i==12) ? "Collection Code :"            : '';
			push @loopfilter, \%cell;
		}
	}
	
#	warn map {"filtres $_\n"} @filters[0..3];

	my @linefilter;
 	$linefilter[0] = @$filters[0] if ($line =~ /dewey/ )  ;
 	$linefilter[1] = @$filters[1] if ($line =~ /dewey/ )  ;
 	$linefilter[0] = @$filters[2] if ($line =~ /lccn/ )  ;
 	$linefilter[1] = @$filters[3] if ($line =~ /lccn/ )  ;
 	$linefilter[0] = @$filters[4] if ($line =~ /items\.itemcallnumber/ )  ;
 	$linefilter[1] = @$filters[5] if ($line =~ /items\.itemcallnumber/ )  ;
	if (C4::Context->preference('item-level_itypes')) {
 		$linefilter[0] = @$filters[6] if ($line =~ /items\.itype/ )  ;
	} else {
 		$linefilter[0] = @$filters[6] if ($line =~ /itemtype/ )  ;
	}
 	$linefilter[0] = @$filters[7] if ($line =~ /publishercode/ ) ;
 	$linefilter[0] = @$filters[8] if ($line =~ /publicationyear/ ) ;
 	$linefilter[1] = @$filters[9] if ($line =~ /publicationyear/ ) ;
 	$linefilter[0] = @$filters[10] if ($line =~ /items\.homebranch/ ) ;
 	$linefilter[0] = @$filters[11] if ($line =~ /items\.location/ ) ;
 	$linefilter[0] = @$filters[12] if ($line =~ /items\.ccode/ ) ;

 	my @colfilter ;
 	$colfilter[0] = @$filters[0] if ($column =~ /dewey/ )  ;
 	$colfilter[1] = @$filters[1] if ($column =~ /dewey/ )  ;
 	$colfilter[0] = @$filters[2] if ($column =~ /lccn/ )  ;
 	$colfilter[1] = @$filters[3] if ($column =~ /lccn/ )  ;
 	$colfilter[0] = @$filters[4] if ($column =~ /items\.itemcallnumber/ )  ;
 	$colfilter[1] = @$filters[5] if ($column =~ /items\.itemcallnumber/ )  ;
	if (C4::Context->preference('item-level_itypes')) {
 		$colfilter[0] = @$filters[6] if ($column =~ /items\.itype/ )  ;
	} else {
 		$colfilter[0] = @$filters[6] if ($column =~ /itemtype/ )  ;
	}
 	$colfilter[0] = @$filters[7] if ($column =~ /publishercode/ ) ;
 	$colfilter[0] = @$filters[8] if ($column =~ /publicationyear/ ) ;
 	$colfilter[1] = @$filters[9] if ($column =~ /publicationyear/ ) ;
 	$colfilter[0] = @$filters[10] if ($column =~ /items\.homebranch/ ) ;
 	$colfilter[0] = @$filters[11] if ($column =~ /items\.location/ ) ;
 	$colfilter[0] = @$filters[12] if ($column =~ /items\.ccode/ ) ;

# 1st, loop rows.
	my $linefield;
	if (($line =~/dewey/)  and ($deweydigits)) {
		$linefield .="left($line,$deweydigits)";
	} elsif (($line=~/lccn/) and ($lccndigits)) {
		$linefield .="left($line,$lccndigits)";
	} elsif (($line=~/items.itemcallnumber/) and ($cotedigits)) {
		$linefield .="left($line,$cotedigits)";
	}else {
		$linefield .= $line;
	}

	my $strsth = "SELECT DISTINCTROW $linefield FROM biblioitems 
                    INNER JOIN items USING (biblioitemnumber)
                    INNER JOIN biblio ON (biblioitems.biblionumber = biblio.biblionumber)
	              WHERE $line IS NOT NULL ";
    $strsth .= " AND barcode $not LIKE ? " if ($barcodefilter);
	if ( @linefilter ) {
		if ($linefilter[1]){
			$strsth .= " AND $line >= ? " ;
			$strsth .= " AND $line <= ? " ;
		} elsif ($linefilter[0]) {
			$linefilter[0] =~ s/\*/%/g;
			$strsth .= " AND $line LIKE ? " ;
		}
	}
	$strsth .=" ORDER BY $linefield";
	$debug and print STDERR "catalogue_stats SQL: $strsth\n";

	my $sth = $dbh->prepare( $strsth );
	if (( @linefilter ) and ($linefilter[1])){
		$sth->execute($barcodefilter,$linefilter[0],$linefilter[1]);
	} elsif ($barcodefilter,$linefilter[0]) {
		$sth->execute($barcodefilter,$linefilter[0]);
	} elsif ($barcodefilter) {
		$sth->execute($barcodefilter);
	}else{
	    $sth->execute();
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
	if (($column =~/dewey/)  and ($deweydigits)) {
		$colfield = "left($column,$deweydigits)";
	}elsif (($column=~/lccn/) and ($lccndigits)) {
		$colfield = "left($column,$lccndigits)";
	}elsif (($column=~/itemcallnumber/) and ($cotedigits)) {
		$colfield = "left($column,$cotedigits)";
	}else {
		$colfield = $column;
	}
	
	my $strsth2 = "
	SELECT distinctrow $colfield
	FROM   biblioitems
	INNER JOIN items
		USING (biblioitemnumber)
    INNER JOIN biblio
        ON (biblioitems.biblionumber = biblio.biblionumber)
	WHERE $column IS NOT NULL ";
	$strsth2 .= " AND barcode $not LIKE ?" if $barcodefilter;
	
	if (( @colfilter ) and ($colfilter[1])) {
		$strsth2 .= " AND $column> ? AND $column< ?";
	}elsif ($colfilter[0]){
		$colfilter[0] =~ s/\*/%/g;
		$strsth2 .= " AND $column LIKE ? ";
	} 
	$strsth2 .= " ORDER BY $colfield";
	$debug and print STDERR "SQL: $strsth2";
	my $sth2 = $dbh->prepare( $strsth2 );
	if ((@colfilter) and ($colfilter[1])) {
		$sth2->execute($barcodefilter,$colfilter[0],$colfilter[1]);
	} elsif ($colfilter[0]){
		$sth2->execute($barcodefilter,$colfilter[0]);
	} elsif ($barcodefilter){
	    $sth2->execute($barcodefilter);
	} else {
		$sth2->execute();
	}
 	while (my ($celvalue) = $sth2->fetchrow) {
 		my %cell;
		my %ft;
		if ($celvalue) {
			$cell{coltitle} = $celvalue;
#		} else {
#			$cell{coltitle} = "";
		}
 		$ft{totalcol} = 0;
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
    my $strcalc = "
        SELECT $linefield, $colfield, count(*)
        FROM biblioitems
        INNER JOIN items ON (items.biblioitemnumber = biblioitems.biblioitemnumber)
        INNER JOIN biblio ON (biblioitems.biblionumber = biblio.biblionumber)
        WHERE 1 ";
	$strcalc .= "AND barcode $not like ? " if ($barcodefilter); 
	
	if (@$filters[0]){
		@$filters[0]=~ s/\*/%/g;
		$strcalc .= " AND dewey >" . @$filters[0];
	}
	if (@$filters[1]){
		@$filters[1]=~ s/\*/%/g ;
		$strcalc .= " AND dewey <" . @$filters[1];
	}
	if (@$filters[2]){
		@$filters[2]=~ s/\*/%/g ;
		$strcalc .= " AND lccn >" . @$filters[2];
	}
	if (@$filters[3]){
		@$filters[3]=~ s/\*/%/g;
		$strcalc .= " AND lccn <" . @$filters[3];
	}
	if (@$filters[4]){
		@$filters[4]=~ s/\*/%/g ;
		$strcalc .= " AND items.itemcallnumber >=" . $dbh->quote(@$filters[4]);
	}
	
	if (@$filters[5]){
		@$filters[5]=~ s/\*/%/g;
		$strcalc .= " AND items.itemcallnumber <=" . $dbh->quote(@$filters[5]);
	}
	
	if (@$filters[6]){
		@$filters[6]=~ s/\*/%/g;
		$strcalc .= " AND " . 
			(C4::Context->preference('item-level_itypes') ? 'items.itype' : 'biblioitems.itemtype')
			. " LIKE '" . @$filters[6] ."'";
	}
	
	if (@$filters[7]){
		@$filters[7]=~ s/\*/%/g;
		@$filters[7].="%" unless @$filters[7]=~/%/;
		$strcalc .= " AND biblioitems.publishercode LIKE \"" . @$filters[7] ."\"";
	}
	if (@$filters[8]){
		@$filters[8]=~ s/\*/%/g;
        $strcalc .= " AND " .
        (C4::Context->preference('marcflavour') eq 'UNIMARC' ? 'publicationyear' : 'copyrightdate')
        . ">" . @$filters[8];
	}
	if (@$filters[9]){
		@$filters[9]=~ s/\*/%/g;
        $strcalc .= " AND " .
        (C4::Context->preference('marcflavour') eq 'UNIMARC' ? 'publicationyear' : 'copyrightdate')
        . "<" . @$filters[9];
	}
	if (@$filters[10]){
		@$filters[10]=~ s/\*/%/g;
		$strcalc .= " AND items.homebranch LIKE '" . @$filters[10] ."'";
	}
	if (@$filters[11]){
		@$filters[11]=~ s/\*/%/g;
		$strcalc .= " AND items.location LIKE '" . @$filters[11] ."'";
	}
	if (@$filters[12]){
		@$filters[12]=~ s/\*/%/g;
		$strcalc .= " AND items.ccode  LIKE '" . @$filters[12] ."'";
	}
	
	$strcalc .= " group by $linefield, $colfield order by $linefield,$colfield";
	$debug and warn "SQL: $strcalc";
	my $dbcalc = $dbh->prepare($strcalc);
	if($barcodefilter){
	   $dbcalc->execute($barcodefilter);
	}else{
	   $dbcalc->execute();
	}
#	warn "filling table";
	my $emptycol; 
	while (my ($row, $col, $value) = $dbcalc->fetchrow) {
#		warn "filling table $row / $col / $value ";
		$emptycol = 1    if (!defined($col));
		$col = "zzEMPTY" if (!defined($col));
		$row = "zzEMPTY" if (!defined($row));
		
		$table{$row}->{$col}+=$value;
		$table{$row}->{totalrow}+=$value;
		$grantotal += $value;
	}

# 	my %cell = {rowtitle => 'zzROWEMPTY'};
# 	push @loopline,\%cell;
# 	undef %cell;
# 	my %cell;
# 	%cell = {coltitle => "zzEMPTY"};
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
						'hilighted' => ($hilighted *= -1 > 0),
						'totalrow' => $table{$row}->{totalrow}
					};
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
