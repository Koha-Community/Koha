#!/usr/bin/perl

# Copyright 2013 ByWater Solutions
#
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

use CGI;

use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use Koha::DateUtils qw( dt_from_string );
use Koha::Club::Templates;
use Koha::Club::Template::Fields;
use Koha::Club::Template::EnrollmentFields;

use Koha::Database;
my $schema = Koha::Database->new()->schema();

my $cgi = CGI->new;

my $op = $cgi->param('op') || q{};
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => 'clubs/templates-add-modify.tt',
        query         => $cgi,
        type          => 'intranet',
        flagsrequired => { clubs => 'edit_templates' },
    }
);

my $id = $cgi->param('id');

my $club_template;
my $stored;

if ( $cgi->param('name') && $op eq 'cud-update' ) {    # Update or create club
    if ($id) {
        $club_template = Koha::Club::Templates->find($id);
        $stored        = 'updated';
    } else {
        $club_template = Koha::Club::Template->new();
        $stored        = 'created';
    }

    $club_template->set(
        {
            id                      => $id                               || undef,
            name                    => scalar $cgi->param('name')        || undef,
            description             => scalar $cgi->param('description') || undef,
            branchcode              => scalar $cgi->param('branchcode')  || undef,
            date_updated            => dt_from_string(),
            is_email_required       => scalar $cgi->param('is_email_required')       ? 1 : 0,
            is_enrollable_from_opac => scalar $cgi->param('is_enrollable_from_opac') ? 1 : 0,
        }
    )->store();

    $id ||= $club_template->id();

    # Update club creation fields
    my @field_id                        = $cgi->multi_param('club_template_field_id');
    my @field_name                      = $cgi->multi_param('club_template_field_name');
    my @field_description               = $cgi->multi_param('club_template_field_description');
    my @field_authorised_value_category = $cgi->multi_param('club_template_field_authorised_value_category');

    my @field_delete = $cgi->multi_param('club_template_field_delete');

    for ( my $i = 0 ; $i < @field_id ; $i++ ) {
        my $field_id                        = $field_id[$i];
        my $field_name                      = $field_name[$i];
        my $field_description               = $field_description[$i];
        my $field_authorised_value_category = $field_authorised_value_category[$i];

        my $field =
            $field_id
            ? Koha::Club::Template::Fields->find($field_id)
            : Koha::Club::Template::Field->new();

        if ( grep { $_ eq $field_id } @field_delete ) {
            $field->delete();
        } else {
            $field->set(
                {
                    club_template_id          => $id,
                    name                      => $field_name,
                    description               => $field_description,
                    authorised_value_category => $field_authorised_value_category,
                }
            )->store();
        }
    }

    # Update club enrollment fields
    @field_id                        = $cgi->multi_param('club_template_enrollment_field_id');
    @field_name                      = $cgi->multi_param('club_template_enrollment_field_name');
    @field_description               = $cgi->multi_param('club_template_enrollment_field_description');
    @field_authorised_value_category = $cgi->multi_param('club_template_enrollment_field_authorised_value_category');

    @field_delete = $cgi->multi_param('club_template_enrollment_field_delete');

    for ( my $i = 0 ; $i < @field_id ; $i++ ) {
        my $field_id                        = $field_id[$i];
        my $field_name                      = $field_name[$i];
        my $field_description               = $field_description[$i];
        my $field_authorised_value_category = $field_authorised_value_category[$i];

        my $field =
            $field_id
            ? Koha::Club::Template::EnrollmentFields->find($field_id)
            : Koha::Club::Template::EnrollmentField->new();

        if ( grep { $_ eq $field_id } @field_delete ) {
            $field->delete();
        } else {
            $field->set(
                {
                    id                        => $field_id,
                    club_template_id          => $id,
                    name                      => $field_name,
                    description               => $field_description,
                    authorised_value_category => $field_authorised_value_category,
                }
            )->store();
        }
    }

    print $cgi->redirect("/cgi-bin/koha/clubs/clubs.pl?stored=$stored&club_template_id=$id");
    exit;
}

$club_template ||= Koha::Club::Templates->find($id);
$template->param( club_template => $club_template );

output_html_with_http_headers( $cgi, $cookie, $template->output );
