#!/usr/bin/perl

# Copyright 2020 Koha Development team
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 14;
use Test::Exception;

use FindBin '$Bin';

use Koha::CoverImages;
use Koha::Database;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

my $biblio = $builder->build_sample_biblio;
my $item   = $builder->build_sample_item;

is( $biblio->cover_images->count, 0, 'No cover images yet' );

my $no_image = Koha::CoverImages->no_image;
is(
    ref($no_image), 'Koha::CoverImage',
    'no_image returns a Koha::CoverImage object'
);
is( $no_image->mimetype, 'image/gif', 'no_image is a gif image' );
ok( $no_image->imagefile, 'no_image has imagefile set' );
ok( $no_image->thumbnail, 'no_image has thumbnail set' );

my $logo_filepath = "$Bin/../../../koha-tmpl/intranet-tmpl/prog/img/koha-logo.png";
my $image         = Koha::CoverImage->new(
    {
        biblionumber => $biblio->biblionumber,
        src_image    => GD::Image->new($logo_filepath)
    }
)->store;

is( $biblio->cover_images->count, 1, 'There is one cover image' );
my $cover_image = $biblio->cover_images->next;
ok( $cover_image->imagefile, 'image is stored in imagefile' );
ok( $cover_image->thumbnail, 'thumbnail has been generated' );
is(
    $cover_image->mimetype, 'image/png',
    'mimetype has been correctly guessed'
);

$image = Koha::CoverImage->new(
    {
        biblionumber => $biblio->biblionumber,
        src_image    => GD::Image->new($logo_filepath)
    }
)->store;
is( $biblio->cover_images->count, 2, 'There are now two cover images' );

is( $item->cover_images->count, 0, 'No cover images yet' );
$image = Koha::CoverImage->new(
    {
        itemnumber => $item->itemnumber,
        src_image  => GD::Image->new($logo_filepath)
    }
)->store;
is(
    ref( $item->cover_images->next ),
    'Koha::CoverImage',
    'Koha::Item->cover_images returns a rs of Koha::CoverImage object'
);

Koha::CoverImage->new(
    {
        biblionumber => $biblio->biblionumber,
        itemnumber   => $item->itemnumber,
        src_image    => GD::Image->new($logo_filepath)
    }
)->store;
is( $biblio->cover_images->count, 3, );
is( $item->cover_images->count,   2, );

$schema->storage->txn_rollback;
