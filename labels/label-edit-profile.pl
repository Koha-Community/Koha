#!/usr/bin/perl
#
# Copyright 2006 Katipo Communications.
# Parts Copyright 2009 Foundations Bible College.
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

use strict;
use warnings;

use CGI;

use C4::Auth qw(get_template_and_user);
use C4::Output qw(output_html_with_http_headers);
use C4::Creators;
use C4::Labels;

my $cgi = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "labels/label-edit-profile.tt",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
    }
);

my $op = $cgi->param('op');
my $profile_id = $cgi->param('profile_id') || $cgi->param('element_id');
my $profile = undef;
my $template_list = undef;
my @label_template = ();

my $units = get_unit_values();

if ($op eq 'edit') {
    $profile = C4::Labels::Profile->retrieve(profile_id => $profile_id);
    $template_list = get_all_templates(table_name => 'creator_templates', field_list => 'template_id,template_code, profile_id');
}
elsif ($op eq 'save') {
    my @params = (
        printer_name        => $cgi->param('printer_name') || 'DEFAULT PRINTER',
        paper_bin           => $cgi->param('paper_bin') || 'Tray 1',
        offset_horz         => $cgi->param('offset_horz') || 0,
        offset_vert         => $cgi->param('offset_vert') || 0,
        creep_horz          => $cgi->param('creep_horz') || 0,
        creep_vert          => $cgi->param('creep_vert') || 0,
        units               => $cgi->param('units') || 'POINT',
    );
    if ($profile_id) {   # if a label_id was passed in, this is an update to an existing layout
        $profile = C4::Labels::Profile->retrieve(profile_id => $profile_id);
        $profile->set_attr(@params);
        $profile->save();
    }
    else {      # if no label_id, this is a new layout so insert it
        $profile = C4::Labels::Profile->new(@params);
        $profile->save();
    }
    print $cgi->redirect("label-manage.pl?label_element=profile");
    exit;
}
else {  # if we get here, this is a new layout
    $profile = C4::Labels::Profile->new();
}

if ($profile_id) {
    @label_template = grep {
        ($_->{'profile_id'} == $profile->get_attr('profile_id')) && ($_->{'template_id'} == $profile->get_attr('template_id'));
        } @$template_list;
}

foreach my $unit (@$units) {
    if ($unit->{'type'} eq $profile->get_attr('units')) {
        $unit->{'selected'} = 1;
    }
}

$template->param(profile_id => $profile->get_attr('profile_id')) if $profile->get_attr('profile_id') > 0;

$template->param(
    label_template      => $label_template[0]->{'template_code'} || '',
    printer_name        => $profile->get_attr('printer_name'),
    paper_bin           => $profile->get_attr('paper_bin'),
    offset_horz         => $profile->get_attr('offset_horz'),
    offset_vert         => $profile->get_attr('offset_vert'),
    creep_horz          => $profile->get_attr('creep_horz'),
    creep_vert          => $profile->get_attr('creep_vert'),
    units               => $units,
    op                  => $op,
);

output_html_with_http_headers $cgi, $cookie, $template->output;
