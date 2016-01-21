#!/usr/bin/perl

# Copyright 2015 Koha Development team
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

use Koha::Database;
use Koha::Patrons;
use Koha::Patron::Image;
use Koha::Patron::Images;
use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;
my $patron = $builder->build({ source => 'Borrower', });
$patron = Koha::Patrons->find($patron->{borrowernumber});
my $nb_of_images = Koha::Patron::Images->search->count;
my $new_image = Koha::Patron::Image->new({
    borrowernumber => $patron->borrowernumber,
    mimetype => 'image/png',
    imagefile => 'lot of binary content',
})->store;

is( Koha::Patron::Images->search->count, $nb_of_images + 1, 'The patron image should have been added' );

my $retrieved_image = Koha::Patron::Images->find( $new_image->borrowernumber );
is( $retrieved_image->imagefile, $new_image->imagefile, 'Find a patron image by borrowernumber should return the correct image' );
is( ref($patron->image), 'Koha::Patron::Image', 'Koha::Patron should have a image method which returns a Koha::Patron::Image' );

$retrieved_image->delete;
is( Koha::Patron::Images->search->count, $nb_of_images, 'Delete should have deleted the patron image' );

$schema->storage->txn_rollback;

1;
