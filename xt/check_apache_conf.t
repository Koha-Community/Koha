#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 2;

use Test::NoWarnings;

use Array::Utils qw( array_minus );
use File::Slurp  qw(read_file);

subtest 'Intranet RewriteRule statements' => sub {
    plan tests => 1;
    my @debian_content = map { chomp; $_ } read_file('debian/templates/apache-shared-intranet.conf');
    my @httpd_content  = map { chomp; $_ } read_file('etc/koha-httpd.conf');

    my @debian_rewrite_rules =
        map { my $x = $_; $x =~ s/^\s+//; $x =~ m/RewriteRule|RewriteCond/ ? $x : () } @debian_content;

    my @httpd_intranet_rewrite_rules;
    my $pattern = "## Intranet";
    my $found   = 0;
    foreach my $line (@httpd_content) {
        if ( $found && $line !~ m/^#/ && $line =~ m/RewriteRule|RewriteCond/ ) {
            $line =~ s/^\s+//;
            push @httpd_intranet_rewrite_rules, $line;
        } elsif ( $line =~ m/$pattern/ ) {
            $found = 1;
        }
    }
    my @diff = array_minus @debian_rewrite_rules, @httpd_intranet_rewrite_rules;
    is( scalar(@diff), 0, "All RewriteRule and RewriteCond directives must be copied to etc/koha-httpd.conf" )
        or diag @diff;
};
