package t::CataloguingCenter::z3950Params;
#
# Copyright 2016 KohaSuomi
#
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

=head IN THIS FILE

We define object properties for our Z39.50 servers.

=cut

sub getCataloguingCenterZ3950params {
    return {
        'host' => 'testcluster.koha-suomi.fi',
        'port' => '7654',
        'db' => 'biblios',
        'userid' => 'testis',
        'password' => 'tissit',
        'servername' => 'CATALOGUING_CENTER',
        'checked' => 1,
        'rank' => 0,
        'syntax' => 'USMARC',
        'encoding' => 'utf8',
        'timeout' => 0,
        'recordtype' => 'biblio',
    };
}

1;
