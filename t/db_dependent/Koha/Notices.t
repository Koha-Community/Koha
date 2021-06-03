#!/usr/bin/perl

# Copyright 2017 Koha Development team
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

use Test::More tests => 4;

use Koha::Notice::Templates;
use Koha::Database;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder       = t::lib::TestBuilder->new;
my $library       = $builder->build( { source => 'Branch' } );
my $nb_of_templates = Koha::Notice::Templates->search->count;
my ( $module, $mtt ) = ( 'circulation', 'email' );
my $new_template = Koha::Notice::Template->new(
    {
        module                 => $module,
        code                   => 'tmpl_code_for_t',
        branchcode             => $library->{branchcode},
        name                   => 'my template name for test 1',
        title                  => 'my template title for test 1',
        content                => 'This one is almost empty',
        message_transport_type => $mtt,
    }
)->store;

is(
    Koha::Notice::Templates->search->count,
    $nb_of_templates + 1,
    'The template should have been added'
);

my $retrieved_template = Koha::Notice::Templates->find(
    {
        module                 => $module,
        code                   => $new_template->code,
        branchcode             => $library->{branchcode},
        message_transport_type => $mtt,
    }
);
is( $retrieved_template->name, $new_template->name,
    'Find a notice template by pk should return the correct template' );

$retrieved_template->delete;
is( Koha::Notice::Templates->search->count,
    $nb_of_templates, 'Delete should have deleted the template' );

subtest 'find_effective_template' => sub {
    plan tests => 7;

    my $default_template = $builder->build_object(
        { class => 'Koha::Notice::Templates', value => { branchcode => '', lang => 'default' } }
    );
    my $key = {
        module                 => $default_template->module,
        code                   => $default_template->code,
        message_transport_type => $default_template->message_transport_type,
    };

    my $library_specific_template = $builder->build_object(
        { class => 'Koha::Notice::Templates', value => { %$key, lang => 'default' } }
    );

    my $es_template = $builder->build_object(
        {
            class => 'Koha::Notice::Templates',
            value => { %$key, lang => 'es-ES' },
        }
    );

    $key->{branchcode} = $es_template->branchcode;

    t::lib::Mocks::mock_preference( 'TranslateNotices', 0 );

    my $template = Koha::Notice::Templates->find_effective_template($key);
    is( $template->lang, 'default', 'no lang passed, default is returned' );
    $template = Koha::Notice::Templates->find_effective_template( { %$key, lang => 'es-ES' } );
    is( $template->lang, 'default',
        'TranslateNotices is off, default is returned' );

    t::lib::Mocks::mock_preference( 'TranslateNotices', 1 );
    $template = Koha::Notice::Templates->find_effective_template($key);
    is( $template->lang, 'default', 'no lang passed, default is returned' );
    $template = Koha::Notice::Templates->find_effective_template( { %$key, lang => 'es-ES' } );
    is( $template->lang, 'es-ES',
        'TranslateNotices is on and es-ES is requested, es-ES is returned' );


    {    # IndependentBranches => 1
        t::lib::Mocks::mock_userenv( { branchcode => $library_specific_template->branchcode, flag => 0 } );
        t::lib::Mocks::mock_preference( 'IndependentBranches', 1 );
        $template = Koha::Notice::Templates->find_effective_template( { %$key, branchcode => $library_specific_template->branchcode } );
        is( $template->content, $library_specific_template->content,
            'IndependentBranches is on, logged in patron is not superlibrarian but asks for their specific template, it is returned'
        );

        my $another_library = $builder->build_object( { class => 'Koha::Libraries' } );
        t::lib::Mocks::mock_userenv( { branchcode => $another_library->branchcode, flag => 0 } );
        $template = Koha::Notice::Templates->find_effective_template($key);
        is( $template->content, $default_template->content,
'IndependentBranches is on, logged in patron is not superlibrarian, default is returned'
        );
    }

    t::lib::Mocks::mock_preference( 'IndependentBranches', 0 );
    $es_template->delete;

    $template = Koha::Notice::Templates->find_effective_template( { %$key, lang => 'es-ES' } );
    is( $template->lang, 'default',
        'TranslateNotices is on and es-ES is requested but does not exist, default is returned'
    );

};

$schema->storage->txn_rollback;

