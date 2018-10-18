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

use Test::More tests => 27;

use Koha::Database;
use t::lib::TestBuilder;

BEGIN {
    use_ok('C4::Items', qw(AddItem));
    use_ok('C4::Biblio');
    use_ok('C4::CourseReserves', qw/:all/);
    use_ok('C4::Context');
    use_ok('MARC::Field');
    use_ok('MARC::Record');
}

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;
my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;

my $branchcode = $builder->build( { source => 'Branch' } )->{branchcode};
my $itemtype = $builder->build(
    { source => 'Itemtype', value => { notforloan => undef } } )->{itemtype};

# Create 10 sample borrowers
my @borrowers = ();
foreach (1..10) {
    push @borrowers, $builder->build({ source => 'Borrower' });
}

# Create the a record with an item
my $record = MARC::Record->new;
my ( $biblionumber, $biblioitemnumber ) = C4::Biblio::AddBiblio($record, '');
my ( undef, undef, $itemnumber ) = C4::Items::AddItem(
    {   homebranch    => $branchcode,
        holdingbranch => $branchcode,
        itype         => $itemtype
    },
    $biblionumber
);

my $course_id = ModCourse(
    course_name => "Test Course",
    staff_note  => "Test staff note",
    public_note => "Test public note",
);

ok( $course_id, "ModCourse created course successfully" );

$course_id = ModCourse(
    course_id  => $course_id,
    staff_note => "Test staff note 2",
    enabled   => 'no',
);

my $course = GetCourse($course_id);

ok( $course->{'course_name'} eq "Test Course",       "GetCourse returned correct course" );
ok( $course->{'staff_note'}  eq "Test staff note 2", "ModCourse updated course succesfully" );
is( $course->{'enabled'}, 'no', "Test Course is disabled" );

my $courses = GetCourses();
is( ref($courses), 'ARRAY', "GetCourses returns an array" );
my @match = map {$_->{course_name} eq 'Test Course'} @$courses;
ok( scalar(@match) > 0, "GetCourses returns valid array of course data" );

ModCourseInstructors( mode => 'add', course_id => $course_id, borrowernumbers => [ $borrowers[0]->{'borrowernumber'} ] );
$course = GetCourse($course_id);
ok( $course->{'instructors'}->[0]->{'borrowernumber'} == $borrowers[0]->{'borrowernumber'}, "ModCourseInstructors added instructors correctly" );

my $course_instructors = GetCourseInstructors($course_id);
ok( $course_instructors->[0]->{'borrowernumber'} eq $borrowers[0]->{'borrowernumber'}, "GetCourseInstructors returns valid data" );

my $ci_id = ModCourseItem( 'itemnumber' => $itemnumber );
ok( $ci_id, "ModCourseItem returned valid data" );

my $course_item = GetCourseItem( 'ci_id' => $ci_id );
ok( $course_item->{'itemnumber'} eq $itemnumber, "GetCourseItem returns valid data" );

my $cr_id = ModCourseReserve( 'course_id' => $course_id, 'ci_id' => $ci_id );
ok( $cr_id, "ModCourseReserve returns valid data" );

my $course_reserve = GetCourseReserve( 'course_id' => $course_id, 'ci_id' => $ci_id );
ok( $course_reserve->{'cr_id'} eq $cr_id, "GetCourseReserve returns valid data" );

my $course_reserves = GetCourseReserves( 'course_id' => $course_id );
ok( $course_reserves->[0]->{'ci_id'} eq $ci_id, "GetCourseReserves returns valid data." );

## Check for regression of Bug 15530
$course_id = ModCourse(
    course_id  => $course_id,
    enabled   => 'yes',
);
$course = GetCourse($course_id);
is( $course->{'enabled'}, 'yes', "Test Course is enabled" );
$course_item = GetCourseItem( 'ci_id' => $ci_id );
is( $course_item->{enabled}, 'yes', "Course item is enabled after modding disabled course" );
my $disabled_course_id = ModCourse(
    course_name => "Disabled Course",
    enabled     => 'no',
);
my $disabled_course = GetCourse( $disabled_course_id );
is( $disabled_course->{'enabled'}, 'no', "Disabled Course is disabled" );
my $cr_id2 = ModCourseReserve( 'course_id' => $disabled_course_id, 'ci_id' => $ci_id );
$course_item = GetCourseItem( 'ci_id' => $ci_id );
is( $course_item->{enabled}, 'yes', "Course item is enabled after modding disabled course" );
## End check for regression of Bug 15530

my $info = GetItemCourseReservesInfo( itemnumber => $itemnumber );
ok( $info->[0]->{'itemnumber'} eq $itemnumber, "GetItemReservesInfo returns valid data." );

DelCourseReserve( 'cr_id' => $cr_id );
$course_reserve = GetCourseReserve( 'cr_id' => $cr_id );
ok( !defined( $course_reserve->{'cr_id'} ), "DelCourseReserve functions correctly" );

DelCourse($course_id);
$course = GetCourse($course_id);
ok( !defined( $course->{'course_id'} ), "DelCourse deleted course successfully" );

$courses = SearchCourses(); # FIXME Lack of tests for SearchCourses
is( ref($courses), 'ARRAY', 'SearchCourses should not crash and return an arrayref' );

$schema->storage->txn_rollback;
