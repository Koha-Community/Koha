package C4::Utils::DataTables::VirtualShelves;

use Modern::Perl;
use C4::Context;
use C4::Utils::DataTables;
use Koha::Virtualshelves;

sub search {
    my ( $params ) = @_;
    my $shelfname = $params->{shelfname};
    my $count = $params->{count};
    my $owner = $params->{owner};
    my $sortby = $params->{sortby};
    my $type = $params->{type};
    my $dt_params = $params->{dt_params};

    # public is default
    $type = 2 if not $type or $type != 1;

    # If not logged in user, be carreful and set the borrowernumber to 0
    # to prevent private lists lack
    my $loggedinuser = C4::Context->userenv->{'number'} || 0;

    my ($iTotalRecords, $iTotalDisplayRecords);

    my $dbh = C4::Context->dbh;

    # FIXME refactore the following queries
    # We should call Koha::Virtualshelves
    my $select = q|
        SELECT vs.shelfnumber, vs.shelfname, vs.owner, vs.category AS type,
        vs.created_on, vs.lastmodified as modification_time,
        bo.surname, bo.firstname, vs.sortfield as sortby,
        count(vc.biblionumber) as count
    |;

    my $from_total = q|
        FROM virtualshelves vs
        LEFT JOIN borrowers bo ON vs.owner=bo.borrowernumber
    |;

    my $from = $from_total . q|
        LEFT JOIN virtualshelfcontents vc USING( shelfnumber )
    |;

    my @args;
    # private
    if ( $type == 1 ) {
        my $join_vs .= q|
            LEFT JOIN virtualshelfshares sh ON sh.shelfnumber = vs.shelfnumber
            AND sh.borrowernumber = ?
        |;
        $from .= $join_vs;
        $from_total .= $join_vs;
        push @args, $loggedinuser;

    }

    my @where_strs;

    if ( defined $shelfname and $shelfname ne '' ) {
        push @where_strs, 'shelfname LIKE ?';
        push @args, "%$shelfname%";
    }
    if ( defined $owner and $owner ne '' ) {
        push @where_strs, '( bo.firstname LIKE ? OR bo.surname LIKE ? )';
        push @args, "%$owner%", "%$owner%";
    }
    if ( defined $sortby and $sortby ne '' ) {
        push @where_strs, 'sortfield = ?';
        push @args, $sortby;
    }

    push @where_strs, 'category = ?';
    push @args, $type;

    if ( $type == 1 ) {
        push @where_strs, '(vs.owner = ? OR sh.borrowernumber = ?)';
        push @args, $loggedinuser, $loggedinuser;
    }

    my $where;
    $where = " WHERE " . join (" AND ", @where_strs) if @where_strs;
    my $orderby = dt_build_orderby($dt_params);
    $orderby =~ s|shelfnumber|vs.shelfnumber| if $orderby;

    my $limit;
    # If iDisplayLength == -1, we want to display all shelves
    if ( $dt_params->{iDisplayLength} > -1 ) {
        # In order to avoid sql injection
        $dt_params->{iDisplayStart} =~ s/\D//g;
        $dt_params->{iDisplayLength} =~ s/\D//g;
        $dt_params->{iDisplayStart} //= 0;
        $dt_params->{iDisplayLength} //= 20;
        $limit = "LIMIT $dt_params->{iDisplayStart},$dt_params->{iDisplayLength}";
    }

    my $group_by = " GROUP BY vs.shelfnumber, vs.shelfname, vs.owner, vs.category,
        vs.created_on, vs.lastmodified, bo.surname, bo.firstname, vs.sortfield ";

    my $query = join(
        " ",
        $select,
        $from,
        ($where ? $where : ""),
        $group_by,
        ($orderby ? $orderby : ""),
        ($limit ? $limit : "")
    );
    my $shelves = $dbh->selectall_arrayref( $query, { Slice => {} }, @args );

    # Get the iTotalDisplayRecords DataTable variable
    $query = "SELECT COUNT(vs.shelfnumber) " . $from_total . ($where ? $where : "");
    ($iTotalDisplayRecords) = $dbh->selectrow_array( $query, undef, @args );

    # Get the iTotalRecords DataTable variable
    $query = q|SELECT COUNT(vs.shelfnumber)| . $from_total . q| WHERE category = ?|;
    $query .= q| AND (vs.owner = ? OR sh.borrowernumber = ?)| if $type == 1;
    @args = $type == 1 ? ( $loggedinuser, $type, $loggedinuser, $loggedinuser ) : ( $type );
    ( $iTotalRecords ) = $dbh->selectrow_array( $query, undef, @args );

    for my $shelf ( @$shelves ) {
        my $s = Koha::Virtualshelves->find( $shelf->{shelfnumber} );
        $shelf->{can_manage_shelf} = $s->can_be_managed( $loggedinuser );
        $shelf->{can_delete_shelf} = $s->can_be_deleted( $loggedinuser );
        $shelf->{is_shared} = $s->is_shared;
    }
    return {
        iTotalRecords => $iTotalRecords,
        iTotalDisplayRecords => $iTotalDisplayRecords,
        shelves => $shelves,
    }
}

1;
__END__

=head1 NAME

C4::Utils::DataTables::VirtualShelves - module for using DataTables with virtual shelves

=head1 SYNOPSIS

This module provides routines used by the virtual shelves search

=head2 FUNCTIONS

=head3 search

    my $dt_infos = C4::Utils::DataTables::VirtualShelves->search($params);

$params is a hashref with some keys:

=over 4

=item shelfname

=item count

=item sortby

=item type

=item dt_params

=cut

=back

=head1 LICENSE

This file is part of Koha.

Copyright 2014 BibLibre

Koha is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

Koha is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Koha; if not, see <http://www.gnu.org/licenses>.
