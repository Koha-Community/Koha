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

use vars qw(@ISA @EXPORT);

BEGIN {

    @ISA        = qw(Exporter);
    @EXPORT     = qw(dt_build_orderby dt_get_params);
}

=head1 NAME

! DEPRECATED - This module is deprecated, the REST API route and REST API Datatables wrapper must be used instead!

C4::Utils::DataTables - Utility subs for building query when DataTables source is AJAX

=head1 SYNOPSYS

    use CGI qw ( -utf8 );
    use C4::Context;
    use C4::Utils::DataTables;

    my $input = new CGI;
    my $vars = $input->Vars;

    my $query = qq{
        SELECT surname, firstname
        FROM borrowers
        WHERE borrowernumber = ?
    };
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

    return unless @orderbys;

    # Must be "branches.branchname asc", "borrowers.firstname desc", etc.
    @orderbys = grep { /^\w+\.\w+\s(asc|desc)$/ } @orderbys;

    $orderby = " ORDER BY " . join(',', @orderbys) . " " if @orderbys;
    return $orderby;
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

1;
