#!/usr/bin/perl

# This file is part of Koha
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
use Test::More tests => 6;

use Koha::SuggestionEngine;

my $suggestor = Koha::SuggestionEngine->new( { plugins => ['ExplodedTerms'] } );
is( ref($suggestor), 'Koha::SuggestionEngine', 'Created suggestion engine' );

my $result = $suggestor->get_suggestions( { search => 'Cookery' } );

ok(
           ( grep { $_->{'search'} eq 'su-na:Cookery' } @$result )
        && ( grep { $_->{'search'} eq 'su-br:Cookery' } @$result )
        && ( grep { $_->{'search'} eq 'su-rl:Cookery' } @$result ),
    "Suggested correct alternatives for keyword search 'Cookery'"
);

$result = $suggestor->get_suggestions( { search => 'su:Cookery' } );

ok(
           ( grep { $_->{'search'} eq 'su-na:Cookery' } @$result )
        && ( grep { $_->{'search'} eq 'su-br:Cookery' } @$result )
        && ( grep { $_->{'search'} eq 'su-rl:Cookery' } @$result ),
    "Suggested correct alternatives for subject search 'Cookery'"
);

$result = $suggestor->get_suggestions( { search => 'nt:Cookery' } );

is( scalar @$result, 0, "No suggestions for fielded search" );

$result = $suggestor->get_suggestions( { search => 'ccl=su:Cookery' } );

is( scalar @$result, 0, "No suggestions for CCL search" );
