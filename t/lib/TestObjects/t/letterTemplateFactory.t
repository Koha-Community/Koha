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

use t::lib::TestObjects::LetterTemplateFactory;
use Koha::LetterTemplates;

my $testContext = {}; #Gather all created Objects here so we can finally remove them all.
my $now = DateTime->now(time_zone => C4::Context->tz());
my $year = $now->year();

my $subtestContext = {};
##Create and Delete using dependencies in the $testContext instantiated in previous subtests.
my $f = t::lib::TestObjects::LetterTemplateFactory->new();
my $hashLT = {letter_id => 'circulation-ODUE1-CPL-print',
            module => 'circulation',
            code => 'ODUE1',
            branchcode => 'CPL',
            name => 'Notice1',
            is_html => undef,
            title => 'Notice1',
            message_transport_type => 'print',
            content => '<item>Barcode: <<items.barcode>>, bring it back!</item>',
        };
my $objects = $f->createTestGroup([
                $hashLT,
                ], undef, $subtestContext);

my $letterTemplate = Koha::LetterTemplates->find($hashLT);
is($objects->{'circulation-ODUE1-CPL-print'}->name, $letterTemplate->name, "LetterTemplate 'circulation-ODUE1-CPL-print'");

#Delete them
t::lib::TestObjects::ObjectFactory->tearDownTestContext($subtestContext);
$letterTemplate = Koha::LetterTemplates->find($hashLT);
ok(not(defined($letterTemplate)), "LetterTemplate 'circulation-ODUE1-CPL-print' deleted");

done_testing();
