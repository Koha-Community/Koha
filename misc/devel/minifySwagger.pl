#!/usr/bin/perl

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

use Getopt::Long qw(:config no_ignore_case);

my $help = 0;
my $verbose = 0;
my $swaggerFile = "swagger.json";
my $swaggerMinifiedFile = "swagger.min.json";

GetOptions(
    'h|help'                      => \$help,
    'v|verbose:i'                 => \$verbose,
    's|source:s'                  => \$swaggerFile,
    'd|destination:s'             => \$swaggerMinifiedFile,
);

my $usage = <<USAGE;

minifySwagger.pl

Reads the swagger.json -file and all referenced JSON-Schema -files and merges
them into one merged and minified version. This minified swagger-file is
intended to be shared to our API consumers.

By default you must run this script from the same directory as the 'swagger.json'
and the minified specification is written to 'swagger.min.json'.
This is a convenience to make the minification process as easy as possible.

!DO NOT! set the executable flag on, or this can be ran from the internetz.

  -h --help             This happy helpful help!

  -v --verbose          0, default, no output.
                        1, turn on internal Swagger debugging flags
                        2, more verbose Swagger2 debugging

  -s --source           Which Swagger2-specification file to minify?
                        Defaults to "swagger.json"

  -d --destination      Where to write the minified Swagger2-spec?
                        Defaults to "swagger.min.json"

EXAMPLES:

    perl minifySwagger.pl -v 1 -s api/v1/swagger/swagger.json -d swag.json
    cd api/v1/swagger && perl minifySwagger.pl

USAGE

if ($help) {
    print $usage;
    exit 0;
}
if ($verbose > 0) {
    $ENV{SWAGGER2_DEBUG} = $verbose;
}


require Swagger2; #When you import the Swagger2-libraries, the environment variables are checked and cannot be altered anymore. So set verbosity first, then load libs.
my $swagger = Swagger2->new($swaggerFile);
$swagger = $swagger->expand; #Fetch all JSON-Schema references

my @errors = $swagger->validate;
print join("\n", "Swagger2: Invalid spec:", @errors)."\n" if @errors;
exit 1 if @errors;

removeNonSwagger2Values($swagger);

open(SWOUT, ">:encoding(UTF-8)", $swaggerMinifiedFile) or die "$0: Couldn't open the minified Swagger2 output file '$swaggerMinifiedFile':\n  $!";
print SWOUT $swagger->to_string();
close(SWOUT);

##For some reason stringifying the Swagger2-spec adds non-valid parameters, like "/id"
sub removeNonSwagger2Values {
    my ($swagger) = @_;

    my $data = $swagger->api_spec->data;
    delete($data->{id});
}
