package Koha::AuthorisedValues;

# Copyright ByWater Solutions 2014
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Carp;

use Koha::Database;

use Koha::Borrower;

use base qw(Koha::Objects);

=head1 NAME

Koha::Borrower - Koha Borrower Object class

=head1 API

=head2 Class Methods

=cut

=head3 Koha::AuthorisedValues->search();

my @objects = Koha::AuthorisedValues->search($params);

=cut

sub search {
    my ( $self, $params ) = @_;

    carp("No branchcode passed in for authorised values search!")
      unless $params->{branchcode};

    my $branchcode = $params->{branchcode};
    delete( $params->{branchcode} );

    my $rs = $self->_resultset()->search(
        {
            %$params,
            -or => [
                'authorised_values_branches.branchcode' => undef,
                'authorised_values_branches.branchcode' => $branchcode,
            ],
        },
        { join => 'authorised_values_branches' }
    );

    my $class = ref($self);
    return wantarray ? $self->_wrap( $rs->all() ) : $class->new_from_dbic($rs);
}

=head3 type

=cut

sub type {
    return 'AuthorisedValue';
}

sub object_class {
    return 'Koha::AuthorisedValue';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
