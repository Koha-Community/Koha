#!/usr/bin/perl

# Copyright 2011 Catalyst IT
# 
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings;

=head1 NAME

valid-templates.t

=head1 DESCRIPTION

This test checks all staff and OPAC templates and includes for syntax errors 

=cut


use File::Find;
use File::Spec;
use Template;
use Test::More;
# use FindBin;
# use IPC::Open3;

print "Testing intranet prog templates\n";
run_template_test(
    'koha-tmpl/intranet-tmpl/prog/en/modules',
    'koha-tmpl/intranet-tmpl/prog/en/includes'
);

print "Testing opac bootstrap templates\n";
run_template_test(
    'koha-tmpl/opac-tmpl/bootstrap/en/modules',
    'koha-tmpl/opac-tmpl/bootstrap/en/includes',
    # templates to exclude from testing because
    # they cannot stand alone
    'doc-head-close.inc',
    'opac-bottom.inc',
);

print "Testing opac prog templates\n";
run_template_test(
    'koha-tmpl/opac-tmpl/prog/en/modules',
    'koha-tmpl/opac-tmpl/prog/en/includes'
);

# TODO add test of opac ccsr templates

done_testing();

sub run_template_test {
    my $template_path = shift;
    my $include_path  = shift;
    my @exclusions = @_;
    my $template_dir  = File::Spec->rel2abs($template_path);
    my $include_dir   = File::Spec->rel2abs($include_path);
    my $template_test = create_template_test($include_dir, @exclusions);
    find( { wanted => $template_test, no_chdir => 1 },
        $template_dir, $include_dir );
}

sub create_template_test {
    my $includes = shift;
    my @exclusions = @_;
    return sub {
        my $tt = Template->new(
            {
                ABSOLUTE     => 1,
                INCLUDE_PATH => $includes,
                PLUGIN_BASE  => 'Koha::Template::Plugin',
            }
        );
        foreach my $exclusion (@exclusions) {
            if ($_ =~ /${exclusion}$/) {
                diag("excluding template $_ because it cannot stand on its own");
                return;
            }
        }
        my $vars;
        my $output;
        if ( !ok( $tt->process( $_, $vars, \$output ), $_ ) ) {
            diag( $tt->error );
        }
    }
}

=head1 AUTHOR

Koha Developement Team <http://koha-community.org>

Chris Cormack <chrisc@catalyst.net.nz>

=cut
