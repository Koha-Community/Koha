package Koha::Patron::Modifications;

# Copyright 2012 ByWater Solutions
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

=head1 NAME

Koha::Patron::Modifications

=cut

use Modern::Perl;

use C4::Context;

use Koha::Patron::Attribute;
use Koha::Patron::Modification;

use JSON;

use base qw(Koha::Objects);

=head2 pending_count

$count = Koha::Patron::Modifications->pending_count();

Returns the number of pending modifications for existing patrons.

=cut

sub pending_count {
    my ( $self, $branchcode ) = @_;

    my $dbh   = C4::Context->dbh;
    my $query = "
        SELECT COUNT(*) AS count
        FROM borrower_modifications, borrowers
        WHERE borrower_modifications.borrowernumber > 0
        AND borrower_modifications.borrowernumber = borrowers.borrowernumber
    ";

    my $userenv = C4::Context->userenv;
    my @branchcodes;
    if ( $userenv and $userenv->{number} ) {
        my $logged_in_user = Koha::Patrons->find( $userenv->{number} );
        if ($branchcode) {
            return 0 unless $logged_in_user->can_see_patrons_from($branchcode);
            @branchcodes = ( $branchcode );
        }
        else {
            @branchcodes = $logged_in_user->libraries_where_can_see_patrons;
        }
    }
    my @sql_params;
    if ( @branchcodes ) {
        $query .= ' AND borrowers.branchcode IN ( ' . join( ',', ('?') x @branchcodes ) . ' )';
        push( @sql_params, @branchcodes );
    }

    my ( $count ) = $dbh->selectrow_array( $query, undef, @sql_params );
    return $count;
}

=head2 pending

$arrayref = Koha::Patron::Modifications->pending();

Returns an arrayref of hashrefs for all pending modifications for existing patrons.

=cut

sub pending {
    my ( $self, $branchcode ) = @_;

    my $dbh   = C4::Context->dbh;
    my $query = "
        SELECT borrower_modifications.*
        FROM borrower_modifications, borrowers
        WHERE borrower_modifications.borrowernumber > 0
        AND borrower_modifications.borrowernumber = borrowers.borrowernumber
    ";

    my $userenv = C4::Context->userenv;
    my @branchcodes;
    if ( $userenv ) {
        my $logged_in_user = Koha::Patrons->find( $userenv->{number} );
        if ($branchcode) {
            return 0 unless $logged_in_user->can_see_patrons_from($branchcode);
            @branchcodes = ( $branchcode );
        }
        else {
            @branchcodes = $logged_in_user->libraries_where_can_see_patrons;
        }
    }
    my @sql_params;
    if ( @branchcodes ) {
        $query .= ' AND borrowers.branchcode IN ( ' . join( ',', ('?') x @branchcodes ) . ' )';
        push( @sql_params, @branchcodes );
    }
    $query .= " ORDER BY borrowers.surname, borrowers.firstname";
    my $sth = $dbh->prepare($query);
    $sth->execute(@sql_params);

    my @m;
    while ( my $row = $sth->fetchrow_hashref() ) {
        foreach my $key ( keys %$row ) {
            if ( defined $row->{$key} && $key eq 'extended_attributes' ) {
                my $attributes = from_json( $row->{$key} );
                my @pending_attributes;
                foreach my $attr ( @{$attributes} ) {
                    push @pending_attributes,
                        Koha::Patron::Attribute->new(
                        {   borrowernumber => $row->{borrowernumber},
                            code           => $attr->{code},
                            attribute      => $attr->{value}
                        }
                        );
                }

                $row->{$key} = \@pending_attributes;
            }
            delete $row->{$key} unless defined $row->{$key};
        }

        push( @m, $row );
    }

    return \@m;
}

sub _type {
    return 'BorrowerModification';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::Patron::Modification';
}

1;
