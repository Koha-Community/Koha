package Koha::Template::Plugin::AudioAlerts;

# Copyright ByWater Solutions 2013

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

use Encode qw( encode );
use JSON;

use base qw( Template::Plugin );

use C4::Context;
use Koha;

sub AudioAlerts {
    my $dbh = C4::Context->dbh;
    my $audio_alerts = $dbh->selectall_arrayref( 'SELECT * FROM audio_alerts ORDER BY precedence', { Slice => {} } );
    return encode_json($audio_alerts);
}

1;
