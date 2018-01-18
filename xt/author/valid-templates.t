#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2011 Catalyst IT
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

=head1 NAME

valid-templates.t

=head1 DESCRIPTION

This test checks all staff and OPAC templates and includes for syntax errors 

=cut


use File::Find;
use File::Spec;
use Template;
use Test::More;

my @themes;

# OPAC themes
my $opac_dir  = 'koha-tmpl/opac-tmpl';
opendir ( my $dh, $opac_dir ) or die "can't opendir $opac_dir: $!";
for my $theme ( grep { not /^\.|lib|js|xslt/ } readdir($dh) ) {
    push @themes, {
        type     => "opac",
        theme    => $theme,
        modules  => "$opac_dir/$theme/en/modules",
        includes => "$opac_dir/$theme/en/includes",
    }
}
close $dh;

# STAFF themes
my $staff_dir = 'koha-tmpl/intranet-tmpl';
opendir ( $dh, $staff_dir ) or die "can't opendir $staff_dir: $!";
for my $theme ( grep { not /^\.|lib|js/ } readdir($dh) ) {
    push @themes, {
        type     => "staff",
        theme    => $theme,
        modules  => "$staff_dir/$theme/en/modules",
        includes => "$staff_dir/$theme/en/includes",
    }
}
close $dh;

# Tests
foreach my $theme ( @themes ) {
    print "Testing $theme->{'type'} $theme->{'theme'} templates\n";
    if ( $theme->{'theme'} eq 'bootstrap' ) {
        run_template_test(
            $theme->{'modules'},
            $theme->{'includes'},
            # templates to exclude from testing because
            # they cannot stand alone
            'doc-head-close.inc',
            'opac-bottom.inc',
        );
    }
    else {
        run_template_test(
            $theme->{'modules'},
            $theme->{'includes'},
        );
    }
}

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
        if ( ! -d $_ ) {    # skip dirs
            if ( !ok( $tt->process( $_, $vars, \$output ), $_ ) ) {
                diag( $tt->error );
            }
        }
    }
}

=head1 AUTHOR

Koha Development Team <http://koha-community.org>

Chris Cormack <chrisc@catalyst.net.nz>

=cut
