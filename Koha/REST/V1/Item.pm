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
use C4::Items qw( GetHiddenItemnumbers );

use Koha::Items;

sub get {
    my $c = shift->openapi->valid_input or return;

    my $itemnumber = $c->validation->param('itemnumber');
    my $item = Koha::Items->find($itemnumber);
    unless ($item) {
        return $c->render(status => 404, openapi => {error => "Item not found"});
    }

    # Hide non-public itemnotes if user has no staff access
    my $user = $c->stash('koha.user');
    unless ($user && haspermission($user->userid, {catalogue => 1})) {

        my @hiddenitems = C4::Items::GetHiddenItemnumbers( ({ itemnumber => $itemnumber}) );
        my %hiddenitems = map { $_ => 1 } @hiddenitems;

        # Pretend it was not found as it's hidden from OPAC to regular users
        return $c->render( status => 404, openapi => {error => "Item not found"} )
          if $hiddenitems{$itemnumber};

        $item->set({ itemnotes_nonpublic => undef });
    }

    return $c->render( status => 200, openapi => $item );
}

1;
