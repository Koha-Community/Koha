package C4::Utils::DataTables::Members;

use C4::Branch qw/onlymine/;
use C4::Context;
use C4::Members qw/GetMemberIssuesAndFines/;
use C4::Utils::DataTables;
use Modern::Perl;

sub search {
    my ( $params ) = @_;
    my $searchmember = $params->{searchmember};
    my $firstletter = $params->{firstletter};
    my $categorycode = $params->{categorycode};
    my $branchcode = $params->{branchcode};
    my $searchtype = $params->{searchtype};
    my $searchfieldstype = $params->{searchfieldstype};
    my $dt_params = $params->{dt_params};

    my ($iTotalRecords, $iTotalDisplayRecords);

    # If branches are independant and user is not superlibrarian
    # The search has to be only on the user branch
    if ( C4::Branch::onlymine ) {
        my $userenv = C4::Context->userenv;
        $branchcode = $userenv->{'branch'};

    }

    my $dbh = C4::Context->dbh;
    my $select = "SELECT
        borrowers.borrowernumber, borrowers.surname, borrowers.firstname,
        borrowers.streetnumber, borrowers.streettype, borrowers.address,
        borrowers.address2, borrowers.city, borrowers.state, borrowers.zipcode,
        borrowers.country, cardnumber, borrowers.dateexpiry, borrowers.dateofbirth,
        borrowers.borrowernotes, borrowers.branchcode, borrowers.email,
        borrowers.emailpro, borrowers.phone, borrowers.phonepro, borrowers.mobile,
        borrowers.altcontactphone, borrowers.B_phone, borrowers.B_email,
        categories.description AS category_description, categories.category_type,
        branches.branchname";
    my $from = "FROM borrowers
        LEFT JOIN branches ON borrowers.branchcode = branches.branchcode
        LEFT JOIN categories ON borrowers.categorycode = categories.categorycode";
    my @where_args;
    my @where_strs;
    if(defined $firstletter and $firstletter ne '') {
        push @where_strs, "borrowers.surname LIKE ?";
        push @where_args, "$firstletter%";
    }
    if(defined $categorycode and $categorycode ne '') {
        push @where_strs, "borrowers.categorycode = ?";
        push @where_args, $categorycode;
    }
    if(defined $branchcode and $branchcode ne '') {
        push @where_strs, "borrowers.branchcode = ?";
        push @where_args, $branchcode;
    }

    # split on coma
    $searchmember =~ s/,/ /g if $searchmember;
    my $searchfields = {
        standard => 'surname,firstname,othernames,cardnumber',
        email => 'email,emailpro,B_email',
        borrowernumber => 'borrowernumber',
        phone => 'phone,phonepro,B_phone,altcontactphone,mobile',
        address => 'streettype,address,address2,city,state,zipcode,country',
        dateofbirth => 'dateofbirth',
        sort1 => 'sort1',
        sort2 => 'sort2',
    };
    foreach my $term ( split / /, $searchmember) {
        next unless $term;
        $searchmember =~ s/\*/%/g; # * is replaced with % for sql
        $term .= '%' # end with anything
            if $term !~ /%$/;
        $term = "%$term" # begin with anythin unless start_with
            if $term !~ /^%/
                and $searchtype eq "contain";
        my @where_strs_or;
        for my $searchfield ( split /,/, $searchfields->{$searchfieldstype} ) {
            push @where_strs_or, "borrowers." . $dbh->quote_identifier($searchfield) . " LIKE ?";
            push @where_args, $term;
        }

        if ( C4::Context->preference('ExtendedPatronAttributes') and $searchmember ) {
            my $matching_borrowernumbers = C4::Members::Attributes::SearchIdMatchingAttribute($searchmember);

            for my $borrowernumber ( @$matching_borrowernumbers ) {
                push @where_strs_or, "borrowers.borrowernumber = ?";
                push @where_args, $borrowernumber;
            }
        }

        push @where_strs, '('. join (' OR ', @where_strs_or) . ')'
            if @where_strs_or;
    }

    my $where;
    $where = " WHERE " . join (" AND ", @where_strs) if @where_strs;
    my $orderby = dt_build_orderby($dt_params);

    my $limit;
    # If iDisplayLength == -1, we want to display all patrons
    if ( $dt_params->{iDisplayLength} > -1 ) {
        # In order to avoid sql injection
        $dt_params->{iDisplayStart} =~ s/\D//g;
        $dt_params->{iDisplayLength} =~ s/\D//g;
        $dt_params->{iDisplayStart} //= 0;
        $dt_params->{iDisplayLength} //= 20;
        $limit = "LIMIT $dt_params->{iDisplayStart},$dt_params->{iDisplayLength}";
    }

    my $query = join(
        " ",
        ($select ? $select : ""),
        ($from ? $from : ""),
        ($where ? $where : ""),
        ($orderby ? $orderby : ""),
        ($limit ? $limit : "")
    );
    my $sth = $dbh->prepare($query);
    $sth->execute(@where_args);
    my $patrons = $sth->fetchall_arrayref({});

    # Get the iTotalDisplayRecords DataTable variable
    $query = "SELECT COUNT(borrowers.borrowernumber) " . $from . ($where ? $where : "");
    $sth = $dbh->prepare($query);
    $sth->execute(@where_args);
    ($iTotalDisplayRecords) = $sth->fetchrow_array;

    # Get the iTotalRecords DataTable variable
    $query = "SELECT COUNT(borrowers.borrowernumber) FROM borrowers";
    $sth = $dbh->prepare($query);
    $sth->execute;
    ($iTotalRecords) = $sth->fetchrow_array;

    # Get some information on patrons
    foreach my $patron (@$patrons) {
        ($patron->{overdues}, $patron->{issues}, $patron->{fines}) =
            GetMemberIssuesAndFines($patron->{borrowernumber});
        if($patron->{dateexpiry} and $patron->{dateexpiry} ne '0000-00-00') {
            $patron->{dateexpiry} = C4::Dates->new($patron->{dateexpiry}, "iso")->output();
        } else {
            $patron->{dateexpiry} = '';
        }
        $patron->{fines} = sprintf("%.2f", $patron->{fines} || 0);
    }

    return {
        iTotalRecords => $iTotalRecords,
        iTotalDisplayRecords => $iTotalDisplayRecords,
        patrons => $patrons
    }
}

1;
__END__

=head1 NAME

C4::Utils::DataTables::Members - module for using DataTables with patrons

=head1 SYNOPSIS

This module provides (one for the moment) routines used by the patrons search

=head2 FUNCTIONS

=head3 search

    my $dt_infos = C4::Utils::DataTables::Members->search($params);

$params is a hashref with some keys:

=over 4

=item searchmember

  String to search in the borrowers sql table

=item firstletter

  Introduced to contain 1 letter but can contain more.
  The search will done on the borrowers.surname field

=item categorycode

  Search patrons with this categorycode

=item branchcode

  Search patrons with this branchcode

=item searchtype

  Can be 'contain' or 'start_with'. Used for the searchmember parameter.

=item searchfieldstype

  Can be 'standard', 'email', 'borrowernumber', 'phone', 'address' or 'dateofbirth', 'sort1', 'sort2'

=item dt_params

  Is the reference of C4::Utils::DataTables::dt_get_params($input);

=cut

=back

=head1 LICENSE

This file is part of Koha.

Copyright 2013 BibLibre

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
