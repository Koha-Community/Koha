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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 39;
use Test::Warn;

use C4::Context;
use Koha::Database;
use Koha::Patrons;

use t::lib::TestBuilder;

BEGIN {
    use_ok('Koha::Club');
    use_ok('Koha::Clubs');
    use_ok('Koha::Club::Field');
    use_ok('Koha::Club::Fields');
    use_ok('Koha::Club::Template');
    use_ok('Koha::Club::Templates');
    use_ok('Koha::Club::Template::Field');
    use_ok('Koha::Club::Template::Fields');
    use_ok('Koha::Club::Enrollment::Field');
    use_ok('Koha::Club::Enrollment::Fields');
    use_ok('Koha::Club::Template::EnrollmentField');
    use_ok('Koha::Club::Template::EnrollmentFields');
}

# Start transaction
my $database = Koha::Database->new();
my $schema   = $database->schema();
my $dbh      = C4::Context->dbh;
my $builder  = t::lib::TestBuilder->new;

$schema->storage->txn_begin();
$dbh->do("DELETE FROM club_templates");

my $categorycode = $builder->build( { source => 'Category' } )->{categorycode};
my $branchcode   = $builder->build( { source => 'Branch' } )->{branchcode};

my $patron = Koha::Patron->new(
    {
        surname      => 'Test 1',
        branchcode   => $branchcode,
        categorycode => $categorycode
    }
);
$patron->store();

my $club_template = Koha::Club::Template->new(
    {
        name                    => "Test Club Template",
        is_enrollable_from_opac => 0,
        is_email_required       => 0,
    }
)->store();
is( ref($club_template), 'Koha::Club::Template', 'Club template created' );

# Add some template fields
my $club_template_field_1 = Koha::Club::Template::Field->new(
    {
        club_template_id => $club_template->id,
        name             => 'Test Club Template Field 1',
    }
)->store();
is(
    ref($club_template_field_1),
    'Koha::Club::Template::Field', 'Club template field 1 created'
);

my $club_template_field_2 = Koha::Club::Template::Field->new(
    {
        club_template_id => $club_template->id,
        name             => 'Test Club Template Field 2',
    }
)->store();
is(
    ref($club_template_field_2),
    'Koha::Club::Template::Field', 'Club template field 2 created'
);

is(
    $club_template->club_template_fields->count,
    2, 'Club template has two fields'
);

## Add some template enrollment fields
my $club_template_enrollment_field_1 = Koha::Club::Template::EnrollmentField->new(
    {
        club_template_id => $club_template->id,
        name             => 'Test Club Template EnrollmentField 1',
    }
)->store();
is(
    ref($club_template_enrollment_field_1),
    'Koha::Club::Template::EnrollmentField',
    'Club template field 1 created'
);

my $club_template_enrollment_field_2 = Koha::Club::Template::EnrollmentField->new(
    {
        club_template_id => $club_template->id,
        name             => 'Test Club Template EnrollmentField 2',
    }
)->store();
is(
    ref($club_template_enrollment_field_2),
    'Koha::Club::Template::EnrollmentField',
    'Club template field 2 created'
);

is(
    $club_template->club_template_enrollment_fields->count,
    2, 'Club template has two enrollment fields'
);

## Create a club based on this template
Koha::Club->new(
    {
        club_template_id => $club_template->id,
        name             => "Test Expired Club",
        branchcode       => $branchcode,
        date_start       => '1900-01-01',
        date_end         => '1900-01-02',
    }
)->store();

my $club = Koha::Club->new(
    {
        club_template_id => $club_template->id,
        name             => "Test Club",
        branchcode       => $branchcode,
        date_start       => '1900-01-01',
        date_end         => '9999-01-01',
    }
)->store();

my $club_field_1 = Koha::Club::Field->new(
    {
        club_template_field_id => $club_template_field_1->id,
        club_id                => $club->id,
        value                  => 'TEST',
    }
)->store();
is( ref($club_field_1), 'Koha::Club::Field', 'Club field 1 created' );
is(
    $club_field_1->club_template_field->id,
    $club_template_field_1->id,
    'Field 2 is linked to correct template field'
);

my $club_field_2 = Koha::Club::Field->new(
    {
        club_template_field_id => $club_template_field_2->id,
        club_id                => $club->id,
        value                  => 'TEST',
    }
)->store();
is( ref($club_field_2), 'Koha::Club::Field', 'Club field 2 created' );
is(
    $club_field_2->club_template_field->id,
    $club_template_field_2->id,
    'Field 2 is linked to correct template field'
);

is( ref($club), 'Koha::Club', 'Club created' );
is(
    $club->club_template->id,
    $club_template->id, 'Club is using correct template'
);
is( $club->branch->id,         $branchcode, 'Club is using correct branch' );
is( $club->club_fields->count, 2,           'Club has correct number of fields' );
is(
    Koha::Clubs->get_enrollable( { borrower => $patron } )->count,
    1, 'Koha::Clubs->get_enrollable returns 1 enrollable club for patron'
);
is(
    $patron->get_enrollable_clubs->count,
    1, 'There is 1 enrollable club for patron'
);

## Create an enrollment for this club
my $club_enrollment = Koha::Club::Enrollment->new(
    {
        club_id        => $club->id,
        borrowernumber => $patron->id,
        branchcode     => $branchcode,
    }
)->store();
is(
    ref($club_enrollment), 'Koha::Club::Enrollment',
    'Club enrollment created'
);

my $club_enrollment_field_1 = Koha::Club::Enrollment::Field->new(
    {
        club_enrollment_id                => $club_enrollment->id,
        club_template_enrollment_field_id => $club_template_enrollment_field_1->id,
        value                             => 'TEST',
    }
)->store();
is(
    ref($club_enrollment_field_1),
    'Koha::Club::Enrollment::Field',
    'Enrollment field 1 created'
);

my $club_enrollment_field_2 = Koha::Club::Enrollment::Field->new(
    {
        club_enrollment_id                => $club_enrollment->id,
        club_template_enrollment_field_id => $club_template_enrollment_field_2->id,
        value                             => 'TEST',
    }
)->store();
is(
    ref($club_enrollment_field_2),
    'Koha::Club::Enrollment::Field',
    'Enrollment field 2 created'
);

is( $club_enrollment->club->id, $club->id, 'Got correct club for enrollment' );
is(
    Koha::Clubs->get_enrollable( { borrower => $patron } )->count,
    0, 'Koha::Clubs->get_enrollable returns 0 enrollable clubs for patron'
);
is(
    $patron->get_club_enrollments->count,
    1, 'Got 1 club enrollment for patron'
);
is(
    $patron->get_enrollable_clubs->count,
    0, 'No more enrollable clubs for patron'
);
is( $club->club_enrollments->count, 1, 'There is 1 enrollment for club' );

$schema->storage->txn_rollback();

subtest 'filter_out_empty' => sub {

    plan tests => 3;

    $schema->storage->txn_begin();

    my $club_template = $builder->build_object( { class => 'Koha::Club::Templates' } );

    # club_1 has 2 patrons
    my $club_1 = $builder->build_object(
        {
            class => 'Koha::Clubs',
            value => { club_template_id => $club_template->id }
        }
    );

    # club_2 has 1 patron but they canceled enrollment
    my $club_2 = $builder->build_object(
        {
            class => 'Koha::Clubs',
            value => { club_template_id => $club_template->id }
        }
    );

    # club_3 is empty
    my $club_3 = $builder->build_object(
        {
            class => 'Koha::Clubs',
            value => { club_template_id => $club_template->id }
        }
    );

    my $patron_1 = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron_2 = $builder->build_object( { class => 'Koha::Patrons' } );

    my $enrollment_1_1 = Koha::Club::Enrollment->new(
        {
            club_id        => $club_1->id,
            borrowernumber => $patron_1->borrowernumber,
            branchcode     => $patron_1->branchcode,
        }
    )->store();
    my $enrollment_2_1 = Koha::Club::Enrollment->new(
        {
            club_id        => $club_2->id,
            borrowernumber => $patron_1->borrowernumber,
            branchcode     => $patron_1->branchcode,
        }
    )->store();
    my $enrollment_1_2 = Koha::Club::Enrollment->new(
        {
            club_id        => $club_1->id,
            borrowernumber => $patron_2->borrowernumber,
            branchcode     => $patron_2->branchcode,
        }
    )->store();

    $enrollment_2_1->cancel;

    my $clubs = Koha::Clubs->search( { club_template_id => $club_template->id } );

    is( $clubs->count, 3, 'Base resultset has all the clubs' );

    my $filtered_out_rs = $clubs->filter_out_empty;

    is( $filtered_out_rs->count,    1,           'Only one club has patron enrolled' );
    is( $filtered_out_rs->next->id, $club_1->id, 'Correct club is considered non-empty' );

    $schema->storage->txn_rollback();
    }
