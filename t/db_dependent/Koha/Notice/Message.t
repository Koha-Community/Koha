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

use Test::NoWarnings;
use Test::More tests => 5;

use C4::Letters qw( GetPreparedLetter EnqueueLetter );

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

    plan tests => 4;

    $schema->storage->txn_begin;

    # Valid patron and message
    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $message = $builder->build_object(
        {
            class => 'Koha::Notice::Messages',
            value => { borrowernumber => $patron->borrowernumber }
        }
    );
    my $message_id = $message->message_id;

    is( ref( $message->patron ),          'Koha::Patron',          'Object type is correct' );
    is( $message->patron->borrowernumber, $patron->borrowernumber, 'Right patron linked' );

    # Deleted patron
    $patron->delete;
    $message = Koha::Notice::Messages->find($message_id);
    is( $message, undef, 'Deleting the patron also deletes the associated message' );

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

subtest 'search_limited' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $patron   = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 1 } } );
    my $patron_2 = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0 } } );

    my $message = $builder->build_object(
        {
            class => 'Koha::Notice::Messages',
            value => { borrowernumber => $patron->borrowernumber }
        }
    );

    my $message_2 = $builder->build_object(
        {
            class => 'Koha::Notice::Messages',
            value => { borrowernumber => $patron_2->borrowernumber }
        }
    );

    my $nb_messages = Koha::Notice::Messages->count;

    my $group_1 = Koha::Library::Group->new( { title => 'TEST Group 1' } )->store;
    my $group_2 = Koha::Library::Group->new( { title => 'TEST Group 2' } )->store;
    Koha::Library::Group->new( { parent_id => $group_1->id, branchcode => $patron->branchcode } )->store();
    Koha::Library::Group->new( { parent_id => $group_2->id, branchcode => $patron_2->branchcode } )->store();
    t::lib::Mocks::mock_userenv( { patron => $patron } );    # Is superlibrarian
    is(
        Koha::Notice::Messages->search_limited->count, $nb_messages,
        'Koha::Notice::Messages->search_limited should return all generated notices for superlibrarian'
    );
    t::lib::Mocks::mock_userenv( { patron => $patron_2 } );    # Is restricted
    is(
        Koha::Notice::Messages->search_limited->count, 1,
        'Koha:Notice::Messages->search_limited should not return all generated notices for restricted patron'
    );
};

1;
