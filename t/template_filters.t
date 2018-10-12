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
use Test::More tests => 5;
use t::lib::QA::TemplateFilters;

subtest 'Asset must use raw' => sub {
    plan tests => 2;
    my $input = <<INPUT;
[% Asset.css("css/one.css") %]
[% Asset.css("js/two.js") %]
INPUT
    my $expected = <<EXPECTED;
[% USE raw %]
[% Asset.css("css/one.css") | \$raw %]
[% Asset.css("js/two.js") | \$raw %]
EXPECTED

    my $new_content = t::lib::QA::TemplateFilters::fix_filters($input);
    is( $new_content . "\n", $expected, );
    my $missing_filters = t::lib::QA::TemplateFilters::search_missing_filters($input);
    is_deeply(
        $missing_filters,
        [
            {
                error       => "asset_must_be_raw",
                line        => '[% Asset.css("css/one.css") %]',
                line_number => 1,
            },
            {
                error       => "asset_must_be_raw",
                line        => '[% Asset.css("js/two.js") %]',
                line_number => 2,
            }

        ],
    );
};

subtest 'Variables must be html escaped' => sub {
    plan tests => 2;

    my $input = <<INPUT;
<title>Koha &rsaquo; Patrons &rsaquo;
    [% UNLESS blocking_error %]
        [% just_a_var %]
        [% just_a_var %] A N D [% another_one_on_same_line %]
    [% END %]
    [% IF ( patron.othernames ) %]&ldquo;[% patron.othernames %]&rdquo;[% END %]
</title>
[% patron_message.get_column('manager_surname') %]
INPUT

    my $expected = <<EXPECTED;
<title>Koha &rsaquo; Patrons &rsaquo;
    [% UNLESS blocking_error %]
        [% just_a_var | html %]
        [% just_a_var | html %] A N D [% another_one_on_same_line | html %]
    [% END %]
    [% IF ( patron.othernames ) %]&ldquo;[% patron.othernames | html %]&rdquo;[% END %]
</title>
[% patron_message.get_column('manager_surname') | html %]
EXPECTED

    my $new_content = t::lib::QA::TemplateFilters::fix_filters($input);
    is( $new_content . "\n", $expected, );
    my $missing_filters = t::lib::QA::TemplateFilters::search_missing_filters($input);
    is_deeply(
        $missing_filters,
        [{
                error => "missing_filter",
                line => "        [% just_a_var %]",
                line_number => 3,
            },
            {
                error => "missing_filter",
                line => "        [% just_a_var %] A N D [% another_one_on_same_line %]",
                line_number => 4,
            },
            {
                error => "missing_filter",
                line => "        [% just_a_var %] A N D [% another_one_on_same_line %]",
                line_number => 4,
            },
            {
                error => "missing_filter",
                line => "    [% IF ( patron.othernames ) %]&ldquo;[% patron.othernames %]&rdquo;[% END %]",
                line_number => 6,
            },
            {
                error => "missing_filter",
                line  => "[% patron_message.get_column('manager_surname') %]",
                line_number => 8
            }
        ],

    );
};

subtest 'TT directives, assignments and already filtered variables must not be escaped' => sub {
    plan tests => 2;
    my $input = <<INPUT;
#[% USE Asset %]
[% INCLUDE 'doc-head-open.inc' %]
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
[% foo UNLESS bar %]
[% SET var = val %]
[% var = val %]
[% var | \$Price %]
[% just_a_var_filtered|html %]
[% just_a_var_filtered |html %]
[% just_a_var_filtered| html %]
[% just_a_var_filtered | html %]
[%END%]
INPUT
    my $expected = <<EXPECTED;
#[% USE Asset %]
[% INCLUDE 'doc-head-open.inc' %]
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
[% foo UNLESS bar %]
[% SET var = val %]
[% var = val %]
[% var | \$Price %]
[% just_a_var_filtered|html %]
[% just_a_var_filtered |html %]
[% just_a_var_filtered| html %]
[% just_a_var_filtered | html %]
[%END%]
EXPECTED

    my $new_content = t::lib::QA::TemplateFilters::fix_filters($input);
    is( $new_content . "\n", $expected, );
    my $missing_filters = t::lib::QA::TemplateFilters::search_missing_filters($input);
    is_deeply(
        $missing_filters,[],);
};

subtest 'Preserve pre/post chomps' => sub {
    plan tests => 1;
    my $input = <<INPUT;
[% USE raw %]
[%- var -%]
[% - var - %]
[%~ var ~%]
[% ~ var ~ %]
[%- var | html -%]
[%~ var | html ~%]
[%- var | uri -%]
[%~ var | uri ~%]
INPUT
    my $expected = <<EXPECTED;
[% USE raw %]
[%- var | html -%]
[%- var | html -%]
[%~ var | html ~%]
[%~ var | html ~%]
[%- var | html -%]
[%~ var | html ~%]
[%- var | uri -%]
[%~ var | uri ~%]
EXPECTED

    my $new_content = t::lib::QA::TemplateFilters::fix_filters($input);
    is( $new_content . "\n", $expected, );
};

subtest 'Use uri filter if needed' => sub {
    plan tests => 3;
    my $input = <<INPUT;
<a href="tel:[% patron.phone %]">[% patron.phone %]</a>
<a href="mailto:[% patron.emailpro %]" title="[% patron.emailpro %]">[% patron.emailpro %]</a>
<a href="mailto:[% patron.emailpro | html %]" title="[% patron.emailpro %]">[% patron.emailpro %]</a>
<a href="mailto:[% patron.emailpro | uri %]" title="[% patron.emailpro %]">[% patron.emailpro %]</a>
<a href="[% myuri %]" title="[% myuri %]">[% myuri %]</a>
<a href="[% myuri | uri %]" title="[% myuri %]">[% myuri %]</a>
<a href="[% myurl | html %]" title="[% myurl %]">[% myurl %]</a>
<a href="[% myurl | url %]" title="[% myurl %]">[% myurl %]</a>
INPUT

    # Note: [% myurl %] will be uri escaped, we cannot know url should be used
    my $expected = <<EXPECTED;
<a href="tel:[% patron.phone | uri %]">[% patron.phone | html %]</a>
<a href="mailto:[% patron.emailpro | uri %]" title="[% patron.emailpro | html %]">[% patron.emailpro | html %]</a>
<a href="mailto:[% patron.emailpro | uri %]" title="[% patron.emailpro | html %]">[% patron.emailpro | html %]</a>
<a href="mailto:[% patron.emailpro | uri %]" title="[% patron.emailpro | html %]">[% patron.emailpro | html %]</a>
<a href="[% myuri | uri %]" title="[% myuri | html %]">[% myuri | html %]</a>
<a href="[% myuri | uri %]" title="[% myuri | html %]">[% myuri | html %]</a>
<a href="[% myurl | uri %]" title="[% myurl | html %]">[% myurl | html %]</a>
<a href="[% myurl | url %]" title="[% myurl | html %]">[% myurl | html %]</a>
EXPECTED

    my $new_content = t::lib::QA::TemplateFilters::fix_filters($input);
    is( $new_content . "\n", $expected, );

    $input = <<INPUT;
<a href="[% wrong_filter | html %]">[% var | html %]</a>
INPUT
    my $missing_filters = t::lib::QA::TemplateFilters::search_missing_filters($input);
    is_deeply(
        $missing_filters,
        [
            {
                error => "wrong_html_filter",
                line =>
                  '<a href="[% wrong_filter | html %]">[% var | html %]</a>',
                line_number => 1
            }

        ],
    );

    $input = <<INPUT;
<a href="[% good_raw_filter | \$raw %]">[% var | html %]</a>
INPUT
    $missing_filters = t::lib::QA::TemplateFilters::search_missing_filters($input);
    is_deeply( $missing_filters, [], );
};
