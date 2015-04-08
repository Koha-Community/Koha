package Koha::Template::Plugin::ItemTypes;

# Copyright ByWater Solutions 2012

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

use Template::Plugin;
use base qw( Template::Plugin );
use Encode qw{encode decode};

use C4::Koha;

sub GetDescription {
    my ( $self, $itemtype ) = @_;

    my $query = "SELECT description FROM itemtypes WHERE itemtype = ?";
    my $sth   = C4::Context->dbh->prepare($query);
    $sth->execute($itemtype);
    my $d = $sth->fetchrow_hashref();
    return encode( 'UTF-8', $d->{'description'} );

}

1;
