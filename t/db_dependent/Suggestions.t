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

use Test::More tests => 10;
use Test::Warn;

BEGIN {
    use_ok('C4::Suggestions');
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
           "No suggestions STALLED letter",
           "ModSuggestion status warning is correct";
ok( $status, "ModSuggestion Status OK");
ok($status= ModSuggestion( {suggestionid => $suggestionid, biblionumber => $biblionumber } ), "ModSuggestion, set biblionumber OK" );
ok($suggestion= GetSuggestionFromBiblionumber( $biblionumber ), "GetSuggestionFromBiblionumber OK");
ok($suggestion= GetSuggestionInfoFromBiblionumber( $biblionumber ), "GetSuggestionInfoFromBiblionumber OK");
ok(@{SearchSuggestion( {STATUS=>'STALLED'} )}>0, "SearchSuggestion Status OK");


$dbh->rollback;

1;
