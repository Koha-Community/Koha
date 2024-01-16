package Koha::REST::V1::Acquisitions::Vendor::Edifact::Files;

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

use Koha::Edifact::Files;

use Try::Tiny qw( catch try );

=head1 NAME

Koha::REST::V1::Acquisitions::Edifact::Files

=head1 API

=head2 Class methods

=head3 list

Controller function that handles EDIFACT files

=cut

=head3 list

Return the list of EDIFACT files

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    my $filter = { deleted => 0 };
    return try {

        my $files_rs = Koha::Edifact::Files->search($filter);
        my $files    = $c->objects->search($files_rs);

        return $c->render(
            status  => 200,
            openapi => $files,
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
