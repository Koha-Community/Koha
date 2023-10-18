package Koha::REST::V1::Preservation;

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

use Koha::Patrons;

use Try::Tiny qw( catch try );

=head1 NAME

Koha::REST::V1::Preservation

=head1 API

=head2 Class methods

=head3 config

Return the configuration options needed for the Preservation Vue app

=cut

sub config {
    my $c = shift->openapi->valid_input or return;

    my $patron = $c->stash('koha.user');

    return $c->render(
        status  => 200,
        openapi => {
            settings => {
                enabled                       => C4::Context->preference('PreservationModule'),
                not_for_loan_waiting_list_in  => C4::Context->preference('PreservationNotForLoanWaitingListIn'),
                not_for_loan_default_train_in => C4::Context->preference('PreservationNotForLoanDefaultTrainIn'),
            },
            permissions => {
                'manage_sysprefs' => $patron->has_permission( { parameters => 'manage_sysprefs' } ) ? 1 : 0,
            },
        },
    );
}

1;
