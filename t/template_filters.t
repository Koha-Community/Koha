# Copyright 2018 Koha Development Team
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
use Test::More tests => 1;
use t::lib::QA::TemplateFilters;

my $input = <<INPUT;
[% USE Asset %]
[% INCLUDE 'doc-head-open.inc' %]
<title>Koha &rsaquo; Patrons &rsaquo;
    [% UNLESS blocking_error %]
        Patron details for [% INCLUDE 'patron-title.inc' no_html = 1 %]
        [% just_a_var %] A N D [% another_one_on_same_line %]
        [% just_a_var_filtered|html %]
        [% just_a_var_filtered |html %]
        [% just_a_var_filtered| html %]
        [% just_a_var_filtered | html %]
    [% END %]
    [% IF ( patron.othernames | html ) %]&ldquo;[% patron.othernames %]&rdquo;[% END %]
    [% Asset.css("css/datatables.css").raw %]
    [% Asset.css("css/datatables.css") | \$raw %]
</title>
<a href="tel:[% patron.phone %]">[% patron.phone %]</a>
<a title="[% patron.emailpro %]" href="mailto:[% patron.emailpro | uri %]">[% patron.emailpro %]</a>
[% patron_message.get_column('manager_surname') %]
[%# do_nothing %]
[% # do_nothing %]
[% SWITCH var %]
[% CASE 'foo' %]foo
[% CASE %]
[% END %]
[%- SWITCH var -%]
[%- CASE 'foo' -%]foo
[%- CASE -%]
[%- END -%]
[%- var -%]
[% - var - %]
[%~ var ~%]
[% ~ var ~ %]
[% var | \$raw %]
[% foo UNLESS bar %]
[% SET var = val %]
[% var = val %]
[%END%]
INPUT

my @expected_errors = (
    {
        error => q{missing_filter},
        line =>
q{        [% just_a_var %] A N D [% another_one_on_same_line %]},
        line_number => 6,
    },
    {
        error => q{missing_filter},
        line =>
q{        [% just_a_var %] A N D [% another_one_on_same_line %]},
        line_number => 6,
    },
    {
        error => q{missing_filter},
        line =>
q{    [% IF ( patron.othernames | html ) %]&ldquo;[% patron.othernames %]&rdquo;[% END %]},
        line_number => 12,
    },
    {
        error       => q{asset_must_be_raw},
        line        => q{    [% Asset.css("css/datatables.css").raw %]},
        line_number => 13,
    },
    {
        error => q{missing_filter},
        line  => q{<a href="tel:[% patron.phone %]">[% patron.phone %]</a>},
        line_number => 16,
    },
    {
        error => q{missing_filter},
        line  => q{<a href="tel:[% patron.phone %]">[% patron.phone %]</a>},
        line_number => 16,
    },
    {
        error => q{missing_filter},
        line =>
q{<a title="[% patron.emailpro %]" href="mailto:[% patron.emailpro | uri %]">[% patron.emailpro %]</a>},
        line_number => 17,
    },
    {
        error => q{missing_filter},
        line =>
q{<a title="[% patron.emailpro %]" href="mailto:[% patron.emailpro | uri %]">[% patron.emailpro %]</a>},
        line_number => 17,
    },
    {
        error       => q{missing_filter},
        line        => q{[% patron_message.get_column('manager_surname') %]},
        line_number => 18,
    },
    {
        error       => q{missing_filter},
        line        => q{[%- var -%]},
        line_number => 29,
    },
    {
        error       => q{missing_filter},
        line        => q{[% - var - %]},
        line_number => 30,
    },
    {
        error       => q{missing_filter},
        line        => q{[%~ var ~%]},
        line_number => 31,
    },
    {
        error       => q{missing_filter},
        line        => q{[% ~ var ~ %]},
        line_number => 32,
    }
);

my @get = t::lib::QA::TemplateFilters::missing_filters($input);
is_deeply( \@get, \@expected_errors);
