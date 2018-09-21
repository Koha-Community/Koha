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
        error  => q{missing_filter},
        line   => q{        [% just_a_var %] A N D [% another_one_on_same_line %]},
    },
    {
        error  => q{missing_filter},
        line   => q{        [% just_a_var %] A N D [% another_one_on_same_line %]},
    },
    {
        error  => q{missing_filter},
        line   => q{    [% IF ( patron.othernames | html ) %]&ldquo;[% patron.othernames %]&rdquo;[% END %]},
    },
    {
        error  => q{asset_must_be_raw},
        line   => q{    [% Asset.css("css/datatables.css").raw %]},
    },
    {
        error  => q{missing_filter},
        line   => q{<a href="tel:[% patron.phone %]">[% patron.phone %]</a>},
    },
    {
        error  => q{missing_filter},
        line   => q{<a href="tel:[% patron.phone %]">[% patron.phone %]</a>},
    },
    {
        error  => q{missing_filter},
        line   => q{<a title="[% patron.emailpro %]" href="mailto:[% patron.emailpro | uri %]">[% patron.emailpro %]</a>},
    },
    {
        error  => q{missing_filter},
        line   => q{<a title="[% patron.emailpro %]" href="mailto:[% patron.emailpro | uri %]">[% patron.emailpro %]</a>},
    },
    {
        error  => q{missing_filter},
        line   => q{[% patron_message.get_column('manager_surname') %]},
    },
    {
        error  => q{missing_filter},
        line   => q{[%- var -%]},
    },
    {
        error  => q{missing_filter},
        line   => q{[% - var - %]},
    },
    {
        error  => q{missing_filter},
        line   => q{[%~ var ~%]},
    },
    {
        error  => q{missing_filter},
        line   => q{[% ~ var ~ %]},
    }
);

my @get = t::lib::QA::TemplateFilters::missing_filters($input);
is_deeply( \@get, \@expected_errors);
