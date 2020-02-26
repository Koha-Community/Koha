#!/usr/bin/perl

# Copyright 2017 Koha-Suomi Oy
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

use Test::More tests => 7;

use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Context;

use Koha::Notice::Templates;
use Koha::Patron::Categories;
use Koha::Patron::Message::Attributes;
use Koha::Patron::Message::Transport::Types;
use Koha::Patron::Message::Transports;
use Koha::Patrons;

use File::Temp qw/tempfile/;
use Log::Log4perl;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'Test class imports' => sub {
    plan tests => 2;

    use_ok('Koha::Patron::Message::Preference');
    use_ok('Koha::Patron::Message::Preferences');
};

subtest 'Test Koha::Patron::Message::Preferences' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $attribute = $builder->build_object({ class => 'Koha::Patron::Message::Attributes' });
    my $letter = build_a_test_letter();
    my $mtt = $builder->build_object({ class => 'Koha::Patron::Message::Transport::Types' });
    Koha::Patron::Message::Transport->new({
        message_attribute_id   => $attribute->message_attribute_id,
        message_transport_type => $mtt->message_transport_type,
        is_digest              => 0,
        letter_module          => $letter->module,
        letter_code            => $letter->code,
    })->store;

    subtest 'Test for a patron' => sub {
        plan tests => 3;

        my $patron = $builder->build_object({ class => 'Koha::Patrons' });
        Koha::Patron::Message::Preference->new({
            borrowernumber       => $patron->borrowernumber,
            message_attribute_id => $attribute->message_attribute_id,
            wants_digest         => 0,
            days_in_advance      => undef,
        })->store;

        my $preference = Koha::Patron::Message::Preferences->find({
            borrowernumber       => $patron->borrowernumber,
            message_attribute_id => $attribute->message_attribute_id
        });
        ok($preference->borrower_message_preference_id > 0,
           'Added a new messaging preference for patron.');

        subtest 'Test set not throwing an exception on duplicate object' => sub {
            plan tests => 1;

            Koha::Patron::Message::Attributes->find({
                message_attribute_id => $attribute->message_attribute_id
            })->set({ takes_days => 1 })->store;
            $preference->set({ days_in_advance => 1 })->store;
            is(ref($preference), 'Koha::Patron::Message::Preference',
             'Updating the preference does not cause duplicate object exception');
        };

        $preference->delete;
        is(Koha::Patron::Message::Preferences->search({
            borrowernumber       => $patron->borrowernumber,
            message_attribute_id => $attribute->message_attribute_id
        })->count, 0, 'Deleted the messaging preference.');
    };

    subtest 'Test for a category' => sub {
        my $category = $builder->build_object({ class => 'Koha::Patron::Categories' });
        Koha::Patron::Message::Preference->new({
            categorycode         => $category->categorycode,
            message_attribute_id => $attribute->message_attribute_id,
            wants_digest         => 0,
            days_in_advance      => undef,
        })->store;

        my $preference = Koha::Patron::Message::Preferences->find({
            categorycode         => $category->categorycode,
            message_attribute_id => $attribute->message_attribute_id
        });
        ok($preference->borrower_message_preference_id > 0,
           'Added a new messaging preference for category.');

        $preference->delete;
        is(Koha::Patron::Message::Preferences->search({
            categorycode         => $category->categorycode,
            message_attribute_id => $attribute->message_attribute_id
        })->count, 0, 'Deleted the messaging preference.');
    };

    $schema->storage->txn_rollback;
};

subtest 'Test Koha::Patron::Message::Preferences->get_options' => sub {
    plan tests => 2;

    subtest 'Test method availability and return value' => sub {
        plan tests => 3;

        ok(Koha::Patron::Message::Preferences->can('get_options'),
            'Method get_options is available.');
        ok(my $options = Koha::Patron::Message::Preferences->get_options,
            'Called get_options successfully.');
        is(ref($options), 'ARRAY', 'get_options returns a ARRAYref');
    };

    subtest 'Make sure options are correct' => sub {
        $schema->storage->txn_begin;
        my $options = Koha::Patron::Message::Preferences->get_options;

        foreach my $option (@$options) {
            my $n = $option->{'message_name'};
            my $attr = Koha::Patron::Message::Attributes->find($option->{'message_attribute_id'});
            is($option->{'message_attribute_id'}, $attr->message_attribute_id,
               '$n: message_attribute_id is set');
            is($option->{'message_name'}, $attr->message_name, '$n: message_name is set');
            is($option->{'takes_days'}, $attr->takes_days, '$n: takes_days is set');
            my $transports = Koha::Patron::Message::Transports->search({
                message_attribute_id => $option->{'message_attribute_id'},
                is_digest => $option->{'has_digest'} || 0,
            });
            while (my $trnzport = $transports->next) {
                is($option->{'has_digest'} || 0, $trnzport->is_digest, '$n: has_digest is set for '.$trnzport->message_transport_type);
                is($option->{'transport_'.$trnzport->message_transport_type}, ' ', '$n: transport_'.$trnzport->message_transport_type.' is set');
            }
        }

        $schema->storage->txn_rollback;
    };
};

subtest 'Add preferences from defaults' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object({ class => 'Koha::Patrons' });
    my ($default, $mtt1, $mtt2) = build_a_test_category_preference({
        patron => $patron,
    });
    ok(Koha::Patron::Message::Preference->new_from_default({
        borrowernumber       => $patron->borrowernumber,
        categorycode         => $patron->categorycode,
        message_attribute_id => $default->message_attribute_id,
    })->store, 'Added a default preference to patron.');
    ok(my $pref = Koha::Patron::Message::Preferences->find({
        borrowernumber       => $patron->borrowernumber,
        message_attribute_id => $default->message_attribute_id,
    }), 'Found the default preference from patron.');
    is(Koha::Patron::Message::Transport::Preferences->search({
        borrower_message_preference_id => $pref->borrower_message_preference_id
    })->count, 2, 'Found the two transport types that we set earlier');

    $schema->storage->txn_rollback;
};

subtest 'Test Koha::Patron::Message::Preference->message_transport_types' => sub {
    plan tests => 4;

    ok(Koha::Patron::Message::Preference->can('message_transport_types'),
       'Method message_transport_types available');

    subtest 'get message_transport_types' => sub {
        plan tests => 5;

        $schema->storage->txn_begin;

        my $patron = $builder->build_object({ class => 'Koha::Patrons' });
        my ($preference, $mtt1, $mtt2) = build_a_test_complete_preference({
            patron => $patron
        });
        Koha::Patron::Message::Transport::Preferences->search({
            borrower_message_preference_id => $preference->borrower_message_preference_id,
        })->delete;
        Koha::Patron::Message::Transport::Preference->new({
            borrower_message_preference_id => $preference->borrower_message_preference_id,
            message_transport_type => $mtt1->message_transport_type,
        })->store;
        Koha::Patron::Message::Transport::Preference->new({
            borrower_message_preference_id => $preference->borrower_message_preference_id,
            message_transport_type => $mtt2->message_transport_type,
        })->store;
        my $stored_transports = Koha::Patron::Message::Transport::Preferences->search({
            borrower_message_preference_id => $preference->borrower_message_preference_id,
        });
        my $transport1 = Koha::Patron::Message::Transports->find({
            message_attribute_id => $preference->message_attribute_id,
            message_transport_type => $mtt1->message_transport_type,
        });
        my $transport2 = Koha::Patron::Message::Transports->find({
            message_attribute_id => $preference->message_attribute_id,
            message_transport_type => $mtt2->message_transport_type,
        });
        my $transports = $preference->message_transport_types;
        is(keys %{$transports}, $stored_transports->count,
           '->message_transport_types gets correct amount of transport types.');
        is($transports->{$stored_transports->next->message_transport_type},
           $transport1->letter_code, 'Found correct message transport type and letter code.');
        is($transports->{$stored_transports->next->message_transport_type},
           $transport2->letter_code, 'Found correct message transport type and letter code.');
        ok(!$preference->message_transport_types->{'nonexistent'},
           'Didn\'t find nonexistent transport type.');

        subtest 'test logging of warnings by invalid message transport type' => sub {
            plan tests => 2;

            my $log = mytempfile();
            my $conf = mytempfile( <<"HERE"
log4perl.logger.opac = WARN, OPAC
log4perl.appender.OPAC=Log::Log4perl::Appender::TestBuffer
log4perl.appender.OPAC.filename=$log
log4perl.appender.OPAC.mode=append
log4perl.appender.OPAC.layout=SimpleLayout
log4perl.logger.intranet = WARN, INTRANET
log4perl.appender.INTRANET=Log::Log4perl::Appender::TestBuffer
log4perl.appender.INTRANET.filename=$log
log4perl.appender.INTRANET.mode=append
log4perl.appender.INTRANET.layout=SimpleLayout
HERE
            );
            t::lib::Mocks::mock_config('log4perl_conf', $conf);
            my $appenders = Log::Log4perl->appenders;
            my $appender = Log::Log4perl->appenders->{OPAC};

            my $pref = Koha::Patron::Message::Preferences->find(
                $preference->borrower_message_preference_id
            );
            my $transports = $pref->message_transport_types;
            is($appender, undef, 'Nothing in buffer yet');

            my $mtt_new = $builder->build_object({ class => 'Koha::Patron::Message::Transport::Types' });
            Koha::Patron::Message::Transport::Preference->new({
                borrower_message_preference_id =>
                                $pref->borrower_message_preference_id,
                message_transport_type => $mtt_new->message_transport_type,
            })->store;
            $pref = Koha::Patron::Message::Preferences->find(
                $pref->borrower_message_preference_id
            );
            $transports = $pref->message_transport_types;
            $appender = Log::Log4perl->appenders->{OPAC};
            my $name = $pref->message_name;
            my $tt = $mtt_new->message_transport_type;
            like($appender->buffer, qr/WARN - $name has no transport with $tt/,
                 'Logged invalid message transport type');
        };

        $schema->storage->txn_rollback;
    };

    subtest 'set message_transport_types' => sub {
        plan tests => 12;

        $schema->storage->txn_begin;

        my $patron = $builder->build_object({ class => 'Koha::Patrons' });
        my ($preference, $mtt1, $mtt2) = build_a_test_complete_preference({
            patron => $patron
        });

        my $mtt1_str = $mtt1->message_transport_type;
        my $mtt2_str = $mtt2->message_transport_type;
        # 1/3, use message_transport_types(list)
        Koha::Patron::Message::Transport::Preferences->search({
            borrower_message_preference_id => $preference->borrower_message_preference_id,
        })->delete;
        ok($preference->message_transport_types($mtt1_str, $mtt2_str)->store,
           '1/3 Set returned true.');
        my $stored_transports = Koha::Patron::Message::Transport::Preferences->search({
            borrower_message_preference_id => $preference->borrower_message_preference_id,
            '-or' => [
                message_transport_type => $mtt1_str,
                message_transport_type => $mtt2_str
            ]
        });
        is($stored_transports->count, 2, 'Two transports selected');

        # 2/3, use message_transport_types(ARRAYREF)
        Koha::Patron::Message::Transport::Preferences->search({
            borrower_message_preference_id => $preference->borrower_message_preference_id,
        })->delete;
        ok($preference->message_transport_types([$mtt1_str, $mtt2_str])->store,
           '2/3 Set returned true.');
        $stored_transports = Koha::Patron::Message::Transport::Preferences->search({
            borrower_message_preference_id => $preference->borrower_message_preference_id,
            '-or' => [
                message_transport_type => $mtt1_str,
                message_transport_type => $mtt2_str
            ]
        });
        is($stored_transports->count, 2, 'Two transports selected');

        # 3/3, use set({ message_transport_types => ARRAYREF })
        Koha::Patron::Message::Transport::Preferences->search({
            borrower_message_preference_id => $preference->borrower_message_preference_id,
        })->delete;
        ok($preference->set({
            message_transport_types => [$mtt1_str, $mtt2_str]})->store,
           '3/3 Set returned true.');
        $stored_transports = Koha::Patron::Message::Transport::Preferences->search({
            borrower_message_preference_id => $preference->borrower_message_preference_id,
            '-or' => [
                message_transport_type => $mtt1_str,
                message_transport_type => $mtt2_str
            ]
        });
        is($stored_transports->count, 2, 'Two transports selected');

        # Test email and smsalertnumber validation
        eval { Koha::Patron::Message::Transport::Types->new({
                message_transport_type => 'email'
            })->store };
        eval { Koha::Patron::Message::Transport::Types->new({
                message_transport_type => 'sms'
            })->store };
        Koha::Patron::Message::Transport->new({
            message_attribute_id   => $preference->message_attribute_id,
            message_transport_type => 'email',
            is_digest              => 1
        })->store;
        Koha::Patron::Message::Transport->new({
            message_attribute_id   => $preference->message_attribute_id,
            message_transport_type => 'sms',
            is_digest              => 1
        })->store;
        $patron->set({ email => '', smsalertnumber => '' })->store;
        eval {
            $preference->message_transport_types('email')->store;
        };
        is (ref $@, 'Koha::Exceptions::BadParameter',
            'Adding a message preference with invalid message_transport_type'
            .' => Koha::Exceptions::BadParameter');
        is ($@->parameter, 'message_transport_types', 'The previous exception '
            .' tells us it was the message_transport_types');
        like ($@->error, qr/^Patron has not set email address/, 'Exception '
            .' is because of patron has not set email address.');
        eval {
            $preference->message_transport_types('sms')->store;
        };
        is (ref $@, 'Koha::Exceptions::BadParameter',
            'Adding a message preference with invalid message_transport_type'
            .' => Koha::Exceptions::BadParameter');
        is ($@->parameter, 'message_transport_types', 'The previous exception '
            .' tells us it was the message_transport_types');
        like ($@->error, qr/^Patron has not set sms number/, 'Exception '
            .' is because of patron has not set sms number.');

        $schema->storage->txn_rollback;
    };

    subtest 'new message_transport_types' => sub {
        plan tests => 3;

        $schema->storage->txn_begin;

        my $patron    = $builder->build_object({ class => 'Koha::Patrons' });
        my $letter    = build_a_test_letter();
        my $attribute = $builder->build_object({ class => 'Koha::Patron::Message::Attributes' });
        my $mtt       = $builder->build_object({ class => 'Koha::Patron::Message::Transport::Types' });
        Koha::Patron::Message::Transport->new({
            message_attribute_id   => $attribute->message_attribute_id,
            message_transport_type => $mtt->message_transport_type,
            is_digest              => 0,
            letter_module          => $letter->module,
            letter_code            => $letter->code,
        })->store;
        ok(my $preference = Koha::Patron::Message::Preference->new({
            borrowernumber => $patron->borrowernumber,
            message_attribute_id => $attribute->message_attribute_id,
            wants_digest => 0,
            days_in_advance => undef,
            message_transport_types => $mtt->message_transport_type,
        })->store, 'Added a new messaging preference and transport types to patron.');
        ok($preference->message_transport_types->{$mtt->message_transport_type},
           'The transport type is stored in the object.');
        my $stored_transports = Koha::Patron::Message::Transport::Preferences->search({
            borrower_message_preference_id => $preference->borrower_message_preference_id,
        });
        is($stored_transports->next->message_transport_type, $mtt->message_transport_type,
           'The transport type is stored in the database.');

        $schema->storage->txn_rollback;
    };
};

subtest 'Test Koha::Patron::Message::Preference->message_name' => sub {
    plan tests => 1;

    $schema->storage->txn_begin;

    my $patron      = $builder->build_object({ class => 'Koha::Patrons' });
    my $attribute   = $builder->build_object({ class => 'Koha::Patron::Message::Attributes' });
    my ($preference, $mtt1, $mtt2) = build_a_test_complete_preference({
        patron => $patron,
        attr   => $attribute,
    });
    my $message_name_pref = Koha::Patron::Message::Preferences->search_with_message_name({
        borrowernumber => $patron->{'borrowernumber'},
        message_name => $attribute->message_name,
    })->next;
    is($message_name_pref->message_name, $attribute->message_name, "Found preference with message_name");

    $schema->storage->txn_rollback;
};

subtest 'Test adding a new preference with invalid parameters' => sub {
    plan tests => 4;

    subtest 'Missing parameters' => sub {
        plan tests => 1;

        eval { Koha::Patron::Message::Preference->new->store };
        is(ref $@, 'Koha::Exceptions::MissingParameter',
            'Adding a message preference without parameters'
            .' => Koha::Exceptions::MissingParameter');
    };

    subtest 'Too many parameters' => sub {
        plan tests => 1;

        $schema->storage->txn_begin;

        my $patron = $builder->build_object({ class => 'Koha::Patrons' });
        eval { Koha::Patron::Message::Preference->new({
            borrowernumber => $patron->borrowernumber,
            categorycode   => $patron->categorycode,
        })->store };
        is(ref $@, 'Koha::Exceptions::TooManyParameters',
            'Adding a message preference for both borrowernumber and categorycode'
            .' => Koha::Exceptions::TooManyParameters');

        $schema->storage->txn_rollback;
    };

    subtest 'Bad parameter' => sub {
        plan tests => 22;

        $schema->storage->txn_begin;

        eval { Koha::Patron::Message::Preference->new({
                borrowernumber => -999,
            })->store };
        is(ref $@, 'Koha::Exceptions::BadParameter',
            'Adding a message preference with invalid borrowernumber'
            .' => Koha::Exceptions::BadParameter');
        is ($@->parameter, 'borrowernumber', 'The previous exception tells us it'
            .' was the borrowernumber.');

        eval { Koha::Patron::Message::Preference->new({
                categorycode => 'nonexistent',
            })->store };
        is(ref $@, 'Koha::Exceptions::BadParameter',
            'Adding a message preference with invalid categorycode'
            .' => Koha::Exceptions::BadParameter');
        is($@->parameter, 'categorycode', 'The previous exception tells us it'
            .' was the categorycode.');

        my $attribute = build_a_test_attribute({ takes_days => 0 });
        my $patron    = $builder->build_object({ class => 'Koha::Patrons' });
        eval { Koha::Patron::Message::Preference->new({
                borrowernumber => $patron->borrowernumber,
                message_attribute_id => $attribute->message_attribute_id,
                days_in_advance => 10,
            })->store };
        is(ref $@, 'Koha::Exceptions::BadParameter',
            'Adding a message preference with days in advance option when not'
            .' available => Koha::Exceptions::BadParameter');
        is($@->parameter, 'days_in_advance', 'The previous exception tells us it'
            .' was the days_in_advance.');

        $attribute->set({ takes_days => 1 })->store;
        eval { Koha::Patron::Message::Preference->new({
                borrowernumber => $patron->borrowernumber,
                message_attribute_id => $attribute->message_attribute_id,
                days_in_advance => 31,
            })->store };
        is(ref $@, 'Koha::Exceptions::BadParameter',
            'Adding a message preference with days in advance option too large'
            .' => Koha::Exceptions::BadParameter');
        is($@->parameter, 'days_in_advance', 'The previous exception tells us it'
            .' was the days_in_advance.');

        eval { Koha::Patron::Message::Preference->new({
                borrowernumber => $patron->borrowernumber,
                message_transport_types => ['nonexistent']
            })->store };
        is (ref $@, 'Koha::Exceptions::BadParameter',
            'Adding a message preference with invalid message_transport_type'
            .' => Koha::Exceptions::BadParameter');
        is ($@->parameter, 'message_transport_types', 'The previous exception '
            .'tells us it was the message_transport_types.');

        my $mtt_new = $builder->build_object({ class => 'Koha::Patron::Message::Transport::Types' });
        eval {
            Koha::Patron::Message::Preference->new({
                borrowernumber => $patron->borrowernumber,
                message_attribute_id => $attribute->message_attribute_id,
                message_transport_types => [$mtt_new->message_transport_type],
                wants_digest => 1,
            })->store };
        is (ref $@, 'Koha::Exceptions::BadParameter',
            'Adding a message preference with invalid message_transport_type'
           .' => Koha::Exceptions::BadParameter');
        is ($@->parameter, 'message_transport_types', 'The previous exception '
            .'tells us it was the message_transport_types.');
        like ($@->error, qr/^No transport configured/, 'Exception is because of '
            .'given message_transport_type is not a valid option.');

        eval {
            Koha::Patron::Message::Preference->new({
                borrowernumber => $patron->borrowernumber,
                message_attribute_id => $attribute->message_attribute_id,
                message_transport_types => [],
                wants_digest => 1,
            })->store };
        is (ref $@, 'Koha::Exceptions::BadParameter',
            'Adding a message preference with invalid message_transport_type'
            .' => Koha::Exceptions::BadParameter');
        is ($@->parameter, 'wants_digest', 'The previous exception tells us it'
            .' was the wants_digest');
        like ($@->error, qr/^Digest cannot be selected/, 'Exception s because of'
            .' given digest is not available for this transport.');

        eval {
            Koha::Patron::Message::Preference->new({
                borrowernumber => $patron->borrowernumber,
                message_attribute_id => $attribute->message_attribute_id,
                message_transport_types => [],
                wants_digest => 0,
            })->store };
        is (ref $@, 'Koha::Exceptions::BadParameter',
            'Adding a message preference with invalid message_transport_type'
            .' => Koha::Exceptions::BadParameter');
        is ($@->parameter, 'wants_digest', 'The previous exception tells us it'
            .' was the wants_digest');
        like ($@->error, qr/^Digest must be selected/, 'Exception s because of'
            .' digest has to be on for this transport.');

        eval {
            Koha::Patron::Message::Preference->new({
                borrowernumber => $patron->borrowernumber,
                message_attribute_id => -1,
                message_transport_types => [],
            })->store };
        is (ref $@, 'Koha::Exceptions::BadParameter',
            'Adding a message preference with invalid message_transport_type'
            .' => Koha::Exceptions::BadParameter');
        is ($@->parameter, 'message_attribute_id', 'The previous exception tells'
            .' us it was the message_attribute_id');
        like ($@->error, qr/^Message attribute with id -1 not found/, 'Exception '
            .' is because of given message attribute id is not found.');

        $schema->storage->txn_rollback;
    };

    subtest 'Duplicate object' => sub {
        plan tests => 2;

        $schema->storage->txn_begin;

        my $attribute = $builder->build_object({ class => 'Koha::Patron::Message::Attributes' });
        my $letter = build_a_test_letter();
        my $mtt = $builder->build_object({ class => 'Koha::Patron::Message::Transport::Types' });
        Koha::Patron::Message::Transport->new({
            message_attribute_id   => $attribute->message_attribute_id,
            message_transport_type => $mtt->message_transport_type,
            is_digest              => 0,
            letter_module          => $letter->module,
            letter_code            => $letter->code,
        })->store;
        my $patron    = $builder->build_object({ class => 'Koha::Patrons' });
        my $preference = Koha::Patron::Message::Preference->new({
            borrowernumber => $patron->borrowernumber,
            message_attribute_id => $attribute->message_attribute_id,
            wants_digest => 0,
            days_in_advance => undef,
        })->store;
        ok($preference->borrower_message_preference_id,
           'Added a new messaging preference for patron.');
        eval { Koha::Patron::Message::Preference->new({
            borrowernumber => $patron->borrowernumber,
            message_attribute_id => $attribute->message_attribute_id,
            wants_digest => 0,
            days_in_advance => undef,
        })->store };
        is(ref $@, 'Koha::Exceptions::DuplicateObject',
                'Adding a duplicate preference'
                .' => Koha::Exceptions::DuplicateObject');

        $schema->storage->txn_rollback;
    };
};

sub build_a_test_attribute {
    my ($params) = @_;

    $params->{takes_days} = $params->{takes_days} && $params->{takes_days} > 0
                            ? 1 : 0;

    my $attribute = $builder->build({
        source => 'MessageAttribute',
        value => $params,
    });

    return Koha::Patron::Message::Attributes->find(
        $attribute->{message_attribute_id}
    );
}

sub build_a_test_letter {
    my ($params) = @_;

    my $mtt = $params->{mtt} ? $params->{mtt} : 'email';
    my $branchcode     = $builder->build({
        source => 'Branch' })->{branchcode};
    my $letter = $builder->build({
        source => 'Letter',
        value => {
            branchcode => '',
            is_html => 0,
            message_transport_type => $mtt
        }
    });

    return Koha::Notice::Templates->find({
        module     => $letter->{module},
        code       => $letter->{code},
        branchcode => $letter->{branchcode},
    });
}

sub build_a_test_category_preference {
    my ($params) = @_;

    my $patron = $params->{patron};
    my $attr = $params->{attr}
                    ? $params->{attr}
                    : build_a_test_attribute($params->{days_in_advance});

    my $letter = $params->{letter} ? $params->{letter} : build_a_test_letter();
    my $mtt1 = $params->{mtt1} ? $params->{mtt1} : $builder->build_object({ class => 'Koha::Patron::Message::Transport::Types' });
    my $mtt2 = $params->{mtt2} ? $params->{mtt2} : $builder->build_object({ class => 'Koha::Patron::Message::Transport::Types' });

    Koha::Patron::Message::Transport->new({
        message_attribute_id   => $attr->message_attribute_id,
        message_transport_type => $mtt1->message_transport_type,
        is_digest              => $params->{digest} ? 1 : 0,
        letter_module          => $letter->module,
        letter_code            => $letter->code,
    })->store;

    Koha::Patron::Message::Transport->new({
        message_attribute_id   => $attr->message_attribute_id,
        message_transport_type => $mtt2->message_transport_type,
        is_digest              => $params->{digest} ? 1 : 0,
        letter_module          => $letter->module,
        letter_code            => $letter->code,
    })->store;

    my $default = Koha::Patron::Message::Preference->new({
        categorycode         => $patron->categorycode,
        message_attribute_id => $attr->message_attribute_id,
        wants_digest         => $params->{digest} ? 1 : 0,
        days_in_advance      => $params->{days_in_advance}
                                 ? $params->{days_in_advance} : undef,
    })->store;

    Koha::Patron::Message::Transport::Preference->new({
        borrower_message_preference_id => $default->borrower_message_preference_id,
        message_transport_type         => $mtt1->message_transport_type,
    })->store;
    Koha::Patron::Message::Transport::Preference->new({
        borrower_message_preference_id => $default->borrower_message_preference_id,
        message_transport_type         => $mtt2->message_transport_type,
    })->store;

    return ($default, $mtt1, $mtt2);
}

sub build_a_test_complete_preference {
    my ($params) = @_;

    my ($default, $mtt1, $mtt2) = build_a_test_category_preference($params);
    my $patron = $params->{patron};
    $patron->set_default_messaging_preferences;
    return (Koha::Patron::Message::Preferences->search({
        borrowernumber => $patron->borrowernumber
    })->next, $mtt1, $mtt2);
}

sub mytempfile {
    my ( $fh, $fn ) = tempfile( SUFFIX => '.logger.test', UNLINK => 1 );
    print $fh $_[0]//'';
    close $fh;
    return $fn;
}

1;
