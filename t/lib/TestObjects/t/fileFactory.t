#!/usr/bin/perl

# Copyright KohaSuomi 2016
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
#

use Modern::Perl;
use Test::More;

use t::lib::TestObjects::FileFactory;
use File::Slurp;
use File::Fu::File;

my ($files);
my $subtestContext = {};

$files = t::lib::TestObjects::FileFactory->createTestGroup([
                    {'filepath' => 'atomicupdate',
                     'filename' => '#30-RabiesIsMyDog.pl',
                     'content' => 'print "Mermaids are my only love\nI never let them down";',
                    },
                    {'filepath' => 'atomicupdate',
                     'filename' => '#31-FrogsArePeopleToo.pl',
                     'content' => 'print "Listen to the Maker!";',
                    },
                    {'filepath' => 'atomicupdate',
                     'filename' => '#32-AnimalLover.pl',
                     'content' => "print 'Do not hurt them!;",
                    },
                ], undef, $subtestContext);

my $file30content = File::Slurp::read_file( $files->{'#30-RabiesIsMyDog.pl'}->absolutely );
ok($file30content =~ m/Mermaids are my only love/,
   "'#30-RabiesIsMyDog.pl' created and content matches");
my $file31content = File::Slurp::read_file( $files->{'#31-FrogsArePeopleToo.pl'}->absolutely );
ok($file31content =~ m/Listen to the Maker!/,
   "'#31-FrogsArePeopleToo.pl' created and content matches");
my $file32content = File::Slurp::read_file( $files->{'#32-AnimalLover.pl'}->absolutely );
ok($file32content =~ m/Do not hurt them!/,
   "'#32-AnimalLover.pl' created and content matches");

##addToContext() test, create new file
my $dir = $files->{'#32-AnimalLover.pl'}->dirname();
my $file = File::Fu::File->new("$dir/addToContext.txt");
$file->touch;
t::lib::TestObjects::FileFactory->addToContext($file, undef, $subtestContext);
ok($file->e,
   "'addToContext.txt' created");

t::lib::TestObjects::ObjectFactory->tearDownTestContext($subtestContext);

ok(not(-e $files->{'#30-RabiesIsMyDog.pl'}->absolutely),
   "'#30-RabiesIsMyDog.pl' deleted");
ok(not(-e $files->{'#31-FrogsArePeopleToo.pl'}->absolutely),
   "'#31-FrogsArePeopleToo.pl' deleted");
ok(not(-e $files->{'#32-AnimalLover.pl'}->absolutely),
   "'#32-AnimalLover.pl' deleted");
ok(not(-e $file->absolutely),
   "'addToContext.txt' deleted");

done_testing();
