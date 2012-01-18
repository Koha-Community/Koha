#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use strict;
use warnings;
use Data::Dumper;

use C4::Suggestions;

use Test::More tests =>9;

BEGIN {
    use_ok('C4::Suggestions');
}

my ($suggestionid, $suggestion, $status, $biblionumber);
$biblionumber = 1;
ok($suggestionid= NewSuggestion( {title=>'Petit traité de philosohpie',author=>'Hubert de Chardassé',publishercode=>'Albin Michel'} ), "NewSuggestion OK");
ok($suggestion= GetSuggestion( $suggestionid), "GetSuggestion OK");
ok($status= ModSuggestion( {title=>'test Modif Simple', suggestionid=>$suggestionid} ), "ModSuggestion Simple OK");
ok($status= ModSuggestion( {STATUS=>'STALLED', suggestionid=>$suggestionid} ), "ModSuggestion Status OK");
ok($status= ModSuggestion( {suggestionid => $suggestionid, biblionumber => $biblionumber } ), "ModSuggestion, set biblionumber OK" );
ok($suggestion= GetSuggestionFromBiblionumber( $biblionumber ), "GetSuggestionFromBiblionumber OK");
ok($suggestion= GetSuggestionInfoFromBiblionumber( $biblionumber ), "GetSuggestionInfoFromBiblionumber OK");
ok(@{SearchSuggestion( {STATUS=>'STALLED'} )}>0, "SearchSuggestion Status OK");

