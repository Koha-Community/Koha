#!/usr/bin/env perl

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

use Test::More tests => 2;
use Test::NoWarnings;

use Template;

subtest 'Format syspref links' => sub {
    plan tests => 2;

    my $template = Template->new(
        {
            PLUGIN_BASE => 'Koha::Template::Plugin',
        }
    );

    my $tt = <<EOF;
[%- USE LinkPref %]
[%- "OPACBaseURL" | html | \$LinkPref -%]
EOF

    my $output;
    $template->process( \$tt, { CAN_user_parameters_manage_sysprefs => 0 }, \$output );
    is( $output, '<span class="link_preference">OPACBaseURL</span>', 'Link to OPACBaseURL' );

    $output = '';
    $template->process( \$tt, { CAN_user_parameters_manage_sysprefs => 1 }, \$output );
    is(
        $output,
        '<a class="link_preference" href="/cgi-bin/koha/admin/preferences.pl?op=search&ok=Search&searchfield=OPACBaseURL">OPACBaseURL</a>'
    );
};
