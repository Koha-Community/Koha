#!/usr/bin/perl

# Copyright 2018 Koha-Suomi Oy
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

use Test::More;
use Test::MockModule;

use t::lib::TestBuilder;
use Koha::Database;

my (
    $conn, $testdb, $server_version, $server_type, $coll_users, $coll_user_logs,
    $mocked_config
);
eval {
    $conn = t::lib::MongoDBTest::build_client();
    $testdb = t::lib::MongoDBTest::get_test_db($conn);
    $server_version = t::lib::MongoDBTest::server_version($conn);
    $server_type = t::lib::MongoDBTest::server_type($conn);
    $coll_users = $testdb->get_collection('users');
    $coll_user_logs = $testdb->get_collection('user_logs');
    $mocked_config = mock_db($conn, $testdb);
};
if($@) {
    plan skip_all => 'This test requires mongodb-server package';
    done_testing();
}
else {
    plan tests => 3;
}

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

use_ok('Koha::MongoDB');

subtest 'Koha::MongoDB initialization' => sub {
    plan tests => 2;

    my $mongo = Koha::MongoDB->new;
    is(ref($mongo), 'Koha::MongoDB', 'Got instance of Koha::MongoDB');
    ok($mongo->can('push_action_logs'), 'push_action_logs method available');
};

subtest 'test push_action_logs()' => sub {
    plan tests => 8;

    $schema->storage->txn_begin;

    my $amnt_borrowers = 10;
    my $amnt_action_logs = 20;
    my $mongo = Koha::MongoDB->new();
    my $client = $mongo->{client};
    my $settings = $mongo->{settings};
    my $mongologs = $client->ns($settings->{database}.'.user_logs');

    generate_test_data($amnt_borrowers, $amnt_action_logs);

    my $logs = new Koha::MongoDB::Logs;
    my $users = new Koha::MongoDB::Users;

    is(@{$logs->getActionCacheLogs}, $amnt_action_logs,
       'Koha: Action logs cache populated');

    subtest 'test $limit' => sub {
        plan tests => 2;

        my $mongo = Koha::MongoDB->new;

        is($mongo->push_action_logs($mongologs, 1000, 3), 1, 'Executed push_action_logs');
        is($coll_user_logs->count(), 0,
       'MongoDB: Did not receive any rows yet due to higher limit');
    };


    is($mongo->push_action_logs($mongologs), 1, 'Koha to MongoDB: Great success');

    my $mongo_user_count = $coll_users->count();
    ok($mongo_user_count >= 1, 'MongoDB: More than one user');
    is($coll_user_logs->count(), $amnt_action_logs,
       'MongoDB: Correct number of action logs');

    is(@{$logs->getActionCacheLogs}, 0,
       'Koha: Action logs cache cleared');

    subtest 'test users collection' => sub {
        plan tests => $mongo_user_count;

        my $mongo_users = $coll_users->find();
        while (my $doc = $mongo_users->next) {
            my $borrno = $doc->{borrowernumber};
            my $found_user = $users->checkUser($borrno);
            is($found_user->{borrowernumber}, $borrno, "Found user $borrno");
        }
    };

    subtest 'test user_logs collection' => sub {
        plan tests => 5;
        my $real_patron_found = 0;
        my $at_least_one_patron_not_found = 0;
        my $ok_sourceusers = 1;
        my $ok_objectusers = 1;
        my $ok_cardnumbers = 1;
        my $mongo_logs = $coll_user_logs->find();
        while (my $doc = $mongo_logs->next) {
            if ($doc->{objectborrowernumber} == 0)
            {
                $at_least_one_patron_not_found = 1;
            }
            if ($doc->{objectborrowernumber} > 0) {
                $real_patron_found = 1;
            }
            unless ($coll_users->count({ '_id' => $doc->{sourceuser} }) == 1) {
                $ok_sourceusers = Data::Dumper::Dumper($doc->{sourceuser});
            }
            unless ($coll_users->count({ '_id' => $doc->{objectuser} }) == 1) {
                $ok_objectusers = Data::Dumper::Dumper($doc->{sourceuser});
            }
            unless (defined $doc->{objectcardnumber}) {
                $ok_cardnumbers = 0;
            }
        }
        is($ok_sourceusers, 1, 'Found all sourceusers');
        is($ok_objectusers, 1, 'Found all objectusers');
        is($ok_cardnumbers, 1, 'All objectusers have cardnumbers defined');
        is($real_patron_found, 1, 'At least one real patron found');
        is($at_least_one_patron_not_found, 1, 'At least one patron not found');
    };

    $schema->storage->txn_rollback;
};

sub generate_test_data {
    my ($amnt_borrowers, $amnt_actionlogs) = @_;
    my @borrnos = (-1);
    for (1..$amnt_borrowers-1) {
        push @borrnos,
            $builder->build({ source => 'Borrower' })->{borrowernumber};
    }
    for (1..$amnt_actionlogs-2) {
        $builder->build({ source => 'ActionLogsCache', value => {
            user => $borrnos[ rand @borrnos ],
            object => $borrnos[ rand @borrnos ],
        }});
    }
    # Build at least one action log with user that cannot be found
    $builder->build({ source => 'ActionLogsCache', value => {
        user => -1,
        object => -1,
    }});
    # Build at least one action log with user that can be found
    $builder->build({ source => 'ActionLogsCache', value => {
        user => $borrnos[1],
        object => $borrnos[1],
    }});
}

sub mock_db {
    my ($conn, $testdb) = @_;
    my $mock = Test::MockModule->new('Koha::MongoDB::Config');
    my $client = $conn;
    $mock->mock('mongoClient', sub {
        return $client;
    });
    $mock->mock('getSettings', sub {
        return {
            database => $testdb->name
        };
    });
    return $mock;
}

1;
