#!/usr/bin/perl

# Copyright 2015 Koha Development team
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

use Test::More tests => 6;
use Test::Exception;

use Koha::Suggestion;
use Koha::Suggestions;
use Koha::Database;
use Koha::DateUtils;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder           = t::lib::TestBuilder->new;
my $biblio_1          = $builder->build( { source => 'Biblio' } );
my $biblio_2          = $builder->build( { source => 'Biblio' } );
my $patron            = $builder->build( { source => 'Borrower' } );
my $nb_of_suggestions = Koha::Suggestions->search->count;
my $new_suggestion_1  = Koha::Suggestion->new(
    {   suggestedby  => $patron->{borrowernumber},
        biblionumber => $biblio_1->{biblionumber},
    }
)->store;
my $new_suggestion_2 = Koha::Suggestion->new(
    {   suggestedby  => $patron->{borrowernumber},
        biblionumber => $biblio_2->{biblionumber},
    }
)->store;

subtest 'store' => sub {
    plan tests => 3;
    my $suggestion  = Koha::Suggestion->new(
        {   suggestedby  => $patron->{borrowernumber},
            biblionumber => $biblio_1->{biblionumber},
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
    throws_ok { $suggestion->managedby(1029384756)->store; }
    'Koha::Exceptions::Object::FKConstraint',
      'store raises an exception on invalid managerid';
    my $manager = $builder->build_object( { class => "Koha::Patrons" } );
    $suggestion->managedby( $manager->borrowernumber )->store;
    $manager->delete;
    $suggestion = $suggestion->get_from_storage;
    is( $suggestion->managedby, undef,
        "The suggestion is not deleted when the related manager is deleted" );

    # acceptedby
    throws_ok { $suggestion->acceptedby(1029384756)->store; }
    'Koha::Exceptions::Object::FKConstraint',
      'store raises an exception on invalid acceptedby id';
    my $acceptor = $builder->build_object( { class => "Koha::Patrons" } );
    $suggestion->acceptedby( $acceptor->borrowernumber )->store;
    $acceptor->delete;
    $suggestion = $suggestion->get_from_storage;
    is( $suggestion->acceptedby, undef,
        "The suggestion is not deleted when the related acceptor is deleted" );

    # rejectedby
    throws_ok { $suggestion->rejectedby(1029384756)->store; }
    'Koha::Exceptions::Object::FKConstraint',
      'store raises an exception on invalid rejectedby id';
    my $rejecter = $builder->build_object( { class => "Koha::Patrons" } );
    $suggestion->rejectedby( $rejecter->borrowernumber )->store;
    $rejecter->delete;
    $suggestion = $suggestion->get_from_storage;
    is( $suggestion->rejectedby, undef,
        "The suggestion is not deleted when the related rejecter is deleted" );

    # budgetid
    throws_ok { $suggestion->budgetid(1029384756)->store; }
    'Koha::Exceptions::Object::FKConstraint',
      'store raises an exception on invalid budgetid';
    my $fund = $builder->build_object( { class => "Koha::Acquisition::Funds" } );
    $suggestion->budgetid( $fund->id )->store;
    $fund->delete;
    $suggestion = $suggestion->get_from_storage;
    is( $suggestion->budgetid, undef,
        "The suggestion is not deleted when the related budget is deleted" );

    $schema->storage->txn_rollback;
};
