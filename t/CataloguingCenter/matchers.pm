package t::CataloguingCenter::matchers;
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

use t::lib::TestObjects::MatcherFactory;

=head IN THIS FILE

Here we create some matchers to play with

=cut

sub create {
    my ($testContext) = @_;

    my $matchers = t::lib::TestObjects::MatcherFactory->createTestGroup([
                    {
                        code => 'MERGER', #Preserves old 020 and copies 049c to 521a
                        description => 'I merge records before MARC modification templates',
                        threshold => 1000,
                        matchpoints => [
                           {
                              index       => '',
                              score       => 0,
                              components => [{
                                   tag         => '020',
                                   subfields   => '',
                                   offset      => 0,
                                   length      => 0,
                                   norms       => ['preserve'],
                              }]
                           },
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
                    {
                        code => 'COM_PART', #Matches 001 to Control-number and makes sure 003's match
                        description => 'I match component part records',
                        threshold => 1000,
                        matchpoints => [
                           {
                              index       => 'Control-number',
                              score       => 1000,
                              components => [{
                                   tag         => '001',
                                   subfields   => '',
                                   offset      => 0,
                                   length      => 0,
                                   norms       => [''],
                              }]
                           },
                        ],
                        required_checks => [{
                            source => [{
                                tag         => '003',
                                subfields   => '',
                                offset      => 0,
                                length      => 0,
                                norms       => [''],
                            }],
                            target => [{
                                tag         => '003',
                                subfields   => '',
                                offset      => 0,
                                length      => 0,
                                norms       => [''],
                            }],
                        }],
                    },
                    {} #One with defauĺts
                ], undef, $testContext);

    return $matchers;
} #EO prepareContext()

1;
