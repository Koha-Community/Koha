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
use C4::Context;
use C4::Members;
use C4::Letters;

use Test::More tests => 34;
use Test::Warn;

BEGIN {
    use_ok('C4::Suggestions');
    use_ok('C4::Koha');
}

my $dbh = C4::Context->dbh;

# Start transaction
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

$dbh->do(q|DELETE FROM suggestions|);
$dbh->do(q|DELETE FROM borrowers|);
$dbh->do(q|DELETE FROM letter|);
$dbh->do(q|DELETE FROM message_queue|);
$dbh->do(q|INSERT INTO letter(module, code, content) VALUES ('suggestions', 'CHECKED', 'my content')|);

my $borrowernumber = AddMember(
    firstname    => 'my firstname',
    surname      => 'my surname',
    categorycode => 'S',
    branchcode   => 'CPL',
);

my $my_suggestion = {
    title         => 'my title',
    author        => 'my author',
    publishercode => 'my publishercode',
    suggestedby   => $borrowernumber,
    biblionumber  => 1,
};
my $my_suggestionid = NewSuggestion($my_suggestion);
isnt( $my_suggestionid, 0, 'NewSuggestion returns an not null id' );
my $suggestion = GetSuggestion($my_suggestionid);
is( $suggestion->{title}, $my_suggestion->{title}, 'NewSuggestion stores the title correctly' );
is( $suggestion->{author}, $my_suggestion->{author}, 'NewSuggestion stores the author correctly' );
is( $suggestion->{publishercode}, $my_suggestion->{publishercode}, 'NewSuggestion stores the publishercode correctly' );
is( $suggestion->{suggestedby}, $my_suggestion->{suggestedby}, 'NewSuggestion stores the borrower number correctly' );
is( $suggestion->{biblionumber}, $my_suggestion->{biblionumber}, 'NewSuggestion stores the biblio number correctly' );
is( $suggestion->{STATUS}, 'ASKED', 'NewSuggestion stores a suggestion with the status ASKED by default' );
$suggestion = GetSuggestion();
is( $suggestion, undef, 'GetSuggestion without the suggestion id returns undef' );


my $status = ModSuggestion();
is( $status, undef, 'ModSuggestion without arguments returns undef' );

my $mod_suggestion1 = {
    title         => 'my modified title',
    author        => 'my modified author',
    publishercode => 'my modified publishercode',
};
$status = ModSuggestion($mod_suggestion1);
is( $status, '0E0', 'ModSuggestion without the suggestion id returns 0E0' );

$mod_suggestion1->{suggestionid} = $my_suggestionid;
$status = ModSuggestion($mod_suggestion1);
is( $status, 1, 'ModSuggestion modifies one entry' );
$suggestion = GetSuggestion($my_suggestionid);
is( $suggestion->{title}, $mod_suggestion1->{title}, 'ModSuggestion modifies the title  correctly' );
is( $suggestion->{author}, $mod_suggestion1->{author}, 'ModSuggestion modifies the author correctly' );
is( $suggestion->{publishercode}, $mod_suggestion1->{publishercode}, 'ModSuggestion modifies the publishercode correctly' );
my $messages = C4::Letters::GetQueuedMessages({
    borrowernumber => $borrowernumber,
});
is( @$messages, 0, 'ModSuggestions does not send an email if the status is not updated' );

my $mod_suggestion2 = {
    STATUS       => 'STALLED',
    suggestionid => $my_suggestionid,
};
warning_is { $status = ModSuggestion($mod_suggestion2) }
           "No suggestions STALLED letter transported by email",
           "ModSuggestion status warning is correct";
is( $status, 1, "ModSuggestion Status OK");

my $mod_suggestion3 = {
    STATUS       => 'CHECKED',
    suggestionid => $my_suggestionid,
};
$status = ModSuggestion($mod_suggestion3);

is( $status, 1, 'ModSuggestion modifies one entry' );
$suggestion = GetSuggestion($my_suggestionid);
is( $suggestion->{STATUS}, $mod_suggestion3->{STATUS}, 'ModSuggestion modifies the status correctly' );
$messages = C4::Letters::GetQueuedMessages({
    borrowernumber => $borrowernumber,
});
is( @$messages, 1, 'ModSuggestion sends an email if the status is updated' );

my $biblionumber = 1;
my $suggestionid = GetSuggestionFromBiblionumber($biblionumber);
is( $suggestionid, $my_suggestionid, 'GetSuggestionFromBiblionumber functions correctly' );


$suggestion = GetSuggestionInfoFromBiblionumber($biblionumber);
is( $suggestion->{suggestionid}, $my_suggestionid, 'GetSuggestionInfoFromBiblionumber gets the suggestion id correctly' );

is( $suggestion->{title}, $mod_suggestion1->{title}, 'GetSuggestionInfoFromBiblionumber gets the title correctly' );
is( $suggestion->{author}, $mod_suggestion1->{author}, 'GetSuggestionInfoFromBiblionumber gets the author correctly' );
is( $suggestion->{publishercode}, $mod_suggestion1->{publishercode}, 'GetSuggestionInfoFromBiblionumber gets the publisher code correctly' );
is( $suggestion->{suggestedby}, $my_suggestion->{suggestedby}, 'GetSuggestionInfoFromBiblionumber gets the borrower number correctly' );
is( $suggestion->{biblionumber}, $my_suggestion->{biblionumber}, 'GetSuggestionInfoFromBiblionumber gets the biblio number correctly' );
is( $suggestion->{STATUS}, $mod_suggestion3->{STATUS}, 'GetSuggestionInfoFromBiblionumber gets the status correctly' );


my $search_suggestion = SearchSuggestion({
    STATUS => $mod_suggestion3->{STATUS},
});
is( @$search_suggestion, 1, '' );

## Bug 11466, making sure GetSupportList() returns itemtypes, even if AdvancedSearchTypes has multiple values
C4::Context->set_preference("AdvancedSearchTypes", 'itemtypes|loc|ccode');
my $itemtypes1 = C4::Koha::GetSupportList();
is(@$itemtypes1, 8, "Purchase suggestion itemtypes collected, multiple AdvancedSearchTypes");

C4::Context->set_preference("AdvancedSearchTypes", 'itemtypes');
my $itemtypes2 = C4::Koha::GetSupportList();
is(@$itemtypes2, 8, "Purchase suggestion itemtypes collected, default AdvancedSearchTypes");

is_deeply($itemtypes1, $itemtypes2, 'same set of purchase suggestion formats retrieved');

$dbh->rollback;
