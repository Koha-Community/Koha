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
# along with Koha; if not, see <http://www.gnu.org/licenses>

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 3;

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

    t::lib::Mocks::mock_preference( 'NoticeCSS', '' );
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
    t::lib::Mocks::mock_preference( 'NoticeCSS', $css_sheet );
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

1;
