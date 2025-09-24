#!/usr/bin/perl

# Tests for C4::AuthoritiesMarc::GetTagsLabels

# Copyright 2022 Rijksmuseum, Koha Development Team
#
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use Test::NoWarnings;
use Test::More tests => 2;

use t::lib::TestBuilder;

use C4::AuthoritiesMarc qw( GetTagsLabels );
use Koha::Authority::Types;
use Koha::Database;

my $schema = Koha::Database->new->schema;
our $builder = t::lib::TestBuilder->new;

$schema->storage->txn_begin;

subtest 'GetTagsLabels' => sub {
    plan tests => 8;

    # Clear auth_tag_structure and subfields (via constraints)
    Koha::Authority::Types->delete;
    my $tagslib = GetTagsLabels();
    is( $tagslib, undef, 'Nothing in table' );

    # Add one tag (and auth type), test librarian flag
    my $tag = $builder->build_object(
        { class => 'Koha::Authority::Tags', value => { authtypecode => 'XX1', tagfield => '177' } } );
    $tagslib = GetTagsLabels( 1, $tag->authtypecode );
    is( ref($tagslib),          'HASH',             'Should be a hash' );
    is( scalar keys %$tagslib,  1,                  'Only one entry' );
    is( ref( $tagslib->{177} ), 'HASH',             'Should be a hash' );
    is( $tagslib->{177}->{lib}, $tag->liblibrarian, 'passed librarian flag' );

    # Add subfield, test opac flag
    my $sub = $builder->build_object(
        {
            class => 'Koha::Authority::Subfields',
            value => { authtypecode => 'XX1', tagfield => '177', tagsubfield => 'a' }
        }
    );
    $tagslib = GetTagsLabels( 0, $tag->authtypecode );
    is( $tagslib->{177}->{lib},      $tag->libopac, 'passed opac flag' );
    is( ref( $tagslib->{177}->{a} ), 'HASH',        'Should be a hash' );
    is( $tagslib->{177}->{a}->{lib}, $sub->libopac, 'opac lib in subfield' );
};

$schema->storage->txn_rollback;
