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

=head1 NAME

plugin that shows a stats on borrowers

=head1 DESCRIPTION

=over 2

=cut

my $input = new CGI;
my $do_it=$input->param('do_it');
my $fullreportname = "reports/catalogue_stats.tmpl";
my $line = $input->param("Line");
my $column = $input->param("Column");
my @filters = $input->param("Filter");
my $deweydigits = $input->param("deweydigits");
my $lccndigits = $input->param("lccndigits");
my $cotedigits = $input->param("cotedigits");
my $output = $input->param("output");
my $basename = $input->param("basename");
my $mime = $input->param("MIME");
my $del = $input->param("sep");

my ($template, $borrowernumber, $cookie)
	= get_template_and_user({template_name => $fullreportname,
				query => $input,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {reports => 1},
				debug => 1,
				});
$template->param(do_it => $do_it);
if ($do_it) {
	my $results = calculate($line, $column, $deweydigits, $lccndigits, $cotedigits, \@filters);
	if ($output eq "screen"){
		$template->param(mainloop => $results);
		output_html_with_http_headers $input, $cookie, $template->output;
		exit(1);
	} else {
		print $input->header(-type => 'application/vnd.sun.xml.calc',
                                     -encoding    => 'utf-8',
							 -attachment=>"$basename.csv",
							 -name=>"$basename.csv" );
		my $cols = @$results[0]->{loopcol};
		my $lines = @$results[0]->{looprow};
		my $sep;
		$sep =C4::Context->preference("delimiter");
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
		exit(1);
	}
} else {
	my $dbh = C4::Context->dbh;
	my @values;
	my %labels;
	my $count=0;
	my $req;
	$req = $dbh->prepare("select count(dewey) from biblioitems ");
	$req->execute;
	my $hasdewey;
	my @select;
# 	push @select,"";
	while (my ($value) =$req->fetchrow) {
		$hasdewey =1 if (($value>2) and (! $hasdewey));
		$count++ if (($value>2) and (! $hasdewey));
#		push @select, $value;
	}
# 	my $CGIdewey=CGI::scrolling_list( -name     => 'Filter',
# 				-id => 'Filter',
# 				-values   => \@select,
# 				-size     => 1,
# 				-multiple => 0 );
	
	$req = $dbh->prepare( "select count(lccn) from biblioitems ");
	$req->execute;
# 	undef @select;
# 	push @select,"";
	my $haslccn;
	my $hlghtlccn;
	while (my ($value) =$req->fetchrow) {
		$hlghtlccn = !($hasdewey);
		$haslccn =1 if (($value>2) and (! $haslccn));
		$count++ if (($value) and (! $haslccn));
#		push @select, $value;
	}
# 	my $CGIlccn=CGI::scrolling_list( -name     => 'Filter',
# 				-id => 'Filter',
# 				-values   => \@select,
# 				-size     => 1,
# 				-multiple => 0 );
	
	$req = $dbh->prepare("select count(itemcallnumber) from items");
	$req->execute;
#	undef @select;
#	push @select,"";
	my $hascote;
	my $hlghtcote;
	while (my ($value) =$req->fetchrow) {
		$hascote =1 if (($value>2) and (! $hascote));
		$count++ if (($value) and (! $hascote));
		$hlghtcote = (($hasdewey) and ($haslccn)) or (!($hasdewey) and !($haslccn));
#		push @select, $value;
	}
# 	my $CGIcote=CGI::scrolling_list( -name     => 'Filter',
# 				-id => 'Filter',
# 				-values   => \@select,
# 				-size     => 1,
# 				-multiple => 0 );
	$count++;
	my $hglghtDT =$count % 2;
#	warn "highlightDT ".$hglghtDT;
	$count++;
	my $hglghtPub =$count % 2;
#	warn "highlightPub ".$hglghtPub;
	$count++;
	my $hglghtPY =$count % 2;
#	warn "highlightPY ".$hglghtPY;
	$count++;
	my $hglghtHB =$count % 2;
#	warn "highlightHB ".$hglghtHB;
	$count++;
	my $hglghtLOC =$count % 2;
#	warn "highlightLOC ".$hglghtLOC;
	
	
	$req = $dbh->prepare("select itemtype from itemtypes order by itemtype");
	$req->execute;
	undef @select;
	push @select,"";
	while (my ($value) =$req->fetchrow) {
		push @select, $value;
	}
	my $CGIitemtype=CGI::scrolling_list( -name     => 'Filter',
				-id => 'itemtype',
				-values   => \@select,
				-size     => 1,
				-multiple => 0 );
	
# 	$req = $dbh->prepare("select distinctrow left(publishercode,75) from biblioitems order by publishercode");
# 	$req->execute;
# 	undef @select;
# 	push @select,"";
# 	while (my ($value) =$req->fetchrow) {
# 		push @select, $value;
# 	}
# 	my $CGIpublisher=CGI::scrolling_list( -name     => 'Filter',
# 				-id => 'Filter',
# 				-values   => \@select,
# 				-size     => 1,
# 				-multiple => 0 );

	undef @select;
	push @select,"";
	my $branches=GetBranches();
	my %select_branches;
	$select_branches{""} = "";
	foreach my $branch (keys %$branches) {
		push @select, $branch;
		$select_branches{$branch} = $branches->{$branch}->{'branchname'};
	}
	my $CGIbranch=CGI::scrolling_list( -name     => 'Filter',
				-id => 'branch',
				-values   => \@select,
				-labels   => \%select_branches,
				-size     => 1,
				-multiple => 0 );
	
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
	
	my @mime = ( C4::Context->preference("MIME") );
	foreach my $mime (@mime){
#		warn "".$mime;
	}
	
	my $CGIextChoice=CGI::scrolling_list(
				-name => 'MIME',
				-id => 'MIME',
				-values   => \@mime,
				-size     => 1,
				-multiple => 0 );
	
	my @dels = ( C4::Context->preference("delimiter") );
	my $CGIsepChoice=CGI::scrolling_list(
				-name => 'sep',
				-id => 'sep',
				-values   => \@dels,
				-size     => 1,
				-multiple => 0 );
	
	$template->param(hasdewey=>$hasdewey,
#					CGIFromDeweyClass => $CGIdewey,
#					CGIToDeweyClass => $CGIdewey,
					haslccn=> $haslccn,
					hlghtlccn => $hlghtlccn,
#					CGIFromLoCClass => $CGIlccn,
#					CGIToLoCClass => $CGIlccn,
					hascote=> $hascote,
					hlghtcote => $hlghtcote,
					hglghtDT => $hglghtDT,
					hglghtPub => $hglghtPub,
					hglghtPY => $hglghtPY,
					hglghtHB => $hglghtHB,
					hglghtLOC => $hglghtLOC,
#					CGIFromCoteClass => $CGIcote,
#					CGIToCoteClass => $CGIcote,
					CGIItemType => $CGIitemtype,
# 					CGIFromPublicationYear => $CGIpublicationyear,
# 					CGIToPublicationYear => $CGIpublicationyear,
#					CGIPublisher => $CGIpublisher,
					CGIBranch => $CGIbranch,
					CGILocation => $CGIlocation,
					CGIextChoice => $CGIextChoice,
					CGIsepChoice => $CGIsepChoice
					);

}
output_html_with_http_headers $input, $cookie, $template->output;



sub calculate {
	my ($line, $column, $deweydigits, $lccndigits, $cotedigits, $filters) = @_;
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
	for (my $i=0;$i<=11;$i++) {
		my %cell;
		if ( @$filters[$i] ) {
			if ((($i==1) or ($i==3) or ($i==5) or ($i==9)) and (@$filters[$i-1])) {
				$cell{err} = 1 if (@$filters[$i]<@$filters[$i-1]) ;
			}
			$cell{filter} .= @$filters[$i];
			$cell{crit} .="Dewey Classification From" if ($i==0);
			$cell{crit} .="Dewey Classification To" if ($i==1);
			$cell{crit} .="Lccn Classification From" if ($i==2);
			$cell{crit} .="Lccn Classification To" if ($i==3);
			$cell{crit} .="Cote Classification From" if ($i==4);
			$cell{crit} .="Cote Classification To" if ($i==5);
			$cell{crit} .="Document type" if ($i==6);
			$cell{crit} .="Publisher" if ($i==7);
			$cell{crit} .="Publication year From" if ($i==8);
			$cell{crit} .="Publication year To" if ($i==9);
			$cell{crit} .="Branch :" if ($i==10);
			$cell{crit} .="Location:" if ($i==11);
			push @loopfilter, \%cell;
		}
	}
	
	my @linefilter;
#	warn "filtres ".@filters[0];
#	warn "filtres ".@filters[1];
#	warn "filtres ".@filters[2];
#	warn "filtres ".@filters[3];
	
 	$linefilter[0] = @$filters[0] if ($line =~ /dewey/ )  ;
 	$linefilter[1] = @$filters[1] if ($line =~ /dewey/ )  ;
 	$linefilter[0] = @$filters[2] if ($line =~ /lccn/ )  ;
 	$linefilter[1] = @$filters[3] if ($line =~ /lccn/ )  ;
 	$linefilter[0] = @$filters[4] if ($line =~ /items.itemcallnumber/ )  ;
 	$linefilter[1] = @$filters[5] if ($line =~ /items.itemcallnumber/ )  ;
 	$linefilter[0] = @$filters[6] if ($line =~ /itemtype/ )  ;
 	$linefilter[0] = @$filters[7] if ($line =~ /publishercode/ ) ;
 	$linefilter[0] = @$filters[8] if ($line =~ /publicationyear/ ) ;
 	$linefilter[1] = @$filters[9] if ($line =~ /publicationyear/ ) ;
 	@linefilter[0] = @$filters[10] if ($line =~ /items.homebranch/ ) ;
 	@linefilter[0] = @$filters[11] if ($line =~ /items.location/ ) ;
# 
 	my @colfilter ;
 	$colfilter[0] = @$filters[0] if ($column =~ /dewey/ )  ;
 	$colfilter[1] = @$filters[1] if ($column =~ /dewey/ )  ;
 	$colfilter[0] = @$filters[2] if ($column =~ /lccn/ )  ;
 	$colfilter[1] = @$filters[3] if ($column =~ /lccn/ )  ;
 	$colfilter[0] = @$filters[4] if ($column =~ /itemcallnumber/ )  ;
 	$colfilter[1] = @$filters[5] if ($column =~ /itemcallnumber/ )  ;
 	$colfilter[0] = @$filters[6] if ($column =~ /itemtype/ )  ;
 	$colfilter[0] = @$filters[7] if ($column =~ /publishercode/ ) ;
 	$colfilter[0] = @$filters[8] if ($column =~ /publicationyear/ ) ;
 	$colfilter[1] = @$filters[9] if ($column =~ /publicationyear/ ) ;
 	@colfilter[0] = @$filters[10] if ($column =~ /items.homebranch/ ) ;
 	@colfilter[0] = @$filters[11] if ($column =~ /items.location/ ) ;

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
	
	
	my $strsth;
	$strsth .= "select distinctrow $linefield from biblioitems left join items on (items.biblioitemnumber = biblioitems.biblioitemnumber) where $line is not null ";
	if ( @linefilter ) {
		if ($linefilter[1]){
			$strsth .= " and $line >= ? " ;
			$strsth .= " and $line <= ? " ;
		} elsif ($linefilter[0]) {
			$linefilter[0] =~ s/\*/%/g;
			$strsth .= " and $line LIKE ? " ;
		}
	}
	$strsth .=" order by $linefield";
	warn "". $strsth;
	
	my $sth = $dbh->prepare( $strsth );
	if (( @linefilter ) and ($linefilter[1])){
		$sth->execute($linefilter[0],$linefilter[1]);
	} elsif ($linefilter[0]) {
		$sth->execute($linefilter[0]);
	} else {
		$sth->execute;
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
		$colfield .="left($column,$deweydigits)";
	}elsif (($column=~/lccn/) and ($lccndigits)) {
		$colfield .="left($column,$lccndigits)";
	}elsif (($column=~/itemcallnumber/) and ($cotedigits)) {
		$colfield .="left($column,$cotedigits)";
	}else {
		$colfield .= $column;
	}
	
	my $strsth2;
	$strsth2 .= "select distinctrow $colfield from biblioitems left join items on (items.biblioitemnumber = biblioitems.biblioitemnumber) where $column is not null ";
	if (( @colfilter ) and ($colfilter[1])) {
		$strsth2 .= " and $column> ? and $column< ?";
	}elsif ($colfilter[0]){
		$colfilter[0] =~ s/\*/%/g;
		$strsth2 .= " and $column LIKE ? ";
	} 
	$strsth2 .= " order by $colfield";
	warn "". $strsth2;
	my $sth2 = $dbh->prepare( $strsth2 );
	if ((@colfilter) and ($colfilter[1])) {
		$sth2->execute($colfilter[0],$colfilter[1]);
	} elsif ($colfilter[0]){
		$sth2->execute($colfilter[0]);
	} else {
		$sth2->execute;
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
	my $strcalc .= "SELECT $linefield, $colfield, count( * ) FROM biblioitems LEFT JOIN  items ON (items.biblioitemnumber = biblioitems.biblioitemnumber) WHERE 1";
	if (@$filters[0]){
		@$filters[0]=~ s/\*/%/g;
		$strcalc .= " AND dewey >" . @$filters[0] ."";
	}
	if (@$filters[1]){
		@$filters[1]=~ s/\*/%/g ;
		$strcalc .= " AND dewey <" . @$filters[1] ."";
		
	}
	if (@$filters[2]){
		@$filters[2]=~ s/\*/%/g ;
		$strcalc .= " AND lccn >" . @$filters[2] ."" ;
	}
	if (@$filters[3]){
		@$filters[3]=~ s/\*/%/g;
		$strcalc .= " AND lccn <" . @$filters[3] ."" ;
	}
	if (@$filters[4]){
		@$filters[4]=~ s/\*/%/g ;
		$strcalc .= " AND items.itemcallnumber >=" . $dbh->quote(@$filters[4]) ."" ;
	}
	
	if (@$filters[5]){
		@$filters[5]=~ s/\*/%/g;
		$strcalc .= " AND items.itemcallnumber <=" . $dbh->quote(@$filters[5]) ."" ;
	}
	
	if (@$filters[6]){
		@$filters[6]=~ s/\*/%/g;
		$strcalc .= " AND biblioitems.itemtype like '" . @$filters[6] ."'";
	}
	
	if (@$filters[7]){
		@$filters[7]=~ s/\*/%/g;
		@$filters[7].="%" unless @$filters[7]=~/%/;
		$strcalc .= " AND biblioitems.publishercode like \"" . @$filters[7] ."\"";
	}
	if (@$filters[8]){
		@$filters[8]=~ s/\*/%/g;
		$strcalc .= " AND publicationyear >" . @$filters[8] ."" ;
	}
	if (@$filters[9]){
		@$filters[9]=~ s/\*/%/g;
		$strcalc .= " AND publicationyear <" . @$filters[9] ."";
	}
	if (@$filters[10]){
		@$filters[10]=~ s/\*/%/g;
		$strcalc .= " AND items.homebranch like '" . @$filters[10] ."'";
	}
	if (@$filters[11]){
		@$filters[11]=~ s/\*/%/g;
		$strcalc .= " AND items.location like '" . @$filters[11] ."'" if ( @$filters[11] );
	}
	
	$strcalc .= " group by $linefield, $colfield order by $linefield,$colfield";
	warn "". $strcalc;
	my $dbcalc = $dbh->prepare($strcalc);
	$dbcalc->execute;
#	warn "filling table";
	
	my $emptycol; 
	while (my ($row, $col, $value) = $dbcalc->fetchrow) {
#		warn "filling table $row / $col / $value ";
		$emptycol = 1 if ($col eq undef);
		$col = "zzEMPTY" if ($col eq undef);
		$row = "zzEMPTY" if ($row eq undef);
		
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
						'hilighted' => ($hilighted >0),
						'totalrow' => $table{$row}->{totalrow}
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
