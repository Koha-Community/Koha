#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;

use Test::More tests => 8;
use File::Temp;
use File::Path qw/make_path/;

BEGIN {
        use_ok('C4::XSLT');
}

my $dir = File::Temp->newdir();
my @themes = ('prog', 'test');
my @langs = ('en', 'es-ES');

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
