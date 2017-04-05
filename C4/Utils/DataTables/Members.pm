package C4::Utils::DataTables::Members;

use Modern::Perl;
use C4::Context;
use C4::Utils::DataTables;
use Koha::DateUtils;
use C4::Members::Attributes qw(SearchIdMatchingAttribute );

sub search {
    my ( $params ) = @_;
    my $searchmember = $params->{searchmember};
    my $firstletter = $params->{firstletter};
    my $categorycode = $params->{categorycode};
    my $branchcode = $params->{branchcode};
    my $searchtype = $params->{searchtype} || 'contain';
    my $searchfieldstype = $params->{searchfieldstype} || 'standard';
    my $dt_params = $params->{dt_params};

    unless ( $searchmember ) {
        $searchmember = $dt_params->{sSearch} // '';
    }

    # If branches are independent and user is not superlibrarian
    # The search has to be only on the user branch
    my $userenv = C4::Context->userenv;
    my @restricted_branchcodes;
    if (C4::Context::only_my_library) {
        push @restricted_branchcodes, $userenv->{branch};
    }
    else {
        my $logged_in_user = Koha::Patrons->find( $userenv->{number} );
        unless (
            $logged_in_user->can(
                { borrowers => 'view_borrower_infos_from_any_libraries' }
            )
          )
        {
            if ( my $library_groups = $logged_in_user->library->library_groups )
            {
                while ( my $library_group = $library_groups->next ) {
                    push @restricted_branchcodes,
                      $library_group->parent->children->get_column('branchcode');
                }
            }
            else {
                push @restricted_branchcodes, $userenv->{branch};
            }
        }
    }

    my ($sth, $query, $iTotalQuery, $iTotalRecords, $iTotalDisplayRecords);
    my $dbh = C4::Context->dbh;
    # Get the iTotalRecords DataTable variable
    $query = $iTotalQuery = "SELECT COUNT(borrowers.borrowernumber) FROM borrowers";
    if ( @restricted_branchcodes ) {
        $iTotalQuery .= " WHERE borrowers.branchcode IN (" . join( ',', ('?') x @restricted_branchcodes ) . ")";
    }
    ($iTotalRecords) = $dbh->selectrow_array( $iTotalQuery, undef, @restricted_branchcodes );

    # Do that after iTotalQuery!
    if ( defined $branchcode and $branchcode ) {
        @restricted_branchcodes = @restricted_branchcodes
            ? grep { /^$branchcode$/ } @restricted_branchcodes
                ? ($branchcode)
                : (undef) # Do not return any results
            : ($branchcode);
    }

    if ( $searchfieldstype eq 'dateofbirth' ) {
        # Return an empty list if the date of birth is not correctly formatted
        $searchmember = eval { output_pref( { str => $searchmember, dateformat => 'iso', dateonly => 1 } ); };
        if ( $@ or not $searchmember ) {
            return {
                iTotalRecords        => $iTotalRecords,
                iTotalDisplayRecords => 0,
                patrons              => [],
            };
        }
    }

    my $select = "SELECT
        borrowers.borrowernumber, borrowers.surname, borrowers.firstname,
        borrowers.streetnumber, borrowers.streettype, borrowers.address,
        borrowers.address2, borrowers.city, borrowers.state, borrowers.zipcode,
        borrowers.country, cardnumber, borrowers.dateexpiry,
        borrowers.borrowernotes, borrowers.branchcode, borrowers.email,
        borrowers.userid, borrowers.dateofbirth, borrowers.categorycode,
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
    if(@restricted_branchcodes ) {
        push @where_strs, "borrowers.branchcode IN (" . join( ',', ('?') x @restricted_branchcodes ) . ")";
        push @where_args, @restricted_branchcodes;
    }

    my $searchfields = {
        standard => C4::Context->preference('DefaultPatronSearchFields') || 'surname,firstname,othernames,cardnumber,userid',
        surname => 'surname',
        email => 'email,emailpro,B_email',
        borrowernumber => 'borrowernumber',
        userid => 'userid',
        phone => 'phone,phonepro,B_phone,altcontactphone,mobile',
        address => 'streettype,address,address2,city,state,zipcode,country',
        dateofbirth => 'dateofbirth',
        sort1 => 'sort1',
        sort2 => 'sort2',
    };

    # * is replaced with % for sql
    $searchmember =~ s/\*/%/g;

    # split into search terms
    my @terms;
    # consider coma as space
    $searchmember =~ s/,/ /g;
    if ( $searchtype eq 'contain' ) {
       @terms = split / /, $searchmember;
    } else {
       @terms = ($searchmember);
    }

    foreach my $term (@terms) {
        next unless $term;

        my $term_dt = eval { local $SIG{__WARN__} = {}; output_pref( { str => $term, dateonly => 1, dateformat => 'sql' } ); };

        if ($term_dt) {
            $term = $term_dt;
        } else {
            $term .= '%'    # end with anything
              if $term !~ /%$/;
            $term = "%$term"    # begin with anythin unless start_with
              if $searchtype eq 'contain' && $term !~ /^%/;
        }

        my @where_strs_or;
        for my $searchfield ( split /,/, $searchfields->{$searchfieldstype} ) {
            push @where_strs_or, "borrowers." . $dbh->quote_identifier($searchfield) . " LIKE ?";
            push @where_args, $term;
        }

        if ( $searchfieldstype eq 'standard' and C4::Context->preference('ExtendedPatronAttributes') and $searchmember ) {
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
    if ( !$dt_params->{iDisplayLength} || $dt_params->{iDisplayLength} > -1 ) {
        # In order to avoid sql injection
        $dt_params->{iDisplayStart} =~ s/\D//g if defined($dt_params->{iDisplayStart});
        $dt_params->{iDisplayLength} =~ s/\D//g if defined($dt_params->{iDisplayLength});
        $dt_params->{iDisplayStart} //= 0;
        $dt_params->{iDisplayLength} //= 20;
        $limit = "LIMIT $dt_params->{iDisplayStart},$dt_params->{iDisplayLength}";
    }

    $query = join(
        " ",
        ($select ? $select : ""),
        ($from ? $from : ""),
        ($where ? $where : ""),
        ($orderby ? $orderby : ""),
        ($limit ? $limit : "")
    );
    $sth = $dbh->prepare($query);
    $sth->execute(@where_args);
    my $patrons = $sth->fetchall_arrayref({});

    # Get the iTotalDisplayRecords DataTable variable
    $query = "SELECT COUNT(borrowers.borrowernumber) " . $from . ($where ? $where : "");
    $sth = $dbh->prepare($query);
    $sth->execute(@where_args);
    ($iTotalDisplayRecords) = $sth->fetchrow_array;

    # Get some information on patrons
    foreach my $patron (@$patrons) {
        my $patron_object = Koha::Patrons->find( $patron->{borrowernumber} );
        $patron->{overdues} = $patron_object->get_overdues->count;
        $patron->{issues} = $patron_object->checkouts->count;
        my $balance = $patron_object->account->balance;
        # FIXME Should be formatted from the template
        $patron->{fines} = sprintf("%.2f", $balance);

        if($patron->{dateexpiry} and $patron->{dateexpiry} ne '0000-00-00') {
            $patron->{dateexpiry} = output_pref( { dt => dt_from_string( $patron->{dateexpiry}, 'iso'), dateonly => 1} );
        } else {
            $patron->{dateexpiry} = '';
        }
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

  Can be 'start_with' or 'contain' (default value). Used for the searchmember parameter.

=item searchfieldstype

  Can be 'standard' (default value), 'email', 'borrowernumber', 'phone', 'address' or 'dateofbirth', 'sort1', 'sort2'

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
