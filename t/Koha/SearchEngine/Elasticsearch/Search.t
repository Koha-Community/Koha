#!/usr/bin/perl
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

use Test::More tests => 2;
use Test::MockModule;
use t::lib::Mocks;

use_ok('Koha::SearchEngine::Elasticsearch::Search');

subtest 'search_auth_compat' => sub {
    plan tests => 4;

    t::lib::Mocks::mock_preference( 'QueryRegexEscapeOptions', 'dont_escape' );

    my $search;
    ok(
        $search = Koha::SearchEngine::Elasticsearch::Search->new(
            { index => $Koha::SearchEngine::Elasticsearch::AUTHORITIES_INDEX }
        ),
        'Creating a new Search object'
    );

    my $builder;
    ok(
        $builder =
            Koha::SearchEngine::QueryBuilder->new( { index => $Koha::SearchEngine::Elasticsearch::AUTHORITIES_INDEX } ),
        'Creating a new Builder object'
    );

    my $search_query = $builder->build_authorities_query_compat(
        ['mainmainentry'], ['and'], [''], ['contains'],
        ['Donald - Duck'], '',      'HeadingAsc'
    );

    my ( $bad_results, undef ) = $search->search_auth_compat( $search_query, 0, 20, undef );

    is( @$bad_results[0], undef, 'We expect no record because it doesnt exist' );

    my $module = Test::MockModule->new('Koha::SearchEngine::Elasticsearch::Search');
    $module->mock( 'count_auth_use', sub { return 1 } );
    $module->mock(
        'search',
        sub {
            # While the 001 and the authid should be the same, it is not always the case
            # The _id is always the authid and so should be our source of trutch
            my $marc_record = MARC::Record->new();
            $marc_record->append_fields(
                MARC::Field->new( '001', 'Wrong001Number' ),
            );
            return {
                hits => {
                    hits => [
                        {
                            '_id'     => 8675309,
                            '_source' => {
                                'local-number' => ['Wrong001Number'],
                                'marc_data'    => $marc_record,
                                'marc_format'  => 'base64ISO2709',
                            },
                        }
                    ]
                }
            };
        }
    );

    my ( $results, undef ) = $search->search_auth_compat('faked');

    is( @$results[0]->{authid}, '8675309', 'We get the expected record _id and not the 001' );

};

1;
