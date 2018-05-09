#!/usr/bin/perl

# Copyright 2015 Tamil s.a.r.l.
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;
use File::Basename;
use File::Path;
use DateTime;
use Test::MockModule;
use Test::More tests => 16;
use Koha::Schema;
use Carp qw/croak carp/;

use Koha::UploadedFile;

BEGIN {
    use_ok('Koha::Sitemapper');
    use_ok('Koha::Sitemapper::Writer');
}

my $now_value       = DateTime->now();
my $mocked_datetime = Test::MockModule->new('DateTime');
$mocked_datetime->mock( 'now', sub { return $now_value; } );

sub slurp {
    my $file = shift;
    open my $fh, '<', $file or croak;
    local $/ = undef;
    my $cont = <$fh>;
    close $fh;
    return $cont;
}

use Test::DBIx::Class;

sub fixtures {
    my ($data) = @_;
    fixtures_ok [
        Biblio => [ [qw/ biblionumber datecreated timestamp  /], @{$data}, ],
    ], 'add fixtures';
    return;
}

# Make the code in the module use our mocked Koha::Schema/Koha::Database
my $db = Test::MockModule->new('Koha::Database');
$db->mock(

    # Schema() gives us the DB connection set up by Test::DBIx::Class
    _new_schema => sub { return Schema(); }
);

my $dir = Koha::UploadedFile->temporary_directory;

my $data = [
    [qw/ 1         2013-11-15 2013-11-15/],
    [qw/ 2         2015-08-31 2015-08-31/],
];
fixtures($data);

# Create a sitemap for a catalog containg 2 biblios, with option 'long url'
my $sitemapper = Koha::Sitemapper->new(
    verbose => 0,
    url     => 'http://www.mylibrary.org',
    dir     => $dir,
    short   => 0,
);
$sitemapper->run();

my $file = "$dir/sitemapindex.xml";
ok( -e "$dir/sitemapindex.xml", 'File sitemapindex.xml created' );
my $file_content     = slurp($file);
my $now              = DateTime->now->ymd;
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
$file_content     = slurp($file);
$expected_content = <<"EOS";
<?xml version="1.0" encoding="UTF-8"?>

<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">
  <url>
    <loc>http://www.mylibrary.org/cgi-bin/koha/opac-detail.pl?biblionumber=1</loc>
    <lastmod>2013-11-15</lastmod>
  </url>
  <url>
    <loc>http://www.mylibrary.org/cgi-bin/koha/opac-detail.pl?biblionumber=2</loc>
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
$sitemapper->run();

$file = "$dir/sitemap0001.xml";
ok( -e $file, 'File sitemap0001.xml with short URLs created' );
$file_content     = slurp($file);
$expected_content = <<"EOS";
<?xml version="1.0" encoding="UTF-8"?>

<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">
  <url>
    <loc>http://www.mylibrary.org/bib/1</loc>
    <lastmod>2013-11-15</lastmod>
  </url>
  <url>
    <loc>http://www.mylibrary.org/bib/2</loc>
    <lastmod>2015-08-31</lastmod>
  </url>
</urlset>
EOS
is( $file_content, $expected_content, 'Its content is valid' );

# Create a sitemap for a catalog containing 75000 biblios, with option 'short
# url'. Test that 3 files are created: index file + 2 urls file with
# respectively 50000 et 25000 urls.
$data = [];
for my $count ( 3 .. 75_000 ) {
    push @{$data}, [ $count, '2015-08-31', '2015-08-31' ];
}
fixtures($data);
$sitemapper = Koha::Sitemapper->new(
    verbose => 0,
    url     => 'http://www.mylibrary.org',
    dir     => $dir,
    short   => 1,
);
$sitemapper->run();

$file = "$dir/sitemapindex.xml";
ok( -e "$dir/sitemapindex.xml",
    'File sitemapindex.xml for 75000 bibs created' );
$file_content     = slurp($file);
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
is( $count, 50_000, 'It contains 50000 URLs' );

$file = "$dir/sitemap0002.xml";
ok( -e $file, 'File sitemap0002.xml created' );

open $fh, '<', $file or croak;
$count = 0;
while (<$fh>) {
    if ( $_ =~ /<loc>/xsm ) { $count++; }
}
close $fh;
is( $count, 25_000, 'It contains 25000 URLs' );

# Cleanup
for my $file (qw/sitemapindex.xml sitemap0001.xml sitemap0002.xml/) {
    unlink "$dir/$file";
}
