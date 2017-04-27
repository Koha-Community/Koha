#!/usr/bin/perl

# Copyright Koha-Suomi Oy 2017
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

use Koha::Auth::PermissionManager;
my $pm = Koha::Auth::PermissionManager->new();
$pm->addPermissionModule({module => 'messages', description => 'Permission regarding notifications and messages in message queue.'});
$pm->addPermission({module => 'messages', code => 'get_message', description => "Allows to get the messages in message queue."});
$pm->addPermission({module => 'messages', code => 'create_message', description => "Allows to create a new message and queue it."});
$pm->addPermission({module => 'messages', code => 'update_message', description => "Allows to update messages in message queue."});
$pm->addPermission({module => 'messages', code => 'delete_message', description => "Allows to delete a message and queue it."});
$pm->addPermission({module => 'messages', code => 'resend_message', description => "Allows to resend messages in message queue."});

print "Upgrade done (Bug 14843: Add Pemissions for message queue REST operations)\n";
