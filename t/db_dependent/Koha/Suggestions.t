#!/usr/bin/perl

# Copyright 2015-2019 Koha Development team
#
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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 11;
use Test::Exception;

use Koha::Suggestions;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string output_pref );

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder           = t::lib::TestBuilder->new;
my $biblio_1          = $builder->build_sample_biblio;
my $biblio_2          = $builder->build_sample_biblio;
my $patron            = $builder->build( { source => 'Borrower' } );
my $nb_of_suggestions = Koha::Suggestions->search->count;
my $new_suggestion_1  = Koha::Suggestion->new(
    {   suggestedby  => $patron->{borrowernumber},
        biblionumber => $biblio_1->biblionumber,
    }
)->store;
my $new_suggestion_2 = Koha::Suggestion->new(
    {   suggestedby  => $patron->{borrowernumber},
        biblionumber => $biblio_2->biblionumber,
    }
)->store;

subtest 'store' => sub {
    plan tests => 5;
    my $suggestion  = Koha::Suggestion->new(
        {   suggestedby  => $patron->{borrowernumber},
            biblionumber => $biblio_1->biblionumber,
        }
    )->store;

    is( $suggestion->suggesteddate, dt_from_string()->ymd, "If suggesteddate not passed in, it will default to today" );
    my $two_days_ago = dt_from_string->subtract( days => 2 );
    my $two_days_ago_sql = output_pref({dt => $two_days_ago, dateformat => 'sql', dateonly => 1 });
    $suggestion->suggesteddate($two_days_ago)->store;
    $suggestion = Koha::Suggestions->find( $suggestion->suggestionid );
    is( $suggestion->suggesteddate, $two_days_ago_sql, 'If suggesteddate passed in, it should be taken into account' );
    $suggestion->reason('because!')->store;
    $suggestion = Koha::Suggestions->find( $suggestion->suggestionid );
    is( $suggestion->suggesteddate, $two_days_ago_sql, 'If suggestion id modified, suggesteddate should not be modified' );

    throws_ok {
        $suggestion->STATUS('UNKNOWN')->store;
    }
    'Koha::Exceptions::Suggestion::StatusForbidden',
        'store raises an exception on invalid STATUS';

    my $authorised_value = Koha::AuthorisedValue->new(
        {
            category         => 'SUGGEST_STATUS',
            authorised_value => 'UNKNOWN'
        }
    )->store;
    $suggestion->STATUS('UNKNOWN')->store;
    is( $suggestion->STATUS, 'UNKNOWN', "UNKNOWN status stored" );
    $suggestion->delete;
};

like( $new_suggestion_1->suggestionid, qr|^\d+$|, 'Adding a new suggestion should have set the suggestionid' );
is( Koha::Suggestions->search->count, $nb_of_suggestions + 2, 'The 2 suggestions should have been added' );

my $retrieved_suggestion_1 = Koha::Suggestions->find( $new_suggestion_1->suggestionid );
is( $retrieved_suggestion_1->biblionumber, $new_suggestion_1->biblionumber, 'Find a suggestion by id should return the correct suggestion' );

$retrieved_suggestion_1->delete;
is( Koha::Suggestions->search->count, $nb_of_suggestions + 1, 'Delete should have deleted the suggestion' );

$schema->storage->txn_rollback;

subtest 'constraints' => sub {
    plan tests => 11;
    $schema->storage->txn_begin;

    my $print_error = $schema->storage->dbh->{PrintError};
    $schema->storage->dbh->{PrintError} = 0;

    my $patron = $builder->build_object( { class => "Koha::Patrons" } );
    my $biblio = $builder->build_sample_biblio();
    my $branch = $builder->build_object( { class => "Koha::Libraries" } );

    my $suggestion = $builder->build_object(
        {
            class => "Koha::Suggestions",
            value => {
                suggestedby  => $patron->borrowernumber,
                biblionumber => $biblio->biblionumber,
                branchcode   => $branch->branchcode,
                managedby    => undef,
                acceptedby   => undef,
                rejectedby   => undef,
                budgetid     => undef,
            }
        }
    );

    my $nonexistent_borrowernumber = $patron->borrowernumber;
    # suggestedby
    $patron->delete;
    $suggestion = $suggestion->get_from_storage;
    is( $suggestion->suggestedby, undef,
        "The suggestion is not deleted when the related patron is deleted" );

    # biblionumber
    $biblio->delete;
    $suggestion = $suggestion->get_from_storage;
    is( $suggestion->biblionumber, undef,
        "The suggestion is not deleted when the related biblio is deleted" );

    # branchcode
    $branch->delete;
    $suggestion = $suggestion->get_from_storage;
    is( $suggestion->branchcode, undef,
        "The suggestion is not deleted when the related branch is deleted" );

    # managerid
    {   # hide useless warnings
        local *STDERR;
        open STDERR, '>', '/dev/null';
        throws_ok {
            $suggestion->managedby($nonexistent_borrowernumber)->store;
        }
        'Koha::Exceptions::Object::FKConstraint',
          'store raises an exception on invalid managerid';
        close STDERR;
    }
    my $manager = $builder->build_object( { class => "Koha::Patrons" } );
    $suggestion->managedby( $manager->borrowernumber )->store;
    $manager->delete;
    $suggestion = $suggestion->get_from_storage;
    is( $suggestion->managedby, undef,
        "The suggestion is not deleted when the related manager is deleted" );

    # acceptedby
    {    # hide useless warnings
        local *STDERR;
        open STDERR, '>', '/dev/null';
        throws_ok {
            $suggestion->acceptedby($nonexistent_borrowernumber)->store;
        }
        'Koha::Exceptions::Object::FKConstraint',
          'store raises an exception on invalid acceptedby id';
        close STDERR;
    }
    my $acceptor = $builder->build_object( { class => "Koha::Patrons" } );
    $suggestion->acceptedby( $acceptor->borrowernumber )->store;
    $acceptor->delete;
    $suggestion = $suggestion->get_from_storage;
    is( $suggestion->acceptedby, undef,
        "The suggestion is not deleted when the related acceptor is deleted" );

    # rejectedby
    {    # hide useless warnings
        local *STDERR;
        open STDERR, '>', '/dev/null';
        throws_ok {
            $suggestion->rejectedby($nonexistent_borrowernumber)->store;
        }
        'Koha::Exceptions::Object::FKConstraint',
          'store raises an exception on invalid rejectedby id';
        close STDERR;
    }
    my $rejecter = $builder->build_object( { class => "Koha::Patrons" } );
    $suggestion->rejectedby( $rejecter->borrowernumber )->store;
    $rejecter->delete;
    $suggestion = $suggestion->get_from_storage;
    is( $suggestion->rejectedby, undef,
        "The suggestion is not deleted when the related rejecter is deleted" );

    # budgetid
    {    # hide useless warnings
        local *STDERR;
        open STDERR, '>', '/dev/null';

        throws_ok { $suggestion->budgetid($nonexistent_borrowernumber)->store; }
        'Koha::Exceptions::Object::FKConstraint',
          'store raises an exception on invalid budgetid';
        close STDERR;
    }
    my $fund = $builder->build_object( { class => "Koha::Acquisition::Funds" } );
    $suggestion->budgetid( $fund->id )->store;
    $fund->delete;
    $suggestion = $suggestion->get_from_storage;
    is( $suggestion->budgetid, undef,
        "The suggestion is not deleted when the related budget is deleted" );

    $schema->storage->dbh->{PrintError} = $print_error;
    $schema->storage->txn_rollback;
};

subtest 'manager, suggester, rejecter, last_modifier' => sub {
    plan tests => 8;
    $schema->storage->txn_begin;

    my $suggestion = $builder->build_object( { class => 'Koha::Suggestions' } );

    is( ref( $suggestion->manager ),
        'Koha::Patron',
        '->manager should have returned a Koha::Patron object' );
    is( ref( $suggestion->rejecter ),
        'Koha::Patron',
        '->rejecter should have returned a Koha::Patron object' );
    is( ref( $suggestion->suggester ),
        'Koha::Patron',
        '->suggester should have returned a Koha::Patron object' );
    is( ref( $suggestion->last_modifier ),
        'Koha::Patron',
        '->last_modifier should have returned a Koha::Patron object' );

    $suggestion->set(
        {
            managedby          => undef,
            rejectedby         => undef,
            suggestedby        => undef,
            lastmodificationby => undef
        }
    );

    is( $suggestion->manager, undef,
        '->manager should have returned undef if no manager set' );
    is( $suggestion->rejecter, undef,
        '->rejecter should have returned undef if no rejecter set' );
    is( $suggestion->suggester, undef,
        '->suggester should have returned undef if no suggester set' );
    is( $suggestion->last_modifier,
        undef,
        '->last_modifier should have returned undef if no last_modifier set' );

    $schema->storage->txn_rollback;
};

subtest 'fund' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $suggestion = $builder->build_object( { class => 'Koha::Suggestions' } );
    is( ref( $suggestion->fund ),
        'Koha::Acquisition::Fund',
        '->fund should have returned a Koha::Acquisition::Fund object' );

    $suggestion->set( { budgetid => undef } );

    is( $suggestion->fund, undef,
        '->fund should have returned undef if not fund set' );

    $schema->storage->txn_rollback;
};

subtest 'search_limited() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    # Two libraries
    my $library_1 = $builder->build_object({ class => 'Koha::Libraries' });
    my $library_2 = $builder->build_object({ class => 'Koha::Libraries' });

    # A patron from $library_1, that is not superlibrarian at all
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library_1->id, flags => 0 }
        }
    );

    # Add 3 suggestions, to be sorted by author
    my $suggestion_1 = $builder->build_object(
        {
            class => 'Koha::Suggestions',
            value => { branchcode => $library_1->id, author => 'A' }
        }
    );
    my $suggestion_2 = $builder->build_object(
        {
            class => 'Koha::Suggestions',
            value => { branchcode => $library_2->id, author => 'B' }
        }
    );
    my $suggestion_3 = $builder->build_object(
        {
            class => 'Koha::Suggestions',
            value => { branchcode => $library_2->id, author => 'C' }
        }
    );

    my $resultset = Koha::Suggestions->search(
        { branchcode => [ $library_1->id, $library_2->id ] },
        { order_by   => { -desc => ['author'] } } );

    is( $resultset->count, 3, 'Only this three suggestions are returned' );

    # Now the tests
    t::lib::Mocks::mock_userenv({ patron => $patron, branchcode => $library_1->id });

    # Disable IndependentBranches
    t::lib::Mocks::mock_preference( 'IndependentBranches', 0 );

    my $filtered_rs = $resultset->search_limited;
    is( $filtered_rs->count, 3, 'No IndependentBranches, all suggestions returned' );

    # Enable IndependentBranches
    t::lib::Mocks::mock_preference( 'IndependentBranches', 1 );

    $filtered_rs = $resultset->search_limited;

    is( $filtered_rs->count, 1, 'IndependentBranches, only suggestions from own branch returned' );

    # Make the patron superlibrarian to override IndependentBranches
    $patron->flags(1)->store;
    # So it reloads C4::Context->userenv->{flags}
    t::lib::Mocks::mock_userenv({ patron => $patron, branchcode => $library_1->id });

    $filtered_rs = $resultset->search_limited;
    is( $filtered_rs->count, 3, 'IndependentBranches but patron is superlibrarian, all suggestions returned' );

    $schema->storage->txn_rollback;
};

subtest 'filter_by_pending() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $suggestion_1 = $builder->build_object( { class => 'Koha::Suggestions', value => { STATUS => 'ASKED' } } );
    my $suggestion_2 = $builder->build_object( { class => 'Koha::Suggestions', value => { STATUS => 'ACCEPTED' } } );
    my $suggestion_3 = $builder->build_object( { class => 'Koha::Suggestions', value => { STATUS => 'ASKED' } } );

    my $suggestions =
      Koha::Suggestions->search( { suggestionid => [ $suggestion_1->id, $suggestion_2->id, $suggestion_3->id ] },
        { order_by => ['suggestionid'] } );

    is( $suggestions->count, 3 );

    my $pending     = $suggestions->filter_by_pending;
    my @pending_ids = $pending->get_column('suggestionid');

    is( $pending->count, 2 );
    is_deeply( \@pending_ids, [ $suggestion_1->id, $suggestion_3->id ] );

    $schema->storage->txn_rollback;
};

subtest 'filter_by_suggested_days_range() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $today             = dt_from_string;
    my $today_minus_two   = dt_from_string->subtract( days => 2 );
    my $today_minus_three = dt_from_string->subtract( days => 3 );

    my $dtf = Koha::Database->new->schema->storage->datetime_parser;

    my $suggestion_1 = $builder->build_object(
        { class => 'Koha::Suggestions', value => { suggesteddate => $dtf->format_date($today) } } );
    my $suggestion_2 = $builder->build_object(
        { class => 'Koha::Suggestions', value => { suggesteddate => $dtf->format_date($today_minus_two) } } );
    my $suggestion_3 = $builder->build_object(
        { class => 'Koha::Suggestions', value => { suggesteddate => $dtf->format_date($today_minus_three) } } );

    my $suggestions =
      Koha::Suggestions->search( { suggestionid => [ $suggestion_1->id, $suggestion_2->id, $suggestion_3->id ] },
        { order_by => ['suggestionid'] } );

    is( $suggestions->count, 3 );

    my $three_days = $suggestions->filter_by_suggested_days_range(3);
    is( $three_days->count, 3 );

    my $two_days = $suggestions->filter_by_suggested_days_range(2);
    is( $two_days->count, 2 );

    my $one_days = $suggestions->filter_by_suggested_days_range(1);
    is( $one_days->count, 1 );

    $schema->storage->txn_rollback;
};
