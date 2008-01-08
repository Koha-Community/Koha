#!/usr/bin/perl

# Convenience script to update two po files at once
# This emulates the GNOME "update.pl" script

use strict;
use integer;
use Getopt::Long;

use vars qw( $pot_p );

GetOptions(
   '--pot' => \$pot_p,
) || exit(1);

my $lang = $ARGV[0];
die <<EOF unless $pot_p || $lang =~ /^[a-z]{2}(?:_[A-Z]{2})?$/;
Usage: $0 LANG
       $0 --pot
EOF

# Remember whether we see the "po" directory; this is used later to guess
# whether the current directory is translator/po or translator.
my $chdir_needed_p = 1 unless -d('po');

# Go through the theme/module combinations we need to update. There can be
# more than two; e.g., if we want ['default', 'opac'] too we can put it in
for my $spec (
      ['css',     'opac'    ],
      ['default', 'intranet']
) {
   my($theme, $module) = @$spec;
   my $pid = fork;
   die "fork: $!\n" unless defined $pid;
   if (!$pid) {

      # If current directory is translator/po instead of translator,
      # then go back to the parent
      if ($chdir_needed_p) {
	 chdir('..') || die "..: cd: $!\n";
      }

      # Now call tmpl_process3.pl to do the real work
      #
      # Traditionally, the pot file should be named PACKAGE.pot
      # (for Koha probably something like koha_intranet_css.pot),
      # but this is not Koha's convention.
      #
      my $target = "po/${theme}_${module}" . ($pot_p? ".pot": "_$lang.po");
      rename($target, "$target~") if $pot_p;
      exec('./tmpl_process3.pl', ($pot_p? 'create': 'update'),
	    '-i', "../../koha-tmpl/$module-tmpl/$theme/en/",
	    '-s', $target, '-r');

      die "tmpl_process3.pl: exec: $!\n";
   }
   wait;
}

