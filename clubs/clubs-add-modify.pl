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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use CGI;

use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Clubs;
use Koha::Club::Fields;

my $cgi = CGI->new;

my $op = $cgi->param('op') || q{};
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => 'clubs/clubs-add-modify.tt',
        query         => $cgi,
        type          => 'intranet',
        flagsrequired => { clubs => 'edit_clubs' },
    }
);

my $schema = Koha::Database->new()->schema();

my $id   = $cgi->param('id');
my $club = $id ? Koha::Clubs->find($id) : Koha::Club->new();

my $stored =
      $cgi->param('name')
    ? $id
        ? 'updated'
        : 'stored'
    : undef;

my $club_template_id = $cgi->param('club_template_id');
my $club_template    = $club->club_template() || Koha::Club::Templates->find($club_template_id);
$club_template_id ||= $club_template->id();

my $date_start = $cgi->param('date_start') || undef;
my $date_end   = $cgi->param('date_end')   || undef;

if ( $cgi->param('name') && $op eq 'cud-update' ) {    # Update or create club
    $club->set(
        {
            club_template_id => scalar $cgi->param('club_template_id') || undef,
            name             => scalar $cgi->param('name')             || undef,
            description      => scalar $cgi->param('description')      || undef,
            branchcode       => scalar $cgi->param('branchcode')       || undef,
            date_start       => $date_start,
            date_end         => $date_end,
            date_updated     => dt_from_string(),
        }
    )->store();

    my @club_template_field_id = $cgi->multi_param('club_template_field_id');
    my @club_field_id          = $cgi->multi_param('club_field_id');
    my @club_field             = $cgi->multi_param('club_field');

    for ( my $i = 0 ; $i < @club_template_field_id ; $i++ ) {
        my $club_template_field_id = $club_template_field_id[$i] || undef;
        my $club_field_id          = $club_field_id[$i]          || undef;
        my $club_field             = $club_field[$i]             || undef;

        my $field =
            $club_field_id
            ? Koha::Club::Fields->find($club_field_id)
            : Koha::Club::Field->new();

        $field->set(
            {
                club_id                => $club->id(),
                club_template_field_id => $club_template_field_id,
                value                  => $club_field,
            }
        )->store();
    }

    $id ||= $club->id();

    print $cgi->redirect("/cgi-bin/koha/clubs/clubs.pl?stored=$stored&club_id=$id");
    exit;
}

$club = Koha::Clubs->find($id);

$template->param(
    club_template => $club_template,
    club          => $club,
);

output_html_with_http_headers( $cgi, $cookie, $template->output );
