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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use Test::More tests => 3;
use Test::NoWarnings;
use File::Slurp qw( read_file );
use Data::Dumper;
use t::lib::QA::TemplateFilters;
use Koha::Devel::Files;

my $dev_files = Koha::Devel::Files->new;
my @files     = $dev_files->ls_tt_files;

ok( @files > 0, 'We should test something' );

my @errors;
for my $file (@files) {
    my $content = read_file($file);
    my @e       = t::lib::QA::TemplateFilters::missing_filters($content);
    push @errors, { file => $file, errors => \@e } if @e;
}

is( @errors, 0, "Template variables should be correctly escaped" )
    or diag( Dumper @errors );
