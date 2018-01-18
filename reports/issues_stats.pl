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

use CGI qw ( -utf8 );
use Date::Manip;

use C4::Auth;
use C4::Debug;
use C4::Context;
use C4::Koha;
use C4::Output;
use C4::Circulation;
use C4::Reports;
use C4::Members;

use Koha::AuthorisedValues;
use Koha::DateUtils;
use Koha::ItemTypes;
use C4::Members::AttributeTypes;

=head1 NAME

reports/issues_stats.pl

=head1 DESCRIPTION

Plugin that shows circulation stats

=cut

# my $debug = 1;	# override for now.
my $input = CGI->new;
my $fullreportname = "reports/issues_stats.tt";
my $do_it    = $input->param('do_it');
my $line     = $input->param("Line");
my $column   = $input->param("Column");
my @filters  = $input->multi_param("Filter");
$filters[0] = eval { output_pref( { dt => dt_from_string( $filters[0]), dateonly => 1, dateformat => 'iso' } ); }
    if ( $filters[0] );
$filters[1] = eval { output_pref( { dt => dt_from_string( $filters[1]), dateonly => 1, dateformat => 'iso' } ); }
    if ( $filters[1] );
my $podsp    = $input->param("DisplayBy");
my $type     = $input->param("PeriodTypeSel");
my $daysel   = $input->param("PeriodDaySel");
my $monthsel = $input->param("PeriodMonthSel");
my $calc     = $input->param("Cellvalue");
my $output   = $input->param("output");
my $basename = $input->param("basename");

my $attribute_filters;
my $vars = $input->Vars;
foreach(keys %$vars) {
    if(/^Filter_borrower_attributes\.(.*)/) {
        $attribute_filters->{$1} = $vars->{$_};
    }
}


my ($template, $borrowernumber, $cookie) = get_template_and_user({
	template_name => $fullreportname,
	query => $input,
	type => "intranet",
	authnotrequired => 0,
	flagsrequired => {reports => '*'},
	debug => 0,
});
our $sep     = $input->param("sep") // ';';
$sep = "\t" if ($sep eq 'tabulation');
$template->param(do_it => $do_it,
);

our @patron_categories = Koha::Patron::Categories->search_limited({}, {order_by => ['description']});

our $locations = { map { ( $_->{authorised_value} => $_->{lib} ) } Koha::AuthorisedValues->get_descriptions_by_koha_field( { frameworkcode => '', kohafield => 'items.location' }, { order_by => ['description'] } ) };
our $ccodes = { map { ( $_->{authorised_value} => $_->{lib} ) } Koha::AuthorisedValues->get_descriptions_by_koha_field( { frameworkcode => '', kohafield => 'items.ccode' }, { order_by => ['description'] } ) };

our $Bsort1 = GetAuthorisedValues("Bsort1");
our $Bsort2 = GetAuthorisedValues("Bsort2");
my ($hassort1,$hassort2);
$hassort1=1 if $Bsort1;
$hassort2=1 if $Bsort2;

if ($do_it) {
    # Displaying results
    my $results = calculate( $line, $column, $podsp, $type, $daysel, $monthsel, $calc, \@filters, $attribute_filters);
    if ( $output eq "screen" ) {

        # Printing results to screen
        $template->param( mainloop => $results );
        output_html_with_http_headers $input, $cookie, $template->output;
    } else {

        # Printing to a csv file
        print $input->header(
            -type       => 'application/vnd.sun.xml.calc',
            -encoding   => 'utf-8',
            -attachment => "$basename.csv",
            -filename   => "$basename.csv"
        );
        my $cols  = @$results[0]->{loopcol};
        my $lines = @$results[0]->{looprow};

        # header top-right
        print @$results[0]->{line} . "/" . @$results[0]->{column} . $sep;

        # Other header
        foreach my $col (@$cols) {
            print $col->{coltitle} . $sep;
        }
        print "Total\n";

        # Table
        foreach my $line (@$lines) {
            my $x = $line->{loopcell};
            print $line->{rowtitle} . $sep;
            print map { $_->{value} . $sep } @$x;
            print $line->{totalrow}, "\n";
        }

        # footer
        print "TOTAL";
        $cols = @$results[0]->{loopfooter};
        print map {$sep.$_->{totalcol}} @$cols;
        print $sep.@$results[0]->{total};
    }
    exit;
}


my $dbh = C4::Context->dbh;
my @values;
my %labels;
my %select;

# create itemtype arrayref for <select>.
our $itemtypes = Koha::ItemTypes->search_with_localization;

    # location list
my @locations;
foreach (sort keys %$locations) {
	push @locations, { code => $_, description => "$_ - " . $locations->{$_} };
}
    
my @ccodes;
foreach (sort {$ccodes->{$a} cmp $ccodes->{$b}} keys %$ccodes) {
	push @ccodes, { code => $_, description => $ccodes->{$_} };
}

my $CGIextChoice = ( 'CSV' ); # FIXME translation
my $CGIsepChoice=GetDelimiterChoices;

my @attribute_types = C4::Members::AttributeTypes::GetAttributeTypes(1);
my %attribute_types_by_class;
foreach my $attribute_type (@attribute_types) {
    if ($attribute_type->{authorised_value_category}) {
        my $authorised_values = C4::Koha::GetAuthorisedValues(
            $attribute_type->{authorised_value_category});

        foreach my $authorised_value (@$authorised_values) {
            push @{ $attribute_type->{authorised_values} }, $authorised_value;
        }
    }
    push @{ $attribute_types_by_class{$attribute_type->{class}} }, $attribute_type;
}

$template->param(
    categoryloop => \@patron_categories,
    itemtypes    => $itemtypes,
    locationloop => \@locations,
    ccodeloop    => \@ccodes,
    hassort1     => $hassort1,
    hassort2     => $hassort2,
    Bsort1       => $Bsort1,
    Bsort2       => $Bsort2,
    CGIextChoice => $CGIextChoice,
    CGIsepChoice => $CGIsepChoice,
    attribute_types_by_class => \%attribute_types_by_class,
);
output_html_with_http_headers $input, $cookie, $template->output;

sub calculate {
    my ( $line, $column, $dsp, $type, $daysel, $monthsel, $process, $filters, $attribute_filters ) = @_;
    my @loopfooter;
    my @loopcol;
    my @loopline;
    my @looprow;
    my %globalline;
    my $grantotal = 0;

    # extract parameters
    my $dbh = C4::Context->dbh;

    my ($line_attribute_type, $column_attribute_type);
    if($line =~ /^borrower_attributes\.(.*)/) {
        $line_attribute_type = $1;
        $line = "borrower_attributes.attribute";
    }
    if($column =~ /^borrower_attributes\.(.*)/) {
        $column_attribute_type = $1;
        $column = "borrower_attributes.attribute";
    }

    # Filters
    # Checking filters
    #
    my @loopfilter;
    for ( my $i = 0 ; $i <= @$filters ; $i++ ) {
        my %cell;
        ( @$filters[$i] ) or next;
        if ( ( $i == 1 ) and ( @$filters[ $i - 1 ] ) ) {
            $cell{err} = 1 if ( @$filters[$i] < @$filters[ $i - 1 ] );
        }
            # format the dates filters, otherwise just fill as is
        if ($i>=2) {
            $cell{filter} = @$filters[$i];
        } else {
            $cell{filter} = eval { output_pref( { dt => dt_from_string( @$filters[$i] ), dateonly => 1 }); }
              if ( @$filters[$i] );
        }
        $cell{crit} = $i;

        push @loopfilter, \%cell;
    }
    foreach (keys %$attribute_filters) {
        next unless $attribute_filters->{$_};
        push @loopfilter, { crit => "$_ =", filter => $attribute_filters->{$_} };
    }
    push @loopfilter, { crit => "Event",        filter => $type };
    push @loopfilter, { crit => "Display by",   filter => $dsp } if ($dsp);
    push @loopfilter, { crit => "Select Day",   filter => $daysel } if ($daysel);
    push @loopfilter, { crit => "Select Month", filter => $monthsel } if ($monthsel);

    my @linefilter;
    $debug and warn "filtres " . join "|", @$filters;
    my ( $colsource, $linesource ) = ('', '');
    $linefilter[1] = @$filters[1] if ( $line =~ /datetime/ );
    $linefilter[0] =
        ( $line =~ /datetime/ )     ? @$filters[0]
      : ( $line =~ /category/ )     ? @$filters[2]
      : ( $line =~ /itemtype/ )     ? @$filters[3]
      : ( $line =~ /^branch/ )      ? @$filters[4]
      : ( $line =~ /ccode/ )        ? @$filters[5]
      : ( $line =~ /location/ )     ? @$filters[6]
      : ( $line =~ /sort1/ )        ? @$filters[9]
      : ( $line =~ /sort2/ )        ? @$filters[10]
      : ( $line =~ /homebranch/)    ? @$filters[11]
      : ( $line =~ /holdingbranch/) ? @$filters[12]
      : ( $line =~ /borrowers.branchcode/ ) ? @$filters[13]
      : ( $line_attribute_type )    ? $attribute_filters->{$line_attribute_type}
      :                               undef;

    if ( $line =~ /ccode/ or $line =~ /location/ or $line =~ /homebranch/ or $line =~ /holdingbranch/ ) {
		$linesource = 'items';
	}

	my @colfilter;
	$colfilter[1] = @$filters[1] if ($column =~ /datetime/);
	$colfilter[0] = 
        ( $column =~ /datetime/ ) ? @$filters[0]
      : ( $column =~ /category/ ) ? @$filters[2]
      : ( $column =~ /itemtype/ ) ? @$filters[3]
      : ( $column =~ /^branch/ )   ? @$filters[4]
      : ( $column =~ /ccode/ )    ? @$filters[5]
      : ( $column =~ /location/ ) ? @$filters[6]
      : ( $column =~ /sort1/ )    ? @$filters[9]
      : ( $column =~ /sort1/ )    ? @$filters[10]
      : ( $column =~ /homebranch/)    ? @$filters[11]
      : ( $column =~ /holdingbranch/) ? @$filters[12]
      : ( $column =~ /borrowers.branchcode/ ) ? @$filters[13]
      : ( $column_attribute_type )    ? $attribute_filters->{$column_attribute_type}
      :                                 undef;

    if ( $column =~ /ccode/ or $column =~ /location/ or $column =~ /homebranch/ or $column =~ /holdingbranch/ ) {
        $colsource = 'items';
    }

    # 1st, loop rows.
    my $linefield;
    if ( $line =~ /datetime/ ) {

        # by Day, Month, Year or Hour (1,2,3,4 respectively)
        $linefield =
            ( $dsp == 1 ) ? "  dayname($line)"
          : ( $dsp == 2 ) ? "monthname($line)"
          : ( $dsp == 3 ) ? "     Year($line)"
          : ( $dsp == 4 ) ? "extract(hour from $line)"
          :                 'date_format(`datetime`,"%Y-%m-%d")';    # Probably should be left alone or passed through Koha::Dates
    } else {
        $linefield = $line;
    }
    my $lineorder =
        ( $linefield =~ /dayname/ ) ? "weekday($line)"
      : ( $linefield =~ /^month/ )  ? "  month($line)"
      :                               $linefield;

    my $strsth;
    if($line_attribute_type) {
        $strsth = "SELECT attribute FROM borrower_attributes WHERE code = '$line_attribute_type' ";
    } else {
        $strsth = "SELECT distinctrow $linefield FROM statistics ";

        # get stats on items if ccode or location, otherwise borrowers.
        $strsth .=
          ( $linesource eq 'items' )
          ? " LEFT JOIN items ON (statistics.itemnumber = items.itemnumber) "
          : " LEFT JOIN borrowers ON (statistics.borrowernumber = borrowers.borrowernumber) ";
        $strsth .= " WHERE $line is not null AND $line != '' ";
    }

    if ( $line =~ /datetime/ ) {
        if ( $linefilter[1] and ( $linefilter[0] ) ) {
            $strsth .= " AND $line between ? AND ? ";
        } elsif ( $linefilter[1] ) {
            $strsth .= " AND $line <= ? ";
        } elsif ( $linefilter[0] ) {
            $strsth .= " AND $line >= ? ";
        }
        $strsth .= " AND type ='" . $type . "' "                    if $type;
        $strsth .= " AND   dayname(datetime) ='" . $daysel . "' "   if $daysel;
        $strsth .= " AND monthname(datetime) ='" . $monthsel . "' " if $monthsel;
    } elsif ( $linefilter[0] ) {
        $linefilter[0] =~ s/\*/%/g;
        $strsth .= " AND $line LIKE ? ";
    }
    $strsth .= " group by $linefield order by $lineorder ";
    $debug and warn $strsth;
    push @loopfilter, { crit => 'SQL =', sql => 1, filter => $strsth };
    my $sth = $dbh->prepare($strsth);
    if ( (@linefilter) and ($linefilter[0]) and ($linefilter[1]) ) {
        $sth->execute( $linefilter[0], $linefilter[1] . " 23:59:59" );
    } elsif ( $linefilter[1] ) {
        $sth->execute( $linefilter[1] . " 23:59:59" );
    } elsif ( $linefilter[0] ) {
        $sth->execute( $linefilter[0] );
    } else {
        $sth->execute;
    }

    while ( my ($celvalue) = $sth->fetchrow ) {
        my %cell = ( rowtitle => $celvalue, totalrow => 0 );    # we leave 'rowtitle' as hash key (used when filling the table), and add coltitle_display
        $cell{rowtitle_display} =
            ( $line =~ /ccode/ )    ? $ccodes->{$celvalue}
          : ( $line =~ /location/ ) ? $locations->{$celvalue}
          : ( $line =~ /itemtype/ ) ? $itemtypes->{$celvalue}->{description}
          :                           $celvalue;                               # default fallback
        if ( $line =~ /sort1/ ) {
            foreach (@$Bsort1) {
                ( $celvalue eq $_->{authorised_value} ) or next;
                $cell{rowtitle_display} = $_->{lib} and last;
            }
        } elsif ( $line =~ /sort2/ ) {
            foreach (@$Bsort2) {
                ( $celvalue eq $_->{authorised_value} ) or next;
                $cell{rowtitle_display} = $_->{lib} and last;
            }
        } elsif ($line =~ /category/) {
            foreach my $patron_category ( @patron_categories ) {
                ($celvalue eq $patron_category->categorycode) or next;
                $cell{rowtitle_display} = $patron_category->description and last;
            }
        }
        push @loopline, \%cell;
    }

    # 2nd, loop cols.
    my $colfield;
    my $colorder;
    if ( $column =~ /datetime/ ) {

        #Display by Day, Month or Year (1,2,3 respectively)
        $colfield =
            ( $dsp == 1 ) ? "  dayname($column)"
          : ( $dsp == 2 ) ? "monthname($column)"
          : ( $dsp == 3 ) ? "     Year($column)"
          : ( $dsp == 4 ) ? "extract(hour from $column)"
          :                 'date_format(`datetime`,"%Y-%m-%d")';    # Probably should be left alone or passed through Koha::Dates
    } else {
        $colfield = $column;
    }
    $colorder =
        ( $colfield =~ /dayname/ ) ? "weekday($column)"
      : ( $colfield =~ /^month/ )  ? "  month($column)"
      :                              $colfield;
    my $strsth2;
    if($column_attribute_type) {
        $strsth2 = "SELECT attribute FROM borrower_attributes WHERE code = '$column_attribute_type' ";
    } else {
        $strsth2 = "SELECT distinctrow $colfield FROM statistics ";

        # get stats on items if ccode or location, otherwise borrowers.
        $strsth2 .=
          ( $colsource eq 'items' )
          ? "LEFT JOIN items ON (statistics.itemnumber = items.itemnumber) "
          : "LEFT JOIN borrowers ON (statistics.borrowernumber = borrowers.borrowernumber) ";
        $strsth2 .= " WHERE $column IS NOT NULL AND $column != '' ";
    }

    if ( $column =~ /datetime/ ) {
        if ( ( $colfilter[1] ) and ( $colfilter[0] ) ) {
            $strsth2 .= " AND $column BETWEEN ? AND ? ";
        } elsif ( $colfilter[1] ) {
            $strsth2 .= " AND $column <= ? ";
        } elsif ( $colfilter[0] ) {
            $strsth2 .= " AND $column >= ? ";
        }
        $strsth2 .= " AND                type ='". $type     ."' " if $type;
        $strsth2 .= " AND   dayname(datetime) ='". $daysel   ."' " if $daysel;
        $strsth2 .= " AND monthname(datetime) ='". $monthsel ."' " if $monthsel;
    } elsif ($colfilter[0]) {
        $colfilter[0] =~ s/\*/%/g;
        $strsth2 .= " AND $column LIKE ? " ;
    }

    $strsth2 .= " group by $colfield order by $colorder ";
    $debug and warn $strsth2;
    push @loopfilter, { crit => 'SQL =', sql => 1, filter => $strsth2 };
    my $sth2 = $dbh->prepare($strsth2);
    if ( (@colfilter) and ($colfilter[0]) and ($colfilter[1]) ) {
        $sth2->execute( $colfilter[0], $colfilter[1] . " 23:59:59" );
    } elsif ( $colfilter[1] ) {
        $sth2->execute( $colfilter[1] . " 23:59:59" );
    } elsif ( $colfilter[0] ) {
        $sth2->execute( $colfilter[0] );
    } else {
        $sth2->execute;
    }

    while ( my ($celvalue) = $sth2->fetchrow ) {
        my %cell = ( coltitle => $celvalue );    # we leave 'coltitle' as hash key (used when filling the table), and add coltitle_display
        $cell{coltitle_display} =
            ( $column =~ /ccode/ )    ? $ccodes->{$celvalue}
          : ( $column =~ /location/ ) ? $locations->{$celvalue}
          : ( $column =~ /itemtype/ ) ? $itemtypes->{$celvalue}->{description}
          :                             $celvalue;                               # default fallback
        if ( $column =~ /sort1/ ) {
            foreach (@$Bsort1) {
                ( $celvalue eq $_->{authorised_value} ) or next;
                $cell{coltitle_display} = $_->{lib} and last;
            }
        } elsif ( $column =~ /sort2/ ) {
            foreach (@$Bsort2) {
                ( $celvalue eq $_->{authorised_value} ) or next;
                $cell{coltitle_display} = $_->{lib} and last;
            }
        } elsif ($column =~ /category/) {
            foreach my $patron_category ( @patron_categories ) {
                ($celvalue eq $patron_category->categorycode) or next;
                $cell{coltitle_display} = $patron_category->description and last;
            }
        }
        push @loopcol, \%cell;
    }

    #Initialization of cell values.....
    my %table;
    foreach my $row (@loopline) {
        foreach my $col (@loopcol) {
            $debug and warn " init table : $row->{rowtitle} ( $row->{rowtitle_display} ) / $col->{coltitle} ( $col->{coltitle_display} )  ";
            table_set(\%table, $row->{rowtitle}, $col->{coltitle}, 0);
        }
        table_set(\%table, $row->{rowtitle}, 'totalrow', 0);
    }

    # preparing calculation
    my $strcalc = "SELECT ";
    if($line_attribute_type) {
        $strcalc .= "TRIM(attribute_$line_attribute_type.attribute) AS line_attribute, ";
    } else {
        $strcalc .= "TRIM($linefield), ";
    }
    if($column_attribute_type) {
        $strcalc .= "TRIM(attribute_$column_attribute_type.attribute) AS column_attribute, ";
    } else {
        $strcalc .= "TRIM($colfield), ";
    }
    $strcalc .=
        ( $process == 1 ) ? " COUNT(*) "
      : ( $process == 2 ) ? "(COUNT(DISTINCT borrowers.borrowernumber))"
      : ( $process == 3 ) ? "(COUNT(DISTINCT statistics.itemnumber))"
      : ( $process == 5 ) ? "(COUNT(DISTINCT items.biblionumber))"
      :                     '';
    if ( $process == 4 ) {
        my $rqbookcount = $dbh->prepare("SELECT count(*) FROM items");
        $rqbookcount->execute;
        my ($bookcount) = $rqbookcount->fetchrow;
        $strcalc .= "100*(COUNT(DISTINCT statistics.itemnumber))/ $bookcount ";
    }
    $strcalc .= "
        FROM statistics
        LEFT JOIN borrowers ON statistics.borrowernumber=borrowers.borrowernumber
    ";
    foreach (keys %$attribute_filters) {
        if(
            ($line_attribute_type and $line_attribute_type eq $_)
            or $column_attribute_type and $column_attribute_type eq $_
            or $attribute_filters->{$_}
        ) {
            $strcalc .= " LEFT JOIN borrower_attributes AS attribute_$_ ON (statistics.borrowernumber = attribute_$_.borrowernumber AND attribute_$_.code = '$_') ";
        }
    }
    $strcalc .= "LEFT JOIN items ON statistics.itemnumber=items.itemnumber "
      if ( $linefield =~ /^items\./
        or $colfield =~ /^items\./
        or $process == 5
        or ( $colsource eq 'items' ) || @$filters[5] || @$filters[6] || @$filters[7] || @$filters[8] || @$filters[9] || @$filters[10] || @$filters[11] || @$filters[12] || @$filters[13] );

    $strcalc .= "WHERE 1=1 ";
    @$filters = map { defined($_) and s/\*/%/g; $_ } @$filters;
    $strcalc .= " AND statistics.datetime >= '" . @$filters[0] . "'"       if ( @$filters[0] );
    $strcalc .= " AND statistics.datetime <= '" . @$filters[1] . " 23:59:59'"       if ( @$filters[1] );
    $strcalc .= " AND borrowers.categorycode LIKE '" . @$filters[2] . "'" if ( @$filters[2] );
    $strcalc .= " AND statistics.itemtype LIKE '" . @$filters[3] . "'"    if ( @$filters[3] );
    $strcalc .= " AND statistics.branch LIKE '" . @$filters[4] . "'"      if ( @$filters[4] );
    $strcalc .= " AND items.ccode LIKE '" . @$filters[5] . "'"            if ( @$filters[5] );
    $strcalc .= " AND items.location LIKE '" . @$filters[6] . "'"         if ( @$filters[6] );
    $strcalc .= " AND items.itemcallnumber >='" . @$filters[7] . "'"      if ( @$filters[7] );
    $strcalc .= " AND items.itemcallnumber <'" . @$filters[8] . "'"       if ( @$filters[8] );
    $strcalc .= " AND borrowers.sort1 LIKE '" . @$filters[9] . "'"        if ( @$filters[9] );
    $strcalc .= " AND borrowers.sort2 LIKE '" . @$filters[10] . "'"       if ( @$filters[10] );
    $strcalc .= " AND items.homebranch LIKE '" . @$filters[11] . "'"      if ( @$filters[11] );
    $strcalc .= " AND items.holdingbranch LIKE '" . @$filters[12] . "'"   if ( @$filters[12] );
    $strcalc .= " AND borrowers.branchcode LIKE '" . @$filters[13] . "'"  if ( @$filters[13] );
    $strcalc .= " AND dayname(datetime) LIKE '" . $daysel . "'"           if ($daysel);
    $strcalc .= " AND monthname(datetime) LIKE '" . $monthsel . "'"       if ($monthsel);
    $strcalc .= " AND statistics.type LIKE '" . $type . "'"               if ($type);
    foreach (keys %$attribute_filters) {
        if($attribute_filters->{$_}) {
            $strcalc .= " AND attribute_$_.attribute LIKE '" . $attribute_filters->{$_} . "'";
        }
    }

    $strcalc .= " GROUP BY ";
    if($line_attribute_type) {
        $strcalc .= " line_attribute, ";
    } else {
        $strcalc .= " $linefield, ";
    }
    if($column_attribute_type) {
        $strcalc .= " column_attribute ";
    } else {
        $strcalc .= " $colfield ";
    }

    $strcalc .= " ORDER BY ";
    if($line_attribute_type) {
        $strcalc .= " line_attribute, ";
    } else {
        $strcalc .= " $lineorder, ";
    }
    if($column_attribute_type) {
        $strcalc .= " column_attribute ";
    } else {
        $strcalc .= " $colorder ";
    }

    ($debug) and warn $strcalc;
    my $dbcalc = $dbh->prepare($strcalc);
    push @loopfilter, { crit => 'SQL =', sql => 1, filter => $strcalc };
    $dbcalc->execute;
    my ( $emptycol, $emptyrow );
    while ( my ( $row, $col, $value ) = $dbcalc->fetchrow ) {
        ($debug) and warn "filling table $row / $col / $value ";
        unless ( defined $col ) {
            $emptycol = 1;
        }
        unless ( defined $row ) {
            $emptyrow = 1;
        }
        table_inc(\%table, $row, $col, $value);
        table_inc(\%table, $row, 'totalrow', $value);
        $grantotal               += $value;
    }
    push @loopcol,  { coltitle => "NULL", coltitle_display => 'NULL' } if ($emptycol);
    push @loopline, { rowtitle => "NULL", rowtitle_display => 'NULL' } if ($emptyrow);

    foreach my $row (@loopline) {
        my @loopcell;

        #@loopcol ensures the order for columns is common with column titles
        # and the number matches the number of columns
        foreach my $col (@loopcol) {
            my $value = table_get(\%table, $row->{rowtitle}, $col->{coltitle});
            push @loopcell, { value => $value };
        }
        push @looprow,
          { 'rowtitle_display' => $row->{rowtitle_display},
            'rowtitle'         => $row->{rowtitle},
            'loopcell'         => \@loopcell,
            'totalrow'         => table_get(\%table, $row->{rowtitle}, 'totalrow'),
          };
    }
    for my $col (@loopcol) {
        my $total = 0;
        foreach my $row (@looprow) {
            $total += table_get(\%table, $row->{rowtitle}, $col->{coltitle}) || 0;
            $debug and warn "value added " . table_get(\%table, $row->{rowtitle}, $col->{coltitle}) . "for line " . $row->{rowtitle};
        }
        push @loopfooter, { 'totalcol' => $total };
    }

    # the header of the table
    $globalline{loopfilter} = \@loopfilter;

    # the core of the table
    $globalline{looprow} = \@looprow;
    $globalline{loopcol} = \@loopcol;

    # 	# the foot (totals by borrower type)
    $globalline{loopfooter} = \@loopfooter;
    $globalline{total}      = $grantotal;
    $globalline{line}       = $line_attribute_type ? $line_attribute_type : $line;
    $globalline{column}     = $column_attribute_type ? $column_attribute_type : $column;
    return [ ( \%globalline ) ];
}

sub null_to_zzempty {
    my $string = shift;

    if (!defined($string) or $string eq '' or uc($string) eq 'NULL') {
        return 'zzEMPTY';
    }

    return $string;
}

sub table_set {
    my ($table, $row, $col, $val) = @_;

    $row = $row // '';
    $col = $col // '';
    $table->{ null_to_zzempty($row) }->{ null_to_zzempty($col) } = $val;
}

sub table_get {
    my ($table, $row, $col) = @_;

    $row = $row // '';
    $col = $col // '';
    return $table->{ null_to_zzempty($row) }->{ null_to_zzempty($col) };
}

sub table_inc {
    my ($table, $row, $col, $inc) = @_;

    $row = $row // '';
    $col = $col // '';
    $table->{ null_to_zzempty($row) }->{ null_to_zzempty($col) } += $inc;
}

1;
