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
        template_name   => "labels/label-edit-template.tt",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
    }
);

my $op = $cgi->param('op');
my $template_id = $cgi->param('template_id') || $cgi->param('element_id');
my $label_template = undef;
my $profile_list = undef;

my $units = get_unit_values();

if ($op eq 'edit') {
    $label_template = C4::Labels::Template->retrieve(template_id => $template_id);
    $profile_list = get_all_profiles(field_list => 'profile_id,printer_name,paper_bin',filter => "template_id=$template_id OR template_id=''");
    push @$profile_list, {paper_bin => 'N/A', profile_id => 0, printer_name => 'No Profile'};
    foreach my $profile (@$profile_list) {
        if ($profile->{'profile_id'} == $label_template->get_attr('profile_id')) {
            $profile->{'selected'} = 1;
        }
        else {
            $profile->{'selected'} = 0;
        }
    }
}
elsif ($op eq 'save') {
    my @params = (      profile_id      => $cgi->param('profile_id'),
                        template_code   => $cgi->param('template_code') || 'DEFAULT_TEMPLATE',
                        template_desc   => $cgi->param('template_desc') || 'Default description',
                        page_width      => $cgi->param('page_width') || 0,
                        page_height     => $cgi->param('page_height') || 0,
                        label_width     => $cgi->param('label_width') || 0,
                        label_height    => $cgi->param('label_height') || 0,
                        top_text_margin => $cgi->param('top_text_margin') || 0,
                        left_text_margin=> $cgi->param('left_text_margin') || 0,
                        top_margin      => $cgi->param('top_margin') || 0,
                        left_margin     => $cgi->param('left_margin') || 0,
                        cols            => $cgi->param('cols') || 0,
                        rows            => $cgi->param('rows') || 0,
                        col_gap         => $cgi->param('col_gap') || 0,
                        row_gap         => $cgi->param('row_gap') || 0,
                        units           => $cgi->param('units') || 'POINT',
                        );
    if ($template_id) {   # if a template_id was passed in, this is an update to an existing template
        $label_template = C4::Labels::Template->retrieve(template_id => $template_id);
        if ($cgi->param('profile_id') && ($label_template->get_attr('template_id') != $cgi->param('profile_id'))) {
            # Release the old profile if one is currently associated
            if ($label_template->get_attr('profile_id') > 0) {
                my $old_profile = C4::Labels::Profile->retrieve(profile_id => $label_template->get_attr('profile_id'));
                $old_profile->set_attr(template_id => 0);
                $old_profile->save();
            }
            my $new_profile = C4::Labels::Profile->retrieve(profile_id => $cgi->param('profile_id'));
            $new_profile->set_attr(template_id => $label_template->get_attr('template_id'));
            $new_profile->save();
        }
        elsif ($cgi->param('profile_id') == 0) { # Disassociate any printer profile from the template
            if ($label_template->get_attr('profile_id') > 0) {
                my $old_profile = C4::Labels::Profile->retrieve(profile_id => $label_template->get_attr('profile_id'));
                $old_profile->set_attr(template_id => 0);
                $old_profile->save();
            }
        }

        $label_template->set_attr(@params);
        $label_template->save();
    }
    else {      # if no template_id, this is a new template so insert it
        $label_template = C4::Labels::Template->new(@params);
        my $template_id = $label_template->save();
        if ($cgi->param('profile_id')) {
            my $profile = C4::Labels::Profile->retrieve(profile_id => $cgi->param('profile_id'));
            $profile->set_attr(template_id => $template_id) if $template_id != $profile->get_attr('template_id');
            $profile->save();
        }
    }
    print $cgi->redirect("label-manage.pl?label_element=template");
    exit;
}
else {  # if we get here, this is a new layout
    $label_template = C4::Labels::Template->new();
    $profile_list = get_all_profiles(field_list => 'profile_id,printer_name,paper_bin',filter => "template_id=''");
    push @$profile_list, {paper_bin => 'N/A', profile_id => 0, printer_name => 'No Profile'};
    foreach my $profile (@$profile_list) {
        if ($profile->{'profile_id'} == 0) {
            $profile->{'selected'} = 1;
        }
        else {
            $profile->{'selected'} = 0;
        }
    }
}

foreach my $unit (@$units) {
    if ($unit->{'type'} eq $label_template->get_attr('units')) {
        $unit->{'selected'} = 1;
    }
}

$template->param(
    profile_list         => $profile_list,
    template_id          => ($label_template->get_attr('template_id') > 0) ? $label_template->get_attr('template_id') : '',
    template_code        => $label_template->get_attr('template_code'),
    template_desc        => $label_template->get_attr('template_desc'),
    page_width           => $label_template->get_attr('page_width'),
    page_height          => $label_template->get_attr('page_height'),
    label_width          => $label_template->get_attr('label_width'),
    label_height         => $label_template->get_attr('label_height'),
    top_text_margin      => $label_template->get_attr('top_text_margin'),
    left_text_margin     => $label_template->get_attr('left_text_margin'),
    top_margin           => $label_template->get_attr('top_margin'),
    left_margin          => $label_template->get_attr('left_margin'),
    cols                 => $label_template->get_attr('cols'),
    rows                 => $label_template->get_attr('rows'),
    col_gap              => $label_template->get_attr('col_gap'),
    row_gap              => $label_template->get_attr('row_gap'),
    units                => $units,
);

output_html_with_http_headers $cgi, $cookie, $template->output;
