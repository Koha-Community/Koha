#!/usr/bin/perl

use Modern::Perl;
use Getopt::Long;


use C4::Installer;


my $help;
my $verbose;
my $marcflavour = 'MARC21';

GetOptions(
    'h|help'        => \$help,
    'v|verbose'     => \$verbose,
    'marcflavour=s' => \$marcflavour
);

if ( $help ) {
    print <<HELP;

Automatically installs the Koha default database and on subsequent runs, updatedatabase.pl

updatedatabase.pl-runs are logged into the Koha logdir

  -v --verbose  Get update notifications

  --marcflavour MARC21

  -h --help     This nice help

HELP
}


C4::Installer::install_default_database($verbose, $marcflavour);
C4::Installer::updatedatabase($verbose);
