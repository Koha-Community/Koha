#!/usr/bin/perl

# Copyright 2015 Tamil s.a.r.l.
#
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
use Carp qw/croak/;
use File::Basename;
use File::Path;
use File::Slurp qw( read_file );
use Test::MockModule;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Sitemapper;
use Koha::Sitemapper::Writer;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;
$schema->storage->txn_begin;

subtest 'Sitemapper' => sub {
    plan tests => 12;

    my $now = dt_from_string()->ymd;

    my $biblio1 = $builder->build_sample_biblio;
    $biblio1->set( { datecreated => '2013-11-15', timestamp => '2013-11-15' } )->store;
    my $id1     = $biblio1->id;
    my $biblio2 = $builder->build_sample_biblio;
    $biblio2->set( { datecreated => '2015-08-31', timestamp => '2015-08-31' } )->store;
    my $id2 = $biblio2->id;

    my $dir = C4::Context::temporary_directory;

    # Create a sitemap for a catalog containg 2 biblios, with option 'long url'
    my $sitemapper = Koha::Sitemapper->new(
        verbose => 0,
        url     => 'http://www.mylibrary.org',
        dir     => $dir,
        short   => 0,
    );
    $sitemapper->run( "biblionumber>=$id1" );

    my $file = "$dir/sitemapindex.xml";
    ok( -e "$dir/sitemapindex.xml", 'File sitemapindex.xml created' );
    my $file_content     = read_file($file);
    my $expected_content = <<"EOS";
<?xml version="1.0" encoding="UTF-8"?>

<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <sitemap>
    <loc>http://www.mylibrary.org/sitemap0001.xml</loc>
    <lastmod>$now</lastmod>
  </sitemap>
</sitemapindex>
EOS
    chop $expected_content;
    is( $file_content, $expected_content, 'Its content is valid' );

    $file = "$dir/sitemap0001.xml";
    ok( -e $file, 'File sitemap0001.xml created' );
    $file_content     = read_file($file);
    $expected_content = <<"EOS";
<?xml version="1.0" encoding="UTF-8"?>

<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">
  <url>
    <loc>http://www.mylibrary.org/cgi-bin/koha/opac-detail.pl?biblionumber=$id1</loc>
    <lastmod>2013-11-15</lastmod>
  </url>
  <url>
    <loc>http://www.mylibrary.org/cgi-bin/koha/opac-detail.pl?biblionumber=$id2</loc>
    <lastmod>2015-08-31</lastmod>
  </url>
</urlset>
EOS
    is( $file_content, $expected_content, 'Its content is valid' );

    # Create a sitemap for a catalog containg 2 biblios, with option 'short url'.
    # Test that 2 files are created.
    $sitemapper = Koha::Sitemapper->new(
        verbose => 0,
        url     => 'http://www.mylibrary.org',
        dir     => $dir,
        short   => 1,
    );
    $sitemapper->run( "biblionumber>=$id1" );

    $file = "$dir/sitemap0001.xml";
    ok( -e $file, 'File sitemap0001.xml with short URLs created' );
    $file_content     = read_file($file);
    $expected_content = <<"EOS";
<?xml version="1.0" encoding="UTF-8"?>

<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">
  <url>
    <loc>http://www.mylibrary.org/bib/$id1</loc>
    <lastmod>2013-11-15</lastmod>
  </url>
  <url>
    <loc>http://www.mylibrary.org/bib/$id2</loc>
    <lastmod>2015-08-31</lastmod>
  </url>
</urlset>
EOS
    is( $file_content, $expected_content, 'Its content is valid' );

    # No need to create 75000 biblios here. Let's create 10 more with $MAX == 6.
    # Expecting 3 files: index plus 2 url files with 6 and 4 urls (when we start after biblio2).
    $Koha::Sitemapper::Writer::MAX = 6;
    for my $count ( 0..9 ) {
        my $biblio2 = $builder->build_sample_biblio->set({ datecreated => '2015-08-31', timestamp => '2015-08-31' })->store;
    }

    $sitemapper = Koha::Sitemapper->new(
        verbose => 0,
        url     => 'http://www.mylibrary.org',
        dir     => $dir,
        short   => 1,
    );
    $sitemapper->run( "biblionumber>$id2" ); # Note: new filter

    $file = "$dir/sitemapindex.xml";
    ok( -e "$dir/sitemapindex.xml", 'File sitemapindex.xml for 10 bibs created' );
    $file_content     = read_file($file);
    $expected_content = <<"EOS";
<?xml version="1.0" encoding="UTF-8"?>

<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <sitemap>
    <loc>http://www.mylibrary.org/sitemap0001.xml</loc>
    <lastmod>$now</lastmod>
  </sitemap>
  <sitemap>
    <loc>http://www.mylibrary.org/sitemap0002.xml</loc>
    <lastmod>$now</lastmod>
  </sitemap>
</sitemapindex>
EOS
    chop $expected_content;
    is( $file_content, $expected_content, 'Its content is valid' );

    $file = "$dir/sitemap0001.xml";
    ok( -e $file, 'File sitemap0001.xml created' );

    open my $fh, '<', $file or croak;
    my $count = 0;
    while (<$fh>) {
        if ( $_ =~ /<loc>/xsm ) { $count++; }
    }
    close $fh;
    is( $count, 6, 'It contains 6 URLs' );

    $file = "$dir/sitemap0002.xml";
    ok( -e $file, 'File sitemap0002.xml created' );

    open $fh, '<', $file or croak;
    $count = 0;
    while (<$fh>) {
        if ( $_ =~ /<loc>/xsm ) { $count++; }
    }
    close $fh;
    is( $count, 4, 'It contains 4 URLs' );

    # Cleanup
    for my $file (qw/sitemapindex.xml sitemap0001.xml sitemap0002.xml/) {
        unlink "$dir/$file";
    }
};
$schema->storage->txn_rollback;
