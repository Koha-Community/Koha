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
use Test::More tests => 1;

use File::Temp;
use File::Path qw/make_path/;

use t::lib::Mocks;

use C4::XSLT;

my $dir = File::Temp->newdir();
my @themes = ('prog', 'test');
my @langs = ('en', 'es-ES');

subtest 'Tests moved from t' => sub {
    plan tests => 8;

# create temporary files to be tested later
foreach my $theme (@themes) {
    foreach my $lang (@langs) {
        make_path("$dir/$theme/$lang/xslt");
        open my $fh, '>', "$dir/$theme/$lang/xslt/my_file.xslt";
        print $fh "Theme $theme, language $lang";
        close $fh;
    }
}

sub find_and_slurp {
    my ($dir, $theme, $lang) = @_;

    my $filename = C4::XSLT::_get_best_default_xslt_filename($dir, $theme, $lang, 'my_file.xslt');
    open my $fh, '<', $filename;
    my $str = <$fh>;
    close $fh;
    return $str;
}

# These tests verify that we're finding the right XSLT file when present,
# and falling back to the right XSLT file when an exact match is not present.
is(find_and_slurp($dir, 'test', 'en'   ), 'Theme test, language en',    'Found test/en');
is(find_and_slurp($dir, 'test', 'es-ES'), 'Theme test, language es-ES', 'Found test/es-ES');
is(find_and_slurp($dir, 'prog', 'en',  ), 'Theme prog, language en',    'Found test/en');
is(find_and_slurp($dir, 'prog', 'es-ES'), 'Theme prog, language es-ES', 'Found test/es-ES');
is(find_and_slurp($dir, 'test', 'fr-FR'), 'Theme test, language en',    'Fell back to test/en for test/fr-FR');
is(find_and_slurp($dir, 'nope', 'es-ES'), 'Theme prog, language es-ES', 'Fell back to prog/es-ES for nope/es-ES');
is(find_and_slurp($dir, 'nope', 'fr-FR'), 'Theme prog, language en',    'Fell back to prog/en for nope/fr-FR');

my $matching_string = q{<syspref name="singleBranchMode">0</syspref>};
my $sysprefs_xml = C4::XSLT::get_xslt_sysprefs();
ok( $sysprefs_xml =~ m/$matching_string/, 'singleBranchMode has a value of 0');
};
