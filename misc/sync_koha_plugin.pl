#!/usr/bin/perl -w

use strict;
use Getopt::Long;

my %opt = ();
GetOptions(
    \%opt,
    qw/head_dir=s rel_2_2_dir=s help/
) or die "\nHouston, we got a problem\n";

if (exists $opt{help}) {
    print <<FIN;
Sync the Koha plugin with the appropriate files from HEAD. Assumes
that you've set up your Koha install to use CVS symlinked to the
normal locations.

Usage: sync_koha_plugin.pl --head_dir=<cvs head directory>
                           --rel_2_2_dir=<cvs rel_2_2 directory>
                        [--help]

--head_dir: is the directory where your Koha HEAD cvs is checked out.

--rel_2_2_dir: is the directory where your Koha rel_2_2 cvs is checked
out and symlinked to your Koha install directories.

--help: show this help

FIN

      exit(0);
}
# Configurable Variables
foreach my $option (qw/head_dir rel_2_2_dir/) {
  if (not exists $opt{$option}) {
    die 'option "', $option, '" is mandatory', "\n";
  }

  if (not -d $opt{$option}) {
    die '"', $opt{$option}, '" must be an existing directory', "\n";
  }

  if (not $opt{$option} =~ m{^/}) {
    die '--', $option, ' must be an absolute path', "\n";
  }
}

## Modules
system(
    'cp',
    $opt{head_dir}.'/C4/Biblio.pm',
    $opt{rel_2_2_dir}.'/C4/'
);
system(
    'cp',
    $opt{head_dir}.'/C4/Context.pm',
    $opt{rel_2_2_dir}.'/C4/'
);
system(
    'cp',
    $opt{head_dir}.'/C4/SearchMarc.pm',
    $opt{rel_2_2_dir}.'/C4/'
);
system(
    'cp',
    $opt{head_dir}.'/C4/Amazon.pm',
    $opt{rel_2_2_dir}.'/C4/'
);
system(
    'cp',
    $opt{head_dir}.'/C4/Review.pm',
    $opt{rel_2_2_dir}.'/C4/'
);
system(
    'cp',
    $opt{head_dir}.'/C4/Search.pm',
    $opt{rel_2_2_dir}.'/C4/'
);

## Intranet
system(
    'cp',
    $opt{head_dir}.'/cataloguing/addbiblio.pl',
    $opt{rel_2_2_dir}.'/acqui.simple/addbiblio.pl'
);
system(
    'cp',
    $opt{head_dir}.'/cataloguing/additem.pl',
    $opt{rel_2_2_dir}.'/acqui.simple/'
);
system(
    'cp',
    $opt{head_dir}.'/catalogue/detail.pl',
    $opt{rel_2_2_dir}.'/'
);
system(
    'cp',
    $opt{head_dir}.'/catalogue/MARCdetail.pl',
    $opt{rel_2_2_dir}.'/'
);
system(
    'cp',
    $opt{head_dir}.'/catalogue/ISBDdetail.pl',
    $opt{rel_2_2_dir}.'/'
);

# OPAC
system(
    'cp',
    $opt{head_dir}.'/opac/opac-detail.pl',
    $opt{rel_2_2_dir}.'/opac/'
);
system(
    'cp',
    $opt{head_dir}.'/opac/opac-MARCdetail.pl',
    $opt{rel_2_2_dir}.'/opac/'
);
system(
    'cp',
    $opt{head_dir}.'/opac/opac-ISBDdetail.pl',
    $opt{rel_2_2_dir}.'/opac/'
);

## Add the symlink necessary due to changes in the dir structure
system(
    'ln',
    '-s',
    $opt{rel_2_2_dir}.'/koha-tmpl/intranet-tmpl/npl/en/acqui.simple',
    $opt{rel_2_2_dir}.'/koha-tmpl/intranet-tmpl/npl/en/cataloguing'
);

print "Finished\n\nRemember, you still need to:

1. Edit moredetail.tmpl and detail.tmpl to allow for deletions
2. symlink your Koha directory's intranet/zebra dir to the zebra dir
   where the pqf file is
3. add  <option value="biblio.title">Title</option> to the detail.tmpl
   pages to sort by relevance by default

\n";

