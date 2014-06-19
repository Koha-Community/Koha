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

use C4::Context;
use C4::Members;
use C4::Letters;

use Test::More tests => 91;
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

my $member = {
    firstname => 'my firstname',
    surname => 'my surname',
    categorycode => 'S',
    branchcode => 'CPL',
};
my $borrowernumber = AddMember(%$member);

my $biblionumber1 = 1;
my $my_suggestion = {
    title         => 'my title',
    author        => 'my author',
    publishercode => 'my publishercode',
    suggestedby   => $borrowernumber,
    biblionumber  => $biblionumber1,
};


is( CountSuggestion(), 0, 'CountSuggestion without the status returns 0' );
is( CountSuggestion('ASKED'), 0, 'CountSuggestion returns the correct number of suggestions' );
is( CountSuggestion('CHECKED'), 0, 'CountSuggestion returns the correct number of suggestions' );
is( CountSuggestion('ACCEPTED'), 0, 'CountSuggestion returns the correct number of suggestions' );
is( CountSuggestion('REJECTED'), 0, 'CountSuggestion returns the correct number of suggestions' );


my $my_suggestionid = NewSuggestion($my_suggestion);
isnt( $my_suggestionid, 0, 'NewSuggestion returns an not null id' );

is( GetSuggestion(), undef, 'GetSuggestion without the suggestion id returns undef' );
my $suggestion = GetSuggestion($my_suggestionid);
is( $suggestion->{title}, $my_suggestion->{title}, 'NewSuggestion stores the title correctly' );
is( $suggestion->{author}, $my_suggestion->{author}, 'NewSuggestion stores the author correctly' );
is( $suggestion->{publishercode}, $my_suggestion->{publishercode}, 'NewSuggestion stores the publishercode correctly' );
is( $suggestion->{suggestedby}, $my_suggestion->{suggestedby}, 'NewSuggestion stores the borrower number correctly' );
is( $suggestion->{biblionumber}, $my_suggestion->{biblionumber}, 'NewSuggestion stores the biblio number correctly' );
is( $suggestion->{STATUS}, 'ASKED', 'NewSuggestion stores a suggestion with the status ASKED by default' );

is( CountSuggestion('ASKED'), 1, 'CountSuggestion returns the correct number of suggestions' );


is( ModSuggestion(), undef, 'ModSuggestion without the suggestion returns undef' );
my $mod_suggestion1 = {
    title         => 'my modified title',
    author        => 'my modified author',
    publishercode => 'my modified publishercode',
};
my $status = ModSuggestion($mod_suggestion1);
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

is( CountSuggestion('CHECKED'), 1, 'CountSuggestion returns the correct number of suggestions' );


is( GetSuggestionInfo(), undef, 'GetSuggestionInfo without the suggestion id returns undef' );
$suggestion = GetSuggestionInfo($my_suggestionid);
is( $suggestion->{suggestionid}, $my_suggestionid, 'GetSuggestionInfo returns the suggestion id correctly' );
is( $suggestion->{title}, $mod_suggestion1->{title}, 'GetSuggestionInfo returns the title correctly' );
is( $suggestion->{author}, $mod_suggestion1->{author}, 'GetSuggestionInfo returns the author correctly' );
is( $suggestion->{publishercode}, $mod_suggestion1->{publishercode}, 'GetSuggestionInfo returns the publisher code correctly' );
is( $suggestion->{suggestedby}, $my_suggestion->{suggestedby}, 'GetSuggestionInfo returns the borrower number correctly' );
is( $suggestion->{biblionumber}, $my_suggestion->{biblionumber}, 'GetSuggestionInfo returns the biblio number correctly' );
is( $suggestion->{STATUS}, $mod_suggestion3->{STATUS}, 'GetSuggestionInfo returns the status correctly' );
is( $suggestion->{surnamesuggestedby}, $member->{surname}, 'GetSuggestionInfo returns the surname correctly' );
is( $suggestion->{firstnamesuggestedby}, $member->{firstname}, 'GetSuggestionInfo returns the firstname correctly' );
is( $suggestion->{borrnumsuggestedby}, $my_suggestion->{suggestedby}, 'GetSuggestionInfo returns the borrower number correctly' );


is( GetSuggestionFromBiblionumber(), undef, 'GetSuggestionFromBiblionumber without the biblio number returns undef' );
is( GetSuggestionFromBiblionumber(2), undef, 'GetSuggestionFromBiblionumber with an invalid biblio number returns undef' );
is( GetSuggestionFromBiblionumber($biblionumber1), $my_suggestionid, 'GetSuggestionFromBiblionumber functions correctly' );


is( GetSuggestionInfoFromBiblionumber(), undef, 'GetSuggestionInfoFromBiblionumber without the biblio number returns undef' );
is( GetSuggestionInfoFromBiblionumber(2), undef, 'GetSuggestionInfoFromBiblionumber with an invalid biblio number returns undef' );
$suggestion = GetSuggestionInfoFromBiblionumber($biblionumber1);
is( $suggestion->{suggestionid}, $my_suggestionid, 'GetSuggestionInfoFromBiblionumber returns the suggestion id correctly' );
is( $suggestion->{title}, $mod_suggestion1->{title}, 'GetSuggestionInfoFromBiblionumber returns the title correctly' );
is( $suggestion->{author}, $mod_suggestion1->{author}, 'GetSuggestionInfoFromBiblionumber returns the author correctly' );
is( $suggestion->{publishercode}, $mod_suggestion1->{publishercode}, 'GetSuggestionInfoFromBiblionumber returns the publisher code correctly' );
is( $suggestion->{suggestedby}, $my_suggestion->{suggestedby}, 'GetSuggestionInfoFromBiblionumber returns the borrower number correctly' );
is( $suggestion->{biblionumber}, $my_suggestion->{biblionumber}, 'GetSuggestionInfoFromBiblionumber returns the biblio number correctly' );
is( $suggestion->{STATUS}, $mod_suggestion3->{STATUS}, 'GetSuggestionInfoFromBiblionumber returns the status correctly' );
is( $suggestion->{surnamesuggestedby}, $member->{surname}, 'GetSuggestionInfoFromBiblionumber returns the surname correctly' );
is( $suggestion->{firstnamesuggestedby}, $member->{firstname}, 'GetSuggestionInfoFromBiblionumber returns the firstname correctly' );
is( $suggestion->{borrnumsuggestedby}, $my_suggestion->{suggestedby}, 'GetSuggestionInfoFromBiblionumeber returns the borrower number correctly' );


my $suggestions = GetSuggestionByStatus();
is( @$suggestions, 0, 'GetSuggestionByStatus without the status returns an empty array' );
$suggestions = GetSuggestionByStatus('CHECKED');
is( @$suggestions, 1, 'GetSuggestionByStatus returns the correct number of suggestions' );
is( $suggestions->[0]->{suggestionid}, $my_suggestionid, 'GetSuggestionByStatus returns the suggestion id correctly' );
is( $suggestions->[0]->{title}, $mod_suggestion1->{title}, 'GetSuggestionByStatus returns the title correctly' );
is( $suggestions->[0]->{author}, $mod_suggestion1->{author}, 'GetSuggestionByStatus returns the author correctly' );
is( $suggestions->[0]->{publishercode}, $mod_suggestion1->{publishercode}, 'GetSuggestionByStatus returns the publisher code correctly' );
is( $suggestions->[0]->{suggestedby}, $my_suggestion->{suggestedby}, 'GetSuggestionByStatus returns the borrower number correctly' );
is( $suggestions->[0]->{biblionumber}, $my_suggestion->{biblionumber}, 'GetSuggestionByStatus returns the biblio number correctly' );
is( $suggestions->[0]->{STATUS}, $mod_suggestion3->{STATUS}, 'GetSuggestionByStatus returns the status correctly' );
is( $suggestions->[0]->{surnamesuggestedby}, $member->{surname}, 'GetSuggestionByStatus returns the surname correctly' );
is( $suggestions->[0]->{firstnamesuggestedby}, $member->{firstname}, 'GetSuggestionByStatus returns the firstname correctly' );
is( $suggestions->[0]->{branchcodesuggestedby}, $member->{branchcode}, 'GetSuggestionByStatus returns the branch code correctly' );
is( $suggestions->[0]->{borrnumsuggestedby}, $my_suggestion->{suggestedby}, 'GetSuggestionByStatus returns the borrower number correctly' );
is( $suggestions->[0]->{categorycodesuggestedby}, $member->{categorycode}, 'GetSuggestionByStatus returns the category code correctly' );


is( ConnectSuggestionAndBiblio(), '0E0', 'ConnectSuggestionAndBiblio without arguments returns 0E0' );
my $biblionumber2 = 2;
my $connect_suggestion_and_biblio = ConnectSuggestionAndBiblio($my_suggestionid, $biblionumber2);
is( $connect_suggestion_and_biblio, '1', 'ConnectSuggestionAndBiblio returns 1' );
$suggestion = GetSuggestion($my_suggestionid);
is( $suggestion->{biblionumber}, $biblionumber2, 'ConnectSuggestionAndBiblio updates the biblio number correctly' );


my $search_suggestion = SearchSuggestion();
is( @$search_suggestion, 1, 'SearchSuggestion without arguments returns all suggestions' );

$search_suggestion = SearchSuggestion({
    title => $mod_suggestion1->{title},
});
is( @$search_suggestion, 1, 'SearchSuggestion returns the correct number of suggestions' );
$search_suggestion = SearchSuggestion({
    title => 'another title',
});
is( @$search_suggestion, 0, 'SearchSuggestion returns the correct number of suggestions' );

$search_suggestion = SearchSuggestion({
    author => $mod_suggestion1->{author},
});
is( @$search_suggestion, 1, 'SearchSuggestion returns the correct number of suggestions' );
$search_suggestion = SearchSuggestion({
    author => 'another author',
});
is( @$search_suggestion, 0, 'SearchSuggestion returns the correct number of suggestions' );

$search_suggestion = SearchSuggestion({
    publishercode => $mod_suggestion3->{publishercode},
});
is( @$search_suggestion, 1, 'SearchSuggestion returns the correct number of suggestions' );
$search_suggestion = SearchSuggestion({
    publishercode => 'another publishercode',
});
is( @$search_suggestion, 0, 'SearchSuggestion returns the correct number of suggestions' );

$search_suggestion = SearchSuggestion({
    STATUS => $mod_suggestion3->{STATUS},
});
is( @$search_suggestion, 1, 'SearchSuggestion returns the correct number of suggestions' );
$search_suggestion = SearchSuggestion({
    STATUS => 'REJECTED',
});
is( @$search_suggestion, 0, 'SearchSuggestion returns the correct number of suggestions' );


my $del_suggestion = {
    title => 'my deleted title',
    STATUS => 'CHECKED',
    suggestedby => $borrowernumber,
};
my $del_suggestionid = NewSuggestion($del_suggestion);

is( CountSuggestion('CHECKED'), 2, 'CountSuggestion returns the correct number of suggestions' );

is( DelSuggestion(), '0E0', 'DelSuggestion without arguments returns 0E0' );
is( DelSuggestion($borrowernumber), '', 'DelSuggestion without the suggestion id returns an empty string' );
is( DelSuggestion(undef, $my_suggestionid), '', 'DelSuggestion with an invalid borrower number returns an empty string' );
$suggestion = DelSuggestion($borrowernumber, $my_suggestionid);
is( $suggestion, 1, 'DelSuggestion deletes one suggestion' );

$suggestions = GetSuggestionByStatus('CHECKED');
is( @$suggestions, 1, 'DelSuggestion deletes one suggestion' );
is( $suggestions->[0]->{title}, $del_suggestion->{title}, 'DelSuggestion deletes the correct suggestion' );

## Bug 11466, making sure GetSupportList() returns itemtypes, even if AdvancedSearchTypes has multiple values
C4::Context->set_preference("AdvancedSearchTypes", 'itemtypes|loc|ccode');
my $itemtypes1 = C4::Koha::GetSupportList();
is(@$itemtypes1, 8, "Purchase suggestion itemtypes collected, multiple AdvancedSearchTypes");

C4::Context->set_preference("AdvancedSearchTypes", 'itemtypes');
my $itemtypes2 = C4::Koha::GetSupportList();
is(@$itemtypes2, 8, "Purchase suggestion itemtypes collected, default AdvancedSearchTypes");

is_deeply($itemtypes1, $itemtypes2, 'same set of purchase suggestion formats retrieved');

$dbh->rollback;
