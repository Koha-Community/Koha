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

use DateTime::Duration;
use Test::More tests => 106;
use Test::Warn;

use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Context;
use C4::Letters qw( GetQueuedMessages GetMessage );
use C4::Budgets qw( AddBudgetPeriod AddBudget GetBudget );
use Koha::Database;
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Libraries;
use Koha::Patrons;
use Koha::Suggestions;

BEGIN {
    use_ok('C4::Suggestions', qw( NewSuggestion GetSuggestion ModSuggestion GetSuggestionInfo GetSuggestionFromBiblionumber GetSuggestionInfoFromBiblionumber GetSuggestionByStatus ConnectSuggestionAndBiblio SearchSuggestion DelSuggestion MarcRecordFromNewSuggestion GetUnprocessedSuggestions DelSuggestionsOlderThan ));
}

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( "EmailPurchaseSuggestions", "0");

# Reset item types to only the default ones
$dbh->do(q|DELETE FROM itemtypes;|);
my $sql = qq|
INSERT INTO itemtypes (itemtype, description, rentalcharge, notforloan, imageurl, summary) VALUES
('BK', 'Books',5,0,'bridge/book.png',''),
('MX', 'Mixed Materials',5,0,'bridge/kit.png',''),
('CF', 'Computer Files',5,0,'bridge/computer_file.png',''),
('MP', 'Maps',5,0,'bridge/map.png',''),
('VM', 'Visual Materials',5,1,'bridge/dvd.png',''),
('MU', 'Music',5,0,'bridge/sound.png',''),
('CR', 'Continuing Resources',5,0,'bridge/periodical.png',''),
('REF', 'Reference',0,1,'bridge/reference.png','');|;
$dbh->do($sql);
$dbh->do(q|DELETE FROM suggestions|);
$dbh->do(q|DELETE FROM issues|);
$dbh->do(q|DELETE FROM borrowers|);
$dbh->do(q|DELETE FROM letter|);
$dbh->do(q|DELETE FROM message_queue|);
$dbh->do(q|INSERT INTO letter(module, code, content) VALUES ('suggestions', 'CHECKED', 'my content')|);
$dbh->do(q|INSERT INTO letter(module, code, content) VALUES ('suggestions', 'NEW_SUGGESTION', 'Content for new suggestion')|);

# Add CPL if missing.
if (not defined Koha::Libraries->find('CPL')) {
    Koha::Library->new({ branchcode => 'CPL', branchname => 'Centerville' })->store;
}

my $patron_category = $builder->build({ source => 'Category' });

my $member = {
    firstname => 'my firstname',
    surname => 'my surname',
    categorycode => $patron_category->{categorycode},
    branchcode => 'CPL',
    smsalertnumber => 12345,
};

my $member2 = {
    firstname => 'my firstname',
    surname => 'my surname',
    categorycode => $patron_category->{categorycode},
    branchcode => 'CPL',
    email => 'to@example.com',
};

my $borrowernumber = Koha::Patron->new($member)->store->borrowernumber;
my $borrowernumber2 = Koha::Patron->new($member2)->store->borrowernumber;

my $biblio_1 = $builder->build_object({ class => 'Koha::Biblios' });
my $my_suggestion = {
    title         => 'my title',
    author        => 'my author',
    publishercode => 'my publishercode',
    suggestedby   => $borrowernumber,
    biblionumber  => $biblio_1->biblionumber,
    branchcode    => 'CPL',
    managedby     => '',
    manageddate   => '',
    accepteddate  => dt_from_string,
    note          => 'my note',
    quantity      => '', # Insert an empty string into int to catch strict SQL modes errors
};

my $budgetperiod_id = AddBudgetPeriod({
    budget_period_startdate   => '2008-01-01',
    budget_period_enddate     => '2008-12-31',
    budget_period_description => 'MAPERI',
    budget_period_active      => 1,
});

my $budget_id = AddBudget({
    budget_code      => 'ABCD',
    budget_amount    => '123.132000',
    budget_name      => 'ABCD',
    budget_notes     => 'This is a note',
    budget_period_id => $budgetperiod_id,
});
my $my_suggestion_with_budget = {
    title         => 'my title 2',
    author        => 'my author 2',
    publishercode => 'my publishercode 2',
    suggestedby   => $borrowernumber,
    branchcode    => '', # This should not fail be set to undef instead
    biblionumber  => $biblio_1->biblionumber,
    managedby     => '',
    manageddate   => '',
    accepteddate  => dt_from_string,
    note          => 'my note',
    budgetid      => $budget_id,
};
my $my_suggestion_with_budget2 = {
    title         => 'my title 3',
    author        => 'my author 3',
    publishercode => 'my publishercode 3',
    suggestedby   => $borrowernumber2,
    biblionumber  => $biblio_1->biblionumber,
    managedby     => '',
    manageddate   => '',
    accepteddate  => dt_from_string,
    note          => 'my note',
    budgetid      => $budget_id,
};
my $my_suggestion_without_suggestedby = {
    title         => 'my title',
    author        => 'my author',
    publishercode => 'my publishercode',
    suggestedby   => undef,
    biblionumber  => $biblio_1->biblionumber,
    branchcode    => 'CPL',
    managedby     => '',
    manageddate   => '',
    accepteddate  => dt_from_string,
    note          => 'my note',
    quantity      => '', # Insert an empty string into int to catch strict SQL modes errors
};

my $my_suggestionid = NewSuggestion($my_suggestion);
isnt( $my_suggestionid, 0, 'NewSuggestion returns an not null id' );
my $my_suggestionid_with_budget = NewSuggestion($my_suggestion_with_budget);

is( GetSuggestion(), undef, 'GetSuggestion without the suggestion id returns undef' );
my $suggestion = GetSuggestion($my_suggestionid);
is( $suggestion->{title}, $my_suggestion->{title}, 'NewSuggestion stores the title correctly' );
is( $suggestion->{author}, $my_suggestion->{author}, 'NewSuggestion stores the author correctly' );
is( $suggestion->{publishercode}, $my_suggestion->{publishercode}, 'NewSuggestion stores the publishercode correctly' );
is( $suggestion->{suggestedby}, $my_suggestion->{suggestedby}, 'NewSuggestion stores the borrower number correctly' );
is( $suggestion->{biblionumber}, $my_suggestion->{biblionumber}, 'NewSuggestion stores the biblio number correctly' );
is( $suggestion->{STATUS}, 'ASKED', 'NewSuggestion stores a suggestion with the status ASKED by default' );
is( $suggestion->{managedby}, undef, 'NewSuggestion stores empty string as undef for non existent foreign key (integer)' );
is( $suggestion->{manageddate}, undef, 'NewSuggestion stores empty string as undef for date' );
is( $suggestion->{budgetid}, undef, 'NewSuggestion should set budgetid to NULL if not given' );

is( ModSuggestion(), undef, 'ModSuggestion without the suggestion returns undef' );
my $mod_suggestion1 = {
    title         => 'my modified title',
    author        => 'my modified author',
    publishercode => 'my modified publishercode',
    managedby     => '',
    manageddate   => '',
};
my $status = ModSuggestion($mod_suggestion1);
is( $status, undef, 'ModSuggestion without the suggestion id returns undef' );

$mod_suggestion1->{suggestionid} = $my_suggestionid;
$status = ModSuggestion($mod_suggestion1);
is( $status, 1, 'ModSuggestion modifies one entry' );
$suggestion = GetSuggestion($my_suggestionid);
is( $suggestion->{title}, $mod_suggestion1->{title}, 'ModSuggestion modifies the title  correctly' );
is( $suggestion->{author}, $mod_suggestion1->{author}, 'ModSuggestion modifies the author correctly' );
is( $suggestion->{publishercode}, $mod_suggestion1->{publishercode}, 'ModSuggestion modifies the publishercode correctly' );
is( $suggestion->{managedby}, undef, 'ModSuggestion stores empty string as undef for non existent foreign key (integer)' );
is( $suggestion->{manageddate}, undef, 'ModSuggestion stores empty string as undef for date' );
isnt( $suggestion->{accepteddate}, undef, 'ModSuggestion does not update a non given date value' );
is( $suggestion->{note}, 'my note', 'ModSuggestion should not erase data if not given' );

my $messages = C4::Letters::GetQueuedMessages({
    borrowernumber => $borrowernumber
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

#Test the message_transport_type of suggestion notices

#Check the message_transport_type when the 'FallbackToSMSIfNoEmail' syspref is disabled
t::lib::Mocks::mock_preference( 'FallbackToSMSIfNoEmail', 0 );
$status = ModSuggestion($mod_suggestion3);
is( $status, 1, 'ModSuggestion modifies one entry' );
$suggestion = GetSuggestion($my_suggestionid);
is( $suggestion->{STATUS}, $mod_suggestion3->{STATUS}, 'ModSuggestion modifies the status correctly' );
$messages = C4::Letters::GetQueuedMessages({
    borrowernumber => $borrowernumber
});
is( @$messages, 1, 'ModSuggestion sends an email if the status is updated' );
is ($messages->[0]->{message_transport_type}, 'email', 'When FallbackToSMSIfNoEmail syspref is disabled the suggestion message_transport_type is always email');

#Check the message_transport_type when the 'FallbackToSMSIfNoEmail' syspref is enabled and the borrower has a smsalertnumber and no email
t::lib::Mocks::mock_preference( 'FallbackToSMSIfNoEmail', 1 );
ModSuggestion($mod_suggestion3);
$messages = C4::Letters::GetQueuedMessages({
    borrowernumber => $borrowernumber
});
is ($messages->[1]->{message_transport_type}, 'sms', 'When FallbackToSMSIfNoEmail syspref is enabled the suggestion message_transport_type is sms if the borrower has no email');

#Make a new suggestion for a borrower with defined email and no smsalertnumber
my $my_suggestion_2_id = NewSuggestion($my_suggestion_with_budget2);

#Check the message_transport_type when the 'FallbackToSMSIfNoEmail' syspref is enabled and the borrower has a defined email and no smsalertnumber
t::lib::Mocks::mock_preference( 'FallbackToSMSIfNoEmail', 1 );
my $mod_suggestion4 = {
    STATUS       => 'CHECKED',
    suggestionid => $my_suggestion_2_id,
};
ModSuggestion($mod_suggestion4);
$messages = C4::Letters::GetQueuedMessages({
    borrowernumber => $borrowernumber2
});
is ($messages->[0]->{message_transport_type}, 'email', 'When FallbackToSMSIfNoEmail syspref is enabled the suggestion message_transport_type is email if the borrower has an email');

{
    # Hiding the expected warning displayed by DBI
    # DBD::mysql::st execute failed: Incorrect date value: 'invalid date!' for column 'manageddate'
    local *STDERR;
    open STDERR, '>', '/dev/null';

    $mod_suggestion4->{manageddate} = 'invalid date!';
    ModSuggestion($mod_suggestion4);
    $messages = C4::Letters::GetQueuedMessages({
        borrowernumber => $borrowernumber2
    });

    close STDERR;
    is (scalar(@$messages), 1, 'No new letter should have been generated if the update raised an error');
}

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
is( GetSuggestionFromBiblionumber($biblio_1->biblionumber), $my_suggestionid, 'GetSuggestionFromBiblionumber functions correctly' );


is( GetSuggestionInfoFromBiblionumber(), undef, 'GetSuggestionInfoFromBiblionumber without the biblio number returns undef' );
is( GetSuggestionInfoFromBiblionumber(2), undef, 'GetSuggestionInfoFromBiblionumber with an invalid biblio number returns undef' );
$suggestion = GetSuggestionInfoFromBiblionumber($biblio_1->biblionumber);
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
is( @$suggestions, 2, 'GetSuggestionByStatus returns the correct number of suggestions' );
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
my $biblio_2 = $builder->build_object({ class => 'Koha::Biblios' });
my $connect_suggestion_and_biblio = ConnectSuggestionAndBiblio($my_suggestionid, $biblio_2->biblionumber);
is( $connect_suggestion_and_biblio, '1', 'ConnectSuggestionAndBiblio returns 1' );
$suggestion = GetSuggestion($my_suggestionid);
is( $suggestion->{biblionumber}, $biblio_2->biblionumber, 'ConnectSuggestionAndBiblio updates the biblio number correctly' );

my $search_suggestion = SearchSuggestion();
is( @$search_suggestion, 3, 'SearchSuggestion without arguments returns all suggestions' );

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
    publishercode => $mod_suggestion1->{publishercode},
});
is( @$search_suggestion, 1, 'SearchSuggestion returns the correct number of suggestions' );
$search_suggestion = SearchSuggestion({
    publishercode => 'another publishercode',
});
is( @$search_suggestion, 0, 'SearchSuggestion returns the correct number of suggestions' );

$search_suggestion = SearchSuggestion({
    STATUS => $mod_suggestion3->{STATUS},
});
is( @$search_suggestion, 2, 'SearchSuggestion returns the correct number of suggestions' );

$search_suggestion = SearchSuggestion({
    STATUS => q||
});
is( @$search_suggestion, 0, 'SearchSuggestion should not return all suggestions if we want the suggestions with a STATUS=""' );
$search_suggestion = SearchSuggestion({
    STATUS => 'REJECTED',
});
is( @$search_suggestion, 0, 'SearchSuggestion returns the correct number of suggestions' );

$search_suggestion = SearchSuggestion({
    budgetid => '',
});
is( @$search_suggestion, 3, 'SearchSuggestion (budgetid = "") returns the correct number of suggestions' );
$search_suggestion = SearchSuggestion({
    budgetid => $budget_id,
});
is( @$search_suggestion, 2, 'SearchSuggestion (budgetid = $budgetid) returns the correct number of suggestions' );
$search_suggestion = SearchSuggestion({
    budgetid => '__NONE__',
});
is( @$search_suggestion, 1, 'SearchSuggestion (budgetid = "__NONE__") returns the correct number of suggestions' );
$search_suggestion = SearchSuggestion({
    budgetid => '__ANY__',
});
is( @$search_suggestion, 3, 'SearchSuggestion (budgetid = "__ANY__") returns the correct number of suggestions' );

$search_suggestion = SearchSuggestion({ budgetid => $budget_id });
is( @$search_suggestion[0]->{budget_name}, GetBudget($budget_id)->{budget_name}, 'SearchSuggestion returns the correct budget name');
$search_suggestion = SearchSuggestion({ budgetid => "__NONE__" });
is( @$search_suggestion[0]->{budget_name}, undef, 'SearchSuggestion returns the correct budget name');


my $del_suggestion = {
    title => 'my deleted title',
    STATUS => 'CHECKED',
    suggestedby => $borrowernumber,
};
my $del_suggestionid = NewSuggestion($del_suggestion);

is( DelSuggestion(), '0E0', 'DelSuggestion without arguments returns 0E0' );
is( DelSuggestion($borrowernumber), '', 'DelSuggestion without the suggestion id returns an empty string' );
is( DelSuggestion(undef, $my_suggestionid), '', 'DelSuggestion with an invalid borrower number returns an empty string' );
$suggestion = DelSuggestion($borrowernumber, $my_suggestionid);
is( $suggestion, 1, 'DelSuggestion deletes one suggestion' );

$suggestions = GetSuggestionByStatus('CHECKED');
is( @$suggestions, 2, 'DelSuggestion deletes one suggestion' );
is( $suggestions->[1]->{title}, $del_suggestion->{title}, 'DelSuggestion deletes the correct suggestion' );

# Test budgetid fk
$my_suggestion->{budgetid} = ''; # If budgetid == '', NULL should be set in DB
my $my_suggestionid_test_budgetid = NewSuggestion($my_suggestion);
$suggestion = GetSuggestion($my_suggestionid_test_budgetid);
is( $suggestion->{budgetid}, undef, 'NewSuggestion Should set budgetid to NULL if equals an empty string' );

$my_suggestion->{budgetid} = ''; # If budgetid == '', NULL should be set in DB
ModSuggestion( $my_suggestion );
$suggestion = GetSuggestion($my_suggestionid_test_budgetid);
is( $suggestion->{budgetid}, undef, 'NewSuggestion Should set budgetid to NULL if equals an empty string' );

my $suggestion2 = {
    title => "Cuisine d'automne",
    author => "Catherine",
    itemtype => "LIV"
};

my $record = MarcRecordFromNewSuggestion($suggestion2);

is("MARC::Record", ref($record), "MarcRecordFromNewSuggestion should return a MARC::Record object");

my ($title_tag, $title_subfield) = C4::Biblio::GetMarcFromKohaField('biblio.title', '');

is($record->field( $title_tag )->subfield( $title_subfield ), "Cuisine d'automne", "Record from suggestion title should be 'Cuisine d'automne'");

my ($author_tag, $author_subfield) = C4::Biblio::GetMarcFromKohaField('biblio.author', '');

is($record->field( $author_tag )->subfield( $author_subfield ), "Catherine", "Record from suggestion author should be 'Catherine'");

subtest 'GetUnprocessedSuggestions' => sub {
    plan tests => 11;
    $dbh->do(q|DELETE FROM suggestions|);
    my $my_suggestionid         = NewSuggestion($my_suggestion);
    my $unprocessed_suggestions = C4::Suggestions::GetUnprocessedSuggestions;
    is( scalar(@$unprocessed_suggestions), 0, 'GetUnprocessedSuggestions should return 0 if a suggestion has been processed but not linked to a fund' );
    my $status     = ModSuggestion($mod_suggestion1);
    my $suggestion = GetSuggestion($my_suggestionid);
    is( $suggestion->{budgetid}, undef, 'ModSuggestion should set budgetid to NULL if not given' );
    ModSuggestion( { suggestionid => $my_suggestionid, budgetid => $budget_id } );
    $suggestion = GetSuggestion($my_suggestionid);
    is( $suggestion->{budgetid}, $budget_id, 'ModSuggestion should modify budgetid if given' );

    $unprocessed_suggestions = C4::Suggestions::GetUnprocessedSuggestions;
    is( scalar(@$unprocessed_suggestions), 1, 'GetUnprocessedSuggestions should return the suggestion if the suggestion is linked to a fund and has not been processed yet' );

    warning_is { ModSuggestion( { suggestionid => $my_suggestionid, STATUS => 'REJECTED' } ) }
                'No suggestions REJECTED letter transported by email',
                'Warning raised if no REJECTED letter by email';
    $unprocessed_suggestions = C4::Suggestions::GetUnprocessedSuggestions;
    is( scalar(@$unprocessed_suggestions), 0, 'GetUnprocessedSuggestions should return the suggestion if the suggestion is linked to a fund and has not been processed yet' );

    warning_is { ModSuggestion( { suggestionid => $my_suggestionid, STATUS => 'ASKED', suggesteddate => dt_from_string->add_duration( DateTime::Duration->new( days => -4 ) ) } ); }
                'No suggestions ASKED letter transported by email',
                'Warning raised if no ASKED letter by email';
    $unprocessed_suggestions = C4::Suggestions::GetUnprocessedSuggestions;
    is( scalar(@$unprocessed_suggestions), 0, 'GetUnprocessedSuggestions should use 0 as default value for days' );
    $unprocessed_suggestions = C4::Suggestions::GetUnprocessedSuggestions(4);
    is( scalar(@$unprocessed_suggestions), 1, 'GetUnprocessedSuggestions should return the suggestion suggested 4 days ago' );
    $unprocessed_suggestions = C4::Suggestions::GetUnprocessedSuggestions(3);
    is( scalar(@$unprocessed_suggestions), 0, 'GetUnprocessedSuggestions should not return the suggestion, it has not been suggested 3 days ago' );
    $unprocessed_suggestions = C4::Suggestions::GetUnprocessedSuggestions(5);
    is( scalar(@$unprocessed_suggestions), 0, 'GetUnprocessedSuggestions should not return the suggestion, it has not been suggested 5 days ago' );
};

subtest 'DelSuggestionsOlderThan' => sub {
    plan tests => 6;

    Koha::Suggestions->delete;

    # Add four suggestions; note that STATUS needs uppercase (FIXME)
    my $d1 = output_pref({ dt => dt_from_string->add(days => -2), dateformat => 'sql' });
    my $d2 = output_pref({ dt => dt_from_string->add(days => -4), dateformat => 'sql' });
    my $sugg01 = $builder->build({ source => 'Suggestion', value => { manageddate => $d1, date => $d2, STATUS => 'ASKED' }});
    my $sugg02 = $builder->build({ source => 'Suggestion', value => { manageddate => $d1, date => $d2, STATUS => 'CHECKED' }});
    my $sugg03 = $builder->build({ source => 'Suggestion', value => { manageddate => $d2, date => $d2, STATUS => 'ASKED' }});
    my $sugg04 = $builder->build({ source => 'Suggestion', value => { manageddate => $d2, date => $d2, STATUS => 'ACCEPTED' }});

    # Test no parameter: should do nothing
    C4::Suggestions::DelSuggestionsOlderThan();
    is( Koha::Suggestions->count, 4, 'No suggestions deleted' );
    # Test zero: should do nothing too
    C4::Suggestions::DelSuggestionsOlderThan(0);
    is( Koha::Suggestions->count, 4, 'No suggestions deleted again' );
    # Test negative value
    C4::Suggestions::DelSuggestionsOlderThan(-1);
    is( Koha::Suggestions->count, 4, 'No suggestions deleted for -1' );

    # Test positive values
    C4::Suggestions::DelSuggestionsOlderThan(5);
    is( Koha::Suggestions->count, 4, 'No suggestions>5d deleted' );
    C4::Suggestions::DelSuggestionsOlderThan(3);
    is( Koha::Suggestions->count, 3, '1 suggestions>3d deleted' );
    C4::Suggestions::DelSuggestionsOlderThan(1);
    is( Koha::Suggestions->count, 2, '1 suggestions>1d deleted' );
};

subtest 'EmailPurchaseSuggestions' => sub {
    plan tests => 11;

    $dbh->do(q|DELETE FROM message_queue|);

    t::lib::Mocks::mock_preference( "KohaAdminEmailAddress",
        'noreply@hosting.com' );

    # EmailPurchaseSuggestions set to disabled
    t::lib::Mocks::mock_preference( "EmailPurchaseSuggestions", "0" );
    NewSuggestion($my_suggestion);
    my $newsuggestions_messages = C4::Letters::GetQueuedMessages(
        {
            borrowernumber => $borrowernumber
        }
    );
    is( @$newsuggestions_messages, 0,
        'NewSuggestions does not send an email when disabled' );

    # EmailPurchaseSuggestions set to BranchEmailAddress
    t::lib::Mocks::mock_preference( "EmailPurchaseSuggestions",
        "BranchEmailAddress" );
    NewSuggestion($my_suggestion);

    t::lib::Mocks::mock_preference( "ReplytoDefault", 'library@b.c' );
    NewSuggestion($my_suggestion);

    Koha::Libraries->find('CPL')->update( { branchemail => 'branchemail@hosting.com' } );
    NewSuggestion($my_suggestion);

    Koha::Libraries->find('CPL')->update( { branchreplyto => 'branchemail@b.c' } );
    NewSuggestion($my_suggestion);

    $newsuggestions_messages = C4::Letters::GetQueuedMessages(
        {
            borrowernumber => $borrowernumber
        }
    );
    isnt( @$newsuggestions_messages, 0, 'NewSuggestions sends an email' );
    my $message1 =
      C4::Letters::GetMessage( $newsuggestions_messages->[0]->{message_id} );
    is( $message1->{to_address}, 'noreply@hosting.com',
'BranchEmailAddress falls back to KohaAdminEmailAddress if branchreplyto, branchemail and ReplytoDefault are not set'
    );
    my $message2 =
      C4::Letters::GetMessage( $newsuggestions_messages->[1]->{message_id} );
    is( $message2->{to_address}, 'library@b.c',
'BranchEmailAddress falls back to ReplytoDefault if neither branchreplyto or branchemail are set'
    );
    my $message3 =
      C4::Letters::GetMessage( $newsuggestions_messages->[2]->{message_id} );
    is( $message3->{to_address}, 'branchemail@hosting.com',
'BranchEmailAddress uses branchemail if branch_replto is not set'
    );
    my $message4 =
      C4::Letters::GetMessage( $newsuggestions_messages->[3]->{message_id} );
    is( $message4->{to_address}, 'branchemail@b.c',
'BranchEmailAddress uses branchreplyto in preference to branchemail when set'
    );

    # EmailPurchaseSuggestions set to KohaAdminEmailAddress
    t::lib::Mocks::mock_preference( "EmailPurchaseSuggestions",
        "KohaAdminEmailAddress" );

    t::lib::Mocks::mock_preference( "ReplytoDefault", undef );
    NewSuggestion($my_suggestion);

    t::lib::Mocks::mock_preference( "ReplytoDefault", 'library@b.c' );
    NewSuggestion($my_suggestion);

    $newsuggestions_messages = C4::Letters::GetQueuedMessages(
        {
            borrowernumber => $borrowernumber
        }
    );
    my $message5 =
      C4::Letters::GetMessage( $newsuggestions_messages->[4]->{message_id} );
    is( $message5->{to_address},
        'noreply@hosting.com', 'KohaAdminEmailAddress uses KohaAdminEmailAddress when ReplytoDefault is not set' );
    my $message6 =
      C4::Letters::GetMessage( $newsuggestions_messages->[5]->{message_id} );
    is( $message6->{to_address},
        'library@b.c', 'KohaAdminEmailAddress uses ReplytoDefualt when ReplytoDefault is set' );

    # EmailPurchaseSuggestions set to EmailAddressForSuggestions
    t::lib::Mocks::mock_preference( "EmailPurchaseSuggestions",
        "EmailAddressForSuggestions" );

    t::lib::Mocks::mock_preference( "ReplytoDefault", undef );
    NewSuggestion($my_suggestion);

    t::lib::Mocks::mock_preference( "ReplytoDefault", 'library@b.c' );
    NewSuggestion($my_suggestion);

    t::lib::Mocks::mock_preference( "EmailAddressForSuggestions",
        'suggestions@b.c' );
    NewSuggestion($my_suggestion);

    $newsuggestions_messages = C4::Letters::GetQueuedMessages(
        {
            borrowernumber => $borrowernumber
        }
    );
    my $message7 =
      C4::Letters::GetMessage( $newsuggestions_messages->[6]->{message_id} );
    is( $message7->{to_address},
        'noreply@hosting.com', 'EmailAddressForSuggestions uses KohaAdminEmailAddress when neither EmailAddressForSuggestions or ReplytoDefault are set' );

    my $message8 =
      C4::Letters::GetMessage( $newsuggestions_messages->[7]->{message_id} );
    is( $message8->{to_address},
        'library@b.c', 'EmailAddressForSuggestions uses ReplytoDefault when EmailAddressForSuggestions is not set' );

    my $message9 =
      C4::Letters::GetMessage( $newsuggestions_messages->[8]->{message_id} );
    is( $message9->{to_address},
        'suggestions@b.c', 'EmailAddressForSuggestions uses EmailAddressForSuggestions when set' );
};

subtest 'ModSuggestion should work on suggestions without a suggester' => sub {
    plan tests => 2;

    $dbh->do(q|DELETE FROM suggestions|);
    my $my_suggestionid = NewSuggestion($my_suggestion_without_suggestedby);
    $suggestion = GetSuggestion($my_suggestionid);
    is( $suggestion->{suggestedby}, undef, "Suggestedby is undef" );

    ModSuggestion(
        {
            suggestionid => $my_suggestionid,
            STATUS       => 'CHECKED',
            note         => "Test note"
        }
    );
    $suggestion = GetSuggestion($my_suggestionid);

    is( $suggestion->{note}, "Test note", "ModSuggestion works on suggestions without a suggester" );
};

subtest 'Suggestion with ISBN' => sub {
    my $suggestion_with_isbn = {
        isbn     => '1940997232',
        title    => "The Clouds",
        author   => "Aristophanes",
    };
    my $record = MarcRecordFromNewSuggestion( $suggestion_with_isbn );
    is("MARC::Record", ref($record), "MarcRecordFromNewSuggestion should return a MARC::Record object");

    my ($isbn_tag, $isbn_subfield) = C4::Biblio::GetMarcFromKohaField('biblioitems.isbn', '');
    is($record->field( $isbn_tag )->subfield( $isbn_subfield ), "1940997232", "ISBN Record from suggestion ISBN should be '1940997232'");

    my ($issn_tag, $issn_subfield) = C4::Biblio::GetMarcFromKohaField('biblioitems.issn', '');
    is($record->field( $issn_tag )->subfield( $issn_subfield ), "1940997232", "ISSN Record from suggestion ISBN should also be '1940997232'");

    my ($title_tag, $title_subfield) = C4::Biblio::GetMarcFromKohaField('biblio.title', '');
    is($record->field( $title_tag), undef, "Record from suggestion title should be empty");

    my ($author_tag, $author_subfield) = C4::Biblio::GetMarcFromKohaField('biblio.author', '');
    is($record->field( $author_tag), undef, "Record from suggestion author should be emtpy");
}

$schema->storage->txn_rollback;
