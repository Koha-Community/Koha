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

use Data::Dumper; # REMOVEME with diag
use Test::More tests => 3;
use Test::MockModule;
use Test::MockTime qw( set_fixed_time );
use t::lib::TestBuilder;

use C4::Biblio;
use C4::Items;
use C4::Members;
use C4::Circulation;

use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Library;
use Koha::Patrons;
use DateTime::Duration;

use MARC::Record;

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

$dbh->do(q|DELETE FROM issues|);
$dbh->do(q|DELETE FROM borrowers|);
$dbh->do(q|DELETE FROM items|);
$dbh->do(q|DELETE FROM biblio|);
$dbh->do(q|DELETE FROM categories|);
$dbh->do(q|DELETE FROM letter|);

my $builder = t::lib::TestBuilder->new;
set_fixed_time(CORE::time());

my $branchcode   = $builder->build({ source => 'Branch' })->{ branchcode };
my $categorycode = $builder->build({ source => 'Category' })->{ categorycode };
my $itemtype     = $builder->build({ source => 'Itemtype' })->{ itemtype };

my %item_infos = (
    homebranch    => $branchcode,
    holdingbranch => $branchcode,
    itype         => $itemtype
);


my $slip_content = <<EOS;
Checked out:
<checkedout>
Title: <<biblio.title>>
Barcode: <<items.barcode>>
Date due: <<issues.date_due>>
</checkedout>

Overdues:
<overdue>
Title: <<biblio.title>>
Barcode: <<items.barcode>>
Date due: <<issues.date_due>>
</overdue>
EOS

$dbh->do(q|
    INSERT INTO letter( module, code, branchcode, name, is_html, title, content, message_transport_type) VALUES ('circulation', 'ISSUESLIP', '', 'Issue Slip', 0, 'Issue Slip', ?, 'email')
|, {}, $slip_content);

my $quick_slip_content = <<EOS;
Checked out today:
<checkedout>
Title: <<biblio.title>>
Barcode: <<items.barcode>>
Date due: <<issues.date_due>>
</checkedout>
EOS

$dbh->do(q|
    INSERT INTO letter( module, code, branchcode, name, is_html, title, content, message_transport_type) VALUES ('circulation', 'ISSUEQSLIP', '', 'Issue Quick Slip', 0, 'Issue Quick Slip', ?, 'email')
|, {}, $quick_slip_content);

my ( $title1, $title2 ) = ( 'My title 1', 'My title 2' );
my ( $barcode1, $barcode2 ) = ('BC0101', 'BC0202' );
my $record = MARC::Record->new;
$record->append_fields(
    MARC::Field->new(
        245, '1', '4',
            a => $title1,
    ),
);
my ($biblionumber1) = AddBiblio( $record, '' );
my $itemnumber1 =
  AddItem( { barcode => $barcode1, %item_infos }, $biblionumber1 );

$record = MARC::Record->new;
$record->append_fields(
    MARC::Field->new(
        245, '1', '4',
            a => $title2,
    ),
);
my ($biblionumber2) = AddBiblio( $record, '' );
my $itemnumber2 =
  AddItem( { barcode => $barcode2, %item_infos }, $biblionumber2 );

my $borrowernumber =
  AddMember( categorycode => $categorycode, branchcode => $branchcode );
my $borrower = Koha::Patrons->find( $borrowernumber )->unblessed;

my $module = new Test::MockModule('C4::Context');
$module->mock( 'userenv', sub { { branch => $branchcode } } );

my $today = dt_from_string;
my $yesterday = dt_from_string->subtract_duration( DateTime::Duration->new( days => 1 ) );

subtest 'Issue slip' => sub {
    plan tests => 3;

    subtest 'Empty slip' => sub {
        plan tests => 1;
        my $slip = IssueSlip( $branchcode, $borrowernumber );
        my $empty_slip = <<EOS;
Checked out:


Overdues:

EOS
        is( $slip->{content}, $empty_slip, 'No checked out or overdues return an empty slip, it should return undef (FIXME)' );
    };

    subtest 'Daily loans' => sub {
        plan tests => 2;
        skip "It's 23:59!", 2 if $today->hour == 23 and $today->minute == 59;
        # Test 1: No overdue
        my $today_daily = $today->clone->set( hour => 23, minute => 59 );
        my $today_daily_as_formatted = output_pref( $today_daily );
        my $yesterday_daily = $yesterday->clone->set( hour => 23, minute => 59 );
        my $yesterday_daily_as_formatted = output_pref( $yesterday_daily );

        my ( $date_due, $issue_date, $slip, $expected_slip );
        $date_due = $today_daily;
        $issue_date = $today_daily->clone->subtract_duration( DateTime::Duration->new( minutes => 1 ) );
        AddIssue( $borrower, $barcode1, $date_due, undef, $issue_date );
        $date_due = $today_daily;
        $issue_date = $yesterday_daily;
        AddIssue( $borrower, $barcode2, $date_due, undef, $issue_date );

        $expected_slip = <<EOS;
Checked out:

Title: $title1
Barcode: $barcode1
Date due: $today_daily_as_formatted


Title: $title2
Barcode: $barcode2
Date due: $today_daily_as_formatted


Overdues:

EOS
        $slip = IssueSlip( $branchcode, $borrowernumber );
        is( $slip->{content}, $expected_slip , 'IssueSlip should return a slip with 2 checkouts');

        AddReturn( $barcode1, $branchcode );
        AddReturn( $barcode2, $branchcode );

        # Test 2: 1 Overdue
        $date_due = $today_daily;
        $issue_date = $today_daily->clone->subtract_duration( DateTime::Duration->new( minutes => 1 ) );
        AddIssue( $borrower, $barcode1, $date_due, undef, $issue_date );
        $date_due = $yesterday_daily;
        $issue_date = $yesterday_daily;
        AddIssue( $borrower, $barcode2, $date_due, undef, $issue_date );

        $expected_slip = <<EOS;
Checked out:

Title: $title1
Barcode: $barcode1
Date due: $today_daily_as_formatted


Overdues:

Title: $title2
Barcode: $barcode2
Date due: $yesterday_daily_as_formatted

EOS
        $slip = IssueSlip( $branchcode, $borrowernumber );
        is( $slip->{content}, $expected_slip, 'IssueSlip should return a slip with 1 checkout and 1 overdue');

        AddReturn( $barcode1, $branchcode );
        AddReturn( $barcode2, $branchcode );
    };

    subtest 'Hourly loans' => sub {
        plan tests => 2;
        skip "It's 23:59!", 2 if $today->hour == 23 and $today->minute == 59;
        # Test 1: No overdue
        my ( $date_due_in_time, $date_due_in_time_as_formatted, $date_due_in_late, $date_due_in_late_as_formatted, $issue_date, $slip, $expected_slip );
        # Assuming today is not hour = 23 and minute = 59
        $date_due_in_time = $today->clone->set(hour => ($today->hour < 23 ? $today->hour + 1 : 23), minute => 59);
        $date_due_in_time_as_formatted = output_pref( $date_due_in_time );
        $issue_date = $date_due_in_time->clone->subtract_duration( DateTime::Duration->new( minutes => 1 ) );
        AddIssue( $borrower, $barcode1, $date_due_in_time, undef, $issue_date );
        $issue_date = $yesterday->clone;
        AddIssue( $borrower, $barcode2, $date_due_in_time, undef, $issue_date );

        # Set timestamps to the same value to avoid a different order
        Koha::Checkouts->search(
            { borrowernumber => $borrower->{borrowernumber} }
        )->update( { timestamp => dt_from_string } );

        $expected_slip = <<EOS;
Checked out:

Title: $title1
Barcode: $barcode1
Date due: $date_due_in_time_as_formatted


Title: $title2
Barcode: $barcode2
Date due: $date_due_in_time_as_formatted


Overdues:

EOS
        $slip = IssueSlip( $branchcode, $borrowernumber );
        is( $slip->{content}, $expected_slip, 'IssueSlip should return a slip with 2 checkouts' )
            or diag(Dumper(Koha::Checkouts->search({borrowernumber => $borrower->{borrowernumber}})->unblessed));

        AddReturn( $barcode1, $branchcode );
        AddReturn( $barcode2, $branchcode );

        # Test 2: 1 Overdue
        $date_due_in_time = $today->clone->set(hour => ($today->hour < 23 ? $today->hour + 1 : 23), minute => 59);
        $date_due_in_time_as_formatted = output_pref( $date_due_in_time );
        $issue_date = $date_due_in_time->clone->subtract_duration( DateTime::Duration->new( minutes => 1 ) );
        AddIssue( $borrower, $barcode1, $date_due_in_time, undef, $issue_date );
        $date_due_in_late = $today->clone->subtract( hours => 1 );
        $date_due_in_late_as_formatted = output_pref( $date_due_in_late );
        $issue_date = $yesterday->clone;
        AddIssue( $borrower, $barcode2, $date_due_in_late, undef, $issue_date );

        $expected_slip = <<EOS;
Checked out:

Title: $title1
Barcode: $barcode1
Date due: $date_due_in_time_as_formatted


Overdues:

Title: $title2
Barcode: $barcode2
Date due: $date_due_in_late_as_formatted

EOS
        $slip = IssueSlip( $branchcode, $borrowernumber );
        is( $slip->{content}, $expected_slip, 'IssueSlip should return a slip with 1 checkout and 1 overdue' );

        AddReturn( $barcode1, $branchcode );
        AddReturn( $barcode2, $branchcode );
    };

};

subtest 'Quick slip' => sub {
    plan tests => 3;

    subtest 'Empty slip' => sub {
        plan tests => 1;
        my $slip = IssueSlip( $branchcode, $borrowernumber, 'quick slip' );
        my $empty_slip = <<EOS;
Checked out today:

EOS
        is( $slip->{content}, $empty_slip, 'No checked out or overdues return an empty slip, it should return undef (FIXME)' );
    };

    subtest 'Daily loans' => sub {
        plan tests => 2;
        skip "It's 23:59!", 2 if $today->hour == 23 and $today->minute == 59;
        # Test 1: No overdue
        my $today_daily = $today->clone->set( hour => 23, minute => 59 );
        my $today_daily_as_formatted = output_pref( $today_daily );
        my $yesterday_daily = $yesterday->clone->set( hour => 23, minute => 59 );
        my $yesterday_daily_as_formatted = output_pref( $yesterday_daily );

        my ( $date_due, $issue_date, $slip, $expected_slip );
        $date_due = $today_daily;
        $issue_date = $today_daily->clone->subtract_duration( DateTime::Duration->new( minutes => 1 ) );
        AddIssue( $borrower, $barcode1, $date_due, undef, $issue_date );
        $date_due = $today_daily;
        $issue_date = $yesterday_daily;
        AddIssue( $borrower, $barcode2, $date_due, undef, $issue_date );

        $expected_slip = <<EOS;
Checked out today:

Title: $title1
Barcode: $barcode1
Date due: $today_daily_as_formatted

EOS
        $slip = IssueSlip( $branchcode, $borrowernumber, 'quick slip' );
        is( $slip->{content}, $expected_slip, 'IssueSlip should return 2 checkouts for today');

        AddReturn( $barcode1, $branchcode );
        AddReturn( $barcode2, $branchcode );

        # Test 2: 1 Overdue
        $date_due = $today_daily;
        $issue_date = $today_daily->clone->subtract_duration( DateTime::Duration->new( minutes => 1 ) );
        AddIssue( $borrower, $barcode1, $date_due, undef, $issue_date );
        $date_due = $yesterday_daily;
        $issue_date = $yesterday_daily;
        AddIssue( $borrower, $barcode2, $date_due, undef, $issue_date );

        $expected_slip = <<EOS;
Checked out today:

Title: $title1
Barcode: $barcode1
Date due: $today_daily_as_formatted

EOS
        $slip = IssueSlip( $branchcode, $borrowernumber, 'quickslip' );
        is( $slip->{content}, $expected_slip );
    };

    subtest 'Hourly loans' => sub {
        plan tests => 2;
        # Test 1: No overdue
        my ( $date_due_in_time, $date_due_in_time_as_formatted, $date_due_in_late, $date_due_in_late_as_formatted, $issue_date, $slip, $expected_slip );
        # Assuming today is not hour = 23 and minute = 59
        $date_due_in_time = $today->clone->set(hour => ($today->hour < 23 ? $today->hour + 1 : 23), minute => 59);
        $date_due_in_time_as_formatted = output_pref( $date_due_in_time );
        $issue_date = $date_due_in_time->clone->subtract_duration( DateTime::Duration->new( minutes => 1 ) );
        AddIssue( $borrower, $barcode1, $date_due_in_time, undef, $issue_date );
        $issue_date = $yesterday->clone;
        AddIssue( $borrower, $barcode2, $date_due_in_time, undef, $issue_date );

        $expected_slip = <<EOS;
Checked out today:

Title: $title1
Barcode: $barcode1
Date due: $date_due_in_time_as_formatted

EOS
        $slip = IssueSlip( $branchcode, $borrowernumber, 'quickslip' );
        is( $slip->{content}, $expected_slip );

        AddReturn( $barcode1, $branchcode );
        AddReturn( $barcode2, $branchcode );

        # Test 2: 1 Overdue
        $date_due_in_time = $today->clone->set(hour => ($today->hour < 23 ? $today->hour + 1 : 23), minute => 59);
        $date_due_in_time_as_formatted = output_pref( $date_due_in_time );
        $issue_date = $date_due_in_time->clone->subtract_duration( DateTime::Duration->new( minutes => 1 ) );
        AddIssue( $borrower, $barcode1, $date_due_in_time, undef, $issue_date );
        $date_due_in_late = $today->clone->subtract( hours => 1 );
        $date_due_in_late_as_formatted = output_pref( $date_due_in_late );
        $issue_date = $yesterday->clone;
        AddIssue( $borrower, $barcode2, $date_due_in_late, undef, $issue_date );

        $expected_slip = <<EOS;
Checked out today:

Title: $title1
Barcode: $barcode1
Date due: $date_due_in_time_as_formatted

EOS
        $slip = IssueSlip( $branchcode, $borrowernumber, 'quickslip' );
        is( $slip->{content}, $expected_slip );

        AddReturn( $barcode1, $branchcode );
        AddReturn( $barcode2, $branchcode );
    };

};

subtest 'bad calls' => sub {
    plan tests => 1;
    my $slip = IssueSlip();
    is( $slip, undef, 'IssueSlip should return if no valid borrowernumber is passed' );
};

$schema->storage->txn_rollback;

