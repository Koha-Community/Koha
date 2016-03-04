#!/usr/bin/perl

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

use Test::More tests => 7;

use File::Basename;
use t::lib::Mocks;
use C4::Context;

t::lib::Mocks::mock_preference( "UseQueryParser", 1 );
my $QParser = C4::Context->queryparser();

# Check initialization correctly parsed the config file
ok( defined $QParser && ref($QParser) eq "Koha::QueryParser::Driver::PQF"
    , 'C4::Context successfully created a QP object' );

is( $QParser->search_class_count, 4,
    "Initialized 4 search classes" );
is( scalar(@{$QParser->search_fields()->{'keyword'}}), 111,
    "Correct number of search fields for 'keyword' class");
is( scalar(@{$QParser->search_fields()->{'author'}}), 5,
    "Correct number of search fields for 'author' class");
is( scalar(@{$QParser->search_fields()->{'subject'}}), 12,
    "Correct number of search fields for 'subject' class");
is( scalar(@{$QParser->search_fields()->{'title'}}), 5,
    "Correct number of search fields for 'title' class");

# Load C4::Context 4 times with different randomization seeds
$ENV{ PERL_PERTURB_KEYS } = "1";
my $hash_seed = "AB123";
my $default_search_class1 = get_default_search_class();
$hash_seed = "CD456";
my $default_search_class2 = get_default_search_class();
$hash_seed = "ABCDE";
my $default_search_class3 = get_default_search_class();
$hash_seed = "123456";
my $default_search_class4 = get_default_search_class();

ok( $default_search_class1 eq 'keyword' &&
    $default_search_class2 eq 'keyword' &&
    $default_search_class3 eq 'keyword' &&
    $default_search_class4 eq 'keyword',
    "C4::Context correctly sets the default search class to 'keyword' (Bug 12738)");

sub get_default_search_class {
    # get the default search class from a forked proccess
    # that just loads C4::Context
    $ENV{ PERL_HASH_SEED }    = $hash_seed;
    my $running_dir = dirname(__FILE__);
    my $default_search_class = qx/$running_dir\/default_search_class.pl/;

    return $default_search_class;
}

1;
