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
use CGI;
use List::MoreUtils qw/uniq/;

use C4::Auth;
use C4::Context;
use C4::Branch; # GetBranches
use C4::Koha;
use C4::Dates;
use C4::Acquisition;
use C4::Output;
use C4::Reports;
use C4::Circulation;
use C4::Members::AttributeTypes;
use C4::Dates qw/format_date format_date_in_iso/;
use Date::Calc qw(
  Today
  Add_Delta_YM
  );

=head1 NAME

plugin that shows a stats on borrowers

=head1 DESCRIPTION

=over 2

=cut

my $input = new CGI;
my $do_it=$input->param('do_it');
my $fullreportname = "reports/borrowers_stats.tt";
my $line = $input->param("Line");
my $column = $input->param("Column");
my @filters = $input->param("Filter");
$filters[3]=format_date_in_iso($filters[3]);
$filters[4]=format_date_in_iso($filters[4]);
my $digits = $input->param("digits");
our $period = $input->param("period");
my $borstat = $input->param("status");
my $borstat1 = $input->param("activity");
my $output = $input->param("output");
my $basename = $input->param("basename");
our $sep     = $input->param("sep");
$sep = "\t" if ($sep and $sep eq 'tabulation');
my $selected_branch; # = $input->param("?");

our $branches = GetBranches;

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
        my $attributes;
        if (C4::Context->preference('ExtendedPatronAttributes')) {
            $attributes = parse_extended_patron_attributes($input);
        }
	my $results = calculate($line, $column, $digits, $borstat,$borstat1 ,\@filters, $attributes);
	if ($output eq "screen"){
		$template->param(mainloop => $results);
		output_html_with_http_headers $input, $cookie, $template->output;
	} else {
		print $input->header(-type => 'application/vnd.sun.xml.calc',
                         -encoding => 'utf-8',
                             -name => "$basename.csv",
                       -attachment => "$basename.csv");
		my $cols = @$results[0]->{loopcol};
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
	}
	exit;	# exit after do_it, regardless
} else {
	my $dbh = C4::Context->dbh;
	my $req;
	$template->param(  CAT_LOOP => &catcode_aref);
	my @branchloop;
	foreach (sort {$branches->{$a}->{branchname} cmp $branches->{$b}->{branchname}} keys %$branches) {
		my $line = {branchcode => $_, branchname => $branches->{$_}->{branchname} || 'UNKNOWN'};
		$line->{selected} = 'selected' if ($selected_branch and $selected_branch eq $_);
		push @branchloop, $line;
	}
	$template->param(BRANCH_LOOP => \@branchloop);
 	$req = $dbh->prepare("SELECT DISTINCTROW zipcode FROM borrowers WHERE zipcode IS NOT NULL AND zipcode <> '' ORDER BY zipcode");
 	$req->execute;
	$template->param(   ZIP_LOOP => $req->fetchall_arrayref({}));
	$req = $dbh->prepare("SELECT authorised_value,lib FROM authorised_values WHERE category='Bsort1' ORDER BY lib");
 	$req->execute;
	$template->param( SORT1_LOOP => $req->fetchall_arrayref({}));
	$req = $dbh->prepare("SELECT DISTINCTROW sort2 AS value FROM borrowers WHERE sort2 IS NOT NULL AND sort2 <> '' ORDER BY sort2 LIMIT 200");
		# More than 200 items in a dropdown is not going to be useful anyway, and w/ 50,000 patrons we can destory DB performance.
	$req->execute;
	$template->param( SORT2_LOOP => $req->fetchall_arrayref({}));
	
    my $CGIextChoice = ( 'CSV' ); # FIXME translation
	my $CGIsepChoice=GetDelimiterChoices;
	$template->param(
		CGIextChoice => $CGIextChoice,
		CGIsepChoice => $CGIsepChoice,
    );
    if (C4::Context->preference('ExtendedPatronAttributes')) {
        $template->param(ExtendedPatronAttributes => 1);
        patron_attributes_form($template);
    }
}
output_html_with_http_headers $input, $cookie, $template->output;

sub catcode_aref {
	my $req = C4::Context->dbh->prepare("SELECT categorycode, description FROM categories ORDER BY description");
	$req->execute;
	return $req->fetchall_arrayref({});
}
sub catcodes_hash {
	my %cathash;
	my $catcodes = &catcode_aref;
	foreach (@$catcodes) {
		$cathash{$_->{categorycode}} = ($_->{description} || 'NO_DESCRIPTION') . " ($_->{categorycode})";
	}
	return %cathash;
}

sub calculate {
	my ($line, $column, $digits, $status, $activity, $filters, $attr_filters) = @_;

	my @mainloop;
	my @loopfooter;
	my @loopcol;
	my @loopline;
	my @looprow;
	my %globalline;
	my $grantotal =0;
# extract parameters
	my $dbh = C4::Context->dbh;

    # check parameters
    my @valid_names = qw(categorycode zipcode branchcode sex sort1 sort2);
    my @attribute_types = C4::Members::AttributeTypes::GetAttributeTypes;
    if ($line =~ /^patron_attr\.(.*)/) {
        my $attribute_type = $1;
        return unless (grep {$attribute_type eq $_->{code}} @attribute_types);
    } else {
        return unless (grep /^$line$/, @valid_names);
    }
    if ($column =~ /^patron_attr\.(.*)/) {
        my $attribute_type = $1;
        return unless (grep {$attribute_type eq $_->{code}} @attribute_types);
    } else {
        return unless (grep /^$column$/, @valid_names);
    }
    return if ($digits and $digits !~ /^\d+$/);
    return if ($status and (grep /^$status$/, qw(debarred gonenoaddress lost)) == 0);
    return if ($activity and (grep /^$activity$/, qw(active nonactive)) == 0);

    # Filters
    my $linefilter;
    if    ( $line =~ /categorycode/ ) { $linefilter = @$filters[0]; }
    elsif ( $line =~ /zipcode/ )      { $linefilter = @$filters[1]; }
    elsif ( $line =~ /branchcode/ )   { $linefilter = @$filters[2]; }
    elsif ( $line =~ /sex/ )          { $linefilter = @$filters[5]; }
    elsif ( $line =~ /sort1/ )        { $linefilter = @$filters[6]; }
    elsif ( $line =~ /sort2/ )        { $linefilter = @$filters[7]; }
    elsif ( $line =~ /^patron_attr\.(.*)$/ ) { $linefilter = $attr_filters->{$1}; }
    else  { $linefilter = ''; }

    my $colfilter;
    if    ( $column =~ /categorycode/ ) { $colfilter = @$filters[0]; }
    elsif ( $column =~ /zipcode/ )      { $colfilter = @$filters[1]; }
    elsif ( $column =~ /branchcode/)    { $colfilter = @$filters[2]; }
    elsif ( $column =~ /sex/)           { $colfilter = @$filters[5]; }
    elsif ( $column =~ /sort1/)         { $colfilter = @$filters[6]; }
    elsif ( $column =~ /sort2/)         { $colfilter = @$filters[7]; }
    elsif ( $column =~ /^patron_attr\.(.*)$/) { $colfilter = $attr_filters->{$1}; }
    else  { $colfilter = ''; }

    my @loopfilter;
    foreach my $i (0 .. scalar @$filters) {
        my %cell;
        if ( @$filters[$i] ) {
            if ($i == 3 or $i == 4) {
                $cell{filter} = format_date(@$filters[$i]);
            } else {
                $cell{filter} = @$filters[$i];
            }

            if    ( $i == 0)  { $cell{crit} = "Cat code"; }
            elsif ( $i == 1 ) { $cell{crit} = "Zip code"; }
            elsif ( $i == 2 ) { $cell{crit} = "Branch code"; }
            elsif ( $i == 3 ||
                    $i == 4 ) { $cell{crit} = "Date of birth"; }
            elsif ( $i == 5 ) { $cell{crit} = "Sex"; }
            elsif ( $i == 6 ) { $cell{crit} = "Sort1"; }
            elsif ( $i == 7 ) { $cell{crit} = "Sort2"; }
            else { $cell{crit} = "Unknown"; }

            push @loopfilter, \%cell;
        }
    }
    foreach my $type (keys %$attr_filters) {
        if($attr_filters->{$type}) {
            push @loopfilter, {
                crit => "Attribute $type",
                filter => $attr_filters->{$type}
            }
        }
    }

	($status  ) and push @loopfilter,{crit=>"Status",  filter=>$status  };
	($activity) and push @loopfilter,{crit=>"Activity",filter=>$activity};
	push @loopfilter,{debug=>1, crit=>"Branches",filter=>join(" ", sort keys %$branches)};
	push @loopfilter,{debug=>1, crit=>"(line, column)", filter=>"($line,$column)"};
# year of activity
	my ( $period_year, $period_month, $period_day )=Add_Delta_YM( Today(),-$period, 0);
	my $newperioddate=$period_year."-".$period_month."-".$period_day;
# 1st, loop rows.
	my $linefield;

    my $line_attribute_type;
    if ($line  =~/^patron_attr\.(.*)$/) {
        $line_attribute_type = $1;
        $line = 'borrower_attributes.attribute';
    }

    if (($line =~/zipcode/) and ($digits)) {
        $linefield = "left($line,$digits)";
    } else {
        $linefield = $line;
    }

	my %cathash = ($line eq 'categorycode' or $column eq 'categorycode') ? &catcodes_hash : ();
	push @loopfilter, {debug=>1, crit=>"\%cathash", filter=>join(", ", map {$cathash{$_}} sort keys %cathash)};

    my $strsth;
    my @strparams; # bind parameters for the query
    if ($line_attribute_type) {
        $strsth = "SELECT distinct attribute FROM borrower_attributes
            WHERE attribute IS NOT NULL AND code=?";
        push @strparams, $line_attribute_type;
    } else {
        $strsth = "SELECT distinctrow $linefield FROM borrowers
            WHERE $line IS NOT NULL ";
    }

	$linefilter =~ s/\*/%/g;
	if ( $linefilter ) {
		$strsth .= " AND $linefield LIKE ? " ;
                push @strparams, $linefilter;
	}
	$strsth .= " AND $status='1' " if ($status);
    $strsth .=" order by $linefield";
	
	push @loopfilter, {sql=>1, crit=>"Query", filter=>$strsth};
	my $sth = $dbh->prepare($strsth);
    $sth->execute(@strparams);
 	while (my ($celvalue) = $sth->fetchrow) {
 		my %cell;
		if ($celvalue) {
			$cell{rowtitle} = $celvalue;
			# $cell{rowtitle_display} = ($linefield eq 'branchcode') ? $branches->{$celvalue}->{branchname} : $celvalue;
			$cell{rowtitle_display} = ($cathash{$celvalue} || "$celvalue\*") if ($line eq 'categorycode');
		}
 		$cell{totalrow} = 0;
		push @loopline, \%cell;
 	}

# 2nd, loop cols.
	my $colfield;

    my $column_attribute_type;
    if ($column  =~/^patron_attr.(.*)$/) {
        $column_attribute_type = $1;
        $column = 'borrower_attributes.attribute';
    }

    if (($column =~/zipcode/) and ($digits)) {
        $colfield = "left($column,$digits)";
    } else {
        $colfield = $column;
    }

    my $strsth2;
    my @strparams2; # bind parameters for the query
    if ($column_attribute_type) {
        $strsth2 = "SELECT DISTINCT attribute FROM borrower_attributes
            WHERE attribute IS NOT NULL AND code=?";
        push @strparams2, $column_attribute_type;
    } else {
        $strsth2 = "SELECT DISTINCTROW $colfield FROM borrowers
            WHERE $column IS NOT NULL";
    }

	if ($colfilter) {
		$colfilter =~ s/\*/%/g;
		$strsth2 .= " AND $colfield LIKE ? ";
        push @strparams2, $colfield;
	}
	$strsth2 .= " AND $status='1' " if ($status);

    $strsth2 .= " order by $colfield";
	push @loopfilter, {sql=>1, crit=>"Query", filter=>$strsth2};
	my $sth2 = $dbh->prepare($strsth2);
    $sth2->execute(@strparams2);
 	while (my ($celvalue) = $sth2->fetchrow) {
 		my %cell;
             if (defined $celvalue) {
			$cell{coltitle} = $celvalue;
			# $cell{coltitle_display} = ($colfield eq 'branchcode') ? $branches->{$celvalue}->{branchname} : $celvalue;
			$cell{coltitle_display} = $cathash{$celvalue} if ($column eq 'categorycode');
		}
		push @loopcol, \%cell;
 	}

	my $i=0;
	#Initialization of cell values.....
	my %table;
#	warn "init table";
	foreach my $row (@loopline) {
		foreach my $col ( @loopcol ) {
            my $rowtitle = $row->{rowtitle} // '';
            my $coltitle = $row->{coltitle} // '';
            $table{$rowtitle}->{$coltitle} = 0;
		}
        $row->{rowtitle} ||= '';
		$table{$row->{rowtitle}}->{totalrow}=0;
		$table{$row->{rowtitle}}->{rowtitle_display} = $row->{rowtitle_display};
	}

    # preparing calculation
    my $strcalc;
    my @calcparams;
    $strcalc = "SELECT ";
    if ($line_attribute_type) {
        $strcalc .= " attribute_$line_attribute_type.attribute AS line_attribute, ";
    } else {
        $strcalc .= " $linefield, ";
    }
    if ($column_attribute_type) {
        $strcalc .= " attribute_$column_attribute_type.attribute AS column_attribute, ";
    } else {
        $strcalc .= " $colfield, ";
    }

    $strcalc .= " COUNT(*) FROM borrowers ";
    foreach my $type (keys %$attr_filters) {
        if (
            ($line_attribute_type and $line_attribute_type eq $type)
         or ($column_attribute_type and $column_attribute_type eq $type)
         or ($attr_filters->{$type})
        ) {
            $strcalc .= " LEFT JOIN borrower_attributes AS attribute_$type
                ON (borrowers.borrowernumber = attribute_$type.borrowernumber
                    AND attribute_$type.code = " . $dbh->quote($type) . ") ";
        }
    }
    $strcalc .= " WHERE 1 ";

	@$filters[0]=~ s/\*/%/g if (@$filters[0]);
	$strcalc .= " AND categorycode like '" . @$filters[0] ."'" if ( @$filters[0] );
	@$filters[1]=~ s/\*/%/g if (@$filters[1]);
	$strcalc .= " AND zipcode like '" . @$filters[1] ."'" if ( @$filters[1] );
	@$filters[2]=~ s/\*/%/g if (@$filters[2]);
	$strcalc .= " AND branchcode like '" . @$filters[2] ."'" if ( @$filters[2] );
	@$filters[3]=~ s/\*/%/g if (@$filters[3]);
	$strcalc .= " AND dateofbirth > '" . @$filters[3] ."'" if ( @$filters[3] );
	@$filters[4]=~ s/\*/%/g if (@$filters[4]);
	$strcalc .= " AND dateofbirth < '" . @$filters[4] ."'" if ( @$filters[4] );
    @$filters[5]=~ s/\*/%/g if (@$filters[5]);
    $strcalc .= " AND sex like '" . @$filters[5] ."'" if ( @$filters[5] );
    @$filters[6]=~ s/\*/%/g if (@$filters[6]);
	$strcalc .= " AND sort1 like '" . @$filters[6] ."'" if ( @$filters[6] );
	@$filters[7]=~ s/\*/%/g if (@$filters[7]);
	$strcalc .= " AND sort2 like '" . @$filters[7] ."'" if ( @$filters[7] );

    foreach my $type (keys %$attr_filters) {
        if($attr_filters->{$type}) {
            my $filter = $attr_filters->{$type};
            $filter =~ s/\*/%/g;
            $strcalc .= " AND attribute_$type.attribute LIKE '" . $filter . "' ";
        }
    }
	$strcalc .= " AND borrowernumber in (select distinct(borrowernumber) from old_issues where issuedate > '" . $newperioddate . "')" if ($activity eq 'active');
	$strcalc .= " AND borrowernumber not in (select distinct(borrowernumber) from old_issues where issuedate > '" . $newperioddate . "')" if ($activity eq 'nonactive');
	$strcalc .= " AND $status='1' " if ($status);

    $strcalc .= " GROUP BY ";
    if ($line_attribute_type) {
        $strcalc .= " line_attribute, ";
    } else {
        $strcalc .= " $linefield, ";
    }
    if ($column_attribute_type) {
        $strcalc .= " column_attribute ";
    } else {
        $strcalc .= " $colfield ";
    }

	push @loopfilter, {sql=>1, crit=>"Query", filter=>$strcalc};
	my $dbcalc = $dbh->prepare($strcalc);
	(scalar(@calcparams)) ? $dbcalc->execute(@calcparams) : $dbcalc->execute();
	
	my $emptycol; 
	while (my ($row, $col, $value) = $dbcalc->fetchrow) {
#		warn "filling table $row / $col / $value ";
		$emptycol = 1 if (!defined($col));
		$col = "zzEMPTY" if (!defined($col));
		$row = "zzEMPTY" if (!defined($row));
		
		$table{$row}->{$col}+=$value;
		$table{$row}->{totalrow}+=$value;
		$grantotal += $value;
	}
	
 	push @loopcol,{coltitle => "NULL"} if ($emptycol);
	
	foreach my $row (sort keys %table) {
		my @loopcell;
		#@loopcol ensures the order for columns is common with column titles
		# and the number matches the number of columns
		foreach my $col ( @loopcol ) {
            my $coltitle = $col->{coltitle} // '';
            $coltitle = $coltitle eq "NULL" ? "zzEMPTY" : $coltitle;
			my $value =$table{$row}->{$coltitle};
			push @loopcell, {value => $value};
		}
		push @looprow,{
			'rowtitle' => ($row eq "zzEMPTY")?"NULL":$row,
			'rowtitle_display' => $table{$row}->{rowtitle_display} || ($row eq "zzEMPTY" ? "NULL" : $row),
			'loopcell' => \@loopcell,
			'totalrow' => $table{$row}->{totalrow}
		};
	}
	
	foreach my $col ( @loopcol ) {
		my $total=0;
		foreach my $row ( @looprow ) {
            my $rowtitle = $row->{rowtitle} // '';
            $rowtitle = ($rowtitle eq "NULL") ? "zzEMPTY" : $rowtitle;
            my $coltitle = $col->{coltitle} // '';
            $coltitle = ($coltitle eq "NULL") ? "zzEMPTY" : $coltitle;

            $total += $table{$rowtitle}->{$coltitle} || 0;
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
	$globalline{line} = ($line_attribute_type) ? $line_attribute_type : $line;
	$globalline{column} = ($column_attribute_type) ? $column_attribute_type : $column;
	push @mainloop,\%globalline;
	return \@mainloop;
}

sub parse_extended_patron_attributes {
    my ($input) = @_;

    my @params_names = $input->param;
    my %attr;
    foreach my $name (@params_names) {
        if ($name =~ /^Filter_patron_attr\.(.*)$/) {
            my $code = $1;
            my $value = $input->param($name);
            $attr{$code} = $value;
        }
    }

    return \%attr;
}


sub patron_attributes_form {
    my $template = shift;

    my @types = C4::Members::AttributeTypes::GetAttributeTypes();

    my %items_by_class;
    foreach my $type (@types) {
        my $attr_type = C4::Members::AttributeTypes->fetch($type->{code});
        my $entry = {
            class             => $attr_type->class(),
            code              => $attr_type->code(),
            description       => $attr_type->description(),
            repeatable        => $attr_type->repeatable(),
            category          => $attr_type->authorised_value_category(),
            category_code     => $attr_type->category_code(),
        };

        my $newentry = { %$entry };
        if ($attr_type->authorised_value_category()) {
            $newentry->{use_dropdown} = 1;
            $newentry->{auth_val_loop} = GetAuthorisedValues(
                $attr_type->authorised_value_category()
            );
        }
        push @{ $items_by_class{ $attr_type->class() } }, $newentry;
    }

    my @attribute_loop;
    foreach my $class ( sort keys %items_by_class ) {
        my $lib = GetAuthorisedValueByCode( 'PA_CLASS', $class ) || $class;
        push @attribute_loop, {
            class => $class,
            items => $items_by_class{$class},
            lib   => $lib,
        };
    }

    $template->param(patron_attributes => \@attribute_loop);

}
