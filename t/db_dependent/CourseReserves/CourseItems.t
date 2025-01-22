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
use C4::CourseReserves
    qw( ModCourse ModCourseItem ModCourseReserve GetCourse GetCourseItem DelCourse DelCourseReserve );
use C4::Context;
use Koha::Items;

use Test::NoWarnings;
use Test::More tests => 37;

BEGIN {
    require_ok('C4::CourseReserves');
}

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new();

create_dependent_objects();
my ( $biblionumber, $itemnumber ) = create_bib_and_item();

my $ci_id = ModCourseItem(
    itemnumber            => $itemnumber,
    itype_enabled         => 1,
    ccode_enabled         => 1,
    homebranch_enabled    => 1,
    holdingbranch_enabled => 1,
    location_enabled      => 1,
    itype                 => 'BK_foo',
    ccode                 => 'BOOK',
    homebranch            => 'B2',
    holdingbranch         => 'B2',
    location              => 'TH',
);

my $course = $builder->build(
    {
        source => 'CourseReserve',
        value  => {
            ci_id => $ci_id,
        }
    }
);

my $cr_id = ModCourseReserve(
    course_id   => $course->{course_id},
    ci_id       => $ci_id,
    staff_note  => '',
    public_note => '',
);

my $course_item = GetCourseItem( ci_id => $ci_id );
is( $course_item->{itype_storage},         'CD_foo', 'Course item itype storage should be CD_foo' );
is( $course_item->{ccode_storage},         'CD',     'Course item ccode storage should be CD' );
is( $course_item->{homebranch_storage},    'B1',     'Course item holding branch storage should be B1' );
is( $course_item->{holdingbranch_storage}, 'B1',     'Course item holding branch storage should be B1' );
is( $course_item->{location_storage},      'HR',     'Course item location storage should be HR' );

my $item = Koha::Items->find($itemnumber);
is( $item->effective_itemtype, 'BK_foo', 'Item type in course should be BK_foo' );
is( $item->ccode,              'BOOK',   'Item ccode in course should be BOOK' );
is( $item->homebranch,         'B2',     'Item home branch in course should be B2' );
is( $item->holdingbranch,      'B2',     'Item holding branch in course should be B2' );
is( $item->location,           'TH',     'Item location in course should be TH' );

ModCourseItem(
    itemnumber            => $itemnumber,
    itype_enabled         => 1,
    ccode_enabled         => 1,
    homebranch_enabled    => 1,
    holdingbranch_enabled => 1,
    location_enabled      => 1,
    itype                 => 'BK_foo',
    ccode                 => 'DVD',
    homebranch            => 'B3',
    holdingbranch         => 'B3',
    location              => 'TH',
);

ModCourseReserve(
    course_id   => $course->{course_id},
    ci_id       => $ci_id,
    staff_note  => '',
    public_note => '',
);

$course_item = GetCourseItem( ci_id => $ci_id );
is( $course_item->{itype_storage},         'CD_foo', 'Course item itype storage should be CD_foo' );
is( $course_item->{ccode_storage},         'CD',     'Course item ccode storage should be CD' );
is( $course_item->{homebranch_storage},    'B1',     'Course item home branch storage should be B1' );
is( $course_item->{holdingbranch_storage}, 'B1',     'Course item holding branch storage should be B1' );
is( $course_item->{location_storage},      'HR',     'Course item location storage should be HR' );

$item = Koha::Items->find($itemnumber);
is( $item->effective_itemtype, 'BK_foo', 'Item type in course should be BK_foo' );
is( $item->ccode,              'DVD',    'Item ccode in course should be DVD' );
is( $item->homebranch,         'B3',     'Item home branch in course should be B3' );
is( $item->holdingbranch,      'B3',     'Item holding branch in course should be B3' );
is( $item->location,           'TH',     'Item location in course should be TH' );

DelCourseReserve( cr_id => $cr_id );
$item = Koha::Items->find($itemnumber);
is( $item->effective_itemtype, 'CD_foo', 'Item type removed from course should be set back to CD_foo' );
is( $item->ccode,              'CD',     'Item ccode removed from course should be set back to CD' );
is( $item->homebranch,         'B1',     'Item home branch removed from course should be set back B1' );
is( $item->holdingbranch,      'B1',     'Item holding branch removed from course should be set back B1' );
is( $item->location,           'HR',     'Item location removed from course should be TH' );

# Test the specific case described on bug #10382.
$item->ccode('')->store;

$item = Koha::Items->find($itemnumber);
is( $item->ccode, '', 'Item ccode should be empty' );

my $ci_id2 = ModCourseItem(
    itemnumber            => $itemnumber,
    itype_enabled         => 1,
    ccode_enabled         => 1,
    homebranch_enabled    => 1,
    holdingbranch_enabled => 1,
    location_enabled      => 1,
    itype                 => 'CD_foo',
    ccode                 => 'BOOK',
    homebranch            => 'B1',
    holdingbranch         => 'B1',
    location              => 'HR',
);

my $cr_id2 = ModCourseReserve(
    course_id   => $course->{course_id},
    ci_id       => $ci_id2,
    staff_note  => '',
    public_note => '',
);

$item = Koha::Items->find($itemnumber);
is( $item->ccode, 'BOOK', 'Item ccode should be BOOK' );

my $course_item2 = GetCourseItem( ci_id => $ci_id2 );
is( $course_item2->{ccode_storage}, '', 'Course item ccode storage should be empty' );

ModCourseItem(
    itemnumber            => $itemnumber,
    itype_enabled         => 1,
    ccode_enabled         => 1,
    homebranch_enabled    => 1,
    holdingbranch_enabled => 1,
    location_enabled      => 1,
    itype                 => 'CD_foo',
    ccode                 => 'DVD',
    homebranch            => 'B1',
    holdingbranch         => 'B1',
    location              => 'HR',
);

ModCourseReserve(
    course_id   => $course->{course_id},
    ci_id       => $ci_id2,
    staff_note  => '',
    public_note => '',
);

$item = Koha::Items->find($itemnumber);
is( $item->ccode, 'DVD', 'Item ccode should be DVD' );

ModCourseItem(
    itemnumber            => $itemnumber,
    itype_enabled         => 1,
    ccode_enabled         => 1,
    homebranch_enabled    => 0,             # LEAVE UNCHANGED
    holdingbranch_enabled => 0,             # LEAVE UNCHANGED
    location_enabled      => 1,
    itype                 => 'BK',
    ccode                 => 'BOOK',
    holdingbranch         => undef,         # LEAVE UNCHANGED
    location              => 'TH',
);
$item = Koha::Items->find($itemnumber);
is( $item->ccode, 'BOOK', 'Item ccode should be BOOK' );

$course_item2 = GetCourseItem( ci_id => $ci_id2 );
is( $course_item2->{ccode_storage}, '', 'Course item ccode storage should be empty' );

DelCourseReserve( cr_id => $cr_id2 );
$item = Koha::Items->find($itemnumber);
is( $item->ccode, '', 'Item ccode should be set back to empty' );

subtest 'Ensure modifying fields on existing course items updates the item and course item' => sub {
    plan tests => 60;

    my ( $biblionumber, $itemnumber ) = create_bib_and_item();
    my $ci_id = ModCourseItem(
        itemnumber            => $itemnumber,
        itype_enabled         => 0,
        ccode_enabled         => 0,
        homebranch_enabled    => 0,
        holdingbranch_enabled => 0,
        location_enabled      => 0,
    );

    my $course = $builder->build(
        {
            source => 'CourseReserve',
            value  => {
                ci_id => $ci_id,
            }
        }
    );

    my $cr_id = ModCourseReserve(
        course_id   => $course->{course_id},
        ci_id       => $ci_id,
        staff_note  => '',
        public_note => '',
    );

    my $course_item = GetCourseItem( ci_id => $ci_id );
    is( $course_item->{itype_storage},         undef, 'Course item itype storage should be undef' );
    is( $course_item->{ccode_storage},         undef, 'Course item ccode storage should be undef' );
    is( $course_item->{homebranch_storage},    undef, 'Course item holding branch storage should be undef' );
    is( $course_item->{holdingbranch_storage}, undef, 'Course item holding branch storage should be undef' );
    is( $course_item->{location_storage},      undef, 'Course item location storage should be undef' );

    is( $course_item->{itype},         undef, 'Course item itype should be undef' );
    is( $course_item->{ccode},         undef, 'Course item ccode should be undef' );
    is( $course_item->{homebranch},    undef, 'Course item holding branch should be undef' );
    is( $course_item->{holdingbranch}, undef, 'Course item holding branch should be undef' );
    is( $course_item->{location},      undef, 'Course item location should be undef' );

    is( $course_item->{itype_enabled},         0, 'Course item itype enabled should be 0' );
    is( $course_item->{ccode_enabled},         0, 'Course item ccode enabled should be 0' );
    is( $course_item->{homebranch_enabled},    0, 'Course item holding branch enabled should be 0' );
    is( $course_item->{holdingbranch_enabled}, 0, 'Course item holding branch enabled should be 0' );
    is( $course_item->{location_enabled},      0, 'Course item location enabled should be 0' );

    my $item = Koha::Items->find($itemnumber);
    is( $item->effective_itemtype, 'CD_foo', 'Item type in course should be CD_foo' );
    is( $item->ccode,              'CD',     'Item ccode in course should be CD' );
    is( $item->homebranch,         'B1',     'Item home branch in course should be B1' );
    is( $item->holdingbranch,      'B1',     'Item holding branch in course should be B1' );
    is( $item->location,           'HR',     'Item location in course should be HR' );

    ModCourseItem(
        itemnumber            => $itemnumber,
        itype_enabled         => 1,
        ccode_enabled         => 1,
        homebranch_enabled    => 1,
        holdingbranch_enabled => 1,
        location_enabled      => 1,
        itype                 => 'BK_foo',
        ccode                 => 'BOOK',
        homebranch            => 'B2',
        holdingbranch         => 'B2',
        location              => 'TH',
    );

    $course_item = GetCourseItem( ci_id => $ci_id );
    is( $course_item->{itype_storage},         'CD_foo', 'Course item itype storage should be CD_foo' );
    is( $course_item->{ccode_storage},         'CD',     'Course item ccode storage should be CD' );
    is( $course_item->{homebranch_storage},    'B1',     'Course item holding branch storage should be B1' );
    is( $course_item->{holdingbranch_storage}, 'B1',     'Course item holding branch storage should be B1' );
    is( $course_item->{location_storage},      'HR',     'Course item location storage should be HR' );

    is( $course_item->{itype},         'BK_foo', 'Course item itype should be BK_foo' );
    is( $course_item->{ccode},         'BOOK',   'Course item ccode should be BOOK' );
    is( $course_item->{homebranch},    'B2',     'Course item holding branch should be B2' );
    is( $course_item->{holdingbranch}, 'B2',     'Course item holding branch should be B2' );
    is( $course_item->{location},      'TH',     'Course item location should be TH' );

    is( $course_item->{itype_enabled},         1, 'Course item itype enabled should be 1' );
    is( $course_item->{ccode_enabled},         1, 'Course item ccode enabled should be 1' );
    is( $course_item->{homebranch_enabled},    1, 'Course item holding branch enabled should be 1' );
    is( $course_item->{holdingbranch_enabled}, 1, 'Course item holding branch enabled should be 1' );
    is( $course_item->{location_enabled},      1, 'Course item location enabled should be 1' );

    $item = Koha::Items->find($itemnumber);
    is( $item->effective_itemtype, 'BK_foo', 'Item type in course should be BK_foo' );
    is( $item->ccode,              'BOOK',   'Item ccode in course should be BOOK' );
    is( $item->homebranch,         'B2',     'Item home branch in course should be B2' );
    is( $item->holdingbranch,      'B2',     'Item holding branch in course should be B2' );
    is( $item->location,           'TH',     'Item location in course should be TH' );

    # Test removing fields from an active course item
    ModCourseItem(
        itemnumber            => $itemnumber,
        itype_enabled         => 0,
        ccode_enabled         => 0,
        homebranch_enabled    => 0,
        holdingbranch_enabled => 0,
        location_enabled      => 0,
    );

    $course_item = GetCourseItem( ci_id => $ci_id );
    is( $course_item->{itype_storage},         undef, 'Course item itype storage should be undef' );
    is( $course_item->{ccode_storage},         undef, 'Course item ccode storage should be undef' );
    is( $course_item->{homebranch_storage},    undef, 'Course item holding branch storage should be undef' );
    is( $course_item->{holdingbranch_storage}, undef, 'Course item holding branch storage should be undef' );
    is( $course_item->{location_storage},      undef, 'Course item location storage should be undef' );

    is( $course_item->{itype},         undef, 'Course item itype should be undef' );
    is( $course_item->{ccode},         undef, 'Course item ccode should be undef' );
    is( $course_item->{homebranch},    undef, 'Course item holding branch should be undef' );
    is( $course_item->{holdingbranch}, undef, 'Course item holding branch should be undef' );
    is( $course_item->{location},      undef, 'Course item location should be undef' );

    is( $course_item->{itype_enabled},         0, 'Course item itype enabled should be 0' );
    is( $course_item->{ccode_enabled},         0, 'Course item ccode enabled should be 0' );
    is( $course_item->{homebranch_enabled},    0, 'Course item holding branch enabled should be 0' );
    is( $course_item->{holdingbranch_enabled}, 0, 'Course item holding branch enabled should be 0' );
    is( $course_item->{location_enabled},      0, 'Course item location enabled should be 0' );

    $item = Koha::Items->find($itemnumber);
    is( $item->effective_itemtype, 'CD_foo', 'Item type in course should be CD_foo' );
    is( $item->ccode,              'CD',     'Item ccode in course should be CD' );
    is( $item->homebranch,         'B1',     'Item home branch in course should be B1' );
    is( $item->holdingbranch,      'B1',     'Item holding branch in course should be B1' );
    is( $item->location,           'HR',     'Item location in course should be HR' );
};

subtest 'Ensure item info is preserved' => sub {
    plan tests => 8;

    my $course = $builder->build( { source => 'Course' } );
    my $item   = $builder->build_sample_item( { ccode => "grasshopper", location => "transylvania" } );

    #Add course item but change nothing
    my $course_item_id = ModCourseItem(
        itemnumber    => $item->itemnumber,
        itype         => '',
        ccode         => '',
        holdingbranch => '',
        location      => '',
    );

    #Add course reserve
    my $course_reserve_id = ModCourseReserve(
        course_id   => $course->{course_id},
        ci_id       => $course_item_id,
        staff_note  => '',
        public_note => '',
    );

    #Remove course reservei
    DelCourseReserve( cr_id => $course_reserve_id );
    my $item_after = Koha::Items->find( $item->itemnumber );
    is(
        $item->effective_itemtype, $item_after->itype,
        "Itemtype is unchanged after adding to and removing from course reserves for inactive course"
    );
    is(
        $item->location, $item_after->location,
        "Location is unchanged after adding to and removing from course reserves for inactive course"
    );
    is(
        $item->holdingbranch, $item_after->holdingbranch,
        "Holdingbranch is unchanged after adding to and removing from course reserves for inactive course"
    );
    is(
        $item->ccode, $item_after->ccode,
        "Collection is unchanged after adding to and removing from course reserves for inactive course"
    );

    $course = $builder->build( { source => 'Course' } );
    $item   = $builder->build_sample_item( { ccode => "grasshopper", location => "transylvania" } );

    #Add course item but change nothing
    $course_item_id = ModCourseItem(
        itemnumber    => $item->itemnumber,
        itype         => '',
        ccode         => '',
        holdingbranch => '',
        location      => '',
    );

    #Add course reserve
    $course_reserve_id = ModCourseReserve(
        course_id   => $course->{course_id},
        ci_id       => $course_item_id,
        staff_note  => '',
        public_note => '',
    );

    #Remove course reserve
    DelCourseReserve( cr_id => $course_reserve_id );
    $item_after = Koha::Items->find( $item->itemnumber );
    is(
        $item->effective_itemtype, $item_after->itype,
        "Itemtype is unchanged after adding to and removing from course reserves for inactive course"
    );
    is(
        $item->location, $item_after->location,
        "Location is unchanged after adding to and removing from course reserves for inactive course"
    );
    is(
        $item->holdingbranch, $item_after->holdingbranch,
        "Holdingbranch is unchanged after adding to and removing from course reserves for inactive course"
    );
    is(
        $item->ccode, $item_after->ccode,
        "Collection is unchanged after adding to and removing from course reserves for inactive course"
    );

};

subtest 'biblio added to course without items' => sub {
    plan tests => 1;

    my $course = $builder->build( { source => 'Course' } );

    #Add course item but change nothing
    my $course_item_id = ModCourseItem(
        itemnumber    => undef,
        biblionumber  => $biblionumber,
        itype         => '',
        ccode         => '',
        holdingbranch => '',
        location      => '',
    );

    #Add course reserve
    my $course_reserve_id = ModCourseReserve(
        course_id   => $course->{course_id},
        ci_id       => $course_item_id,
        staff_note  => 'staff note',
        public_note => '',
    );

    my $course_item = GetCourseItem( ci_id => $course_item_id );
    is( $course_item->{itemnumber}, undef, "Course reserve with no item correctly added" );
};

$schema->storage->txn_rollback;

sub create_dependent_objects {
    $builder->build(
        {
            source => 'Itemtype',
            value  => {
                itemtype    => 'CD_foo',
                description => 'Compact Disk'
            }
        }
    );

    $builder->build(
        {
            source => 'Itemtype',
            value  => {
                itemtype    => 'BK_foo',
                description => 'Book'
            }
        }
    );

    $builder->build(
        {
            source => 'Branch',
            value  => {
                branchcode => 'B1',
                branchname => 'Branch 1'
            }
        }
    );

    $builder->build(
        {
            source => 'Branch',
            value  => {
                branchcode => 'B2',
                branchname => 'Branch 2'
            }
        }
    );

    $builder->build(
        {
            source => 'Branch',
            value  => {
                branchcode => 'B3',
                branchname => 'Branch 3'
            }
        }
    );

    $builder->build(
        {
            source => 'AuthorisedValue',
            value  => {
                category         => 'CCODE',
                authorised_value => 'BOOK',
                lib              => 'Book'
            }
        }
    );

    $builder->build(
        {
            source => 'AuthorisedValue',
            value  => {
                category         => 'CCODE',
                authorised_value => 'DVD',
                lib              => 'Book'
            }
        }
    );

    $builder->build(
        {
            source => 'AuthorisedValue',
            value  => {
                category         => 'CCODE',
                authorised_value => 'CD',
                lib              => 'Compact Disk'
            }
        }
    );

    $builder->build(
        {
            source => 'AuthorisedValue',
            value  => {
                category         => 'LOC',
                authorised_value => 'HR',
                lib              => 'Here'
            }
        }
    );

    $builder->build(
        {
            source => 'AuthorisedValue',
            value  => {
                category         => 'LOC',
                authorised_value => 'TH',
                lib              => 'There'
            }
        }
    );
}

sub create_bib_and_item {
    my $item = $builder->build_sample_item(
        {
            itype    => 'CD_foo',
            ccode    => 'CD',
            location => 'HR',
            library  => 'B1',
        }
    );
    return ( $item->biblionumber, $item->itemnumber );
}
