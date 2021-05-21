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
use File::Slurp qw( read_file );
use JSON qw( from_json );
use Test::More tests => 4;
use Data::Dumper;

my $dh;

my $definitions_dir = 'api/v1/swagger/definitions';
opendir( $dh, $definitions_dir ) or die "$!";
my @files = readdir $dh;
my @wrong_additionalProperties;
ok( @files, "making sure we found definitions files" );
for my $file (@files) {
    next unless $file =~ m|\.json$|;
    my $spec = from_json read_file("$definitions_dir/$file");
    if ( not exists $spec->{additionalProperties}
        or $spec->{additionalProperties} != 0 )
    {
        push @wrong_additionalProperties, { file => $file, };
    }
}
is( scalar @wrong_additionalProperties, 0 )
  or diag Dumper \@wrong_additionalProperties;


my $paths_dir = 'api/v1/swagger/paths';
opendir( $dh, $paths_dir ) or die "$!";
@files = readdir $dh;
@wrong_additionalProperties = ();
ok(@files, "making sure we found paths files");
for my $file (@files) {
    next unless $file =~ m|\.json$|;
    my $spec = from_json read_file("$paths_dir/$file");
    for my $route ( keys %$spec ) {
        for my $method ( keys %{ $spec->{$route} } ) {
            next if $method ne 'post' && $method ne 'put';
            for my $parameter ( @{ $spec->{$route}->{$method}->{parameters} } ) {
                if ( exists $parameter->{schema} ) {

                    # If it's a ref we inherit from the definition file
                    next if exists $parameter->{schema}->{'$ref'};

                    if ( not exists $parameter->{schema}->{additionalProperties}
                        or $parameter->{schema}->{additionalProperties} != 0 )
                    {
                        push @wrong_additionalProperties,
                          {
                            file   => "$paths_dir/$file",
                            route  => $route,
                            method => $method,
                          };
                    }
                }
            }
        }
    }
}

is( scalar @wrong_additionalProperties, 0 )
  or diag Dumper \@wrong_additionalProperties;
