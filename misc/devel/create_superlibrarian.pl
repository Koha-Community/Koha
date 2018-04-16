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

use C4::Members;

my ( $help, $surname, $userid, $password, $branchcode, $categorycode, $cardnumber );
GetOptions(
    'help|?'         => \$help,
    'userid=s'       => \$userid,
    'password=s'     => \$password,
    'branchcode=s'   => \$branchcode,
    'categorycode=s' => \$categorycode,
    'cardnumber=s'   => \$cardnumber,
);

pod2usage(1) if $help;
pod2usage("userid is mandatory")       unless $userid;
pod2usage("password is mandatory")     unless $password;
pod2usage("branchcode is mandatory")   unless $branchcode;
pod2usage("categorycode is mandatory") unless $categorycode;
pod2usage("cardnumber is mandatory")   unless $cardnumber;

C4::Members::AddMember(
    surname      => $surname,
    userid       => $userid,
    cardnumber   => $cardnumber,
    branchcode   => $branchcode,
    categorycode => $categorycode,
    password     => $password,
    flags        => 1,
);

=head1 NAME

create_superlibrarian.pl - create a user in Koha with superlibrarian permissions

=head1 SYNOPSIS

create_superlibrarian.pl
  --userid <userid> --password <password> --branchcode <branchcode> --categorycode <categorycode> --cardnumber <cardnumber>

 Options:
   -?|--help        brief help message
   --userid         specify the userid to be set
   --password       specify the password to be set
   --branchcode     specify the library code
   --categorycode   specify the patron category code
   --cardnumber     specify the cardnumber to be set

=head1 OPTIONS

=over 8

=item B<--help|-?>

Print a brief help message and exits

=item B<--userid>

To specify the userid to be set in the database

=item B<--password>

To specify the password to be set in the database

=item B<--branchcode>

Library code

=item B<--categorycode>

Patron category's code

=item B<--cardnumber>

Patron's cardnumber

=back

=head1 DESCRIPTION

A simple script to create a user in the Koha database with superlibrarian permissions

=cut
