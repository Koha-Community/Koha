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

use C4::Suggestions;

use Test::More tests => 14;
use Test::Warn;

BEGIN {
    use_ok('C4::Suggestions');
    use_ok('C4::Koha');
}

my $dbh = C4::Context->dbh;

# Start transaction
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

my ($suggestionid, $suggestion, $status, $biblionumber);
$biblionumber = 1;
ok($suggestionid= NewSuggestion( {title=>'Petit traité de philosohpie',author=>'Hubert de Chardassé',publishercode=>'Albin Michel'} ), "NewSuggestion OK");
ok($suggestion= GetSuggestion( $suggestionid), "GetSuggestion OK");
ok($status= ModSuggestion( {title=>'test Modif Simple', suggestionid=>$suggestionid} ), "ModSuggestion Simple OK");
warning_is { $status = ModSuggestion( {STATUS=>'STALLED', suggestionid=>$suggestionid} )}
           "No suggestions STALLED letter transported by email",
           "ModSuggestion status warning is correct";
ok( $status, "ModSuggestion Status OK");
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

$dbh->rollback;

1;
