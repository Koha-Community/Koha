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

foreach my $type qw(intranet opac) {
    my $template_dir = File::Spec->rel2abs("koha-tmpl/$type-tmpl/prog/en/modules");
    my $include_dir  = File::Spec->rel2abs("koha-tmpl/$type-tmpl/prog/en/includes");
    my $template_test = create_template_test($include_dir);
    find({ wanted => $template_test, no_chdir => 1 }, $template_dir, $include_dir);
}

done_testing();

sub create_template_test {
    my $includes = shift;
    return sub {
	my $tt = Template->new({ABSOLUTE => 1,
				   INCLUDE_PATH => $includes });
	my $vars;
	my $output;
	if ( ! ok($tt->process($_,$vars,\$output), $_) ){
	    diag($tt->error);
	}
    }
}

=head1 AUTHOR

Koha Developement Team <http://koha-community.org>

Chris Cormack <chrisc@catalyst.net.nz>

=cut
