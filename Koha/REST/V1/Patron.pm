package Koha::REST::V1::Patron;

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

use Mojo::Base 'Mojolicious::Controller';

use Koha::Patrons;

sub list {
    my $c = shift->openapi->valid_input or return;

    # FIXME The limited does not work here, the userenv is not set
    my $patrons = Koha::Patrons->search_limited;

    return $c->render(status => 200, openapi => $patrons);
}

sub get {
    my $c = shift->openapi->valid_input or return;

    my $borrowernumber = $c->validation->param('borrowernumber');
    my $patron = Koha::Patrons->find($borrowernumber);
    unless ($patron) {
        return $c->render(status => 404, openapi => { error => "Patron not found." });
    }

    return $c->render(status => 200, openapi => $patron);
}

1;
