#!/usr/bin/perl

# Convenience script to update a po file
# This emulates the GNOME "update.pl" script

use strict;
use integer;

my $lang = $ARGV[0];
die "Usage: $0 LANG\n" unless defined $lang && $lang =~ /\S/;

my $chdir_needed_p = 1 unless -d('po'); # guess if pwd is translator/ or po/

for my $spec (['css', 'opac'], ['default', 'intranet']) {
   my($theme, $module) = @$spec;
   my $pid = fork;
   die "fork: $!\n" unless defined $pid;
   if (!$pid) {
      if ($chdir_needed_p) {
	 chdir('..') || die "..: cd: $!\n";
      }
      exec('./tmpl_process3.pl', 'update', '-i', "../../koha-tmpl/$module-tmpl/$theme/en/", '-s', "po/${theme}_${module}_$lang.po", '-r');
      die "tmpl_process3.pl: exec: $!\n";
   }
   wait;
}

