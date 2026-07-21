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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use DateTime::Duration;
use Test::NoWarnings;
use Test::More tests => 51;
use Test::Warn;

use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Context;
use C4::Letters qw( GetQueuedMessages GetMessage );
use C4::Budgets qw( AddBudgetPeriod AddBudget GetBudget );
use Koha::Database;
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Holds;
use Koha::Libraries;
use Koha::Patrons;
use Koha::Suggestions;

BEGIN {
    use_ok(
        'C4::Suggestions',
        qw( ModSuggestion DelSuggestion MarcRecordFromNewSuggestion GetUnprocessedSuggestions )
    );
}

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh     = C4::Context->dbh;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( "EmailPurchaseSuggestions", "0" );

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
$dbh->do(q|INSERT INTO letter(module, code, content) VALUES ('suggestions', 'ORDERED', 'my content')|);
$dbh->do(
    q|INSERT INTO letter(module, code, content) VALUES ('suggestions', 'NEW_SUGGESTION', 'Content for new suggestion')|
);

# Add CPL if missing.
if ( not defined Koha::Libraries->find('CPL') ) {
    Koha::Library->new( { branchcode => 'CPL', branchname => 'Centerville' } )->store;
}

my $patron_category = $builder->build( { source => 'Category' } );

my $member = {
    firstname      => 'my firstname',
    surname        => 'my surname',
    categorycode   => $patron_category->{categorycode},
    branchcode     => 'CPL',
    smsalertnumber => 12345,
};

my $member2 = {
    firstname    => 'my firstname',
    surname      => 'my surname',
    categorycode => $patron_category->{categorycode},
    branchcode   => 'CPL',
    email        => 'to@example.com',
};

my $borrowernumber  = Koha::Patron->new($member)->store->borrowernumber;
my $borrowernumber2 = Koha::Patron->new($member2)->store->borrowernumber;

my $biblio_1      = $builder->build_object( { class => 'Koha::Biblios' } );
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
    quantity      => '',                        # Insert an empty string into int to catch strict SQL modes errors
};

my $budgetperiod_id = AddBudgetPeriod(
    {
        budget_period_startdate   => '2008-01-01',
        budget_period_enddate     => '2008-12-31',
        budget_period_description => 'MAPERI',
        budget_period_active      => 1,
    }
);

my $budget_id = AddBudget(
    {
        budget_code      => 'ABCD',
        budget_amount    => '123.132000',
        budget_name      => 'ABCD',
        budget_notes     => 'This is a note',
        budget_period_id => $budgetperiod_id,
    }
);
my $my_suggestion_with_budget = {
    title         => 'my title 2',
    author        => 'my author 2',
    publishercode => 'my publishercode 2',
    suggestedby   => $borrowernumber,
    branchcode    => '',                        # This should not fail be set to undef instead
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
    quantity      => '',                        # Insert an empty string into int to catch strict SQL modes errors
};

my $my_suggestion_object = Koha::Suggestion->new($my_suggestion)->store;
my $my_suggestionid      = $my_suggestion_object->id;
isnt( $my_suggestionid, 0, 'Suggestion is correctly saved' );
my $my_suggestion_with_budget_object = Koha::Suggestion->new($my_suggestion_with_budget)->store;
my $my_suggestionid_with_budget      = $my_suggestion_with_budget_object->id;

my $suggestion = Koha::Suggestions->find($my_suggestionid);
is( $suggestion->title,         $my_suggestion->{title},         'Suggestion stores the title correctly' );
is( $suggestion->author,        $my_suggestion->{author},        'Suggestion stores the author correctly' );
is( $suggestion->publishercode, $my_suggestion->{publishercode}, 'Suggestion stores the publishercode correctly' );
is( $suggestion->suggestedby,   $my_suggestion->{suggestedby},   'Suggestion stores the borrower number correctly' );
is( $suggestion->biblionumber,  $my_suggestion->{biblionumber},  'Suggestion stores the biblio number correctly' );
is( $suggestion->STATUS,    'ASKED', 'Suggestion stores a suggestion with the status ASKED by default' );
is( $suggestion->managedby, undef,   'Suggestion stores empty string as undef for non existent foreign key (integer)' );
is( $suggestion->manageddate, undef, 'Suggestion stores empty string as undef for date' );
is( $suggestion->budgetid,    undef, 'Suggestion should set budgetid to NULL if not given' );

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
$suggestion = Koha::Suggestions->find($my_suggestionid);
is( $suggestion->title,  $mod_suggestion1->{title},  'ModSuggestion modifies the title  correctly' );
is( $suggestion->author, $mod_suggestion1->{author}, 'ModSuggestion modifies the author correctly' );
is(
    $suggestion->publishercode, $mod_suggestion1->{publishercode},
    'ModSuggestion modifies the publishercode correctly'
);
is(
    $suggestion->managedby, undef,
    'ModSuggestion stores empty string as undef for non existent foreign key (integer)'
);
is( $suggestion->manageddate, undef, 'ModSuggestion stores empty string as undef for date' );
isnt( $suggestion->accepteddate, undef, 'ModSuggestion does not update a non given date value' );
is( $suggestion->note, 'my note', 'ModSuggestion should not erase data if not given' );

my $messages = C4::Letters::GetQueuedMessages( { borrowernumber => $borrowernumber } );
is( @$messages, 0, 'ModSuggestions does not send an email if the status is not updated' );

my $authorised_value = Koha::AuthorisedValue->new(
    {
        category         => 'SUGGEST_STATUS',
        authorised_value => 'STALLED'
    }
)->store;
my $mod_suggestion2 = {
    STATUS       => 'STALLED',
    suggestionid => $my_suggestionid,
};
warning_is { $status = ModSuggestion($mod_suggestion2) }
"No suggestions STALLED letter transported by email",
    "ModSuggestion status warning is correct";
is( $status, 1, "ModSuggestion Status OK" );

my $mod_suggestion3 = {
    STATUS       => 'CHECKED',
    suggestionid => $my_suggestionid,
};

#Test the message_transport_type of suggestion notices

#Check the message_transport_type when the 'FallbackToSMSIfNoEmail' syspref is disabled
t::lib::Mocks::mock_preference( 'FallbackToSMSIfNoEmail', 0 );
$status = ModSuggestion($mod_suggestion3);
is( $status, 1, 'ModSuggestion modifies one entry' );
$suggestion = Koha::Suggestions->find($my_suggestionid);
is( $suggestion->STATUS, $mod_suggestion3->{STATUS}, 'ModSuggestion modifies the status correctly' );
$messages = C4::Letters::GetQueuedMessages( { borrowernumber => $borrowernumber } );
is( @$messages, 1, 'ModSuggestion sends an email if the status is updated' );
is(
    $messages->[0]->{message_transport_type}, 'email',
    'When FallbackToSMSIfNoEmail syspref is disabled the suggestion message_transport_type is always email'
);

#Check the message_transport_type when the 'FallbackToSMSIfNoEmail' syspref is enabled and the borrower has a smsalertnumber and no email
t::lib::Mocks::mock_preference( 'FallbackToSMSIfNoEmail', 1 );
my $mod_suggestion3a = {
    STATUS       => 'ORDERED',
    suggestionid => $my_suggestionid,
};
ModSuggestion($mod_suggestion3a);
$messages = C4::Letters::GetQueuedMessages( { borrowernumber => $borrowernumber } );
is(
    $messages->[1]->{message_transport_type}, 'sms',
    'When FallbackToSMSIfNoEmail syspref is enabled the suggestion message_transport_type is sms if the borrower has no email'
);

#Make a new suggestion for a borrower with defined email and no smsalertnumber
my $my_suggestion_2_object = Koha::Suggestion->new($my_suggestion_with_budget2)->store();
my $my_suggestion_2_id     = $my_suggestion_2_object->id;

#Check the message_transport_type when the 'FallbackToSMSIfNoEmail' syspref is enabled and the borrower has a defined email and no smsalertnumber
t::lib::Mocks::mock_preference( 'FallbackToSMSIfNoEmail', 1 );
my $mod_suggestion4 = {
    STATUS       => 'CHECKED',
    suggestionid => $my_suggestion_2_id,
};
ModSuggestion($mod_suggestion4);
$messages = C4::Letters::GetQueuedMessages( { borrowernumber => $borrowernumber2 } );
is(
    $messages->[0]->{message_transport_type}, 'email',
    'When FallbackToSMSIfNoEmail syspref is enabled the suggestion message_transport_type is email if the borrower has an email'
);

# Check that FallbackToSMSIfNoEmail respects notice_email_address, i.e. consults
# EmailFieldPrimary / EmailFieldPrecedence rather than only borrowers.email.
# A patron with no raw email but a populated alternate field must not fall back to SMS.
my $emailpro_patron = Koha::Patron->new(
    {
        firstname      => 'Test',
        surname        => 'Emailpro',
        categorycode   => $patron_category->{categorycode},
        branchcode     => 'CPL',
        smsalertnumber => 99999,
        emailpro       => 'emailpro@example.com',
    }
)->store;
my $suggestion_for_emailpro_patron = Koha::Suggestion->new(
    {
        title        => 'emailpro suggestion',
        author       => 'test author',
        suggestedby  => $emailpro_patron->borrowernumber,
        biblionumber => $biblio_1->biblionumber,
        branchcode   => 'CPL',
        note         => 'test',
    }
)->store;

t::lib::Mocks::mock_preference( 'FallbackToSMSIfNoEmail', 1 );
t::lib::Mocks::mock_preference( 'EmailFieldPrimary',      'emailpro' );
ModSuggestion( { STATUS => 'CHECKED', suggestionid => $suggestion_for_emailpro_patron->id } );
my $emailpro_messages = C4::Letters::GetQueuedMessages( { borrowernumber => $emailpro_patron->borrowernumber } );
is(
    $emailpro_messages->[0]->{message_transport_type}, 'email',
    'FallbackToSMSIfNoEmail does not fall back to SMS when patron has emailpro set and EmailFieldPrimary=emailpro'
);

t::lib::Mocks::mock_preference( 'EmailFieldPrimary',    '' );
t::lib::Mocks::mock_preference( 'EmailFieldPrecedence', 'emailpro|email|B_email' );
ModSuggestion( { STATUS => 'ORDERED', suggestionid => $suggestion_for_emailpro_patron->id } );
$emailpro_messages = C4::Letters::GetQueuedMessages( { borrowernumber => $emailpro_patron->borrowernumber } );
is(
    $emailpro_messages->[1]->{message_transport_type}, 'email',
    'FallbackToSMSIfNoEmail does not fall back to SMS when patron has emailpro set and EmailFieldPrecedence includes emailpro'
);

# changing STATUS from ORDERED to CHECKED should generate a message
my $mod_suggestion5 = {
    STATUS       => 'CHECKED',
    suggestionid => $my_suggestionid,
};
$status   = ModSuggestion($mod_suggestion5);
$messages = C4::Letters::GetQueuedMessages( { borrowernumber => $borrowernumber } );
is( @$messages, 3, 'ModSuggestions does send a message if the status has been changed' );

# modifying suggestion without changing STATUS should not generate a message
$status   = ModSuggestion($mod_suggestion5);
$messages = C4::Letters::GetQueuedMessages( { borrowernumber => $borrowernumber } );
is( @$messages, 3, 'ModSuggestions does send a message if the status has been changed' );

$mod_suggestion4->{manageddate} = 'invalid date!';
warning_like(
    sub {
        ModSuggestion($mod_suggestion4);
    },
    qr/Invalid value/
);
$messages = C4::Letters::GetQueuedMessages( { borrowernumber => $borrowernumber2 } );

is( scalar(@$messages), 1, 'No new letter should have been generated if the update raised an error' );

my $del_suggestion = {
    title       => 'my deleted title',
    STATUS      => 'CHECKED',
    suggestedby => $borrowernumber,
};
my $del_suggestion_object = Koha::Suggestion->new($del_suggestion)->store();
my $del_suggestionid      = $del_suggestion_object->id;

is( DelSuggestion(),                '0E0', 'DelSuggestion without arguments returns 0E0' );
is( DelSuggestion($borrowernumber), '',    'DelSuggestion without the suggestion id returns an empty string' );
is(
    DelSuggestion( undef, $my_suggestionid ), '',
    'DelSuggestion with an invalid borrower number returns an empty string'
);
$suggestion = DelSuggestion( $borrowernumber, $my_suggestionid );
is( $suggestion, 1, 'DelSuggestion deletes one suggestion' );

# Test budgetid fk
$my_suggestion->{budgetid} = '';    # If budgetid == '', NULL should be set in DB
my $my_suggestionid_test_budget_object = Koha::Suggestion->new($my_suggestion)->store;
my $my_suggestionid_test_budgetid      = $my_suggestionid_test_budget_object->id;
$suggestion = Koha::Suggestions->find($my_suggestionid_test_budgetid);
is( $suggestion->budgetid, undef, 'Suggestion Should set budgetid to NULL if equals an empty string' );

$my_suggestion->{budgetid} = '';    # If budgetid == '', NULL should be set in DB
ModSuggestion($my_suggestion);
$suggestion = Koha::Suggestions->find($my_suggestionid_test_budgetid);
is( $suggestion->budgetid, undef, 'Suggestion Should set budgetid to NULL if equals an empty string' );

my $suggestion2 = {
    title    => "Cuisine d'automne",
    author   => "Catherine",
    itemtype => "LIV"
};

my $record = MarcRecordFromNewSuggestion($suggestion2);

is( "MARC::Record", ref($record), "MarcRecordFromNewSuggestion should return a MARC::Record object" );

my ( $title_tag, $title_subfield ) = C4::Biblio::GetMarcFromKohaField('biblio.title');

is(
    $record->field($title_tag)->subfield($title_subfield), "Cuisine d'automne",
    "Record from suggestion title should be 'Cuisine d'automne'"
);

my ( $author_tag, $author_subfield ) = C4::Biblio::GetMarcFromKohaField('biblio.author');

is(
    $record->field($author_tag)->subfield($author_subfield), "Catherine",
    "Record from suggestion author should be 'Catherine'"
);

subtest 'GetUnprocessedSuggestions' => sub {
    plan tests => 11;
    $dbh->do(q|DELETE FROM suggestions|);
    my $my_suggestionid         = Koha::Suggestion->new($my_suggestion)->store->id;
    my $unprocessed_suggestions = C4::Suggestions::GetUnprocessedSuggestions;
    is(
        scalar(@$unprocessed_suggestions), 0,
        'GetUnprocessedSuggestions should return 0 if a suggestion has been processed but not linked to a fund'
    );
    my $status     = ModSuggestion($mod_suggestion1);
    my $suggestion = Koha::Suggestions->find($my_suggestionid);
    is( $suggestion->budgetid, undef, 'ModSuggestion should set budgetid to NULL if not given' );
    ModSuggestion( { suggestionid => $my_suggestionid, budgetid => $budget_id } );
    $suggestion = Koha::Suggestions->find($my_suggestionid);
    is( $suggestion->budgetid, $budget_id, 'ModSuggestion should modify budgetid if given' );

    $unprocessed_suggestions = C4::Suggestions::GetUnprocessedSuggestions;
    is(
        scalar(@$unprocessed_suggestions), 1,
        'GetUnprocessedSuggestions should return the suggestion if the suggestion is linked to a fund and has not been processed yet'
    );

    warning_is { ModSuggestion( { suggestionid => $my_suggestionid, STATUS => 'REJECTED' } ) }
    'No suggestions REJECTED letter transported by email',
        'Warning raised if no REJECTED letter by email';
    $unprocessed_suggestions = C4::Suggestions::GetUnprocessedSuggestions;
    is(
        scalar(@$unprocessed_suggestions), 0,
        'GetUnprocessedSuggestions should return the suggestion if the suggestion is linked to a fund and has not been processed yet'
    );

    warning_is {
        ModSuggestion(
            {
                suggestionid  => $my_suggestionid, STATUS => 'ASKED',
                suggesteddate => dt_from_string->add_duration( DateTime::Duration->new( days => -4 ) )
            }
        );
    }
    'No suggestions ASKED letter transported by email',
        'Warning raised if no ASKED letter by email';
    $unprocessed_suggestions = C4::Suggestions::GetUnprocessedSuggestions;
    is( scalar(@$unprocessed_suggestions), 0, 'GetUnprocessedSuggestions should use 0 as default value for days' );
    $unprocessed_suggestions = C4::Suggestions::GetUnprocessedSuggestions(4);
    is(
        scalar(@$unprocessed_suggestions), 1,
        'GetUnprocessedSuggestions should return the suggestion suggested 4 days ago'
    );
    $unprocessed_suggestions = C4::Suggestions::GetUnprocessedSuggestions(3);
    is(
        scalar(@$unprocessed_suggestions), 0,
        'GetUnprocessedSuggestions should not return the suggestion, it has not been suggested 3 days ago'
    );
    $unprocessed_suggestions = C4::Suggestions::GetUnprocessedSuggestions(5);
    is(
        scalar(@$unprocessed_suggestions), 0,
        'GetUnprocessedSuggestions should not return the suggestion, it has not been suggested 5 days ago'
    );
};

subtest 'EmailPurchaseSuggestions' => sub {
    plan tests => 13;

    $dbh->do(q|DELETE FROM message_queue|);

    t::lib::Mocks::mock_preference(
        "KohaAdminEmailAddress",
        'noreply@hosting.com'
    );

    # EmailPurchaseSuggestions set to disabled
    t::lib::Mocks::mock_preference( "EmailPurchaseSuggestions", "0" );
    Koha::Suggestion->new($my_suggestion)->store;
    my $newsuggestions_messages = C4::Letters::GetQueuedMessages( { letter_code => 'NEW_SUGGESTION' } );
    is(
        @$newsuggestions_messages, 0,
        'New suggestion does not send an email when EmailPurchaseSuggestions disabled'
    );

    # EmailPurchaseSuggestions set to BranchEmailAddress
    t::lib::Mocks::mock_preference( "EmailPurchaseSuggestions",   "BranchEmailAddress" );
    t::lib::Mocks::mock_preference( "ReplytoDefault",             "" );
    t::lib::Mocks::mock_preference( "EmailAddressForSuggestions", "" );
    Koha::Libraries->find('CPL')->update( { branchemail => '', branchreplyto => '' } );
    Koha::Suggestion->new($my_suggestion)->store;

    t::lib::Mocks::mock_preference( "ReplytoDefault", 'library@b.c' );
    Koha::Suggestion->new($my_suggestion)->store;

    Koha::Libraries->find('CPL')->update( { branchemail => 'branchemail@hosting.com' } );
    Koha::Suggestion->new($my_suggestion)->store;

    Koha::Libraries->find('CPL')->update( { branchreplyto => 'branchemail@b.c' } );
    Koha::Suggestion->new($my_suggestion)->store;

    $newsuggestions_messages = C4::Letters::GetQueuedMessages( { letter_code => 'NEW_SUGGESTION' } );
    isnt( @$newsuggestions_messages, 0, 'New suggestions sends an email wne EmailPurchaseSuggestions enabled' );
    my $message1 =
        C4::Letters::GetMessage( $newsuggestions_messages->[0]->{message_id} );
    is(
        $message1->{to_address}, 'noreply@hosting.com',
        'BranchEmailAddress falls back to KohaAdminEmailAddress if branchreplyto, branchemail and ReplytoDefault are not set'
    );
    my $message2 =
        C4::Letters::GetMessage( $newsuggestions_messages->[1]->{message_id} );
    is(
        $message2->{to_address}, 'library@b.c',
        'BranchEmailAddress falls back to ReplytoDefault if neither branchreplyto or branchemail are set'
    );
    my $message3 =
        C4::Letters::GetMessage( $newsuggestions_messages->[2]->{message_id} );
    is(
        $message3->{to_address}, 'branchemail@hosting.com',
        'BranchEmailAddress uses branchemail if branch_replto is not set'
    );
    my $message4 =
        C4::Letters::GetMessage( $newsuggestions_messages->[3]->{message_id} );
    is(
        $message4->{to_address}, 'branchemail@b.c',
        'BranchEmailAddress uses branchreplyto in preference to branchemail when set'
    );

    my $branchless_suggestion = { %{$my_suggestion}, branchcode => undef };
    t::lib::Mocks::mock_preference( "ReplytoDefault", undef );

    # must eval to test itself dying, then check $@ for error
    eval { Koha::Suggestion->new($branchless_suggestion)->store; };
    is( $@, '', 'BranchEmailAddress does not die when suggestion has no library branch' );

    $newsuggestions_messages = C4::Letters::GetQueuedMessages( { letter_code => 'NEW_SUGGESTION' } );
    my $message_branchless =
        C4::Letters::GetMessage( $newsuggestions_messages->[4]->{message_id} );
    is(
        $message_branchless->{to_address}, undef,
        'BranchEmailAddress sets no to_address when suggestion has no branch'
    );

    # EmailPurchaseSuggestions set to KohaAdminEmailAddress
    t::lib::Mocks::mock_preference(
        "EmailPurchaseSuggestions",
        "KohaAdminEmailAddress"
    );

    t::lib::Mocks::mock_preference( "ReplytoDefault", undef );
    Koha::Suggestion->new($my_suggestion)->store;

    t::lib::Mocks::mock_preference( "ReplytoDefault", 'library@b.c' );
    Koha::Suggestion->new($my_suggestion)->store;

    $newsuggestions_messages = C4::Letters::GetQueuedMessages( { letter_code => 'NEW_SUGGESTION' } );
    my $message5 =
        C4::Letters::GetMessage( $newsuggestions_messages->[5]->{message_id} );
    is(
        $message5->{to_address},
        'noreply@hosting.com', 'KohaAdminEmailAddress uses KohaAdminEmailAddress when ReplytoDefault is not set'
    );
    my $message6 =
        C4::Letters::GetMessage( $newsuggestions_messages->[6]->{message_id} );
    is(
        $message6->{to_address},
        'library@b.c', 'KohaAdminEmailAddress uses ReplytoDefualt when ReplytoDefault is set'
    );

    # EmailPurchaseSuggestions set to EmailAddressForSuggestions
    t::lib::Mocks::mock_preference(
        "EmailPurchaseSuggestions",
        "EmailAddressForSuggestions"
    );

    t::lib::Mocks::mock_preference( "ReplytoDefault", undef );
    Koha::Suggestion->new($my_suggestion)->store;

    t::lib::Mocks::mock_preference( "ReplytoDefault", 'library@b.c' );
    Koha::Suggestion->new($my_suggestion)->store;

    t::lib::Mocks::mock_preference(
        "EmailAddressForSuggestions",
        'suggestions@b.c'
    );
    Koha::Suggestion->new($my_suggestion)->store;

    $newsuggestions_messages = C4::Letters::GetQueuedMessages( { letter_code => 'NEW_SUGGESTION' } );
    my $message7 =
        C4::Letters::GetMessage( $newsuggestions_messages->[7]->{message_id} );
    is(
        $message7->{to_address},
        'noreply@hosting.com',
        'EmailAddressForSuggestions uses KohaAdminEmailAddress when neither EmailAddressForSuggestions or ReplytoDefault are set'
    );

    my $message8 =
        C4::Letters::GetMessage( $newsuggestions_messages->[8]->{message_id} );
    is(
        $message8->{to_address},
        'library@b.c', 'EmailAddressForSuggestions uses ReplytoDefault when EmailAddressForSuggestions is not set'
    );

    my $message9 =
        C4::Letters::GetMessage( $newsuggestions_messages->[9]->{message_id} );
    is(
        $message9->{to_address},
        'suggestions@b.c', 'EmailAddressForSuggestions uses EmailAddressForSuggestions when set'
    );
};

subtest 'ModSuggestion should work on suggestions without a suggester' => sub {
    plan tests => 2;

    $dbh->do(q|DELETE FROM suggestions|);
    my $my_suggestionid = Koha::Suggestion->new($my_suggestion_without_suggestedby)->store()->id;
    $suggestion = Koha::Suggestions->find($my_suggestionid);
    is( $suggestion->suggestedby, undef, "Suggestedby is undef" );

    ModSuggestion(
        {
            suggestionid => $my_suggestionid,
            STATUS       => 'CHECKED',
            note         => "Test note"
        }
    );
    $suggestion = Koha::Suggestions->find($my_suggestionid);

    is( $suggestion->note, "Test note", "ModSuggestion works on suggestions without a suggester" );
};

subtest 'place_hold tests' => sub {
    plan tests => 4;

    t::lib::Mocks::mock_preference( "PlaceHoldsOnOrdersFromSuggestions", "0" );

    my $biblio     = $builder->build_sample_biblio();
    my $patron     = $builder->build_object( { class => 'Koha::Patrons' } );
    my $suggestion = $builder->build_object(
        {
            class => 'Koha::Suggestions',
            value => {
                branchcode   => $patron->branchcode,
                biblionumber => undef,
                suggestedby  => $patron->id
            }
        }
    );

    my $hold_id = $suggestion->place_hold();
    is( $hold_id, undef, "No suggestion placed when preference is disabled" );

    t::lib::Mocks::mock_preference( "PlaceHoldsOnOrdersFromSuggestions", "1" );

    $hold_id = $suggestion->place_hold();
    is(
        $hold_id, undef,
        "No suggestion placed when preference is enabled and suggestion does not have a biblionumber"
    );

    $suggestion->biblionumber( $biblio->id )->store();
    $suggestion->discard_changes();

    $hold_id = $suggestion->place_hold();
    ok( $hold_id, "Suggestion placed when preference is enabled and suggestion does have a biblionumber" );

    my $hold = Koha::Holds->find($hold_id);
    $hold->delete();

    t::lib::Mocks::mock_preference( "PlaceHoldsOnOrdersFromSuggestions", "0" );

    $hold_id = $suggestion->place_hold();
    is( $hold_id, undef, "Suggestion not placed when preference is disabled and suggestion does have a biblionumber" );

};

subtest 'Suggestion with ISBN' => sub {
    my $suggestion_with_isbn = {
        isbn   => '1940997232',
        title  => "The Clouds",
        author => "Aristophanes",
    };
    my $record = MarcRecordFromNewSuggestion($suggestion_with_isbn);
    is( "MARC::Record", ref($record), "MarcRecordFromNewSuggestion should return a MARC::Record object" );

    my ( $isbn_tag, $isbn_subfield ) = C4::Biblio::GetMarcFromKohaField('biblioitems.isbn');
    is(
        $record->field($isbn_tag)->subfield($isbn_subfield), "1940997232",
        "ISBN Record from suggestion ISBN should be '1940997232'"
    );

    my ( $issn_tag, $issn_subfield ) = C4::Biblio::GetMarcFromKohaField('biblioitems.issn');
    is(
        $record->field($issn_tag)->subfield($issn_subfield), "1940997232",
        "ISSN Record from suggestion ISBN should also be '1940997232'"
    );

    my ( $title_tag, $title_subfield ) = C4::Biblio::GetMarcFromKohaField('biblio.title');
    is( $record->field($title_tag), undef, "Record from suggestion title should be empty" );

    my ( $author_tag, $author_subfield ) = C4::Biblio::GetMarcFromKohaField('biblio.author');
    is( $record->field($author_tag), undef, "Record from suggestion author should be empty" );
};

$schema->storage->txn_rollback;
