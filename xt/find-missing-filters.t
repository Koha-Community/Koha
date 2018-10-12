#!/usr/bin/perl

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
use File::Find;
use File::Slurp;
use Data::Dumper;
use t::lib::QA::TemplateFilters;

my @themes;

# OPAC themes
my $opac_dir  = 'koha-tmpl/opac-tmpl';
opendir ( my $dh, $opac_dir ) or die "can't opendir $opac_dir: $!";
for my $theme ( grep { not /^\.|lib|js|xslt/ } readdir($dh) ) {
    push @themes, "$opac_dir/$theme/en";
}
close $dh;

# STAFF themes
my $staff_dir = 'koha-tmpl/intranet-tmpl';
opendir ( $dh, $staff_dir ) or die "can't opendir $staff_dir: $!";
for my $theme ( grep { not /^\.|lib|js/ } readdir($dh) ) {
    push @themes, "$staff_dir/$theme/en";
}
close $dh;

my @files;
sub wanted {
    my $name = $File::Find::name;
    push @files, $name
        if $name =~ m[\.(tt|inc)$] and -f $name;
}

find({ wanted => \&wanted, no_chdir => 1 }, @themes );

my @errors;
for my $file ( @files ) {
    my $content = read_file($file);
    my $e = t::lib::QA::TemplateFilters::search_missing_filters($content);
    push @errors, { file => $file, errors => $e } if @$e;
}

is( @errors, 0, "Template variables should be correctly escaped" )
    or diag(Dumper @errors);
