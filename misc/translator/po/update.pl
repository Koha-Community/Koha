#!/usr/bin/perl

# Convenience script to update two po files at once
# This emulates the GNOME "update.pl" script

use strict;
use integer;

my $lang = $ARGV[0];
die "Usage: $0 LANG\n" unless $lang =~ /^[a-z]{2}(?:_[A-Z]{2})?$/;

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
      exec('./tmpl_process3.pl', 'update',
	    '-i', "../../koha-tmpl/$module-tmpl/$theme/en/",
	    '-s', "po/${theme}_${module}_$lang.po", '-r');

      die "tmpl_process3.pl: exec: $!\n";
   }
   wait;
}

