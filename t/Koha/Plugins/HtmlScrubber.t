#!/usr/bin/perl

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

use Test::More tests => 2;
use Template;

subtest 'test scrubbing using default scrubber' => sub {
    plan tests => 1;
    my $template = Template->new(
        {
            PLUGIN_BASE => 'Koha::Template::Plugin',
        }
    );

    my $tt = <<EOF;
[%- USE HtmlScrubber %]
[%- '<script>alert("boo!")</script><p>Hello!</p>' | scrub_html -%]
[%- '<div id="stuff">Hello!</div>' | scrub_html -%]
EOF

    my $output;
    $template->process( \$tt, {}, \$output );
    is( $output, 'Hello!Hello!', 'Default scrubber removes all HTML' );
};

subtest 'test scrubbing using "note" type' => sub {
    plan tests => 1;
    my $template = Template->new(
        {
            PLUGIN_BASE => 'Koha::Template::Plugin',
        }
    );

    my $tt = <<EOF;
[%- USE HtmlScrubber %]
[%- '<script>alert("boo!")</script><p>Hello!</p>' | scrub_html type => 'note' -%]
[%- '<div id="stuff">Hello!</div>' | scrub_html type => 'note' -%]
EOF

    my $output;
    $template->process( \$tt, {}, \$output );
    is( $output, '<p>Hello!</p><div>Hello!</div>', '<script> element and "id" attribute stripped out' );
};
