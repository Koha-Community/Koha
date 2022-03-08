package Koha::REST::V1::Acquisitions::Funds;

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

use Mojo::Base 'Mojolicious::Controller';

use Koha::Acquisition::Funds;

use Try::Tiny qw( catch try );

=head1 NAME

Koha::REST::V1::Acquisitions::Funds

=head1 API

=head2 Class methods

=head3 list

Controller function that handles listing Funds

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {

        my $funds_rs = Koha::Acquisition::Funds->new;
        my $funds = $c->objects->search( $funds_rs );

        return $c->render(
            status  => 200,
            openapi => $funds
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 list_owners

Return the list of possible funds' owners

=cut

sub list_owners {
    my $c = shift->openapi->valid_input or return;

    return try {

        my $patrons_rs = Koha::Patrons->search->filter_by_have_permission('acquisition.budget_modify');
        my $patrons    = $c->objects->search( $patrons_rs );

        return $c->render(
            status  => 200,
            openapi => $patrons
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 list_users

Return the list of possible funds' users

=cut

sub list_users {
    my $c = shift->openapi->valid_input or return;

    return try {

        my $patrons_rs = Koha::Patrons->search->filter_by_have_permission('acquisition.budget_modify');
        my $patrons    = $c->objects->search( $patrons_rs );

        return $c->render(
            status  => 200,
            openapi => $patrons
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

1;
