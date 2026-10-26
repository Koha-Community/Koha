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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 17;

use C4::Context;
use Koha::ActionLogs;
use Koha::Patron::Message;
use Koha::Patron::Messages;
use Koha::Patrons;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder         = t::lib::TestBuilder->new;
my $library         = $builder->build( { source => 'Branch' } );
my $patron          = $builder->build( { source => 'Borrower', value => { branchcode => $library->{branchcode} } } );
my $patron_2        = $builder->build( { source => 'Borrower' } );
my $patron_3        = $builder->build( { source => 'Borrower' } );
my $nb_of_logaction = get_nb_of_logactions();
my $nb_of_messages  = Koha::Patron::Messages->search->count;

t::lib::Mocks::mock_preference( 'BorrowersLog', 0 );
my $new_message_1 = Koha::Patron::Message->new(
    {
        borrowernumber => $patron->{borrowernumber},
        branchcode     => $library->{branchcode},
        message_type   => 'L',
        message        => 'my message 1',
    }
)->store;
is( get_nb_of_logactions(), $nb_of_logaction, 'With BorrowersLog off, no new log should have been added' );

my $context = Test::MockModule->new('C4::Context');
$context->mock(
    'userenv',
    sub {
        return {
            number => $patron_2->{borrowernumber},
        };
    }
);

t::lib::Mocks::mock_preference( 'BorrowersLog', 1 );
my $new_message_2 = Koha::Patron::Message->new(
    {
        borrowernumber => $patron->{borrowernumber},
        branchcode     => $library->{branchcode},
        message_type   => 'B',
        message        => 'my message 2',
    }
)->store;

my $new_message_3 = Koha::Patron::Message->new(
    {
        borrowernumber => $patron->{borrowernumber},
        branchcode     => $library->{branchcode},
        message_type   => 'B',
        message        => 'my message 2',
        manager_id     => $patron_3->{borrowernumber},
    }
)->store;
is(
    get_nb_of_logactions(), $nb_of_logaction + 2,
    'With BorrowersLog on, 2 new log should have been added when adding a new message'
);

like( $new_message_1->message_id, qr|^\d+$|, 'Adding a new message should have set the message_id' );
is( Koha::Patron::Messages->search->count, $nb_of_messages + 3, 'The 3 messages should have been added' );

my $retrieved_message_1 = Koha::Patron::Messages->find( $new_message_1->message_id );
is( $retrieved_message_1->message, $new_message_1->message, 'Find a message by id should return the correct message' );
is( $retrieved_message_1->manager_id, undef, 'Manager id should not be filled in when it is not defined in userenv' );
my $retrieved_message_2 = Koha::Patron::Messages->find( $new_message_2->message_id );
is(
    $retrieved_message_2->manager_id, $patron_2->{borrowernumber},
    'Manager id should be filled in when it is defined in userenv'
);
my $retrieved_message_3 = Koha::Patron::Messages->find( $new_message_3->message_id );
is(
    $retrieved_message_3->manager_id, $patron_3->{borrowernumber},
    'Manager id should be overwrite-able even if defined in userenv'
);

t::lib::Mocks::mock_preference( 'BorrowersLog', 0 );
$retrieved_message_1->delete;
is( Koha::Patron::Messages->search->count, $nb_of_messages + 2, 'Delete should have deleted the message 1' );
is(
    get_nb_of_logactions(), $nb_of_logaction + 2,
    'With BorrowersLog off, no new log should have been added when deleting a new message'
);

t::lib::Mocks::mock_preference( 'BorrowersLog', 1 );
$new_message_2->delete;
is( Koha::Patron::Messages->search->count, $nb_of_messages + 1, 'Delete should have deleted the message 2' );
is(
    get_nb_of_logactions(), $nb_of_logaction + 3,
    'With BorrowersLog on, 1 new log should have been added when deleting a new message'
);

my $new_message_4 = Koha::Patron::Message->new(
    {
        borrowernumber => $patron->{borrowernumber},
        branchcode     => $library->{branchcode},
        message_type   => 'B',
        message        => 'my message 2',
        manager_id     => $patron_3->{borrowernumber},
    }
)->store;
my $patron_obj             = Koha::Patrons->find( $patron->{borrowernumber} );
my $current_messages_count = $patron_obj->messages->count;
is( $patron_obj->messages->filter_by_unread->count, $current_messages_count, "No messages have been marked as read" );
$new_message_4->update( { patron_read_date => dt_from_string } );
is(
    $patron_obj->messages->filter_by_unread->count, $current_messages_count - 1,
    "One message has been marked as read"
);

subtest 'message_without_newlines' => sub {
    plan tests => 6;

    my $message = Koha::Patron::Message->new( { message => "  Line 1\nLine 2\r\nLine 3 \n  " } );

    is(
        $message->message_without_newlines, 'Line 1 Line 2 Line 3',
        'Newlines and carriage returns removed, collapsed and trimmed'
    );

    $message->message("Multiple    spaces     stay collapsed");
    is( $message->message_without_newlines, 'Multiple spaces stay collapsed', 'Multiple spaces collapsed' );

    $message->message("\n\nOnly\nNewlines\n\n");
    is( $message->message_without_newlines, 'Only Newlines', 'Only newlines handled correctly' );

    $message->message("Already clean");
    is( $message->message_without_newlines, 'Already clean', 'Clean string returns as is' );

    $message->message(q{});
    is( $message->message_without_newlines, undef, 'Empty string returns undef' );

    $message->message(undef);
    is( $message->message_without_newlines, undef, 'Undef message returns undef' );
};

subtest 'search_limited() tests' => sub {

    plan tests => 4;

    # restore the real userenv, mocked at file level
    $context->unmock('userenv');

    my $library       = $builder->build_object( { class => 'Koha::Libraries' } );
    my $other_library = $builder->build_object( { class => 'Koha::Libraries' } );

    my $group = $builder->build_object(
        {
            class => 'Koha::Library::Groups',
            value => { ft_hide_patron_info => 1, branchcode => undef, parent_id => undef }
        }
    );
    $builder->build_object(
        {
            class => 'Koha::Library::Groups',
            value => { parent_id => $group->id, branchcode => $library->id }
        }
    );

    my $librarian =
        $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0, branchcode => $library->id } } );

    my $visible_patron =
        $builder->build_object( { class => 'Koha::Patrons', value => { branchcode => $library->id } } );
    my $hidden_patron =
        $builder->build_object( { class => 'Koha::Patrons', value => { branchcode => $other_library->id } } );

    my $visible_message = $builder->build_object(
        { class => 'Koha::Patron::Messages', value => { borrowernumber => $visible_patron->id, message_type => 'L' } }
    );
    my $visible_b_message = $builder->build_object(
        { class => 'Koha::Patron::Messages', value => { borrowernumber => $visible_patron->id, message_type => 'B' } }
    );
    my $hidden_message = $builder->build_object(
        { class => 'Koha::Patron::Messages', value => { borrowernumber => $hidden_patron->id, message_type => 'L' } } );

    my $filter = { 'me.message_id' => [ $visible_message->id, $visible_b_message->id, $hidden_message->id ] };

    C4::Context->unset_userenv;
    is( Koha::Patron::Messages->search_limited( {%$filter} )->count, 3, 'No logged in user, no restrictions' );

    t::lib::Mocks::mock_userenv( { patron => $librarian } );
    is_deeply(
        [ sort map { $_->id } Koha::Patron::Messages->search_limited( {%$filter} )->as_list ],
        [ sort ( $visible_message->id, $visible_b_message->id ) ],
        'Only messages for visible patrons returned'
    );
    is(
        Koha::Patron::Messages->search_limited( { %$filter, message_type => 'L' } )->next->id,
        $visible_message->id, 'Passed parameters are honored'
    );

    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $librarian->id,
                module_bit     => 4,
                code           => 'view_borrower_infos_from_any_libraries',
            },
        }
    );
    is(
        Koha::Patron::Messages->search_limited( {%$filter} )->count, 3,
        'view_borrower_infos_from_any_libraries lifts the restriction'
    );
};

$schema->storage->txn_rollback;

sub get_nb_of_logactions {
    return Koha::ActionLogs->search( { module => 'MEMBERS' } )->count;
}

