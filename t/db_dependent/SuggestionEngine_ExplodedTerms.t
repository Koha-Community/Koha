#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

BEGIN {
        use_ok('Koha::SuggestionEngine');
}

my $suggestor = Koha::SuggestionEngine->new( { plugins => [ 'ExplodedTerms' ] } );
is(ref($suggestor), 'Koha::SuggestionEngine', 'Created suggestion engine');

my $result = $suggestor->get_suggestions({search => 'Cookery'});

ok((grep { $_->{'search'} eq 'su-na=Cookery' } @$result) && (grep { $_->{'search'} eq 'su-br=Cookery' } @$result) && (grep { $_->{'search'} eq 'su-rl=Cookery' } @$result), "Suggested correct alternatives for keyword search 'Cookery'");

$result = $suggestor->get_suggestions({search => 'su:Cookery'});

ok((grep { $_->{'search'} eq 'su-na=Cookery' } @$result) && (grep { $_->{'search'} eq 'su-br=Cookery' } @$result) && (grep { $_->{'search'} eq 'su-rl=Cookery' } @$result), "Suggested correct alternatives for subject search 'Cookery'");

$result = $suggestor->get_suggestions({search => 'nt:Cookery'});

is(scalar @$result, 0, "No suggestions for fielded search");

$result = $suggestor->get_suggestions({search => 'ccl=su:Cookery'});

is(scalar @$result, 0, "No suggestions for CCL search");

done_testing();
