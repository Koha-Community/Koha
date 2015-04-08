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
use CGI;
use C4::Context;
use C4::Reports;
use C4::Output;
use C4::Koha;
use C4::Circulation;
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Branch;
use C4::Biblio;

=head1 NAME

reports/acquisitions_stats.pl

=head1 DESCRIPTION

Plugin that shows a stats on borrowers

=cut

my $input          = new CGI;
my $do_it          = $input->param('do_it');
my $fullreportname = "reports/acquisitions_stats.tt";
my $line           = $input->param("Line");
my $column         = $input->param("Column");
my @filters        = $input->param("Filter");
$filters[0] = format_date_in_iso( $filters[0] );
$filters[1] = format_date_in_iso( $filters[1] );
$filters[2] = format_date_in_iso( $filters[2] );
$filters[3] = format_date_in_iso( $filters[3] );
my $podsp          = $input->param("PlacedOnDisplay");
my $rodsp          = $input->param("ReceivedOnDisplay");
my $calc           = $input->param("Cellvalue");
my $output         = $input->param("output");
my $basename       = $input->param("basename");

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => $fullreportname,
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { reports => '*' },
        debug           => 1,
    }
);

our $sep     = $input->param("sep") // '';
$sep = "\t" if ($sep eq 'tabulation');

$template->param(
    do_it                    => $do_it,
);

if ($do_it) {
    my $results =
      calculate( $line, $column, $podsp, $rodsp, $calc, \@filters );
    if ( $output eq "screen" ) {
        $template->param( mainloop => $results );
        output_html_with_http_headers $input, $cookie, $template->output;
    }
    else {
        print $input->header(
            -type       => 'application/vnd.sun.xml.calc',
            -encoding    => 'utf-8',
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
    }
    exit;
}
else {
    my $dbh = C4::Context->dbh;
    my $req;
    $req = $dbh->prepare("SELECT distinctrow id,name FROM aqbooksellers ORDER BY name");
    $req->execute;
    my $booksellers = $req->fetchall_arrayref({});

    $req = $dbh->prepare("SELECT DISTINCTROW itemtype,description FROM itemtypes ORDER BY description");
    $req->execute;
    my @iselect;
    my %iselect;
    while ( my ( $value, $desc ) = $req->fetchrow ) {
        push @iselect, $value;
        $iselect{$value} = $desc;
    }
    my $ItemTypes = {
        values  => \@iselect,
        labels  => \%iselect,
   };

    $req = $dbh->prepare("SELECT DISTINCTROW budget_code, budget_name FROM aqbudgets ORDER BY budget_name");
    $req->execute;
    my @bselect;
    my %bselect;

    while ( my ( $value, $desc ) = $req->fetchrow ) {
        push @bselect, $value;
        $bselect{$value} = $desc;
    }
    my $Budgets = {
        values   => \@bselect,
        labels   => \%bselect,
    };

    $req =
      $dbh->prepare(
"SELECT DISTINCTROW sort1 FROM aqorders WHERE sort1 IS NOT NULL ORDER BY sort1"
      );
    $req->execute;
    my @s1select;
    my %s1select;
    my $hassort1;
    while ( my ($value) = $req->fetchrow ) {
        if ($value) {
            $hassort1 = 1;
            push @s1select, $value;
            $s1select{$value} = $value;
        }
    }
    my $Sort1 = {
        values   => \@s1select,
        labels   => \%s1select,
    };

    $req =
      $dbh->prepare(
"SELECT DISTINCTROW sort2 FROM aqorders WHERE sort2 IS NOT NULL ORDER BY sort2"
      );
    $req->execute;
    my @s2select;
    my %s2select;
    my $hassort2;
    my $hglghtsort2;

    while ( my ($value) = $req->fetchrow ) {
        if ($value) {
            $hassort2    = 1;
            $hglghtsort2 = !($hassort1);
            push @s2select, $value;
            $s2select{$value} = $value;
        }
    }
    my $Sort2 = {
        values   => \@s2select,
        labels   => \%s2select,
    };

    my $CGIsepChoice = GetDelimiterChoices;

    my $branches = GetBranches;
    my @branches;
    foreach ( sort keys %$branches ) {
        push @branches, $branches->{$_};
    }

    my $ccode_subfield_structure = GetMarcSubfieldStructureFromKohaField('items.ccode', '');
    my $ccode_label;
    my $ccode_avlist;
    if($ccode_subfield_structure) {
        $ccode_label = $ccode_subfield_structure->{liblibrarian};
        $ccode_avlist = GetAuthorisedValues($ccode_subfield_structure->{authorised_value});
    }

    $template->param(
        booksellers   => $booksellers,
        ItemTypes     => $ItemTypes,
        Budgets       => $Budgets,
        hassort1      => $hassort1,
        hassort2      => $hassort2,
        Sort1         => $Sort1,
        Sort2         => $Sort2,
        CGIsepChoice  => $CGIsepChoice,
        branches      => \@branches,
        ccode_label   => $ccode_label,
        ccode_avlist  => $ccode_avlist,
    );

}
output_html_with_http_headers $input, $cookie, $template->output;

sub calculate {
    my ( $line, $column, $podsp, $rodsp, $process, $filters ) = @_;
    my @mainloop;
    my @loopfooter;
    my @loopcol;
    my @loopline;
    my @looprow;
    my %globalline;
    my $grantotal = 0;

    $podsp ||= 0;
    $rodsp ||= 0;

    # extract parameters
    my $dbh = C4::Context->dbh;

    # Filters
    # Checking filters
    #
    my @loopfilter;
    for ( my $i = 0 ; $i <= @$filters ; $i++ ) {
        if( defined @$filters[$i] and @$filters[$i] ne '' ) {
            my %cell;
            if ( ( ( $i == 1 ) or ( $i == 3 ) ) and ( @$filters[ $i - 1 ] ) ) {
                $cell{err} = 1 if ( @$filters[$i] lt @$filters[ $i - 1 ] );
            }
            # format the dates filters, otherwise just fill as is
            if ($i >= 4) {
                $cell{filter} = @$filters[$i];
            } else {
                $cell{filter} = format_date(@$filters[$i]);
            }
            $cell{crit} = $i;
            push @loopfilter, \%cell;
        }
    }

    my %filter;
    my %field;
    foreach ($line, $column) {
        $filter{$_} = [];
        $field{$_} = $_;
        if ( $_ =~ /closedate/ ) {
            $filter{$_}->[0] = @$filters[0];
            $filter{$_}->[1] = @$filters[1];
            my $a = $_;
            if ( $podsp == 1 ) {
                $field{$a} = "concat(hex(weekday($a)+1),'-',dayname($a))";
            } elsif ( $podsp == 2 ) {
                $field{$a} = "concat(hex(month($a)),'-',monthname($a))";
            } elsif ( $podsp == 3 ) {
                $field{$a} = "Year($a)";
            } else {
                $field{$a} = $a;
            }
        }
        elsif ( $_ =~ /received/ ) {
            $filter{$_}->[0] = @$filters[2];
            $filter{$_}->[1] = @$filters[3];
            my $a = $_;
            if ( $rodsp == 1 ) {
                $field{$a} = "concat(hex(weekday($a)+1),'-',dayname($a))";
            } elsif ( $rodsp == 2 ) {
                $field{$a} = "concat(hex(month($a)),'-',monthname($a))";
            } elsif ( $rodsp == 3 ) {
                $field{$a} = "Year($a)";
            } else {
                field{$a} = $a;
            }
        }
        elsif ( $_ =~ /bookseller/ ) {
            $filter{$_}->[0] = @$filters[4];
        }
        elsif ( $_ =~ /homebranch/ ) {
            $filter{$_}->[0] = @$filters[5];
        }
        elsif ( $_ =~ /ccode/ ) {
            $filter{$_}->[0] = @$filters[6];
        }
        elsif ( $_ =~ /itemtype/ ) {
            $filter{$_}->[0] = @$filters[7];
        }
        elsif ( $_ =~ /budget/ ) {
            $filter{$_}->[0] = @$filters[8];
        }
        elsif ( $_ =~ /sort1/ ) {
            $filter{$_}->[0] = @$filters[9];
        }
        elsif ( $_ =~ /sort2/ ) {
            $filter{$_}->[0] = @$filters[10];
        }
    }

    my @linefilter = @{ $filter{$line} };
    my $linefield = $field{$line};
    my @colfilter = @{ $filter{$column} };
    my $colfield = $field{$column};

    # 1st, loop rows.
    my $strsth = "
        SELECT DISTINCTROW $linefield
        FROM aqorders
          LEFT JOIN aqbasket ON (aqorders.basketno = aqbasket.basketno)
          LEFT JOIN aqorders_items ON (aqorders.ordernumber = aqorders_items.ordernumber)
          LEFT JOIN items ON (aqorders_items.itemnumber = items.itemnumber)
          LEFT JOIN biblioitems ON (aqorders.biblionumber = biblioitems.biblionumber)
          LEFT JOIN aqbudgets  ON (aqorders.budget_id = aqbudgets.budget_id )
          LEFT JOIN aqbooksellers ON (aqbasket.booksellerid = aqbooksellers.id)
        WHERE $line IS NOT NULL AND $line <> '' ";

    if (@linefilter) {
        if ( $linefilter[1] ) {
            if ( $linefilter[0] ) {
                $strsth .= " AND $line BETWEEN ? AND ? ";
            }
            else {
                $strsth .= " AND $line <= ? ";
            }
        }
        elsif (
            ( $linefilter[0] )
            and (  ( $line =~ /closedate/ )
                or ( $line =~ /received/ ))
          )
        {
            $strsth .= " AND $line >= ? ";
        }
        elsif ( $linefilter[0] ) {
            $linefilter[0] =~ s/\*/%/g;
            $strsth .= " AND $line LIKE ? ";
        }
    }
    $strsth .= " GROUP BY $linefield";
    $strsth .= " ORDER BY $line";

    my $sth = $dbh->prepare($strsth);
    if ( (@linefilter) and ( $linefilter[1] ) ) {
        $sth->execute( $linefilter[0], $linefilter[1] );
    }
    elsif ( $linefilter[0] ) {
        $sth->execute( $linefilter[0] );
    }
    else {
        $sth->execute;
    }
    while ( my ($celvalue) = $sth->fetchrow ) {
        my %cell;
        if ($celvalue) {
            $cell{rowtitle} = $celvalue;
            push @loopline, \%cell;
        }
        $cell{totalrow} = 0;
    }

    # 2nd, loop cols.
    my $strsth2 = "
        SELECT DISTINCTROW $colfield
        FROM aqorders
          LEFT JOIN aqbasket ON (aqorders.basketno = aqbasket.basketno)
          LEFT JOIN aqorders_items ON (aqorders.ordernumber = aqorders_items.ordernumber)
          LEFT JOIN items ON (aqorders_items.itemnumber = items.itemnumber)
          LEFT JOIN biblioitems ON (aqorders.biblionumber = biblioitems.biblionumber)
          LEFT JOIN aqbudgets  ON (aqorders.budget_id = aqbudgets.budget_id )
          LEFT JOIN aqbooksellers ON (aqbasket.booksellerid = aqbooksellers.id)
        WHERE $column IS NOT NULL AND $column <> ''
    ";

    if (@colfilter) {
        if ( $colfilter[1] ) {
            if ( $colfilter[0] ) {
                $strsth2 .= " AND $column BETWEEN  ? AND ? ";
            }
            else {
                $strsth2 .= " AND $column <= ? ";
            }
        }
        elsif (
            ( $colfilter[0] )
            and (  ( $column =~ /closedate/ )
                or ( $line =~ /received/ ))
          )
        {
            $strsth2 .= " AND $column >= ? ";
        }
        elsif ( $colfilter[0] ) {
            $colfilter[0] =~ s/\*/%/g;
            $strsth2 .= " AND $column LIKE ? ";
        }
    }

    $strsth2 .= " GROUP BY $colfield";
    $strsth2 .= " ORDER BY $colfield";

    my $sth2 = $dbh->prepare($strsth2);

    if ( (@colfilter) and ($colfilter[1]) ) {
        $sth2->execute( $colfilter[0], $colfilter[1] );
    }
    elsif ( $colfilter[0] ) {
        $sth2->execute( $colfilter[0] );
    }
    else {
        $sth2->execute;
    }
    while ( my $celvalue = $sth2->fetchrow ) {
        my %cell;
        if ($celvalue) {
            $cell{coltitle} = $celvalue;
            push @loopcol, \%cell;
        }
    }

    my $i = 0;
    my @totalcol;
    my $hilighted = -1;

    #Initialization of cell values.....
    my %table;

    foreach my $row (@loopline) {
        foreach my $col (@loopcol) {
            $table{ $row->{rowtitle} }->{ $col->{coltitle} } = 0;
        }
        $table{ $row->{rowtitle} }->{totalrow} = 0;
    }

    # preparing calculation
    my $strcalc;
    $strcalc .= "SELECT $linefield, $colfield, ";
    if ( $process == 1 ) {
        $strcalc .= "COUNT(*) ";
    } elsif ( $process == 2 ) {
        $strcalc .= "COUNT(DISTINCT(aqorders.biblionumber)) ";
    } elsif ( $process == 3 || $process == 4 || $process == 5 ) {
        $strcalc .= "SUM(aqorders.listprice) ";
    } else {
        $strcalc .= "NULL ";
    }
    $strcalc .= "
        FROM aqorders
          LEFT JOIN aqbasket ON (aqorders.basketno = aqbasket.basketno)
          LEFT JOIN aqorders_items ON (aqorders.ordernumber = aqorders_items.ordernumber)
          LEFT JOIN items ON (aqorders_items.itemnumber = items.itemnumber)
          LEFT JOIN biblioitems ON (aqorders.biblionumber = biblioitems.biblionumber)
          LEFT JOIN aqbudgets ON (aqorders.budget_id = aqbudgets.budget_id )
          LEFT JOIN aqbooksellers ON (aqbasket.booksellerid = aqbooksellers.id)
        WHERE aqorders.datecancellationprinted IS NULL ";
    $strcalc .= " AND (aqorders.datereceived IS NULL OR aqorders.datereceived = '') "
        if ( $process == 4 );
    $strcalc .= " AND aqorders.datereceived IS NOT NULL AND aqorders.datereceived <> '' "
        if ( $process == 5 );
    @$filters[0] =~ s/\*/%/g if ( @$filters[0] );
    $strcalc .= " AND aqbasket.closedate >= '" . @$filters[0] . "'"
      if ( @$filters[0] );
    @$filters[1] =~ s/\*/%/g if ( @$filters[1] );
    $strcalc .= " AND aqbasket.closedate <= '" . @$filters[1] . "'"
      if ( @$filters[1] );
    @$filters[2] =~ s/\*/%/g if ( @$filters[2] );
    $strcalc .= " AND aqorders.datereceived >= '" . @$filters[2] . "'"
      if ( @$filters[2] );
    @$filters[3] =~ s/\*/%/g if ( @$filters[3] );
    $strcalc .= " AND aqorders.datereceived <= '" . @$filters[3] . "'"
      if ( @$filters[3] );
    @$filters[4] =~ s/\*/%/g if ( @$filters[4] );
    $strcalc .= " AND aqbooksellers.name LIKE '" . @$filters[4] . "'"
      if ( @$filters[4] );
    $strcalc .= " AND items.homebranch = '" . @$filters[5] . "'"
      if ( @$filters[5] );
    @$filters[6] =~ s/\*/%/g if ( @$filters[6] );
    $strcalc .= " AND items.ccode = '" . @$filters[6] . "'"
      if ( @$filters[6] );
    @$filters[7] =~ s/\*/%/g if ( @$filters[7] );
    $strcalc .= " AND biblioitems.itemtype LIKE '" . @$filters[7] . "'"
      if ( @$filters[7] );
    @$filters[8] =~ s/\*/%/g if ( @$filters[8] );
    $strcalc .= " AND aqbudgets.budget_code LIKE '" . @$filters[8] . "'"
      if ( @$filters[8] );
    @$filters[9] =~ s/\*/%/g if ( @$filters[9] );
    $strcalc .= " AND aqorders.sort1 LIKE '" . @$filters[9] . "'"
      if ( @$filters[9] );
    @$filters[10] =~ s/\*/%/g if ( @$filters[10] );
    $strcalc .= " AND aqorders.sort2 LIKE '" . @$filters[10] . "'"
      if ( @$filters[10] );

    $strcalc .= " GROUP BY $linefield, $colfield ORDER BY $linefield,$colfield";
    my $dbcalc = $dbh->prepare($strcalc);
    $dbcalc->execute;

    my $emptycol;
    while ( my ( $row, $col, $value ) = $dbcalc->fetchrow ) {
        $emptycol = 1         if ( !defined($col) );
        $col      = "zzEMPTY" if ( !defined($col) );
        $row      = "zzEMPTY" if ( !defined($row) );

        $table{$row}->{$col}     += $value;
        $table{$row}->{totalrow} += $value;
        $grantotal               += $value;
    }

    push @loopcol, { coltitle => "NULL" } if ($emptycol);

    foreach my $row ( sort keys %table ) {
        my @loopcell;
        #@loopcol ensures the order for columns is common with column titles
        # and the number matches the number of columns
        foreach my $col (@loopcol) {
            my $value = $table{$row}->{ ( $col->{coltitle} eq "NULL" ) ? "zzEMPTY" : $col->{coltitle} };
            $value = sprintf("%.2f", $value) if($value and grep /$process/, (3,4,5));
            push @loopcell, { value => $value };
        }
        my $r = {
            rowtitle => ( $row eq "zzEMPTY" ) ? "NULL" : $row,
            loopcell  => \@loopcell,
            hilighted => ( $hilighted > 0 ),
            totalrow  => $table{$row}->{totalrow}
        };
        $r->{totalrow} = sprintf("%.2f", $r->{totalrow}) if($r->{totalrow} and grep /$process/, (3,4,5));
        push @looprow, $r;
        $hilighted = -$hilighted;
    }

    foreach my $col (@loopcol) {
        my $total = 0;
        foreach my $row (@looprow) {
            $total += $table{
                ( $row->{rowtitle} eq "NULL" ) ? "zzEMPTY"
                : $row->{rowtitle}
              }->{
                ( $col->{coltitle} eq "NULL" ) ? "zzEMPTY"
                : $col->{coltitle}
              };
        }
        $total = sprintf("%.2f", $total) if($total and grep /$process/, (3,4,5));

        push @loopfooter, { 'totalcol' => $total };
    }

    # the header of the table
    $globalline{loopfilter} = \@loopfilter;
    # the core of the table
    $globalline{looprow} = \@looprow;
    $globalline{loopcol} = \@loopcol;

    #       # the foot (totals by borrower type)
    $grantotal = sprintf("%.2f", $grantotal) if ($grantotal and grep /$process/, (3,4,5));
    $globalline{loopfooter} = \@loopfooter;
    $globalline{total}      = $grantotal;
    $globalline{line}       = $line;
    $globalline{column}     = $column;
    push @mainloop, \%globalline;
    return \@mainloop;
}

1;

