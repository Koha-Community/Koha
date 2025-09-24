#!/usr/bin/perl

# Copyright 2024 Koha Development team
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

use Test::NoWarnings;
use Test::More tests => 2;

use Koha::Course;
use Koha::Courses;
use Koha::Course::Instructor;
use Koha::Course::Instructors;
use Koha::Database;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'relationship tests' => sub {
    plan tests => 1;

    subtest 'intructors' => sub {
        plan tests => 3;

        $schema->storage->txn_begin;

        my $course = $builder->build_object( { class => 'Koha::Courses' } );

        my $instructors = $course->instructors;
        is( ref($instructors),   'Koha::Patrons', '->instructors returns a Koha::Patrons object' );
        is( $instructors->count, 0, '->instructors->count returns 0 when there are no instructors associated' );

        foreach my $i ( 0 .. 3 ) {

            my $instructor = $builder->build_object( { class => 'Koha::Patrons' } );

            Koha::Course::Instructor->new(
                {
                    course_id      => $course->course_id,
                    borrowernumber => $instructor->borrowernumber,
                }
            )->store();
        }

        $instructors = $course->instructors;
        is( $instructors->count, 4, '4 instructors returns' );

        $schema->storage->txn_rollback;
    };
};
