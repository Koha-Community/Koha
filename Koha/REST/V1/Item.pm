package Koha::REST::V1::Item;

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
use Mojo::JSON;

use C4::Auth qw( haspermission );

use Koha::Items;

sub get {
    my ($c, $args, $cb) = @_;

    my $itemnumber = $c->param('itemnumber');
    my $item = Koha::Items->find($itemnumber);
    unless ($item) {
        return $c->$cb({error => "Item not found"}, 404);
    }

    # Hide non-public itemnotes if user has no staff access
    my $user = $c->stash('koha.user');
    unless ($user && haspermission($user->userid, {catalogue => 1})) {
        $item->set({ itemnotes_nonpublic => undef });
    }

    return $c->$cb($item->unblessed, 200);
}

1;
