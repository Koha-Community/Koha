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

use Test::More tests => 5;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Koha::Notice::Templates;
use Koha::Patron::Categories;
use Koha::Patron::Message::Attributes;
use Koha::Patron::Message::Transport::Types;
use Koha::Patron::Message::Transports;
use Koha::Patrons;

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

    my $attribute = build_a_test_attribute();

    subtest 'Test for a patron' => sub {
        plan tests => 3;

        my $patron = build_a_test_patron();
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
        my $category = build_a_test_category();
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

    my $patron = build_a_test_patron();
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

        my $patron = build_a_test_patron();
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
        plan tests => 8;

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
        my $patron    = build_a_test_patron();
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

        $schema->storage->txn_rollback;
    };

    subtest 'Duplicate object' => sub {
        plan tests => 2;

        $schema->storage->txn_begin;

        my $attribute = build_a_test_attribute();
        my $patron    = build_a_test_patron();
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

sub build_a_test_category {
    my $categorycode   = $builder->build({
        source => 'Category' })->{categorycode};

    return Koha::Patron::Categories->find($categorycode);
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

sub build_a_test_patron {
    my $categorycode   = $builder->build({
        source => 'Category' })->{categorycode};
    my $branchcode     = $builder->build({
        source => 'Branch' })->{branchcode};
    my $borrowernumber = $builder->build({
        source => 'Borrower' })->{borrowernumber};

    return Koha::Patrons->find($borrowernumber);
}

sub build_a_test_transport_type {
    my $mtt = $builder->build({
        source => 'MessageTransportType' });

    return Koha::Patron::Message::Transport::Types->find(
        $mtt->{message_transport_type}
    );
}

sub build_a_test_category_preference {
    my ($params) = @_;

    my $patron = $params->{patron};
    my $attr = $params->{attr}
                    ? $params->{attr}
                    : build_a_test_attribute($params->{days_in_advance});

    my $letter = $params->{letter} ? $params->{letter} : build_a_test_letter();
    my $mtt1 = $params->{mtt1} ? $params->{mtt1} : build_a_test_transport_type();
    my $mtt2 = $params->{mtt2} ? $params->{mtt2} : build_a_test_transport_type();

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
                                 ? $params->{days_in_advance} : 0,
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

1;
