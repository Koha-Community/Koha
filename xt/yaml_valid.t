#!/usr/bin/perl

# Copyright (C) 2012 BibLibre
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
use Test::YAML::Valid;
use File::Find;
use FindBin ();

use Test::More;

my $filebase = "$FindBin::Bin/../koha-tmpl/intranet-tmpl/prog/en/modules/admin/preferences";

my @files;

sub wanted {
    my $name = $File::Find::name;
    push @files, $name
        if $name =~ /\.pref/;
}
find( { wanted => \&wanted, no_chdir => 1 }, $filebase );

plan tests => scalar @files;

foreach my $f (@files) {
    chomp $f;
    yaml_file_ok( $f, "$f is YAML" );
}

=head1 NAME

yaml_valid.t

=head1 DESCRIPTION

=cut

=head1 USAGE

From everywhere:

prove xt/yaml_valid.t

=cut
