#!/usr/bin/perl

# Copyright 2009 BibLibre
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

=head1 NAME

csv-profile.pl : Defines a CSV export profile

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

This script allow the user to define a new profile for CSV export

=head1 FUNCTIONS

=cut

use strict;
#use warnings; FIXME - Bug 2505
use Data::Dumper;
use Encode;

use C4::Auth;
use C4::Context;
use C4::Output;
use CGI;
use C4::Koha;
use C4::Csv;

my $input        = new CGI;
my $dbh          = C4::Context->dbh;

# open template
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "tools/csv-profiles.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => 'manage_csv_profiles' },
        debug           => 1,
    }
);

# Getting available encodings list
my @encodings = Encode->encodings();
my @encodings_loop = map{{encoding => $_}} @encodings;
$template->param(encodings => \@encodings_loop);

my $profile_name        = $input->param("profile_name");
my $profile_description = $input->param("profile_description");
my $csv_separator       = $input->param("csv_separator");
my $field_separator     = $input->param("field_separator");
my $subfield_separator  = $input->param("subfield_separator");
my $encoding            = $input->param("encoding");
my $type                = $input->param("profile_type");
my $action              = $input->param("action");
my $delete              = $input->param("delete");
my $id                  = $input->param("id");
if ($delete) { $action = "delete"; }

my $profile_content = $type eq "marc"
    ? $input->param("profile_marc_content")
    : $input->param("profile_sql_content");

if ($profile_name && $profile_content && $action) {
    my $rows;

    if ($action eq "create") {
    my $query = "INSERT INTO export_format(export_format_id, profile, description, content, csv_separator, field_separator, subfield_separator, encoding, type) VALUES (NULL, ?, ?, ?, ?, ?, ?, ?, ?)";
	my $sth   = $dbh->prepare($query);
    $rows  = $sth->execute($profile_name, $profile_description, $profile_content, $csv_separator, $field_separator, $subfield_separator, $encoding, $type);
    
    }

    if ($action eq "edit") {
    my $query = "UPDATE export_format SET description=?, content=?, csv_separator=?, field_separator=?, subfield_separator=?, encoding=?, type=? WHERE export_format_id=? LIMIT 1";
	my $sth   = $dbh->prepare($query);
    $rows  = $sth->execute($profile_description, $profile_content, $csv_separator, $field_separator, $subfield_separator, $encoding, $type, $profile_name);
    }

    if ($action eq "delete") {
	my $query = "DELETE FROM export_format WHERE export_format_id=? LIMIT 1";
	my $sth   = $dbh->prepare($query);
	$rows  = $sth->execute($profile_name);

    }

    $rows ? $template->param(success => 1) : $template->param(error => 1);
    $template->param(profile_name => $profile_name);
    $template->param(action => $action);

}

    # If a profile has been selected for modification
    if ($id) {
    my $query = "SELECT export_format_id, profile, description, content, csv_separator, field_separator, subfield_separator, encoding, type FROM export_format WHERE export_format_id = ?";
	my $sth;
	$sth = $dbh->prepare($query);

	$sth->execute($id);
	my $selected_profile = $sth->fetchrow_arrayref();
	$template->param(
	    selected_profile_id          => $selected_profile->[0],
	    selected_profile_name        => $selected_profile->[1],
	    selected_profile_description => $selected_profile->[2],
        selected_profile_content     => $selected_profile->[3],
	    selected_csv_separator       => $selected_profile->[4],
	    selected_field_separator     => $selected_profile->[5],
	    selected_subfield_separator  => $selected_profile->[6],
        selected_encoding            => $selected_profile->[7],
        selected_profile_type        => $selected_profile->[8]
	);

    }

    # List of existing profiles
    $template->param(existing_profiles => GetCsvProfilesLoop());

output_html_with_http_headers $input, $cookie, $template->output;
