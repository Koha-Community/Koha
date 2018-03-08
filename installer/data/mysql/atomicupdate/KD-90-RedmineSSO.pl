#!/usr/bin/perl

# Copyright Open Source Freedom Fighters
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

use C4::Context;
use Koha::AtomicUpdater;

my $dbh = C4::Context->dbh();
my $atomicUpdater = Koha::AtomicUpdater->new();

if(!$atomicUpdater->find('#90') && !$atomicUpdater->find('KD90')) {

    use Koha::Auth::PermissionManager;
    my $pm = Koha::Auth::PermissionManager->new();
    $pm->addPermissionModule({module => 'auth', description => 'Permission regarding authentications and allowing to authenticate other users.'});
    $pm->addPermission({module => 'auth', code => 'get_session', description => "Allow querying if the given session is active, and get very basic user details for the session; email, lastname, firstname"});

    print "Upgrade done (KD-90: Redmine SSO)\n";
}
