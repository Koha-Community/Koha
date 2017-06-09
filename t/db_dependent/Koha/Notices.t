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

use Test::More tests => 3;

use Koha::Notice::Templates;
use Koha::Database;

use t::lib::TestBuilder;

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

$schema->storage->txn_rollback;

