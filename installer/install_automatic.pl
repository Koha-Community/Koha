#!/usr/bin/perl

use Modern::Perl;
use Getopt::Long;


use C4::Installer;
use Koha::Caches;
use Koha::SearchEngine::Elasticsearch;

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
    exit 0;
}


C4::Installer::install_default_database($verbose, $marcflavour);

C4::Installer::updatedatabase($verbose);

Koha::Caches::flush();

# Initialize ES mappings
Koha::SearchEngine::Elasticsearch->reset_elasticsearch_mappings;
