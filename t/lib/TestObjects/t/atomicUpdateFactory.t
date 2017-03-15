#!/usr/bin/perl

# Copyright KohaSuomi 2016
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
#

use Modern::Perl;
use Test::More;

use t::lib::TestObjects::AtomicUpdateFactory;
use Koha::AtomicUpdater;

my ($atomicUpdater, $atomicupdate);
my $subtestContext = {};
##Create and Delete using dependencies in the $testContext instantiated in previous subtests.
my $atomicupdates = t::lib::TestObjects::AtomicUpdateFactory->createTestGroup([
                        {
                         'filename' => 'Bug-10-RavingRabbitsMayhem.pl',
                         'modification_time' => '2015-01-02 15:59:32',},
                        {
                         'filename' => 'Bug-11-RancidSausages.perl',
                         'modification_time' => '2015-01-02 15:59:33',},
                        ],
                        undef, $subtestContext);
$atomicUpdater = Koha::AtomicUpdater->new();
$atomicupdate = $atomicUpdater->find($atomicupdates->{'Bug-10'}->issue_id);
is($atomicupdate->issue_id,
   'Bug-10',
   "Bug-10-RavingRabbitsMayhem created");
$atomicupdate = $atomicUpdater->find($atomicupdates->{'Bug-11'}->issue_id);
is($atomicupdate->issue_id,
   'Bug-11',
   "Bug-11-RancidSausages created");

t::lib::TestObjects::ObjectFactory->tearDownTestContext($subtestContext);

$atomicupdate = $atomicUpdater->find($atomicupdates->{'Bug-10'}->issue_id);
ok(not($atomicupdate),
   "Bug-10-RavingRabbitsMayhem deleted");
$atomicupdate = $atomicUpdater->find($atomicupdates->{'Bug-11'}->issue_id);
ok(not($atomicupdate),
   "Bug-11-RancidSausages created");

done_testing();
