#!/usr/bin/perl
#
# This is to test C4/Members
# It requires a working Koha database with the sample data

use strict;
use warnings;

use Test::More tests => 16;
use Data::Dumper;

BEGIN {
   use_ok('C4::Context');
        use_ok('C4::CourseReserves');
}

my $dbh = C4::Context->dbh;
$dbh->do("TRUNCATE TABLE course_instructors");
$dbh->do("TRUNCATE TABLE courses");
$dbh->do("TRUNCATE TABLE course_reserves");

my $sth = $dbh->prepare("SELECT * FROM borrowers ORDER BY RAND() LIMIT 10");
$sth->execute();
my @borrowers = @{$sth->fetchall_arrayref({})};

$sth = $dbh->prepare("SELECT * FROM items ORDER BY RAND() LIMIT 10");
$sth->execute();
my @items = @{$sth->fetchall_arrayref({})};

my $course_id = ModCourse(
      course_name => "Test Course",
  staff_note => "Test staff note",
       public_note => "Test public note",
);

ok( $course_id, "ModCourse created course successfully" );

$course_id = ModCourse(
     course_id => $course_id,
       staff_note => "Test staff note 2",
);

my $course = GetCourse( $course_id );

ok( $course->{'course_name'} eq "Test Course", "GetCourse returned correct course" );
ok( $course->{'staff_note'} eq "Test staff note 2", "ModCourse updated course succesfully" );

my $courses = GetCourses();
ok( $courses->[0]->{'course_name'} eq "Test Course", "GetCourses returns valid array of course data" );

ModCourseInstructors( mode => 'add', course_id => $course_id, borrowernumbers => [ $borrowers[0]->{'borrowernumber'} ] );
$course = GetCourse( $course_id );
ok( $course->{'instructors'}->[0]->{'borrowernumber'} == $borrowers[0]->{'borrowernumber'}, "ModCourseInstructors added instructors correctly");

my $course_instructors = GetCourseInstructors( $course_id );
ok( $course_instructors->[0]->{'borrowernumber'} eq $borrowers[0]->{'borrowernumber'}, "GetCourseInstructors returns valid data" );

my $ci_id = ModCourseItem( 'itemnumber' => $items[0]->{'itemnumber'} );
ok( $ci_id, "ModCourseItem returned valid data" );

my $course_item = GetCourseItem( 'ci_id' => $ci_id );
ok( $course_item->{'itemnumber'} eq $items[0]->{'itemnumber'}, "GetCourseItem returns valid data" );

my $cr_id = ModCourseReserve( 'course_id' => $course_id, 'ci_id' => $ci_id );
ok( $cr_id, "ModCourseReserve returns valid data" );

my $course_reserve = GetCourseReserve( 'course_id' => $course_id, 'ci_id' => $ci_id );
ok( $course_reserve->{'cr_id'} eq $cr_id, "GetCourseReserve returns valid data" );

my $course_reserves = GetCourseReserves( 'course_id' => $course_id );
ok( $course_reserves->[0]->{'ci_id'} eq $ci_id, "GetCourseReserves returns valid data." );

my $info = GetItemReservesInfo( itemnumber => $items[0]->{'itemnumber'} );
ok( $info->[0]->{'itemnumber'} eq $items[0]->{'itemnumber'}, "GetItemReservesInfo returns valid data." );

DelCourseReserve( 'cr_id' => $cr_id );
$course_reserve = GetCourseReserve( 'cr_id' => $cr_id );
ok( !defined( $course_reserve->{'cr_id'} ), "DelCourseReserve functions correctly" );

DelCourse( $course_id );
$course = GetCourse( $course_id );
ok( !defined( $course->{'course_id'} ), "DelCourse deleted course successfully" );

$dbh->do("TRUNCATE TABLE course_instructors");
$dbh->do("TRUNCATE TABLE courses");
$dbh->do("TRUNCATE TABLE course_reserves");

exit;
