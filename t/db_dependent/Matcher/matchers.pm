package t::db_dependent::Matcher::matchers;
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

a matcher which looks for 001 similarities and confirms that 003 is the same

=cut

sub create {
my ($testContext) = @_;

my $matchers = t::lib::TestObjects::MatcherFactory->createTestGroup([
                    {
                        code => '001',
                        description => 'I match control number and control number identifier',
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
                    }
                ], undef, $testContext);

return $matchers;
} #EO prepareContext()

1;
