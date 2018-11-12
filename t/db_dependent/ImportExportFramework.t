#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 3;
use File::Basename qw( dirname );

use Koha::Database;
use Koha::BiblioFrameworks;
use Koha::MarcSubfieldStructures;
use t::lib::TestBuilder;
use C4::ImportExportFramework;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;

my $data_filepath = dirname(__FILE__) . '/data/biblio_framework.csv';

my $frameworkcode = '4T';
C4::ImportExportFramework::ImportFramework($data_filepath, $frameworkcode);

my $dbh = C4::Context->dbh;

# FIXME Import does not create the biblio framework
#my $biblio_framework = Koha::BiblioFrameworks->find($frameworkcode);
#ok( $biblio_framework );

my $nb_tags = $dbh->selectrow_array(q|SELECT COUNT(*) FROM marc_tag_structure WHERE frameworkcode="4T"|);
is( $nb_tags, 4, "4 tags should have been imported" );

my $nb_subfields =
  Koha::MarcSubfieldStructures->search( { frameworkcode => $frameworkcode } )
  ->count;
is( $nb_subfields, 12, "12 subfields should have been imported" );
