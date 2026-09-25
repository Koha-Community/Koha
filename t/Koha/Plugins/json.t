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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 3;
use Template;

subtest 'test double-encoding prevention' => sub {
    plan tests => 1;
    my $template = Template->new(
        {
            PLUGIN_BASE => 'Koha::Template::Plugin',
        }
    );

    my $tt = <<EOF;
[%- USE JSON.Escape %]
[%- '<script>alert("boo");</script>' | json -%]
EOF

    my $output;
    $template->process( \$tt, {}, \$output );
    is( $output, '\u003cscript\u003ealert("boo");\u003c/script\u003e', 'Angle brackets are escaped' );
};

subtest 'Check json filtering' => sub {
    plan tests => 1;
    my $template = Template->new(
        {
            PLUGIN_BASE => 'Koha::Template::Plugin',
        }
    );

    my $tt = <<"EOF";
[%- USE JSON.Escape %]
[%- "&<>+\x{2028}\x{2029}" | json -%]
EOF

    my $output;
    $template->process( \$tt, {}, \$output );
    is( $output, '\u0026\u003c\u003e\u002b\u2028\u2029', 'All problem characters are escaped' );
};
