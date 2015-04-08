#!/usr/bin/perl

# Copyright (C) 2012 BibLibre
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
use Getopt::Long;
use YAML;

my $usage = <<EOF;
yaml_valid.pl - give it a filename and it will told you if it is an exact yaml file.
    -h|--help           Print this help and exit;
    -f|--file           File to check

  Tests yaml config files
  It does not tell if the params are correct, only if the file is well-formed (ie: readable by yaml)
EOF

my $help = 0;
my $file = 0;
GetOptions(
    "help"   => \$help,
    "file=s" => \$file,
) or die $usage;
die $usage if $help;

say "Testing file: $file";
eval { YAML::LoadFile($file); };
if ($@) {
    print "KO!\n$@\n";
}
else {
    print "Loading and Syntax OK\n";
}

#yaml_file_ok("$file", "$file is YAML");

=head1 NAME

yaml_valid.pl

=head1 DESCRIPTION

  Tests yaml config files
  It does not tell if the params are correct, only if the file is well-formed (ie: readable by yaml)

=head1 USAGE

From Koha root directory:

perl xt/yaml_valid.pl -f filename.yaml

=cut
