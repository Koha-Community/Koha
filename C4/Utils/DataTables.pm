package C4::Utils::DataTables;

# Copyright 2011 BibLibre
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
require Exporter;

use vars qw($VERSION @ISA @EXPORT);

BEGIN {
    $VERSION    = 3.07.00.049,

    @ISA        = qw(Exporter);
    @EXPORT     = qw(dt_build_orderby dt_build_having dt_get_params dt_build_query);
}

=head1 NAME

C4::Utils::DataTables - Utility subs for building query when DataTables source is AJAX

=head1 SYNOPSYS

    use CGI;
    use C4::Context;
    use C4::Utils::DataTables;

    my $input = new CGI;
    my $vars = $input->Vars;

    my $query = qq{
        SELECT surname, firstname
        FROM borrowers
        WHERE borrowernumber = ?
    };
    my ($having, $having_params) = dt_build_having($vars);
    $query .= $having;
    $query .= dt_build_orderby($vars);
    $query .= " LIMIT ?,? ";

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute(
        $vars->{'borrowernumber'},
        @$having_params,
        $vars->{'iDisplayStart'},
        $vars->{'iDisplayLength'}
    );
    ...

=head1 DESCRIPTION

    This module provide two utility functions to build a part of the SQL query,
    depending on DataTables parameters.
    One function build the 'ORDER BY' part, and the other the 'HAVING' part.

=head1 FUNCTIONS

=head2 dt_build_orderby

    my $orderby = dt_build_orderby($dt_param);
    This function takes a reference to a hash containing DataTables parameters
    and build the corresponding 'ORDER BY' clause.
    This hash must contains the following keys:
        iSortCol_N, where N is a number from 0 to the number of columns to sort on minus 1
        sSortDir_N is the sorting order ('asc' or 'desc) for the corresponding column
        mDataProp_N is a mapping between the column index, and the name of a SQL field

=cut

sub dt_build_orderby {
    my $param = shift;

    my $i = 0;
    my $orderby;
    my @orderbys;
    while(exists $param->{'iSortCol_'.$i}){
        my $iSortCol = $param->{'iSortCol_'.$i};
        my $sSortDir = $param->{'sSortDir_'.$i};
        my $mDataProp = $param->{'mDataProp_'.$iSortCol};
        my @sort_fields = $param->{$mDataProp.'_sorton'}
            ? split(' ', $param->{$mDataProp.'_sorton'})
            : ();
        if(@sort_fields > 0) {
            push @orderbys, "$_ $sSortDir" foreach (@sort_fields);
        } else {
            push @orderbys, "$mDataProp $sSortDir";
        }
        $i++;
    }

    $orderby = " ORDER BY " . join(',', @orderbys) . " " if @orderbys;
    return $orderby;
}

=head2 dt_build_having

    my ($having, $having_params) = dt_build_having($dt_params)

    This function takes a reference to a hash containing DataTables parameters
    and build the corresponding 'HAVING' clause.
    This hash must contains the following keys:
        sSearch is the text entered in the global filter
        iColumns is the number of columns
        bSearchable_N is a boolean value that is true if the column is searchable
        mDataProp_N is a mapping between the column index, and the name of a SQL field
        sSearch_N is the text entered in individual filter for column N

=cut

sub dt_build_having {
    my $param = shift;

    my @filters;
    my @params;

    # Global filter
    if($param->{'sSearch'}) {
        my $sSearch = $param->{'sSearch'};
        my $i = 0;
        my @gFilters;
        my @gParams;
        while($i < $param->{'iColumns'}) {
            if($param->{'bSearchable_'.$i} eq 'true') {
                my $mDataProp = $param->{'mDataProp_'.$i};
                my @filter_fields = $param->{$mDataProp.'_filteron'}
                    ? split(' ', $param->{$mDataProp.'_filteron'})
                    : ();
                if(@filter_fields > 0) {
                    foreach my $field (@filter_fields) {
                        push @gFilters, " $field LIKE ? ";
                        push @gParams, "%$sSearch%";
                    }
                } else {
                    push @gFilters, " $mDataProp LIKE ? ";
                    push @gParams, "%$sSearch%";
                }
            }
            $i++;
        }
        push @filters, " (" . join(" OR ", @gFilters) . ") ";
        push @params, @gParams;
    }

    # Individual filters
    my $i = 0;
    while($i < $param->{'iColumns'}) {
        my $sSearch = $param->{'sSearch_'.$i};
        if($sSearch) {
            my $mDataProp = $param->{'mDataProp_'.$i};
            my @filter_fields = $param->{$mDataProp.'_filteron'}
                ? split(' ', $param->{$mDataProp.'_filteron'})
                : ();
            if(@filter_fields > 0) {
                my @localfilters;
                foreach my $field (@filter_fields) {
                    push @localfilters, " $field LIKE ? ";
                    push @params, "%$sSearch%";
                }
                push @filters, " ( ". join(" OR ", @localfilters) ." ) ";
            } else {
                push @filters, " $mDataProp LIKE ? ";
                push @params, "%$sSearch%";
            }
        }
        $i++;
    }

    return (\@filters, \@params);
}

=head2 dt_get_params

    my %dtparam = = dt_get_params( $input )
    This function takes a reference to a new CGI object.
    It prepares a hash containing Datatable parameters.

=cut
sub dt_get_params {
    my $input = shift;
    my %dtparam;
    my $vars = $input->Vars;

    foreach(qw/ iDisplayStart iDisplayLength iColumns sSearch bRegex iSortingCols sEcho /) {
        $dtparam{$_} = $input->param($_);
    }
    foreach(grep /(?:_sorton|_filteron)$/, keys %$vars) {
        $dtparam{$_} = $vars->{$_};
    }
    for(my $i=0; $i<$dtparam{'iColumns'}; $i++) {
        foreach(qw/ bSearchable sSearch bRegex bSortable iSortCol mDataProp sSortDir /) {
            my $key = $_ . '_' . $i;
            $dtparam{$key} = $input->param($key) if defined $input->param($key);
        }
    }
    return %dtparam;
}

=head2 dt_build_query_simple

    my ( $query, $params )= dt_build_query_simple( $value, $field )

    This function takes a value and a field (table.field).

    It returns (undef, []) if not $value.
    Else, returns a SQL where string and an arrayref containing parameters
    for the execute method of the statement.

=cut
sub dt_build_query_simple {
    my ( $value, $field ) = @_;
    my $query;
    my @params;
    if( $value ) {
        $query .= " AND $field = ? ";
        push @params, $value;
    }
    return ( $query, \@params );
}

=head2 dt_build_query_dates

    my ( $query, $params )= dt_build_query_dates( $datefrom, $dateto, $field)

    This function takes a datefrom, dateto and a field (table.field).

    It returns (undef, []) if not $value.
    Else, returns a SQL where string and an arrayref containing parameters
    for the execute method of the statement.

=cut
sub dt_build_query_dates {
    my ( $datefrom, $dateto, $field ) = @_;
    my $query;
    my @params;
    if ( $datefrom ) {
        $query .= " AND $field >= ? ";
        push @params, C4::Dates->new($datefrom)->output('iso');
    }
    if ( $dateto ) {
        $query .= " AND $field <= ? ";
        push @params, C4::Dates->new($dateto)->output('iso');
    }
    return ( $query, \@params );
}

=head2 dt_build_query

    my ( $query, $filter ) = dt_build_query( $type, @params )

    This function takes a value and a list of parameters.

    It calls dt_build_query_dates or dt_build_query_simple function of $type.

    $type can contain 'simple' or 'range_dates'.
    if $type is not matched it returns undef

=cut
sub dt_build_query {
    my ( $type, @params ) = @_;
    if ( $type =~ m/simple/ ) {
        return dt_build_query_simple(@params);
    }
    elsif ( $type =~ m/range_dates/ ) {
        return dt_build_query_dates(@params);
    }
    return;
}

1;
