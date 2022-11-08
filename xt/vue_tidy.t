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
use File::Slurp qw( read_file );
use File::Find;
use FindBin();
use Data::Dumper qw( Dumper );
use Test::More tests => 1;

my $vue_dir = "$FindBin::Bin/../koha-tmpl/intranet-tmpl/prog/js/vue";

my @files;
sub wanted {
    my $name = $File::Find::name;
    push @files, $name
        if $name =~ /\.vue$/;
}
find({ wanted => \&wanted, no_chdir => 1 }, $vue_dir);

my @not_tidy;
foreach my $filepath (@files) {
    chomp $filepath;
    my $tidy = qx{yarn --silent run prettier --trailing-comma es5 --semi false --arrow-parens avoid $filepath};
    my $content = read_file $filepath;
    if ( $content ne $tidy ) {
        push @not_tidy, $filepath;
    }
}

is(scalar(@not_tidy), 0, 'No vue file should be messy') or diag Dumper \@not_tidy;
