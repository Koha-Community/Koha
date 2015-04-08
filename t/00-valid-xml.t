# Copyright 2010 Galen Charlton
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

use strict;
use warnings;

use Test::More;
use File::Spec;
use File::Find;
use XML::LibXML;

my $parser = XML::LibXML->new();

find({
    bydepth => 1,
    no_chdir => 1,
    wanted => sub {
        my $file = $_;
        return unless $file =~ /(\.xml|\.xsl|\.xslt)$/i;
        my $dom;
        eval { $dom = $parser->parse_file($file); };
        if ($@) {
            fail("$file parses");
            diag($@);
        } else {
            pass("$file parses");
        }
    },
}, File::Spec->curdir());
done_testing();
