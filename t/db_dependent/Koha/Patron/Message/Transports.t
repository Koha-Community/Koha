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

use t::lib::TestBuilder;

use Koha::Notice::Templates;
use Koha::Patron::Message::Attributes;
use Koha::Patron::Message::Transport::Types;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'Test class imports' => sub {
    plan tests => 2;

    use_ok('Koha::Patron::Message::Transport');
    use_ok('Koha::Patron::Message::Transports');
};

subtest 'Test Koha::Patron::Message::Transports' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $attribute = $builder->build_object({ class => 'Koha::Patron::Message::Attributes' });
    my $mtt       = $builder->build_object({ class => 'Koha::Patron::Message::Transport::Types' });
    my $letter    = build_a_test_letter({
        mtt => $mtt->message_transport_type
    });

    my $transport = Koha::Patron::Message::Transport->new({
        message_attribute_id   => $attribute->message_attribute_id,
        message_transport_type => $mtt->message_transport_type,
        is_digest              => 0,
        letter_module          => $letter->module,
        letter_code            => $letter->code,
    })->store;

    is($transport->message_attribute_id, $attribute->message_attribute_id,
       'Added a new messaging transport.');

    $transport->delete;
    is(Koha::Patron::Message::Transports->search({
        message_attribute_id => $attribute->message_attribute_id,
        message_transport_type => $mtt->message_transport_type,
        is_digest => 0
    })->count, 0, 'Deleted the messaging transport.');

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
