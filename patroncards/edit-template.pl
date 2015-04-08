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
use autouse 'Data::Dumper' => qw(Dumper);

use C4::Auth qw(get_template_and_user);
use C4::Output qw(output_html_with_http_headers);
use C4::Creators;
use C4::Patroncards;

my $cgi = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "patroncards/edit-template.tt",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
    }
);

my $op = $cgi->param('op') || '';
my $template_id = $cgi->param('template_id') || $cgi->param('element_id');
my $card_template = undef;
my $profile_list = undef;

my $units = get_unit_values();

if ($op eq 'edit') {
    $card_template = C4::Patroncards::Template->retrieve(template_id => $template_id);
    $profile_list = get_all_profiles(field_list => 'profile_id,printer_name,paper_bin', filter => "template_id=$template_id OR template_id=''");
}
elsif ($op eq 'save') {
    my @params = (      profile_id      => $cgi->param('profile_id') || '',
                        template_code   => $cgi->param('template_code'),
                        template_desc   => $cgi->param('template_desc'),
                        page_width      => $cgi->param('page_width'),
                        page_height     => $cgi->param('page_height'),
                        label_width     => $cgi->param('card_width'),
                        label_height    => $cgi->param('card_height'),
                        top_margin      => $cgi->param('top_margin'),
                        left_margin     => $cgi->param('left_margin'),
                        cols            => $cgi->param('cols'),
                        rows            => $cgi->param('rows'),
                        col_gap         => $cgi->param('col_gap'),
                        row_gap         => $cgi->param('row_gap'),
                        units           => $cgi->param('units'),
                        );
    if ($template_id) {   # if a template_id was passed in, this is an update to an existing template
        $card_template = C4::Patroncards::Template->retrieve(template_id => $template_id);
        if ($cgi->param('profile_id') && ($card_template->get_attr('template_id') != $cgi->param('profile_id'))) {
            if ($card_template->get_attr('profile_id') > 0) {   # no need to get the old one if there was no profile associated
                my $old_profile = C4::Patroncards::Profile->retrieve(profile_id => $card_template->get_attr('profile_id'));
                $old_profile->set_attr(template_id => 0);
                $old_profile->save();
            }
            my $new_profile = C4::Patroncards::Profile->retrieve(profile_id => $cgi->param('profile_id'));
            $new_profile->set_attr(template_id => $card_template->get_attr('template_id'));
            $new_profile->save();
        }
        $card_template->set_attr(@params);
        $card_template->save();
    }
    else {      # if no template_id, this is a new template so insert it
        $card_template = C4::Patroncards::Template->new(@params);
        die "Error: $card_template\n" if !ref($card_template);
        my $template_id = $card_template->save();
        if ($cgi->param('profile_id')) {
            my $profile = C4::Patroncards::Profile->retrieve(profile_id => $cgi->param('profile_id'));
            $profile->set_attr(template_id => $template_id) if $template_id != $profile->get_attr('template_id');
            $profile->save();
        }
    }
    print $cgi->redirect("manage.pl?card_element=template");
    exit;
}
else {  # if we get here, this is a new layout
    $card_template = C4::Patroncards::Template->new();
}
if ($template_id) {
    foreach my $profile (@$profile_list) {
        if ($profile->{'profile_id'} == $card_template->get_attr('profile_id')) {
            $profile->{'selected'} = 1;
        }
        else {
            $profile->{'selected'} = 0;
        }
    }
}

foreach my $unit (@$units) {
    if ($unit->{'type'} eq $card_template->get_attr('units')) {
        $unit->{'selected'} = 1;
    }
}

$template->param(
    profile_list         => $profile_list,
    template_id          => ($card_template->get_attr('template_id') > 0) ? $card_template->get_attr('template_id') : '',
    template_code        => $card_template->get_attr('template_code'),
    template_desc        => $card_template->get_attr('template_desc'),
    page_width           => $card_template->get_attr('page_width'),
    page_height          => $card_template->get_attr('page_height'),
    card_width           => $card_template->get_attr('label_width'),
    card_height          => $card_template->get_attr('label_height'),
    top_margin           => $card_template->get_attr('top_margin'),
    left_margin          => $card_template->get_attr('left_margin'),
    cols                 => $card_template->get_attr('cols'),
    rows                 => $card_template->get_attr('rows'),
    col_gap              => $card_template->get_attr('col_gap'),
    row_gap              => $card_template->get_attr('row_gap'),
    units                => $units,
);

output_html_with_http_headers $cgi, $cookie, $template->output;
