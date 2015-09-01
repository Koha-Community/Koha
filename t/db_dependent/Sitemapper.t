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
use Test::MockModule;
use File::Basename;
use File::Path;
use DateTime;
use Test::More tests => 14;


BEGIN {
    use_ok('Koha::Sitemapper');
    use_ok('Koha::Sitemapper::Writer');
}


sub slurp {
    my $file = shift;
    open my $fh, '<', $file or die;
    local $/ = undef;
    my $cont = <$fh>;
    close $fh;
    return $cont;
}


# Create 3 mocked dataset to be used by Koha::Sitemaper in place of DB content
my $module_context = new Test::MockModule('C4::Context');
$module_context->mock('_new_dbh', sub {
    my $dbh = DBI->connect( 'DBI:Mock:', '', '' )
    || die "Cannot create handle: $DBI::errstr\n";
    return $dbh
});
my $dbh = C4::Context->dbh();
my $two_bibs = [
	[ qw/ biblionumber timestamp  / ],
	[ qw/ 1234         2013-11-15 / ],
	[ qw/ 9875         2015-08-31 / ],
];
my $lotof_bibs = [ [ qw/ biblionumber timestamp / ] ];
push @$lotof_bibs, [ $_, '2015-08-31' ] for 1..75000;
$dbh->{mock_add_resultset} = $two_bibs;
$dbh->{mock_add_resultset} = $two_bibs;
$dbh->{mock_add_resultset} = $lotof_bibs;

my $dir = File::Spec->rel2abs( dirname(__FILE__) );

# Create a sitemap for a catalog containg 2 biblios, with option 'long url'
my $sitemaper = Koha::Sitemapper->new(
    verbose => 0,
    url     => 'http://www.mylibrary.org',
    dir     => $dir,
    short   => 0,
);
$sitemaper->run();

my $file = "$dir/sitemapindex.xml";
ok( -e "$dir/sitemapindex.xml", "File sitemapindex.xml created");
my $file_content = slurp($file);
my $now = DateTime->now->ymd;
my $expected_content = <<EOS;
<?xml version="1.0" encoding="UTF-8"?>

<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <sitemap>
    <loc>http://www.mylibrary.org/sitemap0001.xml</loc>
    <lastmod>$now</lastmod>
  </sitemap>
</sitemapindex>
EOS
chop $expected_content;
ok( $file_content eq $expected_content, "Its content is valid" );

$file = "$dir/sitemap0001.xml";
ok( -e $file, "File sitemap0001.xml created");
$file_content = slurp($file);
$expected_content = <<EOS;
<?xml version="1.0" encoding="UTF-8"?>

<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">
  <url>
    <loc>http://www.mylibrary.org/cgi-bin/koha/opac-detail.pl?biblionumber=1234</loc>
    <lastmod>2013-11-15</lastmod>
  </url>
  <url>
    <loc>http://www.mylibrary.org/cgi-bin/koha/opac-detail.pl?biblionumber=9875</loc>
    <lastmod>2015-08-31</lastmod>
  </url>
</urlset>
EOS
ok( $file_content eq $expected_content, "Its content is valid" );


# Create a sitemap for a catalog containg 2 biblios, with option 'short url'.
# Test that 2 files are created.
$sitemaper = Koha::Sitemapper->new(
    verbose => 0,
    url     => 'http://www.mylibrary.org',
    dir     => $dir,
    short   => 1,
);
$sitemaper->run();

$file = "$dir/sitemap0001.xml";
ok( -e $file, "File sitemap0001.xml with short URLs created");
$file_content = slurp($file);
$expected_content = <<EOS;
<?xml version="1.0" encoding="UTF-8"?>

<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">
  <url>
    <loc>http://www.mylibrary.org/bib/1234</loc>
    <lastmod>2013-11-15</lastmod>
  </url>
  <url>
    <loc>http://www.mylibrary.org/bib/9875</loc>
    <lastmod>2015-08-31</lastmod>
  </url>
</urlset>
EOS
ok( $file_content eq $expected_content, "Its content is valid" );


# Create a sitemap for a catalog containing 75000 biblios, with option 'short
# url'. Test that 3 files are created: index file + 2 urls file with
# respectively 50000 et 25000 urls.
$sitemaper = Koha::Sitemapper->new(
    verbose => 0,
    url     => 'http://www.mylibrary.org',
    dir     => $dir,
    short   => 1,
);
$sitemaper->run();

$file = "$dir/sitemapindex.xml";
ok( -e "$dir/sitemapindex.xml", "File sitemapindex.xml for 75000 bibs created");
$file_content = slurp($file);
$expected_content = <<EOS;
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
ok( $file_content eq $expected_content, "Its content is valid" );

$file = "$dir/sitemap0001.xml";
ok( -e $file, "File sitemap0001.xml created");

open my $fh, "<", $file;
my $count = 0;
while (<$fh>) {
	$count++ if /<loc>/;
}
ok ( $count == 50000, "It contains 50000 URLs");

$file = "$dir/sitemap0002.xml";
ok( -e $file, "File sitemap0002.xml created");

open $fh, "<", $file;
$count = 0;
while (<$fh>) {
	$count++ if /<loc>/;
}
ok ( $count == 25000, "It contains 25000 URLs");

# Cleanup
unlink "$dir/$_" for qw / sitemapindex.xml sitemap0001.xml sitemap0002.xml /;
