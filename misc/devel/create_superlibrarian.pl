#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2016 Koha Development Team
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
use Pod::Usage;

use C4::Installer;
use C4::Context;
use C4::Members;

use Koha::DateUtils;
use Koha::Libraries;
use Koha::Patrons;
use Koha::Patron::Categories;

my $library         = Koha::Libraries->search->next;
my $patron_category = Koha::Patron::Categories->search->next;

die
"Not enough data in the database, library and/or patron category does not exist"
  unless $library and $patron_category;

die "A patron with userid 'koha' already exists"
  if Koha::Patrons->find( { userid => 'koha' } );
die "A patron with cardnumber '42' already exists"
  if Koha::Patrons->find( { cardnumber => 'koha' } );

my $userid   = 'koha';
my $password = 'koha';
my $help;

GetOptions(
    'help|?'   => \$help,
    'userid=s'   => \$userid,
    'password=s' => \$password
);

pod2usage(1) if $help;

AddMember(
    surname      => 'koha',
    userid       => $userid,
    cardnumber   => 42,
    branchcode   => $library->branchcode,
    categorycode => $patron_category->categorycode,
    password     => $password,
    flags        => 1,
);

=head1 NAME

create_superlibrarian.pl - create a user in Koha with superlibrarian permissions

=head1 SYNOPSIS

create_superlibrarian.pl
  [ --userid <userid> ] [ --password <password> ]

 Options:
   -?|--help        brief help message
   --userid         specify the userid to be set (defaults to koha)
   --password       specify the password to be set (defaults to koha)

=head1 OPTIONS

=over 8

=item B<--help|-?>

Print a brief help message and exits

=item B<--userid>

Allows you to specify the userid to be set in the database

=item B<--password>

Allows you to specify the password to be set in the database

=back

=head1 DESCRIPTION

A simple script to create a user in the Koha database with superlibrarian permissions

=cut
