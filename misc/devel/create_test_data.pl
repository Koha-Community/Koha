#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2012 ByWater Solutions
# Copyright (C) 2013 Equinox Software, Inc.
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

use Getopt::Long qw( GetOptions );
use Pod::Usage   qw( pod2usage );

use t::lib::TestBuilder;
my $builder = t::lib::TestBuilder->new;

my $source;
my $values;
my $number;
my $help;
my $verbose;

GetOptions(
    "s|source=s" => \$source,
    "d|data=s%"  => \$values,
    "n|number=i" => \$number,
    "h|help"     => \$help,
    "v|verbose"  => \$verbose,
);

# If we were asked for usage instructions, do it
pod2usage(1) if $help || !$number || !$source;

for ( 1 .. $number ) {

    if ( $source eq 'Biblio' ) {
        $builder->build_sample_biblio($values);
    } elsif ( $source eq 'Item' ) {
        $builder->build_sample_item($values);
    } elsif ( $source eq 'Illrequest' ) {
        $builder->build_sample_ill_request($values);
    } else {
        $builder->build(
            {
                source => $source,
                value  => $values,
            }
        );
    }
}

=head1 NAME

misc/devel/create_test_data.pl

=head1 SYNOPSIS

 create_test_data.pl -n 99 -s ObjectName [ -d foreignkey=somevalue ]

This script allows for quickly generated large numbers of test data for development purposes.

=head1 OPTIONS

=over 8

=item B<-s|--source> <source>

The DBIx::Class ResultSet source to use ( e.g. Branch, Category, EdifactMessage, etc. )

=item B<-d|--data> <valumn>=<value>

Repeatable, set a given column to the specified value for all generated data.

create_test_data.pl -n 5 -s Issue -d borrowernumber=42 -d -d branchcode=MPL

=item B<-n|--number> <number>

The number of rows to create

=item B<-h|--help>

prints this help text

=back
