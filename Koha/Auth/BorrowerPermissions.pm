package Koha::Auth::BorrowerPermissions;

# Copyright 2015 Vaara-kirjastot
#
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
use Scalar::Util qw(blessed);

use Koha::Auth::BorrowerPermission;

use base qw(Koha::Objects);

sub _type {
    return 'BorrowerPermission';
}
sub object_class {
    return 'Koha::Auth::BorrowerPermission';
}

sub _get_castable_unique_columns {
    return ['borrower_permission_id'];
}

1;
