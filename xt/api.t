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

use Test::More tests => 6;

use Test::Mojo;
use Data::Dumper;


use PPI;
use FindBin();
use IPC::Cmd        qw(can_run);
use List::MoreUtils qw(any);
use File::Slurp qw(read_file);

use Koha::Database;

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
                && $parameter->{schema}->{type} eq 'object' )
            {

                # it is an object type definition
                if (
                    $parameter->{name} ne 'query'    # our query parameter is under-specified
                    and not exists $parameter->{schema}->{additionalProperties}
                    )
                {
                    push @missing_additionalProperties,
                        {
                        type  => 'parameter',
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
                && $responses->{$response}->{schema}->{type} eq 'object' )
            {

                # it is an object type definition
                if ( not exists $responses->{$response}->{schema}->{additionalProperties} ) {
                    push @missing_additionalProperties,
                        {
                        type  => 'response',
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

    if ( can_run('swagger-cli') ) {
        my $spec_dir = "$FindBin::Bin/../api/v1/swagger";
        my $var      = qx{swagger-cli validate $spec_dir/swagger.yaml 2>&1};
        is( $?, 0, 'Validation exit code is 0' )
            or diag $var;
    } else {
        ok( 0, "Test skipped, swagger-cli missing" );
    }
};

subtest 'tags tests' => sub {

    plan tests => 1;

    my @top_level_tags = map { $_->{name} } @{ $spec->{tags} };

    my @errors;

    foreach my $route ( keys %{$paths} ) {
        foreach my $verb ( keys %{ $paths->{$route} } ) {
            my @tags = @{ $paths->{$route}->{$verb}->{tags} };

            # Check tag has an entry in the top level tags section
            foreach my $tag (@tags) {
                push @errors, "$verb $route -> uses tag '$tag' not present in top level list"
                    unless any { $_ eq $tag } @top_level_tags;
            }
        }
    }

    is_deeply( \@errors, [], 'No tag errors in the spec' );

    foreach my $error (@errors) {
        print STDERR "$error\n";
    }
};

subtest '400 response tests' => sub {

    plan tests => 1;

    my @errors;

    foreach my $route ( sort keys %{$paths} ) {
        foreach my $verb ( keys %{ $paths->{$route} } ) {

            my $response_400 = $paths->{$route}->{$verb}->{responses}->{400};

            if ( !$response_400 ) {
                push @errors, "$verb $route -> response 400 absent";
                next;
            }

            push @errors,
                "$verb $route -> 'description' does not start with 'Bad request': ($response_400->{description})"
                unless $response_400->{description} =~ /^Bad request/;

            my $ref = $response_400->{schema}->{'$ref'};
            push @errors, "$verb $route -> '\$ref' is not '#/definitions/error': ($ref)"
                unless $ref eq '#/definitions/error';

            # GET routes with q parameter must mention the `invalid_query` error code
            if (   ( any { $_->{in} eq 'body' && $_->{name} eq 'query' } @{ $paths->{$route}->{$verb}->{parameters} } )
                || ( any { $_->{in} eq 'query' && $_->{name} eq 'q' } @{ $paths->{$route}->{$verb}->{parameters} } ) )
            {

                push @errors,
                    "$verb $route -> 'description' does not include '* \`invalid_query\`': ($response_400->{description})"
                    unless $response_400->{description} =~ /\* \`invalid_query\`/;
            }
        }
    }

    is( scalar @errors, 0, 'No errors in 400 definitions in the spec' );

    foreach my $error (@errors) {
        print STDERR "$error\n";
    }
};

subtest 'POST (201) have location header' => sub {
    my @files = `git ls-files 'Koha/REST/V1/**/*.pm'`;
    my $exceptions = {
        'Koha/REST/V1/Auth/Password.pm'              => [qw(validate)],
        'Koha/REST/V1/ERM/EHoldings/Titles/Local.pm' => [qw(import_from_list import_from_kbart_file)],
        'Koha/REST/V1/Preservation/Trains.pm'        => [qw(add_item add_items copy_item)],
        'Koha/REST/V1/Preservation/WaitingList.pm'   => [qw(add_items)],
    };
    foreach my $file (@files) {
        chomp $file;
        my $doc  = PPI::Document->new($file);
        my $subs = $doc->find( sub { $_[1]->isa('PPI::Statement::Sub') } );

        foreach my $sub (@$subs) {
            my $name = $sub->name;
            if ( exists $exceptions->{$file} && grep { $name eq $_ } @{ $exceptions->{$file} } ) {
                pass("$file:$name is skipped - exception");
                next;
            }

            my $content = $sub->content;

            if ( $content =~ /\$c->res->headers->location\(.*?\);\s*return\s+\$c->render\s*\(\s*status\s*=>\s*201,/s ) {
                pass("$file:$name contains the location header");
            } elsif ( $content =~ /\$c->res->headers->location\(.*?\);/ ) {
                if ( $content !~ /return\s+\$c->render\s*\(\s*status\s*=>\s*201,/ ) {
                    fail("$file:$name has the location header without 201");
        } else {
                    fail("$file:$name has the location header and 201, but other statements should be between them");
                }
            } elsif ( $content !~ /status\s*=>\s*201/s ) {
                pass("$file:$name does not seem to have a POST endpoint");
            } else {
                fail("$file:$name does not contain the location header");
            }
        }
    }
};
