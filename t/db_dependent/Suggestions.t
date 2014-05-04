#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use strict;
use warnings;
use Data::Dumper;

use C4::Suggestions;

use Test::More tests => 13;

BEGIN {
    use_ok('C4::Suggestions');
    use_ok('C4::Koha');
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

## Bug 11466, making sure GetSupportList() returns itemtypes, even if AdvancedSearchTypes has multiple values
C4::Context->set_preference("AdvancedSearchTypes", 'itemtypes|loc|ccode');
my $itemtypes1 = C4::Koha::GetSupportList();
ok(scalar @$itemtypes1, "Purchase suggestion itemtypes collected, multiple AdvancedSearchTypes");

C4::Context->set_preference("AdvancedSearchTypes", 'itemtypes');
my $itemtypes2 = C4::Koha::GetSupportList();
ok(scalar @$itemtypes2, "Purchase suggestion itemtypes collected, default AdvancedSearchTypes");

is_deeply($itemtypes1, $itemtypes2, 'same set of purchase suggestion formats retrieved');

##EO Bug 11466
