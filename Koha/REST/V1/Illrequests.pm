package Koha::REST::V1::Illrequests;

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

use C4::Context;
use Koha::Illrequests;
use Koha::Illrequestattributes;
use Koha::Libraries;
use Koha::Patrons;
use Koha::Libraries;
use Koha::DateUtils qw( format_sqldatetime );

=head1 NAME

Koha::REST::V1::Illrequests

=head2 Operations

=head3 list

Controller function that handles listing Koha::Illrequest objects

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {

        my $reqs = $c->objects->search(Koha::Illrequests->new->filter_by_visible);

        return $c->render(
            status  => 200,
            openapi => $reqs,
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
