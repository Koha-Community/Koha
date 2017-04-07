package Koha::Reviews;

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

use Koha::Review;

use base qw(Koha::Objects);

=head1 NAME

Koha::Reviews - Koha Review Object set class

=head1 API

=head2 Class Methods

=cut

=head2 search_limited

my $reviews = Koha::Reviews->search_limited( $params, $attributes );

Search for reviews according to logged in patron restrictions

=cut

sub search_limited {
    my ( $self, $params, $attributes ) = @_;

    my $userenv = C4::Context->userenv;
    my @restricted_branchcodes;
    if ( $userenv ) {
        my $logged_in_user = Koha::Patrons->find( $userenv->{number} );
        @restricted_branchcodes = $logged_in_user->libraries_where_can_see_patrons;
    }
    # TODO This 'borrowernumber' relation name is confusing and needs to be renamed
    $params->{'borrowernumber.branchcode'} = { -in => \@restricted_branchcodes } if @restricted_branchcodes;
    $attributes->{join} = 'borrowernumber';
    return $self->search( $params, $attributes );
}

=head3 type

=cut

sub _type {
    return 'Review';
}

sub object_class {
    return 'Koha::Review';
}

1;
