package Koha::Auth::Challenge::Version;

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

use C4::Context;
use Koha;

use base qw(Koha::Auth::Challenge);

use Koha::Exception::VersionMismatch;
use Koha::Exception::BadSystemPreference;

=head challenge
STATIC

    Koha::Auth::Challenge::Version::challenge();

Checks if the DB version is valid.

@THROWS Koha::Exception::VersionMismatch, if versions do not match
@THROWS Koha::Exception::BadSystemPreference, if "Version"-syspref is not set.
                        This probably means that Koha has not been installed yet.
=cut

sub challenge {
    my $versionSyspref = C4::Context->preference('Version');
    unless ( $versionSyspref ) {
        Koha::Exception::BadSystemPreference->throw(error => "No Koha 'Version'-system preference defined. Koha needs to be installed.");
    }

    my $kohaversion = Koha::version();
    # remove the 3 last . to have a Perl number
    $kohaversion =~ s/(.*\..*)\.(.*)\.(.*)/$1$2$3/;
    if ( $versionSyspref < $kohaversion ) {
        Koha::Exception::VersionMismatch->throw(error => "Database update needed. Database is 'v$versionSyspref' and Koha is 'v$kohaversion'");
    }
}

1;
