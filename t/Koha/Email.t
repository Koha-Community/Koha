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

use Test::NoWarnings;
use Test::More tests => 6;

use Test::MockModule;
use Test::Exception;

use t::lib::Mocks;

use_ok('Koha::Email');

subtest 'create() tests' => sub {

    plan tests => 27;

    t::lib::Mocks::mock_preference( 'SendAllEmailsTo', undef );

    my $html_body = '<h1>Title</h1><p>Message</p>';
    my $text_body = "#Title: Message";

    my $email = Koha::Email->create(
        {
            from        => 'Fróm <from@example.com>',
            to          => 'Tö <to@example.com>',
            cc          => 'cc@example.com',
            bcc         => 'bcc@example.com',
            reply_to    => 'reply_to@example.com',
            sender      => 'sender@example.com',
            subject     => 'Some subject',
            html_body   => $html_body,
            body_params => { charset => 'iso-8859-1' },
            template_id => 1,
            message_id  => 1,
        }
    );

    is( $email->email->header('From'),               'Fróm <from@example.com>', 'Value set correctly' );
    is( $email->email->header('To'),                 'Tö <to@example.com>',     'Value set correctly' );
    is( $email->email->header('Cc'),                 'cc@example.com',          'Value set correctly' );
    is( $email->email->header('Bcc'),                'bcc@example.com',         'Value set correctly' );
    is( $email->email->header('Reply-To'),           'reply_to@example.com',    'Value set correctly' );
    is( $email->email->header('Sender'),             'sender@example.com',      'Value set correctly' );
    is( $email->email->header('Subject'),            'Some subject',            'Value set correctly' );
    is( $email->email->header('X-Mailer'),           'Koha',                    'Value set correctly' );
    is( $email->email->header('X-Koha-Template-ID'), 1,                         'Value set correctly' );
    is( $email->email->header('X-Koha-Message-ID'),  1,                         'Value set correctly' );
    is( $email->email->body,                         $html_body,                "Body set correctly" );
    like( $email->email->content_type,         qr|text/html|,              "Content type set correctly" );
    like( $email->email->content_type,         qr|charset="?iso-8859-1"?|, "Charset set correctly" );
    like( $email->email->header('Message-ID'), qr/\<.*@.*\>/,              'Value set correctly' );

    $email = Koha::Email->create(
        {
            from => 'from@8.8.8.8',
            to   => 'to@example.com',
            bcc  => 'root@localhost',
        }
    );

    is( $email->email->header('Bcc'),  'root@localhost', 'Non-FQDN (@localhost) supported' );
    is( $email->email->header('From'), 'from@8.8.8.8',   'IPs supported' );

    t::lib::Mocks::mock_preference( 'SendAllEmailsTo',       'catchall@example.com' );
    t::lib::Mocks::mock_preference( 'ReplytoDefault',        'replytodefault@example.com' );
    t::lib::Mocks::mock_preference( 'ReturnpathDefault',     'returnpathdefault@example.com' );
    t::lib::Mocks::mock_preference( 'KohaAdminEmailAddress', 'kohaadminemailaddress@example.com' );

    $email = Koha::Email->create(
        {
            to        => 'to@example.com',
            cc        => 'cc@example.com',
            bcc       => 'bcc@example.com',
            text_body => $text_body,
        }
    );

    is(
        $email->email->header('From'), 'kohaadminemailaddress@example.com',
        'KohaAdminEmailAddress is picked when no from passed'
    );
    is( $email->email->header('To'),  'catchall@example.com', 'SendAllEmailsTo overloads any address' );
    is( $email->email->header('Cc'),  undef,                  'SendAllEmailsTo overloads any address' );
    is( $email->email->header('Bcc'), undef,                  'SendAllEmailsTo overloads any address' );
    is(
        $email->email->header('Reply-To'), 'replytodefault@example.com',
        'ReplytoDefault picked when replyto not passed'
    );
    is(
        $email->email->header('Sender'), 'returnpathdefault@example.com',
        'ReturnpathDefault picked when sender not passed'
    );
    is( $email->email->header('Subject'), '',         'No subject passed, empty string' );
    is( $email->email->body,              $text_body, "Body set correctly" );
    like( $email->email->content_type, qr|text/plain|,        "Content type set correctly" );
    like( $email->email->content_type, qr|charset="?utf-8"?|, "Charset set correctly" );

    subtest 'exception cases' => sub {

        plan tests => 16;

        throws_ok { Koha::Email->create( { from => 'not_an_email' } ); }
        'Koha::Exceptions::BadParameter',
            'Exception thrown correctly';

        like( "$@", qr/Invalid 'from' parameter: not_an_email/, 'Exception message correct' );

        t::lib::Mocks::mock_preference( 'KohaAdminEmailAddress', 'not_an_email' );

        throws_ok { Koha::Email->create( {} ); }
        'Koha::Exceptions::BadParameter',
            'Exception thrown correctly';

        like( "$@", qr/Invalid 'from' parameter: not_an_email/, 'Exception message correct' );

        t::lib::Mocks::mock_preference( 'KohaAdminEmailAddress', 'tomasito@mail.com' );
        t::lib::Mocks::mock_preference( 'SendAllEmailsTo',       undef );

        throws_ok { Koha::Email->create( { to => 'not_an_email' } ); }
        'Koha::Exceptions::BadParameter',
            'Exception thrown correctly';

        like( "$@", qr/Invalid 'to' parameter: not_an_email/, 'Exception message correct' );

        t::lib::Mocks::mock_preference( 'SendAllEmailsTo', 'not_an_email' );

        throws_ok { Koha::Email->create( {} ); }
        'Koha::Exceptions::BadParameter',
            'Exception thrown correctly';

        like( "$@", qr/Invalid 'to' parameter: not_an_email/, 'Exception message correct' );

        t::lib::Mocks::mock_preference( 'SendAllEmailsTo', undef );

        throws_ok {
            Koha::Email->create(
                {
                    to       => 'tomasito@mail.com',
                    reply_to => 'not_an_email'
                }
            );
        }
        'Koha::Exceptions::BadParameter',
            'Exception thrown correctly';

        like( "$@", qr/Invalid 'reply_to' parameter: not_an_email/, 'Exception message correct' );

        throws_ok {
            Koha::Email->create(
                {
                    to     => 'tomasito@mail.com',
                    sender => 'not_an_email'
                }
            );
        }
        'Koha::Exceptions::BadParameter',
            'Exception thrown correctly';

        like( "$@", qr/Invalid 'sender' parameter: not_an_email/, 'Exception message correct' );

        throws_ok {
            Koha::Email->create(
                {
                    to => 'tomasito@mail.com',
                    cc => 'not_an_email'
                }
            );
        }
        'Koha::Exceptions::BadParameter',
            'Exception thrown correctly';

        like( "$@", qr/Invalid 'cc' parameter: not_an_email/, 'Exception message correct' );

        throws_ok {
            Koha::Email->create(
                {
                    to  => 'tomasito@mail.com',
                    bcc => 'not_an_email'
                }
            );
        }
        'Koha::Exceptions::BadParameter',
            'Exception thrown correctly';

        like( "$@", qr/Invalid 'bcc' parameter: not_an_email/, 'Exception message correct' );
    };
};

subtest 'send_or_die() tests' => sub {

    plan tests => 7;

    my $email;
    my $args;

    my $transport = "Hi there!";

    my $mocked_email_simple = Test::MockModule->new('Email::Sender::Simple');
    $mocked_email_simple->mock(
        'send',
        sub {
            my @params = @_;
            $email = $params[1];
            $args  = $params[2];
            return;
        }
    );

    my $html_body = '<h1>Title</h1><p>Message</p>';
    my $THE_email = Koha::Email->create(
        {
            from      => 'from@example.com',
            to        => 'to@example.com',
            cc        => 'cc@example.com',
            reply_to  => 'reply_to@example.com',
            sender    => 'sender@example.com',
            html_body => $html_body
        }
    );

    my @bcc = ( 'bcc_1@example.com', 'bcc_2@example.com' );

    $THE_email->bcc(@bcc);

    is(
        $THE_email->email->header_str('Bcc'),
        join( ', ', @bcc ),
        'Bcc header set correctly'
    );

    $THE_email->send_or_die( { transport => $transport, to => ['tomasito@mail.com'], from => 'returns@example.com' } );
    is_deeply(
        $args->{to}, ['tomasito@mail.com'],
        'If explicitly passed, "to" is preserved'
    );
    is( $args->{from}, 'returns@example.com', 'If explicitly pass, "from" is preserved' );

    $THE_email->send_or_die( { transport => $transport } );
    my @to = sort @{ $args->{to} };
    is_deeply(
        [@to],
        [
            'bcc_1@example.com', 'bcc_2@example.com',
            'cc@example.com',    'to@example.com',
        ],
        'If "to" is not explicitly passed, extract recipients from headers'
    );
    is( $email->header_str('Bcc'), undef, 'The Bcc header is unset' );
    my $from = $args->{from};
    is( $from, 'sender@example.com',         'If "from" is not explicitly passed, extract from Sender header' );
    is( $email->header_str('Sender'), undef, 'The Sender header is unset' );
};

subtest 'is_valid' => sub {
    plan tests => 8;

    is( Koha::Email->is_valid('Fróm <from@example.com>'), 1 );
    is( Koha::Email->is_valid('from@example.com'),        1 );
    is( Koha::Email->is_valid('<from@example.com>'),      1 );
    is( Koha::Email->is_valid('root@localhost'),          1 );    # See bug 28017

    is( Koha::Email->is_valid('<from@fróm.com>'), 0 )
        ;    # "In accordance with RFC 822 and its descendants, this module demands that email addresses be ASCII only"
    isnt( Koha::Email->is_valid('@example.com'), 1 );
    isnt( Koha::Email->is_valid('example.com'),  1 );
    isnt( Koha::Email->is_valid('from'),         1 );
};

subtest 'new_from_string() tests' => sub {

    plan tests => 1;

    my $html_body = '<h1>Title</h1><p>Message</p>';
    my $email_1   = Koha::Email->create(
        {
            from        => 'Fróm <from@example.com>',
            to          => 'Tö <to@example.com>',
            cc          => 'cc@example.com',
            bcc         => 'bcc@example.com',
            reply_to    => 'reply_to@example.com',
            sender      => 'sender@example.com',
            subject     => 'Some subject',
            html_body   => $html_body,
            body_params => { charset => 'iso-8859-1' },
        }
    );

    my $string  = $email_1->as_string;
    my $email_2 = Koha::Email->new_from_string($string);

    is( $email_1->as_string, $email_2->as_string, 'Emails match' );
};
