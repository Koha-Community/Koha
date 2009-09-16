#!/usr/bin/perl

# Copyright 2009 BibLibre
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

=head1 NAME

csv-profile.pl : Defines a CSV export profile

=head1 SYNOPSIS


=head1 DESCRIPTION

This script allow the user to define a new profile for CSV export

=head1 FUNCTIONS

=over 2

=cut

use strict;
use Data::Dumper;

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
        template_name   => "tools/csv-profiles.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => 'manage_csv_profiles' },
        debug           => 1,
    }
);


my $profile_name        = $input->param("profile_name");
my $profile_description = $input->param("profile_description");
my $profile_content     = $input->param("profile_content");
my $action              = $input->param("action");
my $delete              = $input->param("delete");
my $id                  = $input->param("id");
if ($delete) { $action = "delete"; }

if ($profile_name && $profile_content && $profile_description && $action) {
    my $rows;

    if ($action eq "create") {
	my $query = "INSERT INTO export_format(export_format_id, profile, description, marcfields) VALUES (NULL, ?, ?, ?)";
	my $sth   = $dbh->prepare($query);
	$rows  = $sth->execute($profile_name, $profile_description, $profile_content);
    
    }

    if ($action eq "edit") {
	my $query = "UPDATE export_format SET description=?, marcfields=? WHERE export_format_id=? LIMIT 1";
	my $sth   = $dbh->prepare($query);
	$rows  = $sth->execute($profile_description, $profile_content, $profile_name);

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
	my $query = "SELECT export_format_id, profile, description, marcfields FROM export_format WHERE export_format_id = ?";
	my $sth;
	$sth = $dbh->prepare($query);

	$sth->execute($id);
	my $selected_profile = $sth->fetchrow_arrayref();
	$template->param(
	    selected_profile_id          => $selected_profile->[0],
	    selected_profile_name        => $selected_profile->[1],
	    selected_profile_description => $selected_profile->[2],
	    selected_profile_marcfields  => $selected_profile->[3]
	);

    }

    # List of existing profiles
    $template->param(existing_profiles => GetCsvProfilesLoop());

output_html_with_http_headers $input, $cookie, $template->output;
