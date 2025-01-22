#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 7;

use C4::Context;
use Koha::Database;
use Koha::ItemTypes;

use t::lib::TestBuilder;
use t::lib::Mocks;

BEGIN {
    use_ok('Koha::Template::Plugin::Notices');
}

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

$schema->storage->txn_begin;

my $plugin = Koha::Template::Plugin::Notices->new();
ok( $plugin, "initialized Notices plugin" );

my $notice_templates = Koha::Notice::Templates->search();

my $fetched_templates = $plugin->GetTemplates(undef);
is( scalar @$fetched_templates, $notice_templates->count, "All templates returned when no parameters passed" );

my $notice_A = $builder->build_object(
    {
        class => 'Koha::Notice::Templates',
        value => {}
    }
);

$fetched_templates = $plugin->GetTemplates( $notice_A->module );
is( scalar @$fetched_templates, 1, "GetTemplates with module passed gets the one notice in new module" );

is_deeply( @$fetched_templates[0]->unblessed, $notice_A->unblessed, 'The notice is correctly retrieved' );

$notice_A->delete;

$fetched_templates = $plugin->GetTemplates( $notice_A->module );
is( scalar @$fetched_templates, 0, "No notice returned when invalid module passed" );

$schema->storage->txn_rollback;

1;
