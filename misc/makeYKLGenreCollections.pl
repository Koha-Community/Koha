#!/usr/bin/perl
# makeYKLGenreCollections.pl - V161027 - Written by Pasi Korkalo/Koha-Suomi Oy

# Create (selected) genre collections according to YKL genre classes in the
# bibliographic records and set item ccodes to place the items in the created
# collections if they don't belong to another collection already.

# This script will not make direct database modifications. It just prints
# SQL to STDOUT. You can put that in a file and run it in your Koha-database.

# Distributed under "Poetic License" by Alexander Edward Genaud:

# This work 'as-is' we provide.
# No warranty express or implied.
#      We've done our best,
#      to debug and test.
# Liability for damages denied.

# Permission is granted hereby,
# to copy, share, and modify.
#      Use as is fit,
#      free or for profit.
# These rights, on this notice, rely.

use utf8;
use strict;
use warnings;
use C4::Context;

binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

# Asterisk in front will enable creating genre-collection, others will be in generic "GENRE" colletion.
my @YKLgenres=('Eläimet', 'Erotiikka', 'Historia', 'Huumori', 'Urheilu', 'Uskonto', '*Erä', '*Fantasia', '*Jännitys', '*Kauhu', '*Novellit', '*Romantiikka', '*Scifi', '*Sota');

my $dbh=C4::Context->dbh();

my @bibliodata;
my $biblionumber;

my @bibliogenres;
my $genreclass;
my $genrecollection;
my $collectionname;

my $collectioncode;
my @existingcollection;
my @createdcollections;

# Create genre-collections in the database if they don't exist
my $genre_sth=$dbh->prepare("select authorised_value from authorised_values where category = 'CCODE' and authorised_value = ? limit 1");

push (@YKLgenres, "GENRE"); # We want this too
foreach (grep /^\*/, @YKLgenres) {
  $collectioncode=uc(substr($_,1,10));
  $collectioncode=~s/Ä/A/g;
  $genre_sth->execute("$collectioncode");
  @existingcollection=$genre_sth->fetchrow_array();
  unless ( grep /$collectioncode/, @createdcollections or defined $existingcollection[0]) {
    print STDERR "# Adding new genre collection $collectioncode\n";
    if ("$collectioncode" eq "GENRE") {
      $collectionname="Muu genre";
    } else {
      $collectionname=substr($_,1,10);
    }
    print "insert into authorised_values (category, authorised_value, lib, lib_opac) values ('CCODE', '$collectioncode', '$collectionname', '$collectionname');\n";
    push (@createdcollections, $collectioncode);
  }
}
pop @YKLgenres; # Get rid of 'GENRE' colletion now that it is created

# Put items in created collections
my $sth=$dbh->prepare('select biblionumber,ExtractValue(marcxml, \'//datafield[@tag="084"][@ind1="9"]/subfield[@code="a"]\') from biblioitems where ExtractValue(marcxml, \'//datafield[@tag="084"][@ind1="9"]/subfield[@code="a"]\') != \'\';');
$sth->execute();

while (@bibliodata = $sth->fetchrow_array()) {
  undef $genrecollection;
  $biblionumber=$bibliodata[0];
  @bibliogenres=split(' ', $bibliodata[1]);
  foreach $genreclass (@bibliogenres) {
    if (grep /^$genreclass$/, @YKLgenres) {
      print STDERR "# Skipping create genre collection for items in biblio " . $biblionumber . " with YKL genre " . $genreclass . ", using collection 'GENRE' instead.\n";
      $genrecollection="GENRE";
    } elsif (grep /^\*$genreclass$/, @YKLgenres) {
      $genrecollection=substr(uc($genreclass),0,10);
      $genrecollection=~s/Ä/A/g;
    }
    last if defined ($genrecollection);
  }
  # Put items in the collection if they don't belong to some other collection already
  print "update items set ccode='$genrecollection' where biblionumber='$biblionumber' and (ccode is null or ccode='GENRE' or ccode='');\n" if defined($genrecollection);
}

exit 0;
