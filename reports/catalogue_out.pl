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
use warnings;
use CGI;

use C4::Auth;
use C4::Context;
use C4::Debug;
use C4::Branch;    # GetBranchesLoop
use C4::Output;
use C4::Koha;      # GetItemTypes
# use Date::Manip;  # TODO: add not borrowed since date X criteria
use Data::Dumper;

=head1 catalogue_out

Report that shows unborrowed items.

=cut

my $input   = new CGI;
my $do_it   = $input->param('do_it');
my $limit   = $input->param("Limit") || 10;
my $column  = $input->param("Criteria");
my @filters = $input->param("Filter");

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "reports/catalogue_out.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { reports => 'execute_reports' },
        debug           => 1,
    }
);

$template->param( do_it => $do_it );
if ($do_it) {
    my $results = calculate( $limit, $column, \@filters );
    $template->param( mainloop => $results );
    output_html_with_http_headers $input, $cookie, $template->output;
    exit;    # in either case, exit after do_it
}

# Displaying choices (i.e., not do_it)
my $itemtypes = GetItemTypes();
my @itemtypeloop;
foreach (
    sort { $itemtypes->{$a}->{'description'} cmp $itemtypes->{$b}->{'description'} }
    keys %$itemtypes
  )
{
    push @itemtypeloop,
      {
        value       => $_,
        description => $itemtypes->{$_}->{'description'},
      };
}

$template->param(
    itemtypeloop => \@itemtypeloop,
    branchloop   => GetBranchesLoop(),
);
output_html_with_http_headers $input, $cookie, $template->output;

sub calculate {
    my ( $limit, $column, $filters ) = @_;
    my @loopline;
    my @looprow;
    my %globalline;
    my %columns = ();
    my $dbh     = C4::Context->dbh;

    # Filters
    # Checking filters
    #
    my @loopfilter;
    for ( my $i = 0 ; $i <= 6 ; $i++ ) {
        if ( @$filters[$i] ) {
            my %cell = ( filter => @$filters[$i] );
            if ( ( $i == 1 ) and ( @$filters[ $i - 1 ] ) ) {
                $cell{err} = 1 if ( @$filters[$i] < @$filters[ $i - 1 ] );
            }
            $cell{crit} = "Branch"   if ( $i == 0 );
            $cell{crit} = "Doc Type" if ( $i == 1 );
            push @loopfilter, \%cell;
        }
    }
    push @loopfilter, { crit => 'limit', filter => $limit } if ($limit);
    if ($column) {
        push @loopfilter, { crit => 'by', filter => $column };
        my $tablename = ( $column =~ /branchcode/ ) ? 'branches' : 'items';
        $column =
          ( $column =~ /branchcode/ or $column =~ /itype/ )
          ? "$tablename.$column"
          : $column;
        my $strsth2 =
          ( $tablename eq 'branches' )
          ? "SELECT $column as coltitle, count(items.itemnumber) AS coltitle_count FROM $tablename LEFT JOIN items ON items.homebranch=$column "
          : "SELECT $column as coltitle, count(*)                AS coltitle_count FROM $tablename ";
        if ( $tablename eq 'branches' ) {
            my $f = @$filters[0];
            $f =~ s/\*/%/g;
            $strsth2 .= " AND $column LIKE '$f' ";
        }
        $strsth2 .= " GROUP BY $column ORDER BY $column ";    # needed for count
        push @loopfilter, { crit => 'SQL', sql => 1, filter => $strsth2 };
        $debug and warn "catalogue_out SQL: " . $strsth2;
        my $sth2 = $dbh->prepare($strsth2);
        $sth2->execute;

        while ( my ( $celvalue, $count ) = $sth2->fetchrow ) {
            ($celvalue) or $celvalue = 'UNKNOWN';
            $columns{$celvalue} = $count;
        }
    }

    my %tables = ( map { $_ => [] } keys %columns );

    # preparing calculation
    my @exe_args = ();
    my $query    = "
        SELECT items.barcode        as barcode,
               items.homebranch     as branch,
               items.itemcallnumber as itemcallnumber,
               biblio.title         as title,
               biblio.biblionumber  as biblionumber,
               biblio.author        as author";
    ($column) and $query .= ",\n$column as col ";
    $query .= "
        FROM items
        LEFT JOIN biblio      USING (biblionumber)
        LEFT JOIN     issues  USING (itemnumber)
        LEFT JOIN old_issues  USING (itemnumber)
          WHERE       issues.itemnumber IS NULL
           AND    old_issues.itemnumber IS NULL
	";
    if ( $filters->[0] ) {
        $filters->[0] =~ s/\*/%/g;
        push @exe_args, $filters->[0];
        $query .= " AND items.homebranch LIKE ?";
    }
    if ( $filters->[1] ) {
        $filters->[1] =~ s/\*/%/g;
        push @exe_args, $filters->[1];
        $query .= " AND items.itype      LIKE ?";
    }
    if ($column) {
        $query .= " AND $column = ? GROUP BY items.itemnumber, $column ";
        # placeholder handled below
    }
    else {
        $query .= " GROUP BY items.itemnumber ";
    }
    $query .= " ORDER BY items.itemcallnumber DESC, barcode";
    $query .= " LIMIT 0,$limit" if ($limit);
    $debug and warn "SQL : $query";

    # warn "SQL : $query";
    push @loopfilter, { crit => 'SQL', sql => 1, filter => $query };
    my $dbcalc = $dbh->prepare($query);

    if ($column) {
        foreach ( sort keys %columns ) {
            # execute(@exe_args,$_) would fail when the array is empty
            # but @more_exe_args will work
            my (@more_exe_args) = @exe_args;
            push @more_exe_args, $_;
            $dbcalc->execute(@more_exe_args)
              or die "Query execute(@more_exe_args) failed: $query";
            while ( my $data = $dbcalc->fetchrow_hashref ) {
                my $col = $data->{col} || 'NULL';
                $tables{$col} or $tables{$col} = [];
                push @{ $tables{$col} }, $data;
            }
        }
    }
    else {
        ( scalar @exe_args ) ? $dbcalc->execute(@exe_args) : $dbcalc->execute;
        while ( my $data = $dbcalc->fetchrow_hashref ) {
            my $col = $data->{col} || 'NULL';
            $tables{$col} or $tables{$col} = [];
            push @{ $tables{$col} }, $data;
        }
    }

    foreach my $tablename ( sort keys %tables ) {
        my (@temptable);
        my $i = 0;
        foreach my $cell ( @{ $tables{$tablename} } ) {
            if ( 0 == $i++ and $debug ) {
                my $dump = Dumper($cell);
                $dump =~ s/\n/ /gs;
                $dump =~ s/\s+/ /gs;
                print STDERR "first cell for $tablename: $dump";
            }
            push @temptable, $cell;
        }
        my $count    = scalar(@temptable);
        my $allitems = $columns{$tablename};
        $globalline{total_looptable_count} += $count;
        $globalline{total_coltitle_count}  += $allitems;
        push @{ $globalline{looptables} },
          {
            looprow         => \@temptable,
            coltitle        => $tablename,
            coltitle_count  => $allitems,
            looptable_count => $count,
            looptable_first => ($count) ? $temptable[0]->{itemcallnumber} : '',
            looptable_last  => ($count) ? $temptable[-1]->{itemcallnumber} : '',
          };
    }

    # the header of the table
    $globalline{loopfilter} = \@loopfilter;
    $globalline{limit}      = $limit;
    $globalline{column}     = $column;
    return [ ( \%globalline ) ];    # reference to array of reference to hash
}

1;
__END__

