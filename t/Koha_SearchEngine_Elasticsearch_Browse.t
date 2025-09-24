#!/usr/bin/perl

# Copyright 2015 Catalyst IT
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 4;

use_ok('Koha::SearchEngine::Elasticsearch::Browse');

# testing browse itself not implemented as it'll require a running ES
can_ok(
    'Koha::SearchEngine::Elasticsearch::Browse',
    qw/ _build_query browse /
);

subtest "_build_query tests" => sub {
    plan tests => 2;

    my $browse = Koha::SearchEngine::Elasticsearch::Browse->new( { index => 'dummy' } );
    my $q      = $browse->_build_query( 'foo', 'title' );
    is_deeply(
        $q,
        {
            size    => 1,
            suggest => {
                suggestions => {
                    text       => 'foo',
                    completion => {
                        field => 'title__suggestion',
                        size  => 500,
                        fuzzy => {
                            fuzziness => 1,
                        }
                    }
                }
            }
        },
        'No fuzziness or size specified'
    );

    # Note that a fuzziness of 4 will get reduced to 2.
    $q = $browse->_build_query( 'foo', 'title', { fuzziness => 4, count => 400 } );
    is_deeply(
        $q,
        {
            size    => 1,
            suggest => {
                suggestions => {
                    text       => 'foo',
                    completion => {
                        field => 'title__suggestion',
                        size  => 400,
                        fuzzy => {
                            fuzziness => 2,
                        }
                    }
                }
            }
        },
        'Fuzziness and size specified'
    );
};
