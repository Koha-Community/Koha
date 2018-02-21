#!/usr/bin/perl

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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use t::lib::Mocks;
use t::lib::TestBuilder;
use C4::CourseReserves qw/ModCourseItem ModCourseReserve DelCourseReserve GetCourseItem/;
use C4::Context;
use Koha::Items;

use Test::More tests => 27;

BEGIN {
    require_ok('C4::CourseReserves');
}

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new();

create_dependent_objects();
my ($biblionumber, $itemnumber) = create_bib_and_item();

my $ci_id = ModCourseItem(
    itemnumber    => $itemnumber,
    itype         => 'BK_foo',
    ccode         => 'BOOK',
    holdingbranch => 'B2',
    location      => 'TH',
);

my $course = $builder->build({
    source => 'CourseReserve',
    value => {
        ci_id => $ci_id,
    }
});

my $cr_id = ModCourseReserve(
    course_id   => $course->{course_id},
    ci_id       => $ci_id,
    staff_note  => '',
    public_note => '',
);

my $course_item = GetCourseItem( ci_id => $ci_id );
is($course_item->{itype}, 'CD_foo', 'Course item itype should be CD_foo');
is($course_item->{ccode}, 'CD', 'Course item ccode should be CD');
is($course_item->{holdingbranch}, 'B1', 'Course item holding branch should be B1');
is($course_item->{location}, 'HR', 'Course item location should be HR');

my $item = Koha::Items->find($itemnumber);
is($item->itype, 'BK_foo', 'Item type in course should be BK_foo');
is($item->ccode, 'BOOK', 'Item ccode in course should be BOOK');
is($item->holdingbranch, 'B2', 'Item holding branch in course should be B2');
is($item->location, 'TH', 'Item location in course should be TH');

ModCourseItem(
    itemnumber    => $itemnumber,
    itype         => 'BK_foo',
    ccode         => 'DVD',
    holdingbranch => 'B3',
    location      => 'TH',
);

ModCourseReserve(
    course_id   => $course->{course_id},
    ci_id       => $ci_id,
    staff_note  => '',
    public_note => '',
);

$course_item = GetCourseItem( ci_id => $ci_id );
is($course_item->{itype}, 'CD_foo', 'Course item itype should be CD_foo');
is($course_item->{ccode}, 'CD', 'Course item ccode should be CD');
is($course_item->{holdingbranch}, 'B1', 'Course item holding branch should be B1');
is($course_item->{location}, 'HR', 'Course item location should be HR');

$item = Koha::Items->find($itemnumber);
is($item->itype, 'BK_foo', 'Item type in course should be BK_foo');
is($item->ccode, 'DVD', 'Item ccode in course should be DVD');
is($item->holdingbranch, 'B3', 'Item holding branch in course should be B3');
is($item->location, 'TH', 'Item location in course should be TH');

DelCourseReserve( cr_id => $cr_id );
$item = Koha::Items->find($itemnumber);
is($item->itype, 'CD_foo', 'Item type removed from course should be set back to CD_foo');
is($item->ccode, 'CD', 'Item ccode removed from course should be set back to CD');
is($item->holdingbranch, 'B1', 'Item holding branch removed from course should be set back B1');
is($item->location, 'HR', 'Item location removed from course should be TH');

# Test the specific case described on bug #10382.
$item->ccode('')->store;

$item = Koha::Items->find($itemnumber);
is($item->ccode, '', 'Item ccode should be empty');

my $ci_id2 = ModCourseItem(
    itemnumber    => $itemnumber,
    itype         => 'CD_foo',
    ccode         => 'BOOK',
    holdingbranch => 'B1',
    location      => 'HR',
);

my $cr_id2 = ModCourseReserve(
    course_id   => $course->{course_id},
    ci_id       => $ci_id2,
    staff_note  => '',
    public_note => '',
);

$item = Koha::Items->find($itemnumber);
is($item->ccode, 'BOOK', 'Item ccode should be BOOK');

my $course_item2 = GetCourseItem( ci_id => $ci_id2 );
is($course_item2->{ccode}, '', 'Course item ccode should be empty');

ModCourseItem(
    itemnumber    => $itemnumber,
    itype         => 'CD_foo',
    ccode         => 'DVD',
    holdingbranch => 'B1',
    location      => 'HR',
);

ModCourseReserve(
    course_id   => $course->{course_id},
    ci_id       => $ci_id2,
    staff_note  => '',
    public_note => '',
);

$item = Koha::Items->find($itemnumber);
is($item->ccode, 'DVD', 'Item ccode should be BOOK');

$course_item2 = GetCourseItem( ci_id => $ci_id2 );
is($course_item2->{ccode}, '', 'Course item ccode should be empty');

DelCourseReserve( cr_id => $cr_id2 );
$item = Koha::Items->find($itemnumber);
is($item->ccode, '', 'Item ccode should be set back to empty');

$schema->storage->txn_rollback;

sub create_dependent_objects {
    $builder->build({
        source => 'Itemtype',
        value  => {
            itemtype => 'CD_foo',
            description => 'Compact Disk'
        }
    });

    $builder->build({
        source => 'Itemtype',
        value  => {
            itemtype => 'BK_foo',
            description => 'Book'
        }
    });

    $builder->build({
        source => 'Branch',
        value  => {
            branchcode => 'B1',
            branchname => 'Branch 1'
        }
    });

    $builder->build({
        source => 'Branch',
        value  => {
            branchcode => 'B2',
            branchname => 'Branch 2'
        }
    });

    $builder->build({
        source => 'Branch',
        value  => {
            branchcode => 'B3',
            branchname => 'Branch 3'
        }
    });

    $builder->build({
        source => 'AuthorisedValue',
        value  => {
            category => 'CCODE',
            authorised_value => 'BOOK',
            lib => 'Book'
        }
    });

    $builder->build({
        source => 'AuthorisedValue',
        value  => {
            category => 'CCODE',
            authorised_value => 'DVD',
            lib => 'Book'
        }
    });

    $builder->build({
        source => 'AuthorisedValue',
        value  => {
            category => 'CCODE',
            authorised_value => 'CD',
            lib => 'Compact Disk'
        }
    });

    $builder->build({
        source => 'AuthorisedValue',
        value  => {
            category => 'LOC',
            authorised_value => 'HR',
            lib => 'Here'
        }
    });

    $builder->build({
        source => 'AuthorisedValue',
        value  => {
            category => 'LOC',
            authorised_value => 'TH',
            lib => 'There'
        }
    });
}

sub create_bib_and_item {
    my $biblio = $builder->build({
        source => 'Biblio',
        value  => {
            title => 'Title',
        }
    });
    my $item = $builder->build({
        source => 'Item',
        value  => {
            biblionumber  => $biblio->{biblionumber},
            itype         => 'CD_foo',
            ccode         => 'CD',
            location      => 'HR',
            homebranch    => 'B1',
            holdingbranch => 'B1',
        }
    });
    return ($biblio->{biblionumber}, $item->{itemnumber});
}
