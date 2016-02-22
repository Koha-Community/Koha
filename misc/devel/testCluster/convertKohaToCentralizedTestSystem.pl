#!/usr/bin/perl
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

use C4::Context;
use C4::Search;
use misc::devel::testCluster::testContexts::batchOverlayContext;

=head IN THIS FILE

Here we convert this Koha-installation to a centralized test server.

=cut

print "\nExposing the public Z39.50-server\n";
my $conf = C4::Context->new();
unless ($conf->{listen}->{publicserver} && $conf->{serverinfo}->{publicserver} && $conf->{server}->{publicserver}) {
    print "\nZebra is not configured to act as a public Z39.50 server. You must enable it for remote system tests to work.\n";
    print "\nThis is most easily done by undocumenting the <server id=\"publicserver\"  listenref=\"publicserver\"> -stanza and restarting Zebra";
    print "See Koha-manuals for more info on how to enable the public Z39.50-server";
    exit 1;
}

misc::devel::testCluster::testContexts::batchOverlayContext::prepareContext();

print "\nReindexing the search index\n";
my $output = C4::Search::reindexZebraChanges();

print $output;