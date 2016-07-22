#!/usr/bin/perl

# Copyright 2009 BibLibre
# Copyright 2015 Koha Development Team
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

use Modern::Perl;
use Encode;

use C4::Auth;
use C4::Context;
use C4::Output;
use CGI qw ( -utf8 );
use C4::Koha;
use Koha::CsvProfiles;

my $input            = new CGI;
my $export_format_id = $input->param('export_format_id');
my $op               = $input->param('op') || 'list';
my @messages;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "tools/csv-profiles.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => 'manage_csv_profiles' },
        debug           => 1,
    }
);

# Getting available encodings list
$template->param( encodings => [ Encode->encodings ] );

if ( $op eq 'add_form' ) {
    my $csv_profile;
    if ($export_format_id) {
        $csv_profile = Koha::CsvProfiles->find($export_format_id);
    }
    $template->param( csv_profile => $csv_profile, );
} elsif ( $op eq 'add_validate' ) {
    my $profile     = $input->param("profile");
    my $description = $input->param("description");
    my $type        = $input->param("type");
    my $content =
        $type eq "marc"
      ? $input->param("marc_content")
      : $input->param("sql_content");
    my $csv_separator      = $input->param("csv_separator");
    my $field_separator    = $input->param("field_separator");
    my $subfield_separator = $input->param("subfield_separator");
    my $encoding           = $input->param("encoding");

    if ($export_format_id) {
        my $csv_profile = Koha::CsvProfiles->find($export_format_id)
            or die "Something went wrong! This export_format_id does not match any existing CSV profile.";
        $csv_profile->profile($profile);
        $csv_profile->description($description);
        $csv_profile->content($content);
        $csv_profile->csv_separator($csv_separator);
        $csv_profile->field_separator($field_separator);
        $csv_profile->subfield_separator($subfield_separator);
        $csv_profile->encoding($encoding);
        $csv_profile->type($type);
        eval { $csv_profile->store; };

        if ($@) {
            push @messages, { type => 'error', code => 'error_on_update' };
        } else {
            push @messages, { type => 'message', code => 'success_on_update' };
        }
    } else {
        my $csv_profile = Koha::CsvProfile->new(
            {   profile            => $profile,
                description        => $description,
                content            => $content,
                csv_separator      => $csv_separator,
                field_separator    => $field_separator,
                subfield_separator => $subfield_separator,
                encoding           => $encoding,
                type               => $type,
            }
        );
        eval { $csv_profile->store; };
        if ($@) {
            push @messages, { type => 'error', code => 'error_on_insert' };
        } else {
            push @messages, { type => 'message', code => 'success_on_insert' };
        }
    }
    $op = 'list';
} elsif ( $op eq 'delete_confirm' ) {
    my $csv_profile = Koha::CsvProfiles->find($export_format_id);
    $template->param( csv_profile => $csv_profile, );
} elsif ( $op eq 'delete_confirmed' ) {
    my $csv_profile = Koha::CsvProfiles->find($export_format_id);
    my $deleted = eval { $csv_profile->delete; };

    if ( $@ or not $deleted ) {
        push @messages, { type => 'error', code => 'error_on_delete' };
    } else {
        push @messages, { type => 'message', code => 'success_on_delete' };
    }
    $op = 'list';
}

if ( $op eq 'list' ) {
    my $csv_profiles = Koha::CsvProfiles->search;
    $template->param( csv_profiles => $csv_profiles, );
}

$template->param(
    messages => \@messages,
    op       => $op,
);

output_html_with_http_headers $input, $cookie, $template->output;
