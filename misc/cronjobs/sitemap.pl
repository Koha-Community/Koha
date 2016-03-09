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

package Main;

use Modern::Perl;
use utf8;
use Pod::Usage;
use Getopt::Long;
use C4::Biblio;
use Koha::Sitemapper;


my ($verbose, $help, $url, $dir, $short) = (0, 0, '', '.', 1);
GetOptions(
    'verbose'   => \$verbose,
    'help'      => \$help,
    'url=s'     => \$url,
    'dir=s'     => \$dir,
    'short!'    => \$short,
);

sub usage {
    pod2usage( -verbose => 2 );
    exit;
}

usage() if $help;

unless ($url) {
    $url = C4::Context->preference("OPACBaseURL");
    unless ($url) {
        say "OPACBaseURL syspref isn't defined. You can use --url parameter.";
        exit;
    }
}
$url =~ s/\/*$//g;

my $sitemaper = Koha::Sitemapper->new(
    verbose => $verbose,
    url     => $url,
    dir     => $dir,
    short   => $short,
);
$sitemaper->run();


=head1 USAGE

=over

=item sitemap.pl [--verbose|--help|--short|--noshort|--url|--dir]

=back

=head1 SYNOPSIS

  sitemap.pl --verbose
  sitemap.pl --noshort --url /home/koha/mylibrary/www

=head1 DESCRIPTION

Process all biblio records from a Koha instance and generate Sitemap files
complying with this protocol as described on L<http://sitemaps.org>. The goal of
this script is to be able to provide to search engines direct access to biblio
records. It avoid leaving search engine browsing Koha OPAC and so generating
a lot of traffic, and workload, for a bad result.

A file name F<sitemapindex.xml> is generated. It contains references to Sitemap
multiples files. Each file contains at most 50,000 urls, and is named
F<sitemapXXXX.xml>.

The files must be stored on Koha OPAC root directory, ie
F<<koha-root>/koha-tmpl/>. Place also in this directory a F<robots.txt> file
like this one:

 Sitemap: sitemapindex.xml
 User-agent: *
 Disallow: /cgi-bin/

=head1 PARAMETERS

=over

=item B<--url=Koha OPAC base URL>

If omitted, OPACBaseURL syspref is used.

=item B<--short|noshort>

By default, --short. With --short, URL to bib record ends with
/bib/biblionumber. With --noshort, URL ends with
/cgi-bin/koha/opac-detail.pl?biblionumber=bibnum

=item B<--dir>

Directory where to write sitemap files. By default, the current directory.

=item B<--verbose|-v>

Enable script verbose mode: a message is displayed for each 10,000 biblio
records processed.

=item B<--help|-h>

Print this help page.

=back

=cut
