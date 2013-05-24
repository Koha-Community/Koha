#!/usr/bin/perl
#
# This is to test C4/Members
# It requires a working Koha database with the sample data

use Modern::Perl;

use Test::More tests => 20;
use Data::Dumper;

BEGIN {
    use_ok('C4::Biblio');
    use_ok('C4::Context');
    use_ok('C4::CourseReserves', qw/:all/);
    use_ok('C4::Items', qw(AddItemFromMarc));
    use_ok('MARC::Field');
    use_ok('MARC::Record');
}

my $dbh = C4::Context->dbh;

my $sth = $dbh->prepare("SELECT * FROM borrowers ORDER BY RAND() LIMIT 10");
$sth->execute();
my @borrowers = @{ $sth->fetchall_arrayref( {} ) };

# Create the item
my $record = MARC::Record->new();
$record->append_fields(
    MARC::Field->new( '952', '0', '0', a => 'CPL', b => 'CPL' )
);
my ( $biblionumber, $biblioitemnumber ) = C4::Biblio::AddBiblio($record, '');
my @iteminfo = C4::Items::AddItemFromMarc( $record, $biblionumber );
my $itemnumber = $iteminfo[2];

my $course_id = ModCourse(
    course_name => "Test Course",
    staff_note  => "Test staff note",
    public_note => "Test public note",
);

ok( $course_id, "ModCourse created course successfully" );

$course_id = ModCourse(
    course_id  => $course_id,
    staff_note => "Test staff note 2",
);

my $course = GetCourse($course_id);

ok( $course->{'course_name'} eq "Test Course",       "GetCourse returned correct course" );
ok( $course->{'staff_note'}  eq "Test staff note 2", "ModCourse updated course succesfully" );

my $courses = GetCourses();
ok( $courses->[0]->{'course_name'} eq "Test Course", "GetCourses returns valid array of course data" );

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

my $info = GetItemCourseReservesInfo( itemnumber => $itemnumber );
ok( $info->[0]->{'itemnumber'} eq $itemnumber, "GetItemReservesInfo returns valid data." );

DelCourseReserve( 'cr_id' => $cr_id );
$course_reserve = GetCourseReserve( 'cr_id' => $cr_id );
ok( !defined( $course_reserve->{'cr_id'} ), "DelCourseReserve functions correctly" );

DelCourse($course_id);
$course = GetCourse($course_id);
ok( !defined( $course->{'course_id'} ), "DelCourse deleted course successfully" );

END {
    C4::Items::DelItem( $dbh, $biblionumber, $itemnumber );
    C4::Biblio::DelBiblio( $biblionumber );
};
