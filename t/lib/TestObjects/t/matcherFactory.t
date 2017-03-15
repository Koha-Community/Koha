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

use t::lib::TestObjects::MatcherFactory;
use Koha::AtomicUpdater;

my ($matchers, $matcher, $mp1, $mp2, $reqCheck);
my $subtestContext = {};
##Create and Delete using dependencies in the $testContext instantiated in previous subtests.
$matchers = t::lib::TestObjects::MatcherFactory->createTestGroup([
                    {
                        code => 'MATCHLORD',
                        description => 'I am lord',
                        threshold => 1001,
                        matchpoints => [
                           {
                              index       => 'title',
                              score       => 500,
                              components => [{
                                   tag         => '130',
                                   subfields   => 'a',
                                   offset      => 0,
                                   length      => 0,
                                   norms       => ['hello'],
                              }]
                           },
                           {
                              index       => 'isbn',
                              score       => 500,
                              components => [{
                                   tag         => '020',
                                   subfields   => 'a',
                                   offset      => 0,
                                   length      => 0,
                                   norms       => ['isbn'],
                              }]
                           }
                        ],
                        required_checks => [{
                            source => [{
                                tag         => '049',
                                subfields   => 'c',
                                offset      => 0,
                                length      => 0,
                                norms       => ['copy'],
                            }],
                            target => [{
                                tag         => '521',
                                subfields   => 'a',
                                offset      => 0,
                                length      => 0,
                                norms       => ['paste'],
                            }],
                        }],
                    },
                    {} #One with defauĺts
                ], undef, $subtestContext);
#################
## MATCHERLORD ##
is($matchers->{MATCHLORD}->code,
   'MATCHLORD',
   'MATCHLORD');
is($matchers->{MATCHLORD}->threshold,
   1001,
   'threshold 1001');
$mp1 = $matchers->{MATCHLORD}->{matchpoints}->[0];
is($mp1->{components}->[0]->{tag},
   '130',
   'matchpoint 130');
is($mp1->{components}->[0]->{norms}->[0],
   'hello',
   'matchpoint hello');
$mp2 = $matchers->{MATCHLORD}->{matchpoints}->[1];
is($mp2->{components}->[0]->{tag},
   '020',
   'matchpoint 020');
is($mp2->{components}->[0]->{norms}->[0],
   'isbn',
   'matchpoint isbn');
$reqCheck = $matchers->{MATCHLORD}->{'required_checks'}->[0];
is($reqCheck->{source_matchpoint}->{components}->[0]->{tag},
   '049',
   'required checks source matchpoint tag 049');
is($reqCheck->{target_matchpoint}->{components}->[0]->{tag},
   '521',
   'required checks target matchpoint tag 521');


#############
## MATCHER ##
is($matchers->{MATCHER}->code,
   'MATCHER',
   'MATCHER');
is($matchers->{MATCHER}->threshold,
   1000,
   'threshold 1000');
$mp1 = $matchers->{MATCHER}->{matchpoints}->[0];
is($mp1->{components}->[0]->{tag},
   '245',
   'matchpoint 245');
is($mp1->{components}->[0]->{offset},
   '0',
   'matchpoint 0');
$mp2 = $matchers->{MATCHER}->{matchpoints}->[1];
is($mp2->{components}->[0]->{tag},
   '100',
   'matchpoint 020');
is($mp2->{components}->[0]->{norms}->[0],
   '',
   'matchpoint ""');
$reqCheck = $matchers->{MATCHER}->{'required_checks'}->[0];
is($reqCheck->{source_matchpoint}->{components}->[0]->{tag},
   '020',
   'required checks source matchpoint tag 020');
is($reqCheck->{target_matchpoint}->{components}->[0]->{tag},
   '024',
   'required checks target matchpoint tag 024');


t::lib::TestObjects::ObjectFactory->tearDownTestContext($subtestContext);

$matcher = C4::Matcher->fetch( $matchers->{MATCHER}->{id} );
ok(not($matcher), "Matcher MATCHER deleted");
$matcher = C4::Matcher->fetch( $matchers->{MATCHLORD}->{id} );
ok(not($matcher), "Matcher MATCHLORD deleted");

done_testing();
