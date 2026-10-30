#!/usr/bin/perl

# Copyright 2023 Koha Development team
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
# along with Koha; if not, see <https://www.gnu.org/licenses>

use Modern::Perl;

use Test::Exception;
use Test::Warn;
use Test::NoWarnings;
use Test::More tests => 10;

use C4::Letters qw( GetPreparedLetter EnqueueLetter );

use Koha::ActionLogs;
use Koha::Database;
use Koha::Library::Group;
use Koha::Notice::Messages;
use Koha::Notice::Templates;
use Koha::Patrons;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'is_html() tests' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $template = $builder->build_object(
        {
            class => 'Koha::Notice::Templates',
            value => {
                module                 => 'test',
                code                   => 'TEST',
                message_transport_type => 'email',
                is_html                => '0',
                name                   => 'test notice template',
                title                  => '[% borrower.firstname %]',
                content                => 'This is a test template using borrower [% borrower.id %]',
                branchcode             => "",
                lang                   => 'default',
            }
        }
    );

    my $patron         = $builder->build_object( { class => 'Koha::Patrons' } );
    my $firstname      = $patron->firstname;
    my $borrowernumber = $patron->id;

    my $prepared_letter = GetPreparedLetter(
        (
            module      => 'test',
            letter_code => 'TEST',
            tables      => {
                borrowers => $patron->id,
            },
        )
    );

    my $message_id = EnqueueLetter(
        {
            letter                 => $prepared_letter,
            borrowernumber         => $patron->id,
            message_transport_type => 'email'
        }
    );
    my $message = Koha::Notice::Messages->find($message_id);

    ok( !$message->is_html, "Non html template yields a non html message" );

    $template->is_html(1)->store;
    $prepared_letter = GetPreparedLetter(
        (
            module      => 'test',
            letter_code => 'TEST',
            tables      => {
                borrowers => $patron->id,
            },
        )
    );

    $message_id = EnqueueLetter(
        {
            letter                 => $prepared_letter,
            borrowernumber         => $patron->id,
            message_transport_type => 'email'
        }
    );

    $message = Koha::Notice::Messages->find($message_id);
    ok( $message->is_html, "HTML template yields a html message" );

    $schema->storage->txn_rollback;
};

subtest 'html_content() tests' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    my $template = $builder->build_object(
        {
            class => 'Koha::Notice::Templates',
            value => {
                module                 => 'test',
                code                   => 'TEST',
                message_transport_type => 'email',
                is_html                => '1',
                name                   => 'test notice template',
                title                  => '[% borrower.firstname %]',
                content                => 'This is a test template using borrower [% borrower.id %]',
                branchcode             => "",
                lang                   => 'default',
            }
        }
    );
    my $patron         = $builder->build_object( { class => 'Koha::Patrons' } );
    my $firstname      = $patron->firstname;
    my $borrowernumber = $patron->id;

    my $prepared_letter = GetPreparedLetter(
        (
            module      => 'test',
            letter_code => 'TEST',
            tables      => {
                borrowers => $patron->id,
            },
        )
    );

    my $message_id = EnqueueLetter(
        {
            letter                 => $prepared_letter,
            borrowernumber         => $patron->id,
            message_transport_type => 'email'
        }
    );

    # Mock all CSS preferences to ensure clean test state
    t::lib::Mocks::mock_preference( 'AllNoticeStylesheet',   '' );
    t::lib::Mocks::mock_preference( 'AllNoticeCSS',          '' );
    t::lib::Mocks::mock_preference( 'EmailNoticeStylesheet', '' );
    t::lib::Mocks::mock_preference( 'EmailNoticeCSS',        '' );
    t::lib::Mocks::mock_preference( 'PrintNoticeStylesheet', '' );
    t::lib::Mocks::mock_preference( 'PrintNoticeCSS',        '' );

    my $css_import      = '';
    my $message         = Koha::Notice::Messages->find($message_id);
    my $wrapped_compare = <<"WRAPPED";
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en" xml:lang="en" xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>$firstname</title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    $css_import
  </head>
  <body>
  This is a test template using borrower $borrowernumber
  </body>
</html>
WRAPPED

    is( $message->html_content, $wrapped_compare, "html_content returned the correct html wrapped letter" );

    my $css_sheet = 'https://localhost/shiny.css';
    t::lib::Mocks::mock_preference( 'AllNoticeStylesheet', $css_sheet );
    $css_import = qq{<link rel="stylesheet" type="text/css" href="$css_sheet">};

    $wrapped_compare = <<"WRAPPED";
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en" xml:lang="en" xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>$firstname</title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    $css_import
  </head>
  <body>
  This is a test template using borrower $borrowernumber
  </body>
</html>
WRAPPED

    is(
        $message->html_content, $wrapped_compare,
        "html_content returned the correct html wrapped letter including stylesheet"
    );

    $template->is_html(0)->store;

    # Reset all preferences for plaintext test
    t::lib::Mocks::mock_preference( 'AllNoticeStylesheet',   '' );
    t::lib::Mocks::mock_preference( 'AllNoticeCSS',          '' );
    t::lib::Mocks::mock_preference( 'EmailNoticeStylesheet', '' );
    t::lib::Mocks::mock_preference( 'EmailNoticeCSS',        '' );
    t::lib::Mocks::mock_preference( 'PrintNoticeStylesheet', '' );
    t::lib::Mocks::mock_preference( 'PrintNoticeCSS',        '' );

    $prepared_letter = GetPreparedLetter(
        (
            module      => 'test',
            letter_code => 'TEST',
            tables      => {
                borrowers => $patron->id,
            },
        )
    );

    $message_id = EnqueueLetter(
        {
            letter                 => $prepared_letter,
            borrowernumber         => $patron->id,
            message_transport_type => 'email'
        }
    );

    $wrapped_compare =
        "<div style=\"white-space: pre-wrap;\">This is a test template using borrower $borrowernumber</div>";

    $message = Koha::Notice::Messages->find($message_id);
    is(
        $message->html_content, $wrapped_compare,
        "html_content returned the correct html wrapped letter for a plaintext template"
    );

    $schema->storage->txn_rollback;
};

subtest 'stylesheets() tests' => sub {
    plan tests => 8;

    $schema->storage->txn_begin;

    my $template = $builder->build_object(
        {
            class => 'Koha::Notice::Templates',
            value => {
                module                 => 'test',
                code                   => 'TEST',
                message_transport_type => 'email',
                is_html                => '1',
                name                   => 'test notice template',
                title                  => 'Test Title',
                content                => 'Test content',
                branchcode             => "",
                lang                   => 'default',
            }
        }
    );

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    my $prepared_letter = GetPreparedLetter(
        (
            module      => 'test',
            letter_code => 'TEST',
            tables      => {
                borrowers => $patron->id,
            },
        )
    );

    # Test with no stylesheets set
    t::lib::Mocks::mock_preference( 'AllNoticeStylesheet',   '' );
    t::lib::Mocks::mock_preference( 'AllNoticeCSS',          '' );
    t::lib::Mocks::mock_preference( 'EmailNoticeStylesheet', '' );
    t::lib::Mocks::mock_preference( 'EmailNoticeCSS',        '' );
    t::lib::Mocks::mock_preference( 'PrintNoticeStylesheet', '' );
    t::lib::Mocks::mock_preference( 'PrintNoticeCSS',        '' );

    my $message_id = EnqueueLetter(
        {
            letter                 => $prepared_letter,
            borrowernumber         => $patron->id,
            message_transport_type => 'email'
        }
    );
    my $message = Koha::Notice::Messages->find($message_id);

    is( $message->stylesheets, '', "No stylesheets when all preferences are empty" );

    # Test AllNoticeStylesheet only
    t::lib::Mocks::mock_preference( 'AllNoticeStylesheet', 'https://example.com/all.css' );
    is(
        $message->stylesheets, '<link rel="stylesheet" type="text/css" href="https://example.com/all.css">',
        "AllNoticeStylesheet works correctly"
    );

    # Test AllNoticeCSS only
    t::lib::Mocks::mock_preference( 'AllNoticeStylesheet', '' );
    t::lib::Mocks::mock_preference( 'AllNoticeCSS',        'body { color: red; }' );
    is( $message->stylesheets, '<style type="text/css">body { color: red; }</style>', "AllNoticeCSS works correctly" );

    # Test email-specific stylesheet for email transport
    t::lib::Mocks::mock_preference( 'AllNoticeCSS',          '' );
    t::lib::Mocks::mock_preference( 'EmailNoticeStylesheet', 'https://example.com/email.css' );
    is(
        $message->stylesheets, '<link rel="stylesheet" type="text/css" href="https://example.com/email.css">',
        "EmailNoticeStylesheet works for email transport"
    );

    # Test email-specific CSS for email transport
    t::lib::Mocks::mock_preference( 'EmailNoticeStylesheet', '' );
    t::lib::Mocks::mock_preference( 'EmailNoticeCSS',        '.email { font-weight: bold; }' );
    is(
        $message->stylesheets, '<style type="text/css">.email { font-weight: bold; }</style>',
        "EmailNoticeCSS works for email transport"
    );

    # Test combined all + email styles
    t::lib::Mocks::mock_preference( 'AllNoticeStylesheet',   'https://example.com/all.css' );
    t::lib::Mocks::mock_preference( 'AllNoticeCSS',          'body { margin: 0; }' );
    t::lib::Mocks::mock_preference( 'EmailNoticeStylesheet', 'https://example.com/email.css' );
    t::lib::Mocks::mock_preference( 'EmailNoticeCSS',        '.email { color: blue; }' );

    my $expected_combined =
          '<link rel="stylesheet" type="text/css" href="https://example.com/all.css">' . "\n"
        . '<style type="text/css">body { margin: 0; }</style>'
        . '<link rel="stylesheet" type="text/css" href="https://example.com/email.css">' . "\n"
        . '<style type="text/css">.email { color: blue; }</style>';
    is( $message->stylesheets, $expected_combined, "Combined all and email styles work correctly" );

    # Test print transport type
    $message_id = EnqueueLetter(
        {
            letter                 => $prepared_letter,
            borrowernumber         => $patron->id,
            message_transport_type => 'print'
        }
    );
    $message = Koha::Notice::Messages->find($message_id);

    # Reset email preferences and set print preferences
    t::lib::Mocks::mock_preference( 'EmailNoticeStylesheet', '' );
    t::lib::Mocks::mock_preference( 'EmailNoticeCSS',        '' );
    t::lib::Mocks::mock_preference( 'PrintNoticeStylesheet', 'https://example.com/print.css' );
    t::lib::Mocks::mock_preference( 'PrintNoticeCSS',        '.print { page-break-after: always; }' );

    my $expected_print =
          '<link rel="stylesheet" type="text/css" href="https://example.com/all.css">' . "\n"
        . '<style type="text/css">body { margin: 0; }</style>'
        . '<link rel="stylesheet" type="text/css" href="https://example.com/print.css">' . "\n"
        . '<style type="text/css">.print { page-break-after: always; }</style>';
    is( $message->stylesheets, $expected_print, "Print transport type uses correct stylesheets" );

    # Test that email styles are NOT included for print transport
    t::lib::Mocks::mock_preference( 'AllNoticeStylesheet',   '' );
    t::lib::Mocks::mock_preference( 'AllNoticeCSS',          '' );
    t::lib::Mocks::mock_preference( 'EmailNoticeStylesheet', 'https://example.com/email.css' );
    t::lib::Mocks::mock_preference( 'EmailNoticeCSS',        '.email { color: blue; }' );
    t::lib::Mocks::mock_preference( 'PrintNoticeStylesheet', '' );
    t::lib::Mocks::mock_preference( 'PrintNoticeCSS',        '' );

    is( $message->stylesheets, '', "Print transport does not include email-specific styles" );

    $schema->storage->txn_rollback;
};

subtest 'patron() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    # Valid patron and message
    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $message = $builder->build_object(
        {
            class => 'Koha::Notice::Messages',
            value => { borrowernumber => $patron->borrowernumber }
        }
    );

    is( ref( $message->patron ),          'Koha::Patron',          'Object type is correct' );
    is( $message->patron->borrowernumber, $patron->borrowernumber, 'Right patron linked' );

    # Missing patron
    $message = $builder->build_object(
        {
            class => 'Koha::Notice::Messages',
            value => { borrowernumber => undef }
        }
    );

    is( $message->patron, undef, 'Returns undef if borrowernumber is missing' );

    $schema->storage->txn_rollback;
};

subtest 'template() tests' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    # Valid template and message
    my $template = $builder->build_object( { class => 'Koha::Notice::Templates' } );
    my $message  = $builder->build_object(
        {
            class => 'Koha::Notice::Messages',
            value => { letter_id => $template->id }
        }
    );

    is( ref( $message->template ), 'Koha::Notice::Template', 'Object type is correct' );
    is( $message->template->id,    $template->id,            'Right template linked' );

    # Deleted template
    $template->delete;
    $message->discard_changes;
    is( $message->template, undef, 'Returns undef if template was deleted' );

    # Missing template
    $message = $builder->build_object(
        {
            class => 'Koha::Notice::Messages',
            value => { letter_id => undef }
        }
    );

    is( $message->template, undef, 'Returns undef if no template used for message' );

    $schema->storage->txn_rollback;
};

subtest 'is_sensitive(), can_be_printed() and mark_as_printed() tests' => sub {

    plan tests => 16;

    $schema->storage->txn_begin;

    my $message = sub {
        my ($value) = @_;
        return $builder->build_object( { class => 'Koha::Notice::Messages', value => $value } );
    };

    # is_sensitive
    for my $code (qw( PASSWORD_RESET STAFF_PASSWORD_RESET OPAC_REG_VERIFY 2FA_OTP_TOKEN )) {
        ok( $message->( { letter_code => $code } )->is_sensitive, "$code is sensitive" );
    }
    ok( !$message->( { letter_code => 'HOLD_SLIP' } )->is_sensitive, 'Other notices are not sensitive' );
    ok( !$message->( { letter_code => undef } )->is_sensitive, 'Messages without a letter code are not sensitive' );

    my $secret = $message->(
        {
            letter_code            => 'PASSWORD_RESET', content => 'https://example.org/reset?uniqueKey=SECRETKEY',
            message_transport_type => 'email'
        }
    );
    unlike( $secret->html_content, qr/SECRETKEY/, 'The content of a sensitive message is not in html_content' );
    like( $secret->html_content, qr/not displayed/, 'html_content says why' );

    # can_be_printed
    my %printable = (
        sent          => { message_transport_type => 'email', status => 'sent' },
        failed        => { message_transport_type => 'sms',   status => 'failed' },
        printed       => { message_transport_type => 'print', status => 'printed' },
        pending_print => { message_transport_type => 'print', status => 'pending' },
    );
    ok(
        $message->( { letter_code => 'HOLD_SLIP', %{ $printable{sent} } } )->can_be_printed,
        'A sent email can be printed'
    );
    ok(
        $message->( { letter_code => 'HOLD_SLIP', %{ $printable{failed} } } )->can_be_printed,
        'A failed sms can be printed'
    );
    ok(
        $message->( { letter_code => 'HOLD_SLIP', %{ $printable{pending_print} } } )->can_be_printed,
        'A pending print notice can be printed'
    );
    ok(
        !$message->( { letter_code => 'HOLD_SLIP', message_transport_type => 'email', status => 'pending' } )
            ->can_be_printed,
        'A pending email cannot be printed'
    );
    ok(
        !$message->( { letter_code => 'PASSWORD_RESET', message_transport_type => 'email', status => 'sent' } )
            ->can_be_printed,
        'A sensitive notice cannot be printed'
    );

    # mark_as_printed
    t::lib::Mocks::mock_preference( 'NoticesLog', 1 );
    my $to_print = $message->( { letter_code => 'HOLD_SLIP', message_transport_type => 'email', status => 'sent' } );
    $to_print->mark_as_printed;
    is( $to_print->get_from_storage->status, 'printed', 'The status is set to printed' );
    is(
        Koha::ActionLogs->search( { module => 'NOTICES', action => 'PRINT', object => $to_print->message_id } )->count,
        1, 'It is logged when the notices are logged'
    );
    t::lib::Mocks::mock_preference( 'NoticesLog', 0 );
    my $unlogged = $message->( { letter_code => 'HOLD_SLIP', status => 'sent' } );
    $unlogged->mark_as_printed;
    is(
        Koha::ActionLogs->search( { module => 'NOTICES', action => 'PRINT', object => $unlogged->message_id } )->count,
        0, 'It is not logged when the notices are not logged'
    );

    $schema->storage->txn_rollback;
};

subtest 'convert_to_print() tests' => sub {

    plan tests => 21;

    $schema->storage->txn_begin;

    # The notice used to convert, with the patron and the original notice
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron  = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library->branchcode, address => '1 Test Street', lang => 'default' }
        }
    );
    Koha::Notice::Templates->search( { code => 'CONVERTED_TO_PRINT' } )->delete;
    $builder->build_object(
        {
            class => 'Koha::Notice::Templates',
            value => {
                module                 => 'members',
                code                   => 'CONVERTED_TO_PRINT',
                branchcode             => '',
                message_transport_type => 'print',
                lang                   => 'default',
                is_html                => 1,
                title                  => '[% original_message.subject %]',
                content                =>
                    '<p>[% borrower.address %]</p><p>[% original_message.status %]</p>[% original_message.content_as_html %]',
            }
        }
    );

    my $message = sub {
        my ($value) = @_;
        return $builder->build_object(
            {
                class => 'Koha::Notice::Messages',
                value => {
                    borrowernumber         => $patron->borrowernumber,
                    letter_code            => 'HOLD_SLIP',
                    message_transport_type => 'email',
                    subject                => 'Your hold',
                    content                => 'Come <and> get it',
                    status                 => 'failed',
                    %{$value}
                }
            }
        );
    };

    # content_as_html
    is(
        $message->( { content => 'a <b>', content_type => 'text/plain; charset="UTF-8"' } )->content_as_html,
        '<div style="white-space: pre-wrap;">a &lt;b&gt;</div>', 'Text is escaped'
    );

    # can_be_converted_to_print
    ok( $message->( { status => 'failed' } )->can_be_converted_to_print, 'A failed email can be converted' );
    ok(
        $message->( { status => 'sent', message_transport_type => 'sms' } )->can_be_converted_to_print,
        'A sent sms can be converted'
    );
    ok( !$message->( { status => 'pending' } )->can_be_converted_to_print,   'A pending notice cannot be converted' );
    ok( !$message->( { status => 'printed' } )->can_be_converted_to_print,   'A printed notice cannot be converted' );
    ok( !$message->( { status => 'converted' } )->can_be_converted_to_print, 'A converted notice cannot be converted' );
    ok(
        !$message->( { status => 'sent', message_transport_type => 'print' } )->can_be_converted_to_print,
        'A print notice cannot be converted'
    );
    ok(
        !$message->( { status => 'sent', letter_code => 'PASSWORD_RESET' } )->can_be_converted_to_print,
        'A sensitive notice cannot be converted'
    );
    ok(
        !$message->( { status => 'sent', borrowernumber => undef } )->can_be_converted_to_print,
        'A notice without a patron cannot be converted'
    );
    ok(
        !$message->( { status => 'converted' } )->can_be_printed,
        'A converted notice is not printed, its print notice is'
    );

    # convert_to_print
    t::lib::Mocks::mock_preference( 'NoticesLog', 1 );
    my $original = $message->( { status => 'failed' } );
    my $print    = $original->convert_to_print;
    is( ref($print),                    'Koha::Notice::Message', 'The print notice is returned' );
    is( $print->message_transport_type, 'print',                 'It is a print notice' );
    is( $print->status,                 'pending',               'It is waiting to be printed' );
    is( $print->borrowernumber,         $patron->borrowernumber, 'It is for the same patron' );
    like(
        $print->content, qr/1 Test Street.*failed.*Come &lt;and&gt; get it/s,
        'It has the address and the original content'
    );
    is( $original->get_from_storage->status, 'converted', 'The original is converted' );
    is(
        Koha::ActionLogs->search( { module => 'NOTICES', action => 'CONVERT', object => $original->message_id } )
            ->count,
        1, 'It is logged'
    );

    throws_ok { $original->convert_to_print } 'Koha::Exceptions::Notice::CannotConvertToPrint',
        'A converted notice cannot be converted again';

    # Without the notice
    Koha::Notice::Templates->search( { code => 'CONVERTED_TO_PRINT' } )->delete;
    my $another = $message->( { status => 'sent' } );
    warning_like {
        throws_ok { $another->convert_to_print } 'Koha::Exceptions::Notice::NoConversionTemplate',
        'There must be a notice to convert with'
    } qr/No members CONVERTED_TO_PRINT letter transported by print/, 'Koha warns that the notice is missing';
    is( $another->get_from_storage->status, 'sent', 'The notice is not changed' );

    $schema->storage->txn_rollback;
};

subtest 'scoped_style() tests' => sub {

    plan tests => 9;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'EmailNoticeCSS', 'p { color: red; }' );
    t::lib::Mocks::mock_preference( 'PrintNoticeCSS', '@media print { p { color: blue; } }' );

    my $email =
        $builder->build_object( { class => 'Koha::Notice::Messages', value => { message_transport_type => 'email' } } );
    like( $email->scoped_style, qr/\.type_email\s+p\s*\{/, 'Email styles are scoped to the transport type' );

    my $print =
        $builder->build_object( { class => 'Koha::Notice::Messages', value => { message_transport_type => 'print' } } );
    like(
        $print->scoped_style, qr/\@media print\s*\{\s*\.type_print\s+p\s*\{/,
        'Rules inside an at-rule are scoped'
    );

    t::lib::Mocks::mock_preference(
        'PrintNoticeCSS',
        "\@media print {\n    p { color: blue; }\n    h1 { color: red; }\n}\n"
    );
    like(
        $print->scoped_style, qr/\.type_print\s+p\s*\{.*\.type_print\s+h1\s*\{/s,
        'Rules inside a formatted at-rule are scoped'
    );

    t::lib::Mocks::mock_preference(
        'PrintNoticeCSS',
        'body { color: red; } h1, :is(a, b), [data-x="1,2"] { margin: 0 }'
    );
    my $scoped = $print->scoped_style;
    like( $scoped, qr/^\.type_print\s*\{ color: red; \}/, 'The document selectors apply to the container' );
    like(
        $scoped, qr/\.type_print h1, \.type_print :is\(a, b\), \.type_print \[data-x="1,2"\] \{/,
        'Only top level commas separate selectors'
    );

    t::lib::Mocks::mock_preference( 'PrintNoticeCSS', '@layer base { p { color: blue; } }' );
    like( $print->scoped_style, qr/\@layer base \{ \.type_print p/, 'Rules in layers are scoped' );

    my $template = $builder->build_object(
        { class => 'Koha::Notice::Templates', value => { style => '@media print { p { a: b; } } p { c: d; }' } } );
    my $templated =
        $builder->build_object( { class => 'Koha::Notice::Messages', value => { letter_id => $template->id } } );
    is(
        $templated->scoped_template_style('#notice_1'), '@media print { #notice_1 p { a: b; } } #notice_1 p { c: d; }',
        'The style of the template is scoped'
    );

    my $sms =
        $builder->build_object( { class => 'Koha::Notice::Messages', value => { message_transport_type => 'sms' } } );
    is( $sms->scoped_style, q{}, 'No styles for transport types without styles, and no warnings' );

    t::lib::Mocks::mock_preference( 'EmailNoticeCSS', '' );
    is( $email->scoped_style, q{}, 'No styles when the preference is empty, and no warnings' );

    $schema->storage->txn_rollback;
};

subtest 'search_limited' => sub {
    plan tests => 13;

    $schema->storage->txn_begin;

    my $library_a = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_b = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_c = $builder->build_object( { class => 'Koha::Libraries' } );

    my $super = $builder->build_object(
        { class => 'Koha::Patrons', value => { flags => 1, branchcode => $library_a->branchcode } } );
    my $patron_a = $builder->build_object(
        { class => 'Koha::Patrons', value => { flags => 0, branchcode => $library_a->branchcode } } );
    my $patron_b = $builder->build_object(
        { class => 'Koha::Patrons', value => { flags => 0, branchcode => $library_b->branchcode } } );
    my $patron_c = $builder->build_object(
        { class => 'Koha::Patrons', value => { flags => 0, branchcode => $library_c->branchcode } } );
    my $patron_any = $builder->build_object(
        { class => 'Koha::Patrons', value => { flags => 4, branchcode => $library_c->branchcode } } );
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $patron_any->borrowernumber,
                module_bit     => 4,
                code           => 'view_borrower_infos_from_any_libraries'
            }
        }
    );

    # A and B are in separate groups that hide patron information, C is in no group
    my $group_1 = Koha::Library::Group->new( { title => 'TEST Group 1', ft_hide_patron_info => 1 } )->store;
    my $group_2 = Koha::Library::Group->new( { title => 'TEST Group 2', ft_hide_patron_info => 1 } )->store;
    Koha::Library::Group->new( { parent_id => $group_1->id, branchcode => $library_a->branchcode } )->store;
    Koha::Library::Group->new( { parent_id => $group_2->id, branchcode => $library_b->branchcode } )->store;

    my %patron = ( a => $patron_a, b => $patron_b, c => $patron_c );
    my %message;
    $message{$_} = $builder->build_object(
        { class => 'Koha::Notice::Messages', value => { borrowernumber => $patron{$_}->borrowernumber } } )
        for qw(a b c);
    $message{none} =
        $builder->build_object( { class => 'Koha::Notice::Messages', value => { borrowernumber => undef } } );
    my @ids = map { $_->message_id } values %message;

    my $visible = sub {
        my ( $patron, $params, $attributes ) = @_;
        t::lib::Mocks::mock_userenv( { patron => $patron } );
        return [ sort map { $_->message_id }
                Koha::Notice::Messages->search_limited( { 'me.message_id' => \@ids, %{ $params // {} } }, $attributes )
                ->as_list ];
    };
    my $ids = sub {
        [ sort map { $message{$_}->message_id } @_ ]
    };

    is_deeply(
        $visible->($super), $ids->(qw(a b c none)),
        'Superlibrarian sees all notices, also those without a patron'
    );
    is_deeply(
        $visible->($patron_a), $ids->('a'),
        'Patron in a group only sees the notices of patrons of the group libraries'
    );
    is_deeply(
        $visible->($patron_c), $ids->('c'),
        'Patron without group only sees the notices of patrons of their own library'
    );
    is_deeply(
        $visible->($patron_any), $ids->(qw(a b c none)),
        'Patron with view_borrower_infos_from_any_libraries sees all notices'
    );

    t::lib::Mocks::mock_preference( 'IndependentBranches', 1 );
    is_deeply( $visible->($patron_a), $ids->('a'), 'IndependentBranches restricts to the own library' );

    # With IndependentBranches, the own library is all that can be seen, whatever the permissions
    is_deeply(
        $visible->($patron_any), $ids->('c'),
        'A patron with view_borrower_infos_from_any_libraries is restricted to their library by IndependentBranches'
    );
    is_deeply(
        $visible->( $patron_any, { 'me.borrowernumber' => $patron_a->borrowernumber } ), [],
        'And does not see the notices of the patrons of other libraries, also when asking for them'
    );

    # The patrons table is joined to restrict the notices: a column of the notices that is also
    # a column of the patrons, such as borrowernumber, must not be ambiguous. Used here whether there is a
    # restriction or not, selecting a column of the patrons so that the join is not dropped as unused
    is_deeply(
        eval {
            $visible->(
                $super, { borrowernumber => $patron_c->borrowernumber },
                { join => ['borrowernumber'], '+columns' => { patron_library => 'borrowernumber.branchcode' } }
            );
        } // "died: $@",
        $ids->('c'),
        'A column of the notices that is also one of the patrons can be used without its table name'
    );
    is_deeply(
        eval { $visible->( $patron_any, { borrowernumber => $patron_c->borrowernumber } ) } // "died: $@",
        $ids->('c'),
        'Also when the notices are restricted, as the table of the patrons is then joined'
    );
    t::lib::Mocks::mock_preference( 'IndependentBranches', 0 );

    # The restriction is combined with, not replaced by, the passed conditions
    is_deeply(
        $visible->( $patron_a, { 'borrowernumber.branchcode' => $library_b->branchcode } ), [],
        'The restriction is not overridden by a library filter on another library'
    );
    is_deeply(
        $visible->( $super, { 'borrowernumber.branchcode' => $library_b->branchcode } ), $ids->('b'),
        'A library filter is applied'
    );

    # The arguments are not modified
    my $params     = { 'me.message_id' => \@ids };
    my $attributes = { join            => ['borrowernumber'], rows => 10 };
    t::lib::Mocks::mock_userenv( { patron => $patron_a } );
    Koha::Notice::Messages->search_limited( $params, $attributes )->count;
    is_deeply(
        [ $params, $attributes ], [ { 'me.message_id' => \@ids }, { join => ['borrowernumber'], rows => 10 } ],
        'search_limited does not modify its arguments'
    );

    # A logged in user that cannot be found sees nothing
    my $unknown    = $builder->build_object( { class => 'Koha::Patrons' } );
    my $unknown_id = $unknown->borrowernumber;
    $unknown->delete;
    t::lib::Mocks::mock_userenv( { borrowernumber => $unknown_id } );
    is(
        Koha::Notice::Messages->search_limited( { 'me.message_id' => \@ids } )->count, 0,
        'Nothing is returned when the logged in patron cannot be found'
    );

    $schema->storage->txn_rollback;
};

1;
