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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use CGI        qw ( -utf8 );
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use C4::Context;
use C4::Reports qw( GetDelimiterChoices );

use Koha::ItemTypes;
use Koha::Patron::Categories;

=head1 NAME

plugin that shows a stats on borrowers

=head1 DESCRIPTION

=cut

my $input          = CGI->new;
my $fullreportname = "reports/bor_issues_top.tt";
my $do_it          = $input->param('do_it');
my $limit          = $input->param("Limit");
my $column         = $input->param("Criteria");
my @filters        = $input->multi_param("Filter");
my $output         = $input->param("output");
my $basename       = $input->param("basename");
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => $fullreportname,
        query         => $input,
        type          => "intranet",
        flagsrequired => { reports => '*' },
    }
);
our $sep = C4::Context->csv_delimiter( scalar $input->param("sep") );
$template->param(
    do_it => $do_it,
);
if ($do_it) {

    # Displaying results
    my $results = calculate( $limit, $column, \@filters );
    if ( $output eq "screen" ) {

        # Printing results to screen
        $template->param( mainloop => $results, limit => $limit );
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

        # header top-left
        print @$results[0]->{line} . "/" . @$results[0]->{column} . $sep;
        print "Patron" . $sep;
        print "Total" . $sep;

        # Other header
        print join( $sep, map { $_->{coltitle} } @$cols );
        print "\n";

        # Table
        foreach my $line (@$lines) {
            my $x = $line->{loopcell};
            print $line->{rowtitle} . $sep;
            print '"' . $line->{patron} . '"' . $sep;
            print join( $sep, map { $_->{count} } @$x );
            print "\n";
        }

        # footer
        print "TOTAL";
        $cols = @$results[0]->{loopfooter};
        print join( $sep, map { $_->{total} } @$cols );
        print $sep. @$results[0]->{total};
    }
    exit;
}

my $dbh = C4::Context->dbh;

# here each element returned by map is a hashref, get it?
my @mime   = ( map { { type => $_ } } ( split /[;:]/, 'CSV' ) );    # FIXME translation
my $delims = GetDelimiterChoices;

my $patron_categories = Koha::Patron::Categories->search_with_library_limits( {}, { order_by => ['categorycode'] } );
my $itemtypes         = Koha::ItemTypes->search_with_localization;
$template->param(
    mimeloop          => \@mime,
    CGIseplist        => $delims,
    itemtypes         => $itemtypes,
    patron_categories => $patron_categories,
);
output_html_with_http_headers $input, $cookie, $template->output;

sub calculate {
    my ( $limit, $column, $filters ) = @_;

    my @loopcol;
    my @looprow;
    my %globalline;
    my %columns;
    my $grantotal = 0;
    my $dbh       = C4::Context->dbh;

    # Checking filters
    my @loopfilter;
    my @cellmap = (
        "Issue From",
        "Issue To",
        "Return From",
        "Return To",
        "Branch",
        "Doc Type",
        "Bor Cat",
        "Day",
        "Month",
        "Year"
    );
    for ( my $i = 0 ; $i <= 6 ; $i++ ) {
        my %cell;
        if ( @$filters[$i] ) {
            if ( ( $i == 1 ) and ( @$filters[ $i - 1 ] ) ) {
                $cell{err} = 1 if ( @$filters[$i] < @$filters[ $i - 1 ] );
            }
            $cell{filter} .= @$filters[$i];
            defined( $cellmap[$i] )
                and $cell{crit} .= $cellmap[$i];
            push @loopfilter, \%cell;
        }
    }
    my $colfield;
    my $colorder;
    if ($column) {
        $column = "old_issues." . $column if ( ( $column =~ /branchcode/ ) or ( $column =~ /timestamp/ ) );
        $column = "items.itype"           if $column =~ /itemtype/;
        $column = "borrowers." . $column  if $column =~ /categorycode/;
        my @colfilter;
        if ( $column =~ /timestamp/ ) {
            $colfilter[0] = @$filters[0];
            $colfilter[1] = @$filters[1];
        } elsif ( $column =~ /returndate/ ) {
            $colfilter[0] = @$filters[2];
            $colfilter[1] = @$filters[3];
        } elsif ( $column =~ /branchcode/ ) {
            $colfilter[0] = @$filters[4];
        } elsif ( $column =~ /itemtype/ ) {
            $colfilter[0] = @$filters[5];
        } elsif ( $column =~ /category/ ) {
            $colfilter[0] = @$filters[6];
        } elsif ( $column =~ /sort2/ ) {

            # $colfilter[0] = @$filters[11];
        }

        # loop cols.
        if ( $column eq "Day" ) {

            #Display by day
            $column = "old_issues.timestamp";
            $colfield .= "dayname($column)";
            $colorder .= "weekday($column)";
        } elsif ( $column eq "Month" ) {

            #Display by Month
            $column = "old_issues.timestamp";
            $colfield .= "monthname($column)";
            $colorder .= "month($column)";
        } elsif ( $column eq "Year" ) {

            #Display by Year
            $column = "old_issues.timestamp";
            $colfield .= "Year($column)";
            $colorder .= $column;
        } else {
            $colfield .= $column;
            $colorder .= $column;
        }

        my $strsth2;
        $strsth2 .= "SELECT DISTINCTROW $colfield 
                     FROM `old_issues` 
                     LEFT JOIN borrowers   ON old_issues.borrowernumber=borrowers.borrowernumber 
                     LEFT JOIN items       ON old_issues.itemnumber=items.itemnumber 
                     LEFT JOIN biblioitems ON (biblioitems.biblioitemnumber=items.biblioitemnumber)
                     WHERE 1";
        if ( ( $column =~ /timestamp/ ) or ( $column =~ /returndate/ ) ) {
            if ( $colfilter[1] and $colfilter[0] ) {
                $strsth2 .= " AND $column between '$colfilter[0]' AND '$colfilter[1]' ";
            } elsif ( $colfilter[1] ) {
                $strsth2 .= " AND $column < '$colfilter[1]' ";
            } elsif ( $colfilter[0] ) {
                $strsth2 .= " AND $column > '$colfilter[0]' ";
            }
        } elsif ( $colfilter[0] ) {
            $colfilter[0] =~ s/\*/%/g;
            $strsth2 .= " AND $column LIKE '$colfilter[0]' ";
        }
        $strsth2 .= " GROUP BY $colfield";
        $strsth2 .= " ORDER BY $colorder";

        my $sth2 = $dbh->prepare($strsth2);
        $sth2->execute;
        while ( my @row = $sth2->fetchrow ) {
            $columns{ ( $row[0] || 'NULL' ) }++;
            push @loopcol, { coltitle => $row[0] || 'NULL' };
        }

        $strsth2 =~ s/old_issues/issues/g;
        $sth2 = $dbh->prepare($strsth2);
        $sth2->execute;
        while ( my @row = $sth2->fetchrow ) {
            $columns{ ( $row[0] || 'NULL' ) }++;
            push @loopcol, { coltitle => $row[0] || 'NULL' };
        }
    } else {
        $columns{''} = 1;
    }

    my $strcalc;

    # Processing average loanperiods
    $strcalc .=
        "SELECT  CONCAT_WS('', borrowers.surname , \",\\t\", borrowers.firstname),  COUNT(*) AS `RANK`, borrowers.borrowernumber AS ID";
    $strcalc .= " , $colfield " if ($colfield);
    $strcalc .= " FROM `old_issues`
                  LEFT JOIN  borrowers  USING(borrowernumber)
                  LEFT JOIN    items    USING(itemnumber)
                  LEFT JOIN biblioitems USING(biblioitemnumber)
                  WHERE old_issues.borrowernumber IS NOT NULL
                  ";
    my @filterterms = (
        'old_issues.issuedate >',
        'old_issues.issuedate <',
        'old_issues.returndate >',
        'old_issues.returndate <',
        'old_issues.branchcode  like',
        'items.itype            like',
        'borrowers.categorycode like',
    );
    foreach ( (@$filters)[ 0 .. 9 ] ) {
        my $term = shift @filterterms;    # go through both arrays in step
        ($_) or next;
        s/\*/%/g;
        $strcalc .= " AND $term '$_' ";
    }
    $strcalc .= " GROUP BY borrowers.borrowernumber";
    $strcalc .= ", $colfield" if ($column);
    $strcalc .= " ORDER BY `RANK` DESC";
    $strcalc .= ",$colfield "   if ($colfield);
    $strcalc .= " LIMIT $limit" if ($limit);

    my $dbcalc = $dbh->prepare($strcalc);
    $dbcalc->execute;
    my %patrons = ();

    # DATA STRUCTURE is going to look like this:
    #     (2253=> {name=>"John Doe",
    #                 allcols=>{MAIN=>12, MEDIA_LIB=>3}
    #             },
    #     )
    while ( my @data = $dbcalc->fetchrow ) {
        my ( $row, $rank, $id, $col ) = @data;
        $col = "zzEMPTY" if ( !defined($col) );
        unless ( $patrons{$id} ) {
            $patrons{$id} = { name => $row, allcols => {}, newcols => {}, oldcols => {} };
        }
        $patrons{$id}->{oldcols}->{$col} = $rank;
    }

    $strcalc =~ s/old_issues/issues/g;
    $dbcalc = $dbh->prepare($strcalc);
    $dbcalc->execute;
    while ( my @data = $dbcalc->fetchrow ) {
        my ( $row, $rank, $id, $col ) = @data;
        $col = "zzEMPTY" if ( !defined($col) );
        unless ( $patrons{$id} ) {
            $patrons{$id} = { name => $row, allcols => {}, newcols => {}, oldcols => {} };
        }
        $patrons{$id}->{newcols}->{$col} = $rank;
    }

    foreach my $id ( keys %patrons ) {
        my @uniq =
            keys %{ { %{ $patrons{$id}->{newcols} }, %{ $patrons{$id}->{oldcols} } } };    # get uniq keys, see perlfaq4
        foreach (@uniq) {
            my $count = ( $patrons{$id}->{newcols}->{$_} || 0 ) + ( $patrons{$id}->{oldcols}->{$_} || 0 );
            $patrons{$id}->{allcols}->{$_} = $count;
            $patrons{$id}->{total} += $count;
        }
    }

    my $i             = 1;
    my @cols_in_order = sort keys %columns;    # if you want to order the columns, do something here
    my @ranked_ids =
        sort { $patrons{$b}->{total} <=> $patrons{$a}->{total} || $patrons{$a}->{name} cmp $patrons{$b}->{name} }
        keys %patrons;
    foreach my $id (@ranked_ids) {
        my @loopcell;

        if ($column) {

            #  Total
            push @loopcell, {
                count => $patrons{$id}->{total},
            };
            foreach my $key (@cols_in_order) {
                push @loopcell, {
                    count => $patrons{$id}->{allcols}->{$key},
                };
                $grantotal += $patrons{$id}->{allcols}->{$key};
            }
        } else {
            push @loopcell, {
                count => $patrons{$id}->{total},
            };
            $grantotal += $patrons{$id}->{total};
        }
        push @looprow, {
            'rowtitle'    => $i++,
            'loopcell'    => \@loopcell,
            'highlighted' => ( $i % 2 ),
            'patron'      => $patrons{$id}->{name},
            'reference'   => $id,
        };

        # use a limit, if a limit is defined
        last if $i > $limit and $limit;
    }

    # the header of the table
    $globalline{loopfilter} = \@loopfilter;

    # the core of the table
    $globalline{looprow} = \@looprow;
    $globalline{loopcol} = [ map { { coltitle => $_ } } @cols_in_order ] if ($column);

    # the foot (totals by borrower type)
    $globalline{loopfooter} = [];
    $globalline{total}      = $grantotal;    # FIXME: useless
    $globalline{column}     = $column;
    return [ \%globalline ];                 # reference to a 1 element array: that element is a hashref
}

1;
__END__
