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

use Test::More tests => 2;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Koha::Notice::Templates;
use Koha::Patron::Categories;
use Koha::Patron::Message::Attributes;
use Koha::Patron::Message::Preferences;
use Koha::Patron::Message::Transport::Types;
use Koha::Patron::Message::Transports;
use Koha::Patrons;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'Test class imports' => sub {
    plan tests => 2;

    use_ok('Koha::Patron::Message::Transport::Preference');
    use_ok('Koha::Patron::Message::Transport::Preferences');
};

subtest 'Test Koha::Patron::Message::Transport::Preferences' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $attribute = $builder->build_object({ class => 'Koha::Patron::Message::Attributes' });
    my $mtt       = $builder->build_object({ class => 'Koha::Patron::Message::Transport::Types' });
    my $letter    = build_a_test_letter({
        mtt => $mtt->message_transport_type
    });
    Koha::Patron::Message::Transport->new({
        message_attribute_id   => $attribute->message_attribute_id,
        message_transport_type => $mtt->message_transport_type,
        is_digest              => 0,
        letter_module          => $letter->module,
        letter_code            => $letter->code,
    })->store;

    subtest 'For a patron' => sub {
        my $patron    = $builder->build_object({ class => 'Koha::Patrons' });
        my $preference = Koha::Patron::Message::Preference->new({
            borrowernumber       => $patron->borrowernumber,
            message_attribute_id => $attribute->message_attribute_id,
            wants_digest         => 0,
            days_in_advance      => undef,
        })->store;

        my $pref_id = $preference->borrower_message_preference_id;
        my $transport_pref = Koha::Patron::Message::Transport::Preference->new({
            borrower_message_preference_id => $pref_id,
            message_transport_type => $mtt->message_transport_type,
        })->store;
        is(ref($transport_pref), 'Koha::Patron::Message::Transport::Preference',
           'Added a new messaging transport preference for patron.');

        $transport_pref->delete;
        is(Koha::Patron::Message::Transport::Preferences->search({
            borrower_message_preference_id => $pref_id,
            message_transport_type => $mtt->message_transport_type,
        })->count, 0, 'Deleted the messaging transport preference.');
    };

    subtest 'For a category' => sub {
        my $category   = $builder->build_object({ class => 'Koha::Patron::Categories' });
        my $preference = Koha::Patron::Message::Preference->new({
            categorycode         => $category->categorycode,
            message_attribute_id => $attribute->message_attribute_id,
            wants_digest         => 0,
            days_in_advance      => undef,
        })->store;

        my $pref_id = $preference->borrower_message_preference_id;
        my $transport_pref = Koha::Patron::Message::Transport::Preference->new({
            borrower_message_preference_id => $pref_id,
            message_transport_type => $mtt->message_transport_type,
        })->store;
        is(ref($transport_pref), 'Koha::Patron::Message::Transport::Preference',
           'Added a new messaging transport preference for category.');

        $transport_pref->delete;
        is(Koha::Patron::Message::Transport::Preferences->search({
            borrower_message_preference_id => $pref_id,
            message_transport_type => $mtt->message_transport_type,
        })->count, 0, 'Deleted the messaging transport preference.');
    };

    $schema->storage->txn_rollback;
};

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
        module => $letter->{module},
        code   => $letter->{code},
        branchcode => $letter->{branchcode},
    });
}

1;
