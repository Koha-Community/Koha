# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 3;

use Test::Mojo;
use Data::Dumper;

use FindBin();
use IPC::Cmd qw(can_run);

my $t    = Test::Mojo->new('Koha::REST::V1');
my $spec = $t->get_ok( '/api/v1/', 'Correctly fetched the spec' )->tx->res->json;

my $paths = $spec->{paths};

my @missing_additionalProperties = ();

foreach my $route ( keys %{$paths} ) {
    foreach my $verb ( keys %{ $paths->{$route} } ) {

        # p($paths->{$route}->{$verb});

        # check parameters []
        foreach my $parameter ( @{ $paths->{$route}->{$verb}->{parameters} } ) {
            if (   exists $parameter->{schema}
                && exists $parameter->{schema}->{type}
                && ref( $parameter->{schema}->{type} ) ne 'ARRAY'
                && $parameter->{schema}->{type} eq 'object' ) {

                # it is an object type definition
                if ( $parameter->{name} ne 'query' # our query parameter is under-specified
                    and not exists $parameter->{schema}->{additionalProperties} ) {
                    push @missing_additionalProperties,
                      { type  => 'parameter',
                        route => $route,
                        verb  => $verb,
                        name  => $parameter->{name}
                      };
                }
            }
        }

        # check responses  {}
        my $responses = $paths->{$route}->{$verb}->{responses};
        foreach my $response ( keys %{$responses} ) {
            if (   exists $responses->{$response}->{schema}
                && exists $responses->{$response}->{schema}->{type}
                && ref( $responses->{$response}->{schema}->{type} ) ne 'ARRAY'
                && $responses->{$response}->{schema}->{type} eq 'object' ) {

                # it is an object type definition
                if ( not exists $responses->{$response}->{schema}->{additionalProperties} ) {
                    push @missing_additionalProperties,
                      { type  => 'response',
                        route => $route,
                        verb  => $verb,
                        name  => $response
                      };
                }
            }
        }
    }
}

is( scalar @missing_additionalProperties, 0 )
  or diag Dumper \@missing_additionalProperties;

subtest 'The spec passes the swagger-cli validation' => sub {

    plan tests => 1;

    SKIP: {
        skip "Skipping tests, swagger-cli missing", 1
          unless can_run('swagger-cli');

        my $spec_dir = "$FindBin::Bin/../api/v1/swagger";
        my $var      = qx{swagger-cli validate $spec_dir/swagger.yaml 2>&1};
        is( $?, 0, 'Validation exit code is 0' )
          or diag $var;
    }
};
