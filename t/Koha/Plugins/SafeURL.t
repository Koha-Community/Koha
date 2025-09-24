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
[%- USE SafeURL %]
[%- 'http://koha-community.org?url=https%3A%2F%2Fkoha-community.org' | safe_url -%]
EOF

    my $output;
    $template->process( \$tt, {}, \$output );
    is( $output, 'http://koha-community.org?url=https%3A%2F%2Fkoha-community.org', 'URL is not double-encoded' );
};

subtest 'double quotes are escaped' => sub {
    plan tests => 1;
    my $template = Template->new(
        {
            PLUGIN_BASE => 'Koha::Template::Plugin',
        }
    );

    my $tt = <<EOF;
[%- USE SafeURL %]
[%- 'http://koha-community.org?url=https%3A%2F%2Fkoha-community.org"' | safe_url -%]
EOF

    my $output;
    $template->process( \$tt, {}, \$output );
    is( $output, 'http://koha-community.org?url=https%3A%2F%2Fkoha-community.org%22', 'double quotes are escaped' );
};
