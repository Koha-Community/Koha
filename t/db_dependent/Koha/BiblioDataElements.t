# Copyright 2016 KohaSuomi
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
use Test::More;

use Koha::BiblioDataElements;

use t::db_dependent::Koha::BiblioDataElements;
use t::db_dependent::Koha::BiblioDataElements;
use t::lib::TestObjects::ObjectFactory;

my $testContext = {};
my $records = t::db_dependent::Koha::BiblioDataElements::context($testContext);



Koha::BiblioDataElements::forceRebuild(undef, undef, 'oldDbiPlix');



subtest "Happy path", \&happyPath;
sub happyPath {
  my ($bde);

  $bde = Koha::BiblioDataElements->find({ biblioitemnumber => $records->{'BDE-tester-1'}->{biblioitemnumber} });
  is($bde->{biblioitemnumber}, $records->{'BDE-tester-1'}->{biblioitemnumber}, "Bib1. biblionumber");
  is($bde->{deleted}, undef, "Bib1. deleted");
  is($bde->{primary_language}, 'swe', "Bib1. primary language");
  is($bde->{languages}, 'a:swe,a:eng', "Bib1. languages");
  is($bde->{fiction}, 1, "Bib1. fiction");
  is($bde->{musical}, 0, "Bib1. musical");
  is($bde->{itemtype}, 'BK', "Bib1. itemtype");
  is($bde->{serial}, 0, "Bib1. serial");
  is($bde->{encoding_level}, 4, "Bib1. encoding level");

  $bde = Koha::BiblioDataElements->find({ biblioitemnumber => $records->{'BDE-tester-2'}->{biblioitemnumber} });
  is($bde->{biblioitemnumber}, $records->{'BDE-tester-2'}->{biblioitemnumber}, "Bib2. biblionumber");
  is($bde->{deleted}, undef, "Bib2. deleted");
  is($bde->{primary_language}, 'fin', "Bib2. primary language");
  is($bde->{languages}, 'a:swe,a:fin,a:eng', "Bib2. languages");
  is($bde->{fiction}, 0, "Bib2. fiction");
  is($bde->{musical}, 1, "Bib2. musical");
  is($bde->{itemtype}, 'AL', "Bib2. itemtype");
  is($bde->{serial}, 1, "Bib2. serial");
  is($bde->{encoding_level}, 'z', "Bib2. encoding level");
}






t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext);

done_testing();
