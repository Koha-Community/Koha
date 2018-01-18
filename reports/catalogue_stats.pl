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
use C4::Reports;
use C4::Circulation;
use C4::Biblio qw/GetMarcSubfieldStructureFromKohaField/;

use Koha::AuthorisedValues;
use Koha::DateUtils;
use Koha::ItemTypes;

=head1 NAME

plugin that shows a stats on borrowers

=head1 DESCRIPTION

=cut

our $debug = 0;
my $input = new CGI;
my $fullreportname = "reports/catalogue_stats.tt";
my $do_it       = $input->param('do_it');
my $line        = $input->param("Line");
my $column      = $input->param("Column");
my $cellvalue      = $input->param("Cellvalue"); # one of 'items', 'biblios', 'deleteditems'
my @filters     = $input->multi_param("Filter");
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
    my $results = calculate( $line, $column, $cellvalue, $cotedigits, \@filters );
    if ( $output eq "screen" ) {
        $template->param( mainloop => $results );
        output_html_with_http_headers $input, $cookie, $template->output;
        exit;
    } else {
        print $input->header(
            -type       => 'text/csv',
            -encoding   => 'utf-8',
            -attachment => "$basename.csv",
            -name       => "$basename.csv"
        );
        my $cols  = @$results[0]->{loopcol};
        my $lines = @$results[0]->{looprow};
        print @$results[0]->{line} . "/" . @$results[0]->{column} . $sep;
        foreach my $col (@$cols) {
            print $col->{coltitle} . $sep;
        }
        print "Total\n";
        foreach my $line (@$lines) {
            my $x = $line->{loopcell};
            print $line->{rowtitle} . $sep;
            foreach my $cell (@$x) {
                print $cell->{value} . $sep;
            }
            print $line->{totalrow};
            print "\n";
        }
        print "TOTAL";
        $cols = @$results[0]->{loopfooter};
        foreach my $col (@$cols) {
            print $sep. $col->{totalcol};
        }
        print $sep. @$results[0]->{total};
        exit;
    }
} else {
	my $dbh = C4::Context->dbh;
	my @values;
	my %labels;
	my $count=0;
	my $req;
	my @select;

    my $itemtypes = Koha::ItemTypes->search_with_localization;

    my @authvals = map { { code => $_->{authorised_value}, description => $_->{lib} } } Koha::AuthorisedValues->get_descriptions_by_koha_field( { frameworkcode => '', kohafield => 'items.ccode' }, { order_by => ['description'] } );
    my @locations = map { { code => $_->{authorised_value}, description => $_->{lib} } } Koha::AuthorisedValues->get_descriptions_by_koha_field( { frameworkcode => '', kohafield => 'items.location' }, { order_by => ['description'] } );

    foreach my $kohafield (qw(items.notforloan items.materials)) {
        my $subfield_structure = GetMarcSubfieldStructureFromKohaField($kohafield);
        if($subfield_structure) {
            my $avlist;
            my $avcategory = $subfield_structure->{authorised_value};
            if($avcategory) {
                $avlist = GetAuthorisedValues($avcategory);
            }
            my $kf = $kohafield;
            $kf =~ s/^items\.//;
            $template->param(
                $kf => 1,
                $kf."_label" => $subfield_structure->{liblibrarian},
                $kf."_avlist" => $avlist
            );
        }
    }

    my @mime  = ( map { +{type =>$_} } (split /[;:]/, 'CSV') ); # FIXME translation

    $template->param(
        itemtypes    => $itemtypes,
        locationloop => \@locations,
        authvals     => \@authvals,
        CGIextChoice => \@mime,
        CGIsepChoice => GetDelimiterChoices,
        item_itype   => $item_itype,
    );

}
output_html_with_http_headers $input, $cookie, $template->output;

## End of Main Body


sub calculate {
    my ( $line, $column, $cellvalue, $cotedigits, $filters ) = @_;
    my @mainloop;
    my @loopfooter;
    my @loopcol;
    my @loopline;
    my @looprow;
    my %globalline;
    my $grantotal     = 0;
    my $barcodelike   = @$filters[16];
    my $barcodefilter = @$filters[17];
    my $not;
    my $itemstable = ($cellvalue eq 'deleteditems') ? 'deleteditems' : 'items';

    my $dbh = C4::Context->dbh;

    # if barcodefilter is empty set as %
    if ($barcodefilter) {

        # Check if barcodefilter is "like" or "not like"
        if ( !$barcodelike ) {
            $not = "not";
        }

        # Change * to %
        $barcodefilter =~ s/\*/%/g;
    }

    # Filters
    # Checking filters
    #
    my @loopfilter;
    for ( my $i = 0 ; $i <= @$filters ; $i++ ) {
        my %cell;
        if ( defined @$filters[$i] and @$filters[$i] ne '' and $i != 11 ) {
            if ( ( ( $i == 1 ) or ( $i == 5 ) ) and ( @$filters[ $i - 1 ] ) ) {
                $cell{err} = 1 if ( @$filters[$i] < @$filters[ $i - 1 ] );
            }
            $cell{filter} .= @$filters[$i];
            $cell{crit} .=
                ( $i == 0 )  ? "Item CallNumber From"
              : ( $i == 1 )  ? "Item CallNumber To"
              : ( $i == 2 )  ? "Item type"
              : ( $i == 3 )  ? "Publisher"
              : ( $i == 4 )  ? "Publication year From"
              : ( $i == 5 )  ? "Publication year To"
              : ( $i == 6 ) ? "Library"
              : ( $i == 7 ) ? "Shelving Location"
              : ( $i == 8 ) ? "Collection Code"
              : ( $i == 9 ) ? "Status"
              : ( $i == 10 ) ? "Materials"
              : ( $i == 12 and $filters->[11] == 0 ) ? "Barcode (not like)"
              : ( $i == 12 and $filters->[11] == 1 ) ? "Barcode (like)"
              : ( $i == 13 ) ? "Date acquired (item) from"
              : ( $i == 14 ) ? "Date acquired (item) to"
              : ( $i == 15 ) ? "Date deleted (item) from"
              : ( $i == 16 ) ? "Date deleted (item) to"
              :                '';

            push @loopfilter, \%cell;
        }
    }

    @$filters[13] = dt_from_string(@$filters[13])->date() if @$filters[13];
    @$filters[14] = dt_from_string(@$filters[14])->date() if @$filters[14];
    @$filters[15] = dt_from_string(@$filters[15])->date() if @$filters[15];
    @$filters[16] = dt_from_string(@$filters[16])->date() if @$filters[16];

    my @linefilter;
    $linefilter[0] = @$filters[0] if ( $line =~ /items\.itemcallnumber/ );
    $linefilter[1] = @$filters[1] if ( $line =~ /items\.itemcallnumber/ );
    if ( C4::Context->preference('item-level_itypes') ) {
        $linefilter[0] = @$filters[2] if ( $line =~ /items\.itype/ );
    } else {
        $linefilter[0] = @$filters[2] if ( $line =~ /itemtype/ );
    }
    $linefilter[0] = @$filters[3] if ( $line =~ /publishercode/ );
    $linefilter[0] = @$filters[4] if ( $line =~ /publicationyear/ );
    $linefilter[1] = @$filters[5] if ( $line =~ /publicationyear/ );

    $linefilter[0] = @$filters[6] if ( $line =~ /items\.homebranch/ );
    $linefilter[0] = @$filters[7] if ( $line =~ /items\.location/ );
    $linefilter[0] = @$filters[8] if ( $line =~ /items\.ccode/ );
    $linefilter[0] = @$filters[9] if ( $line =~ /items\.notforloan/ );
    $linefilter[0] = @$filters[10] if ( $line =~ /items\.materials/ );
    $linefilter[0] = @$filters[13] if ( $line =~ /items\.dateaccessioned/ );
    $linefilter[1] = @$filters[14] if ( $line =~ /items\.dateaccessioned/ );
    $linefilter[0] = @$filters[15] if ( $line =~ /deleteditems\.timestamp/ );
    $linefilter[1] = @$filters[16] if ( $line =~ /deleteditems\.timestamp/ );

    my @colfilter;
    $colfilter[0] = @$filters[0] if ( $column =~ /items\.itemcallnumber/ );
    $colfilter[1] = @$filters[1] if ( $column =~ /items\.itemcallnumber/ );
    if ( C4::Context->preference('item-level_itypes') ) {
        $colfilter[0] = @$filters[2] if ( $column =~ /items\.itype/ );
    } else {
        $colfilter[0] = @$filters[2] if ( $column =~ /itemtype/ );
    }
    $colfilter[0] = @$filters[3]  if ( $column =~ /publishercode/ );
    $colfilter[0] = @$filters[4]  if ( $column =~ /publicationyear/ );
    $colfilter[1] = @$filters[5]  if ( $column =~ /publicationyear/ );
    $colfilter[0] = @$filters[6] if ( $column =~ /items\.homebranch/ );
    $colfilter[0] = @$filters[7] if ( $column =~ /items\.location/ );
    $colfilter[0] = @$filters[8] if ( $column =~ /items\.ccode/ );
    $colfilter[0] = @$filters[9] if ( $column =~ /items\.notforloan/ );
    $colfilter[0] = @$filters[10] if ( $column =~ /items\.materials/ );
    $colfilter[0] = @$filters[13] if ( $column =~ /items.dateaccessioned/ );
    $colfilter[1] = @$filters[14] if ( $column =~ /items\.dateaccessioned/ );
    $colfilter[0] = @$filters[15] if ( $column =~ /deleteditems\.timestamp/ );
    $colfilter[1] = @$filters[16] if ( $column =~ /deleteditems\.timestamp/ );

    # 1st, loop rows.
    my $origline = $line;
    $line =~ s/^items\./deleteditems./ if($cellvalue eq "deleteditems");
    my $linefield;
    if ( ( $line =~ /itemcallnumber/ ) and ($cotedigits) ) {
        $linefield = "left($line,$cotedigits)";
    } elsif ( $line =~ /^deleteditems\.timestamp$/ ) {
        $linefield = "DATE($line)";
    } else {
        $linefield = $line;
    }

    my $strsth = "SELECT DISTINCTROW $linefield FROM $itemstable
                    LEFT JOIN biblioitems USING (biblioitemnumber)
                    LEFT JOIN biblio ON (biblioitems.biblionumber = biblio.biblionumber)
                  WHERE 1 ";
    $strsth .= " AND barcode $not LIKE ? " if ($barcodefilter);
    if (@linefilter) {
        if ( $linefilter[1] ) {
            $strsth .= " AND $line >= ? ";
            $strsth .= " AND $line <= ? ";
        } elsif ( defined $linefilter[0] and $linefilter[0] ne '' ) {
            $linefilter[0] =~ s/\*/%/g;
            $strsth .= " AND $line LIKE ? ";
        }
    }
    $strsth .= " ORDER BY $linefield";
    $debug and print STDERR "catalogue_stats SQL: $strsth\n";

    my $sth = $dbh->prepare($strsth);
    if ( $barcodefilter and (@linefilter) and ( $linefilter[1] ) ) {
        $sth->execute( $barcodefilter, $linefilter[0], $linefilter[1] );
    } elsif ( (@linefilter) and ( $linefilter[1] ) ) {
        $sth->execute( $linefilter[0], $linefilter[1] );
    } elsif ( $barcodefilter and $linefilter[0] ) {
        $sth->execute( $barcodefilter, $linefilter[0] );
    } elsif ( $linefilter[0] ) {
        $sth->execute($linefilter[0]);
    } elsif ($barcodefilter) {
        $sth->execute($barcodefilter);
    } else {
        $sth->execute();
    }
    my $rowauthvals = { map { $_->{authorised_value} => $_->{lib} } Koha::AuthorisedValues->get_descriptions_by_koha_field( { frameworkcode => '', kohafield => $origline } ) };
    while ( my ($celvalue) = $sth->fetchrow ) {
        my %cell;
        if (defined $celvalue and $celvalue ne '') {
            if($rowauthvals and $rowauthvals->{$celvalue}) {
                $cell{rowtitle} = $rowauthvals->{$celvalue};
            } else {
                $cell{rowtitle} = $celvalue;
            }
            $cell{value} = $celvalue;
        }
        else {
            $cell{rowtitle} = "NULL";
            $cell{value} = "zzEMPTY";
        }
        $cell{totalrow} = 0;
        push @loopline, \%cell;
    }

    # 2nd, loop cols.
    my $origcolumn = $column;
    $column =~ s/^items\./deleteditems./ if($cellvalue eq "deleteditems");
    my $colfield;
    if ( ( $column =~ /itemcallnumber/ ) and ($cotedigits) ) {
        $colfield = "left($column,$cotedigits)";
    } elsif ( $column =~ /^deleteditems\.timestamp$/ ) {
        $colfield = "DATE($column)";
    } else {
        $colfield = $column;
    }

    my $strsth2 = "
        SELECT distinctrow $colfield
        FROM   $itemstable
        LEFT JOIN biblioitems
            USING (biblioitemnumber)
        LEFT JOIN biblio
            ON (biblioitems.biblionumber = biblio.biblionumber)
        WHERE 1 ";
    $strsth2 .= " AND barcode $not LIKE ?" if $barcodefilter;

    if ( (@colfilter) and ( $colfilter[1] ) ) {
        $strsth2 .= " AND $column >= ? AND $column <= ?";
    } elsif ( defined $colfilter[0] and $colfilter[0] ne '' ) {
        $colfilter[0] =~ s/\*/%/g;
        $strsth2 .= " AND $column LIKE ? ";
    }
    $strsth2 .= " ORDER BY $colfield";
    $debug and print STDERR "SQL: $strsth2";
    my $sth2 = $dbh->prepare($strsth2);
    if ( $barcodefilter and (@colfilter) and ( $colfilter[1] ) ) {
        $sth2->execute( $barcodefilter, $colfilter[0], $colfilter[1] );
    } elsif ( (@colfilter) and ( $colfilter[1] ) ) {
        $sth2->execute( $colfilter[0], $colfilter[1] );
    } elsif ( $barcodefilter && $colfilter[0] ) {
        $sth2->execute( $barcodefilter , $colfilter[0] );
    } elsif ( $colfilter[0]) {
        $sth2->execute( $colfilter[0] );
    } elsif ($barcodefilter) {
        $sth2->execute($barcodefilter);
    } else {
        $sth2->execute();
    }
    my $colauthvals = { map { $_->{authorised_value} => $_->{lib} } Koha::AuthorisedValues->get_descriptions_by_koha_field( { frameworkcode => '', kohafield => $origcolumn } ) };
    while ( my ($celvalue) = $sth2->fetchrow ) {
        my %cell;
        if (defined $celvalue and $celvalue ne '') {
            if($colauthvals and $colauthvals->{$celvalue}) {
                $cell{coltitle} = $colauthvals->{$celvalue};
            } else {
                $cell{coltitle} = $celvalue;
            }
            $cell{value} = $celvalue;
        }
        else {
            $cell{coltitle} = "NULL";
            $cell{value} = "zzEMPTY";
        }
        $cell{totalcol} = 0;
        push @loopcol, \%cell;
    }

    my $i = 0;
    my @totalcol;
    my $hilighted = -1;

    #Initialization of cell values.....
    my %table;

    foreach my $row (@loopline) {
        foreach my $col (@loopcol) {
            $table{ $row->{value} }->{ $col->{value} } = 0;
        }
        $table{ $row->{value} }->{totalrow} = 0;
    }

    # preparing calculation
    my $select_cellvalue = " COUNT(*) ";
    $select_cellvalue = " COUNT(DISTINCT biblioitems.biblionumber) " if($cellvalue eq 'biblios');
    my $strcalc = "
        SELECT $linefield, $colfield, $select_cellvalue
        FROM $itemstable
        LEFT JOIN biblioitems ON ($itemstable.biblioitemnumber = biblioitems.biblioitemnumber)
        LEFT JOIN biblio ON (biblioitems.biblionumber = biblio.biblionumber)
        WHERE 1 ";

    my @sqlargs;

    if ($barcodefilter) {
        $strcalc .= "AND barcode $not like ? ";
        push @sqlargs, $barcodefilter;
    }

    if ( @$filters[0] ) {
        $strcalc .= " AND $itemstable.itemcallnumber >= ? ";
        @$filters[0] =~ s/\*/%/g;
        push @sqlargs, @$filters[0];
    }

    if ( @$filters[1] ) {
        $strcalc .= " AND $itemstable.itemcallnumber <= ? ";
        @$filters[1] =~ s/\*/%/g;
        push @sqlargs, @$filters[1];
    }

    if ( @$filters[2] ) {
        $strcalc .= " AND " . ( C4::Context->preference('item-level_itypes') ? "$itemstable.itype" : 'biblioitems.itemtype' ) . " LIKE ? ";
        @$filters[2] =~ s/\*/%/g;
        push @sqlargs, @$filters[2];
    }

    if ( @$filters[3] ) {
        $strcalc .= " AND biblioitems.publishercode LIKE ? ";
        @$filters[3] =~ s/\*/%/g;
        @$filters[3] .= "%" unless @$filters[3] =~ /%/;
        push @sqlargs, @$filters[3];
    }
    if ( @$filters[4] ) {
        $strcalc .= " AND " .
        (C4::Context->preference('marcflavour') eq 'UNIMARC' ? 'publicationyear' : 'copyrightdate')
        . "> ? ";
        @$filters[4] =~ s/\*/%/g;
        push @sqlargs, @$filters[4];
    }
    if ( @$filters[5] ) {
        @$filters[5] =~ s/\*/%/g;
        $strcalc .= " AND " .
        (C4::Context->preference('marcflavour') eq 'UNIMARC' ? 'publicationyear' : 'copyrightdate')
        . "< ? ";
        push @sqlargs, @$filters[5];
    }
    if ( @$filters[6] ) {
        $strcalc .= " AND $itemstable.homebranch LIKE ? ";
        @$filters[6] =~ s/\*/%/g;
        push @sqlargs, @$filters[6];
    }
    if ( @$filters[7] ) {
        $strcalc .= " AND $itemstable.location LIKE ? ";
        @$filters[7] =~ s/\*/%/g;
        push @sqlargs, @$filters[7];
    }
    if ( @$filters[8] ) {
        $strcalc .= " AND $itemstable.ccode  LIKE ? ";
        @$filters[8] =~ s/\*/%/g;
        push @sqlargs, @$filters[8];
    }
    if ( defined @$filters[9] and @$filters[9] ne '' ) {
        $strcalc .= " AND $itemstable.notforloan  LIKE ? ";
        @$filters[9] =~ s/\*/%/g;
        push @sqlargs, @$filters[9];
    }
    if ( defined @$filters[10] and @$filters[10] ne '' ) {
        $strcalc .= " AND $itemstable.materials  LIKE ? ";
        @$filters[10] =~ s/\*/%/g;
        push @sqlargs, @$filters[10];
    }
    if ( @$filters[13] ) {
        $strcalc .= " AND $itemstable.dateaccessioned >= ? ";
        @$filters[13] =~ s/\*/%/g;
        push @sqlargs, @$filters[13];
    }
    if ( @$filters[14] ) {
        $strcalc .= " AND $itemstable.dateaccessioned <= ? ";
        @$filters[14] =~ s/\*/%/g;
        push @sqlargs, @$filters[14];
    }
    if ( $cellvalue eq 'deleteditems' and @$filters[15] ) {
        $strcalc .= " AND DATE(deleteditems.timestamp) >= ? ";
        @$filters[15] =~ s/\*/%/g;
        push @sqlargs, @$filters[15];
    }
    if ( $cellvalue eq 'deleteditems' and @$filters[16] ) {
        @$filters[16] =~ s/\*/%/g;
        $strcalc .= " AND DATE(deleteditems.timestamp) <= ?";
        push @sqlargs, @$filters[16];
    }
    $strcalc .= " group by $linefield, $colfield order by $linefield,$colfield";
    $debug and warn "SQL: $strcalc";
    my $dbcalc = $dbh->prepare($strcalc);
    $dbcalc->execute(@sqlargs);

    while ( my ( $row, $col, $value ) = $dbcalc->fetchrow ) {

        $col      = "zzEMPTY" if ( !defined($col) );
        $row      = "zzEMPTY" if ( !defined($row) );

        $table{$row}->{$col}     += $value;
        $table{$row}->{totalrow} += $value;
        $grantotal               += $value;
    }

    foreach my $row ( @loopline ) {
        my @loopcell;

        #@loopcol ensures the order for columns is common with column titles
        # and the number matches the number of columns
        foreach my $col (@loopcol) {
            my $value = $table{$row->{value}}->{ $col->{value} };
            push @loopcell, { value => $value };
        }
        push @looprow,
          { 'rowtitle' => $row->{rowtitle},
            'value'    => $row->{value},
            'loopcell' => \@loopcell,
            'hilighted' => ( $hilighted *= -1 > 0 ),
            'totalrow' => $table{$row->{value}}->{totalrow}
          };
    }

    foreach my $col (@loopcol) {
        my $total = 0;
        foreach my $row (@looprow) {
            $total += $table{ $row->{value} }->{ $col->{value} };
        }

        push @loopfooter, { 'totalcol' => $total };
    }

    # the header of the table
    $globalline{loopfilter} = \@loopfilter;

    # the core of the table
    $globalline{looprow} = \@looprow;
    $globalline{loopcol} = \@loopcol;

    # the foot (totals by borrower type)
    $globalline{loopfooter} = \@loopfooter;
    $globalline{total}      = $grantotal;
    $globalline{line}       = $line;
    $globalline{column}     = $column;
    push @mainloop, \%globalline;
    return \@mainloop;
}
